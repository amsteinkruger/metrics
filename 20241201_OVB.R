# Get packages.

library(tidyverse)
library(magrittr)
library(ggpubr)


# (b)


# Pick a number of observations. 

n = 20000

# Get a plausible income distribution in hundreds of thousands of dollars (?).

I = rnorm(n, 0, 1)

# Get errors.

e = rnorm(n, 0, 1)
u = rnorm(n, 0, 1)

# Consolidate into a tibble and drop implausible observations.

dat = 
  tibble(I, u, e) %>% 
  mutate(F = 2 - 5 * I + u,
         E = 5 + 4 * I + 2 * F + e) %>% 
  filter(I > 0 & F > 0)

rm(n, I , u, e)

# Plot relationships of interest.

vis_I_F = 
  dat %>% 
  ggplot() + 
  geom_point(aes(x = I,
                 y = F),
             alpha = 0.10) +
  theme_pubr()

vis_I_E = 
  dat %>% 
  ggplot() +
  geom_point(aes(x = I,
                 y = E),
             alpha = 0.10) + 
  theme_pubr()

vis_F_E = 
  dat %>% 
  ggplot() + 
  geom_point(aes(x = F,
                 y = E),
             alpha = 0.10) +
  theme_pubr()

vis = ggarrange(vis_I_F, vis_I_E, vis_F_E, nrow = 1)

# Estimate relationships of interest.

mod_omit = lm(E ~ I, dat)

mod = lm(E ~ I + F, dat)

# Check a correlation of interest.

cor(dat$I, dat$F)

# Same but with iteration.

rm(list = ls())

set.seed(7)

n_population = 10000
n_samples = 100

dat = 
  tibble(group = rep(1:n_samples, each = n_population / n_samples),
         e = rnorm(n_population),
         u = rnorm(n_population),
         I = rnorm(n_population),
         F = 2 - 5 * I + u,
         E = 5 + 4 * I + 2 * F + e) %>% 
  filter(I > 0 & F > 0) %>% # Clean out nonsense values of variables. This results in groups of unequal size.
  group_by(group) %>% 
  nest %>% 
  mutate(cor_i_f = map(data, ~ cor(.x$I, .x$F)),
         model_omit = map(data, ~ lm(E ~ I, .x)),
         coefficients_omit = map(model_omit, coef),
         intercept_omit = map(coefficients_omit, extract2, 1),
         beta_i_omit = map(coefficients_omit, extract2, 2),
         model = map(data, ~ lm(E ~ I + F, .x)),
         coefficients = map(model, coef),
         intercept = map(coefficients, extract2, 1),
         beta_i = map(coefficients, extract2, 2),
         beta_f = map(coefficients, extract2, 3)) %>% 
  select(group, cor_i_f, starts_with("bet")) %>% 
  unnest(everything()) %>% 
  ungroup

# Plot distributions of interest.

vis_cor = 
  dat %>% 
  ggplot() +
  geom_histogram(aes(x = cor_i_f),
                 color = NA,
                 fill = "grey75",
                 binwidth = 0.05) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = "Cor(I, F)", 
       y = "Simulations") +
  theme_pubr()

vis_mean_omit = dat %>% pivot_longer(everything()) %>% filter(name == "beta_i_omit") %>% summarize(value = value %>% mean) %>% magrittr::extract2(1)
vis_mean = dat %>% pivot_longer(everything()) %>% filter(name == "beta_i") %>% summarize(value = value %>% mean) %>% magrittr::extract2(1)

vis_bet = 
  dat %>% 
  select(starts_with("beta_i")) %>% 
  pivot_longer(everything()) %>% 
  ggplot() +
  geom_histogram(data = . %>% filter(name == "beta_i_omit"),
                 aes(x = value),
                 fill = "orange",
                 alpha = 0.33,
                 binwidth = 1) +
  geom_histogram(data = . %>% filter(name == "beta_i"),
                 aes(x = value),
                 fill = "blue",
                 alpha = 0.33,
                 binwidth = 1) +
  geom_vline(xintercept = vis_mean_omit,
             color = "orange") +
  geom_vline(xintercept = vis_mean,
             color = "blue") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = "Estimated Effect of I on E", 
       y = "Simulations") +
  theme_pubr()

vis_both = ggarrange(vis_cor, vis_bet, nrow = 1)

ggsave("output/vis_ovb_b.png",
       vis_both,
       dpi = 300,
       width = 8,
       height = 4)
  
# (c)


# Clean up.

rm(list = ls())

# Pick a number of observations. 

n = 100000
age = runif(n, 65 - 16, 65)
edu = runif(n, 10, 20)
exp = age - edu - rnorm(n) # Noise reflects experience and education less than age (and avoids singularity).
e = rnorm(n)
u = rnorm(n)
fem_0 = 2 + 0 * exp + u
fem_1 = 2 + (-4) * exp + u
inc_0 = 1 + 3 * exp + 6 * edu + 3 * age + (-6) * fem_0 + e
inc_1 = 1 + 3 * exp + 6 * edu + 3 * age + (-6) * fem_1 + e

# Estimate relationships of interest.

cor(inc_0, fem_0)
cor(inc_1, fem_1)

mod_uncor_omit = lm(inc_0 ~ exp + edu + age)
mod_uncor = lm(inc_0 ~ exp + edu + age + fem_0)

mod_cor_omit = lm(inc_1 ~ exp + edu + age)
mod_cor = lm(inc_1 ~ exp + edu + age + fem_1)

# Same but with iteration.

rm(list = ls())

set.seed(7)

n_population = 10000
n_samples = 100

dat = 
  tibble(group = rep(1:n_samples, each = n_population / n_samples),
         age = runif(n_population, 65 - 16, 65),
         edu = runif(n_population, 10, 20),
         exp = age - edu - rnorm(n_population), # Noise reflects experience and education less than age.
         e = rnorm(n_population),
         u = rnorm(n_population),
         fem_0 = 2 + 0 * exp + u,
         fem_1 = 2 + (-4) * exp + u,
         inc_0 = 1 + 3 * exp + 6 * edu + 3 * age + (-6) * fem_0 + e,
         inc_1 = 1 + 3 * exp + 6 * edu + 3 * age + (-6) * fem_1 + e) %>% 
  group_by(group) %>% 
  nest %>% 
  mutate(cor_0 = map(data, ~ cor(.x$exp, .x$fem_0)),
         cor_1 = map(data, ~ cor(.x$exp, .x$fem_1)),
         mod_uncor_omit = map(data, ~ lm(inc_0 ~ exp + edu + age, .x)),
         coef_uncor_omit = map(mod_uncor_omit, coef),
         beta_uncor_omit = map(coef_uncor_omit, extract2, 2),
         mod_uncor = map(data, ~ lm(inc_0 ~ exp + edu + age + fem_0, .x)),
         coef_uncor = map(mod_uncor, coef),
         beta_uncor = map(coef_uncor, extract2, 2),
         mod_cor_omit = map(data, ~ lm(inc_1 ~ exp + edu + age, .x)),
         coef_cor_omit = map(mod_cor_omit, coef),
         beta_cor_omit = map(coef_cor_omit, extract2, 2),
         mod_cor = map(data, ~ lm(inc_1 ~ exp + edu + age + fem_1, .x)),
         coef_cor = map(mod_cor, coef),
         beta_cor = map(coef_cor, extract2, 2)) %>% 
  select(group, starts_with("cor"), starts_with("bet")) %>% 
  unnest(everything()) %>% 
  ungroup

# Plot distributions of interest.

#  Actually, just report means of correlations to avoid a goofy histogram.
dat$cor_0 %>% mean
dat$cor_1 %>% mean

vis_mean_uncor_omit = dat %>% pivot_longer(everything()) %>% filter(name == "beta_uncor_omit") %>% summarize(value = value %>% mean) %>% magrittr::extract2(1)
vis_mean_uncor = dat %>% pivot_longer(everything()) %>% filter(name == "beta_uncor") %>% summarize(value = value %>% mean) %>% magrittr::extract2(1)
vis_mean_cor_omit = dat %>% pivot_longer(everything()) %>% filter(name == "beta_cor_omit") %>% summarize(value = value %>% mean) %>% magrittr::extract2(1)
vis_mean_cor = dat %>% pivot_longer(everything()) %>% filter(name == "beta_cor") %>% summarize(value = value %>% mean) %>% magrittr::extract2(1)

vis_uncor = 
  dat %>% 
  select(starts_with("beta_uncor")) %>% 
  pivot_longer(everything()) %>% 
  ggplot() +
  geom_histogram(data = . %>% filter(name == "beta_uncor_omit"),
                 aes(x = value),
                 fill = "orange",
                 alpha = 0.33,
                 binwidth = 0.10) +
  geom_histogram(data = . %>% filter(name == "beta_uncor"),
                 aes(x = value),
                 fill = "blue",
                 alpha = 0.33,
                 binwidth = 0.10) +
  geom_vline(xintercept = vis_mean_uncor_omit,
             color = "orange") +
  geom_vline(xintercept = vis_mean_uncor,
             color = "blue") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = "Estimated Effect of Exp. on Inc.", 
       y = "Simulations",
       title = "Cor(Exp., Fem.) = 0") +
  theme_pubr()

vis_cor = 
  dat %>% 
  select(starts_with("beta_cor")) %>% 
  pivot_longer(everything()) %>% 
  ggplot() +
  geom_histogram(data = . %>% filter(name == "beta_cor_omit"),
                 aes(x = value),
                 fill = "goldenrod1",
                 alpha = 0.33,
                 binwidth = 0.50) +
  geom_histogram(data = . %>% filter(name == "beta_cor"),
                 aes(x = value),
                 fill = "purple",
                 alpha = 0.33,
                 binwidth = 0.50) +
  geom_vline(xintercept = vis_mean_cor_omit,
             color = "goldenrod1") +
  geom_vline(xintercept = vis_mean_cor,
             color = "purple") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = "Estimated Effect of Exp. on Inc.", 
       y = "Simulations",
       title = "Cor(Exp., Fem.) = -1") +
  theme_pubr()

vis_both = ggarrange(vis_uncor, vis_cor, nrow = 1)

ggsave("output/vis_ovb_d.png",
       vis_both,
       dpi = 300,
       width = 8,
       height = 4)