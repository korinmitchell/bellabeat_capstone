WITH user_setup AS (
  SELECT
  --Grabbing weekly aggregate data to check the intensity levels of user activities
    user.Id,
    ROUND((AVG(VeryActiveMinutes) * 7), 2) AS wk_avg_very_min,
    ROUND((AVG(FairlyActiveMinutes) * 7), 2) AS wk_avg_fairly_min,
    ROUND((AVG(LightlyActiveMinutes) * 7), 2) AS wk_avg_lightly_min,
    ROUND(AVG(user.TotalSteps), 2) AS avg_daily_steps,
    ROUND(AVG(user.Calories), 2) AS avg_daily_cal
  FROM
    `colin-bellabeat-capstone.bellabeat.daily_active_mar-apr_2016` AS user
  GROUP BY
    user.Id
),

active_usage_details AS (
  SELECT
  --Slightly more detailed info on how active users were on an average weekly cycle
    details.Id,
    ROUND(SAFE_DIVIDE(COUNT(DISTINCT ActivityDate), 31) * 7, 2) AS avg_wk_active_days,
    ROUND(SAFE_DIVIDE(SAFE_DIVIDE(COUNT(DISTINCT ActivityDate), 31) * 7, 7), 3) AS wk_active_rate
  FROM
    `colin-bellabeat-capstone.bellabeat.daily_active_mar-apr_2016` AS details
  WHERE
  --Filter for users who were truly inactive while wearing the fitbit
    SedentaryMinutes < 1440
    AND Calories > 0
    AND TotalSteps > 20
  GROUP BY
    details.Id
),

active_day_check AS (
  SELECT
    Id,
    --Converting ActivityDate column into days of the week and counting specific days as heavy activity days via CASE
    FORMAT_DATE('%a', ActivityDate) AS day_of_wk,
    CASE
      WHEN SedentaryMinutes < 1440
      AND TotalSteps > 7000 
      AND Calories > 1500
      THEN 1 else 0 END AS active_day_count
  FROM
    `colin-bellabeat-capstone.bellabeat.daily_active_mar-apr_2016`
),

active_day_consistency AS (
  SELECT
    Id,
    day_of_wk,
    --Create SUM function that tallies up all heavy activty days per user
    SUM(active_day_count) AS active_num
  FROM
    `active_day_check`
  GROUP BY
    Id,
    day_of_wk
),

day_rank AS (
  SELECT
    *,
    --Checks for the #1 heaviest active day of the week per user
    ROW_NUMBER() OVER(PARTITION BY Id ORDER BY active_num DESC) AS consistency_rank
  FROM
    `active_day_consistency`
),

health_categories AS (
  SELECT *
  FROM
    `active_usage_details`
)

SELECT
  user_setup.Id,
  /*Creates user labels compliant with Lancet health study claiming 7,000+ 
  steps a day gives 47% lower risk of all-cause mortality*/
  CASE
    WHEN user_setup.avg_daily_steps >= 7000 THEN 'Excellent Health'
    WHEN user_setup.avg_daily_steps BETWEEN 5000 AND 7000 THEN 'Great Health'
    WHEN user_setup.avg_daily_steps BETWEEN 2000 AND 5000 THEN 'Decent Health'
    WHEN user_setup.avg_daily_steps < 2000 THEN 'Health At Risk'
    END AS lancet_rating,
  user_setup.wk_avg_very_min,
  user_setup.wk_avg_fairly_min,
  user_setup.avg_daily_steps,
  user_setup.avg_daily_cal,
  --Preparing label for users with no 'heavy' activity recorded
  CASE
    WHEN day_rank.active_num = 0 OR day_rank.active_num IS NULL
    THEN 'No Heavy Activity' 
    ELSE day_rank.day_of_wk
    END AS heaviest_active_day,
  day_rank.active_num AS heavy_active_count,
  
  --Using IFNULL to avoid User 4388161847's inactive 0 data
  IFNULL(active_usage_details.wk_active_rate, 0) AS wk_active_rate,
  IFNULL(active_usage_details.avg_wk_active_days, 0) AS avg_wk_active_days
  
FROM
  `user_setup`
FULL OUTER JOIN
  `active_usage_details` ON user_setup.Id = active_usage_details.Id
FULL OUTER JOIN
  `day_rank` ON user_setup.Id = day_rank.Id
WHERE
  day_rank.consistency_rank = 1

  

