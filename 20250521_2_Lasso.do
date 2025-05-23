* Problem Set 4

* log using 20250521_Log, append

clear all

set iterlog off

* (2)

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

* Remember to store estimates for tabulation.

* Adaptive Lasso

gen id = _n // Count rows for easier drops.

vl create x = (x1 x2 x3 x4 x5 x6)

lasso linear y c.($x)##c.($x), selection(adaptive) rseed(10101) // n = 10000
lasso linear y c.($x)##c.($x) if id < 1001, selection(adaptive) rseed(10101) // n = 1000
lasso linear y c.($x)##c.($x) if id < 101, selection(adaptive) rseed(10101) // n = 100

* OLS

reg y c.($x)##c.($x) // n = 10000
reg y c.($x)##c.($x) if id < 1001 // n = 1000
reg y c.($x)##c.($x) if id < 101 // n = 100

* OLS (On X significant at a = 0.05)

vl create x_significant = (x1 x2 x4 x5)

reg y $x_significant c.x1#c.x2 c.x2#c.x4 c.x3#c.x4 c.x4#c.x5

* Is the point of the prompt to check OLS results w/ decreasing n or w/ decreasing P?

* Tabulate
