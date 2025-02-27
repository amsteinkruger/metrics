* Problem Set 3

* (1)

clear all

* Set up a program.

program montecarlo, rclass

	* Preliminaries.
	
	drop _all
	set obs 4000
	
	* Get time-invariant variables.
	
	gen id = _n
	
	gen group = ceil(id * 0.001)
	
	gen group_placebo = 0
	replace group_placebo = 1 if (group == 3 | group == 4)
	
	gen group_treatment = 0
	replace group_treatment = 1 if (group == 2 | group == 4)
	
	gen group_string = "D = 0"
	replace group_string = "D = 1" if group > 1
	replace group_string = "D = 0, Placebo" if group > 2
	replace group_string = "D = 1, Placebo" if group > 3

	* Expand for t in 1, 2 for all i. Sort on i.
	
	expand 2
	
	sort id
	
	* Get time-variant variables.
	
	*  RHS
	
	by id: gen t = _n - 1
	
	gen error = rnormal()
	
	gen x_att = 0
	replace x_att = 0.50 if t == 1 & group_placebo == 0 & group_treatment == 1

	*   i. Parallel trends holds for the primary treatment and placebo groups.
	
	gen x_trend_i = 0
	replace x_trend_i = 1 if t == 1
	
	*   ii. Parallel trends holds for the primary treatment group but not the placebo group.
	
	gen x_trend_ii = 0
	replace x_trend_ii = 1 if t == 1 & (group_placebo == 0 | group_treatment == 1)
	
	*   iii. Parallel trends holds for neither group but the parallel trends violations are equivalent.
	
	gen x_trend_iii = 0
	replace x_trend_iii = 1 if t == 1 & group_treatment == 1
	
	*   iv. Parallel trends holds for neither group and the parallel trends violations are not equivalent.
	
	gen x_trend_iv = 0
	replace x_trend_iv = group if t == 1
	
	*  LHS
	
	gen y_i = x_att + x_trend_i + error
	gen y_ii = x_att + x_trend_ii + error
	gen y_iii = x_att + x_trend_iii + error
	gen y_iv = x_att + x_trend_iv + error
	
	* Estimate. Note that "d" represents treatment.
	
	*  i.
	
	reg y_i t group_treatment t#group_treatment if group_placebo == 0
	return scalar b_t_0_i = _b[t]
	return scalar b_d_0_i = _b[group_treatment]
	reg y_i t group_treatment t#group_treatment if group_placebo == 1
	return scalar b_t_1_i = _b[t]
	return scalar b_d_1_i = _b[group_treatment]
	
	*  ii.
	
	reg y_ii t group_treatment t#group_treatment if group_placebo == 0
	return scalar b_t_0_ii = _b[t]
	return scalar b_d_0_ii = _b[group_treatment]
	reg y_ii t group_treatment t#group_treatment if group_placebo == 1
	return scalar b_t_1_ii = _b[t]
	return scalar b_d_1_ii = _b[group_treatment]
	
	*  iii.
	
	reg y_iii t group_treatment t#group_treatment if group_placebo == 0
	return scalar b_t_0_iii = _b[t]
	return scalar b_d_0_iii = _b[group_treatment]
	reg y_iii t group_treatment t#group_treatment if group_placebo == 1
	return scalar b_t_1_iii = _b[t]
	return scalar b_d_1_iii = _b[group_treatment]
	
	*  iv.
	
	reg y_iv t group_treatment t#group_treatment if group_placebo == 0
	return scalar b_t_0_iv = _b[t]
	return scalar b_d_0_iv = _b[group_treatment]
	reg y_iv t group_treatment t#group_treatment if group_placebo == 1
	return scalar b_t_1_iv = _b[t]
	return scalar b_d_1_iv = _b[group_treatment]

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
