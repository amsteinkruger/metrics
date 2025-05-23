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

poregress y x1, controls($xlist2 $x1interact $rlist2) // n = 10000
poregress y x1 if id < 1001, controls($xlist2 $x1interact $rlist2) // n = 1000
poregress y x1 if id < 101, controls($xlist2 $x1interact $rlist2) // n = 100

* OLS

reg y x1 $xlist2 $x1interact $rlist2

* Cross-Fit Partialing-Out Lasso Linear Regression

xporegress y x1, controls($xlist2 $x1interact $rlist2)

* Run xporgress on n = 10000 or on decreasing n?

* Tabulate
