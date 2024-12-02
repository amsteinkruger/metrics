# Get packages.

library(magrittr)
library(dplyr)
library(ggplot2)
library(ggpubr)


# (b)


# Pick a number of observations. 

n = 20000

# Get a plausible income distribution in hundreds of thousands of dollars (?).

I = rnorm(n, 0, 1)

# Get errors.

u = rnorm(n, 0, 1)
e = rnorm(n, 0, 1)

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

mod_omit = lm(inc_0 ~ exp + edu + age)

mod = lm(inc_1 ~ exp + edu + age + fem_1)
