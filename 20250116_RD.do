* Get a problem set done. Or don't.

* Get a package.

net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace


* (1)

* Get data.

* Nitpicking: do these data describe the first year of the policy, the nth year of the policy, or the -nth year of the policy?

import delimited "data\ChicagoCrimeTemperature2018.csv"

* (a) 
* Without bothering with notation:
* The unit of analysis is day. Happens to be unique. With more data, unique only on year, month, day.
* The running variable is average daily temperature ("temp").
* The cut-off is 32 degrees Fahrenheit (temp == 32).
* The treatment variable is patrolling, i.e. whether CPD officers patrol on a day. 
* The outcome is the daily number of crimes ("crimes").

* (b)
* No. The police department has really good, hyper-accurate forecasts of average daily temperature and no clear option to manipulate them.
* Wait, is it manipulation if people doing crimes ("crimes") respond to the policy by reallocating crimes into colder days?
* Isn't that more of an endogeneity problem (or something)?

* (c)

rdplot crimes temp, c(32) p(4) binselect(es)

rdplot crimes temp, c(32) p(4) binselect(qs)

* The fourth-order polynomial for the control group (let's call that "control days") is a terrible fit at the minimum of the running variable and at the cut-off. There are also fewer control days than treatment days (?).

* 

* (d)

gen treatment = 0
replace treatment = 1 if temp >= 32

gen temp_2 = temp * temp

gen temp_treatment = temp * treatment
gen temp_2_treatment = temp_2 * treatment

* Without bothering about errors, these estimates yield the effect as the difference in intercepts.

reg crimes temp temp_2 if temp < 32
reg crimes temp temp_2 if temp >= 32

* Without bothering about errors, these estimates yield the effect as coefficient "treatment".

reg crimes treatment temp temp_2 temp_treatment temp_2_treatment

* (And those two manual approaches match, which is helpful).

* (e)

* (???)

gen temp_center = temp - 32

gen temp_center_2 = temp_center * temp_center

gen temp_center_treatment = temp_center * treatment
gen temp_center_2_treatment = temp_center_2 * treatment

reg crimes treatment temp_center temp_center_2 temp_center_treatment temp_center_2_treatment
