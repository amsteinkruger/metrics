* Problem Set 3

* (4)

clear all

* Get experimental data.

use "data/nsw_dw.dta"

* Get the experimental treatment effect shown in lecture for reference.

sort treat
by treat: egen mean = mean(re78)
egen less = min(mean)
egen more = max(mean)
gen effect = more - less
quietly sum effect
display "Experimental Treatment Effect: " r(mean)

drop mean less more effect

* Get observational data.

append using "data/cps_controls3.dta"

* Drop experimental control data.

drop if data_id == "Dehejia-Wahba Sample" & treat == 0

* Get the replication treatment effect shown in lecture for reference.

sort treat
by treat: egen mean = mean(re78)
egen less = min(mean)
egen more = max(mean)
gen effect = more - less
quietly sum effect
display "Replication Treatment Effect: " r(mean)

drop mean less more effect

* Note that this has the right sign, so we might expect the CPS control to provide better balance.

* Set up a unique ID for reshape.

gen unit_id = _n

* (a)

reshape long re, i(unit_id) j(year) // Because it's easier to estimate with long data.

gen treat_post = (year == 78 & treat == 1)

reghdfe re treat_post if year != 75, absorb(unit_id year) cluster(unit_id)

drop treat_post // The hassle with reshape isn't worth it.

reshape wide re, i(unit_id) j(year) // Because stddiff looks for wide data.

* (b)

* Get a package.

* ssc install stddiff

* Define a global variable list.

vl create covariates = (age education hispanic black married nodegree re74 re75)

* Get standardized differences.

stddiff $covariates, by(treat)

* (c)

* Estimate.

logit treat $covariates

* Get propensity scores.

predict ps

* Get means of propensity scores by group.

sort treat

by treat: egen ps_mean = mean(ps)

egen ps_mean_0 = min(ps_mean) // Watch out for the hard-coding.
egen ps_mean_1 = max(ps_mean) // "".

quietly sum ps_mean_0
display "Mean Propensity Score, Treated: " r(mean)

quietly sum ps_mean_1
display "Mean Propensity Score, Control: " r(mean)

drop ps_*

* Get distributions of propensity scores by group.

histogram ps, by(treat)

graph export "output/20250301_PS3_2.png", width(800) height(400) as(png) replace

* (d)

* Get a package.

* ssc install psmatch2

* Get ATT with matching using psmatch2 defaults: single NN, no calipers, with replacement.

psmatch2 treat, outcome(re78) pscore(ps)

* Note that the estimated ATT, 1965, is in the ballpark of the experimental treatment effect (1794).

* Check balance. Note that (differences between) weights aren't accounted for in stddiff. 

stddiff $covariates if _weight != ., by(treat)

* (e)

* Trim.

keep if ps >= 0.1 & ps <= 0.9

* Estimate ATT with DD.

reshape long re, i(unit_id) j(year)

gen treat_post = (year == 78 & treat == 1)

reghdfe re treat if year != 75, absorb(unit_id year) cluster(unit_id)

drop treat_post

reshape wide re, i(unit_id) j(year)

* (f)

* Get inverse probability weights.

gen ipw = 1 // IPW for treated observations.
replace ipw = ps / (1 - ps) if treat == 0 // IPW for control observations.

* Get ATT with IPW.

* With two regular old regressions?

quietly reg re78 $covariates [aweight = ipw] if treat == 1
predict re78_1

quietly reg re78 $covariates [aweight = ipw] if treat == 0
predict re78_0

gen re78_att = re78_1 - re78_0

quietly sum re78_att if treat == 1
display "IPW ATT: " r(mean)

* With TWFE and analytic weights?

reshape long re, i(unit_id) j(year)

gen treat_post = (year == 78 & treat == 1)

reghdfe re treat_post [aweight = ipw] if year != 75, absorb(unit_id year) cluster(unit_id)

drop treat_post

reshape wide re, i(unit_id) j(year)

* (g)
