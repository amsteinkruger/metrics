# Find covariance of errors in intercept and coefficient estimates for simple linear regressions on simulated disjoint samples.

library(tidyr)
library(dplyr)
library(purrr)
library(magrittr)

set.seed(7)

n_population = 1000
n_samples = 100

mean_population = 4
sd_population = 2

mean_noise = 2
sd_noise = 1

alpha_population = 1
beta_population = 3

dat = 
  tibble(group = rep(1:n_samples, each = n_population / n_samples),
         x = rnorm(n_population, mean_population, sd_population),
         y = (alpha_population + beta_population * x) + rnorm(n_population, mean_noise, sd_noise)) %>% 
  group_by(group) %>% 
  nest %>% 
  mutate(model = 
           map(data,
               ~ lm(y ~ x, .x)),
         coefficients = 
           map(model,
               coef),
         alpha = 
           map(coefficients,
               extract2,
               1),
         beta = 
           map(coefficients,
               extract2,
               2),
         alpha_error = 
           map(alpha,
               ~ subtract(.x, alpha_population)),
         beta_error = 
           map(beta,
               ~ subtract(.x, beta_population)))

vis_population = 
  dat %>% 
  ungroup %>% 
  select(data) %>% 
  unnest %>% 
  ggplot() +
  geom_point(aes(x = x,
                 y = y),
             alpha = 0.50)

vis_coef = 
  dat %>% 
  ungroup %>% 
  select(alpha, beta) %>% 
  unnest %>% 
  ggplot() +
  geom_point(aes(x = beta,
                 y = alpha),
             alpha = 0.50)

vis_error = 
  dat %>% 
  ungroup %>% 
  select(alpha_error, beta_error) %>% 
  unnest %>% 
  ggplot() + 
  geom_point(aes(x = beta_error,
                 y = alpha_error),
             alpha = 0.50)

dat_cov = 
  dat %>% 
  ungroup %>% 
  select(alpha, beta) %>% 
  unnest

val_cov = cov(dat_cov$alpha, dat_cov$beta)

val_cov

dat_cov_error = 
  dat %>% 
  ungroup %>% 
  select(alpha_error, beta_error) %>% 
  unnest

val_cov_error = cov(dat_cov_error$alpha_error, dat_cov_error$beta_error)

val_cov_error

val_cov_error == val_cov
