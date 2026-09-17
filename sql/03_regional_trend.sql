-- 03_regional_trend.sql
-- Regional (Census division / region column) monthly totals.

CREATE OR REPLACE TABLE regional_trend AS
SELECT
    region,
    date,
    SUM(deaths) AS total_deaths
FROM fentanyl_deaths
WHERE state_name != 'United States'
GROUP BY region, date
ORDER BY region, date;

COPY regional_trend TO 'data/processed/regional_trend.csv' (HEADER, DELIMITER ',');
