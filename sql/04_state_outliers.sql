-- 04_state_outliers.sql
-- Flags states whose most recent month deviates from their own trailing baseline.
-- First-pass logic: 12-month rolling mean/stddev, flag if latest month is
-- beyond +/-2 std dev. Treat the threshold as a starting point to tune, not final.

CREATE OR REPLACE TABLE state_monthly AS
SELECT
    state,
    state_name,
    date,
    deaths,
    AVG(deaths) OVER (
        PARTITION BY state ORDER BY date
        ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
    ) AS trailing_avg,
    STDDEV(deaths) OVER (
        PARTITION BY state ORDER BY date
        ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
    ) AS trailing_stddev
FROM fentanyl_deaths
WHERE state_name != 'United States';

CREATE OR REPLACE TABLE state_outliers AS
SELECT
    *,
    (deaths - trailing_avg) / NULLIF(trailing_stddev, 0) AS z_score
FROM state_monthly
WHERE date = (SELECT MAX(date) FROM state_monthly)
  AND ABS((deaths - trailing_avg) / NULLIF(trailing_stddev, 0)) >= 2;

COPY state_outliers TO 'data/processed/state_outliers.csv' (HEADER, DELIMITER ',');
-- Also export the full state-level series for the dashboard's state drilldown:
COPY state_monthly TO 'data/processed/state_monthly.csv' (HEADER, DELIMITER ',');
