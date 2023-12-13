# cleaning-data.R
#
# converted from STATA code using ChatGPT


library(haven)
library(dplyr)

# CREATE DATABASE
countries <- c("ALB", "BIH", "KOS", "MKD", "MNE", "SRB")

for (country in countries) {
  for (i in 1:6) {
    sav_name <- paste0(country, "_", i, ".sav")
    dta_name <- paste0(country, "_", i, ".dta")
    data <- haven::read_sav(sav_name, to_lowercase = TRUE)
    haven::write_dta(data, dta_name)
  }
}

# APPEND dataset
for (i in 1:6) {
  data_files <- c()
  
  for (country in countries) {
    dta_file <- paste0(country, "_", i, ".dta")
    data_files <- c(data_files, dta_file)
  }
  
  combined_data <- haven::read_dta(data_files[1])
  
  for (j in 2:length(data_files)) {
    data <- haven::read_dta(data_files[j])
    combined_data <- haven::append(combined_data, data)
  }
  
  save_file <- paste0("data_", i, ".dta")
  haven::write_dta(combined_data, save_file)
}

# MERGE
data_1 <- read_dta("data_1.dta")
data_1 <- subset(data_1, select = c("m8", "m9", "m11"))
colnames(data_1) <- c("type_residence", "type_house", "number_members")
data_1 <- subset(data_1, select = -c(type_house, number_members))
write_dta(data_1, "data_1.dta")

data_4 <- read_dta("data_4.dta")
data_4 <- subset(data_4, select = c("q1_1a", "q1_1b", "q1_1c", "q1_2", "q3_2", "q3_3", "q3_4", "q3_6_1", "q3_6_2", "q3_6_3",
                                    "q3_6_4", "q3_6_5", "q3_6_6", "q3_6_7", "q3_6_8", "q3_6_9", "q3_6_10", "q3_6_11", "q3_7_1",
                                    "q3_7_2", "q3_7_3", "q3_7_4", "q3_7_5", "q3_7_6", "q3_14", "q3_15"))
colnames(data_4) <- c("livinghere_5years", "livinghere_12months", "livinghere_6months", "comingfromothplace", "number_rooms",
                      "square_meters", "owner_house", "radio", "tv", "bike", "car", "horse", "computer", "internet", "phone",
                      "washingmachine", "bed_foreach", "books30", "powergenerator", "afford_rent", "afford_heating", "afford_holiday",
                      "afford_meat", "afford_unexpectedexpenses", "afford_drugs", "hungry", "economic_security")
write_dta(data_4, "data_4.dta")

data_2 <- read_dta("data_2.dta")
data_2 <- subset(data_2, select = c("a1", "a2", "a3", "a4", "a5", "a6", "a7", "a7_95_oth", "a8"))
colnames(data_2) <- c("sex", "age", "role", "marital", "age_marriage", "ethnicity", "religion", "religion_other", "activity")
write_dta(data_2, "data_2.dta")

data_5 <- read_dta("data_5.dta")
data_5 <- subset(data_5, select = c("b1", "b3_a", "b3_b", "b3_c", "b3_d"))
colnames(data_5) <- c("health_behavior", "dental_screening", "xray_screening", "cholesterol_screening", "heart_screening")
write_dta(data_5, "data_5.dta")

# merge the 4 different data sets I am using, data_3 and data_6 are not used
# They refer to Parenting techniques and additional sections on the attitudes of the household

# Before merge between data 2 and data 4
data_4 <- read.dta("data_4.dta")
data_2 <- read.dta("data_2.dta")
merged_data <- merge(data_4, data_2, by = c("country", "psu", "hh_id", "hhm_id"))

merged_data <- merged_data[merged_data$m1 == 3, ]

# with data 5 and 1
data_5 <- read.dta("data_5.dta")
data_1 <- read.dta("data_1.dta")

merged_data <- merge(merged_data, data_5, by = c("sample", "country", "psu", "hh_id"))
merged_data <- merge(merged_data, data_1, by = c("sample", "country", "psu", "hh_id"))

# Save merged data to dataDEF.dta
write.dta(merged_data, "dataDEF.dta")

# Order variables
merged_data <- merged_data[order(merged_data$hhm_id, merged_data$number_members, merged_data$sex, merged_data$role), ]
merged_data <- merged_data[order(merged_data$country, merged_data$psu, merged_data$hh_id), ]
write.dta(merged_data, "dataDEF.dta")

# Order municipality
merged_data <- merged_data[order(merged_data$municipality), ]
write.dta(merged_data, "dataDEF.dta")

# Fix gaps in data of municipalities, settlements, and komune variables
municipalities <-
  c("BIHAĆ",
    "BANJA LUKA",
    "BANOVIĆI",
    "BOSANSKA KRUPA",
    "BRČKO",
    "CENTAR SARAJEVO",
    "DOBOJ",
    "DONJI VAKUF",
    "GRAD MOSTAR",
    "GRAČANICA",
    "GRADAČAC",
    "GRADIŠKA",
    "ILIDŽA",
    "JAJCE",
    "KAKANJ",
    "KONJIC",
    "KALESIJA",
    "KISELJAK",
    "KLJUČ",
    "LUKAVAC",
    "MODRIČA",
    "NOVI GRAD SARAJEVO",
    "NOVO SARAJEVO",
    "PRIJEDOR",
    "TRAVNIK",
    "TUZLA",
    "VISOKO",
    "VITEZ",
    "VUKOSAVLJE",
    "ZAVIDOVIĆI",
    "ZENICA",
    "ŽIVINICE")

for (i in municipalities) {
  merged_data$settlement[merged_data$municipality == i] <- i
}

##TODO
# merged_data <-
#   merged_data %>%
#   mutate(settlement = coalesce(settlement, municipality))


merged_data$komune[merged_data$municipality == "Berat (qytet)"] <- "Berat (qytet)"
merged_data$komune[merged_data$municipality == "Ura e Kuçit"] <- "Ura e Kuçit"
merged_data$komune[merged_data$municipality == "Lagjia Stan/Moravë"] <- "Lagjia Stan/Moravë"
merged_data$komune[merged_data$municipality == "Kuçova"] <- "Kuçova"
merged_data$komune[merged_data$municipality == "Durrës"] <- "Durrës"
merged_data$komune[merged_data$municipality == "Shkozet (lagj.14)"] <- "Shkozet (lagj.14)"
merged_data$komune[merged_data$municipality == "Plazh (Mbikalimi)"] <- "Plazh (Mbikalimi)"
merged_data$komune[merged_data$municipality == "Qafa e ariut"] <- "Qafa e ariut"

komune_mapping <- c(
  "Allias/B.Curri",
  "Baltëz (komuna Derrmenas)",
  "Bilisht (Devoll)",
  "Bregu i lumit",
  "Cerrik",
  "Elbasan (qytet)",
  "Fushë-Kruja",
  "Gjirokaster",
  "Josif Pashko/ Nish.Tulla Nr.3",
  "Kinostudio",
  "Komuna Grabian",
  "Korça (qytet) Shkolla Naim Frasheri",
  "Kombinat/Yzberisht",
  "Lagj. Qender Azotik",
  "Levan (Komuna)",
  "Laç",
  "Lezhë (Rome+Egjiptiane)",
  "Maliq (Korçë)",
  "Mbrostar Ura",
  "Peqin",
  "Pluk",
  "N/stacioni elektrik",
  "Pojani (Korçë)",
  "Pogradec (Qytet)",
  "Roskoveci",
  "Rrogozhina",
  "5 maji (Rapishte)",
  "Seman",
  "Shengjini",
  "Shkodër (dy krahet e lumit Buna)",
  "Seliata",
  "Sovjan (Korçë)"
)

merged_data$municipality <- komune_mapping[match(merged_data$komune, komune_mapping)]


#
merged_data$municipality[merged_data$settlement == "Prilep"] <- "Prilep"
merged_data$municipality[merged_data$settlement == "Vataša"] <- "Vataša"
merged_data$municipality[merged_data$settlement == "Kavadarci"] <- "Kavadarci"
merged_data$municipality[merged_data$settlement == "Bitola"] <- "Bitola"
merged_data$municipality[merged_data$settlement == "Skopje - Šuto Orizari"] <- "Skopje - Šuto Orizari"
merged_data$municipality[merged_data$settlement == "Skopje - Saraj"] <- "Skopje - Saraj"
merged_data$municipality[merged_data$settlement == "Selo Dračevo"] <- "Selo Dračevo"
merged_data$municipality[merged_data$settlement == "Naselba Dračevo"] <- "Naselba Dračevo"

                   
                   