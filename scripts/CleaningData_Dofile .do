clear all
*Create a local directory (change this in order to execute the files)
local dir "/Users/antoniomarchitto/Desktop/DATASET/mydata"
cd `dir'

*** The first step is to convert the .sav files to dta files. Each country has 6 different survey parts. 
*** I created 6 different loops (6 countries). I renamed the sav files in this way: ALB=Albania BIH=Bosnia-Herzegovina KOS=Kosovo MKD= Macedonia MNE=Montenegro SRB=Serbia. For the numbers this is the legend:
*** Module 0 - Management section ==1 , Module 1 - Hoseuhold mebers profile ==2 
*** Module 1 - Parenting techniques == 3 , Module 3 - Status of the household == 4 
*** Module 4 - Individual status and attitudes of the randomly selected respondent ==5 
*** MODULE 4 - G1 G2 sections == 6 
*In other words, ALB_1 is the Module 0 for Albania



*CREATE DATABASE
forvalues i=1/6 {
clear 
import spss using ALB_`i'.sav, case(lower)
save ALB_`i'.dta, replace
}
clear 
forvalues i=1/6 {
clear 
import spss using BIH_`i'.sav, case(lower)
save BIH_`i'.dta, replace
}
clear 
forvalues i=1/6 {
clear 
import spss using KOS_`i'.sav, case(lower)
save KOS_`i'.dta, replace
}
forvalues i=1/6 {
clear 
import spss using MKD_`i'.sav, case(lower)
save MKD_`i'.dta, replace
}
forvalues i=1/6 {
clear 
import spss using MNE_`i'.sav, case(lower)
save MNE_`i'.dta, replace
}
forvalues i=1/6 {
clear 
import spss using SRB_`i'.sav, case(lower)
save SRB_`i'.dta, replace
}

*** Now we use append to create 6 different data sets, corresponding to each of the 6 parts of the survey. Each data set containts all the 6 countries. 

* APPEND dataset  
clear 
forvalues i=1/6 {
clear 
use ALB_`i'.dta
append using BIH_`i'.dta
save data_`i'.dta, replace
}
forvalues i=1/6 {
clear 
use data_`i'.dta
append using KOS_`i'.dta
save data_`i'.dta, replace
}
forvalues i=1/6 {
clear 
use data_`i'.dta
append using MKD_`i'.dta
save data_`i'.dta, replace
}
forvalues i=1/6 {
clear 
use data_`i'.dta
append using MNE_`i'.dta
save data_`i'.dta, replace
}
forvalues i=1/6 {
clear 
use data_`i'.dta
append using SRB_`i'.dta
save data_`i'.dta, replace
}

***At the end, we have 6 different datasets, representing the 6 different modules (with all the 6 countries in each module)


*MERGE 

***Now, we are merging the obtained 6 datasets to obtain only one. Before that, some data cleaning is required.

*** REMINDER: the number of each data set corresponds to a specific module of the survey. Module 0 - Management section ==1 , Module 1 - Hoseuhold mebers profile ==2 
*** Module 1 - Parenting techniques == 3 , Module 3 - Status of the household == 4 
*** Module 4 - Individual status and attitudes of the randomly selected respondent ==5 
*** MODULE 4 - G1 G2 sections == 6 

*MODULE 0  Management Section - data_1.dta , HOUSEHOLD level.
*We rename the variables of interest and we drop the ones we won't use.
clear
use data_1.dta
rename m8 type_residence
label var type_residence "Type of Residence the Household Lives In"
rename m9 type_house
label var type_house "External evaluation of the household's dwelling"
rename m11 number_members
label var number_members "Total number of household members"
order municipality, after(komune)

**In order to obtain one municipality variable, we need to fill the gaps in the variables by using the kanton or settlement values when needed. 

gen municipality1 = municipality
replace municipality1=komune if missing(municipality1)
replace municipality1= settlement if missing(municipality1)

encode municipality1, gen(municipality_n)
order municipality_n, after(number_members)

drop m9_6_oth m10_8 m10_9 m10_10 m10_11 m11a m11b m11c m11d m12a m12a_oth m12b m12b_oth m14 m15 m16 m17 m18_1 m18_1_1_oth m18_2 m18_2_1_oth municipality_old municipality_new qarkus rrethis bashic region entity kanton area
elabel rename (*) (*_master) 

save data_1.dta, replace

*** This dataset contains 12 variables and 6760 observations

*MODULE 3 - Status of the household == data_4.dta. HOUSEHOLD LEVEL
***Again, we rename the variables of interest and we drop those that we do not need. We keep all the variables related to the migration history. I might work on them. 
clear 
use data_4
rename q1_1a livinghere_5years
label var livinghere_5years "Did you household live here, in this village/town 5 years ago?"
rename q1_1b livinghere_12months
label var livinghere_12months "Did you household live here, in this village/town 12 months ago"
rename q1_1c livinghere_6months
label var livinghere_6months "Did you household live here, in this village/town 6 months ago?"
rename q1_2  comingfromothplace
label var comingfromothplace "Did you household move here from another place?"

rename q1_8_1 transp_healthcenter 
label var transp_healthcenter "What transportation do you most often use to go to the primary health center?"
replace transp_healthcenter=. if transp_healthcenter>5
egen walking_healthfacility= anycount(transp_healthcenter), value(1)
replace walking_healthfacility=. if transp_healthcenter==.
label var walking_healthfacility "Do you walk to go to the primary health center?"
rename q3_2 number_rooms
label var number_rooms "How many rooms does your household have int he dwelling you currently occupy?"
rename q3_3 square_meters
label var square_meters "How many square meters in total is the size of your current dwelling?"
rename q3_4 owner_house
label var  owner_house " Who is the owner of the dwelling in which you live?"

** The next variables are related to the possession of different items
rename q3_6_1 radio
rename q3_6_2 tv
rename q3_6_3 bike
rename q3_6_4 car
rename q3_6_5 horse
rename q3_6_6 computer
rename q3_6_7 internet
rename q3_6_8 phone
rename q3_6_9 washingmachine
rename q3_6_10 bed_foreach
rename q3_6_11 books30
rename q3_6_12 powergenerator


*The following variables related to the possession of items will allow to create an asset index for each household

gen kitchen=1 if q3_9a==1
replace kitchen=0 if q3_9a==2
gen piped=1 if q3_9b==1
replace piped=0 if q3_9b==2
gen toilet=1 if q3_9c==1
replace toilet=0 if q3_9c==2
gen wastewater=1 if q3_9e==1
replace wastewater=0 if q3_9e==2
gen bathroom=1 if q3_9f==1
replace bathroom=0 if q3_9f==2
gen electricity=1 if q3_9g==1
replace electricity=0 if q3_9g==2
gen heating=1 if q3_9h==1
replace heating=0 if q3_9h==2


drop settlement type region percentage_of_roma entity kanton municipality area municipality_old municipality_new komune qarkus rrethis bashic  q1_4_20_oth q1_5d q1_5h q1_5l q1_6 q1_8_3 q1_8a_3 q1_8_8 q1_8a_8 q1_9_95_oth q1_10_3 q1_10_95_oth q2_1a q2_1b q2_1c q2_1d q2_1e q2_1f q2_1_oth q2_2 q2_2a q2_3 q2_4 q2_5 q2_6_1 q2_6_2 q2_6_3 q2_6_4 q2_6_5 q2_6_6 q2_6_7 q2_6_oth g1 g1_1_1 g1_1_2 g1_1_3 g1_1_4 g1_1_5 g1_1_6 g1_1_7 g1_1_8 g1_1_8_oth g1_2_1 g1_3_1 g1_4_1 g1_5_1_9999 g1_5_1_1 g1_5_1_2 g1_5_1_3 g1_5_1_4 g1_5_1_5 g1_5_1_6 g1_5_1_7 g1_5_1_8 g1_5_1_9 g1_5_1_10 g1_2_2 g1_3_2 g1_4_2 g1_5_2_9999 g1_5_2_1 g1_5_2_2 g1_5_2_3 g1_5_2_4 g1_5_2_5 g1_5_2_6 g1_5_2_7 g1_5_2_8 g1_5_2_9 g1_5_2_10 g1_2_3 g1_3_3 g1_4_3 g1_5_3_9999 g1_5_3_1 g1_5_3_2 g1_5_3_3 g1_5_3_4 g1_5_3_5 g1_5_3_6 g1_5_3_7 g1_5_3_8 g1_5_3_9 g1_5_3_10 g1_2_4 g1_3_4 g1_4_4 g1_5_4_9999 g1_5_4_1 g1_5_4_2 g1_5_4_3 g1_5_4_4 g1_5_4_5 g1_5_4_6 g1_5_4_7 g1_5_4_8 g1_5_4_9 g1_5_4_10 g1_2_5 g1_3_5 g1_4_5 g1_5_5_9999 g1_5_5_1 g1_5_5_2 g1_5_5_3 g1_5_5_4 g1_5_5_5 g1_5_5_6 g1_5_5_7 g1_5_5_8 g1_5_5_9 g1_5_5_10 g1_2_6 g1_3_6 g1_4_6 g1_5_6_9999 g1_5_6_1 g1_5_6_2 g1_5_6_3 g1_5_6_4 g1_5_6_5 g1_5_6_6 g1_5_6_7 g1_5_6_8 g1_5_6_9 g1_5_6_10 g1_2_7 g1_3_7 g1_4_7 g1_5_7_9999 g1_5_7_1 g1_5_7_2 g1_5_7_3 g1_5_7_4 g1_5_7_5 g1_5_7_6 g1_5_7_7 g1_5_7_8 g1_5_7_9 g1_5_7_10 g1_2_8 g1_3_8 g1_4_8 g1_5_8_9999 g1_5_8_1 g1_5_8_2 g1_5_8_3 g1_5_8_4 g1_5_8_5 g1_5_8_6 g1_5_8_7 g1_5_8_8 g1_5_8_9 g1_5_8_10 g2_1_3 g2_1_4 g2_1_5 g2_2_1 g2_3_1 g2_4_1_9999 g2_4_1_1 g2_4_1_2 g2_4_1_3 g2_4_1_4 g2_4_1_5 g2_4_1_6 g2_4_1_7 g2_4_1_8 g2_4_1_9 g2_4_1_10 g2_2_2 g2_3_2 g2_4_2_9999 g2_4_2_1 g2_4_2_2 g2_4_2_3 g2_4_2_4 g2_4_2_5 g2_4_2_6 g2_4_2_7 g2_4_2_8 g2_4_2_9 g2_4_2_10 g2_2_3 g2_3_3 g2_4_3_9999 g2_4_3_1 g2_4_3_2 g2_4_3_3 g2_4_3_4 g2_4_3_5 g2_4_3_6 g2_4_3_7 g2_4_3_8 g2_4_3_9 g2_4_3_10 g2_2_4 g2_3_4 g2_4_4_9999 g2_4_4_1 g2_4_4_2 g2_4_4_3 g2_4_4_4 g2_4_4_5 g2_4_4_6 g2_4_4_7 g2_4_4_8 g2_4_4_9 g2_4_4_10 g2_2_5 g2_3_5 g2_4_5_9999 g2_4_5_1 g2_4_5_2 g2_4_5_3 g2_4_5_4 g2_4_5_5 g2_4_5_6 g2_4_5_7 g2_4_5_8 g2_4_5_9 g2_4_5_10 g3_1_3 g3_1_4 g3_1_5 g3_2_1 g3_3_1 g3_4_1_9999 g3_4_1_1 g3_4_1_2 g3_4_1_3 g3_4_1_4 g3_4_1_5 g3_4_1_6 g3_4_1_7 g3_4_1_8 g3_4_1_9 g3_4_1_10 g3_2_2 g3_3_2 g3_4_2_9999 g3_4_2_1 g3_4_2_2 g3_4_2_3 g3_4_2_4 g3_4_2_5 g3_4_2_6 g3_4_2_7 g3_4_2_8 g3_4_2_9 g3_4_2_10 g3_2_3 g3_3_3 g3_4_3_9999 g3_4_3_1 g3_4_3_2 g3_4_3_3 g3_4_3_4 g3_4_3_5 g3_4_3_6 g3_4_3_7 g3_4_3_8 g3_4_3_9 g3_4_3_10 g3_2_4 g3_3_4 g3_4_4_9999 g3_4_4_1 g3_4_4_2 g3_4_4_3 g3_4_4_4 g3_4_4_5 g3_4_4_6 g3_4_4_7 g3_4_4_8 g3_4_4_9 g3_4_4_10 g3_2_5 g3_3_5 g3_4_5_9999 g3_4_5_1 g3_4_5_2 g3_4_5_3 g3_4_5_4 g3_4_5_5 g3_4_5_6 g3_4_5_7 g3_4_5_8 g3_4_5_9 g3_4_5_10 g4_1_3 g4_1_4 g4_1_5 g4_1_6 g4_1_7 g4_1_8 g4_2_1 g4_3_1 g4_2_2 g4_3_2 g4_2_3 g4_3_3 g4_2_4 g4_3_4 g4_2_5 g4_3_5 g3_2_6 g3_3_6 g3_2_7 g3_3_7 g3_2_8 g3_3_8 g6_1 g6_2 g7_1 g7_2 g9 g9_1 g9_2 g10 g10_1 g10_2 g12 q3_1 q3_4_95_oth q3_4_clan q3_8 q3_8_95_oth  q3_10 q3_10_95_oth q3_11 q3_11_95_oth q3_12a q3_12b q3_12c q3_12d q3_12e q3_12f q3_12g q3_12h q3_12i q3_13a_1 q3_13a_2 q3_13a_3 q3_13b_1 q3_13b_2 q3_13b_3 q3_13c_1 q3_13c_2 q3_13c_3 q3_13d_1 q3_13d_2 q3_13d_3 q3_13e_1 q3_13e_2 q3_13e_3 q3_13f_1 q3_13f_2 q3_13f_3 q3_13g_1 q3_13g_2 q3_13g_3 q3_13h_1 q3_13h_2 q3_13h_3 q3_13i_1 q3_13i_2 q3_13i_3 q3_8 q3_8_95_oth  q3_10 q3_10_95_oth q3_11 q3_11_95_oth q3_12a q3_12b q3_12c q3_12d q3_12e q3_12f q3_12g q3_12h q3_12i q3_13a_1 q3_13a_2 q3_13a_3 q3_13b_1 q3_13b_2 q3_13b_3 q3_13c_1 q3_13c_2 q3_13c_3 q3_13d_1 q3_13d_2 q3_13d_3 q3_13e_1 q3_13e_2 q3_13e_3 q3_13f_1 q3_13f_2 q3_13f_3 q3_13g_1 q3_13g_2 q3_13g_3 q3_13h_1 q3_13h_2 q3_13h_3 q3_13i_1 q3_13i_2 q3_13i_3 q3_9a q3_9b q3_9c q3_9d q3_9e q3_9f q3_9g q3_9h q1_5a q1_5b q1_5c q1_5e q1_5f q1_5g q1_5i q1_5j q1_5k q1_8a_1 q1_8_2 q1_8a_2 q1_8_4 q1_8a_4 q1_8_5 q1_8a_5 q1_8_6 q1_8a_6 q1_8_7 q1_8a_7 q1_9 q1_10_1 q1_10_2 q1_11a q1_11b q1_11c q1_11d q1_11e g2 g2_1_1 g2_1_2 g3 g3_1_1 g3_1_2 g4 g4_1_1 g4_1_2 g6 g7 q3_5 q1_3a q1_3b q1_3b_95_oth q1_4_1 q1_4_2 q1_4_3 q3_7_1 q3_7_2 q3_7_3 q3_7_4 q3_7_4 q3_7_5 q3_7_6

elabel rename (*) (*_master2)
save data_4.dta, replace

**This dataset, after the cleaning, contains 35 variables and 6760 obs. 


*HOUSEHOLD AND HOUSEHOLD MEMBERS PROFILES MODULE 1 data_2.dta. This dataset is at the individual level. 
*General characteristics variables 
clear
use data_2.dta
rename a1 sex
label de sex 1 "Male" 2 "Female"
label var sex "Gender"
rename a2 age
rename a3 role
rename a4 marital
rename a5 age_marriage
rename a6 ethnicity
rename a7 religion
rename a7_95_oth religion_other
rename a8 activity

*For the educational level
rename a9 educ_level
replace educ_level=. if educ_level>15
** We can create two variables related to education, one that selects only 5 different categories and not 15, the second variable is a binary variable that takes 1 if the educational level correponds to no formal education
gen education="No formal education" if educ_level==1
replace education="Incomplete primary" if educ_level==2
replace education="Completed primary" if educ_level==3 | educ_level==4 | educ_level==5 | educ_level==6
replace education="Completed secondary" if educ_level>6 & educ_level<13 
replace education="More than secondary" if educ_level>12 & educ_level<16

la de educ 1 "No formal education" 2 "Incomplete primary" 3 "Completed primary" 4 "Completed secondary" 5 "More than secondary"
encode education, gen(educ)  
label var educ "Educational level"
label list educ

gen no_educ=1 if educ_level==1
replace no_educ=0 if educ_level>1 & educ_level!=.
label var no_educ "No education"

** The next set of variables are related to the migration status. It might be interesting to work with them, but the current analysis do not take them into account. 
rename a12 birth_country
rename a12br birth_registration
rename a12br1 birth_registration_place
rename a13_1 id_card1
rename a13_2 passport1
rename a13_3 temporary_residence_card1
rename a13_4 permament_residence_card1
rename a15idp idp
rename a15r refugee

*Health section 

*Health_self is a self-assessement of health conditions
rename c1 health_self
tab health_self
replace health_self=. if health_self>5 
gen good_health=1 if health_self==4 | health_self==5
replace good_health=0 if health_self!=4 & health_self!=5 & health_self!=.
label var good_health "Self-reported good or very good health"


tab c3
*The survey gives the possibility to state if the possession of health insurance is in the respondent's own name or through other members of the household. 
*** For the purpose of this research we are interested only on the possession of health insurance, despite the way. 
gen health_insurance=1 if c3==1 | c3==2
replace health_insurance=0 if c3==3
la val health_insurance health_insurance
label def health_insurance 0 "No" 1 "Yes"
label var health_insurance "Health insurance"
rename c_wg_1 disability
replace disability=. if disability>2


*Employement 
rename e2 paid_work
gen unemployed=1 if paid_work==2 & age>16
replace unemployed=0 if paid_work==1 & age>16
label var unemployed "Unemployed"

drop a6_95_oth a8_95_oth ec2_2 ec2_3 ec2_4 ec2_5 ec2_6 ec2_7 ec2_8 ec2_9 ec2_10 ec2_11 ec2_95 ec5_1 ec5_2 ec5_3 ec6_1 ec6_2 ec6_3 ec6_4 ec6_5 ec6_5others ec10 ec11 a11c3_cou_95_oth a12_95_oth a12br2 a14_1_1 a14_1_2 a14_1_4 a14_1_6 a14_1_7 a14_1_9 a14_1_10 a14_1_11 a14_1_12 a14_1_13 a14_1_14 a14_1_18 a14_1_20 a14_1_21 a14_1_22 a14_1_23 a14_1_24 a14_1_25 a14_1_26 a14_1_95 a14_1_888998 a14_1_95_oth a14_2_1 a14_2_2 a14_2_4 a14_2_6 a14_2_7 a14_2_9 a14_2_10 a14_2_11 a14_2_12 a14_2_13 a14_2_14 a14_2_18 a14_2_20 a14_2_21 a14_2_22 a14_2_23 a14_2_24 a14_2_25 a14_2_26 a14_2_95 a14_2_888998 a14_2_95_oth a14_3_1 a14_3_2 a14_3_4 a14_3_6 a14_3_7 a14_3_9 a14_3_10 a14_3_11 a14_3_12 a14_3_13 a14_3_14 a14_3_18 a14_3_20 a14_3_21 a14_3_22 a14_3_23 a14_3_24 a14_3_25 a14_3_26 a14_3_95 a14_3_888998 a14_3_95_oth a14_4_1 a14_4_2 a14_4_4 a14_4_6 a14_4_7 a14_4_9 a14_4_10 a14_4_11 a14_4_12 a14_4_13 a14_4_14 a14_4_18 a14_4_20 a14_4_21 a14_4_22 a14_4_23 a14_4_24 a14_4_25 a14_4_26 a14_4_95 a14_4_888998 a14_4_95_oth a12br1_cou a12br1_cou_95_oth b2_95_oth b3 b4 b4_6_oth e3 e11_3 e11_4 e11_5 e11_95 e11_888998 e11_95_oth e14_95_oth e15_95_oth f1 f2 f2a f3d f3w f4 f5 f6 r0 r1 r1_95_oth r2_m r2_y r3 r4_m r4_y r5 r6_1 r6_2 r6_3 r7 r7_95_oth r8_1 r8_2 r8_3 r8_4 r8_5 r8_888996 r9 r10_1 r10_2 r10_3 r10_4 r10_888996 r11_1 r11_2 r11_3 r12 r13 r13_95_oth entity kanton municipality area municipality_old municipality_new komune qarkus rrethis bashic settlement type region percentage_of_roma religion_other b5 a10_b7 a11_b8 ec2_1 a11c a11c2 a11c3 a11c3_cou b1 b2 b10 b11 c_wg_2_1 c_wg_2_2 c_wg_2_3 c_wg_2_4 c_wg_2_5 c_wg_2_6 c_wg_2_95 c_wg_2_888998 c_wg_3 e11_1 e11_2 a6_95_oth a8_95_oth e12_year e13 e4 e5 e5a e6 e7 e7a e8 e9 e9_2 e10 e14 e15 educ_level education c3

elabel rename (*) (*_master3)
save data_2.dta, replace

*** This dataset, after the cleaning, contains 30 variables and 27205 obs. 

*MODULE 4: individual status and attitudes of the randomly selected respondent, data_5.dta. 
clear
use data_5.dta

rename b1 health_behavior
label var health_behavior "Healthcare avoidance"
*Now, the dependent variable "health behavior" takes value 1 and 2. We want it to take values 1 and 0
replace health_behavior=0 if health_behavior==2
replace health_behavior=1 if health_behavior==1
replace health_behavior=. if health_behavior!=0 & health_behavior!=1


*** For the different medical screenings there is a distinguish between a screening that has been made by the respondent's initiative, by doctor's initiative, by a screening program. 
*** For all the following screening variables, value=1 if states for own initiative, value=2 for doctor's initiative and value=3 for a screening program. The variable takes value 4 if a screening has not been done.

rename b3_a dental_screening
rename b3_b xray_screening
rename b3_c cholesterol_screening
rename b3_d heart_screening


global screening dental_screening xray_screening cholesterol_screening heart_screening 


*For each of the different screenings, we want to create 4 variables, differentiating the different sources of decisions. 

local x $screening
foreach var of varlist `x'* {
replace `var'=. if `var'>4
gen `var'2=1 if `var'==1
replace `var'2=0 if `var'==2 |`var'==3 | `var'==4
gen `var'3=1 if `var'==2
replace `var'3=0 if `var'==1 |`var'==3 | `var'==4
gen `var'4=1 if `var'==3
replace `var'4=0 if `var'==1 |`var'==2 | `var'==4
}

*We want to create 4 different variables. "Screening" describes if the respondent took a medical screening, independently from the source of decision. "Screening2" describes if the respondent took a screening from its own initiative. "Screening3" describes if the respondent took a screening because the doctor prescribed it. "Screening4" describes if the respondent took a screening in the presence of a screening program.  

*For the missing values, the cumulative variable is missing if all the different screenings are missing at the same time. 

egen screening= anycount(dental_screening xray_screening cholesterol_screening heart_screening), values(1 2 3)
replace screening=. if dental_screening==. & xray_screening==. & cholesterol_screening==. & heart_screening==. 
label var screening "Access to health services despite the source"

egen screening2= anycount(dental_screening2 xray_screening2 cholesterol_screening2 heart_screening2), values(1)
replace screening2=. if dental_screening2==. & xray_screening2==. & cholesterol_screening2==. & heart_screening2==. 
label var screening2 "Access to health services by own initiative"

egen screening3= anycount(dental_screening3 xray_screening3 cholesterol_screening3 heart_screening3), values(1)
replace screening3=. if dental_screening3==. & xray_screening3==. & cholesterol_screening3==. & heart_screening3==. 
label var screening3 "Access to health services by doctor's initiative"

egen screening4= anycount(dental_screening4 xray_screening4 cholesterol_screening4 heart_screening4), values(1)
replace screening4=. if dental_screening4==. & xray_screening4==. & cholesterol_screening4==. & heart_screening4==. 
label var screening4 "Access to health services by screening program"


** Now, the next variables are related to the forms of social support listed by the respondent and their social attitudes. 

***The next three variables refer to different forms of social support listed by the respondent. If the respondent listed more than one second_support and third_support respectively include a second and a third form of social support
rename q1_a first_support
label var first_support "First form of social support"
rename q1_b second_support
label var second_support "Second form of social support"
rename q1_c third_support
label var third_support "Third form of social support"

*The next variables are related to the social attitudes of the respondents
rename q3_1b citizenbribe_acceptance
rename q3_1c notaxes_acceptance
rename q3_1d officialbribe_acceptance
rename q3_1e stealingfood_acceptance
rename q3_3a marriage_acceptance
rename q3_3b bridesteal_acceptance
rename q3_3c arrangedmarriageboy_acceptance
rename q3_3d arrangedmarriagegirl_acceptance
rename q3_3e delaymarriagegirl_acceptance
rename q3_5a husbandslapwife
rename q3_5b wifeslaphusband


*For the following questions the values will be inverted: marriage_acceptance and delaymarriagegirl_acceptance
gen nomixedmarriage=1 if marriage_acceptance==3
replace nomixedmarriage=3 if marriage_acceptance==1
replace nomixedmarriage=2 if marriage_acceptance==2

gen nodelaymarriage=1 if delaymarriagegirl_acceptance==3
replace nodelaymarriage=3 if delaymarriagegirl_acceptance==1
replace nodelaymarriage=2 if delaymarriagegirl_acceptance==2


*The variable discrimination_ethnicity refers to the perceived discrimination of the respondent towards its own ethnicity
rename j1_1a discrimination_ethnicity
replace discrimination_ethnicity=0 if discrimination_ethnicity==2
replace discrimination_ethnicity=. if discrimination_ethnicity>2
label var discrimination_ethnicity "Feel discriminated for ethnicity"

drop g20 g21 g22 b2_95_oth q1_a_95_oth q1_b_95_oth q1_c_95_oth komune qarkus rrethis bashic settlement type region percentage_of_roma entity kanton municipality area municipality_old municipality_new q4_2 q4_3 q4_4 q7a q7b q7c q7e q8  j2a j3a j4a j5a j6a j2b j3b j4b j5b j6b j2c j3c j4c j5c j6c j6d j2e j3e j4e j5e j6e l3a g3 g4_1 g4_2 g4_3 g4_95_oth g5 g6_1 g6_2 g6_3 g6_9_oth z1 z1_reason komune qarkus rrethis bashic settlement type region percentage_of_roma entity kanton municipality area municipality_old municipality_new j1_1b j1_1c j1_1d j1_1e j1_1f j1_1g j1_2 j2d j3d j4d j5d l3b l3f l3g q6_1 q6_2 q10 b4_a b4_b b4_c b2_1 b2_2 b2_3 b3_f b3_e

elabel rename (*) (*_master4)
save data_5.dta, replace

*Now I merge the 4 different data sets I am using, data_3 and data_6 are not used. They refer to Parenting techniques and additional sections on the attitudes of the household

*Before merge between data 2 and data 4
clear
use data_5.dta
isid country psu hh_id hhm_id
merge 1:m  country psu hh_id hhm_id using data_2.dta, gen(m1) 
keep if m1==3
*Now, with data 5 and 1 
merge 1:1 sample country psu hh_id using data_4.dta, gen(m2) 
merge 1:1 sample country psu hh_id using data_1.dta, gen(m3)
save dataDEF.dta, replace
order hhm_id number_members sex role, after(hh_id)
sort country psu hh_id 
save dataDEF.dta, replace

*Now, some final cleaning for the following binary variables

global property radio tv bike car horse computer internet phone washingmachine bed_foreach books30 powergenerator

local x $property
foreach var of varlist `x'* {
replace `var'=0 if `var'==2
}

replace disability=0 if disability==2
replace disability=. if disability>2

replace marital=. if marital>100
replace religion=. if religion>90

gen female=1 if sex==2
replace female=0 if female==.
order female, after(sex)
gen town=1 if type_residence==3
replace town=0 if town==.
gen capital=1 if type_residence==1
replace capital=0 if capital==. 
gen city=1 if type_residence==2
replace city=0 if city==.
gen village=1 if type_residence==4
replace village=0 if village==.
gen unregulated_area=1 if type_residence==5
replace unregulated_area=0 if unregulated_area==.

replace sample=0 if sample==2 

label define country 1 "Serbia" 2 "Montenegro" 3 "Albania" 4 "Macedonia" 5 "Kosovo" 6 "Bosnia-Herz", modify
label values country country

save dataDEF.dta, replace
