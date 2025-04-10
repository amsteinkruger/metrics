* Problem Set 1

* (2)

clear all

use "data/smoke.dta"

gen college = 0
replace college = 1 if educ > 15

sum

* (a)

sum cigs

histogram cigs

* (b)

gen cigs_arcsinh = asinh(cigs)

reg cigs_arcsinh i.college age income

* (c)

gen cigs_log1 = log(cigs + 1)

reg cigs_log1 i.college age income

* (d)

gen packs_arcsinh = asinh(packs)

reg packs_arcsinh i.college age income

gen packs_log1 = log(packs + 1)

reg packs_log1 i.college age income

* (e)

* Poisson model goes here.

* (f)

* Extensive margin by OLS goes here.

* (g)

keep if cigs > 0

reg cigs_arcsinh i.college age income
reg cigs_log1 i.college age income

reg packs_arcsinh i.college age income
reg packs_log1 i.college age income

* Poisson
* Extensive margin

* (h)

gen cigs_log = log(cigs)
gen packs_log = log(packs)

reg cigs_log i.college age income
reg packs_log i.college age income
