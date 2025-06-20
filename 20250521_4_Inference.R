# Problem Set 4

# (4)

# Packages

library(tidyverse)
library(ggpubr)
library(gt)

# Seed

set.seed(0112358)

# Parameters

n = 30
run_vec = seq(1, 100)
beta_vec = seq(0, 0.99, by = 0.01)
rho_vec = seq(0, 0.99, by = 0.01)

value = 3.84

Z = matrix(1, n, 1)

# Simulation

Time_0 = Sys.time()

dat = 
  expand.grid(run = run_vec, rho = rho_vec, b_2 = beta_vec) %>% 
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
         Coefficients_Short = 
           list(M_Short = M_Short, Data_Short = Data_Short, Y = Y) %>% 
           pmap(function(M_Short, Data_Short, Y) M_Short %*% crossprod(Data_Short, Y)),
         Coefficients_Long = 
           list(M_Long = M_Long, Data_Long = Data_Long, Y = Y) %>% 
           pmap(function(M_Long, Data_Long, Y) M_Long %*% crossprod(Data_Long, Y)),
         V_Short = map2(M_Short, sig_2, ~ .x * .y),
         V_Long = M_Long,
         t_1_Short = map2(Coefficients_Short, V_Short, ~ .x[1] ^ 2 / .y[1, 1]),
         t_1_Long = map2(Coefficients_Long, V_Long, ~ .x[1] ^ 2 / .y[1, 1]),
         t_2_Long = map2(Coefficients_Long, V_Long, ~ .x[2] ^ 2 / .y[2, 2]),
         t_Check = 
           list(t_1_Short, t_1_Long, t_2_Long) %>% 
           pmap(function(t_1_Short, t_1_Long, t_2_Long) ifelse(t_2_Long > value, t_1_Long, t_1_Short)),
         Coverage = t_Check %>% map(~ .x < value))

Time_1 = Sys.time()

dat_less = 
  dat %>% 
  unnest(Coverage) %>% 
  group_by(rho, b_2) %>% # Group to compute coverage probabilities.
  summarize(Probability = mean(Coverage)) %>% 
  ungroup

# Tabulate

tab = 
  dat_less %>% 
  filter(rho %in% c(0.30, 0.50, 0.70, 0.80) & b_2 %in% c(0.25, 0.50, 0.75)) %>% 
  gt() %>% 
  tab_header("Selected Results") %>% 
  cols_label(rho = "{{:rho:}}",
             b_2 = "{{:beta:_2}}",
             Probability = "Coverage Probability ({{:beta:_1}})")

gtsave(filename = "output/20250521_PS4_4_Table.png",
       data = tab)

# Visualize

vis = 
  dat_less %>% 
  ggplot() +
  geom_raster(aes(x = rho,
                  y = b_2,
                  fill = Probability),
              hjust = 1,
              vjust = 1) +
  xlab(~ paste(rho)) +
  ylab(~ paste(beta[2])) +
  labs(fill = ~ paste("Coverage Probability (", beta[1], ")")) +
  scale_x_continuous(expand = c(0, 0),
                     breaks = c(0, 1.00)) +
  scale_y_continuous(expand = c(0, 0),
                     breaks = c(0, 1.00)) +
  scale_fill_viridis_c(limits = c(0, 1),
                       breaks = c(0, 1),
                       option = "mako", 
                       guide = guide_colorbar(reverse = TRUE)) +
  coord_fixed() +
  theme_pubr() +
  theme(legend.position = "bottom",
        legend.ticks = element_blank(),
        legend.title = element_text(hjust = 0.50),
        legend.title.position = "bottom",
        legend.key.width = unit(2.25, "lines"),
        axis.title.y = element_text(angle = 0, vjust = 0.5))

ggsave("output/20250521_PS4_4_Plot.png",
       vis,
       dpi = 300,
       width = 3,
       height = 4)
