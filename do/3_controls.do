*------------------------------------------------------------------------------
*******************************************************************************
*
* Controls and sample selection
*
* Giovanni Minchio
*
* University of Trento
*
* 17.04.2024
*
*******************************************************************************
*------------------------------------------------------------------------------


clear 

cd "your directory/Early public childcare and fertility"


use "data/masterP.dta", clear // individual level characteristics dataset 


gen upartid = upid 

desc 

rename pb150 sex

*------------------------------------------------------------------------------
**# keep only necessary variables 
*------------------------------------------------------------------------------ 

desc sex pb190 pb200 pl020* pl025* pl031* pl160 pl170 pl180 pl190 pl200 pl210* ///
		pl211* pl040* pl051 pl060 pl140* pe040* py010* py020* px010 pd050 pe020 /// 
		pl110 py09* country year upid uhid upartid py05*
	
keep sex pb190 pb200 pl020* pl025* pl031* pl160 pl170 pl180 pl190 pl200 pl210* ///
	pl211* pl040* pl051 pl060 pl140* pe040* py010* py020* px010 pd050 pe020 /// 
	pl110 py09* country year upid uhid upartid py05*

	
*------------------------------------------------------------------------------
**# Education (pe040)
*------------------------------------------------------------------------------ 

gen educ3 = . 

replace educ3 = 3 if pe040 > 499
replace educ3 = 2 if pe040 < 451
replace educ3 = 1 if pe040 < 201

replace educ3 = 3 if pe040 == 6 | pe040 == 5
replace educ3 = 2 if pe040 == 3 | pe040 == 4 
replace educ3 = 1 if pe040 == 0 | pe040 == 1 | pe040 == 2
replace educ3 = . if pe040 == .

gen educ2 = educ3 

replace educ2 = 1 if educ2 == 2
replace educ2 = 2 if educ2 == 3 
replace educ2 = . if pe040 == .

tab educ2 pe040_f, m 
tab educ2 educ3, m 

label variable educ3 "Education (3 cat.)"
label variable educ2 "Education (2 cat.)"

label define educ3l 1 "Low" 2 "Medium" 3 "High"
label define educ2l 1 "Low-Medium" 2 "High"

label values educ3 educ3l  
label values educ2 educ2l  

tab educ2 year


*------------------------------------------------------------------------------
**# Employment status (pl031, pl040, pl020, pl060)
*------------------------------------------------------------------------------

/*

pl031, pl211* and  are missing before 2009 
pl040, pl020, pl060 are present and could be used to develop a synthetic measure 
before 2009 for empl3 and empl4
empl2 is not an issue since pl040_f records who is employed and who is not.

 */
 
// twoway( histogram pl060 if pl031 == 1 | pl031 == 3, color(red%30)) ///        
//        (histogram pl060 if pl031 == 2 | pl031 == 4, color(green%30)), ///   
//        legend(order(1 "Full-time" 2 "Part-time" ))

/*
Looks like 30 hours is a good threshold for distinguishing full-time/part-time 
we could use it to define observations before 2009 
*/

// tab  pl031 pl020, m row
// tab  pl031 pl020 if year < 2009, m row

/*

pl020 is needed to define who's inactive and who's unemployed.
97% of the observations that are missing in 2009 can be found here. 

*/ 
 
gen empl4 =. 

replace empl4 = 1 if pl040_f == -2 
replace empl4 = 4 if pl040_f == 1
replace empl4 = 4 if pl031 == 1 | pl031 == 3 
replace empl4 = 3 if pl031 == 2 | pl031 == 4
replace empl4 = 1 if pl031 == 10 | pl031 == 11
replace empl4 = 2 if pl031 == 5
replace empl4 = 3  if pl060 != . & pl060 <= 30 & year < 2009 & pl031 ==.
replace empl4 = 4  if pl060 != . & pl060 > 30 & year < 2009 & pl031 ==.
replace empl4 = 2 if empl4 == 1  & pl020 == 1 
replace empl4 = 1 if empl4 == 2  & pl020 == 2 
replace empl4 = . if pl031 == 9 | pl031 == 8 | pl031 == 7 | pl031 == 6

label variable empl4 "Employment status (4 cat.)"

label define empl4l 1 "inactive" 2 "unemployed"  3 "part-time" 4 "full-time"
label values empl4 empl4l  


gen empl3 =. 

replace empl3 = 1 if empl4 == 1 | empl4 == 2
replace empl3 = 2 if empl4 == 3
replace empl3 = 3 if empl4 == 4

label variable empl3 "Employment status (3 cat.) - unemployed-inactive; part-time; full-time"

label define empl3l 1 "unemployed-inactive" 2 "part-time" 3 "full-time"
label values empl3 empl3l  


gen empl3b =. 

replace empl3b = 1 if empl4 == 1 
replace empl3b = 2 if empl4 == 2
replace empl3b = 3 if empl4 == 4 | empl4 == 4


label variable empl3b "Employment status (3 cat.) - inactive; unemployed; employed"

label define empl3bl 1 "inactive" 2 "unemployed" 3 "employed"
label values empl3b empl3bl  


gen empl2 =. 

replace empl2 = 1 if empl4 == 1 | empl4 == 2
replace empl2 = 2 if empl4 == 3 | empl4 == 4


label variable empl2 "Employment status (2 cat.)"

label define empl2l 1 "unemployed-inactive" 2 "employed"
label values empl2 empl2l  


compress
save "cleaned/Pers_Inc_Empl_Edu.dta", replace


** Lagged employment variables 

* 1 year

keep upid year empl2 empl3 empl3b empl4 

replace year = year + 1


rename empl2 empl2_L1 
rename empl3 empl3_L1 
rename empl3b empl3b_L1
rename empl4 empl4_L1

label variable empl4_L1 "Employment status (4 cat.) Lag 1"
label variable empl3_L1 "Employment status (3 cat.) Lag 1"
label variable empl3b_L1 "Employment status (3 cat.) Lag 1"
label variable empl2_L1 "Employment status (2 cat.) Lag 1"

save "cleaned/Empl_L1.dta", replace


* 2 years

replace year = year + 1

rename  empl2_L1 empl2_L2
rename  empl3_L1 empl3_L2
rename empl3b_L1 empl3b_L2
rename  empl4_L1 empl4_L2

label variable empl4_L2 "Employment status (4 cat.) Lag 2"
label variable empl3_L2 "Employment status (3 cat.) Lag 2"
label variable empl3b_L2 "Employment status (3 cat.) Lag 2"
label variable empl2_L2 "Employment status (2 cat.) Lag 2"


save "cleaned/Empl_L2.dta", replace


* merge 

use "cleaned/Pers_Inc_Empl_Edu.dta", clear

merge 1:1 upid year using "cleaned/Empl_L1.dta"
drop if _merge == 2
drop _merge
merge 1:1 upid year using "cleaned/Empl_L2.dta"
drop if _merge == 2
drop _merge

*** Renaming variables 

rename pb190 marit_st
rename pb200 cons_union

rename upid upidF

keep educ* empl* sex marit_st cons_union UnempBen py020n emplInc pd050 /// 
	NACE ISCO year upartid upidF SelfEmplNet SelfEmplGross pl031

	
duplicates report upartid year

compress
save  "cleaned/Pers_Inc_Empl_Edu.dta", replace



*------------------------------------------------------------------------------ 
**# Merge personal characteristics and parity transitions
*------------------------------------------------------------------------------ 


use "cleaned/P12_NUTS_RC.dta", clear 



*------------------------------------------------------------------------------ 
**# Drop countries
*------------------------------------------------------------------------------ 

/*
Based on results from Nitsche et al.(2021) and Greulich and Dasré (2017) we exluded Bulgaria, Cyprus, 
Lithuania, Malta, and Romania.

Greulich, Angela, and Aurélien Dasré. 2017. `The Quality of Periodic Fertility Measures in EU-SILC'. Demographic Research 36:525–56. doi:10.4054/DemRes.2017.36.17.
Nitsche, Natalie, Anna Matysiak, Jan Van Bavel, and Daniele Vignoli. 2021. `Educational Pairings and Fertility Across Europe: How Do the Low-Educated Fare?' Comparative Population Studies 46. doi:10.12765/CPoS-2021-19.


ECEC data:
	- UK only 2015-2019 (only England)
	- RO only 2015-2018
	- DK only 2000-2014
	- NL only 2007-2017
	- CY CH IS LT LU LV EE EL PT RS not present

EU-SILC:
	- DE, NL only NUTS-0 (country-level)
	- UK stops in 2018
	- DE only 2015-2019
	- HR only 2010-2020
	- DK, HR, IE, NO, SI, SK nuts-1 are equal to the whole country
	*/
	
	
drop if country == "BG"
drop if country == "DE"
drop if country == "CY"
drop if country == "EE"
drop if country == "EL"
drop if country == "HR"
drop if country == "IS"
drop if country == "LU"
drop if country == "LV"
drop if country == "LT"
drop if country == "PT"
drop if country == "RO" 
drop if country == "RS"
drop if country == "SI"
drop if country == "UK" 


*------------------------------------------------------------------------------ 
**# Merge individual info
*------------------------------------------------------------------------------ 


* Start from the partner's characteristics

/*
A major necessity is part_id to be valid, thus all obsrvation missing such 
information at t0 should be dropped 
*/

replace upartid = "" if part_id == "." /* check for missing partners and drop miscoded upartid */

// codebook part_id
//
gen no_partid = 0
replace no_partid = 1 if rb240 == . & YrInP == year
bys upid2: egen no_partidt0 = max(no_partid)

drop if no_partidt0 == 1 // drop women with no partner (living together)


duplicates report upartid year

bys upartid year: gen dupes = _n

tab upartid if dupes >1, m
// browse if uhid == "NO220152456900" /* two women, same hhld same partner -- > merge m:1 */
drop if dupes >1 & rb240 != .

duplicates report upartid year

drop dupes no_partid no_partidt0


* merge parnters' infos

merge m:1 upartid year using "Cleaned/Pers_Inc_Empl_Edu.dta"

drop if _merge == 2

rename _merge P12mergePersP

drop upidF

rename educ* P_educ*
rename empl* P_empl*
rename sex P_sex
rename NACE P_NACE
rename ISCO P_ISCO
rename UnempBen P_UnempBen
rename py020n P_py020n 
rename pd050 P_pd050
rename SelfEmplNet P_SelfEmplNet 
rename SelfEmplGross P_SelfEmplGross
rename pl031 P_pl031
drop marit_st cons_union 



*** Merge women's characteristics

gen upidF = upid 

merge 1:1 upidF year using "Cleaned/Pers_Inc_Empl_Edu.dta"
drop if _merge == 2
rename _merge P12mergePersF

drop upidF



*------------------------------------------------------------------------------ 
**# Cohabiting and marital status  
*------------------------------------------------------------------------------ 

gen cohab = . 
replace cohab = 1 if rb240 !=.
replace cohab = 0 if rb240 ==.
label variable cohab "Cohabiting with partner/spouse"
label define dummyYN 0 "No" 1 "Yes"
label values cohab dummyYN


gen cohab_0 = .
replace cohab_0 = cohab if year ==YrInP
bys upid2: egen cohab_t0 = max(cohab_0)

drop cohab_0

gen married = . 
replace married = 1 if marit_st == 2
replace married = 0 if marit_st == 1
replace married = 0 if marit_st == 3
replace married = 0 if marit_st == 4
replace married = 0 if marit_st == 5

label values married dummyYN

gen single = . 
replace single = 1 if marit_st == 1 & cohab == 0 
replace single = 0 if cohab == 1
replace single = 0 if married == 1
replace single = 0 if cons_union == 2
replace single = 0 if cons_union == 1
replace single = 1 if cons_union == 3 & cohab == 0 

label variable single "Nor married, in union or cohabiting"
label values single dummyYN


gen fam_type = . 
replace fam_type = 1 if married == 1 & cohab == 1 
replace fam_type = 2 if married == 0 & cohab == 1 & single == 0 
replace fam_type = 3 if married == 1 & cohab == 0 
replace fam_type = 3 if cons_union == 1 & cohab == 0 
replace fam_type = 3 if cons_union == 2 & cohab == 0 
replace fam_type = 4 if single == 1 

label variable fam_type "Partnership status (4 cat.)"
label define fam_typel 1 "Married"  2 "Cohabiting" 3 "Non-cohabiting unions" 4 "Non-cohabiting/Single"
label values fam_type fam_typel

tab fam_type


gen fam_type_yrin = fam_type if year == YrInP 

bys upid2: egen fam_type_t0 = max(fam_type_yrin)

drop fam_type_yrin

label variable fam_type_t0 "Partnership status (4 cat.) at t0"
label values fam_type_t0 fam_typel

tab fam_type fam_type_t0, m 
tab cohab_t0 fam_type_t0

gen sep_divorced = . 
replace sep_divorced = 0 if marit_st == 2
replace sep_divorced = 1 if marit_st == 3 | marit_st == 5

gen married_t0 = fam_type_t0

recode married_t0  (1=1) (2 = 0) (else = .)
lab val married_t0 dummyYN

tab married_t0 married, m



*------------------------------------------------------------------------------ 
**# Variables fixed at entrance (t=0)
*------------------------------------------------------------------------------ 


*** Employment

tab empl4
tab pl031 empl4, m 
tab P_pl031 P_empl4, m 
tab pl031 P_empl4, m 


gen pl031_yrin = pl031 if year == YrInP 

bys upid2: egen pl031_t0 = max(pl031_yrin)

drop pl031_yrin


gen P_pl031_yrin = P_pl031 if year == YrInP 

bys upid2: egen P_pl031_t0 = max(P_pl031_yrin)

drop P_pl031_yrin

gen empl4_yrin = empl4 if year == YrInP 

bys upid2: egen empl4_t0 = max(empl4_yrin)

drop empl4_yrin

label variable empl4_t0 "Employment status (4 cat.) at t0"
label values empl4_t0 empl4l  


gen empl3_yrin = empl3 if year == YrInP 

bys upid2: egen empl3_t0 = max(empl3_yrin)

drop empl3_yrin

label variable empl3_t0 "Employment status (3 cat.) at t0"
label values empl3_t0 empl3l  


gen empl3b_yrin = empl3b if year == YrInP 

bys upid2: egen empl3b_t0 = max(empl3b_yrin)

drop empl3b_yrin

label variable empl3b_t0 "Employment status (3 cat.) at t0"
label values empl3b_t0 empl3bl 


gen empl2_yrin = empl2 if year == YrInP 

bys upid2: egen empl2_t0 = max(empl2_yrin)

drop empl2_yrin

label variable empl2_t0 "Employment status (2 cat.) at t0"
label values empl2_t0 empl2l  


gen P_empl4_yrin = P_empl4 if year == YrInP 

bys upid2: egen P_empl4_t0 = max(P_empl4_yrin)

drop P_empl4_yrin

label variable P_empl4_t0 "Employment status (4 cat.) at t0"
label values P_empl4_t0 empl4l  


gen P_empl3_yrin = P_empl3 if year == YrInP 

bys upid2: egen P_empl3_t0 = max(P_empl3_yrin)

drop P_empl3_yrin

label variable P_empl3_t0 "Employment status (3 cat.) at t0"
label values P_empl3_t0 empl3l  


gen P_empl3b_yrin = P_empl3b if year == YrInP 

bys upid2: egen P_empl3b_t0 = max(P_empl3b_yrin)

drop P_empl3b_yrin

label variable P_empl3b_t0 "Employment status (3 cat.) at t0"
label values P_empl3b_t0 empl3bl 


gen P_empl2_yrin = P_empl2 if year == YrInP 

bys upid2: egen P_empl2_t0 = max(P_empl2_yrin)

drop P_empl2_yrin

label variable P_empl2_t0 "Employment status (2 cat.) at t0"
label values P_empl2_t0 empl2l  

*** Employment

gen educ3_yrin = educ3 if year == YrInP 
bys upid2: egen educ3_t0 = max(educ3_yrin)
drop educ3_yrin

gen educ2_yrin = educ2 if year == YrInP 
bys upid2: egen educ2_t0 = max(educ2_yrin)
drop educ2_yrin

gen P_educ3_yrin = P_educ3 if year == YrInP 
bys upid2: egen P_educ3_t0 = max(P_educ3_yrin)
drop P_educ3_yrin

gen P_educ2_yrin = P_educ2 if year == YrInP 
bys upid2: egen P_educ2_t0 = max(P_educ2_yrin)
drop P_educ2_yrin


*------------------------------------------------------------------------------ 
**# Sample selection 
*------------------------------------------------------------------------------ 

** on cohabiting couples
drop if fam_type_t0 > 2 // keep only individuals cohabiting at entrance

** on employment characteristics
fre  *pl031_t0
//     6   Pupil, student, further training, unpaid work experience (MT: 6-11=6)
//     7   In retirement or in early retirement or has given up business
//     8   Permanently disabled or/and unfit to work
//     9   In compulsory military community or service

drop if pl031_t0 == 6
drop if pl031_t0 == 7
drop if pl031_t0 == 8
drop if pl031_t0 == 9


drop if P_pl031_t0 == 6
drop if P_pl031_t0 == 7
drop if P_pl031_t0 == 8
drop if P_pl031_t0 == 9

label data "First and second parities – controls – Only partnered women 20 to 45 y. o."
compress
save  "cleaned/P12_ctrl.dta", replace


	
*------------------------------------------------------------------------------ 
**# Merge childcare use data 
*------------------------------------------------------------------------------ 

use "data/EU_pubUse.dta", clear

rename  NUTSEUSILC nuts_silc
rename  years year
rename usage02_public CCuseNUTS


gen cntry = substr(nuts_silc,1,2)

sum CCuseNUTS

replace CCuseNUTS =. if CCuseNUTS<0


** Generate  Lagged Public used from 1 to 5 years

preserve 

replace year = year + 1
rename CCuseNUTS CCuseNUTS_L1


save "cleaned/EU_pubUse_NUTS_L1.dta", replace

replace year = year + 1
rename CCuseNUTS_L1 CCuseNUTS_L2

save "cleaned/EU_pubUse_NUTS_L2.dta", replace

replace year = year + 1
rename CCuseNUTS_L2 CCuseNUTS_L3

save "cleaned/EU_pubUse_NUTS_L3.dta", replace

replace year = year + 1
rename CCuseNUTS_L3 CCuseNUTS_L4

save "cleaned/EU_pubUse_NUTS_L4.dta", replace

replace year = year + 1
rename CCuseNUTS_L4 CCuseNUTS_L5

save "cleaned/EU_pubUse_NUTS_L5.dta", replace

restore 

merge 1:1 nuts_silc year using "cleaned/EU_pubUse_NUTS_L1.dta"
list if _merge ==1 
list if _merge ==2
drop _merge

merge 1:1 nuts_silc year using "cleaned/EU_pubUse_NUTS_L2.dta"
list if _merge ==1
list if _merge ==2
drop _merge

merge 1:1 nuts_silc year using "cleaned/EU_pubUse_NUTS_L3.dta"
list if _merge ==1
list if _merge ==2
drop _merge

merge 1:1 nuts_silc year using "cleaned/EU_pubUse_NUTS_L4.dta"
list if _merge ==1
list if _merge ==2
drop _merge

merge 1:1 nuts_silc year using "cleaned/EU_pubUse_NUTS_L5.dta"
list if _merge ==1
list if _merge ==2
drop _merge

save "cleaned/EU_pubUse_NUTS_Lagged.dta", replace


*** merge to parities and individual-level controls 

use  "cleaned/P12_ctrl.dta", clear


rename country cntry

merge m:1 nuts_silc year using "cleaned/EU_pubUse_NUTS_Lagged.dta"
tab _merge
tab cntry year if _merge == 3
tab cntry year if _merge == 2
tab cntry year if _merge == 1

rename _merge SILCmergeCCNUTS


merge m:1 cntry year using "cleaned/EU_pubUse_NAT_Lagged.dta"
tab _merge
tab cntry year if _merge == 3
tab cntry year if _merge == 2
tab cntry year if _merge == 1

rename _merge SILCmergeCCNAT

drop if year > 2020
drop if year < 2003

drop if SILCmergeCCNAT == 1
drop if SILCmergeCCNAT == 2


/* dropping the ones that have NUTS-1 equal to NUTS-0 in SILC ?

IE IS HR SK SI NO DK 

They are not missing the nuts level
They are small and hence the whole country is a nuts-1 level
Even if national and sub-national level CC should be the same even after the collapse,
is better to use the national level from macro-data.
In Parities12_1645_CC CCuseNUTS will include the "whole country nuts-1"
In Parities12_1645_CCNUTS only sub-national nuts region will be kept

 */


gen toNAT = 0
replace toNAT = 1 if cntry ==  "IE" | cntry ==  "IS" | cntry ==  "HR"
replace toNAT = 1 if cntry ==  "SK"| cntry ==  "SI" | cntry ==  "NO" | cntry ==  "DK" 


replace CCuseNUTS = CCuseNAT if toNAT == 1 
replace CCuseNUTS_L1 = CCuseNAT_L1 if toNAT == 1 
replace CCuseNUTS_L2 = CCuseNAT_L2 if toNAT == 1 
replace CCuseNUTS_L3 = CCuseNAT_L3 if toNAT == 1 
replace CCuseNUTS_L4 = CCuseNAT_L4 if toNAT == 1 
replace CCuseNUTS_L5 = CCuseNAT_L5 if toNAT == 1 


drop toNAT
bys upid year: gen dupes = _n

tab dupes
tab upid if dupes >1, m 
tab dupes year if upid=="", m 

drop if upid == ""
tab dupes
drop dupes 


drop if SILCmergeCCNUTS == 1
drop if SILCmergeCCNUTS == 2


*** demening


* mean and demean CC on NUTS levels lagged

bys nuts: egen CCuseNUTS_L1_m = mean(CCuseNUTS_L1)

gen CCuseNUTS_L1_dm = CCuseNUTS_L1 - CCuseNUTS_L1_m

sum CCuseNUTS_L1_dm

bys nuts: egen CCuseNUTS_L2_m = mean(CCuseNUTS_L2)

gen CCuseNUTS_L2_dm = CCuseNUTS_L2 - CCuseNUTS_L2_m

sum CCuseNUTS_L2_dm

bys nuts: egen CCuseNUTS_L3_m = mean(CCuseNUTS_L3)

gen CCuseNUTS_L3_dm = CCuseNUTS_L3 - CCuseNUTS_L3_m

sum CCuseNUTS_L3_dm


**# Other data peparation 

*** Country numeric

encode cntry, gen(cntryn)

***# Labelling

lab var P1 "Transition to Parenthood"
lab var P2 "Second Parity Transition"

lab var CCuseNUTS_L2_dm "Demeaned childcare usage in t-2"
lab var CCuseNUTS_L2_m  "Regional average childcare usage"
lab var CCuseNUTS_L2_st  "Regional average childcare usage in 2003"

lab var  married_t0 "Civil status"
lab def  married_t02 0 "Not Married" 1 "Married"
lab val married_t0 married_t02

lab var educ3 "Educational level (3 cat.)"
lab def educ3lab 1 "Lower Secondary" 2 "Upper Secondary" 3 "Tertiary"
lab val educ3 educ3lab


lab var empl2_t0 "Employment status (2 cat.)"
lab def empl2_t0l 1 "Unemployed-Inactive" 2 "Employed" 
lab val empl2_t0 empl2_t0l

lab var age_cat5 "Age (5 year band)"
lab def age_cat5l 0 "20-24" 1 "25-29" 2 "30-34" 3 "35-39" 4 "40-45"
lab val age_cat5 age_cat5l


* sample selection

/*

Longitudinal weights excludes short panels that are not concluded (4-yrs minimum)
Hence, the last incoming rotating panel enters the survey in 2017. 

*/

drop if YrInP > 2017


// Error in Navarra's data. Therefore, exclude. 
drop if nuts_silc == "ES22" // Navarra's data are incorrect



*------------------------------------------------------------------------------ 
**# Saving 
*------------------------------------------------------------------------------ 

compress
save "cleaned/Parities12_2045_CCNUTS.dta", replace


	
	
	