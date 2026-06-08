*------------------------------------------------------------------------------
*******************************************************************************
***								
***		Select and merge 		
***		D H R master files		
***								
***		Giovanni Minchio		
***
***		University of Trento	
***
***		v1.0 - July 5, 2023		
***								
*******************************************************************************
*------------------------------------------------------------------------------


********************************************************************************
**#  Set Working Directory
********************************************************************************


cd "your directory/Early public childcare and fertility"

********************************************************************************


**# Master D

use "data/masterD.dta", clear

rename db040 region

keep year country region uhid urtgrp hid db100 db110 db095 db050 yrelease

label variable uhid "household and rotationgroup IDs that are unique across releases"

compress
save "cleaned/masterD_cl.dta", replace

**# Master H

use "data/masterH.dta", clear

keep year hid country rotation_group uhid urtgrp hy020 hy020_f hy020_i hy022 hy022_f hy022_i hy023 hy023_f hy023_i  hx040 hx090 hx100 hy050n hy050n_f hy050n_i hy025 hy025_f hy080g

label variable uhid "household and rotationgroup IDs that are unique across releases"

compress
save "cleaned/masterH_cl.dta", replace


**# Master R

use "data/masterR.dta", clear

keep country year pop hid pid rotation_group uhid urtgrp upid upidnum rscale rb060s smwrate60 lrb064 lrscale rb064s smwrate64 T rb064 rb070 rb080 rb090 rb100 rb110 rb120 rb140 rb150 rb160 rb170 rb180 rb190 rb200 rb210 rb220 rb220_f rb230 rb230_f rb240 rb240_f rb245 rx010 rx020

label variable uhid "household and rotationgroup IDs that are unique across releases"

label variable rscale "scales for the base weights for individuals in R file"


label variable upid "personal IDs that are unique across releases"

compress 
save "cleaned/masterR_cl.dta", replace



use "cleaned/masterD_cl.dta", clear

merge 1:1 year country uhid using "cleaned/masterH_cl.dta"

gen DmergeH = _merge 
drop _merge


merge 1:m year country uhid using "cleaned/masterR_cl.dta"

gen DHmergeR = _merge 
drop _merge

*** including the proper nuts level for future merging

gen nuts_silc = region

replace nuts_silc = "BE1" if nuts_silc =="BE3"


replace nuts_silc = "BG3" if nuts_silc == "BG31" | nuts_silc == "BG32" | nuts_silc == "BG33" | nuts_silc == "BG34"
replace nuts_silc = "BG4" if nuts_silc == "BG41" | nuts_silc == "BG42"
replace nuts_silc = "" if nuts_silc == "BG01"
replace nuts_silc = "" if nuts_silc == "BG02"
replace nuts_silc = "" if nuts_silc == "BG03"
replace nuts_silc = "" if nuts_silc == "BG04"
replace nuts_silc = "" if nuts_silc == "BG05"
replace nuts_silc = "" if nuts_silc == "BG06"


replace nuts_silc = "UKC" if nuts_silc == "UKC1"
replace nuts_silc = "UKC" if nuts_silc == "UKC2"
replace nuts_silc = "UKD" if nuts_silc == "UKD1"
replace nuts_silc = "UKD" if nuts_silc == "UKD3"
replace nuts_silc = "UKD" if nuts_silc == "UKD4"
replace nuts_silc = "UKD" if nuts_silc == "UKD6"
replace nuts_silc = "UKD" if nuts_silc == "UKD7"
replace nuts_silc = "UKE" if nuts_silc == "UKE1"
replace nuts_silc = "UKE" if nuts_silc == "UKE2"
replace nuts_silc = "UKE" if nuts_silc == "UKE3"
replace nuts_silc = "UKE" if nuts_silc == "UKE4"
replace nuts_silc = "UKF" if nuts_silc == "UKF1"
replace nuts_silc = "UKF" if nuts_silc == "UKF2"
replace nuts_silc = "UKF" if nuts_silc == "UKF3"
replace nuts_silc = "UKG" if nuts_silc == "UKG1"
replace nuts_silc = "UKG" if nuts_silc == "UKG2"
replace nuts_silc = "UKG" if nuts_silc == "UKG3"
replace nuts_silc = "UKH" if nuts_silc == "UKH1"
replace nuts_silc = "UKH" if nuts_silc == "UKH2"
replace nuts_silc = "UKH" if nuts_silc == "UKH3"
replace nuts_silc = "UKI" if nuts_silc == "UKI1"
replace nuts_silc = "UKI" if nuts_silc == "UKI2"
replace nuts_silc = "UKJ" if nuts_silc == "UKJ1"
replace nuts_silc = "UKJ" if nuts_silc == "UKJ2"
replace nuts_silc = "UKJ" if nuts_silc == "UKJ3"
replace nuts_silc = "UKJ" if nuts_silc == "UKJ4"
replace nuts_silc = "UKK" if nuts_silc == "UKK1"
replace nuts_silc = "UKK" if nuts_silc == "UKK2"
replace nuts_silc = "UKK" if nuts_silc == "UKK3"
replace nuts_silc = "UKK" if nuts_silc == "UKK4"
replace nuts_silc = "UKL" if nuts_silc == "UKL1"
replace nuts_silc = "UKL" if nuts_silc == "UKL2"
replace nuts_silc = "UKM" if nuts_silc == "UKM2"
replace nuts_silc = "UKM" if nuts_silc == "UKM3"
replace nuts_silc = "UKM" if nuts_silc == "UKM5"
replace nuts_silc = "UKM" if nuts_silc == "UKM6"
replace nuts_silc = "UKN" if nuts_silc == "UKN0"


replace nuts_silc = "FI1D" if nuts_silc == "FI13"
replace nuts_silc = "FI1D" if nuts_silc == "FI1A"
replace nuts_silc = "FI18" if nuts_silc == "FI1B"
replace nuts_silc = "FI18" if nuts_silc == "FI1C"

replace nuts_silc = "FR1" if nuts_silc =="FR10"
replace nuts_silc = "FR2" if nuts_silc =="FR21"
replace nuts_silc = "FR2" if nuts_silc =="FR22"
replace nuts_silc = "FR2" if nuts_silc =="FR23"
replace nuts_silc = "FR2" if nuts_silc =="FR24"
replace nuts_silc = "FR2" if nuts_silc =="FR25"
replace nuts_silc = "FR2" if nuts_silc =="FR26"
replace nuts_silc = "FR3" if nuts_silc =="FR30"
replace nuts_silc = "FR4" if nuts_silc =="FR41"
replace nuts_silc = "FR4" if nuts_silc =="FR42"
replace nuts_silc = "FR4" if nuts_silc =="FR43"
replace nuts_silc = "FR5" if nuts_silc =="FR51"
replace nuts_silc = "FR5" if nuts_silc =="FR52"
replace nuts_silc = "FR5" if nuts_silc =="FR53"
replace nuts_silc = "FR6" if nuts_silc =="FR61"
replace nuts_silc = "FR6" if nuts_silc =="FR62"
replace nuts_silc = "FR6" if nuts_silc =="FR63"
replace nuts_silc = "FR7" if nuts_silc =="FR71"
replace nuts_silc = "FR7" if nuts_silc =="FR72"
replace nuts_silc = "FR8" if nuts_silc =="FR81"
replace nuts_silc = "FR8" if nuts_silc =="FR82"
replace nuts_silc = "FR8" if nuts_silc =="FR83"
replace nuts_silc = "FR2" if nuts_silc =="FRB0"
replace nuts_silc = "FR2" if nuts_silc =="FRC1"
replace nuts_silc = "FR4" if nuts_silc =="FRC2"
replace nuts_silc = "FR2" if nuts_silc =="FRD1"
replace nuts_silc = "FR2" if nuts_silc =="FRD2"
replace nuts_silc = "FR3" if nuts_silc =="FRE1"
replace nuts_silc = "FR2" if nuts_silc =="FRE2"
replace nuts_silc = "FR4" if nuts_silc =="FRF1"
replace nuts_silc = "FR2" if nuts_silc =="FRF2"
replace nuts_silc = "FR4" if nuts_silc =="FRF3"
replace nuts_silc = "FR5" if nuts_silc =="FRG0"
replace nuts_silc = "FR5" if nuts_silc =="FRH0"
replace nuts_silc = "FR6" if nuts_silc =="FRI1"
replace nuts_silc = "FR6" if nuts_silc =="FRI2"
replace nuts_silc = "FR5" if nuts_silc =="FRI3"
replace nuts_silc = "FR8" if nuts_silc =="FRJ1"
replace nuts_silc = "FR6" if nuts_silc =="FRJ2"
replace nuts_silc = "FR7" if nuts_silc =="FRK1"
replace nuts_silc = "FR7" if nuts_silc =="FRK2"
replace nuts_silc = "FR8" if nuts_silc =="FRL0"
replace nuts_silc = "FR8" if nuts_silc =="FRM0"


replace nuts_silc = "ITD" if nuts_silc=="ITH"
replace nuts_silc = "ITE" if nuts_silc=="ITI"

replace nuts_silc = "RO1" if nuts_silc=="RO11"
replace nuts_silc = "RO1" if nuts_silc=="RO12"
replace nuts_silc = "RO2" if nuts_silc=="RO21"
replace nuts_silc = "RO2" if nuts_silc=="RO22"
replace nuts_silc = "RO3" if nuts_silc=="RO31"
replace nuts_silc = "RO3" if nuts_silc=="RO32"
replace nuts_silc = "RO4" if nuts_silc=="RO41"
replace nuts_silc = "RO4" if nuts_silc=="RO42"

replace nuts_silc = "PLN" if nuts_silc=="PL1" | nuts_silc=="PL3" | nuts_silc=="PL7" | nuts_silc=="PL8" ///
				| nuts_silc=="PL9"
				
replace nuts_silc = "" if region == "SE0"

replace nuts_silc = "EL5" if region == "EL1"
replace nuts_silc = "EL6" if region == "EL2"

replace nuts_silc = "CH0" if region == "CH01"
replace nuts_silc = "CH0" if region == "CH02"
replace nuts_silc = "CH0" if region == "CH03"
replace nuts_silc = "CH0" if region == "CH04"
replace nuts_silc = "CH0" if region == "CH05"
replace nuts_silc = "CH0" if region == "CH06"
replace nuts_silc = "CH0" if region == "CH07"

replace nuts_silc = "SI0" if nuts_silc=="" & country =="SI"

replace nuts_silc = "PT" if country =="PT"


**# Saving

label data "Merged D H R masters 2020" 

compress
save "cleaned/Master_DHR.dta", replace 

