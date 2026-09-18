-- 01_load_raw.sql
-- Stages the raw VSRR CSV into a clean base table. Filenames must match what's
-- actually in data/raw/ after the manual download step in README.md.

CREATE OR REPLACE TABLE vsrr_raw AS
SELECT * FROM read_csv_auto('data/raw/vsrr_overdose_raw.csv');

-- VSRR reports month as full text ("January"), not a number - needed for correct
-- chronological sorting/date construction.
CREATE OR REPLACE MACRO month_num(m) AS CASE m
    WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
    WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
    WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
    WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    ELSE NULL END;

-- Fact table: synthetic opioid (T40.4) deaths, one row per reporting area/month.
-- Confirmed: T40.4 = fentanyl-driving category. 7,208 rows - matches the other
-- single-drug indicators exactly (12 total indicators exist; 3 are summary rows).
CREATE OR REPLACE TABLE fentanyl_deaths AS
SELECT
    "State" AS state_abbr,
    "State Name" AS state_name,
    "Year" AS year,
    "Month" AS month,
    make_date("Year", month_num("Month"), 1) AS month_date,
    "Period"                         AS period,
    -- Suppressed counts (true value 1-9, masked for privacy) arrive as NULL.
    -- Confirmed via raw data: values jump 0 -> 10 with nothing 1-9 reported.
    -- True zeros ARE reported as 0 already - not conflated with suppression.
    -- Imputed as midpoint (5): unbiased if suppressed values are ~uniform
    -- across 1-9; any single row could still be off by up to +/-4.
    COALESCE(CAST(REPLACE("Data Value", ',', '') AS DOUBLE), 5) AS deaths,
    -- Flag so anything downstream (esp. z-score outlier flagging) can tell
    -- a real value from an imputed one - a suppressed/missing row hitting
    -- the imputed 5 next to a normal baseline reads as a huge fake z-score.
    "Data Value" IS NULL                AS deaths_imputed,
    "Percent Complete"               AS percent_complete
FROM vsrr_raw
WHERE "Indicator" = 'Synthetic opioids, excl. methadone (T40.4)';

-- Census state population, Vintage 2025. SUMLEV 40 = state-level rows only
-- (excludes nation/region/division summary rows also present in this file).
-- Coverage: 2020-2025 only - no population data exists here for 2015-2019.
-- Two Census vintages combined into one long-format series: state, year, population.
-- 2010-2019 from Vintage 2020 file; 2020-2025 from Vintage 2025 file. The 2020
-- value is deliberately taken from the NEWER file only (Vintage 2025's revised
-- 2020 estimate), since Census revises earlier years with each new vintage -
-- the newer number is presumed more accurate. SUMLEV cast to INT for a
-- consistent filter across both files (arrives as VARCHAR in the 2010-2020 file,
-- differently typed in the other - cast forces both to match).
CREATE OR REPLACE TABLE state_population AS
SELECT state_name, CAST(REPLACE(year_col, 'POPESTIMATE', '') AS INTEGER) AS year, population, FALSE AS population_imputed
FROM (
    UNPIVOT (
        SELECT "NAME" AS state_name,
               POPESTIMATE2010, POPESTIMATE2011, POPESTIMATE2012, POPESTIMATE2013,
               POPESTIMATE2014, POPESTIMATE2015, POPESTIMATE2016, POPESTIMATE2017,
               POPESTIMATE2018, POPESTIMATE2019
        FROM read_csv_auto('data/seeds/NST-EST2020-ALLDATA.csv')
        WHERE TRY_CAST("SUMLEV" AS INTEGER) = 40
    )
    ON COLUMNS('POPESTIMATE.*')
    INTO NAME year_col VALUE population
)

UNION ALL

SELECT state_name, CAST(REPLACE(year_col, 'POPESTIMATE', '') AS INTEGER) AS year, population, FALSE AS population_imputed
FROM (
    UNPIVOT (
        SELECT "NAME" AS state_name,
               POPESTIMATE2020, POPESTIMATE2021, POPESTIMATE2022, POPESTIMATE2023,
               POPESTIMATE2024, POPESTIMATE2025
        FROM read_csv_auto('data/seeds/NST-EST2025-ALLDATA.csv')
        WHERE TRY_CAST("SUMLEV" AS INTEGER) = 40
    )
    ON COLUMNS('POPESTIMATE.*')
    INTO NAME year_col VALUE population
)

UNION ALL

-- 2026 has no official Census estimate yet (Vintage 2026 isn't published
-- until Dec 2026 - confirmed against census.gov's release schedule). VSRR
-- data already runs into 2026, so without this the per-capita/outlier
-- calcs would just go blank for the newest, most-relevant months.
-- Imputed as: 2025 population x (2025/2024 growth rate) - i.e. carrying
-- each state's most recent observed YoY growth forward one year. Simple
-- and directionally fine for a monitoring dashboard, but it IS a guess -
-- population_imputed flags it downstream, and swap in the real Vintage
-- 2026 figures once released (due Dec 2026).
SELECT
    "NAME" AS state_name,
    2026 AS year,
    ROUND(POPESTIMATE2025 * (POPESTIMATE2025 / NULLIF(POPESTIMATE2024, 0))) AS population,
    TRUE AS population_imputed
FROM read_csv_auto('data/seeds/NST-EST2025-ALLDATA.csv')
WHERE TRY_CAST("SUMLEV" AS INTEGER) = 40;

-- separate lookup for region
-- Sourced from the newer Census file
-- region codes don't change between vintages.
CREATE OR REPLACE TABLE state_region AS
SELECT DISTINCT "NAME" AS state_name, TRY_CAST("REGION" AS INTEGER) AS census_region_code
FROM read_csv_auto('data/seeds/NST-EST2025-ALLDATA.csv')
WHERE TRY_CAST("SUMLEV" AS INTEGER) = 40;