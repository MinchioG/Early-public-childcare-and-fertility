*------------------------------------------------------------------------------
*******************************************************************************
*
* Results
*
* Giovanni Minchio
*
* University of Trento
*
* 18.04.2024
*
*******************************************************************************
*------------------------------------------------------------------------------

* Graph Settings

grstyle clear

set scheme plotplainblind

   grstyle init
    grstyle set plain, grid dotted

	
*-------------------------------------------------------------------------------
**# Set globals
*-------------------------------------------------------------------------------
global GRAPHS "results/graphs"
global GRAPHSP "results/graphs/exports"
global TBLS "results/tables"
global EST "results/estimates"


use  "cleaned/Parities12_2045_CCNUTS.dta", clear


*-------------------------------------------------------------------------------
**# M1: Full model without interactions
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
**##  First order births
*-------------------------------------------------------------------------------

qui cloglog P1 c.CCuseNUTS_L2_dm i.age_cat5 i.married_t0 i.educ3 i.empl2_t0 /// 
ib2010.YrInP i.nuts [pweight=rb064s], cluster(upid2) eform
est store M1_P1_L2dmHRall

qui margins, dydx(CCuseNUTS_L2_dm) vce(unconditional) saving($EST/M1_P1_L2dm_AME.dta, replace) post
// Graphs of the average marginal effects (AME) are done using R and the exported estimates

est restore M1_P1_L2dmHRall
margins, at(CCuseNUTS_L2_dm=(-10(2)10)) vce(unconditional) saving($EST/M1_P1_L2dm_cloglogPr, replace)

marginsplot, saving($GRAPHS/M1_P1_L2dm_cloglog2, replace) /// 
ytitle("P(transition to parenthood)", size(small)) scheme(plotplainblind) ///
xtitle("Demeaned childcare usage in t-2", size(small)) ///
xlabel(-10(2)10) title("") ylabel(0(.025).2) xsize(6) ysize(9)
graph export "$GRAPHSP/M1_P1_L2dm_cloglog2.eps", as(eps) replace
graph export "$GRAPHSP/M1_P1_L2dm_cloglog2.svg", replace
graph export "$GRAPHSP/M1_P1_L2dm_cloglog2.eps", as(eps) replace

*-------------------------------------------------------------------------------
**##  Second order births
*-------------------------------------------------------------------------------

qui cloglog P2 c.CCuseNUTS_L2_dm  i.age_cat5 i.married_t0 i.educ3 i.empl2_t0 /// 
ib2010.YrInP i.nuts [pweight=rb064s], cluster(upid2) eform
est store M1_P2_L2dmHRall

qui margins, dydx(CCuseNUTS_L2_dm) vce(unconditional) saving($EST/M1_P2_L2dm_AME.dta, replace) post

est restore M1_P2_L2dmHRall
margins, at(CCuseNUTS_L2_dm=(-10(2)10)) vce(unconditional) saving($EST/M1_P2_L2dm_cloglogPr, replace)
marginsplot, saving($GRAPHS/M1_P2_L2dm_cloglog2, replace) ///
ytitle("P(second birth transition)", size(small)) scheme(plotplainblind) ///
xtitle("Demeaned childcare usage in t-2", size(small)) ///
xlabel(-10(2)10) title("") ylabel(0(.025).2) xsize(6) ysize(9)
graph export "$GRAPHSP/M1_P2_L2dm_cloglog2.eps", as(eps) replace
graph export "$GRAPHSP/M1_P2_L2dm_cloglog2.svg", replace


*-------------------------------------------------------------------------------
**# M2: CC demened X Education Level + Controls
*-------------------------------------------------------------------------------
 
*-------------------------------------------------------------------------------
**##  First order births
*-------------------------------------------------------------------------------
 
qui cloglog P1 c.CCuseNUTS_L2_dm##i.educ3 i.age_cat5 i.married_t0 /// 
ib2010.YrInP i.nuts [pweight=rb064s] if MISS==0, cluster(upid2) eform
est store M2_P1_L2dmXedu3

margins, dydx(CCuseNUTS_L2_dm) at(educ3=(1(1)3)) vce(unconditional) /// 
saving($EST/M2_P1_L2dmXedu3_cloglogAME.dta, replace) post
// Graphs of the average marginal effects (AME) are done using R 


est restore M2_P1_L2dmXedu3
margins, at(CCuseNUTS_L2_dm=(-10(2)10) educ3=(1(1)3)) vce(unconditional) /// 
saving($EST/M2_P1_L2dmXedu3_cloglogPr, replace) post
est store margM2_P1_L2dmXedu3


*-------------------------------------------------------------------------------
**##  Second order births
*-------------------------------------------------------------------------------

qui cloglog P2 c.CCuseNUTS_L2_dm##i.educ3 i.age_cat5 i.married_t0  /// 
ib2010.YrInP i.nuts [pweight=rb064s] if MISS==0, cluster(upid2) eform 
est store M2_P2_L2dmXedu3

// est restore M2_P2_L2dmXedu3

lincom CCuseNUTS_L2_dm, eform
 
lincom CCuseNUTS_L2_dm + 2.educ3#c.CCuseNUTS_L2_dm, eform

lincom CCuseNUTS_L2_dm + 3.educ3#c.CCuseNUTS_L2_dm, eform

est restore M2_P2_L2dmXedu3

   margins, expression(_b[CCuseNUTS_L2_dm]) post
    est store M2_P2_L2dmXedu3_1

forval i=2/3{
    est restore M2_P2_L2dmXedu3
    margins, expression(_b[CCuseNUTS_L2_dm]+ _b[`i'.educ3#c.CCuseNUTS_L2_dm]) post
    est store M2_P2_L2dmXedu3_`i'
}

est restore M2_P2_L2dmXedu3
margins, dydx(CCuseNUTS_L2_dm) at(educ3=(1(1)3))  vce(unconditional) /// 
saving($EST/M2_P2_L2dmXedu3_cloglogAME.dta, replace) post
// Graphs of the average marginal effects (AME) are done using R 


est restore M2_P2_L2dmXedu3
margins, at(CCuseNUTS_L2_dm=(-10(2)10) educ3=(1(1)3)) vce(unconditional) saving($EST/M2_P2_L2dmXedu3_cloglogPr, replace) post
est store margM2_P2_L2dmXedu3pr

est restore margM2_P2_L2dmXedu3pr
marginsplot ,  saving($GRAPHS/M2_P2_L2dmXedu3_cloglogPr, replace) ///
 ytitle("Second birth transition rates", size(*0.9)) ciopt(color(%60))  title("") /// 
 legend(off) ///
 xlabel(-10(2)10) xtitle("Demeaned ECEC in t-2", size(*.85)) ///
 ylabel(0(.025).2) fxsize(50)

lincom 10*(CCuseNUTS_L2_dm + 2.educ3#c.CCuseNUTS_L2_dm), eform

*-------------------------------------------------------------------------------
**# M3: CC demened X Employment Status + Controls
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
**##  First order births
*-------------------------------------------------------------------------------

qui cloglog P1 c.CCuseNUTS_L2_dm##i.empl2_t0 i.age_cat5 i.married_t0 i.educ3  /// 
ib2010.YrInP i.nuts [pweight=rb064s], cluster(upid2) eform coefl
est store M3_P1_L2dmXempl2

margins, expression(_b[CCuseNUTS_L2_dm]) vce(unconditional) post
    est store M3_P1_L2dmXempl2_1

    est restore M3_P1_L2dmXempl2
margins, expression(_b[CCuseNUTS_L2_dm]+ _b[2.empl2_t0#c.CCuseNUTS_L2_dm]) vce(unconditional) post
    est store M3_P1_L2dmXempl2_2
	
est restore M3_P1_L2dmXempl2
margins, dydx(CCuseNUTS_L2_dm) at(empl2_t0=(1(1)2))  vce(unconditional) /// 
saving($EST/M3_P1_L2dmXempl2_cloglogAME.dta, replace) post
est store M3_P1_L2dmXempl2AME

est restore M3_P1_L2dmXempl2
margins, at(CCuseNUTS_L2_dm=(-10(2)10) empl2_t0=(1 2)) vce(unconditional) saving($EST/M3_P1_L2dmXempl2_cloglogPr, replace) post

marginsplot ,  saving($GRAPHS/M3_P1_L2dmXempl2_cloglogPr, replace) ///
 ytitle("") ciopt(color(%60))  title("") /// 
 legend(title("By employment status:", size(*0.9)) ///
           pos(11) ring(0) col(1) ///
           region(lcolor(none) fcolor(white)) ///
           symxsize(0))  ///
 xlabel(-10(2)10) xtitle("") ///
  ylabel(0(.025).2) xsize(7) ysize(9) fysize(46)
 
  
*-------------------------------------------------------------------------------
**##  Second order births
*-------------------------------------------------------------------------------

qui cloglog P2 c.CCuseNUTS_L2_dm##i.empl2_t0 i.age_cat5 i.married_t0 i.educ3  /// 
ib2010.YrInP i.nuts [pweight=rb064s] if MISS==0, cluster(upid2) eform coefl
est store M3_P2_L2dmXempl2

margins, expression(_b[CCuseNUTS_L2_dm]) vce(unconditional) post
    est store M3_P2_L2dmXempl2_1
    est restore M3_P2_L2dmXempl2
margins, expression(_b[CCuseNUTS_L2_dm]+ _b[2.empl2_t0#c.CCuseNUTS_L2_dm]) vce(unconditional) post
    est store M3_P2_L2dmXempl2_2

est restore M3_P2_L2dmXempl2 
margins, dydx(CCuseNUTS_L2_dm) at(empl2_t0=(1(1)2))  vce(unconditional) /// 
saving($EST/M3_P2_L2dmXempl2_cloglogAME.dta, replace) post
est store M3_P2_L2dmXempl2AME

est restore M3_P2_L2dmXempl2
margins, at(CCuseNUTS_L2_dm=(-10(2)10) empl2_t0=(1 2)) vce(unconditional) saving($EST/M3_P2_L2dmXempl2_cloglogPr, replace) post

marginsplot ,  saving($GRAPHS/M3_P2_L2dmXempl2_cloglogPr, replace) ///
 ytitle("") ciopt(color(%60))  title("") /// 
 legend(off) ///
 xlabel(-10(2)10) xtitle("Demeaned ECEC in t-2", size(*.85)) ///
 ylabel(0(.025).2) xsize(7) ysize(9) fxsize(45) fysize(50)


*-------------------------------------------------------------------------------
**# M4: CC demened by region Avg. X with region Avg. squared (level effect)
*-------------------------------------------------------------------------------

sum CCuseNUTS_L2_m

*-------------------------------------------------------------------------------
**##  First order births
*-------------------------------------------------------------------------------

cloglog P1 c.CCuseNUTS_L2_dm##c.CCuseNUTS_L2_m##c.CCuseNUTS_L2_m i.age_cat5 /// 
i.married_t0 i.educ3 i.empl2_t0 ib2010.YrInP i.cntryn [pweight=rb064s], cluster(upid2) eform
est store M4_P1_L2dmXsq 

est restore M4_P1_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=(2(1)68))  vce(unconditional) post
est store margM4_P1_L2dmXsq 

est restore margM4_P1_L2dmXsq 
marginsplot, ytitle("AME - First birth transition")  ///
xlabel(,ang(0) nogrid) xtitle("") ///
plot1opts(mcolor(navy) lcolor(navy%50)) title("") xlabel(0(5)70) ///
ciopt(color(red%50)) yline(0, lwidth(vthin) lcolor(black)) ///
 saving($GRAPHS/M4_P1_L2dmXsq_cloglogAME, replace) ///
 ylabel(-0.005(.0025)0.0125)  xsize(11) ysize(11) fysize(46)

graph export "$GRAPHSP/M4_P1_L2dmXsqr_cloglogAME.eps", as(eps) replace  logo(off) 
graph export "$GRAPHSP/M4_P1_L2dmXsqr_cloglogAME.pdf", width(4.33) height(4.33) replace 
graph export "$GRAPHSP/M4_P1_L2dmXsqr_cloglogAME.svg", replace 


est restore M4_P1_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=22) vce(unconditional) post
est restore M4_P1_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=23) vce(unconditional) post
 
*-------------------------------------------------------------------------------
**##  Second order births
*-------------------------------------------------------------------------------

cloglog P2 c.CCuseNUTS_L2_dm##c.CCuseNUTS_L2_m##c.CCuseNUTS_L2_m i.age_cat5 ///
 i.married_t0 i.educ3 i.empl2_t0 ib2010.YrInP i.cntryn [pweight=rb064s], cluster(upid2) eform
est store M4_P2_L2dmXsq 

est restore M4_P2_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=(2(1)68))  vce(unconditional) post
est store margM4_P2_L2dmXsq 

est restore margM4_P2_L2dmXsq 
marginsplot, title("") ytitle("AME - Second birth transition") ///
xlabel(,ang(0) nogrid) xtitle("Region's Average Childcare Usage (%)", size(*0.9)) ///
plot1opts(mcolor(navy) lcolor(navy%50)) title("") xlabel(0(5)70) ///
ciopt(color(red%50))  yline(0, lwidth(vthin) lcolor(black)) ///
 saving($GRAPHS/M4_P2_L2dmXsq_cloglogAME, replace)  ///
 ylabel(-0.005(.0025)0.0125) xsize(11) ysize(11) fysize(50)

graph export "$GRAPHSP/M4_P2_L2dmXsq_cloglogAME.eps", as(eps)  logo(off)  replace
graph export "$GRAPHSP/M4_P2_L2dmXsqrcloglogAME.svg", replace
graph export "$GRAPHSP/M4_P2_L2dmXsqr_cloglogAME.pdf", width(4.33) height(4.33) replace 



est restore M4_P2_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=28)  vce(unconditional) post

est restore M4_P2_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=29)  vce(unconditional) post

 est restore M4_P2_L2dmXsq 
margins, dydx(CCuseNUTS_L2_dm) at(CCuseNUTS_L2_m=30)  vce(unconditional) post

 
*-------------------------------------------------------------------------------
**# Combine multiple Graphs	
*-------------------------------------------------------------------------------

graph combine $GRAPHS/M2_P1_L2dmXedu3_cloglogPr.gph  $GRAPHS/M3_P1_L2dmXempl2_cloglogPr.gph ///
  $GRAPHS/M2_P2_L2dmXedu3_cloglogPr.gph $GRAPHS/M3_P2_L2dmXempl2_cloglogPr.gph, /// 
  col(2) ycommon xcommon imargin(zero) xsize(4.33) ysize(4.33) // this one final 
graph export "$GRAPHSP/M23_P12.eps", as(eps) replace  logo(off) fontface("Times")
graph export "$GRAPHSP/M23_P12.pdf", width(4.33) height(4.33) replace 
graph export "$GRAPHSP/M23_P12.svg", replace 
 

graph combine $GRAPHS/M4_P1_L2dmXsq_cloglogAME.gph /// 
$GRAPHS/M4_P2_L2dmXsq_cloglogAME.gph , col(1) xsize(4.33) ysize(4.33) imargin(zero)
graph export "$GRAPHSP/M4_P12_L2dmXsq_cloglogAME.eps", as(eps) replace fontface("Times")
graph export "$GRAPHSP/M4_P12_L2dmXsq_cloglogAME.svg", replace
graph export "$GRAPHSP/M4_P12_L2dmXsq_cloglogAME.pdf", width(4.33) height(4.33) replace 
 

 // Graphs of the average marginal effects (AME in Fig. 2) are generated using R.  

*-------------------------------------------------------------------------------
**# Tables of coefficients
*-------------------------------------------------------------------------------

esttab M1_P1_L2dmHRall M3_P1_L2dmXedu3 M3_P1_L2dmXempl2 M2_P1_L2dmXsq ///
	using $TBLS/Mall_P1_L2dmHRall.rtf, ci star(* 0.10 ** 0.05 *** 0.01) /// 
	replace compress eform label sca(N_clust)
	
	
esttab M1_P2_L2dmHRall M3_P2_L2dmXedu3 M3_P2_L2dmXempl2 M2_P2_L2dmXsq ///
	using $TBLS/Mall_P2_L2dmHRall.rtf, ci star(* 0.10 ** 0.05 *** 0.01) /// 
	replace compress eform label sca(N_clust)

