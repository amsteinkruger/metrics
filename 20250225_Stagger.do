* Problem Set 3

* (3)

clear all

* Get packages.

* ssc install bacondecomp

* Get data.

use "data/ps3_castle.dta"

* Set up estimates.

*  Manual:

*  Set up a total count for n_* calculations.

egen count = count(year)

*  Set up n_2006. 

gen n_2006_bin = 0
replace n_2006_bin = 1 if castle_year == 2006

egen n_2006_sum = sum(n_2006_bin)
gen n_2006 = n_2006_sum / count

drop n_2006_*

*  Set up n_2009.

gen n_2009_bin = 0
replace n_2009_bin = 1 if castle_year == 2009

egen n_2009_sum = sum(n_2009_bin)
gen n_2009 = n_2009_sum / count

drop n_2009_*

*  Set up n_inf.

gen n_inf_bin = 0
replace n_inf_bin = 1 if castle_year == 0

egen n_inf_sum = sum(n_inf_bin)
gen n_inf = n_inf_sum / count

drop n_inf_*

*  Set up n_2006_inf, n_2006_2009, n_2009_2006.

gen n_2006_inf = n_2006 / (n_2006 + n_inf)
gen n_2006_2009 = n_2006 / (n_2006 + n_2009)
gen n_2009_2006 = n_2009 / (n_2006 + n_2009)

*  Set up D_2006, D_2009. This wouldn't be hard-coded if Stata was reasonable.

gen D_2006 = (2010 - 2006 + 1) / (2010 - 2000 + 1)
gen D_2009 = (2010 - 2009 + 1) / (2010 - 2000 + 1)

*  Get the variance quotient.

egen V_u = mean(castle_post)
gen V_D = V_u * (1 - V_u)

*  Get weights without the variance quotient.

gen s_2006_inf = (n_2006 + n_inf) ^ 2 * n_2006_inf * (1 - n_2006_inf) * D_2006 * (1 - D_2006)
gen s_2006_2009_2006 = ((n_2006 + n_2009) * (1 - D_2009)) ^ 2 * n_2006_2009 * (1 - n_2006_2009) * (((D_2006 - D_2009) / (1 - D_2009)) * ((1 - D_2006) / (1 - D_2009)))
gen s_2006_2009_2009 = ((n_2006 + n_2009) * (D_2006)) ^ 2 * n_2006_2009 * (1 - n_2006_2009) * ((D_2009 / D_2006) * ((D_2006 - D_2009) / D_2006))

*  Get estimates for export. 

collapse (mean) s_*
xpose, varname clear

gen Comparison = "2006_Inf"
replace Comparison = "2006_2009" if _varname != "s_2006_inf"
gen Control = "2006"
replace Control = "2009" if _varname == "s_2006_2009_2009"
drop _varname

rename v1 Weight_Manual
order Comparison Control Weight_Manual

format Weight_Manual %9.6f

list, abbreviate(24)

*  bacondecomp:

clear all

use "data/ps3_castle.dta"

xtset sid year

quietly xtreg l_homicide castle_post, fe // Following an example in documentation for bacondecomp.

quietly bacondecomp l_homicide castle_post, stub(Bacon_) ddetail nograph

* Get estimates for export.

keep Bacon_T Bacon_C Bacon_S Bacon_B
keep if (Bacon_T == "2006" & Bacon_C == "Never") | (Bacon_T == "2006" & Bacon_C == "2009") | (Bacon_T == "2009" & Bacon_C == "2006")

gen sort = 1
replace sort = 2 if Bacon_C == "2009"
replace sort = 3 if Bacon_C == "2006"
sort sort
drop sort

gen Comparison = "2006_Inf"
replace Comparison = "2006_2009" if Bacon_C != "Never"
gen Control = "2006"
replace Control = "2009" if Bacon_C == "2006"

rename Bacon_S Weight_bacondecomp
rename Bacon_B Coefficient_bacondecomp
keep Comparison Control Weight_bacondecomp Coefficient_bacondecomp
order Comparison Control Weight_bacondecomp Coefficient_bacondecomp

format Weight_bacondecomp %9.6f
format Coefficient_bacondecomp %9.6f

list, abbreviate(24)
