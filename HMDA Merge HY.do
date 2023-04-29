*First we need to merge the hmda data with geocorr data to add the zipcode in geocorr to hmda.

/* Data Used */

*hmda_revised.dta
*geocorr_zip.dta

 use  "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Revised HMDA\hmda_revised.dta" 

*merge

*Taking into account the HMDA data update problem

replace year=1990 if rawyear>=2000 &rawyear<=2002
replace year=2000 if rawyear>=2010 &rawyear<=2011

merge m:m state_code county_code census_tract year using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Hmda Zip\geocorr_zip.dta" 
 

*After merging I mainly used the "sum hold if _merge==____&_____" to analyse the unmerged data and use the data editor (browse) to check unmerged observations with the filter and sort options in it, since the whole process is too long I'm gonna skip those in this do file.

*After analysis of the unmerged observations (_merge==1 | _merge==2), the results of which are included in my previous follow-up emails with you and was uploaded to dropbox, we decided to drop the unmerged cases with code:

drop if _merge!=3
drop _merge

*After the steps above the revised HMDA dataset is properly merged with geocorr and here we would like to merge it with the population data at county level I collected from the census bureau website.

merge m:m fips rawyear using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Population race data\Population_HY.dta" 

*After merge we use the sum hold trick and tabulations to investigate the unmerged cases which is covered in my follow-ups over the past month. Easily found in the follow-up pdf files hence I am skipping those for now. After the merging and investigating process we would like to collapse and produce the county and state level population merged HMDA data.

/*County level collapse*/

collapse (sum) count_orig amt_orig count_app count_deny (mean) nhwhite-count_tract, by(state_code county_code rawyear race)

drop if rawyear<1997|rawyear>2015
(34,555 observations deleted)

drop if race==.

*To produce the type of data sorted by race as per the instructions given my Emily in our meeting on June 6

reshape wide count_orig-count_tract, i(state_code county_code rawyear) j(race)

 *Summary of the reshape 
 


Data                               Long   ->   Wide
-----------------------------------------------------------------------------
Number of observations          106,431   ->   59,538      
Number of variables                  20   ->   35          
j variable (2 values)              race   ->   (dropped)
xij variables:
                             count_orig   ->   count_orig1 count_orig2
                               amt_orig   ->   amt_orig1 amt_orig2
                              count_app   ->   count_app1 count_app2
                             count_deny   ->   count_deny1 count_deny2
                                nhwhite   ->   nhwhite1 nhwhite2
                                nhblack   ->   nhblack1 nhblack2
                               nhnative   ->   nhnative1 nhnative2
                                nhaspac   ->   nhaspac1 nhaspac2
                                 hwhite   ->   hwhite1 hwhite2
                                 hblack   ->   hblack1 hblack2
                                hnative   ->   hnative1 hnative2
                                 haspac   ->   haspac1 haspac2
                                  nhtwo   ->   nhtwo1 nhtwo2
                                   htwo   ->   htwo1 htwo2
                              count_zip   ->   count_zip1 count_zip2
                            count_tract   ->   count_tract1 count_tract2
-----------------------------------------------------------------------------



 
 /*State level collapse*/
 
 collapse (sum) count_orig amt_orig count_app count_deny, by(state_code rawyear race)
 
  merge m:m state_code rawyear using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Population race data\statepop.dta"

 
 *To produce the type of data sorted by race as per the instructions given my Emily in our meeting on June 6
 
 reshape wide count_orig-count_tract, i(state_code rawyear) j(race)
 
 *Summary of the reshape 
 Data                               Long   ->   Wide
-----------------------------------------------------------------------------
Number of observations            1,938   ->   969         
Number of variables                  19   ->   34          
j variable (2 values)              race   ->   (dropped)
xij variables:
                             count_orig   ->   count_orig1 count_orig2
                               amt_orig   ->   amt_orig1 amt_orig2
                              count_app   ->   count_app1 count_app2
                             count_deny   ->   count_deny1 count_deny2
                                nhwhite   ->   nhwhite1 nhwhite2
                                nhblack   ->   nhblack1 nhblack2
                               nhnative   ->   nhnative1 nhnative2
                                nhaspac   ->   nhaspac1 nhaspac2
                                 hwhite   ->   hwhite1 hwhite2
                                 hblack   ->   hblack1 hblack2
                                hnative   ->   hnative1 hnative2
                                 haspac   ->   haspac1 haspac2
                                  nhtwo   ->   nhtwo1 nhtwo2
                                   htwo   ->   htwo1 htwo2
                              count_zip   ->   count_zip1 count_zip2
                            count_tract   ->   count_tract1 count_tract2
-----------------------------------------------------------------------------

/*Producing the ZIP level population merged data is a bit fussy as it requires us to break down the merged HMDA data into 1990, 2000 amd 2010 files and merge separately with ZCTA 2000 and 2010 data*/
*The first step is to use GeoCorr data of 1990, 2000 and 2010 to make a new GeoCorr file used for merging. The file I compiled for the ZIP level merge is named geocorr_HY and is in the GeoCorr folder in Dropbox.

*First let's compile this New Geocorr file with new allocation factor
 *Creating population data file separately for 1990, 2000 and 2010
import delimited "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Geocorr Data\geocorr1990z.csv"

rename statecodefips state_code
rename county fips
rename censustractbna census_tract
gen county_code=fips-1000*state_code
gen year=1990
collapse (sum) pop, by(state_code county_code census_tract year)
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1990countypop.dta", replace
*Tract population file has been create, next we need to merge it with the same geocorr_1990z file
import delimited "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Geocorr Data\geocorr1990z.csv"
gen county_code=county-1000*state
merge m:1 state_code county_code censustractbna using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1990countypop.dta"
. drop _merge

. gen rev_factor=pop/tractpop

. rename county fips

. rename censustractbna census_tract

. gen year=1990

. save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1990zipgeocorr.dta"
*Do the same for 2000 and 2010, except that we need to covert xlsx to csv for 2000 and 2010, then append 
append using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\2000zipgeocorr.dta"
append using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\2010zipgeocorr.dta"
. replace county_code=86 if fips==12025
. replace fips=12086 if fips==12025
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\geocorr_HY.dta"

*Now go back to HMDA we need to reshape first such that our identifier is unique 
 use  "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\Revised HMDA\hmda_revised.dta" 

replace year=1990 if rawyear>=2000 &rawyear<=2002
replace year=2000 if rawyear>=2010 &rawyear<=2011
 reshape wide count_app count_deny amt_orig count_orig,  i(state_code county_code census_tract rawyear) j(race)
 . replace county_code=86 if fips==12025
. replace fips=12086 if fips==12025
 joinby state_code county_code census_tract year using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\geocorr_HY.dta"
 
 save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HY_Merge.dta"

 *Note: We could also use the original geocorr_zip.dta file and merge with the reshaped HMDA file using a 1:m merge, and this would require one more step: merge 1.dta, 2.dta and 3.dta produced (in the same way as shown below) with the geocorr_HY.dta file which has the reverse allocation factor.
 
drop if year!=1990

 save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1990HMDA.dta", replace

Matching HMDA to ZCTA data
 
use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1990HMDA.dta"

destring zipcode, replace

 merge m:m zipcode using  "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\2000ZCTA.dta" 
 
 drop if _merge!=3
 
 drop _merge

save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1.dta", replace
*Do the same for 2000 and 2010 careful for 2010, all of the census tracts in HMDA and GeoCorr files must be rounded to 0.01 level or they would not be merged, I was stuck here for some time until I ruled out every possibility of unmerging, glad that rounding up worked 

*Note: If the original geocorr_zip rather than the geocorr_HY with rev_factor was used, then from file 1.dta, 2.dta and 3.dta we still need to merge then with 1990zipgeocorr.dta, 2000zipgeocorr.dta and 2010zipgeocorr.dta
/*
use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\1.dta"
merge m:1 state_code county_code zipcode census_tract year using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\1990zipgeocorr.dta"
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\11.dta"

And do the same for 2.dta and 3.dta in producing 12.dta and 13.dta then:
use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\11.dta"
append using 12
append using 13
*/

*Round the data 
Use  "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\2010zipgeocorr.dta"
replace census_tract=round(census_tract,0.01)
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\2010zipgeocorr.dta", replace
Use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\3.dta"
replace census_tract=round(census_tract,0.01)
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\3.dta", replace

*Now append the data*/
Use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\1.dta"
Use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\2.dta"
Use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\3.dta"
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\RA updates\MergedHY_zip.dta" 
 *Calculate Zip level counts and amounts from census tracts.
 gen count_orig1z=count_orig1*rev_factor
 gen count_orig2z=count_orig2*rev_factor
 gen count_app1z=count_app1*rev_factor
 gen count_app2z=count_app2*rev_factor
 gen count_deny1z=count_deny1*rev_factor
 gen count_deny2z=count_deny2*rev_factor
 gen amt_orig1z=amt_orig1*rev_factor
 gen amt_orig2z=amt_orig2*rev_factor
 *Collapse into final data form
 rename rawyear year18
 collapse (sum) count_orig1z-amt_orig2z (mean) totpop00-pop totpop10 popchange pctpopchange1000, by(state_code county_code zipcode year18)
save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\RA updates\MergedHY_zip.dta", replace
*To Produce the "matched" Zip level data as is mentioned in the 12 July email, I programmed in R and produced a new dta file name geocorr_HYm.dta which could be found in the same folder as this do file, starting from that geocorr file with a 0/1 dummy on whether a zipcode is in two or more counties (0 for no and 1 for yes), I did the following work in producing the final zip level panel for uploaded
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\geocorr_HYm.dta" 
 collapse (mean) multiplecounty, by (state_code zipcode year)
 save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\geocorr_HYcollapse.dta" 

. use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\MergedzZIP_HY.dta" 
 
 gen count_orig1z=count_orig1*rev_factor
 gen count_orig2z=count_orig2*rev_factor
 gen count_app1z=count_app1*rev_factor
 gen count_app2z=count_app2*rev_factor
 gen count_deny1z=count_deny1*rev_factor
 gen count_deny2z=count_deny2*rev_factor
 gen amt_orig1z=amt_orig1*rev_factor
 gen amt_orig2z=amt_orig2*rev_factor
 
merge m:1 state_code zipcode year using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\geocorr_HYcollapse.dta"

 drop if _merge!=3

. drop _merge

 collapse (sum) count_orig1z-amt_orig2z (mean) totpop00-pop totpop10 popchange pctpopchange1000, by(state_code zipcode year18)
 
 rename count_orig1z count_orig1zsum

. rename count_orig2z count_orig2zsum

. rename count_app1z count_app1zsum

. rename count_app2z count_app2zsum

. rename count_deny1z count_deny1zsum

. rename count_deny2z count_deny2zsum

. rename amt_orig1z amt_orig1zsum

. rename amt_orig2z amt_orig2zsum

. save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\zipsum.dta", replace

 use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\MergedHY_zip.dta" 

. merge m:1 state_code zipcode year18 using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\zipsum.dta"
drop _merge

 gen year=1990 if year18<=2002

. replace year=2000 if year18>=2003&year18<=2011

. replace year=2010 if year18>2011

. merge m:1 state_code zipcode year using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\geocorr_HYcollapse.dta"

 drop if _merge!=3

. drop _merge

. drop year

save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\MergedHY_zipsum.dta"


*For county-level data with multiplecounty identifier, I did the following:

use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\MergedHY_zipsum.dta" 

. drop count_orig1zsum-amt_orig2zsum

tostring county_code, generate (county)

tostring zipcode, generate (zip)

. gen countyzipfips=county+"-"+zip

. drop county zip



 save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\county_ziplvlMerge.dta"

*For zip-level data with multiplecounty identifier, I did the following:

 use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\MergedzZIP_HY.dta" 
 
 gen count_orig1z=count_orig1*rev_factor
 gen count_orig2z=count_orig2*rev_factor
 gen count_app1z=count_app1*rev_factor
 gen count_app2z=count_app2*rev_factor
 gen count_deny1z=count_deny1*rev_factor
 gen count_deny2z=count_deny2*rev_factor
 gen amt_orig1z=amt_orig1*rev_factor
 gen amt_orig2z=amt_orig2*rev_factor
 
merge m:1 state_code zipcode year using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\geocorr_HYcollapse.dta"

 drop if _merge!=3

. drop _merge

 collapse (sum) count_orig1z-amt_orig2z (mean) totpop00-pop totpop10 popchange pctpopchange1000, by(state_code zipcode year18)
 
 rename count_orig1z count_orig1zsum

. rename count_orig2z count_orig2zsum

. rename count_app1z count_app1zsum

. rename count_app2z count_app2zsum

. rename count_deny1z count_deny1zsum

. rename count_deny2z count_deny2zsum

. rename amt_orig1z amt_orig1zsum

. rename amt_orig2z amt_orig2zsum

 gen year=1990 if year18<=2002

. replace year=2000 if year18>=2003&year18<=2011

. replace year=2010 if year18>2011

. merge m:1 state_code zipcode year using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\geocorr_HYcollapse.dta"

 drop if _merge!=3

. drop _merge

. drop year

save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\ziplvlMerge.dta.dta"

/*Heng's note: To address the problem that around 87k data from 2012 to 2015 report missing white1 population variable, I used the variable "pop" which is the total population and variable "pctwhite_non_hisp" which indicates the percentage of nonhispanic white population out of total population (white1 denotes nonhispanic white in our dataset)
*/

use "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\ziplvlMerge.dta" 

. drop pop

 merge m:1 state_code zipcode year using "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\geocorr_HY_pop.dta" 

. drop if _merge!=3

. drop_merge

replace white1=round(pop*pctwhite_non_hisp/100) if white1==.

 save "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\HYzipMergefiles\ziplvlMerge_July_20.dta"
 
*Note: There is a file named ziplvlMerge_July_20_duplicated.dta. I created this file to test some merging techniques, the contents are the same as the ziplvlMerge_July_20.dta file.
*Now merge the 2010zip.dta file generate from R to compile the data with full information at ZCTA2010 level:
 use "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\ziplvlMerge_July_20_pop_duplicate.dta" 

. drop if year==2010

 append using "C:\Users\Heng Yu\OneDrive - Duke University\Desktop\R Files\2010zip.dta"
 
 . drop sumlev esriid
 
 . . label variable totpop00 "total population 2000"

. . label variable totpop90 "total population 1990"

. . label variable popchange0090 "total population change 90 to 00"

. . label variable pctchange "percentage of total pop change 90-00"

. . label variable male "male population"

. . label variable pctmale "percentage of male"

. . label variable pctmale "percentage of male pop"

. . label variable female "female population"

. label variable pctfemale "percentage of female"

. . label variable one_race_total " one_race_total population"

. . label variable pctone_race_total "percentage of one race total pop"

. . label variable white1 "White Alone "

. . label variable pctwhite1 "percentage White Alone "

. . label variable black1 "black alone "

. 
. 
. 
. . label variable white1 "white Alone "

. 
. 
. 
. . label variable pctblack1 "percentage black alone"

. 
. 
. 
. . label variable indian "indian alone"

. 
. 
. 
. . label variable black1 "Black or African American Alone "

. 
. 
. 
. . label variable pctblack1 "percentage Black or African American Alone "

. 
. 
. 
. . label variable indian "American Indian or Alaska Native Alone "

. 
. 
. 
. . label variable pctindian "% American Indian or Alaska Native Alone "

. 
. 
. 
. . label variable asian1 "Asian Alone "

. 
. 
. 
. . label variable pctasian1 "% Asian Alone "

. 
. 
. 
. . label variable asian_indian "Asian Indian "

. 
. 
. 
. . label variable pct_asian_indian "% Asian Indian "

. 
. 
. 
. . label variable chinese "Chinese "

. 
. 
. 
. . label variable pct_chinese "% Chinese "

. 
. 
. 
. . label variable filipino "Filipino "

. 
. 
. 
. . label variable pct_filipino "% Filipino "

. 
. 
. 
. . label variable japanese " japanese"

. 
. 
. 
. . label variable pct_japanese "% japanese"

. 
. 
. 
. . label variable korean "korean"

. 
. 
. 
. . label variable pct_korean "% korean"

. 
. 
. 
. . label variable vietnamese "vietnamese"

. 
. 
. 
. . label variable pct_vietnamese "% vietnamese"

. 
. 
. 
. . label variable other_asian " other_asian"

. 
. 
. 
. . label variable pct_other_asian "% other_asian"

. 
. 
. 
. . label variable hawnpi1 "Hawaiian and Other Pac Islndr Alone "

. 
. 
. 
. . label variable pcthawnpi1 "% Hawaiian and Other Pac Islndr Alone "

. 
. 
. 
. . label variable hawaiian "Native Hawaiian "

. 
. 
. 
. . label variable pct_hawaiian "%Native Hawaiian "

. 
. 
. 
. . label variable guam_or_cham "Guamanian or Chamorro "

. 
. 
. 
. . label variable pct_guam_or_cham "%Guamanian or Chamorro "

. 
. 
. 
. . label variable samoan "Samoan "

. 
. 
. 
. . label variable pct_samoan "%Samoan "

. 
. 
. 
. . label variable other_pac_islander "Other Pacific Islander Alone "

. 
. 
. 
. . label variable pct_other_pac_islander "%Other Pacific Islander Alone "

. 
. 
. 
. . label variable other1 "Some other race Alone "

. 
. 
. 
. . label variable pctother1 "%Some other race Alone "

. 
. 
. 
. . label variable multrace "Multi Racial "

. 
. 
. 
. . label variable pctmultrace "%Multi Racial "

. 
. 
. 
. . label variable white2 "White Alone or in Combination "

. 
. 
. 
. . label variable pct_white2 "%White Alone or in Combination "

. 
. 
. 
. . label variable black2 "Black or African American Alone or in Comb "

. 
. 
. 
. . label variable pct_black2 "%Black or African American Alone or in Comb "

. 
. 
. 
. . label variable indian2 "American Indian or Alaska Native Alone or in Comb "

. 
. 
. 
. . label variable pct_indian2 "%American Indian or Alaska Native Alone or in Comb "

. 
. 
. 
. . label variable asian2 "Asian Alone or in Comb "

. 
. 
. 
. . label variable pct_asian2 "%Asian Alone or in Comb "

. 
. 
. 
. . label variable hawnpi2 "Hawaiian and Other Pac Islndr Alone or in Comb "

. 
. 
. 
. . label variable pct_hawnpi2 "%Hawaiian and Other Pac Islndr Alone or in Comb "

. 
. 
. 
. . label variable other2 "Other race Alone or in Comb "

. 
. 
. 
. . label variable pct_other2 "%Other race Alone or in Comb "

. 
. 
. 
. . label variable hisppop "Total Hispanic or Latino (any Race) "

. 
. 
. 
. . label variable pcthisppop "%Total Hispanic or Latino (any Race) "

. 
. 
. 
. . label variable mexican "Mexican "

. 
. 
. 
. . label variable pctmexican "%Mexican "

. 
. 
. 
. . label variable puertorican "Puertorican"

. 
. 
. 
. . label variable pctpuertorican "%Puertorican"

. 
. 
. 
. . label variable cuban "Cuban"

. 
. 
. 
. . label variable pctcuban "%Cuban"

. 
. 
. 
. . label variable otherhispanic "Other Hispanic or Latino "

. 
. 
. 
. . label variable pctotherhispanic "%Other Hispanic or Latino "

. 
. 
. 
. . label variable non_hispanic "Not Hispanic or Latino "

. 
. 
. 
. . label variable pctnon_hispanic "%Not Hispanic or Latino "

. 
. 
. 
. . label variable white_non_hisp "White Alone Non Hispanic "

. 
. 
. 
. . label variable pctwhite_non_hisp "%White Alone Non Hispanic "

. 
. 
. 
. . label variable poppsqmi "Persons Per Sq Mile "

. 
. 
. 
. . label variable totpop10 "total population 2010"


. . label variable popchange "population change 00-10"

. 
. . label variable pctpopchange1000 "% population change 00-10"

. 
. . label variable multiplecounty "multiplecounty dummy"

. . label variable pop "population from geocorr"

. save "C:\Users\Heng Yu\Dropbox\PSID Proj 3 R & T\Race Differences in Parental College Support & Attendance\FASFA, Pell Grant & HMDA Materials\HYzipMergefiles\ziplvlMerge_July_21_R_updated.dta"
