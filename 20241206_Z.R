# Get packages.

library(tidyverse)
library(magrittr)
library(ggpubr)

# (b)

set.seed(7)

n_sample_1 = 10
n_sample_2 = 1000
n_sample_3 = 10000
n_samples = 1000
n_total = n_samples * (n_sample_1 + n_sample_2 + n_sample_3)

dat = 
  tibble(which = 
           c(rep(1, n_sample_1 * n_samples),
             rep(2, n_sample_2 * n_samples),
             rep(3, n_sample_3 * n_samples)),
         group = 
           c(rep(1:n_samples, each = n_sample_1),
             rep(1:n_samples, each = n_sample_2),
             rep(1:n_samples, each = n_sample_3)),
         e = rnorm(n_total),
         u = rnorm(n_total),
         Z = rnorm(n_total),
         X = 1 + 2 * Z + u,
         Y = 1 + 5 * X + e) %>% 
  group_by(which, group) %>% 
  nest %>% 
  mutate(model_x = map(data, ~ lm(Y ~ X, .x)),
         coefficients_x = map(model_x, coef),
         beta_x = map(coefficients_x, extract2, 2),
         model_z = map(data, ~ lm(Y ~ Z, .x)),
         coefficients_z = map(model_z, coef),
         beta_z = map(coefficients_z, extract2, 2)) %>% 
  select(which, group, starts_with("beta")) %>% 
  unnest(everything()) %>% 
  ungroup

# Plot distributions of interest.

vis_mean_1 = dat %>% filter(which == 1) %>% pull(beta_z) %>% mean
vis_mean_2 = dat %>% filter(which == 2) %>% pull(beta_z) %>% mean
vis_mean_3 = dat %>% filter(which == 3) %>% pull(beta_z) %>% mean

vis = 
  dat %>% 
  select(which, beta_z) %>% 
  mutate(which_nice = ifelse(which == 1, "n = 10", ifelse(which == 2, "n = 1000", "n = 10000"))) %>% 
  ggplot() +
  geom_histogram(data = . %>% filter(which == 1),
                 aes(x = beta_z),
                 fill = "blue",
                 alpha = 0.25,
                 binwidth = 0.25) +
  geom_histogram(data = . %>% filter(which == 2),
                 aes(x = beta_z),
                 fill = "blue",
                 alpha = 0.50,
                 binwidth = 0.25) +
  geom_histogram(data = . %>% filter(which == 3),
                 aes(x = beta_z),
                 fill = "blue",
                 alpha = 0.75,
                 binwidth = 0.25) +
  geom_vline(xintercept = vis_mean_1) +
  geom_vline(xintercept = vis_mean_2) +
  geom_vline(xintercept = vis_mean_3) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 1000),
                     breaks = seq(0, 1000, by = 250)) +
  labs(x = "Estimated Effect", 
       y = "Simulations") +
  theme_pubr() +
  facet_wrap(~ which_nice, 
             nrow = 1)

ggsave("output/vis_z.png",
       vis,
       dpi = 300,
       width = 8,
       height = 4)
