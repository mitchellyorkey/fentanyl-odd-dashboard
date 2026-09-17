-- 03_regional_trend.sql
-- Regional (Census division / region column) monthly totals.

-- Regional trend via Census REGION classification. Excludes United States,
-- Puerto Rico (not in Census's 4-region scheme), and New York City (not a
-- state in the Census population file, so it has no region code here -
-- its deaths are still counted at the national level, just not regionally).
CREATE OR REPLACE TABLE regional_trend AS
SELECT
    CASE p.census_region_code
        WHEN 1 THEN 'Northeast' WHEN 2 THEN 'Midwest'
        WHEN 3 THEN 'South'     WHEN 4 THEN 'West'
        ELSE 'Unknown'
    END AS region_name,
    f.month_date, f.year, f.month,
    SUM(f.deaths) AS total_deaths
FROM fentanyl_deaths f
JOIN state_region p ON f.state_name = p.state_name
WHERE f.state_name NOT IN ('United States', 'Puerto Rico', 'New York City')
GROUP BY region_name, f.month_date, f.year, f.month
ORDER BY region_name, f.month_date;

COPY regional_trend TO 'data/processed/regional_trend.csv' (HEADER, DELIMITER ',');