* (2)

use cps09mar.dta, clear

* Begin reference material

* Hansen p. 92:

gen wage = ln(earnings/(hours*week))
gen experience = age - education - 6
gen exp2 = (experience^2)/100
gen mbf = (race  == 2) & (marital <= 2) & (female == 1)

reg wage education experience exp2 if(mbf == 1)

* Use nlcom for calculations  - nonlinear combination of estimators*

nlcom 100*_b[education]
nlcom 100*_b[experience] + 20*_b[exp2]
nlcom -50*_b[experience]/_b[exp2]

* Don't quite match results in text *

* End reference material
