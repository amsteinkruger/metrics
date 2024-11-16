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

* Get Hoy and Mager's environment set up.

ssc install coefplot
ssc install estout
ssc install cibar
ssc install leebounds
ssc install betterbar 

net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
set scheme modern, perm

use "data/Hoy_Mager_Data.dta", clear

* (a)

* (b)

* Controls are under35 male pB40 perc-HI pref-LI vote-incumbent HHsiz.
* Country codes are 1 through 10.

* Table 3, Gap Too Large

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==1 
estimates store m1

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==2
estimates store m2

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==3
estimates store m3

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==4
estimates store m4

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==5
estimates store m5

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==6
estimates store m6

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==7
estimates store m7

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==8
estimates store m8

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==9
estimates store m9

reg gap_A Placedis_Con under35 male pB40 vote_incumbent HHsize if CTRY_code==10
estimates store m10

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 using "output/Table3a.csv", ///
cells(b(fmt(3)) se(par fmt(2)) p) ///
keep(Placedis_Con) nonumbers ///
mtitles("(ES)" "(IN)" "(MA)" "(MX)" "(NG)" "(NL)" "(US)" "(ZA)" "(UK)" "(AU)") ///
varlabels(Placedis_Con "Gap Too Large") ///
replace

* Table 3, Government Responsible

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==1
estimates store m1

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==2
estimates store m2

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==3
estimates store m3

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==4
estimates store m4

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==5
estimates store m5

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==6
estimates store m6

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==7
estimates store m7

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==8
estimates store m8

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==9
estimates store m9

reg res_A Placedis_Con under35 male pB40 vote_incumbent HHsize  if CTRY_code==10
estimates store m10

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 using "output/Table3b.csv", ///
cells(b(fmt(3)) se(par fmt(2)) p)  ///
keep(Placedis_Con) nonumbers ///
mtitles("(ES)" "(IN)" "(MA)" "(MX)" "(NG)" "(NL)" "(US)" "(ZA)" "(UK)" "(AU)") ///
varlabels(Placedis_Con "Government Responsible") ///
replace

* (c)

* Reestimate with heteroskedasticity-robust standard errors.

* Table 3, Gap Too Large

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==1, robust 
estimates store m1

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==2, robust
estimates store m2

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==3, robust
estimates store m3

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==4, robust
estimates store m4

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==5, robust
estimates store m5

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==6, robust
estimates store m6

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==7, robust
estimates store m7

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==8, robust
estimates store m8

reg gap_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==9, robust
estimates store m9

reg gap_A Placedis_Con under35 male pB40 vote_incumbent HHsize if CTRY_code==10
estimates store m10

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 using "output/Table3a_Robust.csv", ///
cells(b(fmt(3)) se(par fmt(2)) p) ///
keep(Placedis_Con) nonumbers ///
mtitles("(ES)" "(IN)" "(MA)" "(MX)" "(NG)" "(NL)" "(US)" "(ZA)" "(UK)" "(AU)") ///
varlabels(Placedis_Con "Gap Too Large") ///
replace

* Table 3, Government Responsible

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==1, robust
estimates store m1

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==2, robust
estimates store m2

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==3, robust
estimates store m3

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==4, robust
estimates store m4

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==5, robust
estimates store m5

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==6, robust
estimates store m6

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==7, robust
estimates store m7

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==8, robust
estimates store m8

reg res_A Placedis_Con under35 male pB40 perc_HI pref_LI vote_incumbent HHsize if CTRY_code==9, robust
estimates store m9

reg res_A Placedis_Con under35 male pB40 vote_incumbent HHsize  if CTRY_code==10
estimates store m10

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 using "output/Table3b_Robust.csv", ///
cells(b(fmt(3)) se(par fmt(2)) p)  ///
keep(Placedis_Con) nonumbers ///
mtitles("(ES)" "(IN)" "(MA)" "(MX)" "(NG)" "(NL)" "(US)" "(ZA)" "(UK)" "(AU)") ///
varlabels(Placedis_Con "Government Responsible") ///
replace

* (d)

drop if res_A  == .

* Table 4, Gap Too Large

xtreg gap_A Placedis_Con under35 male vote_incumbent HHsize pB40, i(CTRY_code)fe robust
estimates store m1, title(Model 1)

xtreg gap_A Placedis_Con under35 male vote_incumbent HHsize pB40 if deving==1, i(CTRY_code)fe robust
estimates store m2, title(Model 2)

xtreg gap_A Placedis_Con under35 male vote_incumbent HHsize pB40 if deving==0, i(CTRY_code)fe robust
estimates store m3, title(Model 3)

esttab m1 m2 m3 using "output/Table4a.csv", ///
cells(b(fmt(3)) se(par fmt(2)) p) ///
varlabels(Placedis_Con "Gap Too Large") keep(Placedis_Con) nonumbers mtitles("(ALL)" "(MICs)" "(HICs)") ///
replace

* Table 4, Government Responsible
   
xtreg res_A Placedis_Con under35 male HHsize pB40 vote_incumbent, i(CTRY_code)fe robust
estimates store m1, title(Model 1)

xtreg res_A Placedis_Con under35 male HHsize pB40 vote_incumbent if deving==1, i(CTRY_code)fe robust
estimates store m2, title(Model 2)

xtreg res_A Placedis_Con under35 male HHsize pB40 vote_incumbent if deving==0, i(CTRY_code)fe robust
estimates store m3, title(Model 3)

esttab m1 m2 m3 using "output/Table4b.csv", ///
cells(b(fmt(3)) se(par fmt(2)) p) ///
varlabels(Placedis_Con "Government Responsible") keep(Placedis_Con) nomtitles nonumbers ///
replace
