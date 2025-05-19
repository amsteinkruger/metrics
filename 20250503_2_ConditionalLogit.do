* Problem Set 3

* log using 20250503_Log, replace

set iterlog off

* (2)
* (a)

clear all

use "data/FIAPlots_CC.dta"

cmset id rp
cmclogit d r [pweight = expfactor], basealternative(hw)

* (b)

* Find the range of rents for cases where Douglas fir is chosen.

summarize r if choice_df == 1

* Check marginal effect at mean for Douglas fir. (Note that this doesn't match the Excel result.)

margins, dydx(r) outcome(df) alternative(df) atmeans

* (d)

clear all

use "data/FIAPlots_CC_WideForm.dta"

mlogit rpchoice precip_gs, baseoutcome(6) 

* Find the range of precipitation.

summarize precip_gs

* Check marginal effect just for reference.

margins, dydx(*) 
