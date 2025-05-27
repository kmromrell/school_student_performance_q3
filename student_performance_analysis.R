# Set up environment

install.packages("tidyverse")                   
install.packages("ggplot2")
install.packages("ggpubr")
install.packages("broom")
install.packages("AICcmodavg")
install.packages("skimr")
install.packages("relaimpo")
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(broom)
library(AICcmodavg)
library(skimr)
library(relaimpo)

# Explore data
skim_without_charts(all_student_data)

# Single ANOVAs

ell_an<- aov(grade_point_dec ~ ell, data = all_student_data)
sped_an<- aov(grade_point_dec ~ sped, data = all_student_data)
sec_504_an<- aov(grade_point_dec ~ sec_504, data = all_student_data)
tag_an<- aov(grade_point_dec ~ tag, data = all_student_data)
grade_level_an<- aov(grade_point_dec ~ grade_level, data = all_student_data)
gender_an<- aov(grade_point_dec ~ gender, data = all_student_data)
ell_an<- aov(grade_point_dec ~ ab, data = all_student_data)
att_an<-aov(grade_point_dec ~ absence_rate, data = all_student_data)



summary(ell_an)
summary(sped_an)
summary(sec_504_an)
summary(tag_an)
summary(grade_level_an)
summary(gender_an)
summary(att_an)

# Linear Regression

lin_reg_atten<-lm(formula=grade_point_dec ~ absences, data=all_student_data)
lin_reg_tar<-lm(formula=grade_point_dec ~ tardies, data=all_student_data)
lin_reg_ell<-lm(formula=grade_point_dec ~ ell, data=all_student_data)
lin_reg_sped<-lm(formula=grade_point_dec ~ sped, data=all_student_data)
lin_reg_sec_504<-lm(formula=grade_point_dec ~ sec_504, data=all_student_data)
lin_reg_tag<-lm(formula=grade_point_dec ~ tag, data=all_student_data)


summary(lin_reg_atten)
summary(lin_reg_tar)
summary(lin_reg_ell)
summary(lin_reg_sped)
summary(lin_reg_sec_504)
summary(lin_reg_tag)

# Multiple Linear Regression
mult_reg_atten_tar<-lm(formula=grade_point_dec ~ absences + tardies + ss_absences, data=all_student_data)
mult_reg_all<-lm(formula=grade_point_dec ~ absences + tardies + ell + sped + sec_504 + tag + ss_absences + gender_male + gender_female + gender_nonbinary, data=all_student_data)
mult_reg_pass<-lm(formula=pass_or_fail ~ absences + tardies + ell + sped + sec_504 + tag + ss_absences, data=all_student_data)
mult_reg_c<-lm(formula=c_or_higher ~ absences + tardies + ell + sped + sec_504 + tag + ss_absences, data=all_student_data)


summary(mult_reg_atten_tar)
summary(mult_reg_all)
summary(mult_reg_pass)
summary(mult_reg_c)


# Trying it with AI

# Re-label absence_rate with descriptions for the legend
grade_by_absence <- grade_by_absence %>%
  mutate(
    absence_rate_desc = factor(
      absence_rate,
      levels = c("low", "medium", "high", "very high"),
      labels = c(
        "Low (0-9%)",
        "Medium (10-19%)",
        "High (20-39%)",
        "Very High (40%+)"
      )
    )
  )

#Plot grade point by absence rate

ggplot(grade_by_absence, aes(x = absence_rate_desc,
                             y = mean_grade_point,
                             fill = absence_rate_desc)) +
  geom_col() +
  geom_text(aes(label = round(mean_grade_point, 2)), vjust = -0.5, size = 4) +
  geom_text(aes(label = paste0("n=", count)), vjust = 1.5, color = "white", size = 3) +
  scale_fill_manual(values = c(
    "Low (0-9%)" = "#3CB371",
    "Medium (10-19%)" = "gold",
    "High (20-39%)" = "orange",
    "Very High (40%+)" = "red"
  )) +
  labs(
    title = "Average Grade Point by Student Absence Category",
    x = "Absence Category",
    y = "Average Grade Point"
  ) +
  coord_cartesian(ylim = c(0, 4)) +  # keeps all data but y-axis max at 4
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(margin = margin(t = 5))  # moves x-axis labels up (reduce distance)
  )

# Summarize pass rate by absence category
pass_by_absence <- all_student_data %>%
  group_by(absence_rate) %>%
  summarise(
    pass_rate = mean(pass_or_fail),
    count = n()
  ) %>%
  mutate(
    absence_rate_desc = factor(
      absence_rate,
      levels = c("low", "medium", "high", "very high"),
      labels = c(
        "Low (0-9%)",
        "Medium (10-19%)",
        "High (20-39%)",
        "Very High (40%+)"
      )
    )
  )

#Plot pass rate by absence rate
ggplot(pass_by_absence, aes(x = absence_rate_desc,
                            y = pass_rate,
                            fill = absence_rate_desc)) +
  geom_col() +
  geom_text(aes(label = scales::percent(pass_rate, accuracy = 1)), vjust = -0.5, size = 4) +  # Pass rate as %
  geom_text(aes(label = paste0("n=", count)), vjust = 1.5, color = "white", size = 3) +    # Sample size inside bars
  scale_fill_manual(values = c(
    "Low (0-9%)" = "#3CB371",
    "Medium (10-19%)" = "gold",
    "High (20-39%)" = "orange",
    "Very High (40%+)" = "red"
  )) +
  labs(
    title = "Pass Rate by Student Absence Category",
    x = "Absence Category",
    y = "Pass Rate"
  ) +
  coord_cartesian(ylim = c(0, 1)) +  # y-axis from 0 to 100%
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(margin = margin(t = 5))
  )

library(dplyr)
library(ggplot2)
library(scales)

# Filter for core_req == 1 and calculate mean grade point by absence_rate
grade_by_absence_core <- all_with_core %>%
  filter(core_req == 1) %>%
  group_by(absence_rate) %>%
  summarise(
    mean_grade_point = mean(grade_point_dec, na.rm = TRUE),
    count = n()
  ) %>%
  mutate(
    absence_rate_desc = factor(
      absence_rate,
      levels = c("low", "medium", "high", "very high"),
      labels = c(
        "Low (0-9%)",
        "Medium (10-19%)",
        "High (20-39%)",
        "Very High (40%+)"
      )
    )
  )

# Plot Average Grade Point by Absence Category for Core Requirement courses
ggplot(grade_by_absence_core, aes(x = absence_rate_desc,
                                  y = mean_grade_point,
                                  fill = absence_rate_desc)) +
  geom_col() +
  geom_text(aes(label = round(mean_grade_point, 2)), vjust = -0.5, size = 4) +
  geom_text(aes(label = paste0("n=", count)), vjust = 1.5, color = "white", size = 3) +
  scale_fill_manual(values = c(
    "Low (0-9%)" = "#3CB371",
    "Medium (10-19%)" = "gold",
    "High (20-39%)" = "orange",
    "Very High (40%+)" = "red"
  )) +
  labs(
    title = "Average Grade Point by Class Absence Rate (Core Courses)",
    x = "Absence Rate",
    y = "Class Grade Point"
  ) +
  coord_cartesian(ylim = c(0, 4)) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(margin = margin(t = 5))
  )

ggplot(pass_by_absence, aes(x = absence_rate_desc,
                            y = pass_rate,
                            fill = absence_rate_desc)) +
  geom_col() +
  geom_text(aes(label = scales::percent(pass_rate, accuracy = 1)), vjust = -0.5, size = 4) +  # Pass rate as %
  geom_text(aes(label = paste0("n=", count)), vjust = 1.5, color = "white", size = 3) +    # Sample size inside bars
  scale_fill_manual(values = c(
    "Low (0-9%)" = "#3CB371",
    "Medium (10-19%)" = "gold",
    "High (20-39%)" = "orange",
    "Very High (40%+)" = "red"
  )) +
  labs(
    title = "Pass Rate by Student Absence Category",
    x = "Absence Category",
    y = "Pass Rate"
  ) +
  coord_cartesian(ylim = c(0, 1)) +  # y-axis from 0 to 100%
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(margin = margin(t = 5))
  )

# Summarize pass rate by absence category
pass_by_absence_core <- all_with_core %>%
  filter(core_req == 1) %>%
  group_by(absence_rate) %>%
  summarise(
    pass_rate = mean(pass_or_fail),
    count = n()
  ) %>%
  mutate(
    absence_rate_desc = factor(
      absence_rate,
      levels = c("low", "medium", "high", "very high"),
      labels = c(
        "Low (0-9%)",
        "Medium (10-19%)",
        "High (20-39%)",
        "Very High (40%+)"
      )
    )
  )

#Plot pass rate by absence rate
ggplot(pass_by_absence_core, aes(x = absence_rate_desc,
                            y = pass_rate,
                            fill = absence_rate_desc)) +
  geom_col() +
  geom_text(aes(label = scales::percent(pass_rate, accuracy = 1)), vjust = -0.5, size = 4) +  # Pass rate as %
  geom_text(aes(label = paste0("n=", count)), vjust = 1.5, color = "white", size = 3) +    # Sample size inside bars
  scale_fill_manual(values = c(
    "Low (0-9%)" = "#3CB371",
    "Medium (10-19%)" = "gold",
    "High (20-39%)" = "orange",
    "Very High (40%+)" = "red"
  )) +
  labs(
    title = "Class Pass Rate by Absence (Core Classes)",
    x = "Absence Rate",
    y = "Pass Rate"
  ) +
  coord_cartesian(ylim = c(0, 1)) +  # y-axis from 0 to 100%
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(margin = margin(t = 5))
  )


# Check which groups are most affected by attendance

# Adding categorical support_group column to dataset
all_student_data <- all_student_data %>%
  mutate(
    support_group = case_when(
      ell == 1 ~ "ELL",
      sped == 1 ~ "SPED",
      sec_504 == 1 ~ "504",
      tag == 1 ~ "TAG",
      TRUE ~ "None"
    )
  )
library(dplyr)
library(broom)
library(tidyr)
library(purrr)

slope_labels <- all_student_data %>%
  group_by(support_group) %>%
  nest() %>%
  mutate(
    model = map(data, ~ lm(grade_point_dec ~ absences, data = .x)),
    tidied = map(model, tidy)
  ) %>%
  unnest(tidied) %>%
  filter(term == "absences") %>%
  # Instead of select, just rename columns like this:
  mutate(slope = estimate) %>%
  # Keep only needed columns by base R subsetting
  { .[, c("support_group", "slope")] }

# Choose label position (you can tweak these values)
label_positions <- all_student_data %>%
  group_by(support_group) %>%
  summarize(x = max(absences, na.rm = TRUE) * 0.7, y = min(grade_point_dec, na.rm = TRUE) + 0.3)

# Merge slope values with label positions
slope_labels <- left_join(slope_labels, label_positions, by = "support_group")

# Plotting the data
ggplot(all_student_data, aes(x = absences, y = grade_point_dec, color = support_group)) +
  geom_jitter(alpha = 0.3, width = 0.3, height = 0.1) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_text(
    data = slope_labels,
    aes(x = x, y = y, label = paste0("slope = ", round(slope, 3))),
    inherit.aes = FALSE,
    color = "grey30",
    size = 3,
    vjust = -0.5
  ) +
  facet_wrap(~ support_group) +
  scale_y_continuous() +  # optional
  labs(
    title = "Grade Point vs. Absences by Support Status",
    x = "Absences for Class",
    y = "Grade Point for Class"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

