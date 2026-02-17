################################################################################
# NFL Attendance Mixed Effects Model Analysis

################################################################################

library(lme4)
library(lmerTest)
library(car)
library(ggplot2)
library(gridExtra)
library(dplyr)
library(broom.mixed)

# Load data
setwd("/regression-practice")
attendance_data <- read.csv("regression-practice/final_dataframe/attendance_with_lags.csv")

################################################################################
# STEP 1: DETERMINE RANDOM EFFECTS STRUCTURE
################################################################################

#Model with NEITHER time effect
model_no_time <- lm(weekly_attendance ~ factor(home_team),
                    data = attendance_data)

#Model with JUST week
model_week <- lmer(weekly_attendance ~ factor(home_team) + (1|week),
                   data = attendance_data,
                   REML = FALSE)

#Model with JUST year
model_year <- lmer(weekly_attendance ~ factor(home_team) + (1|year),
                   data = attendance_data,
                   REML = FALSE)

#Model with BOTH week and year
model_both <- lmer(weekly_attendance ~ factor(home_team) + (1|week) + (1|year),
                   data = attendance_data,
                   REML = FALSE)

#Compare with AIC/BIC
cat("\n=== Model Comparison: AIC ===\n")
print(AIC(model_week, model_year, model_both))

cat("\n=== Model Comparison: BIC ===\n")
print(BIC(model_week, model_year, model_both))

# Test if BOTH is better than just week
cat("\n=== Testing if both week+year better than just week ===\n")
print(anova(model_week, model_both))

#Test if BOTH is better than just year
cat("\n=== Testing if both week+year better than just year ===\n")
print(anova(model_year, model_both))

################################################################################
#STEP 2: BUILD FULL MODEL AND CHECK VIF
################################################################################

#Full model with all available variables
#Note: Excluded variables not present in new dataset:
#   - date_dummy, time_dummy, win_last_week2
#   - lag_avg_points_for, lag_avg_points_against, lag_sb_winner

full_model <- lmer(weekly_attendance ~ 
                     tie_dummy_lag +
                     day_dummy_lag +
                     weekly_attendance_lag + 
                     pts_win_lag +
                     pts_loss_lag +
                     yds_win_lag + 
                     yds_loss_lag +
                     turnovers_win_lag + 
                     turnovers_loss_lag +
                     win_streak_lag + 
                     lose_streak_lag + 
                     lag_wins +
                     lag_loss +
                     lag_points_for + 
                     lag_points_against +
                     lag_points_differential + 
                     lag_margin_of_victory +
                     lag_strength_of_schedule + 
                     lag_simple_rating + 
                     lag_offensive_ranking +
                     lag_defensive_ranking +
                     lag_playoffs_dummy + 
                     factor(home_team) + (1|year),
                   data = attendance_data,
                   REML = FALSE)

cat("\n=== VIF for Full Model ===\n")
print(vif(full_model))

################################################################################
# STEP 3: ITERATIVELY REMOVE COLLINEAR VARIABLES
################################################################################

# Model 2: Remove lag_margin_of_victory (likely collinear with points differential)
full_model2 <- lmer(weekly_attendance ~ 
                      tie_dummy_lag +
                      day_dummy_lag +
                      weekly_attendance_lag + 
                      pts_win_lag +
                      pts_loss_lag +
                      yds_win_lag + 
                      yds_loss_lag +
                      turnovers_win_lag + 
                      turnovers_loss_lag +
                      win_streak_lag + 
                      lose_streak_lag + 
                      lag_wins +
                      lag_loss +
                      lag_points_for + 
                      lag_points_against +
                      lag_points_differential + 
                      #lag_margin_of_victory +
                      lag_strength_of_schedule + 
                      lag_simple_rating + 
                      lag_offensive_ranking +
                      lag_defensive_ranking +
                      lag_playoffs_dummy + 
                      factor(home_team) + (1|year),
                    data = attendance_data,
                    REML = FALSE)

cat("\n=== VIF for Model 2 (removed lag_margin_of_victory) ===\n")
print(vif(full_model2))

# Model 3: Remove lag_simple_rating
full_model3 <- lmer(weekly_attendance ~ 
                      tie_dummy_lag +
                      day_dummy_lag +
                      weekly_attendance_lag + 
                      pts_win_lag +
                      pts_loss_lag +
                      yds_win_lag + 
                      yds_loss_lag +
                      turnovers_win_lag + 
                      turnovers_loss_lag +
                      win_streak_lag + 
                      lose_streak_lag + 
                      lag_wins +
                      lag_loss +
                      lag_points_for + 
                      lag_points_against +
                      lag_points_differential + 
                      #lag_margin_of_victory +
                      lag_strength_of_schedule + 
                      #lag_simple_rating + 
                      lag_offensive_ranking +
                      lag_defensive_ranking +
                      lag_playoffs_dummy + 
                      factor(home_team) + (1|year),
                    data = attendance_data,
                    REML = FALSE)

cat("\n=== VIF for Model 3 (removed lag_simple_rating) ===\n")
print(vif(full_model3))

# Model 4: Remove lag_points_differential
full_model4 <- lmer(weekly_attendance ~ 
                      tie_dummy_lag +
                      day_dummy_lag +
                      weekly_attendance_lag + 
                      pts_win_lag +
                      pts_loss_lag +
                      yds_win_lag + 
                      yds_loss_lag +
                      turnovers_win_lag + 
                      turnovers_loss_lag +
                      win_streak_lag + 
                      lose_streak_lag + 
                      lag_wins +
                      lag_loss +
                      lag_points_for + 
                      lag_points_against +
                      #lag_points_differential + 
                      #lag_margin_of_victory +
                      lag_strength_of_schedule + 
                      #lag_simple_rating + 
                      lag_offensive_ranking +
                      lag_defensive_ranking +
                      lag_playoffs_dummy + 
                      factor(home_team) + (1|year),
                    data = attendance_data,
                    REML = FALSE)

cat("\n=== VIF for Model 4 (removed lag_points_differential) ===\n")
print(vif(full_model4))

# Model 5: Remove lag_points_for (collinear with pts_win_lag)
full_model5 <- lmer(weekly_attendance ~ 
                      tie_dummy_lag +
                      day_dummy_lag +
                      weekly_attendance_lag + 
                      pts_win_lag +
                      pts_loss_lag +
                      yds_win_lag + 
                      yds_loss_lag +
                      turnovers_win_lag + 
                      turnovers_loss_lag +
                      win_streak_lag + 
                      lose_streak_lag + 
                      lag_wins +
                      lag_loss +
                      #lag_points_for + 
                      lag_points_against +
                      #lag_points_differential + 
                      #lag_margin_of_victory +
                      lag_strength_of_schedule + 
                      #lag_simple_rating + 
                      lag_offensive_ranking +
                      lag_defensive_ranking +
                      lag_playoffs_dummy + 
                      factor(home_team) + (1|year),
                    data = attendance_data,
                    REML = FALSE)

cat("\n=== VIF for Model 5 (removed lag_points_for) ===\n")
print(vif(full_model5))

# Model 6: Remove lag_loss (collinear with lag_wins)
full_model6 <- lmer(weekly_attendance ~ 
                      tie_dummy_lag +
                      day_dummy_lag +
                      weekly_attendance_lag + 
                      pts_win_lag +
                      pts_loss_lag +
                      yds_win_lag + 
                      yds_loss_lag +
                      turnovers_win_lag + 
                      turnovers_loss_lag +
                      win_streak_lag + 
                      lose_streak_lag + 
                      lag_wins +
                      #lag_loss +
                      #lag_points_for + 
                      lag_points_against +
                      #lag_points_differential + 
                      #lag_margin_of_victory +
                      lag_strength_of_schedule + 
                      #lag_simple_rating + 
                      lag_offensive_ranking +
                      lag_defensive_ranking +
                      lag_playoffs_dummy + 
                      factor(home_team) + (1|year),
                    data = attendance_data,
                    REML = FALSE)

cat("\n=== VIF for Model 6 (removed lag_loss) ===\n")
print(vif(full_model6))

# Model 7: Convert categorical variables to factors and remove lag_defensive_ranking
full_model7 <- lmer(weekly_attendance ~ 
                      factor(tie_dummy_lag) +
                      factor(day_dummy_lag) +
                      weekly_attendance_lag + 
                      pts_win_lag +
                      pts_loss_lag +
                      yds_win_lag + 
                      yds_loss_lag +
                      turnovers_win_lag + 
                      turnovers_loss_lag +
                      win_streak_lag + 
                      lose_streak_lag + 
                      lag_wins +
                      #lag_loss +
                      #lag_points_for + 
                      lag_points_against +
                      #lag_points_differential + 
                      #lag_margin_of_victory +
                      lag_strength_of_schedule + 
                      #lag_simple_rating + 
                      lag_offensive_ranking +
                      #lag_defensive_ranking +
                      lag_playoffs_dummy + 
                      factor(home_team) + (1|year),
                    data = attendance_data,
                    REML = FALSE)

cat("\n=== VIF for Model 7 (categorical vars as factors, removed lag_defensive_ranking) ===\n")
print(vif(full_model7))

################################################################################
# STEP 4: BACKWARD ELIMINATION
################################################################################

cat("\n=== Running backward stepwise elimination ===\n")
step_result <- step(full_model7, direction = "backward")

# View results
print(step_result)

# Get final model
final_model <- get_model(step_result)

cat("\n=== FINAL MODEL SUMMARY ===\n")
print(summary(final_model))

################################################################################
# STEP 5: DIAGNOSTIC PLOTS
################################################################################

# Base R diagnostic plots
par(mfrow = c(2, 2))

# 1. Residual Q-Q Plot
qqnorm(resid(final_model), main = "Residual Q-Q Plot")
qqline(resid(final_model))

# 2. Residuals vs Fitted
plot(fitted(final_model), resid(final_model),
     xlab = "Fitted Values", ylab = "Residuals",
     main = "Residuals vs Fitted")
abline(h = 0, lty = 2, col = "red")

# 3. Year Random Effects
qqnorm(ranef(final_model)$year[[1]], 
       main = "Year Random Effects Q-Q Plot")
qqline(ranef(final_model)$year[[1]])

# 4. Scale-Location
plot(fitted(final_model), sqrt(abs(resid(final_model))),
     xlab = "Fitted Values", ylab = "√|Residuals|",
     main = "Scale-Location")

par(mfrow = c(1, 1))

# ggplot2 diagnostic plots
diag_data <- data.frame(
  fitted = fitted(final_model),
  resid = resid(final_model),
  std_resid = resid(final_model) / sd(resid(final_model)),
  obs_num = 1:length(resid(final_model))
)

# 1. Residuals vs Fitted
p1 <- ggplot(diag_data, aes(x = fitted, y = resid)) +
  geom_point(alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_smooth(se = FALSE, color = "blue") +
  labs(title = "Residuals vs Fitted",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

# 2. Q-Q Plot
p2 <- ggplot(diag_data, aes(sample = resid)) +
  stat_qq(alpha = 0.3) +
  stat_qq_line(color = "red") +
  labs(title = "Normal Q-Q",
       x = "Theoretical Quantiles",
       y = "Sample Quantiles") +
  theme_minimal()

# 3. Scale-Location
p3 <- ggplot(diag_data, aes(x = fitted, y = sqrt(abs(std_resid)))) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE, color = "blue") +
  labs(title = "Scale-Location",
       x = "Fitted Values",
       y = "√|Standardized Residuals|") +
  theme_minimal()

# 4. Residuals vs Observation
p4 <- ggplot(diag_data, aes(x = obs_num, y = resid)) +
  geom_point(alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Residuals vs Order",
       x = "Observation Number",
       y = "Residuals") +
  theme_minimal()

# Arrange all plots
grid.arrange(p1, p2, p3, p4, ncol = 2)

################################################################################
# STEP 6: STREAK VISUALIZATIONS
################################################################################

# Create prediction data for streaks
streak_data <- expand.grid(
  win_streak_lag = 0:10,
  lose_streak_lag = 0:10,
  # Set other variables to their means or reference categories
  tie_dummy_lag = 0,
  day_dummy_lag = names(sort(table(attendance_data$day_dummy_lag), decreasing = TRUE))[1],
  weekly_attendance_lag = mean(attendance_data$weekly_attendance_lag, na.rm = TRUE),
  pts_win_lag = mean(attendance_data$pts_win_lag, na.rm = TRUE),
  pts_loss_lag = mean(attendance_data$pts_loss_lag, na.rm = TRUE),
  yds_win_lag = mean(attendance_data$yds_win_lag, na.rm = TRUE),
  yds_loss_lag = mean(attendance_data$yds_loss_lag, na.rm = TRUE),
  turnovers_win_lag = mean(attendance_data$turnovers_win_lag, na.rm = TRUE),
  turnovers_loss_lag = mean(attendance_data$turnovers_loss_lag, na.rm = TRUE),
  lag_wins = mean(attendance_data$lag_wins, na.rm = TRUE),
  lag_points_against = mean(attendance_data$lag_points_against, na.rm = TRUE),
  lag_strength_of_schedule = mean(attendance_data$lag_strength_of_schedule, na.rm = TRUE),
  lag_offensive_ranking = mean(attendance_data$lag_offensive_ranking, na.rm = TRUE),
  lag_playoffs_dummy = 0,
  home_team = names(sort(table(attendance_data$home_team), decreasing = TRUE))[1]
)

# Add predictions
streak_data$predicted <- predict(final_model, newdata = streak_data, re.form = NA)

# Create combined data for comparison
win_data <- subset(streak_data, lose_streak_lag == 0)
win_data$streak_type <- "Winning Streak"
win_data$streak_length <- win_data$win_streak_lag

lose_data <- subset(streak_data, win_streak_lag == 0)
lose_data$streak_type <- "Losing Streak"
lose_data$streak_length <- lose_data$lose_streak_lag

combined_streaks <- rbind(
  win_data[, c("streak_length", "predicted", "streak_type")],
  lose_data[, c("streak_length", "predicted", "streak_type")]
)

# Plot both on same graph
ggplot(combined_streaks, aes(x = streak_length, y = predicted, 
                              color = streak_type)) +
  geom_line(size = 1.5) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Winning Streak" = "darkgreen", 
                                 "Losing Streak" = "darkred")) +
  labs(title = "Effect of Winning vs Losing Streaks on Attendance",
       x = "Consecutive Games in Streak",
       y = "Predicted Weekly Attendance",
       color = "Streak Type",
       subtitle = "Holding all other variables constant") +
  theme_minimal() +
  theme(legend.position = "bottom")

################################################################################
# STEP 7: YEAR RANDOM EFFECTS VISUALIZATION
################################################################################

# Extract year effects
year_effects <- ranef(final_model)$year
year_effects$year_num <- as.numeric(rownames(year_effects))

# Plot
ggplot(year_effects, aes(x = year_num, y = `(Intercept)`)) +
  geom_line(color = "blue", size = 1) +
  geom_point(size = 3, color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Year-to-Year Variation in NFL Attendance",
       x = "Year",
       y = "Year Random Effect",
       subtitle = "Positive = above average attendance that year") +
  theme_minimal()

################################################################################
# STEP 8: TEAM FIXED EFFECTS
################################################################################

# Extract team coefficients using tidy()
coefs <- tidy(final_model)

# Get just the team effects
team_effects <- coefs[grep("factor\\(home_team\\)", coefs$term), ]
team_effects$team <- gsub("factor\\(home_team\\)", "", team_effects$term)

# Add reference team as baseline (effect = 0)
# Determine which team is the reference
ref_team <- setdiff(unique(attendance_data$home_team), team_effects$team)[1]

baseline <- data.frame(
  term = paste0("factor(home_team)", ref_team),
  estimate = 0,
  std.error = 0,
  statistic = NA,
  p.value = NA,
  team = ref_team
)
team_effects <- rbind(team_effects, baseline)

# Plot with ggplot
ggplot(team_effects, aes(x = reorder(team, estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Estimated Team Fixed Effects",
       subtitle = paste("Relative to", ref_team, "(baseline)"),
       x = "Team",
       y = "Effect on Weekly Attendance") +
  theme_minimal()

################################################################################
# STEP 9: TIME SERIES PLOTS
################################################################################

# Plot with different colors for each team
ggplot(attendance_data, aes(x = year, y = weekly_attendance, 
                            group = home_team, color = home_team)) +
  geom_line(alpha = 0.5) +
  labs(title = "Weekly Attendance by Team Over Time",
       x = "Year",
       y = "Weekly Attendance") +
  theme_minimal() +
  theme(legend.position = "none")  # Too many teams to show legend

# Calculate average attendance per year
yearly_avg <- attendance_data %>%
  group_by(year) %>%
  summarise(avg_attendance = mean(weekly_attendance, na.rm = TRUE))

# Plot average attendance over time
ggplot(yearly_avg, aes(x = year, y = avg_attendance)) +
  geom_line(color = "darkblue", size = 1.5) +
  geom_point(size = 3, color = "darkblue") +
  labs(title = "Average NFL Attendance by Year",
       x = "Year",
       y = "Average Weekly Attendance") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

cat("\n=== ANALYSIS COMPLETE ===\n")
