* Problem Set 3

* log using 20250503_Log, replace

set iterlog off

* Preamble

clear all

use "data/FIAPlots_CC_WideForm.dta"

*  Unit-Varying Regressors

table rpchoice, contents(N tmean_gs mean tmean_gs mean precip_gs)

*  Unit-Invariant (Choice-Specific) Regressors

table rpchoice, contents(mean rdf mean rfir mean rhem mean rpp mean rhw)

*  Multinomial Logit

mlogit rpchoice tmean_gs precip_gs, baseoutcome(1) 
margins, dydx(*) 

* (2)
* (a)

clear all

use "data/FIAPlots_CC.dta"

cmset id rp
cmchoiceset
cmtab, choice(d)
cmsummarize tmean_gs precip_gs min12 max08, choice(d) statistics(mean)

cmclogit d r [pweight = expfactor], basealternative(os) // does r need to be specific as case-invariant, choice-varying?


* (d)



*** reference

*********************************************************************************************
*Conditional logit - data in long form (FIAPlots_CC.dta)
*Code for discrete-choice estimation of forest replanting decisions
*For Stata 16 and up - cmclogit command
*tabulate choice set possibilities
*use FIAPlots_CC.dta
cmset id rp
cmchoiceset

*tabluate chosen alternatives
cmtab, choice(d)

*summarize climate variables by chosen alternatives
cmsummarize tmean_gs precip_gs min12 max08, choice(d) statistics(mean)

*Code for simple conditional logit model of replanting after clear-cut, with rent as only indep variable
cmset id rp
cmclogit d r [pweight = expfactor], basealternative(os)
margins, dydx(r)


*Code for logit model of replanting after clear-cut, used for Hashida and Lewis (2022) Resource and Energy Economics
cmset id rp
cmclogit d r [pweight = expfactor], casevars(tmean_gs precip_gs min12 max08 elev) basealternative(os)

*Average marginal effects of tmean_gs on all probabilities
margins, dydx(tmean_gs) 

*Marginal effects of Douglas-fir rent on all probabilities at means
margins, dydx(r) outcome(df fir hem pp hw os) alternative(df) atmeans

*Predicted probabilities
predict p
bys rp: sum p
**********************************************************************************************