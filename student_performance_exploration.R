# Set up environment

install.packages("tidyverse")                   
install.packages("skimr")            # Used to look at the data structure
install.packages("relaimpo")         # Used to calculate relative importance
library(tidyverse) 
library(skimr)
library(relaimpo)

# Exploring the Data
skim_without_charts(all_student_data)

# Single ANOVAs
ell_an<- aov(grade_point_dec ~ ell, data = all_student_data)
sped_an<- aov(grade_point_dec ~ sped, data = all_student_data)
sec_504_an<- aov(grade_point_dec ~ sec_504, data = all_student_data)
tag_an<- aov(grade_point_dec ~ tag, data = all_student_data)
tran_an<- aov(grade_point_dec ~ transfer, data = all_student_data)
grade_level_an<- aov(grade_point_dec ~ grade_level, data = all_student_data)
gender_an<- aov(grade_point_dec ~ gender, data = all_student_data)
abs_an<-aov(grade_point_dec ~ absence_rate, data = all_student_data)

summary(ell_an)
summary(sped_an)
summary(sec_504_an)
summary(tag_an)
summary(tran_an)
summary(grade_level_an)
summary(gender_an)
summary(abs_an)

# Linear Regression
lin_reg_abs<-lm(formula=grade_point_dec ~ absences, data=all_student_data)
lin_reg_ss<-lm(formula=grade_point_dec ~ ss_absences, data=all_student_data)
lin_reg_tar<-lm(formula=grade_point_dec ~ tardies, data=all_student_data)
lin_reg_ell<-lm(formula=grade_point_dec ~ ell, data=all_student_data)
lin_reg_sped<-lm(formula=grade_point_dec ~ sped, data=all_student_data)
lin_reg_sec_504<-lm(formula=grade_point_dec ~ sec_504, data=all_student_data)
lin_reg_tag<-lm(formula=grade_point_dec ~ tag, data=all_student_data)

summary(lin_reg_abs)
summary(lin_reg_ss)
summary(lin_reg_tar)
summary(lin_reg_ell)
summary(lin_reg_sped)
summary(lin_reg_sec_504)
summary(lin_reg_tag)

# Multiple Linear Regression
mult_reg_atten<-lm(formula=grade_point_dec ~ absences + tardies + ss_absences, data=all_student_data)
mult_reg_pass_atten<-lm(formula=pass_or_fail ~ absences + tardies + ss_absences, data=all_student_data)
mult_reg_demog<-lm(formula=grade_point_dec ~ ell + sped + sec_504 + tag + transfer + gender, data=all_student_data)
mult_reg_all<-lm(formula=grade_point_dec ~ absences + tardies + ss_absences + ell + sped + sec_504 + tag + gender + transfer, data=all_student_data)

summary(mult_reg_atten)
summary(mult_reg_pass_atten)
summary(mult_reg_demog)
summary(mult_reg_all)

# Identified attendance variables and academic demographic variables (sped, sec_504, ell, tag) as most notable
mult_reg_all_sig<-lm(formula=grade_point_dec ~ absences + tardies + ss_absences + ell + sped + sec_504 + tag + gender + transfer, data=all_student_data)
mult_reg_pass<-lm(formula=pass_or_fail ~ absences + tardies + ss_absences + ell + sped + sec_504 + tag, data=all_student_data)
mult_reg_c<-lm(formula=c_or_higher ~ absences + tardies + ss_absences + ell + sped + sec_504 + tag, data=all_student_data)

summary(mult_reg_all_sig)
summary(mult_reg_pass)
summary(mult_reg_c)

# Test for collinearity between absences and ss_absences
cor.test(all_student_data$absence_perc, all_student_data$ss_abs_perc, use = "complete.obs")

# Multiple Linear Regressions by core/non-core for grades/pass by attend.
mult_reg_atten_grade_core<-lm(formula=grade_point_dec ~ absences + tardies + ss_absences, data=core_data)
mult_reg_atten_pass_core<-lm(formula=pass_or_fail ~ absences + tardies + ss_absences, data=core_data)
mult_reg_atten_grade_non_core<-lm(formula=grade_point_dec ~ absences + tardies + ss_absences, data=non_core_data)
mult_reg_atten_pass_non_core<-lm(formula=pass_or_fail ~ absences + tardies + ss_absences, data=non_core_data)

summary(mult_reg_atten_grade_core)
summary(mult_reg_atten_pass_core)
summary(mult_reg_atten_grade_non_core)
summary(mult_reg_atten_pass_non_core)
