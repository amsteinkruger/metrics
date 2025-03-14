# Problem Set 4

# (2)

# Packages

library(tidyverse)
library(ggpubr)

# (a)

# Data

dat = haven::read_dta("data/descriptive_data.dta")

# Work

vis_a = 
  dat %>%
  select(year, starts_with("CO2")) %>% 
  pivot_longer(cols = starts_with("CO2")) %>% 
  mutate(name = name %>% str_sub(5, -1),
         name = ifelse(name == "OECD", "OECD Sample", name)) %>% 
  ggplot() +
  geom_vline(xintercept = 1990, linetype = "dashed") +
  geom_line(aes(x = year,
                y = value,
                group = name,
                color = name)) +
  scale_x_continuous(breaks = c(seq(1960, 2000, by = 10), 2005)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 3),
                     breaks = c(0, 1, 2, 3)) +
  labs(x = NULL, y = "Metric Tons per Capita (Carbon from Transport)", color = NULL) +
  theme_pubr()

ggsave("output/20250314_PS4_2_a.png",
       vis_a,
       dpi = 300,
       width = 4.5,
       height = 5)

# (b)

# Housekeeping

rm(list = ls())

# Packages

library(Synth)

# Data

# There's some funk between foreign::read.dta and haven::read_dta. Keeping this for a reminder.

# dat = haven::read_dta("data/carbontax_data.dta")

dat <- foreign::read.dta("data/carbontax_data.dta")

# Work

#  Transform panel into a "dataprep" list of matrices for Synth.

dataprep.out <-
  dataprep(foo = dat,
           predictors = c("GDP_per_capita", "gas_cons_capita", "vehicles_capita", "urban_pop"),
           predictors.op = "mean",
           time.predictors.prior = 1980:1989,
           special.predictors =
             list(list("CO2_transport_capita", 1989, "mean"),
                  list("CO2_transport_capita", 1980, "mean"),
                  list("CO2_transport_capita", 1970, "mean")),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:12, 14:15),
           time.optimize.ssr = 1960:1989,
           time.plot = 1960:2005)

#  Get objects out of the dataprep list.

synth.out <- synth(data.prep.obj = dataprep.out, method = "All")

#  Visualize.

png("output/20250314_PS4_2b.png", 
    width = 1800,
    height = 1800,
    bg = NA,
    res = 300)

path.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "Metric Tons per Capita (CO2 from Transport)",
          Xlab = NA,
          Ylim = c(0, 3),
          Legend = c("Sweden", "Synthetic Sweden"),
          Legend.position = "bottomleft")

abline(v = 1990, lty = "dotted", lwd = 2)

dev.off()

#  Get ATT. This borrows code from function gaps.plot() in package Synth.

att = 
  data.frame(year = 1960:2005,
             gap = dataprep.out$Y1plot - (dataprep.out$Y0plot %*% synth.out$solution.w)) %>% 
  rename(gap = 2) %>% 
  as_tibble %>% 
  filter(year > 1989) %>% 
  summarize(att = mean(gap)) %>% 
  pull(att)

# (-0.286)

#  Get weights for later reference.

dat_weights_c = 
  data.frame(dataprep.out$names.and.numbers[2:15, ], synth.out$solution.w) %>% 
  rename(weights_c = 3) %>% 
  as_tibble

# (d)

# Get ATT without GDP per capita.

#  Transform panel into a "dataprep" list of matrices for Synth.

dataprep.out <-
  dataprep(foo = dat,
           predictors = c("gas_cons_capita", "vehicles_capita", "urban_pop"),
           predictors.op = "mean",
           time.predictors.prior = 1980:1989,
           special.predictors =
             list(list("CO2_transport_capita", 1989, "mean"),
                  list("CO2_transport_capita", 1980, "mean"),
                  list("CO2_transport_capita", 1970, "mean")),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:12, 14:15),
           time.optimize.ssr = 1960:1989,
           time.plot = 1960:2005)

#  Get objects out of the dataprep list.

synth.out <- synth(data.prep.obj = dataprep.out, method = "All")

#  Get ATT. This borrows code from function gaps.plot() in package Synth.

att = 
  data.frame(year = 1960:2005,
             gap = dataprep.out$Y1plot - (dataprep.out$Y0plot %*% synth.out$solution.w)) %>% 
  rename(gap = 2) %>% 
  as_tibble %>% 
  filter(year > 1989) %>% 
  summarize(att = mean(gap)) %>% 
  pull(att)

# (-0.272)

# (e)

# Get ATT and weights with New Zealand pulled from the donor pool.

#  This is a really nice example of bad data handling and function design biting the user.

dat_less = dat %>% filter(country != "New Zealand")

dataprep.out <-
  dataprep(foo = dat_less,
           predictors = c("GDP_per_capita", "gas_cons_capita", "vehicles_capita", "urban_pop"),
           predictors.op = "mean",
           time.predictors.prior = 1980:1989,
           special.predictors =
             list(list("CO2_transport_capita", 1989, "mean"),
                  list("CO2_transport_capita", 1980, "mean"),
                  list("CO2_transport_capita", 1970, "mean")),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:8, 10:12, 14:15),
           time.optimize.ssr = 1960:1989,
           time.plot = 1960:2005)

#  Get objects out of the dataprep list.

synth.out <- synth(data.prep.obj = dataprep.out, method = "All")

#  Get ATT. This borrows code from function gaps.plot() in package Synth.

att = 
  data.frame(year = 1960:2005,
             gap = dataprep.out$Y1plot - (dataprep.out$Y0plot %*% synth.out$solution.w)) %>% 
  rename(gap = 2) %>% 
  as_tibble %>% 
  filter(year > 1989) %>% 
  summarize(att = mean(gap)) %>% 
  pull(att)

# (-0.260)

#  Get weights for comparison with an earlier result. Note that object names are bad.

dat_weights_e = 
  data.frame(dataprep.out$names.and.numbers[2:15, ] %>% drop_na, synth.out$solution.w) %>% 
  rename(weights_e = 3) %>% 
  as_tibble

dat_weights = full_join(dat_weights_c, dat_weights_e) %>% mutate(weights_d = weights_c - weights_e)

# weights_d in dat_weights provides the differences to answer (e) in full.

# (f)

# ATT by DD.

dat = dat %>% mutate(treatment = ifelse(country == "Sweden" & year > 1989, 1, 0))

# Note the authors' comment that their predictor variables for weighting are endogenous to the outcome.

# And note that we have too few countries for meaningful clustering (or something -- clustering has nonsense results.)

mod_f <- plm::plm(data = dat, CO2_transport_capita ~ treatment, index = c("country", "year"))

summary(mod_f)
