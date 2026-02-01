# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
install.packages("tidyverse")
library("readr")
library("ggplot2")
library("tidyverse")



# Boot up our SQL tables
sleep_stress <- readr::read_csv('heartrate_sleep_stress.csv')
user_activity<- readr::read_csv('user_activity_summary.csv')
  

sleep_stress_activity <- sleep_stress %>% 
  
# Join the 2 tables prioritizing 9 users found in stress table
  left_join(user_activity, by = c('user_id' = 'Id')) %>%
  # Use vector at 'by' section when 
  # matching data is named differently
  
# Set up case for new stress labels
  mutate(stress_level = case_when(
    light_stress_count > 0 & heavy_stress_count == 0 ~ 'Light Stress',
    heavy_stress_count > 0 & light_stress_count == 0 ~ 'Heavy Stress',
    heavy_stress_count > 0 & light_stress_count > 0 ~ 'Heavy Stress',
    heavy_stress_count > 0 ~ 'Heavy Stress',
    TRUE ~ 'Relaxed'
  )) %>% 
  
  # Ensures we are grouping the new table by the 23 users with sleep data
  group_by(user_id)
    



# Create histogram showing how many active days per week vs. activity level
ggplot(data = sleep_stress_activity)+
  geom_histogram(mapping = aes(x = avg_nightly_sleep_hours,
                               fill = stress_level,
                               alpha = lancet_rating),
                 bins = 10,
                 color = '#534D41')+
  
  
# Order and label Stress Levels legend, then add fill colors
  scale_fill_manual(
    name = 'Activity Level',
    # Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Relaxed', 'Light Stress', 'Heavy Stress'),
    values = c('Relaxed' = '#349EA3',
               'Light Stress' = '#F3A712',
               'Heavy Stress' = '#9B0B47'),
    guide = guide_legend(order = 1)
  )+
  
  
# Order and label Stress Levels legend, then add colors
  scale_alpha_manual(
    name = 'Lancet Rating',
    # Add breaks to ensure order does not get randomly alphabetized
    breaks = c('Excellent Health',
               'Great Health',
               'Decent Health'),
    values = c('Excellent Health' = 1.0,
               'Great Health' = 0.55,
               'Decent Health' = 0.16),
    drop = FALSE,
    guide = guide_legend(order = 2)
  )+
  
  
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
    title = 'How Stressful is an Average Night\'s Sleep', 
    subtitle = 'Average hours of true sleep segemented by stress and health',
    x = 'Average Night\'s Sleep (hours)',
    y = 'User Count'
  )+
  
# Make comments around interesting plot points
  annotate('text', x = 6.2, y = 3.5,
   label = 'Majority of users sleeping less 
   than 6 hours are Heavily stressed',
   fontface = 'plain', size = 3, color = '#9B0B47')+
  
  annotate('text', x = 2, y = 1.5, 
   label = 'Relaxed Excellent Health user only recorded 
   maximum 1.5 hours of sleep per night',
   fontface = 'plain', size = 3, color = '#10A099')


