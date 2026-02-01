WITH get_ibi AS (
--Convert heart rate to interbeat intervals in milliseconds
SELECT
  id,
  time_log,
  (6000.0/NULLIF(heart_rate, 0)) AS ibi_ms
FROM
  `colin-bellabeat-capstone.bellabeat.clean_heart_rate_mar-apr` AS ibi
),


heartbeat_diff AS (
-- Calculate the difference in time between a user's heartbeat to their next heartbeat
SELECT
  id,
  time_log,
  ibi_ms - LAG(ibi_ms) OVER(PARTITION BY id ORDER BY time_log) AS diff
FROM
  `get_ibi`
),


square_buckets AS (
SELECT
  h.id,
  h.time_log,

--Create 5-minute "bucket" groupings for ibi data instead of checking every second
  TIMESTAMP_SECONDS(DIV(UNIX_SECONDS(CAST(h.time_log AS TIMESTAMP)), 300) * 300) AS bucket_time,

--Square the differences in ibi to make sure they are positive
  POWER(diff, 2) AS diff_sqr,

  s.sleep_id
FROM
  `heartbeat_diff` AS h
INNER JOIN
  `colin-bellabeat-capstone.bellabeat.clean_sleep_logs` AS s
  ON h.id = s.id
  AND DATETIME_TRUNC(h.time_log, MINUTE) = DATETIME_TRUNC(s.time_log, MINUTE)
WHERE
  s.sleep_score = 1
),


base_calculations AS (
SELECT
  id,
  sleep_id,

--Calculate and select average heart rate variance during each sleep session
  SQRT(AVG(square_buckets.diff_sqr)) AS nightly_hrv_avg,

FROM
  `square_buckets`
GROUP BY
  id,
  sleep_id
),


std_dev_calculations AS (
SELECT *,
--Compare nightly average HRV to the overall average HRV of all sleep sessions and HRV standard deviation 
  AVG(nightly_hrv_avg) OVER(PARTITION BY id) AS hrv_overall_avg,
  STDDEV_SAMP(nightly_hrv_avg) OVER(PARTITION BY id) AS hrv_std_dev,

FROM
  `base_calculations`
),



--Calculate total hours of sleep_score = 1 sleep time per user



stress_labels AS (
SELECT *,
--Calculate Z score to understand sleep level stress based on heart beat variance
(nightly_hrv_avg - hrv_overall_avg) / hrv_std_dev AS stress_score,

--Categorize stress levels per sleep session
CASE
  WHEN hrv_std_dev = 0 THEN 'NORMAL' --Prevents dividing by 0
  WHEN (nightly_hrv_avg - hrv_overall_avg) / hrv_std_dev BETWEEN -1.5 AND -1.0 THEN 'LIGHT STRESS'
  WHEN (nightly_hrv_avg - hrv_overall_avg) / hrv_std_dev < -1.5 THEN 'HEAVY STRESS'
  ELSE 'NORMAL' 
END AS stress_status
FROM
  `std_dev_calculations`

WHERE
--Filter out users who only have 1 sleep session recorded
  hrv_std_dev IS NOT NULL
),


sleep_log_duration AS (
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
--Combine sleep and stress calculations into a single user-level dataset
  a.id AS user_id,
  a.total_sleep_records,
  b.avg_nightly_sleep_hours,
  b.best_sleep_hours,
  a.worst_stress_score,
  a.peak_relax_score,
  a.heavy_stress_count,
  a.light_stress_count

FROM (
  SELECT
--Grab user id and summarize total number of sleep sessions tracked
    id,
    COUNT(sleep_id) AS total_sleep_records,
--Highlight the narrowest (stressed) and widest (relaxed) fluctuations in users' heart rates during sleep as stress score
--Between 1 and -1 is standard. Above positive 1 is well relaxed. Less than -1.5 is heavy stress
    MIN(stress_score) AS worst_stress_score,
    MAX(stress_score) AS peak_relax_score,

--Count occurences of heavy and light sleep stress per user
    COUNTIF(stress_status = 'HEAVY STRESS') AS heavy_stress_count,
    COUNTIF(stress_status = 'LIGHT STRESS') AS light_stress_count

  FROM `stress_labels`
  GROUP BY
    id
) AS a

LEFT JOIN (
  SELECT 
    id,
--Aggregating hours slept per session to find average and best PR for sleep hours per user
  ROUND(AVG(hr_sleep_per_session), 2) AS avg_nightly_sleep_hours,
  ROUND(MAX(hr_sleep_per_session), 2) AS best_sleep_hours,    
  FROM
    `sleep_bucket`
  GROUP BY
    id

)AS b
  ON a.id = b.id

ORDER BY
  a.heavy_stress_count DESC
