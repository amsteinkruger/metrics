# Problem Set 4

# (1)

# Packages

library(tidyverse)
library(ggpubr)
library(plm)
library(lmtest)
library(did)

# Data

dat = haven::read_dta("data/wolfers.dta") %>% select(-starts_with("state"))

# Work

# (b)

#  Is the panel balanced on counts of observations?

dat %>% 
  group_by(st) %>% 
  summarize(count = n()) %>% 
  group_by(count) %>% 
  summarize(count = n())

#  (Yes.)

#  Is the panel balanced on div_rate?

dat %>% 
  drop_na(div_rate) %>% 
  group_by(st) %>% 
  summarize(count = n()) %>% 
  group_by(count) %>%
  summarize(count = n())

#  (No.)

#  Get a balanced panel by dropping states with any observations missing div_rate.

dat = 
  dat %>% 
  mutate(check = is.na(div_rate)) %>% 
  group_by(st) %>% 
  mutate(check = sum(check)) %>% 
  ungroup %>% 
  filter(check == 0) %>% 
  select(-check)

# (c)

# Plot the cumulative proportion of states with no-fault laws against study years.

vis_c = 
  dat %>% 
  group_by(year) %>% 
  summarize(pro = sum(unilateral / n())) %>% 
  ungroup %>% 
  ggplot() +
  geom_vline(xintercept = 1969,
             color = "#D73F09",
             linewidth = 1.00) +
  geom_vline(xintercept = 1985,
             color = "#D73F09",
             linewidth = 1.00) +
  geom_line(aes(x = year,
                y = pro),
            linewidth = 1.00) +
  scale_x_continuous(limits = c(1955, 1989),
                     breaks = c(1956, 1969, 1985),
                     expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1),
                     breaks = c(0, 0.50, 1),
                     expand = c(0, 0)) +
  labs(y = "Proportion of States with UDLs") +
  theme_pubr() +
  theme(axis.title.x = element_blank())

ggsave("output/20250311_PS4_1.png",
       vis_c,
       dpi = 300,
       width = 4.5,
       height = 4.5)

# (d)

# What's the largest treatment group?

dat %>% 
  group_by(lfdivlaw) %>% 
  summarize(count = n()) %>% 
  ungroup %>% 
  arrange(desc(count))

# (Never Treated, then 1973, then 1973.)

# What proportion of states are in the largest treatment group?

dat %>% 
  group_by(lfdivlaw) %>% 
  summarize(count = n()) %>% 
  ungroup %>% 
  mutate(proportion = count / sum(count)) %>% 
  filter(lfdivlaw == 1973)

# 0.19

# What proportion of states are in the never-treated group?

dat %>% 
  group_by(lfdivlaw) %>% 
  summarize(count = n()) %>% 
  ungroup %>% 
  mutate(proportion = count / sum(count)) %>% 
  filter(lfdivlaw == 2000)

# 0.35

# Get rid of units that are unobserved before treatment.

dat = dat %>% filter(st != "AK" & st != "OK")

# (e)

# Run TWFE on state and year. Cluster on state for appropriate standard errors.

mod_e <- plm(data = dat, div_rate ~ unilateral, index = c("st", "year"))

coeftest(mod_e, vcov = vcovHC, type = "HC1")

# stargazer or something

# (f)

# Estimate ATT(g, t) following Callaway and Sant'Anna (2021).

# Tweak state names for did::att_gt().

dat = dat %>% mutate(st_numeric = st %>% factor %>% as.numeric)

mod_f <- att_gt(yname = "div_rate",
                gname = "lfdivlaw",
                idname = "st_numeric",
                tname = "year",
                xformla = ~1,
                data = dat,
                est_method = "reg")

summary(mod_f)

