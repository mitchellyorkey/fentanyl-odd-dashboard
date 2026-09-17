-- 02_national_trend.sql
-- National monthly total, for the top-line dashboard chart.

-- Uses CDC's own "United States" aggregate row directly - NOT a sum of states.
-- Avoids suppression-related undercounting and the NY/NYC double-count question
-- entirely, since neither affects the national row.
CREATE OR REPLACE TABLE national_trend AS
SELECT month_date, year, month, deaths AS total_deaths, percent_complete
FROM fentanyl_deaths
WHERE state_name = 'United States'
ORDER BY month_date;

COPY national_trend TO 'data/processed/national_trend.csv' (HEADER, DELIMITER ',');

-- Sanity check (run manually): peak should be June 2023, ~77,695 deaths
-- SELECT * FROM national_trend ORDER BY total_deaths DESC LIMIT 3;