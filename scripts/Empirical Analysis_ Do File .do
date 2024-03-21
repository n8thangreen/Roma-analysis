**** -------- DESCRIPTIVE STATISTICS -------
clear all
*Create a local directory (change this in order to execute the files)
local dir "/Users/antoniomarchitto/Desktop/DATASET/mydata"
cd `dir'
use dataDEF.dta

*First table - Percentage of Roma for each country
label define sample 0 "Non-Roma" 1 "Roma"
label values sample sample
asdoc tab sample country, col label replace title(Table 1: Sample size and Roma composition, by country)


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


graph bar screening_initiative_roma screening_initiative_non, over(country) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ebblue)) bar(2,color(eltgreen )) title("Access to healthcare services")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig1a.png", as(png) name("Graph") replace

*** We can draw a boxplot with interval of confidence
ciplot screening_initiative_roma screening_initiative_non, by(country) inclusive title("Access to healthcare services") xtitle("Country", size(small)) 


** 2) In a second step, the dependent variable of interest is related to unmet medical needs. The variable health_behavior is binary, takes the value of 1 if  the individual, at least once in the last 12 months, needed to consult a doctor but did not, and 0 otherwise.


gen health_behavior_roma=1 if health_behavior==1 & sample==1
replace health_behavior_roma=0 if health_behavior==0 & sample==1
label var health_behavior_roma "Roma subsample"
gen health_behavior_non=1 if health_behavior==1 & sample==0
replace health_behavior_non=0 if health_behavior==0 & sample==0
label var health_behavior_non "Non-Roma subsample"
label var health_behavior "Unmet needs of medical care"

graph bar health_behavior_roma health_behavior_non,over(country) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ebblue)) bar(2,color(eltgreen)) title("Healthcare Avoidance")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig1b.png", as(png) name("Graph") replace

*** We can draw a boxplot with interval of confidence
ciplot health_behavior_roma health_behavior_non, by(country) inclusive title("Healthcare Avoidance") xtitle("Country", size(small)) 






** Presentation of EXPLANATORY VARIABLES

***1) The variable Community support, measures how many of the following sources of support are listed by the respondent:  support from a friend, a relative, an employer, a rich man in the community, a social assistance institution, a bank, a microfinance institution, a local NGO.

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

graph bar screening_initiative_roma screening_initiative_non, over(community_support) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Outcome: access to healthcare services", size(textsizestyle)) b1title("n° sources of community support")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig2a.png", as(png) name("Graph") replace 
graph bar health_behavior_roma health_behavior_non, over(community_support) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Outcome: healthcare avoidance", size(textsizestyle)) b1title("n° sources of community support")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig2b.png", as(png) name("Graph") replace 

****Creation of variable INTENSITY OF IDENTITY
*** This variables measures the strenght of acceptability of behaviors that go against the common rules of the mainstream society

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

**The variabile intensity1 takes the value 1 if the intensity of own norms is hogher than the average. Intensity2 takes the value 1 if the intensity of own norms if higher than the median. 

gen intensity2=1 if own_norms<median_ownorms
replace intensity2=0 if intensity2==.
gen intensity1=1 if own_norms<mean_ownorms
replace intensity1=0 if intensity1==.


graph bar screening_initiative_roma screening_initiative_non, over(intensity1) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Outcome: access to healthcare services", size(textsizestyle)) b1title("Following own social norms (based on the median)")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig3a.png", as(png) name("Graph") replace 
graph bar screening_initiative_roma screening_initiative_non, over(intensity2) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Outcome: access to healthcare services", size(textsizestyle)) b1title("Following own social norms (based on the mean)")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig3b.png", as(png) name("Graph") replace 


graph bar health_behavior_roma screening_initiative_non, over(intensity1) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Outcome: access to healthcare services", size(textsizestyle)) b1title("Following own social norms (based on the median)")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig4a.png", as(png) name("Graph") replace 
graph bar health_behavior_roma screening_initiative_non, over(intensity2) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Outcome: access to healthcare services", size(textsizestyle)) b1title("Following own social norms (based on the mean)")
graph export "/Users/antoniomarchitto/Desktop/DATASET/Fig4b.png", as(png) name("Graph") replace 

label var intensity1 "Intensity of Social Norms"

ciplot intensity1 screening_initiative health_behavior, by(sample) title("CI for the main variables by subsample")



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


*Now we create Table 3 "Characteristics of the respondents"

label var age "Age"
label var unemployed "Unemployed"
label var health_insurance "Health insurance"
label var good_health "Self-reported good health"
label var health_behavior "Avoidance of medical screening"
label var female "Female"
label var sample "Roma"


tab educ_level
asdoc sum female age i.educ_level i.health_self health_insurance i.asset_index if sample==1, label 

asdoc sum female age i.educ_level i.health_self health_insurance i.asset_index if sample==0, label 






*Let's apply IPW for access to healthcare services
gen community=1 if community_support_n>0
replace community=0 if community==.
by sample, sort : teffects ipw (screening_initiative) (intensity1 i.country discrimination_ethnicity health_insurance female age no_educ i.health_self town village capital city unregulated_area i.asset_index)

predict ps pr
twoway scatter community screening_initiative || scatter ps screening_initiative
graph bar ps pr, over(sample)
scatter ps pr
*Let's apply it for healthcare avoidance
by sample, sort : teffects ipw (health_behavior) (community i.country discrimination_ethnicity health_insurance female age no_educ i.health_self town village capital city unregulated_area i.asset_index)


*** Propensity score matching with common support (TRY WITH REVERTING BETWEEN ROMA AND NON ROMA)

gen nonroma=1 if sample==0
replace nonroma=0 if sample==1
global treatment intensity1
global ylist screening_initiative
global xlist discrimination_ethnicity health_insurance female age no_educ  health_self  country $type_neighbourhood   asset_index percentage_of_roma
bysort $treatment: su $ylist $xlist 
pscore $treatment $xlist, pscore(myscore) blockid(myblock) comsup 

*** Matching methods 
*** Nearest neighbor matching 
attnd $ylist $treatment $xlist, pscore(myscore) comsup boot dots
*** Radius matching 
attr $ylist $treatment $xlist, pscore(myscore) comsup  dots radius(0,1)
*** Kernel matching 
attk $ylist $treatment $xlist, pscore(myscore) comsup boot dots
*** Stratification matching
atts $ylist $treatment $xlist, pscore(myscore) comsup blockid(myblock) boot dots




*** --------------- EMPIRICAL ANALYSIS ------------------------

*1) Occurence of health services 

*** a) Logistic regression for occurrence of healthcare (Table 4) and community support
global type_neighbourhood town village capital city unregulated_area
eststo clear


eststo a: logit screening_initiative community_support_n sample discrimination_ethnicity age no_educ female  health_insurance i.country i.asset_index, vce(cluster municipality_n) or
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"



eststo b:  logit  screening_initiative community_support_n intensity1 discrimination_ethnicity sample health_insurance female age no_educ  i.health_self  i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"




eststo c: logit  screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: logit  screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma intensity1 , vce(cluster municipality_n)
 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab a b c d using Tab1.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity sample female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for occurence of healthcare") nomtitles

**** Logistic regression for occurence of healthcare by subsample.
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


*** b) Logisitic regression for occurrence of healthcare DECOMPOSED BY DECISION

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

esttab d1 e f g , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity sample intensity1) stats(asset country neighbour health N, labels("Baseline controls""Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by decision")  mtitles("Anyone's initiative" "Own initiative" "Own Initiative" "Doctor's initiative" "Screening program")


*** c) Logistic regression of occurrence of healthcare decomposed by gender

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

esttab r0 r1 r2 r3 using Tab4.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n discrimination_ethnicity sample community_support_ni intensity1) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by gender")  mtitles("Female" "Female" "Male" "Male")

*Difference between males and females and Roma and non Roma (Table 6) 

eststo clear

eststo r0: logit initiative_screening2 community_support_n  discrimination_ethnicity intensity1  health_insurance  age no_educ  i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 & sample==0 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r1: logit  initiative_screening2 community_support_n discrimination_ethnicity intensity1 health_insurance  age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 & sample==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r2: logit  initiative_screening2 community_support_n discrimination_ethnicity  health_insurance intensity1 age no_educ  i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 & sample==0 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r3: logit  initiative_screening2 community_support_n discrimination_ethnicity intensity1  health_insurance  age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 & sample==1, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab r0 r1 r2 r3, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n discrimination_ethnicity intensity1) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by gender")  mtitles("Female & Non-Roma" "Female & Roma " "Male & Non-Roma" "Male & Roma")

*** 2) Results for Healthcare avoidance 
*a) Logistic regression for avoidance of healthcare (Table 7)

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

esttab a b c using Tab5.tex , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity sample female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for avoidance of healthcare") nomtitles


***b) Logistic regression for avoidance of healthcare decomposed by gender 

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
esttab s1 s2 , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity  sample intensity1 ) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of avoidance of healthcare decomposed by gender")  mtitles("Female" "Male")

**** Logistic regression for avoidance of healthcare by subsample.
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

esttab a b, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity female age no_educ health_insurance intensity1) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for avoidance of healthcare by subsample") mtitles("Non-Roma" "Roma")


*** ------------- IPW -------------------***


*Let's apply IPW for access to healthcare services
gen community=1 if community_support_n>0
replace community=0 if community==.
by sample, sort : teffects ipw (screening_initiative) (community i.country discrimination_ethnicity health_insurance female age no_educ i.health_self town village capital city unregulated_area i.asset_index)
predict ps

*Let's apply it for healthcare avoidance
by sample, sort : teffects ipw (health_behavior) (community i.country discrimination_ethnicity health_insurance female age no_educ i.health_self town village capital city unregulated_area i.asset_index)


*** Propensity score matching with common support (TRY WITH REVERTING BETWEEN ROMA AND NON ROMA)

gen nonroma=1 if sample==0
replace nonroma=0 if sample==1
global treatment community
global ylist screening_initiative
global xlist discrimination_ethnicity health_insurance female age no_educ  health_self  country $type_neighbourhood   asset_index percentage_of_roma
bysort $treatment: su $ylist $xlist 
pscore $treatment $xlist if sample==1, pscore(myscore) blockid(myblock) comsup 

*** Matching methods 
*** Nearest neighbor matching 
attnd $ylist $treatment $xlist, pscore(myscore) comsup boot dots
*** Radius matching 
attr $ylist $treatment $xlist, pscore(myscore) comsup  dots radius(0,1)
*** Kernel matching 
attk $ylist $treatment $xlist, pscore(myscore) comsup boot dots
*** Stratification matching
atts $ylist $treatment $xlist, pscore(myscore) comsup blockid(myblock) boot dots


***         ROBUSTNESS TO OMITTED VARIABLE BIAS.      *****

*Oster Strategy 

*To create Table 9 we must follow the strategy firstly for Screening initiative and then for health behavior. 
* a) For screening initiative, we calculate the delta associated to the variable "Community support" and the interaction term "Community support x Roma"
*FULL MODEL is:

reg screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

gen  beta3=_b[community_support_ni]
gen beta2=_b[community_support_n]
gen R3= e(r2)  

*restricted MODEL is: 

reg screening_initiative community_support_n sample community_support_ni, vce(cluster municipality_n)
gen  beta4=_b[community_support_ni]
gen R2= e(r2) 
gen  beta1=_b[community_support_n]

*We then calculate the delta 
gen delta_community_ni=(beta3/(beta4-beta3))*((R3-R2)/(1.3*R3-R3)) 
gen delta_community=(beta2/(beta1-beta2))*((R3-R2)/(1.3*R3-R3)) 

* b) For Healthcare avoidance we calculate the delta associated to Discrimination for its ethnicity

reg  health_behavior community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

gen  beta5=_b[discrimination_ethnicity]
gen R4= e(r2)  
 
reg health_behavior discrimination_ethnicity sample, vce(cluster municipality_n)
gen beta6=_b[discrimination_ethnicity]
gen R5=e(r2)
gen delta_discrimination=(beta5/(beta6-beta5))*((R4-R5)/(1.3*R4-R4)) 


*Create Table 9 
eststo clear
eststo a: reg screening_initiative community_support_n sample community_support_ni, vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "No"
estadd local country "No"
estadd local neighbour "No"
estadd local health "No"
eststo b: reg screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
estadd local delta "-10.7820"
estadd local delta2 "-17.7536"

eststo c: reg health_behavior discrimination_ethnicity, vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "No"
estadd local country "No"
estadd local neighbour "No"
estadd local health "No"

eststo d: reg  health_behavior community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
estadd local delta "15.582757"
esttab a b c d, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n   community_support_ni discrimination_ethnicity  sample female age no_educ health_insurance) stats( base asset country neighbour health N r2 delta delta2 , labels("Baseline Controls""Asset-Index" "Country FE" "Type of neighbourhood" "Health conditions" "Observations" "$R^2$" "$\hat{\delta}$" "$\hat{\delta$}")) title("Robustness check on Omitted variable bias") mtitles("Restricted" "Full" "Restricted" "Full") mgroups("Screening initiative" "Healthcare avoidance", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) alignment(D{.}{.}{-1}) nonumber booktabs page(dcolumn)


******.      ------ APPENDIX -------

* Table 12: Linear probability model for occurrence of healthcare
eststo clear


eststo a: reg screening_initiative community_support_n  sample   discrimination_ethnicity age no_educ female health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg screening_initiative community_support_n  discrimination_ethnicity sample health_insurance female age no_educ   i.health_self    i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: reg  screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ    i.health_self      i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)


estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



esttab a b c, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n    community_support_ni discrimination_ethnicity sample female age no_educ health_insurance ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear Probability model for occurence of healthcare") nomtitles


*Table 13: Linear probability model for occurrence of healthcare

eststo clear
eststo a: reg health_behavior community_support_n  sample   discrimination_ethnicity age no_educ female  health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg  health_behavior community_support_n    discrimination_ethnicity sample health_insurance female age no_educ    i.health_self   i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: reg  health_behavior community_support_n   discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ   i.health_self   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab a b c, replace depvar  legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear probability model for avoidance of healthcare") nomtitles

* table 14: Comparing marginal effects of the probability model and logit 

eststo clear 
logit screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
eststo c: margins, dydx (*) post 
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: reg screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

logit  health_behavior community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
eststo a: margins, dydx (*) post 
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo b: reg  health_behavior community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab  c d a b, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity sample age female no_educ health_insurance  ) stats( base asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Marginal effects and Linear Probability Model results") mtitles("Marginal Effects" "LPM" "Marginal Effects" "LPM") mgroups("Screening Initiative" "Healthcare Avoidance", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) alignment(D{.}{.}{-1}) nonumber 


*Table 15:  Variance inflation factor 
reg  screening_initiative community_support_n discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

asdoc vif
save dataDEF, replace



