# Problem Set 4

# (1)

# Packages

library(tidyverse)
library(ggpubr)
library(plm)
library(lmtest)
library(did)
library(didimputation)
library(stargazer)

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

# Plot the cumulative proportion of treated units against years.

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

mod_e <- plm(data = dat, div_rate ~ unilateral, effect = "twoways", index = c("st", "year"))

mod_e_cluster = coeftest(mod_e, vcov = vcovHC, type = "HC1", save = TRUE)

stargazer(mod_e, 
          coef = list("unilateral" = mod_e_cluster[1, 1]),
          se = list("unilateral" = mod_e_cluster[1, 2]),
          t = list("unilateral" = mod_e_cluster[1, 3]),
          p = list("unilateral" = mod_e_cluster[1, 4]),
          type = "html", 
          out = "output/20250314_PS4_1_e.html")

# (f)

# Estimate ATT(g, t) following Callaway and Sant'Anna (2021).

# Tweak state names for did::att_gt().

dat = dat %>% mutate(st_numeric = st %>% factor %>% as.numeric)

mod_f <- att_gt(data = dat,
                yname = "div_rate",
                gname = "lfdivlaw",
                idname = "st_numeric",
                tname = "year",
                xformla = ~1,
                clustervars = "st_numeric",
                est_method = "reg")

summary(mod_f)

# Count post-treatment periods.

dat_f = tibble(group = mod_f$group, t = mod_f$t, att = mod_f$att)

dat_f %>% filter(group <= t) %>% nrow

# 148 periods where treatment year is equal to or greater than the current year. Is that the right subset?

# Get a histogram for fun.

vis_f = 
  dat_f %>% 
  mutate(which = ifelse(group <= t, "post", "pre") %>% factor %>% fct_rev) %>% 
  ggplot() +
  geom_histogram(aes(x = att)) +
  facet_wrap(~ which)

# (g)

# Get ATT(1976, 1980) with sample means.

# Grab the answer from (f) for convenience.

dat_f %>% filter(group == 1976 & t == 1980) %>% pull(att)

# (0.44)

#  Count units in 1976 treatment group.

dat %>% distinct(st, lfdivlaw) %>% filter(lfdivlaw == 1976) %>% nrow # It's just Rhode Island.

#  Set up terms for the expression to estimate ATT. This is a mess.

g_Y_it = dat %>% filter(lfdivlaw == 1976 & year == 1980) %>% pull(div_rate) %>% as.numeric

g_Y_ig1 = dat %>% filter(lfdivlaw == 1976 & year == 1975) %>% pull(div_rate) %>% as.numeric

g_N_G_comp = dat %>% filter(lfdivlaw > 1980) %>% pull(st) %>% unique %>% length

g_Y = 
  dat %>% 
  filter(lfdivlaw > 1980 & (year == 1980 | year == 1975)) %>% 
  mutate(div_rate = ifelse(year == 1975, div_rate * -1, div_rate)) %>% 
  summarize(div_rate = sum(div_rate)) %>% 
  pull(div_rate)


#  Estimate ATT.

g_ATT = g_Y_it - g_Y_ig1 - g_N_G_comp ^ -1 * g_Y

# (0.425)

# Note discrepancy. Tweaking filters doesn't help.

# (h)

# Compare overall ATTs between C-S '21 and TWFE.

#  CS '21 with weights by fraction of treated units in each group.

aggte(mod_f, type = "simple")$overall.att 

#  CS '21 with weights by group size (equivalent to equal weights in this application).

aggte(mod_f, type = "group")$overall.att 

# TWFE

mod_e$coefficients[[1]] 

# (i)

mod_i = 
  mod_f %>% 
  aggte(type = "dynamic",
        min_e = -5,
        max_e = 5)

summary(mod_i)

vis_i = ggdid(mod_i) + scale_y_continuous(limits = c(-1.5, 1)) + theme(plot.title = element_blank())

mod_i_dr = 
  att_gt(data = dat,
         yname = "div_rate",
         idname = "st_numeric",
         gname = "lfdivlaw",
         tname = "year",
         xformla = ~ log_income,
         clustervars = "st_numeric",
         est_method = "dr") %>% 
  aggte(type = "dynamic",
        min_e = -5,
        max_e = 5)

summary(mod_i_dr)

vis_i_dr = ggdid(mod_i_dr) + scale_y_continuous(limits = c(-1.5, 1)) + theme(plot.title = element_blank())

vis_i_both = ggarrange(vis_i, vis_i_dr, nrow = 1)

ggsave("output/20250314_PS4_1i.png",
       vis_i_both,
       dpi = 300,
       width = 6.5)

# (j)

# Without log_income. Note that the arguments to first_stage and cluster_var are equivalent to defaults.

mod_j_1 = 
  did_imputation(data = dat,
                 yname = "div_rate",
                 idname = "st_numeric",
                 gname = "lfdivlaw",
                 tname = "year",
                 first_stage = ~ 0 | st_numeric + year,
                 horizon = TRUE,
                 pretrends = -5:-1,
                 cluster_var = "st_numeric") %>% 
  mutate(model = "Without Covariates")

tab_j_1 = mod_j_1 %>% filter(term %in% (-5:5 %>% as.character)) %>% mutate(across(3:6, ~round(., 3))) %>% gt

gtsave(tab_j_1, "output/20250314_PS4_1j_1.png")

# With log_income.

mod_j_2 = 
  did_imputation(data = dat,
                 yname = "div_rate",
                 idname = "st_numeric",
                 gname = "lfdivlaw",
                 tname = "year",
                 first_stage = ~ log_income * year | st_numeric + year,
                 horizon = TRUE,
                 pretrends = -5:-1,
                 cluster_var = "st_numeric") %>% 
  mutate(model = "With Interaction Covariate")

tab_j_2 = mod_j_2 %>% filter(term %in% (-5:5 %>% as.character)) %>% mutate(across(3:6, ~round(., 3))) %>% gt

gtsave(tab_j_2, "output/20250314_PS4_1j_2.png")

# Get estimates out and visualize.

mod_j = 
  bind_rows(mod_j_1, mod_j_2) %>% 
  mutate(model = model %>% factor %>% fct_rev) %>% 
  filter(term %in% -5:5) %>% 
  mutate(treatment = ifelse(term < 0, "Pre", "Post") %>% factor %>% fct_rev,
         term = term %>% factor %>% fct_relevel(-5:5 %>% as.character))

vis_j = 
  mod_j %>% 
  ggplot() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_linerange(aes(x = term, ymin = conf.low, ymax = conf.high, color = treatment)) +
  geom_point(aes(x = term, y = estimate, color = treatment)) +
  scale_x_discrete(breaks = -5:5 %>% as.character) +
  scale_y_continuous() +
  facet_wrap(~ model) +
  labs(x = "Event Time", y = "Estimate") +
  theme_pubr() +
  theme(legend.position = "none")

ggsave("output/20250314_PS4_2j_3.png",
       vis_j,
       dpi = 300,
       width = 6.5)