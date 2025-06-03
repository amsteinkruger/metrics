* Problem Set 4

* log using 20250521_Log, append

clear all

set iterlog off

* (3)

* Copy/Paste

set obs 10000
set seed 10101
matrix MU = (0,0,0)
scalar rho = 0.95
matrix SIGMA = (1,rho,rho \ rho,1,rho \ rho,rho,1)
drawnorm x1 x2 x3, means(MU) cov(SIGMA)
scalar rho = 0.2
matrix SIGMA = (1,rho,rho \ rho,1,rho \ rho,rho,1)
drawnorm x4 x5 x6, means(MU) cov(SIGMA)
generate y = 1 + 2*x1 + 3*x2 + 2*x1*x2 + 2*x4 + 3*x5 + 2*x4*x5 + rnormal(0, 10)

global xlist2 x2 x3 x4 x5 x6
global x1interact c.x1#c.($xlist2)
global rlist2 $xinteract c.($xlist2)##c.($xlist2)

* Partialing-Out Lasso Linear Regression

gen id = _n // Count rows for easier drops.

qui poregress y x1, controls($xlist2 $x1interact $rlist2) // n = 10000
estimates store po_10000
qui poregress y x1 if id < 1001, controls($xlist2 $x1interact $rlist2) // n = 1000
estimates store po_1000
qui poregress y x1 if id < 101, controls($xlist2 $x1interact $rlist2) // n = 100
estimates store po_100

* OLS

qui reg y x1 $xlist2 $x1interact $rlist2 // n = 10000
estimates store ols_10000
qui reg y x1 $xlist2 $x1interact $rlist2 if id < 1001 // n = 1000
estimates store ols_1000
qui reg y x1 $xlist2 $x1interact $rlist2 if id < 101 // n = 100
estimates store ols_100

* Cross-Fit Partialing-Out Lasso Linear Regression

qui xporegress y x1, controls($xlist2 $x1interact $rlist2) // n = 10000
estimates store xpo_10000
qui xporegress y x1 if id < 1001, controls($xlist2 $x1interact $rlist2) // n = 1000
estimates store xpo_1000
qui xporegress y x1 if id < 101, controls($xlist2 $x1interact $rlist2) // n = 100
estimates store xpo_100

* Tabulate

estimates table po_*, se
estimates table ols_*, se keep(x1)
estimates table xpo_*, se
