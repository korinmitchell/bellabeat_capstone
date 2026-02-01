WITH clean_time AS (
  SELECT
    id,
    SAFE.PARSE_DATETIME('%m/%e/%Y %l:%M:%S %p', raw_datetime_string) AS time_log,
    heart_rate
  FROM
    `colin-bellabeat-capstone.bellabeat.heart_rate_mar-apr`
)

SELECT
  id,
  time_log,
  heart_rate
FROM
  `clean_time`