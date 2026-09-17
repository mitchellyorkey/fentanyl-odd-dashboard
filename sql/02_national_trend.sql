-- 02_national_trend.sql
-- National monthly total, for the top-line dashboard chart.

CREATE OR REPLACE TABLE national_trend AS
SELECT
    date,
    SUM(deaths) AS total_deaths
FROM fentanyl_deaths
WHERE state_name = 'United States'  -- CONFIRM: VSRR includes a national aggregate row; verify this is how it's labeled
GROUP BY date
ORDER BY date;

COPY national_trend TO 'data/processed/national_trend.csv' (HEADER, DELIMITER ',');
