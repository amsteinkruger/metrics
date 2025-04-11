* Problem Set 1

* (3)

set seed 0112358

* DGP 1

clear all

set obs 10000

gen id = _n

gen x = runiform()

gen y = x * id + rnormal(10, 5) + 10

* (a)

quietly qreg y x, quantile(0.2)
predict x02
quietly qreg y x, quantile(0.5)
predict x05
quietly qreg y x, quantile(0.8)
predict x08

label variable x02 "0.2 Quantile"
label variable x05 "Median"
label variable x08 "0.8 Quantile"

twoway (scatter y x, color(%5)) ///
(line x02 x) ///
(line x05 x) ///
(line x08 x)

* (b)

reg y x

qreg y x, quantile(0.2)
qreg y x, quantile(0.5)
qreg y x, quantile(0.8)

* (c)

sqreg y x, quantiles(0.2 0.5 0.8) reps(100)
* sqreg y x, quantiles(0.2 0.5 0.8) reps(1000)
* sqreg y x, quantiles(0.2 0.5 0.8) reps(10000)

* DGP 2

clear all

set obs 10000

gen id = _n

gen x = runiform()

gen y = 1e08 - (x * id ^ 2 + rnormal(10, 5) + 10) // fix magic numbers

* (d)

quietly qreg y x, quantile(0.2)
predict x02
quietly qreg y x, quantile(0.5)
predict x05
quietly qreg y x, quantile(0.8)
predict x08

label variable x02 "0.2 Quantile"
label variable x05 "Median"
label variable x08 "0.8 Quantile"

twoway (scatter y x, color(%5)) ///
(line x02 x) ///
(line x05 x) ///
(line x08 x)

* (e)

reg y x

sqreg y x, quantiles(0.2 0.5 0.8) reps(100)
