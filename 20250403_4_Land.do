* Problem Set 1

log using 20250414_Log, append

* (4)

clear all

set iterlog off

use "data/WangLewis24_Data.dta"

* (a)

qreg logprice vpdmean_AJ, quantile(0.2)

predict x02

qreg logprice vpdmean_AJ, quantile (0.5)

predict x05

qreg logprice vpdmean_AJ, quantile (0.8)

predict x08

label variable x02 "0.2 Quantile"
label variable x05 "Median"
label variable x08 "0.8 Quantile"

twoway (scatter logprice vpdmean_AJ, color(%5)) ///
(line x02 vpdmean_AJ) ///
(line x05 vpdmean_AJ) ///
(line x08 vpdmean_AJ)

graph export "output/20250413_PS1_4a.png", width(1350) height(1350) replace

* (b)

vl create covars = (fire fire15 VLF elevation slope near_road near_urban near_pub)

qreg logprice vpdmean_AJ c.vpdmean_AJ#c.vpdmean_AJ $covars i.statefp i.year, quantile(0.2)

margins, dydx(vpdmean_AJ) at(vpdmean_AJ = (2.5 5 7.5 10 12.5))

* (c)

qreg logprice vpdmean_AJ c.vpdmean_AJ#c.vpdmean_AJ $covars i.statefp i.year, quantile(0.8)

margins, dydx(vpdmean_AJ) at(vpdmean_AJ = (2.5 5 7.5 10 12.5))

* (d)

iqreg logprice vpdmean_AJ c.vpdmean_AJ#c.vpdmean_AJ $covars i.statefp i.year, quantiles(0.2 0.8)

margins, dydx(vpdmean_AJ) at(vpdmean_AJ = (2.5 5 7.5 10 12.5))

* (e)



* Graph for (c)

clear all

import delimited "data/ps1_scratch.csv"

twoway (scatter dydx_02 vpdmean_aj) (scatter dydx_08 vpdmean_aj)

graph export "output/20250413_PS1_4c.png", width(1350) height(1350) replace