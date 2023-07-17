# Load required libraries
library(foreign)
library(estimatr)
library(sandwich)
library(lmtest)
library(stargazer)
library(dplyr)
library(ggplot2)
library(reshape2)

# Read the Stata dataset
data <- haven::read_dta("dataDEF.dta")

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
  summarise(prop = sum(screening_initiative)/n())

# Graph bar
ggplot(plot_dat, aes(x = country_labels, y = prop, fill = factor(sample_labels))) +
  geom_bar(stat="identity", position="dodge") +
  labs(title = "Access to healthcare services") +
  labs(fill = "Screening initiative") +
  theme_bw()


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
  summarise(prop = sum(health_behavior, na.rm = TRUE)/n())

# Graph bar
ggplot(plot_dat, aes(x = country_labels, y = prop, fill = factor(sample_labels))) +
  geom_bar(stat="identity", position="dodge") +
  labs(title = "Unmet needs of medical care") +
  labs(fill = "Health-care avoidance") +
  theme_bw()


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
                                       
                                       