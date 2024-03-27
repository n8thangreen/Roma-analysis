**** -------- DESCRIPTIVE STATISTICS -------
clear all
*Create a local directory (change this in order to execute the files)
local dir "/Users/antoniomarchitto/Desktop/DATASET/mydata"
cd `dir'
use dataDEF.dta

*First table - Percentage of Roma for each country (Table 1)
label define sample 0 "Non-Roma" 1 "Roma"
label values sample sample

dtable i.sample, by(country) varlabel sample(,statistics(freq) place(seplabels)) factor(sample, test(none)) title("Sample size and Roma composition") export(table1.tex, replace) 


* Presentation of DEPENDENT VARIABLES. 

**1) The first dependent variable is "screening initiative", which measures the occurrence of medical services received by the respondent. The survey asks the respondent to declare if in the previous 12  months the following medical check-ups  have been  part of any consultation: a dental check-up, an x-ray, ultrasound or other scan, a cholesterol test, an heart check-up. The dependent variable for the analysis  is  binary and takes the value 1 if the respondent listed at least one screening, and 0 otherwise.

*As a remainder, the variable "screening" is a cumulative variable of all the possible screenings the respondent might have undergone. 

gen screening_initiative=1 if screening>0
replace screening_initiative=0 if screening==0
replace screening_initiative=. if screening==.

label var screening_initiative "Access to healthcare services"

***For the graph decribing this first dependent variable
gen screening_initiative_roma=1 if screening_initiative==1 & sample==1
replace screening_initiative_roma=0 if screening_initiative==0 & sample==1
label var screening_initiative_roma "Roma subsample"
gen screening_initiative_non=1 if screening_initiative==1 & sample==0
replace screening_initiative_non=0 if screening_initiative==0 & sample==0
label var screening_initiative_non "Non-Roma subsample"

*** Graph 1 Histogram Healthcare Access by sample
graph bar screening_initiative_roma screening_initiative_non, over(country) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ebblue)) bar(2,color(eltgreen )) title("Access to healthcare services")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig1.png", as(png) name("Graph") replace

*** Graph 2 We can draw a boxplot with interval of confidence
ciplot screening_initiative_roma screening_initiative_non, by(country) inclusive title("Access to healthcare services") xtitle("Country", size(small)) 
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig2.png", as(png) name("Graph") replace

** 2) In a second step, the dependent variable of interest is related to unmet medical needs. The variable health_behavior is binary, takes the value of 1 if  the individual, at least once in the last 12 months, needed to consult a doctor but did not, and 0 otherwise.


gen health_behavior_roma=1 if health_behavior==1 & sample==1
replace health_behavior_roma=0 if health_behavior==0 & sample==1
label var health_behavior_roma "Roma subsample"
gen health_behavior_non=1 if health_behavior==1 & sample==0
replace health_behavior_non=0 if health_behavior==0 & sample==0
label var health_behavior_non "Non-Roma subsample"
label var health_behavior "Unmet needs of medical care"

*** Graph 3 Histogram Healthcare Avoidance
graph bar health_behavior_roma health_behavior_non,over(country) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ebblue)) bar(2,color(eltgreen)) title("Healthcare Avoidance")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig3.png", as(png) name("Graph") replace

*** Graph 4 We can draw a boxplot with interval of confidence
ciplot health_behavior_roma health_behavior_non, by(country) inclusive title("Healthcare Avoidance") xtitle("Country", size(small)) 
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig4.png", as(png) name("Graph") replace

** Presentation of EXPLANATORY VARIABLES

***1) The variable Community support, measures how many of the following sources of support are listed by the respondent:  support from a friend, a relative, an employer, a rich man in the community.

*** We build this summative scale variable. 
global support first_support second_support third_support
local x $support
foreach var of varlist `x'* {
replace `var'=. if `var'>96
replace `var'=0 if `var'==96
}
corr first_support second_support third_support
egen community_support = anycount(first_support second_support third_support), values(1 2 3 4)
replace community_support=. if first_support==. & second_support==. & first_support==.
gen community_support_n = (community_support - 0) / (3)
tab community_support_n sample
label var community_support_n "Community support"


****Creation of variable INTENSITY OF IDENTITY
*** This variables measures the strenght of acceptability of behaviors that go against the common rules of the mainstream society. Each of the variables included can take a value between 1-3 in terms of acceptability of behaviors. If the variable takes the value 1 it means that the behavior is always acceptable, 2 is sometimes acceptable, 3 is never acceptable. 

global intensity citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance nomixedmarriage bridesteal_acceptance arrangedmarriageboy_acceptance arrangedmarriagegirl_acceptance nodelaymarriage husbandslapwife wifeslaphusband

corr $intensity
alpha $intensity
local x $intensity
foreach var of varlist `x'* {
replace `var'=. if `var'>3
}

egen own_norms= rowmean(citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance nomixedmarriage bridesteal_acceptance arrangedmarriageboy_acceptance arrangedmarriagegirl_acceptance nodelaymarriage husbandslapwife wifeslaphusband)
egen median_ownorms=median(own_norms)
egen mean_ownorms=mean(own_norms)

**The variabile intensity1 takes the value 1 if the intensity of own norms is higher than the average. Intensity2 takes the value 1 if the intensity of own norms if higher than the median. The way the variable is it constructed is counterintuitive, because the variable intensity takes the value 1 if the value is lower than the average. (NB, the lower the value of the variable, the more accepted are behaviors that go against the "common rules".)  


gen intensity1=1 if own_norms<mean_ownorms
replace intensity1=0 if intensity1==.
gen intensity2=1 if own_norms<median_ownorms
replace intensity2=0 if intensity2==.

label var intensity1 "Intensity of Social Norms"


*** Graph 5: CI for the main variables by subsample 
ciplot intensity1 screening_initiative health_behavior community_support_n, by(sample) title("CI for the main variables by subsample")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig5.png", as(png) name("Graph") replace

*Now I create the interaction terms for the explanatory variable "Community support", "Intensity of own norms" and "Perceived discrimination"
label var discrimination_ethnicity "Ethnic discrimination"

gen community_support_ni= sample*community_support_n
label var community_support_ni "Community support x Roma"

 
gen intensity1_ni=intensity1*sample
label var intensity1_ni "Community support"

* ADDITIONAL CONTROLS

**1) We create an asset index 
pca radio tv bike car horse computer internet phone washingmachine bed_foreach books30 powergenerator kitchen piped toilet wastewater bathroom electricity heating 
estat kmo
predict comp1
hist comp1
rename comp1 asset_score
xtile asset_index= asset_score [aweight=number_members], nq(5) 
la val asset_index asset_index
la var asset_index "Asset index"
la de asset_index 1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest"
tab asset_index

*Now we create Table 2 "Characteristics of the respondents"

label var age "Age"
label var unemployed "Unemployed"
label var health_insurance "Health insurance"
label var good_health "Self-reported good health"
label var health_behavior "Avoidance of medical screening"
label var female "Female"
label var sample "Sample"
label var health_self "Self-reported Health status"
label var educ "Educational Level"

** Table 2: Summary statistics of the covariates by subsample
dtable i.sex age i.educ i.health_self i.health_insurance i.asset_index, by(sample, nototals tests) varlabel sample(,statistics(freq) place(seplabels)) sformat("(N=%s)" frequency) note(Total sample: N=6760) continuous(age, test(none)) factor(sex educ health_self health_insurance asset_index, test(none)) title("Summary statistics of the covariates by subsample") export(table2.tex, replace) 


*** --------------- EMPIRICAL ANALYSIS ------------------------
label var sample "Roma"
*1) Occurence of health services 

*** a) Logistic regression for occurrence of healthcare (Table 4) and community support
global type_neighbourhood town village capital city unregulated_area
eststo clear


eststo a: logit screening_initiative community_support_n sample age no_educ female  health_insurance i.country i.asset_index, vce(cluster municipality_n) or
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"



eststo b:  logit  screening_initiative community_support_n intensity1 sample health_insurance female age no_educ  i.health_self  i.country $type_neighbourhood   i.asset_index i.percentage_of_roma i.role, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



eststo c: logit  screening_initiative community_support_n  sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma i.role, vce(cluster municipality_n)
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: logit  screening_initiative community_support_n sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 i.role, vce(cluster municipality_n)
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab a b c d using Tab1.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni  sample female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for occurence of healthcare") nomtitles

* Graph 6: Show the results of the completed model as a coefficient plot. 
quietly logit  screening_initiative community_support_n sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 i.role, vce(cluster municipality_n)

coefplot, drop(_cons) xline(1) eform xtitle(Odds ratio) keep(community_support_n  community_support_ni  sample female age no_educ health_insurance intensity1) pstyle(ci2) msymbol(c) mcolor(red) msize(small) ciopts(recast(rcap) lcolor(gs4)) graphregion(color(gs15)) 
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig6.png", as(png) name("Graph") replace

*** b) Logistic regression for occurence of healthcare by subsample.
eststo a: logit  screening_initiative community_support_n discrimination_ethnicity health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 if sample==0 , vce(cluster municipality_n) 
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo b: logit  screening_initiative community_support_n discrimination_ethnicity  health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 if sample==1 , vce(cluster municipality_n) 
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes" 

esttab a b using Tab2.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for occurence of healthcare by subsample") mtitles("Non-Roma" "Roma")

* Graph 7: Show the results of the completed model as a coefficient plot. 


coefplot (a, label(Non-Roma)) (b, label(Roma)), drop(_cons) xline(1) eform xtitle(Odds ratio) keep(community_support_n  community_support_ni  sample female age no_educ health_insurance intensity1) pstyle(ci2) ciopts(recast(rcap) lcolor(gs4)) graphregion(color(gs15)) 
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig7.png", as(png) name("Graph") replace

*** c) Logisitic regression for occurrence of healthcare DECOMPOSED BY DECISION

*Different measures of screening_initiative (Table 5)
global screening screening2 screening3 screening4 
local x $screening
foreach var of varlist `x'* {
gen initiative_`var'=1 if `var'>0
replace initiative_`var'=0 if `var'==0
replace initiative_`var'=. if `var'==.
}


label var initiative_screening2 "Screening initiative by own initiative"
label var initiative_screening3 "Screening initiative by doctor invitation"
label var initiative_screening4 "Screening initiative by screening initiative"


eststo clear
eststo d1: logit  screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo e: logit initiative_screening2 community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo f: logit initiative_screening3 community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo g: logit initiative_screening4 community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab d1 e f g using Tab5.tex , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity sample intensity1) stats(asset country neighbour health N, labels("Baseline controls""Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by decision")  mtitles("Anyone's initiative"  "Own Initiative" "Doctor's initiative" "Screening program")


*** d) Logistic regression of occurrence of healthcare decomposed by gender

*Difference between males and females (Table 6) 

eststo clear

eststo r0: logit initiative_screening2 community_support_n  discrimination_ethnicity sample intensity1  health_insurance  age no_educ  i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r1: logit  initiative_screening2 community_support_n discrimination_ethnicity sample  community_support_ni intensity1 health_insurance  age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r2: logit  initiative_screening2 community_support_n discrimination_ethnicity sample  health_insurance intensity1 age no_educ  i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r3: logit  initiative_screening2 community_support_n discrimination_ethnicity sample intensity1 community_support_ni health_insurance  age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab r0 r1 r2 r3 using Tab6.tex , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n discrimination_ethnicity sample community_support_ni intensity1) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by gender")  mtitles("Female" "Female" "Male" "Male")

* Graph 7: Show the results of the completed model as a coefficient plot. 


coefplot (r1, label(Female sample)) (r3, label(Male sample)), drop(_cons) xline(1) eform xtitle(Odds ratio) keep(community_support_n  community_support_ni  sample female age no_educ health_insurance intensity1) pstyle(ci2) ciopts(recast(rcap) lcolor(gs4)) graphregion(color(gs15)) 
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig8.png", as(png) name("Graph") replace


*** 2) Results for Healthcare avoidance 
***a) Logistic regression for avoidance of healthcare (Table 7)

eststo clear

eststo a: logit health_behavior community_support_n sample intensity1 discrimination_ethnicity age no_educ female  health_insurance i.country i.asset_index, vce(cluster municipality_n) or
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"



eststo b:  logit health_behavior community_support_n intensity1 discrimination_ethnicity sample health_insurance female age no_educ  i.health_self  i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"




eststo c: logit  health_behavior community_support_n intensity1 discrimination_ethnicity sample  community_support_ni  health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab a b c using Tab8.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity sample female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for avoidance of healthcare") nomtitles


***b) Logistic regression for avoidance of healthcare decomposed by gender (Table 8)

eststo clear
eststo s1: logit  health_behavior community_support_n intensity1  discrimination_ethnicity sample health_insurance age no_educ i.country $type_neighbourhood  i.asset_index i.percentage_of_roma  if female==1, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
eststo s2: logit  health_behavior community_support_n intensity1   discrimination_ethnicity sample health_insurance age no_educ    i.country $type_neighbourhood  i.asset_index i.percentage_of_roma  if female==0, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
esttab s1 s2 using Tab8.tex , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity  sample intensity1 ) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of avoidance of healthcare decomposed by gender")  mtitles("Female" "Male")

***c) Logistic regression for avoidance of healthcare by subsample (table 9)
eststo a: logit  health_behavior community_support_n discrimination_ethnicity health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 if sample==0 , vce(cluster municipality_n) 
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo b: logit  health_behavior community_support_n discrimination_ethnicity  health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 if sample==1 , vce(cluster municipality_n) 
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes" 

esttab a b using Tab9.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for avoidance of healthcare by subsample") mtitles("Non-Roma" "Roma")

save dataDEF, replace


*** ------------- IPW and Propensity Score -------------------***

*A)    ACCESS TO HEALTHCARE SERVICES

*-------------------------FULL SAMPLE---------------------------*



clear all 
use dataDEF
*Let's apply IPW for access to healthcare services
*** we have the possibility to use two different "treatments". The treatment variable is intensity of own norms. 

** Stata does it automatically with 'teffects' command. 

eststo a1: teffects ipw (screening_initiative) (intensity1 i.country discrimination_ethnicity community_support_n female age no_educ town village capital city  i.asset_index sample, logit), vce(cluster municipality_n) osample(overlap) 
*The ATE is  -.0584197 and significant at the 1% level 
esttab a1 using Tab10.tex, keep(ATE: POmean:) replace depvar legend label nogaps se star(* 0.10 ** 0.05 *** 0.01) title("Average Treament Effect Estimation trough IPW - Full Sample")

su overlap
*The overlap assumption holds. Indeed, 'overlp' identifies observations that violate the overlap assumption 


** We can also do the same process manually, in this way it is possible to understand all the steps

logit intensity1 i.country discrimination_ethnicity community_support_n female age no_educ town village capital city  i.asset_index sample, vce(cluster municipality_n) 

*We obtain the propensity score from the logistic regression of the treatment as outcome and the covariates used for the analysis 
predict double ps if e(sample)

*We need to calculate the IPW from the propensity scores 

gen double ipw = 1.intensity1/ps + 0.intensity1/(1-ps)


reg screening_initiative intensity1 [pw=ipw]
*The ATE is   -.0583528  


*We can try to do the same by trimming the propensity scores 
drop ipw 
drop if ps<=0.1
drop if ps>=0.9 

gen double ipw = 1.intensity1/ps + 0.intensity1/(1-ps)


reg screening_initiative intensity1 [pw=ipw]
*The ATE calculated now is -.0575818


*We can use some graphs to check the distribution of the scores 

*1) Propensity scores 

*Histograms 
twoway (histogram ps if intensity1==1, color(white) lcolor(red)) (histogram ps if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Propensity Score") legend(label(1 "Treated") label(2 "Control")) name(g1) title("Logistic Propensity scores Full sample")
*kernel Density
twoway (kdensity ps if intensity1==1, color(white) lcolor(red)) (kdensity ps if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Propensity Score") legend(label(1 "Treated") label(2 "Control")) name(g2) title("Logistic Propensity scores Full sample")


*2)IPW 

*Histograms 
twoway (histogram ipw if intensity1==1, color(white) lcolor(red)) (histogram ipw if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Inverse Probability Weights") legend(label(1 "Treated") label(2 "Control")) name(g3) title("IPW Full sample")
*kernel Density
twoway (kdensity ipw if intensity1==1, color(white) lcolor(red)) (kdensity ipw if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Inverse Probability Weights") legend(label(1 "Treated") label(2 "Control")) name(g4) title("IPW Full sample")



*-------------------------BY SUB-SAMPLE---------------------------*

*Let's apply IPW for access to healthcare services BU SUBSAMPLE 
*** we have the possibility to use two different "treatments". The treatment variable is intensity of own norms. 

** Stata does it automatically with 'teffects' command. 
drop ps ipw
*Let's apply IPW for access to healthcare services
*** we have the possibility to use two different "treatments". The treatment variable is intensity of own norms. 

*If we consider the two subsamples (Roma and non-Roma) separately:
eststo a2: teffects ipw (screening_initiative) (intensity1 i.country discrimination_ethnicity community_support_n female age no_educ town village capital city  i.asset_index) if sample==0, vce(cluster municipality_n) 
eststo a3: teffects ipw (screening_initiative) (intensity1 i.country discrimination_ethnicity community_support_n female age no_educ town village capital city  i.asset_index) if sample==1, vce(cluster municipality_n) 
esttab a1 a2 a3 using Tab10.tex, keep(ATE: POmean:) replace depvar legend label nogaps se star(* 0.10 ** 0.05 *** 0.01) title("Average Treament Effect Estimation trough IPW - Full Sample") mtitles("Full sample" "Non-Roma" "Roma")
*We can see that the ATE is significant exclusively for Roma. 
*The ATE is  -.0656355 (compared to -.0584197 for the full sample) and significant at the 1% level  

*We continue the analysis only with the Roma sample
drop if sample==0 


** We can also do the same process manually, in this way it is possible to understand all the steps

logit intensity1 i.country discrimination_ethnicity community_support_n female age no_educ town village capital city  i.asset_index, vce(cluster municipality_n) 

*We obtain the propensity score from the logistic regression of the treatment as outcome and the covariates used for the analysis 
predict double ps if e(sample)

*We need to calculate the IPW from the propensity scores 

gen double ipw = 1.intensity1/ps + 0.intensity1/(1-ps)


reg screening_initiative intensity1 [pw=ipw]
*The ATE is   -.0656958  


*We can try to do the same by trimming the propensity scores 
drop ipw 
drop if ps<=0.1
drop if ps>=0.9 

gen double ipw = 1.intensity1/ps + 0.intensity1/(1-ps)


reg screening_initiative intensity1 [pw=ipw]
*The ATE calculated now is  -.0642839


*We can use some graphs to check the distribution of the scores 

*1) Propensity scores 

*Histograms 
twoway (histogram ps if intensity1==1, color(white) lcolor(red)) (histogram ps if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Propensity Score") legend(label(1 "Treated") label(2 "Control")) name(g5) title("Logistic Propensity scores Roma subsample")
*kernel Density
twoway (kdensity ps if intensity1==1, color(white) lcolor(red)) (kdensity ps if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Propensity Score") legend(label(1 "Treated") label(2 "Control")) name(g6) title("Logistic Propensity scores Roma subsample")


*2)IPW 

*Histograms 
twoway (histogram ipw if intensity1==1, color(white) lcolor(red)) (histogram ipw if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Inverse Probability Weights") legend(label(1 "Treated") label(2 "Control")) name(g7) title("IPW Roma subsample")
*kernel Density
twoway (kdensity ipw if intensity1==1, color(white) lcolor(red)) (kdensity ipw if intensity1==0, color(white)  lcolor(blue)), ytitle("Density") xtitle("Inverse Probability Weights") legend(label(1 "Treated") label(2 "Control")) name(g8) title("IPW Roma subsample")


*We want to combine the graphs 
graph combine g1 g3 g5 g7, ycommon title("Histogram of the Diagnostic of the matching for Roma subsample")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig9.png", as(png) name("Graph") replace
graph combine g2 g4 g6 g8, ycommon title("Kernel Density of the Diagnostic of the matching for Roma subsample")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig10.png", as(png) name("Graph") replace





