* (2)

* Set up data.

use "data/Card1995.dta", clear

keep lwage76 ed76 age black reg76r smsa76r nearc2 nearc4 nearc4a nearc4b 

keep if !missing(lwage76, ed76, age, black, reg76r, smsa76r, nearc2, nearc4, nearc4a, nearc4b)

gen experience = age - ed76 - 6
gen experience_transform = experience^2 / 100

rename ///
(lwage76 ed76 reg76r smsa76r nearc2 nearc4 nearc4a nearc4b) ///
(wage education south urban college_2 college_4 public private)

keep wage age education experience experience_transform black south urban college_2 college_4 public private

order wage education age experience experience_transform black south urban college_2 college_4 public private

* (a)

ivregress 2sls wage experience experience_transform black south urban (education = public private), vce(robust)

regress education experience experience_transform black south urban public private, r

test public private

* (b)

regress education experience experience_transform black south urban college_2 public private, r

test college_2 public private

* (c)

gen public_age = public * age
gen public_age_transform = public * age^2 / 100

regress education experience experience_transform black south urban public_age public_age_transform public private, r

test public_age public_age_transform public private

* (d)

ivregress 2sls ///
wage experience experience_transform black south urban ///
(education = public_age public_age_transform public private), /// 
vce(robust)

* (e)

estat firststage, forcenonrobust

* (f)

ivregress liml ///
wage experience experience_transform black south urban ///
(education = public_age public_age_transform public private), /// 
vce(robust)

estat firststage, forcenonrobust

* (3)

* (a, b)

ivregress gmm wage experience experience_transform black south urban (education = public private), vce(robust)

estat firststage, forcenonrobust

estat overid

ivregress gmm ///
wage experience experience_transform black south urban ///
(education = public_age public_age_transform public private), /// 
vce(robust)

estat firststage, forcenonrobust

estat overid

* (4)

* Handle software. Cheers to the author for instructions at https://github.com/sergiocorreia/ivreghdfe. 
* cap ado uninstall ftools
* net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
* cap ado uninstall reghdfe
* net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
* cap ado uninstall ivreg2
* ssc install ivreg2
* cap ado uninstall ranktest
* ssc install ranktest
* cap ado uninstall ivreghdfe
* net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)

* Handle data. Cheers to the author for replication code.

use "data/Lyu_2023_Data_Original.dta", clear

foreach var in EV electric PHEV hydrogen {
gen scratch_`var'= sales_`var'0-sales_`var'
}

xtset zcta year

egen county_year = group(fips year)

gen ghi_1 = L.ghi
replace ghi_1 = ghi if year == 2011

drop income_mean

* (c)

* Get regression results and store them.

reghdfe ///
sales_EV0 L.cum_count hov_length price_gasoline station pop male age white highschool_more income*, ///
absorb(zcta county_year) cluster(zcta)

estimates store OLS_1

reghdfe ///
sales_EV0 L.cum_area hov_length price_gasoline station pop male age white highschool_more income*, ///
absorb(zcta county_year) cluster(zcta)

estimates store OLS_2

reghdfe ///
L.cum_count ghi_1 L.ghi_1 hov_length price_gasoline station pop male age white highschool_more income*, ///
absorb(zcta county_year) cluster(zcta)

estimates store First_1

reghdfe ///
L.cum_area ghi_1 L.ghi_1 hov_length price_gasoline station pop male age white highschool_more income*, ///
absorb(zcta county_year) cluster(zcta)

estimates store First_2

ivreghdfe ///
sales_EV0 hov_length price_gasoline station pop male age white highschool_more income* ///
(L.cum_count = ghi_1 L.ghi_1), ///
absorb(zcta county_year) cluster(zcta)

estimates store Second_1

ivreghdfe ///
sales_EV0 hov_length price_gasoline station pop male age white highschool_more income* ///
(L.cum_area = ghi_1 L.ghi_1), ///
absorb(zcta county_year) cluster(zcta)

estimates store Second_2

* Cough regression results back up.

estout *, ///
keep(L.cum* L.ghi_1 ghi_1) ///
cells(b(star fmt(3)) se(par fmt(3))) ///
stats(N r2, labels("Observations" "R-Squared")) ///
varlabels(L.cum_count "Solar" L.cum_area "Solar Cap." L.ghi_1 "GHI_-1" ghi_1 "GHI")

* (e)

ivreghdfe ///
sales_EV0 ///
(L.cum_count = ghi_1 L.ghi_1), /// 
absorb(zcta county_year) cluster(zcta) // first

estimates store No_Covars_3

ivreghdfe ///
sales_EV0 ///
(L.cum_area = ghi_1 L.ghi_1), /// 
absorb(zcta county_year) cluster(zcta) // first

estimates store No_Covars_4

estout No_Covars*, ///
keep(L.cum*) ///
cells(b(star fmt(3)) se(par fmt(3))) ///
stats(N, labels("Observations")) ///
varlabels(L.cum_count "Solar" L.cum_area "Solar Cap.")
