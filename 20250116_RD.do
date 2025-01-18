* Get a problem set done. Or don't.

* Get a package.

net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace

ssc install estout, replace

* (1)

* Get data.

import delimited "data\ChicagoCrimeTemperature2018.csv"

* (a) 

* Without bothering with notation:
* The unit of analysis is day. Happens to be unique. With more data, unique only on year, month, day.
* The running variable is average daily temperature ("temp").
* The cut-off is 32 degrees Fahrenheit (temp == 32).
* The treatment variable is patrolling, i.e. whether CPD officers patrol on a day. 
* The outcome is the daily number of crimes ("crimes").

* (b) 

* No. The police department has really good, hyper-accurate forecasts of average daily temperature, and we have no reason to expect the police department to manipulate their forecasts. 

* (c)

rdplot crimes temp, c(32) p(4) binselect(es)

rdplot crimes temp, c(32) p(4) binselect(qs)

* write an answer here

* (d) This is wrong because it doesn't match examples from class with recentered data -- it needs some other adjustment. See Angrist and Pischke or Cunningham (and take another look at course material). Per SR, use lincom on results of two regressions and specify coef (?) to be 32.

gen treatment = 0
replace treatment = 1 if temp >= 32

gen temp_2 = temp * temp

gen temp_treatment = temp * treatment
gen temp_2_treatment = temp_2 * treatment

reg crimes temp temp_2 if temp < 32
reg crimes temp temp_2 if temp >= 32

reg crimes treatment temp temp_2 temp_treatment temp_2_treatment

* (e) This is right because it matches examples from class with recentered data

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

* The authors note that age cannot be manipulated. I imagine that some individuals drive under the MDA threshold, and that the death rate for individuals who drive under the MDA threshold is higher than that for individuals who do not. I believe that could be interpreted as manipulation, in that some individuals are receiving the treatment (being able to drive) despite falling under the cut-off (being old enough to legally drive). That manipulation would bias the authors' estimates downward by increasing death rates for individuals close to the cut-off in the control group.

* (b)

* RD: 0.315, [0.233, 0.496], {<0.0001}; MSE-optimal beta estimate as in Eqn 1, 0.95 CI, family-wise p

* anyhow, the authors assume the relation of drug overdose death rate and months since minimum driving age is continuous about the MDA threshold
* i.e. groups are similar across cut-off

* repeat in notation

* (c)

* Using the authors' notation, the indicator for treatment (POST_a) is subject to measurement error because observations are months while the MDA threshold are days -- that is, the authors cannot observe whether a teenager who dies in the month of the MDA threshold died before or after the threshold. So, the authors include the indicator D_a to correct for bias resulting from this measurement error. 

* (d)

* Model: Y = B1 * AGE + B2 * POST + B3 * (POST * AGE) + B4 * D + e

eststo: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) covs(firstmonth) 

* (e)

eststo: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(uniform) covs(firstmonth)

* (f)

eststo: quietly rdrobust cod_sa_poisoning agemo_mda, p(2) kernel(triangular) covs(firstmonth) 

* (g) 

eststo: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) h(17.604) b(29.318) covs(firstmonth) 

* (h) 

eststo: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular) bwselect(msetwo) covs(firstmonth) 

* (i) 

eststo: quietly rdrobust cod_sa_poisoning agemo_mda, p(1) kernel(triangular)

* Combine estimates in one table for easier comparison. http://repec.org/bocode/e/estout/advanced.html#advanced907

esttab, ci(3)

mat list r(coefs)

esttab r(coefs, transpose)

* switch to more complex and flexible option offered by estout/advanced

* (j) words

* (k) adapt to fuzzy RD (see question)

* MDA compliance is imperfect

