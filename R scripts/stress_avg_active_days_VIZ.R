# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
install.packages("tidyverse")
library("readr")
library("ggplot2")
library("tidyverse")

# Boot up our SQL tables
sleep_stress <- read_csv('heartrate_sleep_stress.csv')
user_activity<- read_csv('user_activity_summary.csv')

# Create new joint table from join of sleep/stress and activity
stress_vs_activity <- sleep_stress %>% 
  
  
# Set up case for new stress labels
  mutate(stress_level = case_when(
    light_stress_count > 0 & heavy_stress_count == 0 ~ 'Light Stress',
    heavy_stress_count > 0 & light_stress_count == 0 ~ 'Heavy Stress',
    heavy_stress_count > 0 & light_stress_count > 0 ~ 'Heavy Stress',
    heavy_stress_count > 0 ~ 'Heavy Stress',
    TRUE ~ 'Relaxed'
  )) %>% 
  
# # Reorder Stress Levels legend with Relaxed at the top 
#   mutate(stress_vs_activity$stress_level <- factor(
#     stress_vs_activity$stress_level,
#     levels = c('Relaxed',
#                'Light Stress',
#                'Heavy Stress')
#   )) %>%
  
  # mutate(stress_vs_activity$lancet_rating <- factor(
  #   stress_vs_activity$lancet_rating,
  #   levels = c('Excellent Health',
  #              'Great Health',
  #              'Decent Health',
  #              'Health At Risk')
  # )) %>% 
  
# Join the 2 tables prioritizing 9 users found in stress table
  left_join(user_activity, by = c('user_id' = 'Id')) %>%
                          # Use vector at 'by' section when 
                          # matching data is named differently

  
# Ensures we are grouping the new table by the 9 users with stress data
  group_by(user_id)


# Create histogram showing how many active days per week vs. stress
ggplot(data = stress_vs_activity)+
  geom_histogram(mapping = aes(x = avg_wk_active_days,
                               fill = stress_level,
                               alpha = lancet_rating),
                 bins = 10,
                 color = '#534D41')+
  
# Order and label Stress Levels legend, then add colors
  scale_fill_manual(
    name = 'User Stress',
# Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Relaxed','Light Stress', 'Heavy Stress'),
    values = c('Relaxed' = '#349EA3',
               'Light Stress' = '#F3A712',
               'Heavy Stress' = '#9B0B47')
  )+
  
# Order and label Stress Levels legend, then add colors
  scale_alpha_manual(
    name = 'Lancet Rating',
# Add breaks to ensure order does not get randomly alphabetized
    breaks = c('Excellent Health',
               'Great Health',
               'Decent Health'),
    values = c('Excellent Health' = 1.0,
               'Great Health' = 0.58,
               'Decent Health' = 0.13),
    drop = FALSE
  )+

  
    
# Force the y axis to max out at 4000
   ylim(0, 5)+
  
# Add space for the axis titles
  theme(
    axis.title.y = element_text(
      margin = margin(t = 0, r = 20, b = 0, l = 0)),
    axis.title.x = element_text(
      margin = margin(t = 20, r = 0, b = 0, l = 0)),
    
# Add color to outside of the grid
    plot.background = element_rect(
      color = '#7D7ABC', fill = '#E0EAED'),
  )+
  
 # Add labels for Viz Title and Axis Titles
labs(
  title = 'Weekly \"Active\" Days with Stress and Step Count Health', 
  subtitle = 'Average active days per week segmented by stress and health',
  x = 'Average Active Days (weekly)',
  y = 'User Count'
  )+
  
# Make comments around interesting plot points
  annotate('text', x = 4, y =1.0,
     label = 'Most users are active around 3 days a week',
     fontface = 'plain', size = 3.5, color = '#10A099',
     angle = 20)+
  annotate('text', x = 3.75, y = 3.1,
     label = 'Many Excellent Health users are heavily stressed',
     fontface = 'plain', size = 3.5, color = '#62092E',
     angle = 20)
  
  
  
