* Problem Set 3

* (1)

clear all

* Set up a program.

program montecarlo, rclass

	* Preliminaries.
	
	drop _all
	set obs 4000
	
	* Get time-invariant variables.
	
	gen i = _n
	
	* Groups
	
	gen group = ceil(i * 0.001)
	gen group_string = "D = 0"
	replace group_string = "D = 1" if group > 1
	replace group_string = "D = 0, Placebo" if group > 2
	replace group_string = "D = 1, Placebo" if group > 3
	
	* Placebo
	
	gen p = 0
	replace p = 1 if (group == 1 | group == 2) // This isn't intuitive but leads to a correct sign on estimates of ATT.
	
	* Treatment
	
	gen d = 0
	replace d = 1 if (group == 2 | group == 4)
	
	* Expand for t in 1, 2 for all i. Sort on i.
	
	expand 2
	
	sort i
	
	* Get time-variant variables.
	
	*  RHS
	
	by i: gen t = _n - 1
	
	gen error = rnormal()
	
	gen x_att = 0
	replace x_att = 0.50 if p == 1 & d == 1 & t == 1 

	*   i. Parallel trends holds for the primary treatment and placebo groups.
	
	gen x_trend_i = 0
	replace x_trend_i = 1 if t == 1
	
	*   ii. Parallel trends holds for the primary treatment group but not the placebo group.
	
	gen x_trend_ii = 0
	replace x_trend_ii = 1 if p == 1 & t == 1
	replace x_trend_ii = group ^ (1 / 2) if p == 0 & t == 1 // This is just a convenient way to get non-parallel trends.
	
	*   iii. Parallel trends holds for neither group but the parallel trends violations are equivalent.
	
	gen x_trend_iii = 0
	replace x_trend_iii = 1 if d == 0 & t == 1
	replace x_trend_iii = 2 if d == 1 & t == 1
	
	*   iv. Parallel trends holds for neither group and the parallel trends violations are not equivalent.
	
	gen x_trend_iv = 0
	replace x_trend_iv = group ^ (1 / 2) if t == 1 // This is still just a convenient way to get non-parallel trends.
	
	*  LHS
	
	gen y_i = x_att + x_trend_i + error
	gen y_ii = x_att + x_trend_ii + error
	gen y_iii = x_att + x_trend_iii + error
	gen y_iv = x_att + x_trend_iv + error
	
	* Estimate. I didn't plan around Stata's factor notation when I used (i)-(iv) in var names.
	
	*  Y = B_0 + B_1 * d + B_2 * t + B_3 * p + B_4 * d * t + B_5 * p * t + B_6 * d * p + B_7 * d * p * t + e_it
	
	* (i)
	
	reg y_i i.d i.p i.t  i.d#i.p i.d#i.t i.p#i.t i.d#i.p#i.t
	return scalar ATT_i = _b[1.d#1.p#1.t]
	
	* (ii)
	
	reg y_ii i.d i.p i.t  i.d#i.p i.d#i.t i.p#i.t i.d#i.p#i.t
	return scalar ATT_ii = _b[1.d#1.p#1.t]
	
	* (iii)
	
	reg y_iii i.d i.p i.t  i.d#i.p i.d#i.t i.p#i.t i.d#i.p#i.t
	return scalar ATT_iii = _b[1.d#1.p#1.t]
	
	* (iv)
	
	reg y_iv i.d i.p i.t  i.d#i.p i.d#i.t i.p#i.t i.d#i.p#i.t
	return scalar ATT_iv = _b[1.d#1.p#1.t]

end

* Run the program.
	
simulate ///
ATT_i = r(ATT_i) ATT_ii = r(ATT_ii) ATT_iii = r(ATT_iii) ATT_iv = r(ATT_iv), ///
reps(1000) seed(112358): montecarlo

* Tabulate estimates.

format ATT_* %9.3f // b_d_* b_t_*
sum, separator(4) format

* Visualize estimates.

format ATT_* %9.1f

hist ATT_i, ///
width(0.05) ///
xtitle("(i)", size(huge)) xlabel(0.00 0.50 1.00, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(ATT_i, replace)

hist ATT_ii, ///
width(0.05) ///
xtitle("(ii)", size(huge)) xlabel(0.00 0.50 1.00, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(ATT_ii, replace)

hist ATT_iii, ///
width(0.05) ///
xtitle("(iii)", size(huge)) xlabel(0.00 0.50 1.00, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(ATT_iii, replace)

hist ATT_iv, ///
width(0.05) ///
xtitle("(iv)", size(huge)) xlabel(0.00 0.50 1.00, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(ATT_iv, replace)

graph combine ATT_i.gph ATT_ii.gph ATT_iii.gph ATT_iv.gph, ///
xcommon ycommon rows(1) ///
graphregion(color(white))

graph export "output/20250225_PS3_1.png", width(1200) height(400) as(png) replace
