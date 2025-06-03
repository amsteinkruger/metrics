* Problem Set 4

* log using 20250521_Log, append

clear all

set iterlog off

* (5)

use "data/PS4.dta"

vl create x = (x1 x2 x3 x4 x5 x6)
vl create x_controls = (x2 x3 x4 x5 x6)

* (a)

qui lasso linear y c.($x)##c.($x), rseed(0112358)
estimates store a_Lasso

qui lasso linear y c.($x)##c.($x), rseed(0112358) selection(adaptive)
estimates store a_Adaptive

qui elasticnet linear y c.($x)##c.($x), rseed(0112358)
estimates store a_ElasticNet

lassocoef a_*, display(coef, postselection) vsquish

* (b)

qui dsregress y x1, controls($x_controls)
estimates store b_Double

qui poregress y x1, controls($x_controls)
estimates store b_Partial

qui xporegress y x1, controls($x_controls)
estimates store b_Cross

estimates table b_*, vsquish

lassocoef (b_Double, for(y)) (b_Partial, for(y)) (b_Cross, for(y) xfold(1)), display(coef, postselection)

lassocoef (b_Double, for(x1)) (b_Partial, for(x1)) (b_Cross, for(x1) xfold(1)), display(coef, postselection)

* (c)

reg y $x
