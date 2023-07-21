# Load required libraries
library(foreign)
library(estimatr)
library(sandwich)
library(lmtest)
library(stargazer)
library(dplyr)
library(ggplot2)
library(reshape2)
library(psych)
library(tidyr)

# Read the Stata dataset
data <- haven::read_dta("../data/dataDEF.dta")

country_labels <- names(attributes(data$country)$labels)
sample_labels <- names(attributes(data$sample)$labels)

data$country_labels <- country_labels[data$country]
data$sample_labels <- sample_labels[data$sample+1]

# First table - Percentage of Roma for each country
tab <- as.data.frame(table(data$sample, data$country))
colnames(tab) <- c("sample", "country", "count")
tab

# Presentation of DEPENDENT VARIABLES.

# 1) Screening initiative
data$screening_initiative <- ifelse(data$screening > 0, 1, 0)
data$screening_initiative <- ifelse(data$screening_initiative != 1, 0, 1)

data$screening_initiative_roma <- ifelse(data$screening_initiative == 1 & data$sample == 1, 1, 0)
data$screening_initiative_roma <- ifelse(data$screening_initiative == 0 & data$sample == 1, 0, 1)

data$screening_initiative_non <- ifelse(data$screening_initiative == 1 & data$sample == 2, 1, 0)
data$screening_initiative_non <- ifelse(data$screening_initiative == 0 & data$sample == 2, 0, 1)

plot_dat <- data |>
  group_by(country_labels, sample_labels) |> 
  summarise(prop = sum(screening_initiative, na.rm = TRUE)/n(),
            n = n()) |> 
  mutate(low = prop - 1.96*sqrt(prop*(1-prop)/n),
         upp = prop + 1.96*sqrt(prop*(1-prop)/n))

# Graph bar
ggplot(plot_dat, aes(x = country_labels, y = prop, fill = factor(sample_labels))) +
  geom_bar(stat="identity", position="dodge") +
  labs(title = "Access to healthcare services") +
  labs(fill = "Screening initiative") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

ggsave("../plots/barplot_healthcare_access.png", width = 8, height = 7)

# box plot
ggplot(plot_dat, aes(country_labels, prop)) +
  geom_errorbar(
    aes(ymin = low, ymax = upp, color = factor(sample_labels)),
    position = position_dodge(0.3), width = 0.2) +
  ylim(0,1) +
  geom_point(aes(color = factor(sample_labels)), position = position_dodge(0.3)) +
  scale_color_manual(values = c("#00AFBB", "#E7B800")) 

ggsave("../plots/boxplot_healthcare_access.png", width = 8, height = 7)

# 2) Health behavior
tab_health_behavior <- as.data.frame(table(data$health_behavior))
colnames(tab_health_behavior) <- c("health_behavior", "count")
tab_health_behavior

data$health_behavior_roma <- ifelse(data$health_behavior == 1 & data$sample == 1, 1, 0)
data$health_behavior_roma <- ifelse(data$health_behavior == 0 & data$sample == 1, 0, 1)

data$health_behavior_non <- ifelse(data$health_behavior == 1 & data$sample == 2, 1, 0)
data$health_behavior_non <- ifelse(data$health_behavior == 0 & data$sample == 2, 0, 1)

plot_dat <- data |>
  group_by(country_labels, sample_labels) |> 
  summarise(prop = sum(health_behavior, na.rm = TRUE)/n(),
            n = n()) |> 
  mutate(low = prop - 1.96*sqrt(prop*(1-prop)/n),
         upp = prop + 1.96*sqrt(prop*(1-prop)/n))

# Graph bar
ggplot(plot_dat, aes(x = country_labels, y = prop, fill = factor(sample_labels))) +
  geom_bar(stat="identity", position="dodge") +
  labs(title = "Unmet needs of medical care") +
  labs(fill = "Health-care avoidance") +
  theme_bw()

ggsave("../plots/barplot_unmet_need.png", width = 8, height = 7)

# box plot
ggplot(plot_dat, aes(country_labels, prop)) +
  geom_errorbar(
    aes(ymin = low, ymax = upp, color = factor(sample_labels)),
    position = position_dodge(0.3), width = 0.2) +
  ylim(0,1) +
  geom_point(aes(color = factor(sample_labels)), position = position_dodge(0.3)) +
  scale_color_manual(values = c("#00AFBB", "#E7B800")) 

ggsave("../plots/boxplot_unmet_need.png", width = 8, height = 7)


################
# summary table

variable_names <- c("discrimination_ethnicity", "age", "no_educ", "female", "afford_n", "health_insurance", "country")

tab_01 <- data |> 
  select(all_of(c("sample", variable_names))) |> 
  group_by(sample) |> 
  summarise(across(all_of(variable_names), \(x) mean(x, na.rm = TRUE))) |> 
  mutate(sample = as.character(sample)) |> 
  tibble::column_to_rownames(var = "sample")

tab_all <- data |> 
  select(all_of(c("sample", variable_names))) |> 
  summarise(across(all_of(variable_names), \(x) mean(x, na.rm = TRUE))) |> 
  mutate(sample = "All") |> 
  tibble::column_to_rownames(var = "sample")

summary_tab <- 
  bind_rows(tab_all, tab_01) |>
  t() |>
  as.data.frame() |> 
  mutate(across(all_of(c("All", "0", "1")), \(x) round(x, 2)),
         diff = `0` - `1`)

write.csv(summary_tab, file = "../output/summary_tab.csv")


########################################
# Presentation of EXPLANATORY VARIABLES

# 1) Community support
data$community_support <- ifelse(data$first_support > 0 | data$second_support > 0 | data$third_support > 0, 1, 0)
data$community_support_n <- (data$community_support - 0) / 3

tab_community_support_n <- as.data.frame(table(data$community_support_n, data$sample))
colnames(tab_community_support_n) <- c("community_support_n", "sample", "count")
tab_community_support_n
data <- subset(data, select = -c(first_support, second_support, third_support, community_support))

# 2) Follow Own norms
data$citizenbribe_acceptance <- ifelse(data$citizenbribe_acceptance > 3, NA, data$citizenbribe_acceptance)
data$citizenbribe_acceptance <- ifelse(data$citizenbribe_acceptance == 3 | data$citizenbribe_acceptance == 2, 0, data$citizenbribe_acceptance)

data$notaxes_acceptance <- ifelse(data$notaxes_acceptance > 3, NA, data$notaxes_acceptance)
data$notaxes_acceptance <- ifelse(data$notaxes_acceptance == 3 | data$notaxes_acceptance == 2, 0, data$notaxes_acceptance)

data$officialbribe_acceptance <- ifelse(data$officialbribe_acceptance > 3, NA, data$officialbribe_acceptance)
data$officialbribe_acceptance <- ifelse(data$officialbribe_acceptance == 3 | data$officialbribe_acceptance == 2, 0, data$officialbribe_acceptance)

data$stealingfood_acceptance <- ifelse(data$stealingfood_acceptance > 3, NA, data$stealingfood_acceptance)
data$stealingfood_acceptance <- ifelse(data$stealingfood_acceptance == 2 | data)
                                       
# Generate Table 2: Explanatory Variables

# Perform t-test
s4 <- t.test(community_support_n ~ sample)
s4 <- cbind(s4$estimate[1:2], s4$stderr[1:2])

# Create a data frame for the table
table_data <- data.frame(
  Roma = s4[1, 1:2],
  Non_Roma = s4[2, 1:2]
)

# Set the row names
rownames(table_data) <- c("Community support", "Own norms")

# Create column names
colnames(table_data) <- c("Mean", "SE")

# Print the table
stargazer(table_data, title = "Explanatory variables", column.labels = c("Roma", "Non-Roma"), digits = 2, header = TRUE)

# Create interaction terms for explanatory variables
data$community_support_ni <- data$sample * data$community_support_n
data$own_norms_ni <- data$sample * data$own_norms_n
data$discrimination_ethnicity_i <- data$discrimination_ethnicity * data$sample

# Label variables
label(data$community_support_n) <- "Community support"
label(data$community_support_ni) <- "Community support x Roma"
label(data$own_norms_n) <- "Follow own norms"
label(data$own_norms_ni) <- "Follow own norms x Roma"
label(data$discrimination_ethnicity) <- "Ethnic discrimination"
label(data$discrimination_ethnicity_i) <- "Discriminated for ethnicity x Roma"

# ADDITIONAL CONTROLS

# Create an asset index

data <- data.frame(
  radio, tv, bike, car, horse, computer, internet, phone, washingmachine,
  bed_foreach, books30, powergenerator, kitchen, piped, toilet, wastewater,
  bathroom, electricity, heating
)
kmo <- KMO(data)
comp1 <- principal(data)$values[, 1]
hist(comp1)
colnames(comp1) <- "asset_score"
xtile(asset_index <- comp1, n = 5)

# Label asset index variable
levels(asset_index) <- c("Poorest", "Poorer", "Middle", "Richer", "Richest")
label(asset_index) <- "Asset index"

# Create Table 3 "Characteristics of the respondents"
label(age) <- "Age"
label(educ_years) <- "Educational years"
label(unemployed) <- "Unemployed"
label(food_insecurity) <- "Food insecurity"
label(health_insurance) <- "Health insurance"
label(good_health) <- "Self-reported good health"
label(health_behavior) <- "Avoidance of medical screening"
label(female) <- "Percentage of females"
label(afford_n) <- "Economic security"

# Subset the data for different samples
summary_data1 <- subset(data, sample == 1)
summary_data0 <- subset(data, sample == 0)

# Print the summary statistics using stargazer
stargazer(summary_data1, title = "Sample 1 Characteristics", digits = 2, type = "text")
stargazer(summary_data0, title = "Sample 0 Characteristics", digits = 2, type = "text")

# EMPIRICAL ANALYSIS

# 1) Occurrence of health services

# a) Logistic regression for occurrence of healthcare (Table 4)
type_neighbourhood <- c("town", "village", "capital", "city", "unregulated_area")

# Run logistic regression model
model <- glm(screening_initiative ~ community_support_n + sample + own_norms_n + discrimination_ethnicity + age + no_educ + female + afford_n + health_insurance + country + asset_index, data = data, family = "binomial")

# Cluster-robust standard errors
vcov <- sandwich::vcovCL(model, cluster = data$municipality_n)

# Create a table with coefficient estimates
coef_table <- cbind(coef(model), sqrt(diag(vcov)))

# Print the table
stargazer(coef_table, title = "Logistic Regression Results", column.labels = c("Estimate", "SE"), digits = 2, header = TRUE)
