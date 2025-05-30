# Problem Set 4

# (4)

# Packages

library(tidyverse)
library(ggpubr)

# Seed

set.seed(0112358)

# Parameters

n = 30
run_vec = seq(1, 10)
beta_vec = seq(0, 2, by = 0.50)
rho_vec = seq(0, 0.99, by = 0.50)

value = 3.84

coverage = matrix(NA, length(beta_vec), length(rho_vec)) # probably don't need this

Z = matrix(1, n, 1) # What is this FOR? (Constants?)

# Iterate

dat = 
  expand.grid(run = run_vec, rho = rho_vec, b_2 = beta_vec) %>% # Base R # draw = draw, 
  as_tibble %>% 
  mutate(sd_2 = (1 - rho ^ 2) ^ (1 / 2),
         sig_2 = 1 + b_2 ^ 2 * (1 - rho ^ 2)) %>% 
  group_by(run) %>% # Group so that pseudorandom draws repeat within runs.
  mutate(X_1 = 
           NA %>% 
           map(~ rnorm(n = n)),
         X_2 = 
           list(X_1 = X_1, rho = rho, sd_2 = sd_2) %>% 
           pmap(function(X_1, rho, sd_2) X_1 * rho + rnorm(n = n, mean = 0, sd = sd_2)),
         Y = 
           list(X_2 = X_2, b_2 = b_2) %>% 
           pmap(function(X_2, b_2) X_2 * b_2 + rnorm(n))) %>% 
  ungroup %>% # Ungroup since there are no more pseudorandom draws to set up.
  mutate(Data_Short = map(X_1, ~ cbind(.x, Z)),
         Data_Long = map2(X_1, X_2, ~ cbind(.x, .y, Z)),
         M_Short = map(Data_Short, ~ .x %>% crossprod %>% solve),
         M_Long = map(Data_Long, ~ .x %>% crossprod %>% solve),
         Coefficients_Short = ,
         Coefficients_Long = ,
         )

# Tabulate

# Visualize
