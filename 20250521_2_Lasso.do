* Problem Set 4

* (2)

* log using 20250521_Log, replace

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

lasso linear y c.($x)##c.($x), selection(adaptive) rseed(10101) // n = 10000
lasso linear y c.($x)##c.($x) if id < 1001, selection(adaptive) rseed(10101) // n = 1000
lasso linear y c.($x)##c.($x) if id < 101, selection(adaptive) rseed(10101) // n = 100

* OLS

reg y c.($x)##c.($x) // n = 10000
reg y c.($x)##c.($x) if id < 1001 // n = 1000
reg y c.($x)##c.($x) if id < 101 // n = 100

* OLS (on X significant at n = 10000 for a = 0.05)

reg y x1 x2 x4 x5 c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5 // n = 10000
reg y x1 x2 x4 x5 c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5  if id < 1001 // n = 1000
reg y x1 x2 x4 x5 c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5 if id < 101 // n = 100

* Tabulate

* use stored estimates; rows are vars, columns are models

* problems: 
*  get list of kept vars out of lasso
*  get different lists of stored variables to play nicely and take binary representation (kept, not kept) for each var
