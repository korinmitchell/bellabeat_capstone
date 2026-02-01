# Install necessary packages
install.packages("ggplot2")
install.packages("readr")
library("readr")
library("ggplot2")

# Create data frame for the user activity csv file
user_activity <- readr::read_csv('user_activity_summary.csv')

# Reorder Lancet Rating legend with Excellent Health at the top
user_activity$lancet_rating <- factor(user_activity$lancet_rating,
                                      levels = c('Excellent Health', 
                                                 'Great Health', 
                                                 'Decent Health', 
                                                 'Health At Risk'))

# Create plot for average daily steps and daily calories burnt
# Add color and shape to plot points to show user health condition
ggplot(data = user_activity)+
  geom_point(mapping = aes(x = avg_daily_steps, y = avg_daily_cal, 
               color = lancet_rating, shape = lancet_rating), size = 3.5)+
  
# Add trend line  
  geom_smooth(method = lm, 
              mapping = aes(x = avg_daily_steps, y = avg_daily_cal), 
              alpha = 0.15, fill = '#7D7ABC', color = alpha('red', .25))+
  
# Order Lancet Rating legend and set colors
  scale_color_manual(
    name = "Lancet Rating",
# Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Excellent Health', 
               'Great Health', 'Decent Health', 'Health At Risk'),
    
    values = c('Excellent Health' = '#23F0C7', 
               'Great Health' = '#8884FF',
               'Decent Health' = '#FFA62B', 
               'Health At Risk' = '#EF767A'))+
  
# Order Lancet Rating legend and set shapes  
  scale_shape_manual(
    name = 'Lancet Rating',
# Add breaks to ensure order does not get randomly alphabetized    
    breaks = c('Excellent Health', 
               'Great Health', 'Decent Health', 'Health At Risk'),
    
    values = c('Excellent Health' = 16,
               'Great Health' = 17,
               'Decent Health' = 15,
               'Health At Risk' = 7)
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
    title = 'Steps vs. Calories', 
    subtitle = 'Averages of daily steps and calories burnt',
    x = 'Average Daily Steps',
    y = 'Average Daily Calories'
  )+
  
# Make comments around interesting plot points  
  annotate('text', x = 5500, y =3350, 
   label = 'High intensity active users\nwith lower step counts',
   fontface = 'plain', size = 3, color = '#7D7ABC')+
  annotate('text', x = 15000, y = 3400,
   label = 'High intesity active user\nwith high step count',
   fontface = 'plain', size = 3, color = '#10A099')+
  annotate('text', x = 6200, y = 1460,
   label = 'Users with small\n bursts of intense activity \nand low step count',
   fontface = 'plain', size = 3, color = '#D08F0F'
    
    
  )





