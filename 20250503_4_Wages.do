* Problem Set 3

log using 20250503_Log, replace

set iterlog off

* (4)

clear all

use "data/cps91.dta"

* (a)

vl create x_a = (educ exper black hispanic)

reg lwage $x_a

* (b)

vl create x_b = (educ exper black hispanic kidlt6 nwifeinc)

probit inlf $x_b 

* (c)

* Heckman

heckman lwage $x_a, select(inlf = $x_b) twostep
