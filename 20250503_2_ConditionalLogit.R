# Problem Set 3

# (2)

# Packages

library(tidyverse)
library(ggpubr)
library(haven)
library(logitr)

# Data

dat = read_dta("data/FIAPlots_CC.dta")

# (a)

model = logitr(data = dat, 
               outcome = "d", 
               obsID = "id", 
               pars = "r",
               robust = TRUE)
