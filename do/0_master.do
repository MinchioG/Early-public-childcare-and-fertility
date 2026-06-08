*------------------------------------------------------------------------------
*******************************************************************************
***
***		Early public childcare and fertility						
***										
***		Master do-file 					
***										
***		Giovanni Minchio 					
***								
***		University of Trento	
***								
***		v1.0 - June 1, 2025		
***								
*------------------------------------------------------------------------------
*******************************************************************************

********************************************************************************
**#  Set Working Directory
********************************************************************************


cd "your directory/Early public childcare and fertility"

********************************************************************************
**# do-files
********************************************************************************

/*

This code was developed using:

Stata/SE 18.0 for Mac (Intel 64-bit)
Revision 14 Feb 2024
Copyright 1985-2023 StataCorp LLC

Workstation configuration:

MacBook Pro (Retina, 15-inch, Late 2013)
macOS 11.7.10
2.7 GHz Intel Core i7 quad-core
16 GB 1600 MHz DDR3
Intel Iris Pro 1536 MB

Subfolders needed:

"your directory/Early public childcare and fertility"
		|
		|--- "do" 		--->	Replication do-files uploaded with the repository
		|		
		|--- "data" 	---> 	original EU-SILC master files
		|
		|--- "cleaned"  --->	stores the cleaned datasets used for merge 
		|
		|--- "results"
				|
				|--- "tables"
				|
				|--- "graphs"
				|		|
				|		|--- "exports"
				|
				|--- "estimates"

				
				
The data used are the cleaned datasets resulting from the eusilcpanel.ado 
provided by GESIS (https://www.gesis.org/en/missy/materials/EU-SILC).


*/


do "do/1_mergeHDR.do" 				// Merge master files

do "do/2_parity_transitions.do"		// generate parity transitions in EU-SILC

do "do/3_controls.do"				// add individual-level controls and nuts-level ECEC usage
		
do "do/4_results.do"				

do "do/Z_erase.do"					// erase datafiles

exit


