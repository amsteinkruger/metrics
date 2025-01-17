* Get a problem set done. Or don't.

* Get a package.

net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace


* (1)

* Get data.

* Nitpicking: do these data describe the first year of the policy, the nth year of the policy, or the -nth year of the policy?

import delimited "data\ChicagoCrimeTemperature2018.csv"

* (a) 

* (b)

* (c)

rdplot crimes temp, c(32) p(4) binselect(es)

rdplot crimes temp, c(32) p(4) binselect(qs)

* (d)

gen treatment = 0
replace treatment = 1 if temp >= 32

gen temp_2 = temp * temp

gen temp_treatment = temp * treatment
gen temp_2_treatment = temp_2 * treatment

reg crimes temp temp_2 if temp < 32
reg crimes temp temp_2 if temp >= 32

reg crimes treatment temp temp_2 temp_treatment temp_2_treatment

* (e)

gen temp_center = temp - 32

gen temp_center_2 = temp_center * temp_center

gen temp_center_treatment = temp_center * treatment
gen temp_center_2_treatment = temp_center_2 * treatment

reg crimes temp_center temp_center_2 if temp_center < 0
reg crimes temp_center temp_center_2 if temp_center >= 0

reg crimes treatment temp_center temp_center_2 temp_center_treatment temp_center_2_treatment

* (2)

* Get data.

clear all

import delimited "data\huh_reif_ps1_data.csv"

* (a)

* (b)

* (c)

* (d)

* Model: Y = B1 * AGE + B2 * POST + B3 * (POST * AGE) + B4 * D + e

gen post = 0
replace post = 1 if agemo_mda >= 0

gen agemo_mda_post = agemo_mda * post

rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) covs(post agemo_mda_post firstmonth)
