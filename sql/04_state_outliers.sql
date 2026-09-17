-- 04_state_outliers.sql
-- Flags states whose most recent month deviates from their own trailing baseline.
-- First-pass logic: 12-month rolling mean/stddev, flag if latest month is
-- beyond +/-2 std dev. Treat the threshold as a starting point to tune, not final.

-- New York State and New York City are reported as separate, mutually
-- exclusive rows in VSRR (confirmed by comparing NY+NYC sum against the
-- US total for May 2023 - not independently verified against CDC docs,
-- treat as a documented working assumption). Combined here for one true
-- "New York State" figure.
CREATE OR REPLACE TABLE fentanyl_deaths_state_combined AS
SELECT
    CASE WHEN state_name = 'New York City' THEN 'New York' ELSE state_name END AS state_name,
    month_date, year, month, SUM(deaths) AS deaths
FROM fentanyl_deaths
WHERE state_name NOT IN ('United States', 'Puerto Rico')
GROUP BY 1, 2, 3, 4;

-- Population join is now a plain year match against the long-format
-- state_population table (2010-2025, two Census vintages unioned in
-- 01_load_raw.sql). No per-year CASE statement needed.
CREATE OR REPLACE TABLE state_monthly AS
SELECT
    s.state_name,
    s.month_date,
    s.year,
    s.month,
    s.deaths,
    p.population,
    s.deaths / NULLIF(p.population, 0) * 100000 AS deaths_per_100k,
    AVG(s.deaths) OVER (
        PARTITION BY s.state_name ORDER BY s.month_date
        ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
    ) AS trailing_avg,
    STDDEV(s.deaths) OVER (
        PARTITION BY s.state_name ORDER BY s.month_date
        ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING
    ) AS trailing_stddev
FROM fentanyl_deaths_state_combined s
LEFT JOIN state_population p
    ON s.state_name = p.state_name AND s.year = p.year;

CREATE OR REPLACE TABLE state_outliers AS
SELECT *, (deaths - trailing_avg) / NULLIF(trailing_stddev, 0) AS z_score
FROM state_monthly
WHERE month_date = (SELECT MAX(month_date) FROM state_monthly)
  AND ABS((deaths - trailing_avg) / NULLIF(trailing_stddev, 0)) >= 2;

COPY state_outliers TO 'data/processed/state_outliers.csv' (HEADER, DELIMITER ',');
-- Also export the full state-level series for the dashboard's state drilldown:
COPY state_monthly TO 'data/processed/state_monthly.csv' (HEADER, DELIMITER ',');