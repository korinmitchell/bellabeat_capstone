WITH quick_avg AS (
  SELECT
  *,
  --Establish daily averages per each user
  AVG(Calories) OVER(PARTITION BY Id) AS daily_avg_calories,
  AVG(SedentaryMinutes) OVER(PARTITION BY Id) AS daily_sedentary_minutes
  FROM
  `colin-bellabeat-capstone.bellabeat.daily_active_mar-apr_2016`

), add_sedentary AS (
  SELECT
    *,
    --Calculate for total non-sedentary usage time 
    (1440 - daily_sedentary_minutes) AS potential_active_minutes
  FROM
    `quick_avg`

)

SELECT 
  Id,
  --Calculate usage time average and percentage vs inactivity
  ROUND(AVG(potential_active_minutes), 2) AS avg_potential_min,
  ROUND(SAFE_DIVIDE(AVG(potential_active_minutes), 1440), 2) AS usage_rate
FROM `add_sedentary`
GROUP BY Id