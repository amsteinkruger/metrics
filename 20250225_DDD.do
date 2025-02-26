* Problem Set 3

* (1)

clear all

* Set up a program.
*  Goal: Get all four cases into a single flat dataframe for easier output handling

program montecarlo, rclass

	* Preliminaries
	
	drop _all
	set obs 4000
	
	* Get time-invariant variables.
	
	gen id = _n
	gen u = rnormal() // nah?
	* gen group = every 1000: in treatment area, treated; in treatment area, placebo; not in treatment area, treated; not in treatment area, placebo
	
	* Expand for t in 1, 2 for all i. Sort on i.
	expand 2
	sort id
	
	* Get time-variant variables.
	* Estimate.

end

* Run the program.
	
simulate ///
* b1_re = r(b1_re) s1_re = r(s1_re) b2_re = r(b2_re) s2_re = r(s2_re) ///
* b1_fe = r(b1_fe) s1_fe = r(s1_fe) b2_fe = r(b2_fe) s2_fe = r(s2_fe) ///
* b1_fd = r(b1_fd) s1_fd = r(s1_fd) b2_fd = r(b2_fd) s2_fd = r(s2_fd), ///
reps(1000) seed(112358): montecarlo

* Tabulate estimates.
* Visualize estimates.

* Reference

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
