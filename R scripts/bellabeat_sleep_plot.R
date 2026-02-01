# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
install.packages("tidyverse")
library("readr")
library("ggplot2")
library("tidyverse")



# Boot up our SQL tables
sleep_trends <- read_csv('sleep_amount_calculation.csv')
user_activity<- read_csv('user_activity_summary.csv')

# Create new joint dataframe from join of sleep calculations and activity
sleep_vs_activity <- sleep_trends %>% 

# Join the 2 tables prioritizing 9 users found in stress table
  left_join(user_activity, by = c('id' = 'Id')) %>%
  # Use vector at 'by' section when 
  # matching data is named differently
  
  
# # Set up case for new activity labels  
#   mutate(activity_label = case_when(
#     avg_wk_active_days > 3.0 ~ 'Active',
#     TRUE ~ 'Less Active'
#   )) %>% 
  
  

  
# Ensures we are grouping the new table by the 23 users with sleep data
  group_by(id) %>% 


# Set up case for new activity labels  
mutate(activity_label = case_when(
  (wk_avg_very_min + wk_avg_fairly_min) >= 150.0 ~ 'Active',
  TRUE ~ 'Less Active'
))


# Create histogram showing how many active days per week vs. activity level
ggplot(data = sleep_vs_activity)+
  geom_histogram(mapping = aes(x = avg_nightly_sleep_hours,
                               fill = activity_label,
                               alpha = lancet_rating),
                 bins = 10,
                 color = '#534D41')+
  
# # Add density line to histogram
#   geom_density()+
  
  
# Order and label Stress Levels legend, then add colors
  scale_fill_manual(
    name = 'Activity Level',
# Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Active', 'Less Active'),
    values = c('Active' = '#349EA3',
               'Less Active' = '#F3A712'),
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
    title = 'Average Night\'s Sleep', 
    subtitle = 'Average hours sleep per night excluding restless and awake',
    x = 'Average Night\'s Sleep (hours)',
    y = 'User Count'
  )+
  
# Make comments around interesting plot points
annotate('text', x = 6.9, y = 6,
  label = 'Majority of active users sleep \nbetween 4.5 - 7 hours a night',
  fontface = 'plain', size = 3, color = '#10A099')+
  
annotate('text', x = 1.7, y = 2.7, 
  label = 'Some users only recorded short \nnaps, or many restless hours',
  fontface = 'plain', size = 3, color = '#10A099')


