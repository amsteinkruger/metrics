* Problem Set 1

* (1)

*  Set up the problem.

clear all

set obs 100

gen id = _n

gen d = 0
replace d = 1 if id < 51

gen packs = 0
replace packs = 1 if id > 30
replace packs = 2 if id > 45
replace packs = 0 if id > 50
replace packs = 1 if id > 85
replace packs = 2 if id > 95

gen cigarettes = packs * 20

sum

* (d)

poisson packs i.d

margins

* mlexp

* nl

* (f)

