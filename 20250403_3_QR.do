* Problem Set 1

log using 20250414_Log, append

* (3)

* DGP 1

clear all

set iterlog off
set seed 0112358
set obs 10000

gen id = _n
gen x = runiform()
gen y = x * id

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

graph export "output/20250413_PS1_3a.png", width(1350) height(1350) replace

* (b)

reg y x

qreg y x, quantile(0.2)
qreg y x, quantile(0.5)
qreg y x, quantile(0.8)

* (c)

sqreg y x, quantiles(0.2 0.5 0.8) reps(100)
sqreg y x, quantiles(0.2 0.5 0.8) reps(1000)
sqreg y x, quantiles(0.2 0.5 0.8) reps(10000)

* DGP 2

clear all

set seed 0112358
set obs 10000

gen id = _n
gen x = runiform()
gen y = 1e08 - x * id ^ 2

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

graph export "output/20250413_PS1_3d.png", width(1350) height(1350) replace

* (e)

reg y x
sqreg y x, quantiles(0.2 0.5 0.8) reps(100)
