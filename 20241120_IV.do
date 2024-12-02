* (4)

log using "C:\Users\amste\OneDrive\Documents\GitHub\metrics\20241120_IV.smcl", replace

use "data/Medical_Expenditure_Data.dta", clear

keep ldrugexp hi_empunion totchr age female blhisp linc ssiratio lowincome firmsz  

* (c)
 
ivregress 2sls ldrugexp  totchr age female blhisp linc (hi_empunion = ssiratio), vce(robust) first

* (d)

estat endogenous

* (e)
 
ivregress 2sls ldrugexp  totchr age female blhisp linc (hi_empunion = ssiratio lowincome firmsz), vce(robust) first

* (f)

estat overid
