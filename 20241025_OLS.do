* (4)

clear
drop _all

* (a)

program define ols_exogenous, rclass

	clear
	drop _all
	set obs 1000
	gen X = rnormal(4, 2)
	gen e_Exogenous = rnormal(4, 2) + 1
	gen Y_Unbiased = 3 * X + e_Exogenous

	reg Y_Unbiased X

	end

simulate beta = _b[X], reps(1000): ols_exogenous
sum
hist beta, xtitle("With Exogeneity") graphregion(color(white)) bgcolor(white) saving(ols_exogenous, replace)

program define ols_endogenous, rclass

	clear
	drop _all
	set obs 1000
	gen X = rnormal(4, 2)
	gen e_Exogenous = rnormal(4, 2) + 1
	gen e_Endogenous = e_Exogenous - 1 + rnormal(0.25, 0.125) * X
	gen Y_Biased = 3 * X + e_Endogenous

	reg Y_Biased X

	end

simulate beta = _b[X], reps(1000): ols_endogenous
sum
hist beta, xtitle("Without Exogeneity") graphregion(color(white)) bgcolor(white) saving(ols_endogenous, replace)

graph combine ols_exogenous.gph ols_endogenous.gph, graphregion(color(white))
graph export "20241031_HW2_4_a.png", as(png) replace

* (b)

program define ols_homoskedastic, rclass

	clear
	drop _all
	set obs 1000
	gen X = rnormal(4, 2)
	gen e_Homoskedastic = rnormal(4, 2) + 1
	gen Y_Homoskedastic = 3 * X + e_Homoskedastic

	reg Y_Homoskedastic X

	end

simulate beta = _b[X], reps(1000): ols_homoskedastic
sum
hist beta, xtitle("With Homoskedasticity") graphregion(color(white)) bgcolor(white) saving(ols_homoskedastic, replace)

program define ols_heteroskedastic, rclass

	clear
	drop _all
	set obs 1000
	gen X = rnormal(4, 2)
	gen e_Heteroskedastic = rnormal(4, 0.5 * X) + 1
	gen Y_Heteroskedastic = 3 * X + e_Heteroskedastic

	reg Y_Heteroskedastic X

	end

simulate beta = _b[X], reps(1000): ols_heteroskedastic
sum
hist beta, xtitle("Without Homoskedasticity") graphregion(color(white)) bgcolor(white) saving(ols_heteroskedastic, replace)

graph combine ols_homoskedastic.gph ols_heteroskedastic.gph, graphregion(color(white))
graph export "20241031_HW2_4_b.png", as(png) replace
