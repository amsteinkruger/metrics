* Problem Set 3

log using 20250503_Log, append

set iterlog off

* (5)
* (b)

clear all

* Set up a program.

program montecarlo, rclass

	drop _all
	set obs 1000

	gen id = _n

	gen x0 = 0.50 + runiform()

	gen x1 = runiform()

	gen x2 = 0
	replace x2 = runiform()^2 if x1 > 0.50

	gen y = x0 + x1 * id + x2 * id
	replace y = 0 if x1 <= 0.50

	tobit y x1, ll(0)
	
	return scalar b1_a = _b[x1]
	return scalar s1_a = _se[x1]
	
	tobit y x1 x2, ll(0)
	
	return scalar b1_b = _b[x1]
	return scalar s1_b = _se[x1]
	return scalar b2_b = _b[x2]
	return scalar s2_b = _se[x2]
	
	reg y x1 x2
	
	return scalar b1_c = _b[x1]
	return scalar s1_c = _se[x1]
	return scalar b2_c = _b[x2]
	return scalar s2_c = _se[x2]
	
end

* Execute the program.

simulate ///
b1_a = r(b1_a) s1_a = r(s1_a) ///
b1_b = r(b1_b) s1_b = r(s1_b) b2_b = r(b2_b) s2_b = r(s2_b) ///
b1_c = r(b1_c) s1_c = r(s1_c) b2_c = r(b2_c) s2_c = r(s2_c), ///
reps(100) seed(112358): montecarlo

* Tabulate estimates.
format b* s* %9.3f
sum, separator(0) format

* Visualize estimates.
* format b* s* %9.1f

