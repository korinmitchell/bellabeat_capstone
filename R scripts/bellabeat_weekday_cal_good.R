# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
install.packages("tidyverse")
library("readr")
library("ggplot2")
library("tidyverse")

# Boot up our SQL table
weekday_cal <- readr::read_csv('calories_by_weekday.csv')

# Reorder day_of_week in the same order of a calendar
weekday_cal$day_of_week <- factor(weekday_cal$day_of_week,
                                  levels = c('Sun',
                                             'Mon',
                                             'Tue',
                                             'Wed',
                                             'Thu',
                                             'Fri',
                                             'Sat'))


#Create Column viz to show each day of the week's total calories
ggplot(data = weekday_cal)+
  geom_col(mapping = aes(x = day_of_week, y = calories_by_weekday,
                         color = day_of_week,
                         fill = day_of_week))+
  
# Boost the Y axis so number labels are more readable  
  ylim(0, 125000)+
  
# Add the exact numbers so the viewer sees the difference 
  geom_text(aes(x = day_of_week, y = calories_by_weekday,
# scales::comma is shortcut for installing scales library for comma() function
                label = scales::comma(calories_by_weekday)), 
            vjust = -.25, fontface = 'plain', size = 3)+
  
# Set border colors for days of the week, while also hiding the legend
  scale_color_manual(
    values = c('Sun' = '#143642',
               'Mon' = '#143642',
               'Tue' = '#948389',
               'Wed' = '#143642',
               'Thu' = '#143642',
               'Fri' = '#EC9A29',
               'Sat' = '#143642'),
    guide = 'none'
  )+
  
# Set fill colors for days of the week, while also hiding the legend
  scale_fill_manual(
    values = c('Sun' = '#065152',
               'Mon' = '#065152',
               'Tue' = '#660B24',
               'Wed' = '#065152',
               'Thu' = '#065152',
               'Fri' = '#0F8B8D',
               'Sat' = '#065152'),
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
    title = 'Most Active Day of the Week', 
    subtitle = 'All users\' calories burnt combined by each weekday ',
    x = 'Days of the Week',
    y = 'Total Calories Burnt'
    
  )
  
  
  
  