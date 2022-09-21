clear all
cd "/Users/antoniomarchitto/Desktop/DATASET"
*** Module 0 - Management section ==1 , Module 1 - Hoseuhold mebers profile ==2 
*** Module 1 - Parenting techniques == 3 , Module 3 - Status of the household == 4 
*** Module 4 - Individual status and attitudes of the randomly selected respondent ==5 
*** MODULE 4 - G1 G2 sections == 6 
clear 
use data_1.dta
browse
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



*MERGE 
*** Module 0 - Management section ==1 , Module 1 - Hoseuhold mebers profile ==2 
*** Module 1 - Parenting techniques == 3 , Module 3 - Status of the household == 4 
*** Module 4 - Individual status and attitudes of the randomly selected respondent ==5 
*** MODULE 4 - G1 G2 sections == 6 

*MODULE 0 - data_1.dta
*HOUSEHOLD 
clear
use data_1.dta
rename m8 type_residence
rename m9 type_house
rename m10_1 environmental_conditions1 
rename m10_2 environmental_conditions2
rename m10_3 environmental_conditions3
rename m10_4 environmental_conditions4 
rename m10_5 environmental_conditions5
rename m10_6 environmental_conditions6
rename m10_7 environmental_conditions7
rename m11 number_members

drop m9_6_oth m10_8 m10_9 m10_10 m10_11 m11a m11b m11c m11d m12a m12a_oth m12b m12b_oth m14 m15 m16 m17 m18_1 m18_1_1_oth m18_2 m18_2_1_oth municipality_old municipality_new qarkus rrethis bashic region entity kanton area
browse

gen greenspace= 0 if environmental_conditions1==1 | environmental_conditions2==1 | environmental_conditions3==1 | environmental_conditions4==1 | environmental_conditions5==1 | environmental_conditions6==1 | environmental_conditions7==1
replace greenspace= 1 if greenspace==.
label var greenspace "Green space not available in vicinity"

gen publicspace=0 if environmental_conditions1==3 | environmental_conditions2==3 | environmental_conditions3==3 | environmental_conditions4==3 | environmental_conditions5==3 | environmental_conditions6==3 | environmental_conditions7==3
replace publicspace= 1 if publicspace==.
label var publicspace "Public space not available in vicinity"

gen landslide=1 if environmental_conditions1==5 | environmental_conditions2==5 | environmental_conditions3==5 | environmental_conditions4==5 | environmental_conditions5==5 | environmental_conditions6==5 | environmental_conditions7==5
replace landslide=0 if landslide==.
label var landslide "Landslide area"

gen flooding=1 if environmental_conditions1==6 | environmental_conditions2==6 | environmental_conditions3==6 | environmental_conditions4==6 | environmental_conditions5==6 | environmental_conditions6==6 | environmental_conditions7==6
replace flooding=0 if flooding==.
label var flooding "Prone to flooding"

gen degraded=1 if environmental_conditions1==7 | environmental_conditions2==7 | environmental_conditions3==7 | environmental_conditions4==7 | environmental_conditions5==7 | environmental_conditions6==7 | environmental_conditions7==7
replace degraded=0 if degraded==. 
label var degraded "Degraded Land"

gen vandalized=1 if environmental_conditions1==8 | environmental_conditions2==8 | environmental_conditions3==8 | environmental_conditions4==8 | environmental_conditions5==8 | environmental_conditions6==8 | environmental_conditions7==8
replace vandalized=0 if vandalized==.
label var vandalized "Vandalized area, ugly graffiti"

gen garbage=1 if environmental_conditions1==9 | environmental_conditions2==9 | environmental_conditions3==9 | environmental_conditions4==9 | environmental_conditions5==9 | environmental_conditions6==9 | environmental_conditions7==9
replace garbage=0 if garbage==. 
label var garbage "There is garbage on streets"

gen bins=0 if environmental_conditions1==10 | environmental_conditions2==10 | environmental_conditions3==10 | environmental_conditions4==10 | environmental_conditions5==10 | environmental_conditions6==10 | environmental_conditions7==10
replace bins=1 if bins==.
label var bins "There are garbage bins, regularly served"

gen publiclight=0 if environmental_conditions1==11 | environmental_conditions2==11 | environmental_conditions3==11 | environmental_conditions4==11 | environmental_conditions5==11 | environmental_conditions6==11 | environmental_conditions7==11
replace publiclight=1 if publiclight==.
label var publiclight "There is no public lighting"

drop environmental_conditions1 environmental_conditions2 environmental_conditions3 environmental_conditions4 environmental_conditions5 environmental_conditions6 environmental_conditions7

gen Roma_settlement=1 if percentage_of_roma==1
replace Roma_settlement=0 if percentage_of_roma==2 



corr greenspace publicspace landslide flooding degraded vandalized garbage bins publiclight
alpha greenspace publicspace landslide flooding degraded vandalized garbage bins publiclight
egen environmental_conditions= rowtotal(greenspace publicspace landslide flooding degraded vandalized garbage bins publiclight), missing
su environmental_conditions

gen environmental_conditions_n = (environmental_conditions - 0) / (9)
su environmental_conditions_n
drop environmental_conditions

*The lower this index, the better housing conditions
elabel rename (*) (*_master)
save data_1.dta, replace

tab country environmental_conditions_n if sample==1, row 
*MODULE 3 data_4.dta
clear 
use data_4
rename q1_1a livinghere_5years
rename q1_1b livinghere_12months
rename q1_1c livinghere_6months
rename q1_2  comingfromothplace
rename q1_3a areaofprovenience
rename q1_3b countryofprovenience
rename q1_3b_95_oth countryofprovenience_oth
rename q1_4_1 reasonmoving_1
rename q1_4_2 reasonmoving_2
rename q1_4_3 reasonmoving_3
rename q1_5a neighborhood_improved
replace neighborhood_improved=. if neighborhood_improved==97 | neighborhood_improved==888998
rename q1_5b roads_improved
replace roads_improved=. if roads_improved==97 | roads_improved==888998
rename q1_5c housing_improved
replace housing_improved=. if housing_improved==97 | housing_improved==888998
rename q1_5e electricity_improved
replace electricity_improved=. if electricity_improved==97 | electricity_improved==888998
rename q1_5f transport_improved
replace transport_improved=. if transport_improved==97 | transport_improved==888998
rename q1_5g water_improved
replace water_improved=. if water_improved==97 | water_improved==888998
rename q1_5i schools_improved
replace schools_improved=. if schools_improved==97 | schools_improved==888998
rename q1_5j healthcenters_improved
replace healthcenters_improved=. if healthcenters_improved==97 | healthcenters_improved==888998
rename q1_5k communitycenter_improved
replace communitycenter_improved=. if communitycenter_improved==97 | communitycenter_improved==888998
corr neighborhood_improved roads_improved housing_improved electricity_improved transport_improved water_improved schools_improved healthcenters_improved communitycenter_improved
alpha neighborhood_improved roads_improved housing_improved electricity_improved transport_improved water_improved schools_improved healthcenters_improved communitycenter_improved, item
*The Cronbach alpha is sufficiently high to justify the construction of this scale variable
egen improvements= rowtotal(neighborhood_improved roads_improved housing_improved electricity_improved transport_improved water_improved schools_improved healthcenters_improved communitycenter_improved), missing
gen improvements_n = (improvements - 3) / (27 - 3)
order improvements improvements_n, after(communitycenter_improved)
*The meaning of the scale constructed is to measure the level of improvements made in the neighbourhood. Lower values state a general improvements, central values indicates no improvements. Higher values a general worsening. 
rename q1_8_1 transp_healthcenter 
replace transp_healthcenter=. if transp_healthcenter>5
rename q1_8a_1 transp_healthcenter_minutes
rename q1_8_2 transp_bus 
replace transp_bus=. if transp_bus>5
rename q1_8a_2 transp_bus_minutes
rename q1_8_4 transp_school 
replace transp_school=. if transp_school>5
rename q1_8a_4 transp_school_minutes
rename q1_8_5 transp_employmentoffice 
replace transp_employmentoffice=. if transp_employmentoffice>5
rename q1_8a_5 transp_employmentoffice_minutes
rename q1_8_6 transp_socialwelfareoffice 
replace transp_socialwelfareoffice=. if transp_socialwelfareoffice>5
rename q1_8a_6 transp_socialwelf_minutes
rename q1_8_7 transp_bank 
replace transp_bank=. if transp_bank>5
rename q1_8a_7 transp_bank_minutes

egen walking_healthfacility= anycount(transp_healthcenter), value(1)
gen no_walking=1 if walking_healthfacility==0
replace no_walking=0 if walking_healthfacility==1
drop transp_bus transp_bus_minutes transp_school transp_school_minutes transp_employmentoffice transp_employmentoffice_minutes transp_socialwelfareoffice transp_socialwelf_minutes transp_bank transp_bank_minutes 
rename q1_9 language_used
rename q1_10_1 language_used2
rename q1_10_2 language_used3
rename q1_11a tradeunion_activity
rename q1_11b political_activity
rename q1_11c Romaorganization_activity
tab Romaorganization_activity
rename q1_11d ngo_activity
rename q1_11e religious_activity
rename g2 pensions
rename g2_1_1 pensions_type1
rename g2_1_2 pensions_type2
gen disability_pension=1 if pensions_type1==2 | pensions_type2==2
replace disability_pension=0 if disability_pension==.
rename g3 aidbenefit
rename g3_1_1 aidbenefit_type1
rename g3_1_2 aidbenefit_type2
rename g4 social_assistance
rename g4_1_1 social_assistance_type1
rename g4_1_2 social_assistance_type2
rename g6 financial_give 
rename g7 financial_received
rename q3_2 number_rooms
rename q3_3 square_meters
rename q3_4 owner_house
rename q3_5 fear_losinghouse
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
rename q3_7_1 afford_rent
rename q3_7_2 afford_heating
rename q3_7_3 afford_holiday
rename q3_7_4 afford_meat
rename q3_7_5 afford_unexpectedexpenses
rename q3_7_6 afford_drugs
rename q3_14 hungry
rename q3_15 economic_security
gen kitchen=1 if q3_9a==1
replace kitchen=0 if q3_9a==2
gen piped=1 if q3_9b==1
replace piped=0 if q3_9b==2
gen toilet=1 if q3_9c==1
replace toilet=0 if toilet==.
gen wastewater=1 if q3_9e==1
replace wastewater=0 if wastewater==.
gen bathroom=1 if q3_9f==1
replace bathroom=0 if bathroom==.
gen electricity=1 if q3_9g==1
replace electricity=0 if electricity==.
gen heating=1 if q3_9h==1
replace heating=0 if heating==.
corr kitchen piped toilet wastewater bathroom electricity heating
alpha kitchen piped toilet wastewater bathroom electricity heating
egen housing_condition= anycount(kitchen piped toilet wastewater bathroom electricity heating), values(1 2 3 4 5 6 7)
gen housing_condition_n = (housing_condition - 0) / (7)
drop settlement type region percentage_of_roma entity kanton municipality area municipality_old municipality_new komune qarkus rrethis bashic  q1_4_20_oth q1_5d q1_5h q1_5l q1_6 q1_8_3 q1_8a_3 q1_8_8 q1_8a_8 q1_9_95_oth q1_10_3 q1_10_95_oth q2_1a q2_1b q2_1c q2_1d q2_1e q2_1f q2_1_oth q2_2 q2_2a q2_3 q2_4 q2_5 q2_6_1 q2_6_2 q2_6_3 q2_6_4 q2_6_5 q2_6_6 q2_6_7 q2_6_oth g1 g1_1_1 g1_1_2 g1_1_3 g1_1_4 g1_1_5 g1_1_6 g1_1_7 g1_1_8 g1_1_8_oth g1_2_1 g1_3_1 g1_4_1 g1_5_1_9999 g1_5_1_1 g1_5_1_2 g1_5_1_3 g1_5_1_4 g1_5_1_5 g1_5_1_6 g1_5_1_7 g1_5_1_8 g1_5_1_9 g1_5_1_10 g1_2_2 g1_3_2 g1_4_2 g1_5_2_9999 g1_5_2_1 g1_5_2_2 g1_5_2_3 g1_5_2_4 g1_5_2_5 g1_5_2_6 g1_5_2_7 g1_5_2_8 g1_5_2_9 g1_5_2_10 g1_2_3 g1_3_3 g1_4_3 g1_5_3_9999 g1_5_3_1 g1_5_3_2 g1_5_3_3 g1_5_3_4 g1_5_3_5 g1_5_3_6 g1_5_3_7 g1_5_3_8 g1_5_3_9 g1_5_3_10 g1_2_4 g1_3_4 g1_4_4 g1_5_4_9999 g1_5_4_1 g1_5_4_2 g1_5_4_3 g1_5_4_4 g1_5_4_5 g1_5_4_6 g1_5_4_7 g1_5_4_8 g1_5_4_9 g1_5_4_10 g1_2_5 g1_3_5 g1_4_5 g1_5_5_9999 g1_5_5_1 g1_5_5_2 g1_5_5_3 g1_5_5_4 g1_5_5_5 g1_5_5_6 g1_5_5_7 g1_5_5_8 g1_5_5_9 g1_5_5_10 g1_2_6 g1_3_6 g1_4_6 g1_5_6_9999 g1_5_6_1 g1_5_6_2 g1_5_6_3 g1_5_6_4 g1_5_6_5 g1_5_6_6 g1_5_6_7 g1_5_6_8 g1_5_6_9 g1_5_6_10 g1_2_7 g1_3_7 g1_4_7 g1_5_7_9999 g1_5_7_1 g1_5_7_2 g1_5_7_3 g1_5_7_4 g1_5_7_5 g1_5_7_6 g1_5_7_7 g1_5_7_8 g1_5_7_9 g1_5_7_10 g1_2_8 g1_3_8 g1_4_8 g1_5_8_9999 g1_5_8_1 g1_5_8_2 g1_5_8_3 g1_5_8_4 g1_5_8_5 g1_5_8_6 g1_5_8_7 g1_5_8_8 g1_5_8_9 g1_5_8_10 g2_1_3 g2_1_4 g2_1_5 g2_2_1 g2_3_1 g2_4_1_9999 g2_4_1_1 g2_4_1_2 g2_4_1_3 g2_4_1_4 g2_4_1_5 g2_4_1_6 g2_4_1_7 g2_4_1_8 g2_4_1_9 g2_4_1_10 g2_2_2 g2_3_2 g2_4_2_9999 g2_4_2_1 g2_4_2_2 g2_4_2_3 g2_4_2_4 g2_4_2_5 g2_4_2_6 g2_4_2_7 g2_4_2_8 g2_4_2_9 g2_4_2_10 g2_2_3 g2_3_3 g2_4_3_9999 g2_4_3_1 g2_4_3_2 g2_4_3_3 g2_4_3_4 g2_4_3_5 g2_4_3_6 g2_4_3_7 g2_4_3_8 g2_4_3_9 g2_4_3_10 g2_2_4 g2_3_4 g2_4_4_9999 g2_4_4_1 g2_4_4_2 g2_4_4_3 g2_4_4_4 g2_4_4_5 g2_4_4_6 g2_4_4_7 g2_4_4_8 g2_4_4_9 g2_4_4_10 g2_2_5 g2_3_5 g2_4_5_9999 g2_4_5_1 g2_4_5_2 g2_4_5_3 g2_4_5_4 g2_4_5_5 g2_4_5_6 g2_4_5_7 g2_4_5_8 g2_4_5_9 g2_4_5_10 g3_1_3 g3_1_4 g3_1_5 g3_2_1 g3_3_1 g3_4_1_9999 g3_4_1_1 g3_4_1_2 g3_4_1_3 g3_4_1_4 g3_4_1_5 g3_4_1_6 g3_4_1_7 g3_4_1_8 g3_4_1_9 g3_4_1_10 g3_2_2 g3_3_2 g3_4_2_9999 g3_4_2_1 g3_4_2_2 g3_4_2_3 g3_4_2_4 g3_4_2_5 g3_4_2_6 g3_4_2_7 g3_4_2_8 g3_4_2_9 g3_4_2_10 g3_2_3 g3_3_3 g3_4_3_9999 g3_4_3_1 g3_4_3_2 g3_4_3_3 g3_4_3_4 g3_4_3_5 g3_4_3_6 g3_4_3_7 g3_4_3_8 g3_4_3_9 g3_4_3_10 g3_2_4 g3_3_4 g3_4_4_9999 g3_4_4_1 g3_4_4_2 g3_4_4_3 g3_4_4_4 g3_4_4_5 g3_4_4_6 g3_4_4_7 g3_4_4_8 g3_4_4_9 g3_4_4_10 g3_2_5 g3_3_5 g3_4_5_9999 g3_4_5_1 g3_4_5_2 g3_4_5_3 g3_4_5_4 g3_4_5_5 g3_4_5_6 g3_4_5_7 g3_4_5_8 g3_4_5_9 g3_4_5_10 g4_1_3 g4_1_4 g4_1_5 g4_1_6 g4_1_7 g4_1_8 g4_2_1 g4_3_1 g4_2_2 g4_3_2 g4_2_3 g4_3_3 g4_2_4 g4_3_4 g4_2_5 g4_3_5 g3_2_6 g3_3_6 g3_2_7 g3_3_7 g3_2_8 g3_3_8 g6_1 g6_2 g7_1 g7_2 g9 g9_1 g9_2 g10 g10_1 g10_2 g12 q3_1 q3_4_95_oth q3_4_clan q3_8 q3_8_95_oth  q3_10 q3_10_95_oth q3_11 q3_11_95_oth q3_12a q3_12b q3_12c q3_12d q3_12e q3_12f q3_12g q3_12h q3_12i q3_13a_1 q3_13a_2 q3_13a_3 q3_13b_1 q3_13b_2 q3_13b_3 q3_13c_1 q3_13c_2 q3_13c_3 q3_13d_1 q3_13d_2 q3_13d_3 q3_13e_1 q3_13e_2 q3_13e_3 q3_13f_1 q3_13f_2 q3_13f_3 q3_13g_1 q3_13g_2 q3_13g_3 q3_13h_1 q3_13h_2 q3_13h_3 q3_13i_1 q3_13i_2 q3_13i_3 q3_8 q3_8_95_oth  q3_10 q3_10_95_oth q3_11 q3_11_95_oth q3_12a q3_12b q3_12c q3_12d q3_12e q3_12f q3_12g q3_12h q3_12i q3_13a_1 q3_13a_2 q3_13a_3 q3_13b_1 q3_13b_2 q3_13b_3 q3_13c_1 q3_13c_2 q3_13c_3 q3_13d_1 q3_13d_2 q3_13d_3 q3_13e_1 q3_13e_2 q3_13e_3 q3_13f_1 q3_13f_2 q3_13f_3 q3_13g_1 q3_13g_2 q3_13g_3 q3_13h_1 q3_13h_2 q3_13h_3 q3_13i_1 q3_13i_2 q3_13i_3 areaofprovenience countryofprovenience countryofprovenience_oth reasonmoving_1 reasonmoving_2 reasonmoving_3 neighborhood_improved roads_improved housing_improved electricity_improved transport_improved water_improved schools_improved healthcenters_improved communitycenter_improved improvements q3_9a q3_9b q3_9c q3_9d q3_9e q3_9f q3_9g q3_9h housing_condition
elabel rename (*) (*_master2)
save data_4.dta, replace

*HOUSEHOLD AND HOUSEHOLD MEMBERS PROFILES MODULE 1 data_2.dta
*General characteristics variables 
clear
use data_2.dta
rename a1 sex
rename a2 age
rename a3 role
rename a4 marital
rename a5 age_marriage
rename a6 ethnicity
rename a7 religion
rename a7_95_oth religion_other
rename a8 activity
rename a9 educ_level
rename b5 literacy1 
rename a10_b7 kindergarden
rename a11_b8 educ_years 
rename ec2_1  children_care
rename a11c citizenship1
rename a11c2 citizenship_acquisition
rename a11c3 citizenship_oth
rename a11c3_cou citizenship_oth_cou
rename a12 birth_country
rename a12br birth_registration
rename a12br1 birth_registration_place
rename a13_1 id_card1
rename a13_2 passport1
rename a13_3 temporary_residence_card1
rename a13_4 permament_residence_card1
rename a15idp idp
rename a15r refugee
*Education
rename b1 current_education 
rename b2 no_educ_reason
rename b11 roma_prevalence_school
rename b10 roma_prevalence_class
*Health
rename c1 health_self
rename c3 health_insurance
rename c_wg_1 disability
rename c_wg_3 disability_assessement
egen grade_disability= anycount(c_wg_2_1 c_wg_2_2 c_wg_2_3 c_wg_2_4 c_wg_2_5 c_wg_2_6), values(1 2 3 4 5 6)
gen grade_disability_n = (grade_disability - 0) / (6)

*Employement 
rename e2 paid_work
rename e4 working_hours
rename e5 profession
rename e5a net_earnings 
rename e6 written_contract
rename e7 contract_type
rename e7a employement_insurance
rename e8 jobsearch
rename e9 inactivity
rename e9_2 readytowork
rename e10 employement_agency
rename e11_1 employement_agency_service
rename e11_2 employement_agency_service2
rename e12_year lastjob
rename e13 years_working
rename e14 occupation_type
rename e15 industry

gen literacy=1 if literacy1==1
replace literacy=0 if literacy==.
order literacy, after(educ_level)

gen citizenship=1 if citizenship1==1
replace citizenship=0 if citizenship==.
order citizenship, after(educ_years)

gen id_card=1 if id_card1==1
replace id_card=0 if id_card==.
order id_card, after(birth_country)

drop a6_95_oth a8_95_oth ec2_2 ec2_3 ec2_4 ec2_5 ec2_6 ec2_7 ec2_8 ec2_9 ec2_10 ec2_11 ec2_95 ec5_1 ec5_2 ec5_3 ec6_1 ec6_2 ec6_3 ec6_4 ec6_5 ec6_5others ec10 ec11 a11c3_cou_95_oth a12_95_oth a12br2 a14_1_1 a14_1_2 a14_1_4 a14_1_6 a14_1_7 a14_1_9 a14_1_10 a14_1_11 a14_1_12 a14_1_13 a14_1_14 a14_1_18 a14_1_20 a14_1_21 a14_1_22 a14_1_23 a14_1_24 a14_1_25 a14_1_26 a14_1_95 a14_1_888998 a14_1_95_oth a14_2_1 a14_2_2 a14_2_4 a14_2_6 a14_2_7 a14_2_9 a14_2_10 a14_2_11 a14_2_12 a14_2_13 a14_2_14 a14_2_18 a14_2_20 a14_2_21 a14_2_22 a14_2_23 a14_2_24 a14_2_25 a14_2_26 a14_2_95 a14_2_888998 a14_2_95_oth a14_3_1 a14_3_2 a14_3_4 a14_3_6 a14_3_7 a14_3_9 a14_3_10 a14_3_11 a14_3_12 a14_3_13 a14_3_14 a14_3_18 a14_3_20 a14_3_21 a14_3_22 a14_3_23 a14_3_24 a14_3_25 a14_3_26 a14_3_95 a14_3_888998 a14_3_95_oth a14_4_1 a14_4_2 a14_4_4 a14_4_6 a14_4_7 a14_4_9 a14_4_10 a14_4_11 a14_4_12 a14_4_13 a14_4_14 a14_4_18 a14_4_20 a14_4_21 a14_4_22 a14_4_23 a14_4_24 a14_4_25 a14_4_26 a14_4_95 a14_4_888998 a14_4_95_oth a12br1_cou a12br1_cou_95_oth b2_95_oth b3 b4 b4_6_oth e3 e11_3 e11_4 e11_5 e11_95 e11_888998 e11_95_oth e14_95_oth e15_95_oth f1 f2 f2a f3d f3w f4 f5 f6 r0 r1 r1_95_oth r2_m r2_y r3 r4_m r4_y r5 r6_1 r6_2 r6_3 r7 r7_95_oth r8_1 r8_2 r8_3 r8_4 r8_5 r8_888996 r9 r10_1 r10_2 r10_3 r10_4 r10_888996 r11_1 r11_2 r11_3 r12 r13 r13_95_oth entity kanton municipality area municipality_old municipality_new komune qarkus rrethis bashic settlement type region percentage_of_roma religion_other literacy1 age_marriage kindergarden children_care citizenship1 citizenship_oth citizenship_oth_cou birth_registration birth_registration_place passport temporary_residence_card permament_residence_card idp refugee id_card1 c_wg_2_95 c_wg_2_888998

*keep if role==1

*There could be a general idea of people stating that are good with their health if they have helath insurance, while according to the table below, the 36.50 of people affirming that are very good with their health, they actually do not dispose of health insurance. 
tab health_self health_insurance, col row

elabel rename (*) (*_master3)
save data_2.dta, replace

*MODULE 4 data_5.dta
clear
use data_5.dta

rename b1 health_behavior
rename b2_1 health_behavior_reason1
rename b2_2 health_behavior_reason2
rename b2_3 health_behavior_reason3

rename b3_a dental_screening
gen dental_screening1=1 if dental_screening<4
replace dental_screening1=0 if dental_screening==4
replace dental_screening1=. if dental_screening>4

gen dental_screening2=1 if dental_screening==1
replace dental_screening2=0 if dental_screening==2 | dental_screening==3 | dental_screening==4 
replace dental_screening2=. if dental_screening>4

gen dental_screening3=1 if dental_screening==2
replace dental_screening3=0 if dental_screening==1 | dental_screening==3 | dental_screening==4 
replace dental_screening3=. if dental_screening>4

gen dental_screening4=1 if dental_screening==3
replace dental_screening4=0 if dental_screening==1 | dental_screening==2 | dental_screening==4 
replace dental_screening4=. if dental_screening>4

rename b3_b xray_screening
gen xray_screening1=1 if xray_screening<4
replace xray_screening1=0 if xray_screening==4
replace xray_screening1=. if xray_screening>4

gen xray_screening2=1 if xray_screening==1
replace xray_screening2=0 if xray_screening==2 | xray_screening==3 | xray_screening==4 
replace xray_screening2=. if xray_screening>4

gen xray_screening3=1 if xray_screening==2
replace xray_screening3=0 if xray_screening==1 | xray_screening==3 | xray_screening==4 
replace xray_screening3=. if xray_screening>4

gen xray_screening4=1 if xray_screening==3
replace xray_screening4=0 if xray_screening==1 | xray_screening==2 | xray_screening==4 
replace xray_screening4=. if xray_screening>4

rename b3_c cholesterol_screening

gen cholesterol_screening1=1 if cholesterol_screening<4
replace cholesterol_screening1=0 if cholesterol_screening==4
replace cholesterol_screening1=. if cholesterol_screening>4

gen cholesterol_screening2=1 if cholesterol_screening==1
replace cholesterol_screening2=0 if cholesterol_screening==2 | cholesterol_screening==3 | cholesterol_screening==4 
replace cholesterol_screening2=. if cholesterol_screening>4

gen cholesterol_screening3=1 if cholesterol_screening==2
replace cholesterol_screening3=0 if cholesterol_screening==1 | cholesterol_screening==3 | cholesterol_screening==4 
replace cholesterol_screening3=. if cholesterol_screening>4

gen cholesterol_screening4=1 if cholesterol_screening==3
replace cholesterol_screening4=0 if cholesterol_screening==1 | cholesterol_screening==2 | cholesterol_screening==4 
replace cholesterol_screening4=. if cholesterol_screening>4


rename b3_d heart_screening
gen heart_screening1=1 if heart_screening<4
replace heart_screening1=0 if heart_screening==4
replace heart_screening1=. if heart_screening>4

gen heart_screening2=1 if heart_screening==1
replace heart_screening2=0 if heart_screening==2 | heart_screening==3 | heart_screening==4 
replace heart_screening2=. if heart_screening>4

gen heart_screening3=1 if heart_screening==2
replace heart_screening3=0 if heart_screening==1 | heart_screening==3 | heart_screening==4 
replace heart_screening3=. if heart_screening>4

gen heart_screening4=1 if heart_screening==3
replace heart_screening4=0 if heart_screening==1 | heart_screening==2 | heart_screening==4 
replace heart_screening4=. if heart_screening>4

rename b3_e gynaecological_screening
rename b3_f breast_screening





rename b4_a blood_pressure_screening
replace blood_pressure_screening=1 if blood_pressure_screening==1
replace blood_pressure_screening=0 if blood_pressure_screening!=1
rename b4_b blood_cholesterol_screening
replace blood_cholesterol_screening=1 if blood_cholesterol_screening==1
replace blood_cholesterol_screening=0 if blood_cholesterol_screening!=1
rename b4_c blood_sugar_screening 
replace blood_sugar_screening=1 if blood_sugar_screening==1
replace blood_sugar_screening=0 if blood_sugar_screening!=1


corr dental_screening xray_screening cholesterol_screening heart_screening gynaecological_screening breast_screening blood_pressure_screening blood_cholesterol_screening blood_sugar_screening
alpha dental_screening xray_screening cholesterol_screening heart_screening gynaecological_screening breast_screening 

egen screening= anycount(dental_screening xray_screening cholesterol_screening heart_screening), values(1 2 3)

egen screening1= anycount(dental_screening1 xray_screening1 cholesterol_screening1 heart_screening1), values(1)

egen screening_f= anycount(dental_screening xray_screening cholesterol_screening heart_screening gynaecological_screening breast_screening), values(1 2 3)
gen screening_initiative_f=1 if screening_f>0
replace screening_initiative_f=0 if screening_f==0

egen screening2= anycount(dental_screening2 xray_screening2 cholesterol_screening2 heart_screening2), values(1)

egen screening3= anycount(dental_screening3 xray_screening3 cholesterol_screening3 heart_screening3), values(1)

egen screening4= anycount(dental_screening4 xray_screening4 cholesterol_screening4 heart_screening4), values(1)

rename q1_a first_support
rename q1_b second_support
rename q1_c third_support



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
rename q6_1 sufficientlevel_school_boy
rename q6_2 sufficientlevel_school_girl
rename q10 safety_place
rename j1_1a discrimination_ethnicity
replace discrimination_ethnicity=0 if discrimination_ethnicity==2
replace discrimination_ethnicity=. if discrimination_ethnicity>2
label var discrimination_ethnicity "Feel discriminated for ethnicity"
rename j1_1b discrimination_gender
rename j1_1c discrimination_sexualorientation
rename j1_1d discrimination_age
rename j1_1e discrimination_religion
rename j1_1f discrimination_disability 
rename j1_1g discrimination_other
rename j2d contact_healthservices
rename j3d discrimination_healthbecauseRoma 
rename j4d discrimination_healthother 
rename j5d discrimination_healthwhen
rename l3b unofficial_payementpolice
rename l3f unofficial_payementhealth
rename l3g unofficial_payementschool
rename j1_2 perceived_discrimination
gen perceived_discrimination_i=1 if perceived_discrimination==2
replace perceived_discrimination_i=0 if perceived_discrimination==1
replace perceived_discrimination_i=. if perceived_discrimination>2
drop perceived_discrimination
rename perceived_discrimination_i perceived_discrimination
drop g20 g21 g22 b2_95_oth q1_a_95_oth q1_b_95_oth q1_c_95_oth komune qarkus rrethis bashic settlement type region percentage_of_roma entity kanton municipality area municipality_old municipality_new q4_2 q4_3 q4_4 q7a q7b q7c q7e q8  j2a j3a j4a j5a j6a j2b j3b j4b j5b j6b j2c j3c j4c j5c j6c j6d j2e j3e j4e j5e j6e l3a g3 g4_1 g4_2 g4_3 g4_95_oth g5 g6_1 g6_2 g6_3 g6_9_oth z1 z1_reason komune qarkus rrethis bashic settlement type region percentage_of_roma entity kanton municipality area municipality_old municipality_new 
elabel rename (*) (*_master4)
save data_5.dta, replace

*Before merge between data 2 and data 1
clear
use data_4.dta
isid country psu hh_id 
merge 1:m  country psu hh_id hhm_id using data_2.dta, gen(m1) 
keep if m1==3
merge 1:1 sample country psu hh_id using data_5.dta, gen(m2) 
merge 1:1 sample country psu hh_id using data_1.dta, gen(m3)
save dataDEF.dta, replace
order hhm_id number_members sex role, after(hh_id)


tab discrimination_healthbecauseRoma if sample==1
sort country psu hh_id
save dataDEF.dta, replace

*IF ALREADY MERGED 
clear all
capture: log close 
cd "/Users/antoniomarchitto/Desktop/DATASET"
use dataDEF.dta
order municipality, after(komune)
*Settlements 
replace settlement="KAKANJ" if municipality=="KAKANJ"
replace settlement="BIHAĆ" if municipality=="BIHAĆ"
replace settlement="KLJUČ" if municipality=="KLJUČ"
replace settlement="BANJA LUKA" if municipality=="BANJA LUKA"
replace settlement="GRADIŠKA" if municipality=="GRADIŠKA"
replace settlement="PRIJEDOR" if municipality=="PRIJEDOR"
replace settlement="CENTAR SARAJEVO" if municipality=="CENTAR SARAJEVO"
replace settlement="ILIDŽA" if municipality=="ILIDŽA"
replace settlement="NOVI GRAD SARAJEVO" if municipality=="NOVI GRAD SARAJEVO"
replace settlement="NOVO SARAJEVO" if municipality=="NOVO SARAJEVO"
replace settlement="BANOVIĆI" if municipality=="BANOVIĆI"
replace settlement="DOBOJ" if municipality=="DOBOJ"
replace settlement="GRAČANICA" if municipality=="GRAČANICA"
replace settlement="BRČKO" if municipality=="BRČKO"
replace settlement="BOSANSKA KRUPA" if municipality=="BOSANSKA KRUPA"
replace settlement="ZENICA" if municipality=="ZENICA"
replace settlement="ZAVIDOVIĆI" if municipality=="ZAVIDOVIĆI"
replace settlement="VITEZ" if municipality=="VITEZ"
replace settlement="VISOKO" if municipality=="VISOKO"
replace settlement="TRAVNIK" if municipality=="TRAVNIK"
replace settlement="JAJCE" if municipality=="JAJCE"
replace settlement="DONJI VAKUF" if municipality=="DONJI VAKUF"
replace settlement="KONJIC" if municipality=="KONJIC"
replace settlement="GRAD MOSTAR" if municipality=="GRAD MOSTAR"
replace settlement="ŽIVINICE" if municipality=="ŽIVINICE"
replace settlement="VUKOSAVLJE" if municipality=="VUKOSAVLJE"
replace settlement="TUZLA" if municipality=="TUZLA"
replace settlement="MODRIČA" if municipality=="MODRIČA"
replace settlement="LUKAVAC" if municipality=="LUKAVAC"
replace settlement="KISELJAK" if municipality=="KISELJAK"
replace settlement="KALESIJA" if municipality=="KALESIJA"
replace settlement="GRADAČAC" if municipality=="GRADAČAC"
replace settlement="KISELJAK" if municipality=="KISELJAK"
replace settlement="KISELJAK" if municipality=="KISELJAK"
encode settlement, gen(settlement_)


*municipality 
replace municipality="Berat (qytet)" if komune=="Berat (qytet)"
replace municipality="Ura e Kuçit" if komune=="Ura e Kuçit"
replace municipality="Lagjia Stan/Moravë" if komune=="Lagjia Stan/Moravë"
replace municipality="Kuçova" if komune=="Kuçova"
replace municipality="Durrës" if komune=="Durrës"
replace municipality="Shkozet (lagj.14)" if komune=="Shkozet (lagj.14)"
replace municipality="Plazh (Mbikalimi)" if komune=="Plazh (Mbikalimi)"
replace municipality="Qafa e ariut" if komune=="Qafa e ariut"
replace municipality="Fushë-Kruja" if komune=="Fushë-Kruja"
replace municipality="Cerrik" if komune=="Cerrik"
replace municipality="Elbasan (qytet)" if komune=="Elbasan (qytet)"
replace municipality="5 maji (Rapishte)" if komune=="5 maji (Rapishte)"
replace municipality="Peqin" if komune=="Peqin"
replace municipality="Baltëz (komuna Derrmenas)" if komune=="Baltëz (komuna Derrmenas)"
replace municipality="Mbrostar Ura" if komune=="Mbrostar Ura"
replace municipality="Lagj. Qender Azotik" if komune=="Lagj. Qender Azotik"
replace municipality="Levan (Komuna)" if komune=="Levan (Komuna)"
replace municipality="Roskoveci" if komune=="Roskoveci"
replace municipality="Seman" if komune=="Seman"
replace municipality="Komuna Grabian" if komune=="Komuna Grabian"
replace municipality="Pluk" if komune=="Pluk"
replace municipality="Gjirokaster" if komune=="Gjirokaster"
replace municipality="Bilisht (Devoll)" if komune=="Bilisht (Devoll)"
replace municipality="Korça (qytet) Shkolla Naim Frasheri" if komune=="Korça (qytet) Shkolla Naim Frasheri"
replace municipality="Maliq (Korçë)" if komune=="Maliq (Korçë)"
replace municipality="Sovjan (Korçë)" if komune=="Sovjan (Korçë)"
replace municipality="Pojani (Korçë)" if komune=="Pojani (Korçë)"
replace municipality="Pogradec (Qytet)" if komune=="Pogradec (Qytet)"
replace municipality="Laç" if komune=="Laç"
replace municipality="Lezhë (Rome+Egjiptiane)" if komune=="Lezhë (Rome+Egjiptiane)"
replace municipality="Shengjini" if komune=="Shengjini"
replace municipality="Shkodër (dy krahet e lumit Buna)" if komune=="Shkodër (dy krahet e lumit Buna)"
replace municipality="Rrogozhina" if komune=="Rrogozhina"
replace municipality="Josif Pashko/ Nish.Tulla Nr.3" if komune=="Josif Pashko/ Nish.Tulla Nr.3"
replace municipality="Kombinat/Yzberisht" if komune=="Kombinat/Yzberisht"
replace municipality="Bregu i lumit" if komune=="Bregu i lumit"
replace municipality="N/stacioni elektrik" if komune=="N/stacioni elektrik"
replace municipality="Kinostudio" if komune=="Kinostudio"
replace municipality="Allias/B.Curri" if komune=="Allias/B.Curri"
replace municipality="Seliata" if komune=="Seliata"
replace municipality="Prilep" if settlement=="Prilep"
replace municipality="Vataša" if settlement=="Vataša"
replace municipality="Kavadarci" if settlement=="Kavadarci"
replace municipality="Bitola" if settlement=="Bitola"
replace municipality="Skopje - Šuto Orizari" if settlement=="Skopje - Šuto Orizari"
replace municipality="Skopje - Saraj" if settlement=="Skopje - Saraj"
replace municipality="Selo Dračevo" if settlement=="Selo Dračevo"
replace municipality="Naselba Dračevo" if settlement=="Naselba Dračevo"
replace municipality="Zlokukjani" if settlement=="Zlokukjani"
replace municipality="Bujkovci" if settlement=="Bujkovci"
replace municipality="Orizari" if settlement=="Orizari"
replace municipality="Novo Selo" if settlement=="Novo Selo"
replace municipality="Singelik" if settlement=="Singelik"
replace municipality="Madžari" if settlement=="Madžari"
replace municipality="Jurumleri" if settlement=="Jurumleri"
replace municipality="Skopje - Čair" if settlement=="Skopje - Čair"
replace municipality="Skopje - Centar" if settlement=="Skopje - Centar"
replace municipality="Gorno Lisiče" if settlement=="Gorno Lisiče"
replace municipality="Tetovo" if settlement=="Tetovo"
replace municipality="Kumanovo" if settlement=="Kumanovo"
replace municipality="Raštani" if settlement=="Raštani"
replace municipality="Kičevo" if settlement=="Kičevo"
replace municipality="Gostivar" if settlement=="Gostivar"
replace municipality="Gorna Banjica" if settlement=="Gorna Banjica"
replace municipality="Debar" if settlement=="Debar"
replace municipality="Vinica" if settlement=="Vinica"
replace municipality="Veles" if settlement=="Veles"
replace municipality="Štip" if settlement=="Štip"
replace municipality="Strumica" if settlement=="Strumica"
replace municipality="Crnik" if settlement=="Crnik"
replace municipality="Krivolak" if settlement=="Krivolak"
replace municipality="Kriva Palanka" if settlement=="Kriva Palanka"
replace municipality="Kočani" if settlement=="Kočani"
replace municipality="Delčevo" if settlement=="Delčevo"
replace municipality="Berovo" if settlement=="Berovo"
replace municipality="Llakatund" if komune=="Llakatund"
replace municipality="Novosela" if komune=="Novosela"
replace municipality="Çuka" if komune=="Çuka"
replace municipality="Konispol" if komune=="Konispol"
replace municipality="Delvina" if komune=="Delvina"
replace municipality="Konispol" if komune=="Konispol"
replace municipality="Konispol" if komune=="Konispol"
replace municipality="Konispol" if komune=="Konispol"
replace municipality="Konispol" if komune=="Konispol"

encode municipality, gen(municipality_n)
order settlement_, after(municipality)
order municipality_n, after(number_members)
*Health_behavior 
replace health_behavior=0 if health_behavior==2
replace health_behavior=1 if health_behavior==1
replace health_behavior=. if health_behavior!=0 & health_behavior!=1

*Creating all the shortcuts
global neighbourhood i.type_residence i.type_house environmental_conditions_n
global property radio tv bike car horse computer internet phone washingmachine bed_foreach books30 powergenerator
global participation tradeunion_activity political_activity Romaorganization_activity ngo_activity religious_activity


*Listing of the variables: MODULE 0 $neighbourhood number_members 
*MODULE 3: walking_healthfacility transp_healthcenter_minutes improvements_n Roma_language disability_pension $property $participation number_rooms square_meters owner_house fear_losinghouse afford_rent afford_heating afford_holiday afford_meat afford_unexpectedexpenses afford_drugs hungry economic_security 
*MODULE1: age marital ethnicity religion activity educ_level literacy educ_years citizenship citizenship_acquisition birth_country id_card   roma_prevalence_class roma_prevalence_school health_self health_insurance disability grade_disability 
*MODULE 4: 
drop ethnicity livinghere_5years livinghere_12months livinghere_6months comingfromothplace greenspace publicspace landslide flooding degraded vandalized garbage bins publiclight pensions pensions_type1 pensions_type2 aidbenefit aidbenefit_type1 aidbenefit_type2 social_assistance social_assistance_type1 social_assistance_type2 role citizenship_acquisition ethnicity birth_country current_education no_educ_reason c_wg_2_1 c_wg_2_2 c_wg_2_3 c_wg_2_4 c_wg_2_5 c_wg_2_6 grade_disability jobsearch inactivity readytowork employement_agency employement_agency_service employement_agency_service2 lastjob  transp_healthcenter
drop disability_assessement 
*For the regression we need: educational status, health_status, Work_status, income, neighbourhood, country fixed effects 
*education, walking_healthfacility transp_healthcenter_minutes religion marital educ_years health_insurance 


local x $property
foreach var of varlist `x'* {
replace `var'=0 if `var'==2
}

replace disability=0 if disability==2
replace disability=. if disability>2
gen no_disability=1 if disability==0
replace no_disability=0 if disability==1
*marital religion delete DK
replace marital=. if marital>100
replace religion=. if religion>90


*generate variables that are not categorical
gen female=1 if sex==2
replace female=0 if female==.
gen male=1 if female==0
replace male=0 if female==1
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
global type_neighbourhood town village capital city unregulated_area

gen serbia=1 if country==1
replace serbia=0 if serbia==.
label var serbia "Serbia"
gen montenegro=1 if country==2
replace montenegro=0 if montenegro==.
label var montenegro "Montenegro"
gen albania=1 if country==3
replace albania=0 if albania==.
label var albania "Albania"
gen macedonia=1 if country==4
replace macedonia=0 if macedonia==.
label var macedonia "Macedonia"
gen kosovo=1 if country==5
replace kosovo=0 if kosovo==.
label var kosovo "Kosovo"
gen bosnia=1 if country==6
replace bosnia=0 if bosnia==.
label var bosnia "Bosnia-Herzegovina"


*First table - Percentage of Roma for each country
asdoc tab sample country, col

*Graphs 
gen health_behavior_roma=1 if health_behavior==1 & sample==1
replace health_behavior_roma=0 if health_behavior==0 &sample==1
gen health_behavior_non=1 if health_behavior==1 & sample==0
replace health_behavior_non=0 if health_behavior==0 &sample==0


*Second Table - Indicators of health 
replace sample=0 if sample==2
gen sample_r=1 if sample==0
replace sample_r=0 if sample==1
replace health_self=. if health_self>5 
gen good_health=1 if health_self==4 | health_self==5
replace good_health=0 if good_health==.
gen bad_health=1 if good_health==0
replace bad_health=0 if good_health==1
label var good_health "Self-reported good or very good health"

replace health_behavior=0 if health_behavior==2
tab environmental_conditions_n sample, col
gen unemployed=1 if paid_work==2 & age>16
replace unemployed=0 if paid_work==1 & age>16
gen employed=1 if paid_work==1 & age>16
replace employed=0 if paid_work==2 & age>16

replace health_insurance=1 if health_insurance==2
replace health_insurance=. if health_insurance>3
replace health_insurance=0 if health_insurance==3


gen food_insecurity=1 if hungry==3 | hungry==4
replace food_insecurity=0 if hungry==1 | hungry==2 
gen food_security=1 if food_insecurity==0
replace food_security=0 if food_insecurity==1
replace afford_drugs=0 if afford_drugs==2
replace afford_drugs=. if afford_drugs>2
replace afford_rent=0 if afford_rent==2
replace afford_rent=. if afford_rent>2
replace afford_heating=0 if afford_heating==2
replace afford_heating=. if afford_heating>2
replace afford_holiday=0 if afford_holiday==2
replace afford_holiday=. if afford_holiday>2
replace afford_meat=0 if afford_meat==2
replace afford_meat=. if afford_meat>2
replace afford_unexpectedexpenses=0 if afford_unexpectedexpenses==2
replace afford_unexpectedexpenses=. if afford_unexpectedexpenses>2
corr afford_rent afford_heating afford_holiday afford_meat afford_unexpectedexpenses afford_drugs
alpha afford_rent afford_heating afford_holiday afford_meat afford_unexpectedexpenses afford_drugs
egen afford= anycount(afford_rent afford_heating afford_holiday afford_meat afford_unexpectedexpenses afford_drugs), values(1)
gen afford_n=(afford-0)/(6)
drop afford 
label var age "Age"
label var educ_years "Educational years"
label var unemployed "Unemployed"
label var food_insecurity "Food insecurity"
label var environmental_conditions_n "Quality of the environment"
label var housing_condition_n "Housing conditions"
label var health_insurance "Health insurance"
label var good_health "Self-reported good health"
label var health_behavior "Avoidance of medical screening"

replace educ_years=. if educ_years>19
tab female sample, col
label var female "Percentage of females"
label var afford_n "Economic security"
eststo clear
eststo s3:  estpost ttest female age no_educ primary secondary  health_insurance food_insecurity afford_n environmental_conditions_n  health_self  disability grade_disability_n walking_healthfacility  $type_neighbourhood  fear_losinghouse asset_index, by(sample)

esttab s3 using c.tex, noobs cells("mu_2 mu_1 se") title ("Characteristics of the sample") collabels ("Roma" "Non-Roma" "SE") nonumber label replace

eststo s4:  estpost ttest community_support_n own_norms_n discrimination_ethnicity , by(sample)

esttab s4 using c.tex, noobs cells("mu_2 mu_1 se") title ("Explanatory variables") collabels ("Roma" "Non-Roma" "SE") nonumber label replace



*Other table 
* Produce a matrix of results using asdoc
label var fear_losinghouse "Fear losing house"
asdoc sum female age health_insurance disability food_insecurity afford_n environmental_conditions_n fear_losinghouse if sample==1, replace stat(mean) label

*  Store the matrix in matrix A
mat A = StatTotal

* Repeat the process for each unique category of treat2x2 variable
asdoc sum female age  health_insurance disability food_insecurity afford_n environmental_conditions_n fear_losinghouse  if sample==0, replace stat(mean) label
mat B = StatTotal

* Combine all the matrices into one matrix
matrix coljoinbyname E = A B

* Write this matrix to Word using asdoc
asdoc wmat, mat(E) replace label

asdoc sum female age i.educ_level i.health_self health_insurance disability food_insecurity afford_n environmental_conditions_n  i.asset_index if sample==1, label 

asdoc sum female age i.educ_level i.health_self health_insurance disability food_insecurity afford_n environmental_conditions_n  i.asset_index if sample==0, label 





*Measures of community influence 
*Roma Language 
gen Roma_language=1 if language_used==1 
replace Roma_language=0 if Roma_language==.
tab Roma_language
tab Roma_language sample

*Then majority of the Roma sample, states that can both speak the official language of the country and Romani. I decided to consider only the languaged MOST used at home. 

*Community support 
corr first_support second_support third_support
alpha first_support second_support third_support 

egen community_support = anycount(first_support second_support third_support), values(1 2 3 4 5 6 7 8)

gen community_support_n = (community_support - 0) / (3)
tab community_support_n sample
drop community_support


*preference for segregation 
gen marriage_contrary=1 if marriage_acceptance==3
replace marriage_contrary=3 if marriage_acceptance==1
replace marriage_contrary=2 if marriage_acceptance==2
gen delaymarriage=1 if delaymarriagegirl_acceptance==3
replace delaymarriage=3 if delaymarriagegirl_acceptance==1
replace delaymarriage=2 if delaymarriagegirl_acceptance==2


corr bridesteal_acceptance arrangedmarriageboy_acceptance arrangedmarriagegirl_acceptance delaymarriage marriage_contrary husbandslapwife wifeslaphusband citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance

alpha bridesteal_acceptance arrangedmarriageboy_acceptance arrangedmarriagegirl_acceptance delaymarriage marriage_contrary  

alpha citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance 


replace bridesteal_acceptance=0 if bridesteal_acceptance==2 | bridesteal_acceptance==3
replace bridesteal_acceptance=. if bridesteal_acceptance>3
gen bridesteal_acceptance_i= sample*bridesteal_acceptance


replace arrangedmarriageboy_acceptance=. if arrangedmarriageboy_acceptance>3
replace arrangedmarriageboy_acceptance=0 if arrangedmarriageboy_acceptance==3 | arrangedmarriageboy_acceptance==2 
gen arrangedmarriageboy_acceptance_i=sample*arrangedmarriageboy_acceptance

replace arrangedmarriagegirl_acceptance=. if arrangedmarriagegirl_acceptance>3
replace arrangedmarriagegirl_acceptance=0 if arrangedmarriagegirl_acceptance==3  | arrangedmarriagegirl_acceptance==2
gen arrangedmarriagegirl_roma=sample*arrangedmarriagegirl_acceptance


replace delaymarriage=0 if delaymarriage==3 | delaymarriage==2
gen delaymarriage_i=sample*delaymarriage

replace marriage_contrary=0 if marriage_contrary>1
gen marriage_contrary_i=sample*marriage_contrary

replace citizenbribe_acceptance=. if citizenbribe_acceptance>3
replace citizenbribe_acceptance=0 if citizenbribe_acceptance==3 | citizenbribe_acceptance==2
gen citizenbribe_acceptance_i= sample*citizenbribe_acceptance

replace notaxes_acceptance=. if notaxes_acceptance>3
replace notaxes_acceptance=0 if notaxes_acceptance==3 | notaxes_acceptance==2 
gen notaxes_acceptance_i=sample*notaxes_acceptance

replace officialbribe_acceptance=. if officialbribe_acceptance>3
replace officialbribe_acceptance=0 if officialbribe_acceptance==3 | officialbribe_acceptance==2
gen officialbribe_acceptance_i=sample*officialbribe_acceptance


replace stealingfood_acceptance=. if stealingfood_acceptance>3
replace stealingfood_acceptance=0 if stealingfood_acceptance==2 | stealingfood_acceptance==3
gen stealingfood_acceptance_i=sample*stealingfood_acceptance

egen own_norms= anycount(citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance), values(1)

gen own_norms_n=(own_norms - 0)/4

global norms bridesteal_acceptance arrangedmarriageboy_acceptance arrangedmarriagegirl_acceptance delaymarriage marriage_contrary citizenbribe_acceptance notaxes_acceptance officialbribe_acceptance stealingfood_acceptance  
global roma bridesteal_acceptance_i arrangedmarriageboy_acceptance_i arrangedmarriagegirl_roma delaymarriage_i marriage_contrary_i citizenbribe_acceptance_i notaxes_acceptance_i officialbribe_acceptance_i stealingfood_acceptance_i

egen trust=anycount(unofficial_payementpolice unofficial_payementhealth unofficial_payementschool), values (4 5)
gen trust_n=(trust - 0)/3

*Interaction term
gen community_support_ni= sample*community_support_n
gen own_norms_ni = sample*own_norms_n
gen discrimination_ethnicity_i= discrimination_ethnicity*sample
gen perceived_discrimination_ni=sample*perceived_discrimination
tab educ_level
gen no_educ=1 if educ_level==1
replace no_educ=0 if no_educ==.
gen trust_ni=sample*trust_n
gen primary=1 if educ_level==3 
replace primary=0 if primary==.

gen secondary=1 if educ_level==7 | educ_level==8 
replace secondary=0 if secondary==.

replace educ_level=. if educ_level>17

replace educ_level=3 if educ_level==4 | educ_level==5 | educ_level==6
replace educ_level=7 if educ_level==8 | educ_level==9
replace educ_level=. if educ_level>16
replace educ_level=10 if educ_level>10

*wealth INDEX 
pca radio tv bike car horse computer internet phone washingmachine bed_foreach books30 powergenerator kitchen piped toilet wastewater bathroom electricity heating 
estat kmo
predict comp1
hist comp1
rename comp1 asset_score
xtile asset_index= asset_score [aweight=number_members], nq(5) 
la val asset_index asset_index
la var asset_index "Asset index"
la de asset_index 1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest"

*LOGIT - CONTACT WITH HEALTH SERVICES
replace fear_losinghouse=. if fear_losinghouse>5
replace contact_healthservices=0 if contact_healthservices==2
replace contact_healthservices=. if contact_healthservices>1
gen screening_initiative=1 if screening>0
replace screening_initiative=0 if screening_initiative!=1
gen screening_initiative_f=1 if screening_f>0
replace screening_initiative_f=0 if screening_initiative_f!=1
gen screening_initiative1=1 if screening1>0
replace screening_initiative1=0 if screening_initiative1!=1
gen screening_initiative2=1 if screening2>0
replace screening_initiative2=0 if screening_initiative2!=1
gen screening_initiative3=1 if screening3>0
replace screening_initiative3=0 if screening_initiative3!=1
gen screening_initiative4=1 if screening4>0
replace screening_initiative4=0 if screening_initiative4!=1

eststo clear
label var disability "Disability"
label var Roma_language "Roma language"
label var community_support_n "Community support"
label var community_support_ni "Community support x Roma"
label var own_norms_n "Follow own norms"
label var own_norms_ni "Follow own norms x Roma"
label var discrimination_ethnicity "Ethnic discrimination"
label var female "Female"
label var environmental_conditions_n "External conditions"
label var good_health "Good health"
label var sample "Roma"
label var health_behavior "Health-care avoidance"
label var contact_healthservices "Contact with health services"
label var own_norms_ni "Follow own norms x Roma"
label var no_educ "No formal education"
label var discrimination_ethnicity "Discriminated for ethnicity"
label var delaymarriage "Girls abandoning school for marriage"
label var discrimination_ethnicity_i "Discriminated for ethnicity x Roma"
label var marriage_contrary "Contrary to marriage"
label var marriage_contrary_i "Contrary to marriage x Roma"
label var bad_health "Bad health"
label var screening_initiative "Screening initiative"
label var screening_initiative1 "Screening initiative by anyone"
label var screening_initiative2 "Screening initiative by own initiative"
label var screening_initiative3 "Screening initiative by doctor invitation"
label var screening_initiative4 "Screening initiative by screening initiative"

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

help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



esttab a b c using f567.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for occurence of healthcare") nomtitles


*Logit - HEALTHCARE AVOIDANCE
*Health Behavior
eststo clear
eststo a: logit health_behavior community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood transp_healthcenter_minutes i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: logit  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab a b c  using d4r.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression for avoidance of healthcare") nomtitles




*Robustness checks: re-run the same regression for each country. 
eststo clear
corr community_support_n discrimination_ethnicity own_norms_n

*Different measures of screening_initiative
eststo clear
eststo d1: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood transp_healthcenter_minutes i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo e: logit screening_initiative2 community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ i.health_self  disability  walking_healthfacility i.country $type_neighbourhood transp_healthcenter_minutes i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo f: logit screening_initiative3 community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility transp_healthcenter_minutes i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo g: logit screening_initiative4 community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood transp_healthcenter_minutes i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab d1 e f g, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity  own_norms_n   sample ) stats(asset country neighbour health N, labels("Baseline controls""Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by decision")  mtitles("Anyone's initiative" "Own initiative" "Doctor's initiative" "Screening program")

*Difference between males and females
eststo clear
eststo r0: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample   health_insurance  age no_educ afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r1: logit  screening_initiative community_support_n  own_norms_n   discrimination_ethnicity sample  community_support_ni health_insurance  age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1 , vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo r2: logit  screening_initiative community_support_n  own_norms_n discrimination_ethnicity sample   health_insurance  age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0 , vce(cluster municipality_n)
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



*For health_behavior
eststo clear
eststo s1: logit health_behavior community_support_n community_support_ni own_norms_n  discrimination_ethnicity sample health_insurance  age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==1, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
eststo s2: logit health_behavior community_support_n community_support_ni own_norms_n  discrimination_ethnicity sample health_insurance  age no_educ  afford_n  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma if female==0, vce(cluster municipality_n)
estadd local base "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"
esttab s1 s2 , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  discrimination_ethnicity own_norms_n community_support_ni sample ) stats(base country neighbour health N, labels("Baseline controls" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by gender")  mtitles("Female" "Male")



*Different countries

eststo clear
eststo w1: logit  screening_initiative community_support_n    discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n  i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma  if country==1 , vce(cluster municipality_n)
estadd local neighbour "Yes"
estadd local health "Yes"

eststo w2: logit  screening_initiative community_support_n    discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma  if country==2 , vce(cluster municipality_n) 
estadd local municipality "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo w3: logit  screening_initiative community_support_n    discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma  if country==3 , vce(cluster municipality_n) 
estadd local municipality "Yes" 
estadd local neighbour "Yes"
estadd local health "Yes"


eststo w4: logit  screening_initiative community_support_n    discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma if country==4 , vce(cluster municipality_n) 
estadd local municipality "Yes" 
estadd local neighbour "Yes"
estadd local health "Yes"


eststo w5: logit  screening_initiative community_support_n    discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma  if country==5 , vce(cluster municipality_n) 
estadd local municipality "Yes" 
estadd local neighbour "Yes"
estadd local health "Yes"


eststo w6: logit  screening_initiative community_support_n    discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  $type_neighbourhood  i.asset_index i.percentage_of_roma  if country==6 , vce(cluster municipality_n) 
estadd local municipality "Yes" 
estadd local neighbour "Yes"
estadd local health "Yes"

esttab w1 w2 w3 w4 w5 w6 , replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  community_support_ni discrimination_ethnicity  sample  ) stats( neighbour health N, labels(  "Type of neighbourhood and house" "Health conditions" "Observations")) title("Logistic regression of occurrence of healthcare decomposed by country")  mtitles("Serbia" "Montenegro" "Albania" "Macedonia" "Kosovo" "Bosnia-Herzegovina")


*Alternative measures of community influence
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
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab c d using bfd5.tex, replace depvar eform legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support own_norms   community_support_i discrimination_ethnicity  sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Alternative measures of community influences") mtitle("Screening Initiative" "Avoidance of healthcare")


*Linear Probability model for screening initiative and healthcare avoidance 
eststo clear
eststo a: logit  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female lnage no_educ primary secondary food_insecurity afford_n environmental_conditions_n  i.health_self  disability grade_disability_n walking_healthfacility i.country $type_neighbourhood  i.fear_losinghouse i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo b: reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female lnage no_educ primary secondary food_insecurity afford_n environmental_conditions_n  i.health_self  disability grade_disability_n walking_healthfacility i.country $type_neighbourhood  i.fear_losinghouse i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo c: logit health_behavior community_support_n  sample own_norms_n discrimination_ethnicity  community_support_ni health_insurance female lnage no_educ primary secondary food_insecurity afford_n environmental_conditions_n   disability grade_disability_n walking_healthfacility i.country $type_neighbourhood  i.fear_losinghouse i.asset_index , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: reg health_behavior community_support_n  sample own_norms_n discrimination_ethnicity  community_support_ni health_insurance female lnage no_educ primary secondary food_insecurity afford_n environmental_conditions_n   disability grade_disability_n walking_healthfacility i.country $type_neighbourhood  i.fear_losinghouse i.asset_index , vce(cluster municipality_n)

estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

esttab a b c d, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n  community_support_ni discrimination_ethnicity  sample female lnage no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("linear Probability regression") mtitle("Logit occurrence" "Reg occurence" "Logit Avoidance" "Reg Avoidance")

*Pairwise correlation between measures of community influence
asdoc corr community_support_n own_norms_n discrimination_ethnicity, label replace
 
*****  
*Linear Probability model for occurrence of healthcare
eststo clear
eststo a: reg screening_initiative community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity discrimination_ethnicity_i sample health_insurance female age no_educ primary secondary afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo c: reg   screening_initiative community_support_n  own_norms_n  discrimination_ethnicity own_norms_ni sample health_insurance female age no_educ primary secondary afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo e:  reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni own_norms_ni  health_insurance female age no_educ  afford_n   i.health_self  disability walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab a b c d e using bvc5.tex, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity own_norms_ni sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear Probability Model for occurrence of healthcare") nomtitles

*LPM for healthcare avoidance 
eststo clear
eststo a: reg health_behavior community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo c: reg   health_behavior community_support_n  own_norms_n  discrimination_ethnicity own_norms_ni sample health_insurance female age no_educ afford_n i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"

eststo d: reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


esttab a b c d using bvf54.tex , replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity own_norms_ni sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear Probability model for avoidance of healthcare") nomtitles

*Comparing marginal effects of the probability model and logit 
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

esttab  c d a b using bvf.tex , replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n community_support_ni discrimination_ethnicity sample age female no_educ afford_n health_insurance  ) stats( base asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Marginal effects and Linear Probability Model results") mtitles("Marginal Effects" "LPM" "Marginal Effects" "LPM")


*Oster Strategy 
*FOR SCREENING INITIATIVE
*community_support_n 
*FULL MODEL

reg screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

gen  beta3=_b[community_support_ni]
gen beta2=_b[community_support_n]
gen R3= e(r2)  

*restricted MODEL 
reg screening_initiative community_support_n sample community_support_ni, vce(cluster municipality_n)
gen  beta4=_b[community_support_ni]
gen R2= e(r2) 
gen  beta1=_b[community_support_n]

*delta 
gen delta_community_ni=(beta3/(beta4-beta3))*((R3-R2)/(1.3*R3-R3)) 
gen delta_community=(beta2/(beta1-beta2))*((R3-R2)/(1.3*R3-R3)) 

*FOR HEALTHCARE AVOIDANCE

reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n  disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)

gen  beta5=_b[discrimination_ethnicity]
gen R4= e(r2)  
 
reg health_behavior discrimination_ethnicity, vce(cluster municipality_n)
gen beta6=_b[discrimination_ethnicity]
gen R5=e(r2)
gen delta_discrimination=(beta5/(beta6-beta5))*((R4-R5)/(1.3*R4-R4)) 


*Create Table
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
esttab a b c d using B3.tex, replace depvar legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n  community_support_ni discrimination_ethnicity  sample female age no_educ health_insurance afford_n) stats( base asset country neighbour health N r2 delta , labels("Baseline Controls""Asset-Index" "Country FE" "Type of neighbourhood" "Health conditions" "Observations" "Delta")) title("Marginal effects and Linear Probability Model results") mtitles("Restricted Regression" "Full regression" "Restricted Regression" "Full regression") mgroups(A B, pattern(1 0 1 0))

logit good_health community_support_n community_support_ni own_norms  discrimination_ethnicity  sample health_insurance female age no_educ afford_n   walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)


*Linear Probability model
eststo clear
eststo a: reg screening_initiative community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n  i.health_self  disability  walking_healthfacility i.country $type_neighbourhood   i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)

help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



esttab a b c using f577.tex, replace depvar  legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear probability model for occurence of healthcare") nomtitles


*healthcare avoidance 
eststo clear
eststo a: reg health_behavior community_support_n  sample  own_norms_n discrimination_ethnicity age no_educ female afford_n health_insurance i.country i.asset_index, vce(cluster municipality_n) 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "No"
estadd local health "No"


eststo b:  reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample health_insurance female age no_educ  afford_n   disability  walking_healthfacility i.country $type_neighbourhood  i.asset_index i.percentage_of_roma, vce(cluster municipality_n)
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"


eststo c: reg  health_behavior community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   disability  walking_healthfacility i.country $type_neighbourhood   i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
help logit 
estadd local asset "Yes"
estadd local country "Yes"
estadd local neighbour "Yes"
estadd local health "Yes"



esttab a b c  using d8r.tex, replace depvar  legend label nogaps b se star(* 0.10 ** 0.05 *** 0.01) keep(community_support_n  own_norms_n   community_support_ni discrimination_ethnicity sample female age no_educ health_insurance afford_n ) stats(asset country neighbour health N, labels("Asset-Index" "Country FE" "Type of neighbourhood and house" "Health conditions" "Observations")) title("Linear Probability model for avoidance of healthcare") nomtitles

reg  screening_initiative community_support_n  own_norms_n  discrimination_ethnicity sample  community_support_ni health_insurance female age no_educ afford_n   i.health_self  disability  walking_healthfacility  i.country $type_neighbourhood  i.asset_index i.percentage_of_roma , vce(cluster municipality_n)
asdoc vif
