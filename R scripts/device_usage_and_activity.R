# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
library("readr")
library("ggplot2")

# Create data frame for the fitbit usage percentage
device_usage <- readr::read_csv('fitbit_usage_rate.csv')

# Create new joint data frame from join of device usage and user activity
usage_vs_activity <- device_usage %>% 
  
# Join the 2 tables prioritizing the data from the device usage data frame  
  left_join(user_activity, by = c('Id' = 'Id'))%>% 
  
# Ensures we are grouping the new table by the same users in both csv's
  group_by(Id) %>% 
  
# Set up case for new activity labels     
  mutate(activity_label = case_when(
    (wk_avg_very_min + wk_avg_fairly_min) >= 150.0 ~ 'Active',
    (wk_avg_very_min + wk_avg_fairly_min) > 0 ~ 'Less Active',
    TRUE ~ 'Inactive'
  )) %>% 
  
# Combine fairly active and very active minutes per user    
  mutate(wk_avg_mvpa = 
           wk_avg_fairly_min + wk_avg_very_min
           ) %>% 

# Calculate the activity score, how truly active a user is with their potential 
  mutate(activity_score = ifelse( usage_rate > 0,
           wk_avg_mvpa / usage_rate)) %>% 
 
# Set up activity labels based on activity score for color segmentation   
  mutate(score_labels = case_when(
    activity_score > 300 ~ 'High Efficiency',
    activity_score < 50 ~ 'Low Efficiency',
    activity_score <= 300 & activity_score >= 50 ~ 'Decent Efficiency',
    TRUE ~ 'No Active Minutes'
  ))
  
# Reorder Device Leverage legend with High Efficiency at the top    
  usage_vs_activity$score_labels <- factor(usage_vs_activity$score_labels,
                                          levels = c('High Efficiency',
                                                     'Decent Efficiency',
                                                     'Low Efficiency'))

# Create plot showing intense activity vs. daily device wearing rate per user
ggplot(data = usage_vs_activity)+
  geom_jitter(mapping = aes(x = usage_rate, y = wk_avg_mvpa, 
                           color = score_labels, shape = score_labels),
             size = 3.5)+
  
  
  geom_smooth(method = lm,
              mapping = aes(x = usage_rate, y = wk_avg_mvpa),
              alpha = 0, color = alpha('#196E81', 0.15))+
  

# Add the WHO goal line for moderate activity    
  geom_hline(yintercept = 150, linetype = "dashed", 
             color = alpha("#D08F0F", .35 ), 
             size = 1) +
# Make comment describing the goal moderate WHO goal line
  annotate("text", x = 0.2, y = 160, label = "WHO Goal: 150 min",
           fontface = 'plain', size = 3, color = '#885C04')+
  
# Add the WHO goal line for intense activity    
  geom_hline(yintercept = 75, linetype = "dashed", 
             color = alpha("red", .25 ), 
             size = 1) +
# Make comment describing the goal intense WHO goal line
  annotate("text", x = 0.5, y = 85, label = "WHO Goal: 75 min",
           fontface = 'plain', size = 3, color = '#6F0833')+
  
  
# Set limits to make viz easier to read, change to y limit 800 to see all data  
  scale_x_continuous(limits = c(0, 1))+
  scale_y_continuous(limits = c(-1, 400))+

   
# Order score labels legend and set colors
  scale_color_manual(
    name = 'Device Usage',
    breaks = c('High Efficiency',
               'Decent Efficiency',
               'Low Efficiency'),
    values = c('High Efficiency' = '#23F0C7',
               'Decent Efficiency' = '#8884FF',
               'Low Efficiency' = '#EF767A')
  )+
  
  
# Order score labels legend and set shapes  
  scale_shape_manual(
    name = 'Device Usage',
    # Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('High Efficiency',
               'Decent Efficiency',
               'Low Efficiency'),
    
    values = c('High Efficiency' = 16,
               'Decent Efficiency' = 17,
               'Low Efficiency' = 7)
  )+
  
# Add labels for Viz Title and Axis Titles
  labs(
    title = 'Is More Wear Time Equal to More Activity?', 
    subtitle = 'Weekly vigorous activity against daily device wearing habits',
    x = 'Daily Device Wear Rate',
    y = 'Average Weekly MVPA (minutes)'
  )+
  
  annotate('text', x = 0.75, y = 30, 
           label = 'Low activity users regularly wearing device',
           fontface = 'plain', size = 3, color = '#8F0941')+
  annotate('text', x = 0.75, y = 225,
           label = 'High activity users regularly wearing device',
           fontface = 'plain', size = 3, color = '#349EA3')+
  
# Add space for the axis titles
  theme(
    axis.title.y = element_text(
      margin = margin(t = 0, r = 20, b = 0, l = 0)),
    axis.title.x = element_text(
      margin = margin(t = 20, r = 0, b = 0, l = 0)),
    
# Add color to outside of the grid
    plot.background = element_rect(
      color = '#7D7ABC', fill = '#E0EAED'),
  )
  
  