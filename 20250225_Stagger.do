* Problem Set 3

* (3)

clear all

* Get packages.

* ssc install bacondecomp

* Optionally, replicate Cunningham's demo with ddtiming.

* net install ddtiming, from(https://raw.githubusercontent.com/tgoldring/ddtiming/master)

* Get data.

use "data/ps3_castle.dta"

* Set up estimates.

*  Following Cunningham with ddtiming:

* areg l_homicide castle_post i.year, a(sid) robust
* ddtiming l_homicide castle_post, i(sid) t(year)

*  Using bacondecomp instead:

xtset sid year

xtreg l_homicide castle_post, fe robust // Following an example in documentation for bacondecomp.

bacondecomp l_homicide castle_post, robust stub(Bacon_) ddetail nograph

* Problem: interpreting problem set notation, interpreting different bacondecomp outputs, and choosing the right bacondecomp output to check manual answers against
