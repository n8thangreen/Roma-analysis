
# Roma regressions
# translated from original STATA code
# Empirical Analysis_ Do File.do

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
sample_labels <- names(attributes(data$sample)$labels)   # Roma/Non-Roma

data$country_labels <- country_labels[data$country]
data$sample_labels <- sample_labels[data$sample + 1]

# 1) Screening initiative
# occurrence of medical services received
# previous 12 months medical check-ups part of any consultation:
# 
# 0 None  
# 1 dental check-up
# 2 x-ray, ultrasound or other scan
# 3 cholesterol test
# 4 heart check-up
# NA
#
# 1 if >0 screening
# 0 otherwise

data$screening_initiative <- ifelse(data$screening > 0, 1, 0)
data$screening_initiative <- ifelse(data$screening_initiative != 1, 0, 1)  ##TODO: is this to replace NA with 0?

# intersection of screening and identity
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

# bar chart
ggplot(plot_dat, aes(x = country_labels, y = prop, fill = factor(sample_labels))) +
  geom_bar(stat="identity", position="dodge") +
  labs(title = "Access to healthcare services") +
  labs(fill = "Screening initiative") +
  theme_bw() +
  xlab("Country") +
  ylab("Proportion") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

ggsave("../plots/barplot_healthcare_access.png", width = 8, height = 7)

# box plot
ggplot(plot_dat, aes(country_labels, prop)) +
  geom_errorbar(
    aes(ymin = low, ymax = upp, color = factor(sample_labels)),
    position = position_dodge(0.3), width = 0.2) +
  ylim(0,1) +
  xlab("Country") +
  ylab("Proportion") +
  geom_point(aes(color = factor(sample_labels)), position = position_dodge(0.3)) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  scale_color_discrete(name = "") +
  scale_color_manual(values = c("#00AFBB", "#E7B800")) +
  scale_color_discrete(name = "")

ggsave("../plots/boxplot_healthcare_access.png", width = 8, height = 7)

# 2) Health behavior
# individuals are aware of needing health consultation, but decide to avoid it
# value          label
# 1              Yes - felt need of a medical and avoided
# 0              No
# 888997         DK (Don't Know)
# 888998         RF (Refused)

# intersection of health avoidance and identity
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

# bar chart
ggplot(plot_dat, aes(x = country_labels, y = prop, fill = factor(sample_labels))) +
  geom_bar(stat="identity", position="dodge") +
  labs(title = "Unmet needs of medical care") +
  labs(fill = "Health-care avoidance") +
  xlab("Country") +
  ylab("Proportion") +
  theme_bw()

ggsave("../plots/barplot_unmet_need.png", width = 8, height = 7)

# box plot
ggplot(plot_dat, aes(country_labels, prop)) +
  geom_errorbar(
    aes(ymin = low, ymax = upp, color = factor(sample_labels)),
    position = position_dodge(0.3), width = 0.2) +
  ylim(0,1) +
  xlab("Country") +
  ylab("Proportion") +
  geom_point(aes(color = factor(sample_labels)), position = position_dodge(0.3)) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  scale_color_manual(values = c("#00AFBB", "#E7B800")) +
  scale_color_discrete(name = "")

ggsave("../plots/boxplot_unmet_need.png", width = 8, height = 7)


################
# summary table

tab_var_names <- c("discrimination_ethnicity", "age", "no_educ", "female", "afford_n", "health_insurance")# , "country")

tab_01 <- data |> 
  select(all_of(c("sample", tab_var_names))) |> 
  group_by(sample) |> 
  summarise(across(all_of(tab_var_names), list(mean = \(x) mean(x, na.rm = TRUE),
                                               sd = \(x) sd(x, na.rm = TRUE)), .names = "{.col}.{.fn}")
            # summarise(across(all_of(tab_var_names), \(x) mean(x, na.rm = TRUE)),
            # n = n()
  ) |> 
  mutate(sample = as.character(sample)) |> 
  tibble::column_to_rownames(var = "sample")

tab_all <- data |> 
  select(all_of(c("sample", tab_var_names))) |> 
  summarise(across(all_of(tab_var_names), list(mean = \(x) mean(x, na.rm = TRUE),
                                               sd = \(x) sd(x, na.rm = TRUE)), .names = "{.col}.{.fn}"),
            # summarise(across(all_of(tab_var_names), \(x) mean(x, na.rm = TRUE)), 
            # n = n()
  ) |> 
  mutate(sample = "All") |> 
  tibble::column_to_rownames(var = "sample")

summary_tab <- 
  bind_rows(tab_all, tab_01) |>
  t() |>
  as.data.frame() |> 
  mutate(Diff = `0` - `1`,
         across(all_of(c("All", "0", "1", "Diff")), \(x) round(x, 2))) |> 
  rename(`Non-Roma` = `0`, Roma = `1`) |> 
  # # normal approximation of binomial
  # mutate(`Var Non-Roma` = signif(2168*`Non-Roma`*(1-`Non-Roma`), 3),
  #        `Var Roma` = signif(4592*`Roma`*(1-`Roma`), 3),
  #        `SD total` = signif(sqrt(`Var Roma` + `Var Non-Roma`), 3),
  #        p = signif(dnorm(Diff, mean = 0, sd = `SD total`), 3),
  #        Signif = ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", "")))
  tibble::rownames_to_column(var = "name") |> 
  separate(name, c("variable", "stat"), sep = "\\.") |> 
  data.table::setDT() |> 
  data.table::dcast(variable ~ stat, value.var = c("All", "Non-Roma", "Roma", "Diff")) |> 
  mutate(
    `sd total` = signif(sqrt(Roma_sd^2 + `Non-Roma_sd`^2), 3),
    p = ifelse(variable == "age",
      signif(dnorm(Diff_mean, mean = 0, sd = `sd total`), 3),
        # two-proportions z-test
      signif(2*pnorm(abs(Diff_mean)/sqrt(All_mean*(1-All_mean)*(1/4592 + 1/2168)), lower.tail = FALSE), 3)
      ),
    Signif = ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", "")),
    # clean covariate names
    variable = gsub("_", " ", variable) |> stringr::str_to_sentence())

summary_tab

write.csv(summary_tab, file = "../output/summary_tab.csv")

# alternatively
###TODO:
# stargazer(data, type = "text", summary = TRUE)

# this seems to be a nice option
##TODO: split into Roma/non-Roma columns
psych::describe(data[, tab_var_names])

########################################

# 1) community_support

# first_support:
# value                  label
# 1                      A friend
# 2             A relative/family
# 3                      Employer
# 4   A rich man in the community
# 5 Social assistance institution
# 6                        A bank
# 7    A microfinance institution
# 8                     Local NGO
# 95                        Other
# 96                       No one
# 888998    RF/DK (Refused/Don't Know)

##TODO: should this be 96: No one?
## does <NA> mean 888998 or `No one`?
## if the first one if `No one` then it doesnt make sense to have anything for the others?
## similarly for second_support?
## would community be friend, family, rich man in community only?

# data$community_support <- ifelse(data$first_support > 0 | data$second_support > 0 | data$third_support > 0, 1, 0)

##TODO: assume that NA is 888998
data$community_support <-
  !data$first_support %in% c(96,888998,NA) |
  !data$second_support %in% c(96,888998,NA) |
  !data$third_support %in% c(96,888998,NA)


##TODO: why do this?
data$community_support_n <- (data$community_support - 0) / 3

# data <- subset(data, select = -c(first_support, second_support, third_support, community_support))

# 2) Follow Own norms

# value       label
# 1           Always acceptable
# 2           Sometimes acceptable
# 3           Never acceptable
# 888998 RF/DK (Refused/Don't Know)

##TODO: rename these variables so not overwriting original?

# replace RF/DK with NA
data$citizenbribe_acceptance <- ifelse(data$citizenbribe_acceptance > 3, NA, data$citizenbribe_acceptance)
data$notaxes_acceptance <- ifelse(data$notaxes_acceptance > 3, NA, data$notaxes_acceptance)
data$officialbribe_acceptance <- ifelse(data$officialbribe_acceptance > 3, NA, data$officialbribe_acceptance)
data$stealingfood_acceptance <- ifelse(data$stealingfood_acceptance > 3, NA, data$stealingfood_acceptance)

# is never acceptable?
data$citizenbribe_acceptance <- !data$citizenbribe_acceptance %in% c(2,3)
data$notaxes_acceptance <- !data$notaxes_acceptance %in% c(2,3)
data$officialbribe_acceptance <- !data$officialbribe_acceptance %in% c(2,3)
data$stealingfood_acceptance <- !data$stealingfood_acceptance %in% c(2,3)

own_norms <- any(citizenbribe_acceptance, notaxes_acceptance, officialbribe_acceptance, stealingfood_acceptance)
own_norms_n <- (own_norms - 0)/4

###############################
# create asset index using PCA

data_asset <- with(data, tibble(
  radio, tv, bike, car, horse, computer, internet, phone, washingmachine,
  bed_foreach, books30, powergenerator, kitchen, piped, toilet, wastewater,
  bathroom, electricity, heating))

# measure of sampling adequacy
kmo <- psych::KMO(data_asset)

pca_res <- psych::principal(data_asset)
asset_scores <- pca_res$scores
asset_quantiles <- quantile(asset_scores, na.rm = TRUE)
asset_index <- cut(asset_scores, breaks = asset_quantiles)
levels(asset_index) <- c("Poorest", "Poorer", "Middle", "Richer", "Richest")

data_Roma <- subset(data, sample == 1)
data_nonRoma <- subset(data, sample == 0)

type_neighbourhood <- c("town", "village", "capital", "city", "unregulated_area")

##TODO:
# # summary statistics using stargazer
# stargazer(data_Roma, title = "Sample 1 Characteristics", digits = 2, type = "text")
# stargazer(data_nonRoma, title = "Sample 0 Characteristics", digits = 2, type = "text")


##############
# regressions
##############

## 1) Occurrence of health services

# logistic regression model
##TODO: interaction term for sample*community_support?

model0_si <- glm(screening_initiative ~ community_support_n*sample,
                 data = data, family = "binomial")

model_si <- glm(screening_initiative ~ community_support_n + sample + discrimination_ethnicity +  # own_norms_n +
                  age + no_educ + female + afford_n + health_insurance + country + asset_index,
                data = data, family = "binomial")

# cluster-robust standard errors
vcov <- sandwich::vcovCL(model_si, cluster = data$municipality_n)

# table with coefficient estimates
coef_table <- cbind(coef(model_si), sqrt(diag(vcov)))

# output table
stargazer(coef_table, title = "Logistic regression health services results", column.labels = c("Estimate", "SE"),
          digits = 2, header = TRUE, type = "text")

## 2) Health behaviour

model0_hb <- glm(health_behavior ~ community_support*sample,
                 data = data, family = "binomial")

stargazer(model0_hb, title = "Logistic regression health behaviour results", column.labels = c("Estimate", "SE"),
          digits = 2, header = TRUE, type = "text")
