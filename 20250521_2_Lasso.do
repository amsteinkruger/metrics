log using 20250521_Log, replace

* Problem Set 4

* (2)

clear all

set iterlog off

* Begin Copy/Paste

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

* End Copy/Paste

gen id = _n // Count rows for easier drops.

* Adaptive Lasso

vl create x = (x1 x2 x3 x4 x5 x6)

qui lasso linear y c.($x)##c.($x), selection(adaptive) rseed(10101) // n = 10000
estimates store Lasso_10000
qui lasso linear y c.($x)##c.($x) if id < 1001, selection(adaptive) rseed(10101) // n = 1000
estimates store Lasso_1000
qui lasso linear y c.($x)##c.($x) if id < 101, selection(adaptive) rseed(10101) // n = 100
estimates store Lasso_100

* OLS, All Variables

*  Use output from the first OLS model to select variables for the fourth through sixth OLS models. 

reg y c.($x)##c.($x) // n = 10000
estimates store OLS_More_10000
qui reg y c.($x)##c.($x) if id < 1001 // n = 1000
estimates store OLS_More_1000
qui reg y c.($x)##c.($x) if id < 101 // n = 100
estimates store OLS_More_100

* OLS, Selected Variables

qui reg y x1 x2 x4 x5 c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5 // n = 10000
estimates store OLS_Less_10000
qui reg y x1 x2 x4 x5 c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5  if id < 1001 // n = 1000
estimates store OLS_Less_1000
qui reg y x1 x2 x4 x5 c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5 if id < 101 // n = 100
estimates store OLS_Less_100

* Tabulate

lassocoef Lasso*, display(coef, postselection) vsquish
estimates table OLS_More*, vsquish
estimates table OLS_Less*, vsquish
