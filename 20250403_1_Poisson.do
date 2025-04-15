* Problem Set 1

log using 20250414_Log, replace

* (1)

*  Set up the problem.

clear all

set iterlog off
set obs 100

gen id = _n

gen d = 0
replace d = 1 if id < 51

gen packs = 0
replace packs = 1 if id > 30
replace packs = 2 if id > 45
replace packs = 0 if id > 50
replace packs = 1 if id > 85
replace packs = 2 if id > 95

gen cigarettes = packs * 20

sum

* (d)

poisson packs i.d // Poisson

mlexp(-exp({xb: d _cons}) + packs * {xb:} - lnfactorial(packs)), vce(robust) // ML

nl (packs = {b0} + {b1} * d) // NLLS

* (e)

sum packs if d == 0
sum packs if d == 1

* (f)

poisson cigarettes i.d // Poisson

mlexp(-exp({xb: d _cons}) + cigarettes * {xb:} - lnfactorial(cigarettes)), vce(robust) // ML

nl (cigarettes = {b0} + {b1} * d) // NLLS