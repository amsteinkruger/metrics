* Problem Set 2

* (2)

clear all

* Set up a program.
program montecarlo, rclass
* Preliminaries
drop _all
set obs 100
* Get time-invariant variables.
gen id = _n
gen u = rnormal()
* Expand to get period t in 1, 2 for each i in 100.
expand 2
* Sort.
sort id
* Get time-variant variables.
gen x1 = rnormal()
gen x2 = rnormal() + u
gen e = rnormal()
gen y = 4 + 1 * x1 + 1.5 * x2 + u + e // Mind hard-coding.
* Compute first differences.
by id: gen y_fd = y - y[_n - 1]
by id: gen x1_fd = x1 - x1[_n - 1]
by id: gen x2_fd = x2 - x2[_n - 1]
by id: gen u_fd = u - u[_n - 1]
by id: gen e_fd = e - e[_n - 1]
* Estimate with RE, FE, and FD.
*  RE
xtset id
xtreg y x1 x2, re
return scalar b1_re = _b[x1]
return scalar s1_re = _se[x1]
return scalar b2_re = _b[x2]
return scalar s2_re = _se[x2]
*  FE
xtreg y x1 x2, fe
return scalar b1_fe = _b[x1]
return scalar s1_fe = _se[x1]
return scalar b2_fe = _b[x2]
return scalar s2_fe = _se[x2]
*  FD
reg y_fd x1_fd x2_fd
return scalar b1_fd = _b[x1]
return scalar s1_fd = _se[x1]
return scalar b2_fd = _b[x2]
return scalar s2_fd = _se[x2]
end

* Execute the program.
simulate ///
b1_re = r(b1_re) s1_re = r(s1_re) b2_re = r(b2_re) s2_re = r(s2_re) ///
b1_fe = r(b1_fe) s1_fe = r(s1_fe) b2_fe = r(b2_fe) s2_fe = r(s2_fe) ///
b1_fd = r(b1_fd) s1_fd = r(s1_fd) b2_fd = r(b2_fd) s2_fd = r(s2_fd), ///
reps(10000) seed(112358): montecarlo

* Tabulate estimates.
format b* s* %9.3f
sum, separator(4) format

* Visualize estimates.
format b* s* %9.1f

hist b2_re, ///
width(0.05) ///
xtitle("Random Effects", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color(gray) graphregion(color(white)) bgcolor(white) ///
saving(re, replace)

hist b2_fe, ///
width(0.05) ///
xtitle("Fixed Effects", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color(gray) graphregion(color(white)) bgcolor(white) ///
saving(fe, replace)

hist b2_fd, ///
width(0.05) ///
xtitle("First Differences", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color(gray) graphregion(color(white)) bgcolor(white) ///
saving(fd, replace)

graph combine re.gph fe.gph fd.gph, ///
title("Estimated Values of {&beta}{sub:2}", size(huge)) ///
xcommon ycommon rows(1) ///
graphregion(color(white))

graph export "output/20250205_PS2_2.png", width(1200) height(450) as(png) replace

* (5)

* (c)

clear all

use "data/dataset1.dta"

* What's with the count of municipalities?

codebook idmunic_centroid idmunic_station municid

* The global syntax is neat and novel (to me)!

global weather ///
temp16a19 temp19a22 temp25a28 temp28a31 temp31mais /// Temperature
humid humidsq windsp /// * Humidity, Wind
temphumid tempsqhumidsq // * Interactions

global controls ///
female black parda asian indigenous racenondecl /// Gender, Race
zerosal umsal um_ummeiosal ummeioa2sal /// Parents' Income (Dummies)
doisa2meiosal doismeioa3sal tresa4sal quatroa5sal /// ""
cincoa6sal seisa7sal setea8sal oitoa9sal /// ""
novea10sal deza12sal quinzea20sal mais20sal // ""

* 1) Municipality FE - Linear Pollution
eststo, title("Model 1"): qui: reghdfe notasd pm_10 $weather $controls i.dia, absorb(idmunic_centroid) cluster(idmunic_centroid)

* 2) Municipality FE - Dummy Pollution
eststo, title("Model 2"): qui: reghdfe notasd pm21 $weather $controls i.dia, absorb(idmunic_centroid) cluster(idmunic_centroid)

* 3) Student FE - Linear Pollution
eststo, title("Model 3"): qui: reghdfe notasd pm_10 $weather i.dia, absorb(id_student) cluster(idmunic_centroid)

* 4) Student FE - Dummy Pollution
eststo, title("Model 4"): qui: reghdfe notasd pm21 $weather i.dia, absorb(id_student) cluster(idmunic_centroid)
 
estout est1 est2 est3 est4, ///
keep(pm_10 pm21) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
stats(r2_a_within N, labels("Adjusted Within R2" "Students")) ///
label legend collabels(none) varlabels(pm_10 "PM10" pm21 "1 if PM10 > 20")

* (e)

* 5) Student FE - Linear Pollution, No Weather
eststo, title("Model 5"): qui: reghdfe notasd pm_10 i.dia, absorb(id_student) cluster(idmunic_centroid)

* 6) Student FE - Dummy Pollution, No Weather
eststo, title("Model 6"): qui: reghdfe notasd pm21 i.dia, absorb(id_student) cluster(idmunic_centroid)
 
estout est5 est6, ///
keep(pm_10 pm21) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
stats(r2_a_within N, labels("Adjusted Within R2" "Students")) ///
label legend collabels(none) varlabels(pm_10 "PM10" pm21 "1 if PM10 > 20")

* (f)

clear all

use "data/dataset1.dta"

global weather ///
temp16a19 temp19a22 temp25a28 temp28a31 temp31mais /// Temperature
humid humidsq windsp /// * Humidity, Wind
temphumid tempsqhumidsq // * Interactions

* Set up percentiles for Panel A.

bysort idmunic_centroid: egen p50nota = pctile(nota), p(50)

* Get estimates.

eststo, title("Model A-3"): qui: reghdfe notasd pm_10 $weather i.dia if nota > p50nota, absorb(id_student) cluster(idmunic_centroid)
eststo, title("Model A-8"): qui: reghdfe notasd pm21 $weather i.dia if nota > p50nota, absorb(id_student) cluster(idmunic_centroid)  

* Set up percentiles for Panel B.

bysort idmunic_centroid: egen p50income = pctile(household_income), p(50)

* Get estimates.

eststo, title("Model B-3"): qui: reghdfe notasd pm_10 $weather i.dia if household_income > p50income, absorb(id_student) cluster(idmunic_centroid) 
eststo, title("Model B-8"): qui: reghdfe notasd pm21 $weather i.dia if household_income > p50income, absorb(id_student) cluster(idmunic_centroid) 

* Tabulate estimates.

estout est1 est2 est3 est4, ///
keep(pm_10 pm21) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
label legend collabels(none) varlabels(pm_10 "PM10" pm21 "1 if PM10 > 20")

* (g)

clear all 

use "data/dataset3.dta"

* Set up globals again, but this time with wind.

global instwind ///
clus1_wind90 clus2_wind90 clus3_wind90 ///
clus1_wind180 clus2_wind180 clus3_wind180 ///
clus1_wind270 clus2_wind270 clus3_wind270

global weather ///
temp16a19 temp19a22 temp25a28 temp28a31 temp31mais /// Temperature
humid humidsq windsp /// * Humidity, Wind
temphumid tempsqhumidsq // * Interactions

* Set up PM21.

gen pm21 = 0
replace pm21 = 1 if pm_10 > 2

* Run 2SLS for PM10.

eststo, title("Model 3 (1S)"): qui: reghdfe pm_10 $instwind $weather i.dia, absorb(id_student) cluster(idmunic_centroid)

predict pm_hat, xb

eststo, title("Model 3"): qui: reghdfe notasd pm_hat $weather i.dia, absorb(id_student) cluster(idmunic_centroid)

* Run 2SLS for PM21.

eststo, title("Model 4 (1S)"): qui: reghdfe pm21 $instwind $weather i.dia, absorb(id_student) cluster(idmunic_centroid)

predict pm21_hat, xb

eststo, title("Model 4"): qui: reghdfe notasd pm21_hat $weather i.dia, absorb(id_student) cluster(idmunic_centroid)

* Tabulate second-stage estimates.

estout est2 est4, ///
keep(pm_hat pm21_hat) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
label legend collabels(none) varlabels(pm_hat "PM10" pm21_hat "1 if PM10 > 20")

* Compute F-statistics, just for fun.

bootstrap, reps(500): reghdfe pm_10 $instwind $weather i.dia, absorb(id_student) cluster(idmunic_centroid)
test $instwind

bootstrap, reps(500): reghdfe pm21 $instwind $weather i.dia, absorb(id_student) cluster(idmunic_centroid)
test $instwind
