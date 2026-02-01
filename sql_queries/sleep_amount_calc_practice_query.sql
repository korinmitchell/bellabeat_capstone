WITH sleep_log_duration AS (
  SELECT
    id,
    sleep_id,
    sleep_score,
--Calculate the difference in time between sleep logs, while avoiding differences > 1 minute
    LEAST(
      DATETIME_DIFF(
      LEAD( time_log) OVER(PARTITION BY id, sleep_id ORDER BY time_log), time_log, MINUTE), 1) AS duration
  FROM
    `colin-bellabeat-capstone.bellabeat.clean_sleep_logs`
),


sleep_bucket AS (
  SELECT
    id,
    sleep_id,
--Bucket: Add up all of the 'sleep_score = 1' sleep time per session in hours
    SUM(
      CASE
        WHEN sleep_score = 1 THEN duration
        ELSE 0
      END) / 60.0 AS hr_sleep_per_session
  FROM
    `sleep_log_duration`

  GROUP BY
    id,
    sleep_id
--Remove sleep sessions that are data errors
  HAVING
    hr_sleep_per_session < 16
    

)

SELECT 
  id,
--Aggregating hours slept per session to find average and best PR for sleep hours per user
  ROUND(AVG(hr_sleep_per_session), 2) AS avg_nightly_sleep_hours,
  ROUND(MAX(hr_sleep_per_session), 2) AS best_sleep_hours
FROM 
  `sleep_bucket`
GROUP BY
id