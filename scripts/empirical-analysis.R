
# Roma regressions
# translated from original STATA code

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

# Read Stata dataset
data <- haven::read_dta("../data/dataDEF.dta")

country_labels <- names(attributes(data$country)$labels)
sample_labels <- names(attributes(data$sample)$labels)

data$country_labels <- country_labels[data$country]
data$sample_labels <- sample_labels[data$sample + 1]

# 1) Screening initiative
# 0-4, NA
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

tab_var_names <- c("discrimination_ethnicity", "age", "no_educ", "female", "afford_n", "health_insurance", "country")

tab_01 <- data |> 
  select(all_of(c("sample", tab_var_names))) |> 
  group_by(sample) |> 
  summarise(across(all_of(tab_var_names), \(x) mean(x, na.rm = TRUE))) |> 
  mutate(sample = as.character(sample)) |> 
  tibble::column_to_rownames(var = "sample")

tab_all <- data |> 
  select(all_of(c("sample", tab_var_names))) |> 
  summarise(across(all_of(tab_var_names), \(x) mean(x, na.rm = TRUE))) |> 
  mutate(sample = "All") |> 
  tibble::column_to_rownames(var = "sample")

summary_tab <- 
  bind_rows(tab_all, tab_01) |>
  t() |>
  as.data.frame() |> 
  mutate(diff = `0` - `1`,
         across(all_of(c("All", "0", "1", "diff")), \(x) round(x, 2))) |> 
  rename(`Non-Roma` = `0`, Roma = `1`)

write.csv(summary_tab, file = "../output/summary_tab.csv")

# alternatively
###TODO:
# stargazer(data, type = "text", summary = TRUE)

# this seems to be a nice option
##TODO: split into Roma/non-Roma columns
psych::describe(data)

########################################
# Presentation of EXPLANATORY VARIABLES

# 1) Community support
# value           label
# 1                      A friend
# 2             A relative/family
# 3                      Employer
# 4   A rich man in the community
# 5 Social assistance institution
# 6                        A bank
# 7    A microfinance institution
# 8                     Local NGO
# 95                         Other
# 96                        No one
# 888998    RF/DK (Refused/Don't Know)

##TODO: should this be 96: No one?
## does NA mean No one?
## if the first one if No one then it doesnt make sense to have anything for the others
## similarly for second_support
data$community_support <- ifelse(data$first_support > 0 | data$second_support > 0 | data$third_support > 0, 1, 0)
data$community_support <- data$first_support != 96 | data$second_support != 96 | data$third_support != 96

##TODO: why do this?
data$community_support_n <- (data$community_support - 0) / 3

# data <- subset(data, select = -c(first_support, second_support, third_support, community_support))

# 2) Follow Own norms
# value       label
# 1          Always acceptable
# 2       Sometimes acceptable
# 3           Never acceptable
# 888998 RF/DK (Refused/Don't Know)

data$citizenbribe_acceptance <- ifelse(data$citizenbribe_acceptance > 3, NA, data$citizenbribe_acceptance)
data$citizenbribe_acceptance <- ifelse(data$citizenbribe_acceptance == 3 | data$citizenbribe_acceptance == 2, 0, data$citizenbribe_acceptance)

data$notaxes_acceptance <- ifelse(data$notaxes_acceptance > 3, NA, data$notaxes_acceptance)
data$notaxes_acceptance <- ifelse(data$notaxes_acceptance == 3 | data$notaxes_acceptance == 2, 0, data$notaxes_acceptance)

data$officialbribe_acceptance <- ifelse(data$officialbribe_acceptance > 3, NA, data$officialbribe_acceptance)
data$officialbribe_acceptance <- ifelse(data$officialbribe_acceptance == 3 | data$officialbribe_acceptance == 2, 0, data$officialbribe_acceptance)

data$stealingfood_acceptance <- ifelse(data$stealingfood_acceptance > 3, NA, data$stealingfood_acceptance)

##Error
data$stealingfood_acceptance <- ifelse(data$stealingfood_acceptance == 2 | data)

# Create an asset index
data_asset <- data.frame(
  radio, tv, bike, car, horse, computer, internet, phone, washingmachine,
  bed_foreach, books30, powergenerator, kitchen, piped, toilet, wastewater,
  bathroom, electricity, heating)

# Measure of Sampling Adequacy
kmo <- KMO(data_asset)
comp1 <- principal(data_asset)$values[, 1]
hist(comp1)
colnames(comp1) <- "asset_score"
xtile(asset_index <- comp1, n = 5)

levels(asset_index) <- c("Poorest", "Poorer", "Middle", "Richer", "Richest")

data_Roma <- subset(data, sample == 1)
data_nonRoma <- subset(data, sample == 0)

# summary statistics using stargazer
stargazer(data_Roma, title = "Sample 1 Characteristics", digits = 2, type = "text")
stargazer(data_nonRoma, title = "Sample 0 Characteristics", digits = 2, type = "text")

type_neighbourhood <- c("town", "village", "capital", "city", "unregulated_area")

##############
# regressions
##############

# 1) Occurrence of health services

# logistic regression model
##TODO: interaction term for sample*community_support?

model0_si <- glm(screening_initiative ~ community_support_n*sample,
                 data = data, family = "binomial")

model_si <- glm(screening_initiative ~ community_support_n + sample + own_norms_n + discrimination_ethnicity + age + no_educ + female + afford_n + health_insurance + country + asset_index,
                data = data, family = "binomial")

# Cluster-robust standard errors
vcov <- sandwich::vcovCL(model_si, cluster = data$municipality_n)

# Create a table with coefficient estimates
coef_table <- cbind(coef(model_si), sqrt(diag(vcov)))

stargazer(coef_table, title = "Logistic Regression Results", column.labels = c("Estimate", "SE"), digits = 2, header = TRUE)

# 2) Health behaviour

model0_hb <- glm(health_behavior ~ community_support*sample,
                 data = data, family = "binomial")

