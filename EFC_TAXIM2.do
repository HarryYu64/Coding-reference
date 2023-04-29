/*First I'm writing out what variables are needed to calculate EFC in the 2011 PSID (which is the survey result of year 2010 with 5255 obs and 8907 vars*/
/*"LABOR INCOME-HEAD" ER52237
"LABOR INCOME-WIFE" ER52249
Total from FAFSA Worksheet A: 	AMT CHILD SUPPORT OF HD(ER48532)+CHILD SUPPORT OF WF AMT(ER48751)+	ADC/TANF OF HEAD(ER48382)+ADC/TANF OF WIFE AMT(ER48735)+AMT WORKMEN COMP OF HEAD(ER48516)+ 	WORKERS COMP OF WIFE(ER48635)+	VA PENSION OF HEAD AMT(ER48435)
Total from FAFSA Worksheet B: Not available (the only relevant is child support paid but this does not meet the standard in the Worksheet B)
Number of children in college:		"# IN FU"ER47316(2011) minus parents (1 or 2 determined by ER47323 HEAD MARITAL STATUS) minus	# CHILDREN IN FU (under 18)ER47320
W28 AMT ALL ACCOUNTS ER48911
WORTH OF OTR REAL ESTATE ER48869
W11 PROFIT IF SOLD BUSINESS/FARM ER48878
PSID STATE OF RESIDENCE CODE ER47303
IMPORTANT: {SAVINGS, PROFIT IF SOLD OTR REAL ESTATE, PROFIT IF SOLD BUSINESS/FARM} NOT FOUND (NOT AVAILABLE) IN PSID 1997

Update of 1/4/2023 meeting: Collegestu would be set to 1 for all families.
Solution on unavailable 1997 equity amount in PSID database is to use the 1994 equity and translated using the inflation rate from 1995 to 1997 (multiplied together gives approximately 1.082) in place of the unavailable 1997 equity (savings and investment)
*/
*2013
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2013.dta",replace

*Now from the beginning
replace ER54113=0 if ER54113>999997
replace ER54329=0 if ER54329>999997
replace ER54060=0 if ER54060>999997
replace ER54430=0 if ER54430>999997
replace ER54210=0 if ER54210>999997
replace ER54226=0 if ER54226>999997
replace ER54446=0 if ER54446>999997
gen EFC_2=ER58038+ER58050
gen EFC_4=ER54113+ER54329+ER54060+ER54430+ER54210+ER54226+ER54446+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER53003 state_code
gen age=ER53017 if ER53017>=ER53019 &ER53017!=999&ER53019!=999
label variable age "Age of older parent"
replace age=ER53019 if ER53017<ER53019&ER53017!=999&ER53019!=999
replace age=ER53017 if ER53019==999|ER53019==0
replace age=ER53019 if ER53017==999|ER53017==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER53003
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2013A5_0 if ER53023==1
replace EFC_23=EFC2013A5_1 if ER53023!=1
gen EFC_9=EFC_7*EFC2013A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2013A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER58038 if ER58038<=110100 
replace EFC_10=8422.65+0.0145*ER58038 if ER58038>110100  
gen EFC_11=0.0765*ER58050 if ER58050<=110100  
replace EFC_11=8422.65+0.0145*ER58050 if ER58050>110100 
*EFC Form A3 "# IN FU" ER53016 Number in parents household, including  student
/*gen Collegestu=ER53016-2-ER53020 if ER53023==1
replace Collegestu=ER53016-1-ER53020 if ER53023!=1*/
gen Collegestu=1
gen EFC_12=11810+4100*ER53016-2910*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER58038>=ER58050 &ER58050!=0&ER58038!=0
replace dummy_head=0 if ER58038<ER58050 &ER58050!=0&ER58038!=0
replace dummy_head=2 if ER58038==0
replace dummy_head=3 if ER58050==0
gen EFC_13=0.35*ER58050 if dummy_head==1
replace EFC_13=0.35*ER58038 if dummy_head==0
replace EFC_13=0.35*ER58050 if dummy_head==2
replace EFC_13=0.35*ER58038 if dummy_head==3
replace EFC_13=3900 if EFC_13>3900
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER54661=0 if ER54661>999999997
replace ER54612=0 if ER54612>999999997
replace ER54625=0 if ER54625>999999997
gen EFC_16=ER54661
gen EFC_17=ER54612
gen EFC_20=ER54625
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=120000
replace EFC_21=48000+0.5*(EFC_20-120000) if EFC_20>120000&EFC_20<=365000
replace EFC_21=170500+0.6*(EFC_20-365000) if EFC_20>365000&EFC_20<=610000
replace EFC_21=317500+(EFC_20-610000) if EFC_20>610000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER53017, AGE OF WIFE ER53019, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=15300
replace EFC_28=3366+0.25*(EFC_27-15300) if EFC_27>=15301&EFC_27<=19200
replace EFC_28=4341+0.29*(EFC_27-19200) if EFC_27>=19201&EFC_27<=23100
replace EFC_28=5472+0.34*(EFC_27-23100) if EFC_27>=23101&EFC_27<=27000
replace EFC_28=6798+0.40*(EFC_27-27000) if EFC_27>=27001&EFC_27<=30900
replace EFC_28=8358+0.47*(EFC_27-30900) if EFC_27>=30901
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2013.dta", replace




*2011
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2011.dta",replace

*Now from the beginning
replace ER48435=0 if ER48435>999997
replace ER48635=0 if ER48635>999997
replace ER48382=0 if ER48382>999997
replace ER48735=0 if ER48735>999997
replace ER48516=0 if ER48516>999997
replace ER48532=0 if ER48532>999997
replace ER48751=0 if ER48751>999997
gen EFC_2=ER52237+ER52249
gen EFC_4=ER48435+ER48635+ER48382+ER48735+ER48516+ER48532+ER48751+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER47303 state_code
gen age=ER47317 if ER47317>=ER47319 &ER47317!=999&ER47319!=999
label variable age "Age of older parent"
replace age=ER47319 if ER47317<ER47319&ER47317!=999&ER47319!=999
replace age=ER47317 if ER47319==999|ER47319==0
replace age=ER47319 if ER47317==999|ER47317==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER47303
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2011A5_0 if ER47323==1
replace EFC_23=EFC2011A5_1 if ER47323!=1
gen EFC_9=EFC_7*EFC2011A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2011A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER52237 if ER52237<=106800 
replace EFC_10=8170.2+0.0145*ER52237 if ER52237>106800 
gen EFC_11=0.0765*ER52249 if ER52249<=106800 
replace EFC_11=8170.2+0.0145*ER52249 if ER52249>106800
*EFC Form A3 "# IN FU" ER47316 Number in parents household, including  student
/*gen Collegestu=ER47316-2-ER47320 if ER47323==1
replace Collegestu=ER47316-1-ER47320 if ER47323!=1*/
gen Collegestu=1
gen EFC_12=11210+3890*ER47316-2760*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER52237>=ER52249 &ER52249!=0&ER52237!=0
replace dummy_head=0 if ER52237<ER52249 &ER52249!=0&ER52237!=0
replace dummy_head=2 if ER52237==0
replace dummy_head=3 if ER52249==0
gen EFC_13=0.35*ER52249 if dummy_head==1
replace EFC_13=0.35*ER52237 if dummy_head==0
replace EFC_13=0.35*ER52249 if dummy_head==2
replace EFC_13=0.35*ER52237 if dummy_head==3
replace EFC_13=3500 if EFC_13>3500
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER48911=0 if ER48911>999999997
replace ER48869=0 if ER48869>999999997
replace ER48878=0 if ER48878>999999997
gen EFC_16=ER48911
gen EFC_17=ER48869
gen EFC_20=ER48878
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=115000
replace EFC_21=46000+0.5*(EFC_20-115000) if EFC_20>115000&EFC_20<=345000
replace EFC_21=161000+0.6*(EFC_20-345000) if EFC_20>345000&EFC_20<=580000
replace EFC_21=302000+(EFC_20-580000) if EFC_20>580000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=14500
replace EFC_28=3190+0.25*(EFC_27-14500) if EFC_27>=14501&EFC_27<=18200
replace EFC_28=4115+0.29*(EFC_27-18200) if EFC_27>=18201&EFC_27<=21900
replace EFC_28=5188+0.34*(EFC_27-21900) if EFC_27>=21901&EFC_27<=25600
replace EFC_28=6446+0.40*(EFC_27-25600) if EFC_27>=25601&EFC_27<=29300
replace EFC_28=7926+0.47*(EFC_27-29300) if EFC_27>=29301
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2011.dta", replace

*2009
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2009.dta",replace

*Now from the beginning
replace ER43110=0 if ER43110>999997
replace ER43310=0 if ER43310>999997
replace ER43060=0 if ER43060>999997
replace ER43410=0 if ER43410>999997
replace ER43191=0 if ER43191>999997
replace ER43207=0 if ER43207>999997
replace ER43426=0 if ER43426>999997
gen EFC_2=ER46829+ER46841
gen EFC_4=ER43110+ER43310+ER43060+ER43410+ER43191+ER43207+ER43426+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER42003 state_code
gen age=ER42017 if ER42017>=ER42019 &ER42017!=999&ER42019!=999
label variable age "Age of older parent"
replace age=ER42019 if ER42017<ER42019&ER42017!=999&ER42019!=999
replace age=ER42017 if ER42019==999|ER42019==0
replace age=ER42019 if ER42017==999|ER42017==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER42003
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2009A5_0 if ER42023==1
replace EFC_23=EFC2009A5_1 if ER42023!=1
gen EFC_9=EFC_7*EFC2009A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2009A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER46829 if ER46829<=102000 
replace EFC_10=7803+0.0145*ER46829 if ER46829>102000  
gen EFC_11=0.0765*ER46841 if ER46841<=102000  
replace EFC_11=7803+0.0145*ER46841 if ER46841>102000 
*EFC Form A3 "# IN FU" ER42016 Number in parents household, including  student
/*gen Collegestu=ER42016-2-ER42020 if ER42023==1
replace Collegestu=ER42016-1-ER42020 if ER42023!=1*/
gen Collegestu=1
gen EFC_12=10940+3800*ER42016-2700*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER46829>=ER46841 &ER46841!=0&ER46829!=0
replace dummy_head=0 if ER46829<ER46841 &ER46841!=0&ER46829!=0
replace dummy_head=2 if ER46829==0
replace dummy_head=3 if ER46841==0
gen EFC_13=0.35*ER46841 if dummy_head==1
replace EFC_13=0.35*ER46829 if dummy_head==0
replace EFC_13=0.35*ER46841 if dummy_head==2
replace EFC_13=0.35*ER46829 if dummy_head==3
replace EFC_13=3500 if EFC_13>3500
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER43586=0 if ER43586>999999997
replace ER43544=0 if ER43544>999999997
replace ER43553=0 if ER43553>999999997
gen EFC_16=ER43586
gen EFC_17=ER43544
gen EFC_20=ER43553
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=115000
replace EFC_21=46000+0.5*(EFC_20-115000) if EFC_20>115000&EFC_20<=340000
replace EFC_21=158500+0.6*(EFC_20-340000) if EFC_20>340000&EFC_20<=565000
replace EFC_21=293500+(EFC_20-565000) if EFC_20>565000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=14200
replace EFC_28=3124+0.25*(EFC_27-14200) if EFC_27>=14201&EFC_27<=17800
replace EFC_28=4024+0.29*(EFC_27-17800) if EFC_27>=17801&EFC_27<=21400
replace EFC_28=5068+0.34*(EFC_27-21400) if EFC_27>=21401&EFC_27<=25000
replace EFC_28=6292+0.40*(EFC_27-25000) if EFC_27>=25001&EFC_27<=28600
replace EFC_28=7732+0.47*(EFC_27-28600) if EFC_27>=28601
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2009.dta", replace




*2007
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2007.dta",replace

*Now from the beginning
replace ER37119=0 if ER37119>999997
replace ER37319=0 if ER37319>999997
replace ER37069=0 if ER37069>999997
replace ER37200=0 if ER37200>999997
replace ER37216=0 if ER37216>999997
replace ER37419=0 if ER37419>999997
replace ER37435=0 if ER37435>999997
gen EFC_2=ER40921+ER40933
gen EFC_4=ER37119+ER37319+ER37069+ER37419+ER37200+ER37216+ER37435+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER36003 state_code
gen age=ER36017 if ER36017>=ER36019 &ER36017!=999&ER36019!=999
label variable age "Age of older parent"
replace age=ER36019 if ER36017<ER36019&ER36017!=999&ER36019!=999
replace age=ER36017 if ER36019==999|ER36019==0
replace age=ER36019 if ER36017==999|ER36017==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER36003
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2007A5_0 if ER36023==1
replace EFC_23=EFC2007A5_1 if ER36023!=1
gen EFC_9=EFC_7*EFC2007A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2007A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER40921 if ER40921<=94200 
replace EFC_10=7206.3+0.0145*ER40921 if ER40921>94200
gen EFC_11=0.0765*ER40933 if ER40933<=94200
replace EFC_11=7206.3+0.0145*ER40933 if ER40933>94200
*EFC Form A3 "# IN FU" ER36016 Number in parents household, including  student
/*gen Collegestu=ER36016-2-ER36020 if ER36023==1
replace Collegestu=ER36016-1-ER36020 if ER36023!=1*/
gen Collegestu=1
gen EFC_12=10370+3590*ER36016-2550*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER40921>=ER40933 &ER40933!=0&ER40921!=0
replace dummy_head=0 if ER40921<ER40933 &ER40933!=0&ER40921!=0
replace dummy_head=2 if ER40921==0
replace dummy_head=3 if ER40933==0
gen EFC_13=0.35*ER40933 if dummy_head==1
replace EFC_13=0.35*ER40921 if dummy_head==0
replace EFC_13=0.35*ER40933 if dummy_head==2
replace EFC_13=0.35*ER40921 if dummy_head==3
replace EFC_13=3200 if EFC_13>3200
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER37595=0 if ER37595>999999997
replace ER37553=0 if ER37553>999999997
replace ER37562=0 if ER37562>999999997
gen EFC_16=ER37595
gen EFC_17=ER37553
gen EFC_20=ER37562
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=105000
replace EFC_21=42000+0.5*(EFC_20-105000) if EFC_20>105000&EFC_20<=320000
replace EFC_21=149500+0.6*(EFC_20-320000) if EFC_20>320000&EFC_20<=535000
replace EFC_21=278500+(EFC_20-535000) if EFC_20>535000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=13400
replace EFC_28=2948+0.25*(EFC_27-13400) if EFC_27>=13401&EFC_27<=16800
replace EFC_28=3798+0.29*(EFC_27-16800) if EFC_27>=16801&EFC_27<=20200
replace EFC_28=4784+0.34*(EFC_27-20200) if EFC_27>=20201&EFC_27<=23700
replace EFC_28=5974+0.40*(EFC_27-23700) if EFC_27>=23701&EFC_27<=27100
replace EFC_28=7334+0.47*(EFC_27-27100) if EFC_27>=27101
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2007.dta", replace

*2005
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2005.dta",replace

*Now from the beginning
replace ER26101=0 if ER26101>999997
replace ER26301=0 if ER26301>999997
replace ER26051=0 if ER26051>999997
replace ER26401=0 if ER26401>999997
replace ER26182=0 if ER26182>999997
replace ER26198=0 if ER26198>999997
replace ER26417=0 if ER26417>999997
gen EFC_2=ER27931+ER27943
gen EFC_4=ER26101+ER26301+ER26051+ER26401+ER26182+ER26198+ER26417+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER25003 state_code
gen age=ER25017 if ER25017>=ER25019 &ER25017!=999&ER25019!=999
label variable age "Age of older parent"
replace age=ER25019 if ER25017<ER25019&ER25017!=999&ER25019!=999
replace age=ER25017 if ER25019==999|ER25019==0
replace age=ER25019 if ER25017==999|ER25017==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER25003
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2005A5_0 if ER25023==1
replace EFC_23=EFC2005A5_1 if ER25023!=1
gen EFC_9=EFC_7*EFC2005A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2005A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER27931 if ER27931<=87900 
replace EFC_10=6724.35+0.0145*ER27931 if ER27931>87900
gen EFC_11=0.0765*ER27943 if ER27943<=87900 
replace EFC_11=6724.35+0.0145*ER27943 if ER27943>87900
*EFC Form A3 "# IN FU" ER25016 Number in parents household, including  student
/*gen Collegestu=ER25016-2-ER25020 if ER25023==1
replace Collegestu=ER25016-1-ER25020 if ER25023!=1*/
gen Collegestu=1
gen EFC_12=9590+3320*ER25016-2360*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER27931>=ER27943 &ER27943!=0&ER27931!=0
replace dummy_head=0 if ER27931<ER27943 &ER27943!=0&ER27931!=0
replace dummy_head=2 if ER27931==0
replace dummy_head=3 if ER27943==0
gen EFC_13=0.35*ER27943 if dummy_head==1
replace EFC_13=0.35*ER27931 if dummy_head==0
replace EFC_13=0.35*ER27943 if dummy_head==2
replace EFC_13=0.35*ER27931 if dummy_head==3
replace EFC_13=3000 if EFC_13>3000
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER26577=0 if ER26577>999999997
replace ER26535=0 if ER26535>999999997
replace ER26544=0 if ER26544>999999997
gen EFC_16=ER26577
gen EFC_17=ER26535
gen EFC_20=ER26544
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=100000
replace EFC_21=40000+0.5*(EFC_20-100000) if EFC_20>100000&EFC_20<=295000
replace EFC_21=137500+0.6*(EFC_20-295000) if EFC_20>295000&EFC_20<=495000
replace EFC_21=257500+(EFC_20-495000) if EFC_20>495000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=12400
replace EFC_28=2728+0.25*(EFC_27-12400) if EFC_27>=12401&EFC_27<=15600
replace EFC_28=3528+0.29*(EFC_27-15600) if EFC_27>=15601&EFC_27<=18700
replace EFC_28=4427+0.34*(EFC_27-18700) if EFC_27>=18701&EFC_27<=21900
replace EFC_28=5515+0.40*(EFC_27-21900) if EFC_27>=21901&EFC_27<=25000
replace EFC_28=6755+0.47*(EFC_27-25000) if EFC_27>=25001
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2005.dta", replace




*2003
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2003.dta",replace

*Now from the beginning
replace ER22120=0 if ER22120>999997
replace ER22320=0 if ER22320>999997
replace ER22070=0 if ER22070>999997
replace ER22420=0 if ER22420>999997
replace ER22201=0 if ER22201>999997
replace ER22217=0 if ER22217>999997
replace ER22436=0 if ER22436>999997
gen EFC_2=ER24116+ER24135
gen EFC_4=ER22120+ER22320+ER22070+ER22420+ER22201+ER22217+ER22436+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER21003 state_code
gen age=ER21017 if ER21017>=ER21019 &ER21017!=999&ER21019!=999
label variable age "Age of older parent"
replace age=ER21019 if ER21017<ER21019&ER21017!=999&ER21019!=999
replace age=ER21017 if ER21019==999|ER21019==0
replace age=ER21019 if ER21017==999|ER21017==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER21003
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2003A5_0 if ER21023==1
replace EFC_23=EFC2003A5_1 if ER21023!=1
gen EFC_9=EFC_7*EFC2003A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2003A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER24116 if ER24116<=84900
replace EFC_10=6494.85+0.0145*ER24116 if ER24116>84900
gen EFC_11=0.0765*ER24135 if ER24135<=84900
replace EFC_11=6494.85+0.0145*ER24135 if ER24135>84900
*EFC Form A3 "# IN FU" ER21016 Number in parents household, including  student
/*
gen Collegestu=ER21016-2-ER21020 if ER21023==1
replace Collegestu=ER21016-1-ER21020 if ER21023!=1*/
gen Collegestu=1
gen EFC_12=9300+3230*ER21016-2290*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER24116>=ER24135 &ER24135!=0&ER24116!=0
replace dummy_head=0 if ER24116<ER24135 &ER24135!=0&ER24116!=0
replace dummy_head=2 if ER24116==0
replace dummy_head=3 if ER24135==0
gen EFC_13=0.35*ER24135 if dummy_head==1
replace EFC_13=0.35*ER24116 if dummy_head==0
replace EFC_13=0.35*ER24135 if dummy_head==2
replace EFC_13=0.35*ER24116 if dummy_head==3
replace EFC_13=3000 if EFC_13>3000
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER22596=0 if ER22596>999999997
replace ER22554=0 if ER22554>999999997
replace ER22563=0 if ER22563>999999997
gen EFC_16=ER22596
gen EFC_17=ER22554
gen EFC_20=ER22563
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=95000
replace EFC_21=38000+0.5*(EFC_20-95000) if EFC_20>95000&EFC_20<=290000
replace EFC_21=135500+0.6*(EFC_20-290000) if EFC_20>290000&EFC_20<=480000
replace EFC_21=249500+(EFC_20-480000) if EFC_20>480000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=12000
replace EFC_28=2640+0.25*(EFC_27-12000) if EFC_27>=12001&EFC_27<=15100
replace EFC_28=3415+0.29*(EFC_27-15100) if EFC_27>=15101&EFC_27<=18200
replace EFC_28=4314+0.34*(EFC_27-18200) if EFC_27>=18201&EFC_27<=21200
replace EFC_28=5334+0.40*(EFC_27-21200) if EFC_27>=21201&EFC_27<=24300
replace EFC_28=6574+0.47*(EFC_27-24300) if EFC_27>=24301
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2003.dta", replace

*2001
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM2001.dta",replace

*Now from the beginning
replace ER18750=0 if ER18750>999997
replace ER18950=0 if ER18950>999997
replace ER18698=0 if ER18698>999997
replace ER19047=0 if ER19047>999997
replace ER18831=0 if ER18831>999997
replace ER18847=0 if ER18847>999997
replace ER19063=0 if ER19063>999997
gen EFC_2=ER20443+ER20447
gen EFC_4=ER18750+ER18950+ER18698+ER19047+ER18831+ER18847+ER19063+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER17004 state_code
gen age=ER17013 if ER17013>=ER17015 &ER17013!=999&ER17015!=999
label variable age "Age of older parent"
replace age=ER17015 if ER17013<ER17015&ER17013!=999&ER17015!=999
replace age=ER17013 if ER17015==999|ER17015==0
replace age=ER17015 if ER17013==999|ER17013==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER17004
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC2001A5_0 if ER17024==1
replace EFC_23=EFC2001A5_1 if ER17024!=1
gen EFC_9=EFC_7*EFC2001A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC2001A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER20443 if ER20443<=76200 
replace EFC_10=5829.3+0.0145*ER20443 if ER20443>76200 
gen EFC_11=0.0765*ER20447 if ER20447<=76200 
replace EFC_11=5829.3+0.0145*ER20447 if ER20447>76200 
*EFC Form A3 "# IN FU" ER17012 Number in parents household, including  student
/*gen Collegestu=ER17012-2-ER17016 if ER17024==1
replace Collegestu=ER17012-1-ER17016 if ER17024!=1*/
gen Collegestu=1
gen EFC_12=8810+3060*ER17012-2170*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER20443>=ER20447 &ER20447!=0&ER20443!=0
replace dummy_head=0 if ER20443<ER20447 &ER20447!=0&ER20443!=0
replace dummy_head=2 if ER20443==0
replace dummy_head=3 if ER20447==0
gen EFC_13=0.35*ER20447 if dummy_head==1
replace EFC_13=0.35*ER20443 if dummy_head==0
replace EFC_13=0.35*ER20447 if dummy_head==2
replace EFC_13=0.35*ER20443 if dummy_head==3
replace EFC_13=2900 if EFC_13>2900
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER19216=0 if ER19216>999999997
replace ER19189=0 if ER19189>999999997
replace ER19198=0 if ER19198>999999997
gen EFC_16=ER19216
gen EFC_17=ER19189
gen EFC_20=ER19198
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=90000
replace EFC_21=36000+0.5*(EFC_20-90000) if EFC_20>90000&EFC_20<=275000
replace EFC_21=128500+0.6*(EFC_20-275000) if EFC_20>275000&EFC_20<=455000
replace EFC_21=236500+(EFC_20-455000) if EFC_20>455000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=11400
replace EFC_28=2508+0.25*(EFC_27-11400) if EFC_27>=11401&EFC_27<=14300
replace EFC_28=3233+0.29*(EFC_27-14300) if EFC_27>=14301&EFC_27<=17200
replace EFC_28=4074+0.34*(EFC_27-17200) if EFC_27>=17201&EFC_27<=20100
replace EFC_28=5060+0.40*(EFC_27-20100) if EFC_27>=20101&EFC_27<=23000
replace EFC_28=6220+0.47*(EFC_27-23000) if EFC_27>=23001
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC2001.dta", replace




*1999
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM1999.dta",replace

*Now from the beginning
replace ER14588=0 if ER14588>999997
replace ER14775=0 if ER14775>999997
replace ER14539=0 if ER14539>999997
replace ER14866=0 if ER14866>999997
replace ER14664=0 if ER14664>999997
replace ER14679=0 if ER14679>999997
replace ER14881=0 if ER14881>999997
gen EFC_2=ER16463+ER16465
gen EFC_4=ER14588+ER14775+ER14539+ER14866+ER14664+ER14679+ER14881+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER13004 state_code
gen age=ER13010 if ER13010>=ER13012 &ER13010!=999&ER13012!=999
label variable age "Age of older parent"
replace age=ER13012 if ER13010<ER13012&ER13010!=999&ER13012!=999
replace age=ER13010 if ER13012==999|ER13012==0
replace age=ER13012 if ER13010==999|ER13010==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta"
drop if _merge!=3
drop _merge 
rename state_code ER13004
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC1999A5_0 if ER13021==1
replace EFC_23=EFC1999A5_1 if ER13021!=1
gen EFC_9=EFC_7*EFC1999A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC1999A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER16463 if ER16463<=68400 
replace EFC_10=5232.6+0.0145*ER16463 if ER16463>68400 
gen EFC_11=0.0765*ER16465 if ER16465<=68400 
replace EFC_11=5232.6+0.0145*ER16465 if ER16465>68400 
*EFC Form A3 "# IN FU" ER13009 Number in parents household, including  student
/*en Collegestu=ER13009-2-ER13013 if ER13021==1
replace Collegestu=ER13009-1-ER13013 if ER13021!=1*/
gen Collegestu=1
gen EFC_12=8470+2940*ER13009-2090*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER16463>=ER16465 &ER16465!=0&ER16463!=0
replace dummy_head=0 if ER16463<ER16465 &ER16465!=0&ER16463!=0
replace dummy_head=2 if ER16463==0
replace dummy_head=3 if ER16465==0
gen EFC_13=0.35*ER16465 if dummy_head==1
replace EFC_13=0.35*ER16463 if dummy_head==0
replace EFC_13=0.35*ER16465 if dummy_head==2
replace EFC_13=0.35*ER16463 if dummy_head==3
replace EFC_13=2800 if EFC_13>2800
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
replace ER15020=0 if ER15020>999999997
replace ER14993=0 if ER14993>999999997
replace ER15002=0 if ER15002>999999997
gen EFC_16=ER15020
gen EFC_17=ER14993
gen EFC_20=ER15002
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=85000
replace EFC_21=34000+0.5*(EFC_20-85000) if EFC_20>85000&EFC_20<=260000
replace EFC_21=121500+0.6*(EFC_20-260000) if EFC_20>260000&EFC_20<=435000
replace EFC_21=226500+(EFC_20-435000) if EFC_20>435000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=11000
replace EFC_28=2420+0.25*(EFC_27-11000) if EFC_27>=11001&EFC_27<=13700
replace EFC_28=3095+0.29*(EFC_27-13700) if EFC_27>=13701&EFC_27<=16500
replace EFC_28=3907+0.34*(EFC_27-16500) if EFC_27>=16501&EFC_27<=19300
replace EFC_28=4859+0.40*(EFC_27-19300) if EFC_27>=19301&EFC_27<=22100
replace EFC_28=5979+0.47*(EFC_27-22100) if EFC_27>=22101
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC1999.dta", replace

*Important note: Many variables or their equivalent are not available in 1997, fixed using 1994 data
*1997
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\FAM1997.dta",replace

*Now from the beginning
replace ER11322=0 if ER11322>999997
replace ER11509=0 if ER11509>999997
replace ER11273=0 if ER11273>999997
replace ER11600=0 if ER11600>999997
replace ER11398=0 if ER11398>999997
replace ER11413=0 if ER11413>999997
replace ER11615=0 if ER11615>999997
gen EFC_2=ER12080+ER12082
gen EFC_4=ER11322+ER11509+ER11273+ER11600+ER11398+ER11413+ER11615+fu_eic+fu_seic
gen EFC_5=EFC_2+EFC_4
*I did not include EFC_6 in this as we do not have data on FASFA Worksheet B
gen EFC_7=EFC_5
*EFC_8 from TAXIM
gen EFC_8=fu_fiitax+fu_siitax
replace EFC_8=0 if EFC_8<0

*EFC_9 From formula A
*Table A1 and A5
rename ER12221 state_code
gen age=ER10009 if ER10009>=ER10011 &ER10009!=999&ER10011!=999
label variable age "Age of older parent"
replace age=ER10011 if ER10009<ER10011&ER10009!=999&ER10011!=999
replace age=ER10009 if ER10011==999|ER10011==0
replace age=ER10011 if ER10009==999|ER10009==0
merge m:1 state_code using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA1.dta" 
drop if _merge!=3
drop _merge
rename state_code ER12221
merge m:1 age using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFCA5.dta"
drop if _merge!=3
drop _merge
gen EFC_23=EFC1999A5_0 if ER10016==1
replace EFC_23=EFC1999A5_1 if ER10016!=1
gen EFC_9=EFC_7*EFC1999A1_0/100 if EFC_7<15000
replace EFC_9=EFC_7*EFC1999A1_1/100 if EFC_7>=15000
replace EFC_9=0 if EFC_9<0
*Calculate social security tax EFC_10 & EFC_11
gen EFC_10=0.0765*ER12080 if ER12080<=68400 
replace EFC_10=5232.6+0.0145*ER12080 if ER12080>68400 
gen EFC_11=0.0765*ER12082 if ER12082<=68400 
replace EFC_11=5232.6+0.0145*ER12082 if ER12082>68400 
*EFC Form A3 "# IN FU" ER10008 Number in parents household, including  student
/*gen Collegestu=ER10008-2-ER10012 if ER10016==1
replace Collegestu=ER10008-1-ER10012 if ER10016!=1*/
gen Collegestu=1
gen EFC_12=8470+2940*ER10008-2090*Collegestu
replace EFC_12=0 if Collegestu==0
gen dummy_head=1 if ER12080>=ER12082 &ER12082!=0&ER12080!=0
replace dummy_head=0 if ER12080<ER12082 &ER12082!=0&ER12080!=0
replace dummy_head=2 if ER12080==0
replace dummy_head=3 if ER12082==0
gen EFC_13=0.35*ER12082 if dummy_head==1
replace EFC_13=0.35*ER12080 if dummy_head==0
replace EFC_13=0.35*ER12082 if dummy_head==2
replace EFC_13=0.35*ER12080 if dummy_head==3
replace EFC_13=2800 if EFC_13>2800
gen EFC_14=EFC_8+EFC_9+EFC_10+EFC_11+EFC_12+EFC_13
gen EFC_15=EFC_7-EFC_14
gen EFC_16=S305
gen EFC_17=S309
gen EFC_20=S303
gen EFC_21=0 if EFC_20<1
*EFC Form A4
replace EFC_21=0.4*EFC_20 if EFC_20>=1&EFC_20<=85000
replace EFC_21=34000+0.5*(EFC_20-85000) if EFC_20>85000&EFC_20<=260000
replace EFC_21=121500+0.6*(EFC_20-260000) if EFC_20>260000&EFC_20<=435000
replace EFC_21=226500+(EFC_20-435000) if EFC_20>435000
gen EFC_22=EFC_16+EFC_17+EFC_21
*For table A5, AGE OF HEAD	ER47317, AGE OF WIFE ER47319, the rates of which are in the separate dta file for compilation of the whole table.
gen EFC_24=EFC_22-EFC_23
gen EFC_26=EFC_24*0.12
replace EFC_26=0 if EFC_26<0
gen EFC_27=EFC_15+EFC_26
*EFC Form A6
gen EFC_28=-750 if EFC_27<-3409
replace EFC_28=0.22*EFC_27 if EFC_27>=-3409&EFC_27<=11000
replace EFC_28=2420+0.25*(EFC_27-11000) if EFC_27>=11001&EFC_27<=13700
replace EFC_28=3095+0.29*(EFC_27-13700) if EFC_27>=13701&EFC_27<=16500
replace EFC_28=3907+0.34*(EFC_27-16500) if EFC_27>=16501&EFC_27<=19300
replace EFC_28=4859+0.40*(EFC_27-19300) if EFC_27>=19301&EFC_27<=22100
replace EFC_28=5979+0.47*(EFC_27-22100) if EFC_27>=22101
replace EFC_28=0 if EFC_28<0
gen EFC_29=Collegestu
gen EFC_30=EFC_28/EFC_29
gen EFC_53=EFC_30
gen EFC=EFC_53
label variable EFC_2 "Parents' income earned from work"
label variable EFC_4 "Untaxed income and benefits"
label variable EFC_5 "Taxable and untaxed income "
label variable EFC_7 "Total income"
label variable EFC_8 "U.S. income tax paid "
label variable EFC_9 "State and other tax allowance"
label variable EFC_10 "Father's Social Security tax "
label variable EFC_11 "Mother's Social Security tax "
label variable EFC_12 "Income protection allowance"
label variable EFC_13 "Employment expense allowance"
label variable EFC_14 "Total allowances"
label variable EFC_15 "Available income"
label variable EFC_16 "Cash, savings, & checking "
label variable EFC_17 "Net worth of real estate & investments"
label variable EFC_20 "Net worth of business/farm"
label variable EFC_21 "Adjusted net worth of business/farm"
label variable EFC_22 "Net worth of assets"
label variable EFC_23 "Education savings and asset protection allowance "
label variable EFC_24 "Discretionary net worth"
label variable EFC_26 "Contribution from assets"
label variable EFC_27 "Adjusted available income "
label variable EFC_28 "Total parents' contribution from AAI"
label variable EFC_29 "Number in college"
label variable EFC_30 "Parents' contribution"
label variable EFC_53 "Expected family contribution"
keep famno year-EFC
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\TAXIM and EFC\EFC CALC\EFC1997.dta", replace
