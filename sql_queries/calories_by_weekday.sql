WITH day_count AS (

SELECT
  Id,
  Calories,
  TotalSteps,
  ActivityDate,
  SedentaryMinutes,
  --Converting ActivityDate column into days of the week
  FORMAT_DATE('%a', ActivityDate) AS day_of_week,
FROM
  `colin-bellabeat-capstone.bellabeat.daily_active_mar-apr_2016`
)

SELECT
  day_of_week,
  SUM(Calories) AS calories_by_weekday
  
FROM 
  `day_count`
WHERE
  SedentaryMinutes < 1440
  AND TotalSteps > 7000 
  AND Calories > 1500
GROUP BY
  day_of_week





