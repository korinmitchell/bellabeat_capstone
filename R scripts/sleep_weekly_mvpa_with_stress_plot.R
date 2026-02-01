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
    TRUE ~ 'Relaxed'),
    
    wk_avg_mvpa = wk_avg_fairly_min + wk_avg_very_min
    
    ) %>% 
  
# Ensures we are grouping the new table by the 23 users with sleep data
  group_by(user_id)




# Create histogram showing how many active days per week vs. activity level
ggplot(data = sleep_stress_activity)+
  geom_point(mapping = aes(x = avg_nightly_sleep_hours, y = wk_avg_mvpa,
                               color = stress_level,
                               shape = lancet_rating), size = 4.5, 
             fill = 'black')+
  
  
# Add trend line  
  geom_smooth(method = lm, 
              mapping = aes(x = avg_nightly_sleep_hours, y = wk_avg_mvpa), 
              alpha = 0.1, fill = '#7D7ABC', color = alpha('red', .16))+
  
  
# Order and label Stress Levels legend, then add colors
  scale_color_manual(
    name = 'Activity Level',
    # Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Relaxed', 'Light Stress', 'Heavy Stress'),
    values = c('Relaxed' = '#349EA3',
               'Light Stress' = '#F3A712',
               'Heavy Stress' = '#9B0B47'),
    guide = guide_legend(order = 1)
  )+
  
  
# Order Lancet Rating legend and set shapes  
  scale_shape_manual(
    name = 'Lancet Rating',
    # Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Excellent Health', 
               'Great Health', 'Decent Health', 'Health At Risk'),
    
    values = c('Excellent Health' = 16,
               'Great Health' = 17,
               'Decent Health' = 15,
               'Health At Risk' = 7),
    guide = guide_legend(order = 2)
  )+
  
  
# Limit the Y axis to only go up to 800 MVPA minutes
  ylim(0, 800)+
  
  
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
    title = 'The Stress-Rest Equilibrium', 
    subtitle = 'Does high activity and long sleep buffer against heavy stress?',
    x = 'Average Night\'s Sleep (hours)',
    y = 'Average Weekly MVPA (minutes)'
  )+
  
# Make comments around interesting plot points
  annotate('text', x = 5, y = 175,
           label = 'Majority of users sleeping less 
   than 6 hours are Heavily stressed',
           fontface = 'plain', size = 3, color = '#9B0B47')+
  
  annotate('text', x = 2.35, y = 500, 
           label = 'Excellent Health & Relaxed user only records 
           maximum 1.5 hours of sleep per night',
           fontface = 'plain', size = 3, color = '#10A099')+
  
  annotate('text', x = 5, y = 600, 
           label = 'Exceeding 500 MVPA min per 
           week may lead to heavy stress',
           fontface = 'plain', size = 3, color = '#D68812')
