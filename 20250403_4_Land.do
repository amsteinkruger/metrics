* Problem Set 1

* (4)

clear all

* ssc install qregplot

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

twoway (scatter logprice vpdmean_AJ) ///
(line x02 vpdmean_AJ) ///
(line x05 vpdmean_AJ) ///
(line x08 vpdmean_AJ)
