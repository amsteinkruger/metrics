* Problem Set 3

* (4)

clear all

use "data/nsw_dw.dta" // Get experimental data.
append using "data/cps_controls3.dta" // Get observational data.
gen unit_id = _n // Set up a unique ID for reshape.
reshape long re, i(unit_id) j(year) // Set up for DD.

* (a)

reg re treat if year != 75
reg re treat if year != 75 & data_id == "Dehejia-Wahba Sample"

* (b)
* note DB in Lecture 13: ATE estimate requires common support of confounder over entire distribution for both treated and untreated
* options for assessing balance:
*  simple t-test for treatment-control difference in means for each X
*  normalized or standardized mean difference
*  ratio of treatment-control variances
*  mean percentile difference, q-q

* (c)



* (d)
* (e)
* (f)
* (g)
