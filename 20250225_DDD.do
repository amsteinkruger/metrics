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
	replace p = 1 if (group == 3 | group == 4)
	
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
	replace x_att = 0.50 if t == 1 & p == 0 & d == 1

	*   i. Parallel trends holds for the primary treatment and placebo groups.
	
	gen x_trend_i = 0
	replace x_trend_i = 1 if t == 1
	
	*   ii. Parallel trends holds for the primary treatment group but not the placebo group.
	
	gen x_trend_ii = 0
	replace x_trend_ii = 1 if t == 1 & (p == 0 | d == 1)
	
	*   iii. Parallel trends holds for neither group but the parallel trends violations are equivalent.
	
	gen x_trend_iii = 0
	replace x_trend_iii = 1 if t == 1 & d == 1
	
	*   iv. Parallel trends holds for neither group and the parallel trends violations are not equivalent.
	
	gen x_trend_iv = 0
	replace x_trend_iv = group if t == 1
	
	*  LHS
	
	gen y_i = x_att + x_trend_i + error
	gen y_ii = x_att + x_trend_ii + error
	gen y_iii = x_att + x_trend_iii + error
	gen y_iv = x_att + x_trend_iv + error
	
	* Estimate. Note that "d" represents treatment.
	
	* begin scratch
	
	* DB: Wage_it = B_0 + B_1 * M_i + B_2 * Post_t + B_3 * W_i + B_4 * M_i * Post_t + B_5 * W_i * Post_t + B_6 * M_i * W_i + B_7 * M_i * W_i * Post_t + e_it => B_7_hat = tau_DDD_hat
	*     where M_i is treatment (d), Post_t is period (t), and W_i is placebo (p), that is,
	*     Y_i = B_0 + B_1 * d_i + B_2 * t + B_3 * p + B_4 * d * t + B_5 * p * t + B_6 * d * p + B_7 * d * p * t + e_it
	
	reg y_i d p t  d#p d#t p#t d#p#t
	
	* or
	
	reghdfe y_i d#t p#t d#p#t, absorb(period) // and B_3 = tau_DDD
	
	* end scratch
	
	*  i.
	
	reg y_i t d t#d if p == 0
	return scalar b_t_0_i = _b[t]
	return scalar b_d_0_i = _b[d]
	reg y_i t d t#d if p == 1
	return scalar b_t_1_i = _b[t]
	return scalar b_d_1_i = _b[d]
	
	*  ii.
	
	reg y_ii t d t#d if p == 0
	return scalar b_t_0_ii = _b[t]
	return scalar b_d_0_ii = _b[d]
	reg y_ii t d t#d if p == 1
	return scalar b_t_1_ii = _b[t]
	return scalar b_d_1_ii = _b[d]
	
	*  iii.
	
	reg y_iii t d t#d if p == 0
	return scalar b_t_0_iii = _b[t]
	return scalar b_d_0_iii = _b[d]
	reg y_iii t d t#d if p == 1
	return scalar b_t_1_iii = _b[t]
	return scalar b_d_1_iii = _b[d]
	
	*  iv.
	
	reg y_iv t d t#d if p == 0
	return scalar b_t_0_iv = _b[t]
	return scalar b_d_0_iv = _b[d]
	reg y_iv t d t#d if p == 1
	return scalar b_t_1_iv = _b[t]
	return scalar b_d_1_iv = _b[d]

end

* Run the program.
	
simulate ///
b_t_0_i = r(b_t_0_i) b_d_0_i = r(b_d_0_i) b_t_1_i = r(b_t_1_i) b_d_1_i = r(b_d_1_i) ///
b_t_0_ii = r(b_t_0_ii) b_d_0_ii = r(b_d_0_ii) b_t_1_ii = r(b_t_1_ii) b_d_1_ii = r(b_d_1_ii) ///
b_t_0_iii = r(b_t_0_iii) b_d_0_iii = r(b_d_0_iii) b_t_1_iii = r(b_t_1_iii) b_d_1_iii = r(b_d_1_iii) ///
b_t_0_iv = r(b_t_0_iv) b_d_0_iv = r(b_d_0_iv) b_t_1_iv = r(b_t_1_iv) b_d_1_iv = r(b_d_1_iv), ///
reps(100) seed(112358): montecarlo

* Tabulate estimates.

format b_d_* b_t_* %9.3f
sum, separator(4) format

* Visualize estimates.

format b* %9.1f

hist b_d_0_i, ///
width(0.05) ///
xtitle("(i)", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(b_d_0_i, replace)

hist b_d_0_ii, ///
width(0.05) ///
xtitle("(ii)", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(b_d_0_ii, replace)

hist b_d_0_iii, ///
width(0.05) ///
xtitle("(iii)", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(b_d_0_iii, replace)

hist b_d_0_iv, ///
width(0.05) ///
xtitle("(iv)", size(huge)) xlabel(, labsize(huge)) ///
ytitle("") ylabel(, labsize(huge)) ///
color("153 153 153") graphregion(color(white)) bgcolor(white) ///
saving(b_d_0_iv, replace)

graph combine b_d_0_i.gph b_d_0_ii.gph b_d_0_iii.gph b_d_0_iv.gph, ///
title("Estimated Treatment Effects for (i) - (iv)", size(huge)) ///
xcommon ycommon rows(1) ///
graphregion(color(white))

graph export "output/20250225_PS3_1.png", width(1200) height(400) as(png) replace
