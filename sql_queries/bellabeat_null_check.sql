SELECT
  *
FROM
  `colin-bellabeat-capstone.bellabeat.daily_active_mar-apr_2016`
WHERE
  Id IS NULL
  OR ActivityDate IS NULL
  OR TotalDistance IS NULL
  OR TotalSteps IS NULL
  OR TrackerDistance IS NULL
  OR LoggedActivitiesDistance IS NULL
  OR VeryActiveDistance IS NULL
  OR VeryActiveMinutes IS NULL
  OR ModeratelyActiveDistance IS NULL
  OR LightActiveDistance IS NULL
  OR LightlyActiveMinutes IS NULL
  OR SedentaryActiveDistance IS NULL
  OR SedentaryMinutes IS NULL
  OR FairlyActiveMinutes IS NULL
  OR Calories IS NULL
