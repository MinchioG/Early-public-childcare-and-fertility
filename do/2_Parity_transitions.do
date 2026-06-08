*------------------------------------------------------------------------------
*******************************************************************************
*										
* Coding parities transitions on EU-SILC			
*
* Giovanni Minchio
*
* University of Trento
*
* 10.03.2024
*
*******************************************************************************
*------------------------------------------------------------------------------

/*

*** Introduciton

The process presented here stems from the Own-Children Method.

Here, we code parities transitions starting from the individual mothers' identifiers.
In doing so, I create a variables that record for each woman, each year,
the year of birth of their offsprings, up to the fifth.

In order to identify parity transitions from this women-only data we record 
when the child enters the household and, therefore, the dataset. 
This was thought to be more consistent than matching year of birth 
and survey year, given the informational lag that comes woth survey interviews.

*/


clear 

cd "your directory/Early public childcare and fertility"



*------------------------------------------------------------------------------
**# Data preparation
*------------------------------------------------------------------------------

use "cleaned/Master_DHR.dta", clear

drop if DmergeH == 1
drop if DHmergeR == 1

drop DmergeH DHmergeR

* creating a variable for age, more consistent with the by-year framework
gen age = year - rb080 



drop if country == "MT" // dropping Malta solves problems with age

label values rb080 // relabeling age

drop if YrInP < 2005 // only few countries before 2005


*** Unique identifiers

/* 
	upid is not unique in the same hhld across time, 
	using year-of-birth (rb080) solve the issue 
	
*/

tostring rb080, gen(rb080_str) format("%15.0f")

gen upid2 = substr(upid,1,7) + substr(upid,8,strlen(upid)-9) ///
				+ rb080_str + substr(pid,-2,2)


*** Individual year of survey entry


bysort country upid2: egen YrInP = min(year)
bysort country upid2: egen YrOutP = max(year)
gen obs_windowP = YrOutP - YrInP + 1

compress 
save "cleaned/Master_PrePar.dta", replace

*------------------------------------------------------------------------------
**# Generating offsprings variables 
*------------------------------------------------------------------------------


/*
	I start by extracting only offsprings of observed mothers 
	i.e., mother.id != . 
*/


drop if rb230 == . 

keep country year urtgrp uhid rb070 rb080 ///
rb090 rb110 rb230 rb230_f upid upid2 age // smaller dataset

drop if age == . 


/* generate unique mother id that can be then matched with upid 
	(same method as eusilcpanel by GESIS)
	RMK: as noted above upid is not unique across different years 
	of observation, but upid2 will provide us with non-unique flags.
	Moreover, the following will be generated yearly, 
	which allows for uniqueness, 
	and mothers have been already flagged in the source dataset */


		tostring rb230, gen(mid_str) format("%15.0f")
	gen suhid = substr(uhid,1,7)
	gen umid = suhid + mid_str
	drop suhid
	
	
* Ranking each offspring of the same mid by age 

bys year uhid umid: egen offs_rank = rank(rb080), unique

rename rb080 birth_year

tab offs_rank, m  
	
	

*** birth_year
gen offs1_brthyr = . 
replace offs1_brthyr = birth_year if offs_rank == 1

gen offs2_brthyr = . 
replace offs2_brthyr = birth_year if offs_rank == 2

gen offs3_brthyr = . 
replace offs3_brthyr = birth_year if offs_rank == 3

gen offs4_brthyr = . 
replace offs4_brthyr = birth_year if offs_rank == 4

gen offs5_brthyr = . 
replace offs5_brthyr = birth_year if offs_rank == 5


*** age
gen offs1_age = . 
replace offs1_age = age if offs_rank == 1

gen offs2_age = . 
replace offs2_age = age if offs_rank == 2

gen offs3_age = . 
replace offs3_age = age if offs_rank == 3

gen offs4_age = . 
replace offs4_age = age if offs_rank == 4

gen offs5_age = . 
replace offs5_age = age if offs_rank == 5

/* 
	Only 0.37% of sample is left above the 5th birth 
	96.98% of the sample has ranked 3rd or lower
*/

sort umid year offs_rank 


/* Checks

list upid umid year offs_rank birth_year ///
offs1_brthyr offs2_brthyr offs3_brthyr in 99/120
list upid umid year offs_rank birth_year  ///
offs1_age offs2_age offs3_age in 99/120

*/

label data "Only offsprings data"

compress
save "cleaned/Master_offs_only.dta", replace


keep year birth_year umid uhid offs1_brthyr ///
	offs2_brthyr offs3_brthyr offs4_brthyr offs5_brthyr ///
	offs1_age offs2_age offs3_age offs4_age offs5_age


bys year umid: egen offs1_ageall = max(offs1_age) 

/*check*/
sort umid year
list  umid year  offs1_age offs2_age offs1_ageall in 99/120

/* offs*_age is recorded only on the line (offspring obs) 
	while offs*_ageall is populated for each line */
	
drop offs1_ageall

bys year umid: egen offs1_brthyrall = max(offs1_brthyr) 
bys year umid: egen offs2_brthyrall = max(offs2_brthyr) 
bys year umid: egen offs3_brthyrall = max(offs3_brthyr) 
bys year umid: egen offs4_brthyrall = max(offs4_brthyr) 
bys year umid: egen offs5_brthyrall = max(offs5_brthyr) 


bys year umid: egen offs1_ageall = max(offs1_age) 
bys year umid: egen offs2_ageall = max(offs2_age) 
bys year umid: egen offs3_ageall = max(offs3_age)
bys year umid: egen offs4_ageall = max(offs4_age) 
bys year umid: egen offs5_ageall = max(offs5_age) 


/*	check
sort umid year birth_year
list  umid year offs1_brthyr offs2_brthyr offs3_brthyr offs1_brthyrall offs2_brthyrall offs3_brthyrall in 99/120
list  umid year  offs1_brthyrall offs2_brthyrall offs3_brthyrall offs4_brthyrall offs5_brthyrall in 199001/199130
list  umid year  offs1_brthyrall offs2_brthyrall offs3_brthyrall offs4_brthyrall offs5_brthyrall if offs5_ageall != . & offs1_brthyrall>2010
list  umid year  offs1_brthyrall offs2_brthyrall offs3_brthyrall offs4_brthyrall offs5_brthyrall if offs2_brthyrall == 2010 & year > 2009

*/

drop birth_year offs1_brthyr offs2_brthyr ///
	offs3_brthyr offs4_brthyr offs5_brthyr offs1_age ///
	offs2_age offs3_age offs4_age offs5_age


*** Chech for duplicates 

duplicates report 

duplicates report year umid uhid 	// must be equal to the above
duplicates report umid 				// must be equal to the above

/* 
	In the datasat derived from SILC we have n*t mother-years 
	over n mothers. Thus, we need to drop duplicates (offs-years) 
	and keep only mother-years 
*/
	
bys umid year uhid: gen cnt = 1 if _n ==1 
tab cnt // check number of mother-years (n*t)
drop cnt 

duplicates drop

disp _N // must be equal to tab cnt above

label data "Mothers' IDs with year-of-birth and age of the first five offsprings"

rename umid upid 	// to have a common identifier for merging


duplicates report upid year


bys upid year: gen cnt = 1 if _n ==1 // dropping the second duplicate - different hhld
tab cnt // check number of mother-years (n*t)

drop if cnt == . 

disp _N // must be equal to tab cnt above

duplicates report upid year

drop cnt

/*
given that upid (formerly umid) should be a unique identifier we can drop uhid.
We cannot use upid2 atm because we lack the mothers' year of birth 
*/ 

drop uhid 

compress
save "cleaned/Offsprings_age.dta", replace


*------------------------------------------------------------------------------
**# Merging offsprings year-of-birth and age to mothers' register 
*------------------------------------------------------------------------------

use "cleaned/Master_PrePar.dta", clear


/* 
In Offsprings_age.dta the identifiers are year and upid (mother-years)
However in DHR there are women registered in different hhlds at the same time.
We need to solve the problem before merging the data. 
Reminder: upid = uhid + pnum
*/


duplicates report year upid uhid	// no duplicates
duplicates report upid year			// 18,965 duplicates over 9,227,499
duplicates report upid2 year		// same as above

bys upid2 year: gen cnt = 1 if _n ==1 

drop if cnt == . // delete duplicates based on upid2


rename cnt cnt2

bys upid year: gen cnt = 1 if _n ==1 

drop if cnt == . // delete duplicates based on upid


// now we can merge since upid (and upid2) is a unique identifier

merge 1:1 year upid using "cleaned/Offsprings_age.dta"

rename _merge DHRmergeOffs


label data "Merged D H R masters and offsprings' year-of-birth and age"

compress
save "cleaned/DHRmergeOffs.dta", replace


drop if rb090 == 1    // drop those coded as biological male (female-based data)

label data " Women-only D H R and offsprings' year-of-birth and age"

compress
save "cleaned/DHRmergeOffsF.dta", replace

*------------------------------------------------------------------------------
**# Parities generation
*------------------------------------------------------------------------------

/* need to make the dataset lighter also for computational porpuses - Keep only women age [18,45] for now */


/* 

	For now the age drop will be done across all years. Hence will drop obs 
	who are less than 20 years old or older than 45 in the first wave. 
	
	*/
	 


bys upid2: egen ageMin = min(age)
bys upid2: egen ageMax = max(age)



drop if ageMin < 20 
drop if ageMin > 45




/* there still are duplicates in upid2 but not in upid2*uhid.
	the problem is that a woman can be observed only in uhid1 at t and then be observed in both uhid1 and uhid2
	but only in uhid2 we can find the birth info 
	We need to be sure to delete the duplicates without parities and keep also the info in the previuos hhld 
	

 browse if upid2 == "IT220137386400197203"
 in this example obs has a child but we do not observe them anymore afterwards 
 
 
 */
	

gen ones = 1 	

bys year upid2: egen dupessum = total(ones)

sort year upid2 uhid
	
bys year upid2: gen rnkdupes = _n

drop if rnkdupes == 2 & offs1_brthyrall ==. // keep info from previous hhld if duplicates are childless

drop if dupessum == 2 & offs1_brthyrall ==. // keep info from hhld in which we observe at least 1 offspring


duplicates report year upid2

duplicates report year upid2 offs1_brthyrall offs2_brthyrall offs3_brthyrall offs4_brthyrall offs5_brthyrall

drop rnkdupes
bys year upid2: gen rnkdupes = _n
tab rnkdupes
drop if rnkdupes == 2 

duplicates report year upid2 


rename YrInP YrInPall
rename YrOutP YrOutPall
rename obs_windowP obs_windowPall

bysort country  upid2: egen YrInP = min(year)
bysort country  upid2: egen YrOutP = max(year)
gen obs_windowP = YrOutP - YrInP + 1
	

/* generate flag for childlessness */ 

gen childless = 0

replace childless = 1 if offs1_brthyrall == . 


/* generate number of offsprings (maximum will be 5 or more given the code above) */

gen Nr_offs = . 

replace Nr_offs = 0 if childless == 1 
replace Nr_offs = 1 if offs1_brthyrall !=.
tab Nr_offs
replace Nr_offs = 2 if offs2_brthyrall !=.
tab Nr_offs
replace Nr_offs = 3 if offs3_brthyrall !=.
tab Nr_offs
replace Nr_offs = 4 if offs4_brthyrall !=.
tab Nr_offs
replace Nr_offs = 5 if offs5_brthyrall !=.
tab Nr_offs

tab Nr_offs childless, m 

/* only 0.62% of dataset (person-years) have 5 or more children */


duplicates report year upid2 Nr_offs 


* Generate offsprings entering the household by personal T


/*  First parity transitions refers to the first child appearing in the dataset. 
	For now the only method on stata is to create wide variables.
	This is consistent with the "newborn entering the household" 
	but it does not take into account the year of birth_year, as many of 
	the "newborn" are actually born the solar year prior to the study, 
	hence they might already be 1 y.o.
	However, we can observe the entering the hhld by offs*_brthyrall 
	changing from . to year-of-birth.
*/



gen chless_t0 = 0 
replace chless_t0 = 1 if childless == 1 & YrInP == year
bys upid2: egen chless_t0tot = max(chless_t0)

gen chless_t1 = .  
replace chless_t1 = 1 if childless == 1 & year == YrInP +1 
replace chless_t1 = 0 if childless == 0 & year == YrInP +1 
replace chless_t1 = 0 if year == YrInP +1 & chless_t0tot == 0 

bys upid2: egen chless_t1tot = max(chless_t1)

gen chless_t2 = . 
replace chless_t2 = 1 if childless == 1 & year == YrInP +2 
replace chless_t2 = 0 if childless == 0 & year == YrInP +2 
replace chless_t2 = 0 if year == YrInP +2 & chless_t1tot == 0 
bys upid2: egen chless_t2tot = max(chless_t2)

gen chless_t3 = . 
replace chless_t3 = 1 if childless == 1 & year == YrInP +3 
replace chless_t3 = 0 if childless == 0 & year == YrInP +3 
replace chless_t3 = 0 if year == YrInP +3 & chless_t2tot == 0 
bys upid2: egen chless_t3tot = max(chless_t3)

gen chless_t4 = . 
replace chless_t4 = 1 if childless == 1 & year == YrInP +4 
replace chless_t4 = 0 if childless == 0 & year == YrInP +4 
replace chless_t4 = 0 if year == YrInP +4 & chless_t3tot == 0 
bys upid2: egen chless_t4tot = max(chless_t4)

gen chless_t5 = . 
replace chless_t5 = 1 if childless == 1 & year == YrInP +5 
replace chless_t5 = 0 if childless == 0 & year == YrInP +5
replace chless_t5 = 0 if year == YrInP +5 & chless_t4tot == 0 
bys upid2: egen chless_t5tot = max(chless_t5)

gen chless_t6 = . 
replace chless_t6 = 1 if childless == 1 & year == YrInP +6 
replace chless_t6 = 0 if childless == 0 & year == YrInP +6
replace chless_t6 = 0 if year == YrInP +6 & chless_t5tot == 0 
bys upid2: egen chless_t6tot = max(chless_t6)

gen chless_t7 = 0 
replace chless_t7 = 1 if childless == 1 & year == YrInP +7
replace chless_t7 = 0 if childless == 0 & year == YrInP +7
replace chless_t7 = 0 if year == YrInP +7 & chless_t6tot == 0 
bys upid2: egen chless_t7tot = max(chless_t7)

gen chless_t8 = . 
replace chless_t7 = 1 if childless == 1 & year == YrInP +8
replace chless_t7 = 0 if childless == 0 & year == YrInP +8
replace chless_t7 = 0 if year == YrInP +8 & chless_t7tot == 0 
bys upid2: egen chless_t8tot = max(chless_t8)

gen chless_t9 = . 
replace chless_t7 = 1 if childless == 1 & year == YrInP +9
replace chless_t7 = 0 if childless == 0 & year == YrInP +9
replace chless_t7 = 0 if year == YrInP +9 & chless_t8tot == 0  
bys upid2: egen chless_t9tot = max(chless_t9)


drop chless_t0 chless_t1 chless_t2 chless_t3 chless_t4 chless_t5 chless_t6 chless_t7 chless_t8 chless_t9
rename chless_t0tot chless_t0
rename chless_t1tot chless_t1
rename chless_t2tot chless_t2
rename chless_t3tot chless_t3
rename chless_t4tot chless_t4
rename chless_t5tot chless_t5
rename chless_t6tot chless_t6
rename chless_t7tot chless_t7
rename chless_t8tot chless_t8
rename chless_t9tot chless_t9


/* Generate First parity indicator */

sort upid year

gen P1 = . 

replace P1 = 0 if chless_t0 == 1 

replace P1 = 1 if chless_t0 == 1 & childless == 0 & year == YrInP +1
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +2
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +3
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +4
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +5
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +6
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +7
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +8
replace P1 = 1 if chless_t0 == 1 & chless_t1 == 0 & year == YrInP +9


replace P1 = 0 if chless_t2 == 1 & year == YrInP +2
replace P1 = 1 if chless_t1 == 1 & childless == 0 & year == YrInP +2
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +3
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +4
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +5
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +6
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +7
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +8
replace P1 = 1 if chless_t1 == 1 & chless_t2 == 0 & year == YrInP +9

replace P1 = 0 if chless_t3 == 1 & year == YrInP +3
replace P1 = 1 if chless_t2 == 1 & childless == 0 & year == YrInP +3
replace P1 = 1 if chless_t2 == 1 & chless_t3 == 0 & year == YrInP +4
replace P1 = 1 if chless_t2 == 1 & chless_t3 == 0 & year == YrInP +5
replace P1 = 1 if chless_t2 == 1 & chless_t3 == 0 & year == YrInP +6
replace P1 = 1 if chless_t2 == 1 & chless_t3 == 0 & year == YrInP +7
replace P1 = 1 if chless_t2 == 1 & chless_t3 == 0 & year == YrInP +8
replace P1 = 1 if chless_t2 == 1 & chless_t3 == 0 & year == YrInP +9

replace P1 = 0 if chless_t4 == 1 & year == YrInP +4
replace P1 = 1 if chless_t3 == 1 & childless == 0 & year == YrInP +4
replace P1 = 1 if chless_t3 == 1 & chless_t4 == 0 & year == YrInP +5
replace P1 = 1 if chless_t3 == 1 & chless_t4 == 0 & year == YrInP +6
replace P1 = 1 if chless_t3 == 1 & chless_t4 == 0 & year == YrInP +7
replace P1 = 1 if chless_t3 == 1 & chless_t4 == 0 & year == YrInP +8
replace P1 = 1 if chless_t3 == 1 & chless_t4 == 0 & year == YrInP +9


replace P1 = 0 if chless_t5 == 1 & year == YrInP +5
replace P1 = 1 if chless_t4 == 1 & childless == 0 & year == YrInP +5 
replace P1 = 1 if chless_t4 == 1 & chless_t5 == 0 & year == YrInP +6
replace P1 = 1 if chless_t4 == 1 & chless_t5 == 0 & year == YrInP +7
replace P1 = 1 if chless_t4 == 1 & chless_t5 == 0 & year == YrInP +8
replace P1 = 1 if chless_t4 == 1 & chless_t5 == 0 & year == YrInP +9

replace P1 = 0 if chless_t6 == 1 & year == YrInP +6 
replace P1 = 1 if chless_t5 == 1 & childless == 0 & year == YrInP +6 
replace P1 = 1 if chless_t5 == 1 & chless_t6 == 0 & year == YrInP +7
replace P1 = 1 if chless_t5 == 1 & chless_t6 == 0 & year == YrInP +8
replace P1 = 1 if chless_t5 == 1 & chless_t6 == 0 & year == YrInP +9


replace P1 = 0 if chless_t7 == 1 & year == YrInP +6
replace P1 = 1 if chless_t6 == 1 & childless == 0 & year == YrInP +7
replace P1 = 1 if chless_t6 == 1 & chless_t7 == 0 & year == YrInP +8
replace P1 = 1 if chless_t6 == 1 & chless_t7 == 0 & year == YrInP +9

replace P1 = 0 if chless_t8 == 1 & year == YrInP +8 
replace P1 = 1 if chless_t7 == 1 & childless == 0 & year == YrInP +8 
replace P1 = 1 if chless_t7 == 1 & chless_t8 == 0 & year == YrInP +9

replace P1 = 0 if chless_t9 == 1 & year == YrInP +9 
replace P1 = 1 if chless_t8 == 1 & childless == 0 & year == YrInP +9 


replace P1 = . if offs1_brthyrall <= YrInP - 1

gen offs1_bfYin = . 
replace offs1_bfYin = 1 if offs1_brthyrall <= YrInP - 1

bys upid2: egen offs1_bfYin_F = max(offs1_bfYin)

replace P1 = . if offs1_bfYin_F == 1 
replace P1test = . if offs1_bfYin_F == 1 

bys upid2: egen offs1_brthyrallWide = max(offs1_brthyrall)
bys upid2: egen offs2_brthyrallWide = max(offs2_brthyrall)
bys upid2: egen offs3_brthyrallWide = max(offs3_brthyrall)

drop offs1_bfYin_F  offs1_bfYin

drop chless_t0 chless_t1 chless_t2 chless_t3 chless_t4 chless_t5 chless_t6  chless_t7 chless_t8 chless_t9


/* Generate Second parity indicator */

/* generate wide variable that takes value 1 when more than one offspring and 0 for one. */

gen offs1_t0 = . 
replace offs1_t0 = 1 if Nr_offs > 1 & YrInP == year
replace offs1_t0 = 0 if Nr_offs == 1 & year == YrInP

bys upid2: egen offs1_t0tot = max(offs1_t0)

gen offs1_t1 = . 
replace offs1_t1 = 0 if Nr_offs == 1 & year == YrInP +1 
replace offs1_t1 = 1 if Nr_offs > 1 & year == YrInP +1
replace offs1_t1 = 1 if year == YrInP +1 & offs1_t0tot == 1 
bys upid2: egen offs1_t1tot = max(offs1_t1)

gen offs1_t2 = . 
replace offs1_t2 = 0 if Nr_offs == 1 & year == YrInP +2 
replace offs1_t2 = 1 if Nr_offs > 1 & year == YrInP +2
replace offs1_t2 = 1 if year == YrInP +2 & offs1_t1tot == 1
bys upid2: egen offs1_t2tot = max(offs1_t2)

gen offs1_t3 = .
replace offs1_t3 = 0 if Nr_offs == 1 & year == YrInP +3 
replace offs1_t3 = 1 if Nr_offs > 1 & year == YrInP +3
replace offs1_t3 = 1 if year == YrInP +3 & offs1_t2tot == 1
bys upid2: egen offs1_t3tot = max(offs1_t3)

gen offs1_t4 = .
replace offs1_t4 = 0 if Nr_offs == 1 & year == YrInP +4 
replace offs1_t4 = 1 if Nr_offs > 1 & year == YrInP +4
replace offs1_t4 = 1 if year == YrInP +4 & offs1_t3tot == 1
bys upid2: egen offs1_t4tot = max(offs1_t4)

gen offs1_t5 = . 
replace offs1_t5 = 0 if Nr_offs == 1 & year == YrInP +5 
replace offs1_t5 = 1 if Nr_offs > 1 & year == YrInP +5
replace offs1_t5 = 1 if year == YrInP +5 & offs1_t4tot == 1
bys upid2: egen offs1_t5tot = max(offs1_t5)

gen offs1_t6 = .
replace offs1_t6 = 0 if Nr_offs == 1 & year == YrInP +6 
replace offs1_t6 = 1 if Nr_offs > 1 & year == YrInP +6
replace offs1_t6 = 1 if year == YrInP +6 & offs1_t5tot == 1
bys upid2: egen offs1_t6tot = max(offs1_t6)

gen offs1_t7 = . 
replace offs1_t7 = 0 if Nr_offs == 1 & year == YrInP +7 
replace offs1_t7 = 1 if Nr_offs > 1 & year == YrInP +7
replace offs1_t7 = 1 if year == YrInP +7 & offs1_t6tot == 1
bys upid2: egen offs1_t7tot = max(offs1_t7)

gen offs1_t8 = . 
replace offs1_t8 = 0 if Nr_offs == 1 & year == YrInP +8 
replace offs1_t8 = 1 if Nr_offs > 1 & year == YrInP +8
replace offs1_t8 = 1 if year == YrInP +8 & offs1_t7tot == 1
bys upid2: egen offs1_t8tot = max(offs1_t8)

gen offs1_t9 = . 
replace offs1_t8 = 0 if Nr_offs == 1 & year == YrInP +9 
replace offs1_t8 = 1 if Nr_offs > 1 & year == YrInP +9
replace offs1_t8 = 1 if year == YrInP +9 & offs1_t8tot == 1
bys upid2: egen offs1_t9tot = max(offs1_t9)


drop offs1_t0 offs1_t1 offs1_t2 offs1_t3 offs1_t4 offs1_t5 offs1_t6 offs1_t7 offs1_t8 offs1_t9

rename offs1_t0tot offs1_t0
rename offs1_t1tot offs1_t1
rename offs1_t2tot offs1_t2
rename offs1_t3tot offs1_t3
rename offs1_t4tot offs1_t4
rename offs1_t5tot offs1_t5
rename offs1_t6tot offs1_t6
rename offs1_t7tot offs1_t7
rename offs1_t8tot offs1_t8
rename offs1_t9tot offs1_t9



gen P2 = . 

replace P2 = 0 if offs1_t0 == 0
replace P2 = 0 if P1 == 1

replace P2 = 1 if offs1_t0 == 0 & Nr_offs > 1 & year == YrInP +1
replace P2 = 0 if Nr_offs == 1 & offs1_t0 == 0 & year == YrInP +1
replace P2 = 0 if Nr_offs == 1 & offs1_t0 == . & year == YrInP +1
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +2
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +3
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +4
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +5
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +6
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +7
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t0 == 0 & offs1_t1 == 1 & year == YrInP +9


replace P2 = 1 if offs1_t1 == 0 & Nr_offs > 1 & year == YrInP +2
replace P2 = 0 if Nr_offs == 1 & offs1_t1 == 0 & year == YrInP +2
replace P2 = 0 if Nr_offs == 1 & offs1_t1 == . & year == YrInP +2
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +3
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +4
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +5
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +6
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +7
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t1 == 0 & offs1_t2 == 1 & year == YrInP +9

replace P2 = 1 if offs1_t2 == 0 & Nr_offs > 1 & year == YrInP +3
replace P2 = 0 if Nr_offs == 1 & offs1_t2 == 0 & year == YrInP +3
replace P2 = 0 if Nr_offs == 1 & offs1_t2 == . & year == YrInP +3
replace P2 = 1 if offs1_t2 == 0 & offs1_t3 == 1 & year == YrInP +4
replace P2 = 1 if offs1_t2 == 0 & offs1_t3 == 1 & year == YrInP +6
replace P2 = 1 if offs1_t2 == 0 & offs1_t3 == 1 & year == YrInP +7
replace P2 = 1 if offs1_t2 == 0 & offs1_t3 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t2 == 0 & offs1_t3 == 1 & year == YrInP +9

replace P2 = 1 if offs1_t3 == 0 & Nr_offs > 1 & year == YrInP +4
replace P2 = 0 if Nr_offs == 1 & offs1_t3 == 0 & year == YrInP +4
replace P2 = 0 if Nr_offs == 1 & offs1_t3 == . & year == YrInP +4
replace P2 = 1 if offs1_t3 == 0 & offs1_t4 == 1 & year == YrInP +5
replace P2 = 1 if offs1_t3 == 0 & offs1_t4 == 1 & year == YrInP +6
replace P2 = 1 if offs1_t3 == 0 & offs1_t4 == 1 & year == YrInP +7
replace P2 = 1 if offs1_t3 == 0 & offs1_t4 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t3 == 0 & offs1_t4 == 1 & year == YrInP +9

replace P2 = 1 if offs1_t4 == 0 & Nr_offs > 1 & year == YrInP +5
replace P2 = 0 if Nr_offs == 1 & offs1_t4 == 0 & year == YrInP +5
replace P2 = 0 if Nr_offs == 1 & offs1_t4 == . & year == YrInP +5
replace P2 = 1 if offs1_t4 == 0 & offs1_t5 == 1 & year == YrInP +6
replace P2 = 1 if offs1_t4 == 0 & offs1_t5 == 1 & year == YrInP +7
replace P2 = 1 if offs1_t4 == 0 & offs1_t5 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t4 == 0 & offs1_t5 == 1 & year == YrInP +9


replace P2 = 1 if offs1_t5 == 0 & Nr_offs > 1 & year == YrInP +6
replace P2 = 0 if Nr_offs == 1 & offs1_t5 == 0 & year == YrInP +6
replace P2 = 0 if Nr_offs == 1 & offs1_t5 == . & year == YrInP +6
replace P2 = 1 if offs1_t5 == 0 & offs1_t6 == 1 & year == YrInP +7
replace P2 = 1 if offs1_t5 == 0 & offs1_t6 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t5 == 0 & offs1_t6 == 1 & year == YrInP +9

replace P2 = 1 if offs1_t6 == 0 & Nr_offs > 1 & year == YrInP +7
replace P2 = 0 if Nr_offs == 1 & offs1_t6 == 0 & year == YrInP +7
replace P2 = 0 if Nr_offs == 1 & offs1_t6 == . & year == YrInP +7
replace P2 = 1 if offs1_t6 == 0 & offs1_t7 == 1 & year == YrInP +8
replace P2 = 1 if offs1_t6 == 0 & offs1_t7 == 1 & year == YrInP +9

replace P2 = 1 if offs1_t7 == 0 & Nr_offs > 1 & year == YrInP +8
replace P2 = 0 if Nr_offs == 1 & offs1_t7 == 0 & year == YrInP +8
replace P2 = 0 if Nr_offs == 1 & offs1_t7 == . & year == YrInP +8
replace P2 = 1 if offs1_t7 == 0 & offs1_t8 == 1 & year == YrInP +9

replace P2 = 1 if offs1_t8 == 0 & Nr_offs > 1 & year == YrInP +9


tab P1 P2, m 


/* 
	As already discussed in general there is a lag between year-of-birth and 
	the moment of appearence in the data.
*/

list year age Nr_offs offs1_brthyrall offs2_brthyrall P1 P2 if uhid == "AT120081038900"

replace P2 = . if offs2_brthyrall <= YrInP - 1


gen offs2_bfYin = . 
replace offs2_bfYin = 1 if offs2_brthyrall <= YrInP - 1

bys upid2: egen offs2_bfYin_F = max(offs2_bfYin)

replace P2 = . if offs2_bfYin_F == 1 


drop offs1_t0 offs1_t1 offs1_t2 offs1_t3 offs1_t4 offs1_t5 offs1_t6 offs1_t7 offs1_t8 offs1_t9



*------------------------------------------------------------------------------
**# Right-censorship generation (time-to-event)
*------------------------------------------------------------------------------


// Given it has been recorded using a rolling OCM we need to censor backwards
// Easier solution: filling years of non-response and lagging P1/2


replace P1 = 1 if P1 == 0 & offs1_brthyrall < year & offs1_brthyrall !=. // filling the skips 
replace P1 = 1 if P1 == 0 & offs1_brthyrall == year & offs1_brthyrall !=. // filling the skips 


replace P2 = 1 if P2 == 0 & offs2_brthyrall < year & offs2_brthyrall !=. & offs1_brthyrall!=offs2_brthyrall 
// filling the skips
replace P2 = 1 if P2 == 0 & offs2_brthyrall == year & offs2_brthyrall !=. & offs1_brthyrall!=offs2_brthyrall 
// filling the skips


// if there are twins P2 shoud be =. 
replace P2 = . if offs1_brthyrall == offs2_brthyrall & offs1_brthyrall != . & P1 ==1 

preserve 

keep upid2 year P1 P2
rename P1 P1L1
rename P2 P2L1 
replace year = year + 1


save "cleaned/P12_L1.dta", replace

rename P1L1 P1L2
rename P2L1 P2L2 
replace year = year + 1


save "cleaned/P12_L2.dta", replace

restore 

merge 1:1 upid2 year using "cleaned/P12_L1.dta"

drop if  _merge==2
drop _merge

gen P1_rc = P1
gen P2_rc = P2


replace P1_rc = . if P1L1 ==1
replace P2_rc = . if P2L1 ==1


merge 1:1 upid2 year using "cleaned/P12_L2.dta"

drop if  _merge==2
drop _merge


replace P1_rc = . if P1L2 ==1
replace P2_rc = . if P2L2 ==1


list upid2 year P1 P1_rc P2 P2_rc  offs1_brthyrall offs2_brthyrall Nr_offs P1sum if P2sum == 2 

tab upid2 if P2sum == 2 

// manual override (just one individual)

replace P2_rc = . if P2sum == 2 & year == 2019


// check last year of observation 

bys upid2: egen maxyear = max(year) 
gen deltayrmax = YrOutP - maxyear
tab deltayrmax


replace P2 = . if P1_rc == 1 & P2_rc == 0 & year == YrOutP

replace P2_rc = . if P1_rc == 1 & P2_rc == 0 & year == YrOutP


rename P1 P1_4t // renaming the original P1/P2 ourcomes

rename P2 P2_4t // renaming the original P1/P2 ourcomes

rename P1_rc P1 // renaming right-censored outcomes 

rename P2_rc P2 // renaming right-censored outcomes 


*** Unique ids for mother and her partner id for individual-level variables  


tostring rb240, gen(part_id) format("%15.0f")
	gen suhid = substr(uhid,1,7)
	gen upartid = suhid + part_id
	drop suhid

replace upartid = "" if part_id == "."

tostring rb230, gen(mid) format("%15.0f")
	gen suhid = substr(uhid,1,7)
	gen umid = suhid + mid
	drop suhid

replace umid = "" if mid == "."

tostring rb220, gen(fid) format("%15.0f")
	gen suhid = substr(uhid,1,7)
	gen ufid = suhid + fid 
	drop suhid

replace ufid = "" if fid == "."

	
label data "Merged D H R masters with first and second parties - Only women aged 18 to 45 y.o."


compress 
save "cleaned/P12_NUTS_RC.dta", replace




