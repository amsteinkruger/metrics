* Problem Set 1

* (3)

* DGP 1

clear all

set obs 100

gen id = _n

gen x = runiform() * 10

gen y = x * id + rnormal(10, 5) + 10

* (a)

scatter y x // but by group and with fit lines?

* (b)

reg y x

sqreg y x, quantiles(0.2 0.5 0.8)

* (c)

sqreg y x, quantiles(0.2 0.5 0.8)

* bootstrap, reps(100): sqreg y x, quantiles(0.2 0.5 0.8)
* bootstrap, reps(1000): sqreg y x, quantiles(0.2 0.5 0.8)
* bootstrap, reps(10000): sqreg y x, quantiles(0.2 0.5 0.8)

* DGP 2

clear all

set obs 100

gen id = _n

gen x = runiform() * 10

gen y = 100000 - x * id ^ 2 + rnormal(10, 5) + 10 // fix magic numbers

* (d)

scatter y x

* (e)

reg y x

sqreg y x, quantiles(0.2 0.5 0.8)
