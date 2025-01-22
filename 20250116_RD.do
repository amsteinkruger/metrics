* Problem Set 1

* Get packages.

net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace

ssc install estout, replace

* (1)

* Get data.

import delimited "data\ChicagoCrimeTemperature2018.csv"

* (a)

* (b)

* (c)

quietly rdplot crimes temp, c(32) p(4) binselect(es) graph_options(legend(off) name(es))

quietly rdplot crimes temp, c(32) p(4) binselect(qs) graph_options(legend(off) name(qs))

quietly graph combine es qs

graph export "output/vis_rd_1c.png", width(1200) height(600) replace

* (d) 

gen treatment = 0
replace treatment = 1 if temp >= 32

gen temp_2 = temp * temp

gen temp_treatment = temp * treatment
gen temp_2_treatment = temp_2 * treatment

eststo: quietly reg crimes temp temp_2 if temp < 32
eststo: quietly reg crimes temp temp_2 if temp >= 32

suest est1 est2

lincom [est2_mean]_cons + [est2_mean]temp * 32 + [est2_mean]temp_2 * 32 * 32 - [est1_mean]_cons - [est1_mean]temp * 32 - [est1_mean]temp_2 * 32 * 32

eststo clear

* (e) 

gen temp_center = temp - 32

gen temp_center_2 = temp_center * temp_center

gen temp_center_treatment = temp_center * treatment
gen temp_center_2_treatment = temp_center_2 * treatment

eststo: quietly reg crimes temp_center temp_center_2 if temp_center < 0
eststo: quietly reg crimes temp_center temp_center_2 if temp_center >= 0

suest est1 est2

lincom [est2_mean]_cons - [est1_mean]_cons

eststo clear

* (2)

* Get data.

clear all

import delimited "data\huh_reif_ps1_data.csv"

* (a)

* (b)

* (c)

* (d)

* Model: Y = B1 * AGE + B2 * POST + B3 * (POST * AGE) + B4 * D + e

eststo model_d: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) covs(firstmonth) 

* (e)

eststo model_e: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(uniform) covs(firstmonth)

* (f)

eststo model_f: quietly rdrobust cod_sa_poisoning agemo_mda, p(2) kernel(triangular) covs(firstmonth) 

* (g) 

* It's a little easier to hard-code bandwidth references in h() and b() than it is to store, manipulate, and retrieve them.

eststo model_g: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) h(17.604) b(29.318) covs(firstmonth) 

* (h) 

eststo model_h: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) bwselect(msetwo) covs(firstmonth) 

* (i) 

eststo model_i: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular)

* Combine estimates in one table for easier comparison. http://repec.org/bocode/e/estout/advanced.html#advanced907

quietly esttab, ci

quietly mat list r(coefs)

esttab r(coefs, transpose), drop(p)

* (j)

* (k)