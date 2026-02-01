# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
install.packages("tidyverse")
library("readr")
library("ggplot2")
library("tidyverse")

# Boot up the same activity dataframe
day_bar <- readr::read_csv('user_activity_summary.csv') %>% 
  
  
# Create new variable for WHO compliance (Y / N)
  mutate(who_compliant = case_when(
    
    wk_avg_very_min >= 75 | wk_avg_fairly_min >= 150 ~ 'Y',
    TRUE ~ 'N'
      
    )
  ) %>% 
    
  


# Set up order of x axis to represent a calendar's day order
  mutate(heaviest_active_day = factor(heaviest_active_day,
                                  levels = c('Sun',
                                             'Mon',
                                             'Tue',
                                             'Wed',
                                             'Thu',
                                             'Fri',
                                             'Sat')),
# Set up order for health rating legend
   lancet_rating = factor(lancet_rating,
                                   levels = c('Excellent Health',
                                              'Great Health',
                                              'Decent Health',
                                              'Health At Risk')),


# Set up order for WHO compliance legend
  who_compliant = factor(who_compliant,
                         levels = c('Y', 'N'))) %>% 
  
  
# Filter out the "No Heavy Activity" from heaviest_active_day data
# Use !is.na() to get rows where it is NOT True that data is missing
  filter(!is.na(heaviest_active_day))
         
# Use !is.na() to get rows where it is NOT True that data is missing
  #        !is.na(heaviest_active_day)) %>% 
  # droplevels()


# Create bar viz for most active day across all 35 users in Mar~Apr 2016
ggplot(data = day_bar)+
  geom_bar(mapping = aes(x = heaviest_active_day,
                         fill = lancet_rating,
                         color = who_compliant),
           linewidth = 1)+
  
  
# Add the 0 values like Sunday and Thursday in the x axis
  scale_x_discrete(drop = FALSE)+

  
# Set up maximum limit for the bar viz
  ylim(0,14)+
  
# Order Lancet Rating legend and set colors
  scale_fill_manual(
    name = "Lancet Rating",
    
# Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Excellent Health', 
               'Great Health', 'Decent Health', 'Health At Risk'),
    
    values = c('Excellent Health' = '#23F0C7', 
               'Great Health' = '#8884FF',
               'Decent Health' = '#FFA62B', 
               'Health At Risk' = '#EF767A'))+
  

# Setup border colors to represent Yes or No for World Health Compliance  
  scale_color_manual(
    name = 'WHO Compliant',
# Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Y',
               'N'),

    values = c('Y' = '#2A5225',
               'N' = '#E0EAED'))+
    
 
# Fix the legend for border color make it easier to see
  guides(color = guide_legend(
    override.aes = list(
      fill = '#E0EAED',
      linewidth = .8
      )
  ))+
  
  scale_linewidth_manual(
    guide = 'none'
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
    title = 'Most Intense Day of the Week', 
    subtitle = 'What weekday did users consistently push their limits?',
    x = 'Days of the Week',
    y = 'User Count'
    
  )+
  
  annotate('text', x = 'Tue', y = 7.5,
     label = 'All WHO compliant users (150 min fairly 
     active or 75 min very active per week)
     have over 5000 steps per day. 
     (at least Great Health)',
     fontface = 'plain', size = 2.4, color = '#5B58B2')
     
     
     
     
     
     
     
