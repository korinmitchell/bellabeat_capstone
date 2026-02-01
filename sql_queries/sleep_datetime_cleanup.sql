WITH clean_time AS (
  SELECT
    id,
    --This will change our sleep log date-time format into 24 hour format while avoiding null values
    COALESCE(
      SAFE.PARSE_DATETIME('%m/%e/%Y %H:%M:%S', datetime_string), SAFE.PARSE_DATETIME('%m/%e/%Y %H:%M:%S %p', datetime_string)  
    ) AS time_log,
    sleep_score,
    SAFE_CAST(sleep_log_id AS INT64) sleep_id
  FROM
    `colin-bellabeat-capstone.bellabeat.sleep_logs`
)

SELECT
  id,
  time_log,
  sleep_score,
  sleep_id
FROM
  `clean_time`