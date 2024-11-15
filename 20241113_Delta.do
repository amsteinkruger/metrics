* (2)

use "data/cps09mar.dta", clear

keep if female == 0 & hisp == 1 & race == 1 

gen wage = ln(earnings / (hours * week))
gen experience = age - education - 6
gen experience_sq = experience ^ 2 / 100

* (a)

reg wage education experience experience_sq, robust

* (b-d)
* See Section 7.11 in Hansen.

nlcom ///
(Ratio: ///
(_b[education] * 1 + _b[experience] * 10 + _b[experience_sq] * 10 ^ 2 / 100 + _b[_cons]) ///
/ ///
(_b[education] * 0 + _b[experience] * 11 + _b[experience_sq] * 11 ^ 2 / 100 + _b[_cons])), ///
level(90)

* (c)

matrix list e(V)

* (4)

use "data/Hoy_Mager_Data.dta", clear

* (b)

* under35 male pB40 perc-HI pref-LI vote-incumbent HHsiz
* Country codes are 1 through 10