**** -------- DESCRIPTIVE STATISTICS -------
clear all
capture: log close 
// cd "/Users/antoniomarchitto/Desktop/DATASET/data"
use dataDEF.dta

*First table - Percentage of Roma for each country
asdoc tab sample country, col

* Presentation of DEPENDENT VARIABLES. 
**1) The first dependent variable is "screening initiative", which measures the occurrence of medical services received by the respondent. The survey asks the respondent to declare if in the previous 12  months the following medical check-ups  have been  part of any consultation: a dental check-up, an x-ray, ultrasound or other scan, a cholesterol test, an heart check-up. The dependent variable for the analysis  is  binary and takes the value 1 if the respondent listed at least one screening, and 0 otherwise.

gen screening_initiative=1 if screening>0
replace screening_initiative=0 if screening_initiative!=1
gen screening_initiative_roma=1 if screening_initiative==1 & sample==1
replace screening_initiative_roma=0 if screening_initiative==0 & sample==1
gen screening_initiative_non=1 if screening_initiative==1 & sample==2
replace screening_initiative_non=0 if screening_initiative==0 & sample==2
label var screening_initiative "Screening initiative"

graph bar screening_initiative screening_initiative_non, over(country) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Access to healthcare services")


** 2) In a second step, the dependent variable of interest is related to unmet medical needs. The variable health_behavior is binary, takes the value of 1 if  the individual, at least once in the last 12 months, needed to consult a doctor but did not, and 0 otherwise.

tab health_behavior
gen health_behavior_roma=1 if health_behavior==1 & sample==1
replace health_behavior_roma=0 if health_behavior==0 & sample==1
gen health_behavior_non=1 if health_behavior==1 & sample==2
replace health_behavior_non=0 if health_behavior==0 & sample==2
label var health_behavior "Health-care avoidance"

graph bar health_behavior_roma health_behavior_non,over(country) legend( lab(1 "Roma") lab(2 "Non-Roma")) bar(1,color(ltblue)) bar(2,color(gs14)) title("Unmet needs of medical care")


** Presentation of EXPLANATORY VARIABLES

***1) The variable Community support, measures how many of the following sources of support are listed by the respondent:  support from a friend, a relative, an employer, a rich man in the community, a social assistance institution, a bank, a microfinance institution, a local NGO.

*** We build this summative scale variable. 
corr first_support second_support third_support

egen community_support = anycount(first_support second_support third_support), values(1 2 3 4 5 6 7 8)
tab community_support
gen community_support_n = (community_support - 0) / (3)
tab community_support_n sample
drop community_support


*** 2) The index Follow Own norms is a summative scale variable that measures how many of the following situation are always acceptable: citizen giving a bribe to achieve what she/he wants, not paying taxes that are required, official accepting a bribe in the course of their duties, stealing food if family goes hungry. 

**Before, the variables must be build assuming that they take value 1 if the situation is always acceptable and 0 otherwhise

replace citizenbribe_acceptance=. if citizenbribe_acceptance>3
replace citizenbribe_acceptance=0 if citizenbribe_acceptance==3 | citizenbribe_acceptance==2


replace notaxes_acceptance=. if notaxes_acceptance>3
replace notaxes_acceptance=0 if notaxes_acceptance==3 | notaxes_acceptance==2 


replace officialbribe_acceptance=. if officialbribe_acceptance>3
replace officialbribe_acceptance=0 if officialbribe_acceptance==3 | officialbribe_acceptance==2



replace stealingfood_acceptance=. if stealingfood_acceptance>3
replace stealingfood_acceptance=0 if stealingfood_acceptance==2 | stealingfood_acceptance==3


***Cronbach's alpha equals to 0.74. The variable has been normalized to assume values between 0 and 1.

corr citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance 
alpha citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance 

egen own_norms= anycount(citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance), values(1)

gen own_norms_n=(own_norms - 0)/4

*** 3) The third measure of community influence captures the feeling of being discriminated for its own ethnicity. The predictor Discrimination for ethnicity is binary, equal to 1 if the respondent has been felt discriminated for its own ethnicity and 0 otherwise.

tab discrimination_ethnicity sample

*** I generate Table 2: Explanatory Variables
eststo s4:  estpost ttest community_support_n own_norms_n discrimination_ethnicity , by(sample)
codebook sample

esttab s4 using c9.tex, noobs cells(" mu_1 mu_2 se") title ("Explanatory variables") collabels ("Roma" "Non-Roma" "SE") nonumber label replace


*Now I create the interaction terms for the  explanatory variables. 

gen community_support_ni= sample*community_support_n
gen own_norms_ni = sample*own_norms_n
gen discrimination_ethnicity_i= discrimination_ethnicity*sample



label var community_support_n "Community support"
label var community_support_ni "Community support x Roma"
label var own_norms_n "Follow own norms"
label var own_norms_ni "Follow own norms x Roma"
label var discrimination_ethnicity "Ethnic discrimination"
label var discrimination_ethnicity_i "Discriminated for ethnicity x Roma"

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
label var educ_years "Educational years"
label var unemployed "Unemployed"
label var food_insecurity "Food insecurity"
label var health_insurance "Health insurance"
label var good_health "Self-reported good health"
label var health_behavior "Avoidance of medical screening"
label var female "Percentage of females"
label var afford_n "Economic security"


asdoc sum female age i.educ_level i.health_self health_insurance disability food_insecurity afford_n i.asset_index if sample==1, label 

asdoc sum female age i.educ_level i.health_self health_insurance disability food_insecurity afford_n  i.asset_index if sample==0, label 

*** --------------- EMPIRICAL ANALYSIS ------------------------

*1) Occurence of health services 

*** a) Logistic regression for occurence of healthcare (Table 4)
global type_neighbourhood town village capital city unregulated_area
eststo clear


eststo a: logit screening_initiative community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) or
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



esttab a b c, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for occurence of healthcare") nomtitles

*** b) Logisitic regression for occurence of healthcare DECOMPOSED BY DECISION

*Different measures of screening_initiative (Table 5)

gen screening_initiative2=1 if screening2>0
replace screening_initiative2=0 if screening_initiative2!=1
gen screening_initiative3=1 if screening3>0
replace screening_initiative3=0 if screening_initiative3!=1
gen screening_initiative4=1 if screening4>0
replace screening_initiative4=0 if screening_initiative4!=1

label var screening_initiative2 "Screening initiative by own initiative"
label var screening_initiative3 "Screening initiative by doctor invitation"
label var screening_initiative4 "Screening initiative by screening initiative"


eststo clear
eststo d1: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo e: logit screening_initiative2 community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n i.health_self  disability  walking_healthfacility   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo f: logit screening_initiative3 community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo g: logit screening_initiative4 community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab d1 e f g, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity  own_norms_n   sample ) stats(asset country neighbour health N, labels("Baseline controls""Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by decision")  mtitles("Anyone's initiative" "Own initiative" "Doctor's initiative" "Screening program")

*** c) Logistic regression of occurrence of healthcare decomposed by gender

*Difference between males and females (Table 6)
*females have more screenings 

gen screening_initiative_f=1 if screening_f>0
replace screening_initiative_f=0 if screening_f==0
eststo clear
eststo r0: logit screening_initiative_f community_support_n  own_norms_n  discrimination_ethnicity sample  health_insurance  age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r1: logit  screening_initiative_f community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance  age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r2: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  health_insurance  age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r3: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance  age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab r0 r1 r2 r3, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity own_norms_n  sample no_educ afford_n health_insurance) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by gender")  mtitles("Female" "Female" "Male" "Male")


*** 2) Results for Healthcare avoidance 
*a) Logistic regression for avoidance of healthcare (Table 7)

eststo clear
eststo a: logit health_behavior community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab a b c, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for avoidance of healthcare") nomtitles


***b) Logistic regression for avoidance of healthcare decomposed by gender (Table 8)

eststo clear
eststo s1: logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma  if female==1, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
eststo s2: logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma  if female==0, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
esttab s1 s2 , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity own_norms_n  sample ) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by gender")  mtitles("Female" "Male")


***         ROBUSTNESS TO OMITTED VARIABLE BIAS.      *****

*Oster Strategy 

*To create Table 9 we must follow the strategy firstly for Screening initiative and then for health behavior. 
* a) For screening initiative, we calculate the delta associated to the variable "Community support" and the interaction term "Community support x Roma"
*FULL MODEL is:

reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

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

reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)

gen  beta5=_b[discrimination_ethnicity]
gen R4= e(r2)  
 
reg health_behavior discrimination_ethnicity, vce(cluster municipality_n)
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
estadd local delta "Yes"
eststo b: reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
estadd local delta "Yes"

eststo c: reg health_behavior discrimination_ethnicity, vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "No"
estadd local country "No"
estadd local neighbour "No"
estadd local health "No"
estadd local delta "Yes"
eststo d: reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
estadd local delta "Yes"
esttab a b c d, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n  community_support_ni discrimination_ethnicity  sample female age no_educ health_insurance afford_n) stats( base asset country neighbour health N r2 delta , labels("Baseline Controls""Asset-Index" "Country FE" "Type of neighbourhood" "Health conditions" "Observations" "Delta")) title("Marginal effects and Linear Probability Model results") mtitles("Restricted Regression" "Full regression" "Restricted Regression" "Full regression") mgroups(A B, pattern(1 0 1 0))


***** ADDITIONAL ROBUSTNESS CHECKS 

** 1) Alternative measures of community influence (Table 10)

gen community_support=1 if community_support_n>0
replace community_support=0 if community_support!=1
gen community_support_i=sample*community_support
label var community_support "Community support"
label var community_support_i "Community support x Roma"
label var own_norms "Own norms"
replace own_norms=1 if own_norms>0
gen own_norms_i=sample*own_norms

eststo clear

eststo c: logit  screening_initiative community_support own_norms  discrimination_ethnicity sample  community_support_i health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo d: logit  health_behavior community_support  own_norms  discrimination_ethnicity sample health_insurance female age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab c d, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support own_norms   community_support_i discrimination_ethnicity  sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Alternative measures of community influences") mtitle("Screening Initiative" "Avoidance of healthcare")


** 2) Pairwise correlation between indicators of community influence (Table 11)
corr community_support_n own_norms_n discrimination_ethnicity





******.      ------ APPENDIX -------

* Table 12: Linear probability model for occurrence of healthcare
eststo clear


eststo a: reg screening_initiative community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility   i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)


estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



esttab a b c, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear Probability model for occurence of healthcare") nomtitles


*Table 13: Linear probability model for occurrence of healthcare

eststo clear
eststo a: reg health_behavior community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab a b c, replace depvar  legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear probability model for avoidance of healthcare") nomtitles

* table 14: Comparing marginal effects of the probability model and logit 

eststo clear 
logit screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
eststo c: margins, dydx (*) post 
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
eststo a: margins, dydx (*) post 
estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo b: reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)

estadd local base "Yes"
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab  c d a b, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n community_support_ni discrimination_ethnicity sample age female no_educ afford_n health_insurance  ) stats( base asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Marginal effects and Linear Probability Model results") mtitles("Marginal Effects" "LPM" "Marginal Effects" "LPM")


*Table 15:  Variance inflation factor 
reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

asdoc vif


*----- not included into the paper ---- Regressions by country , no significant results! 



eststo clear
eststo w1: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma   if country==1 , vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"

eststo w2: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma   if country==2 , vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"

eststo w3: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma   if country==3 , vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"


eststo w4: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma   if country==4 , vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"


eststo w5: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma   if country==5 , vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"

eststo w6: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma   if country==6, vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"

esttab w1 w2 w3 w4 w5 w6 , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity  sample  ) stats( neighbour health N, labels(  "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by country")  mtitles("Serbia" "Montenegro" "Albania" "Macedonia" "Kosovo" "Bosnia-Herzegovina")
