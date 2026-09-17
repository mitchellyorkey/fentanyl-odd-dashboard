-- 01_load_raw.sql
-- Stages the raw VSRR CSV into a clean base table. Filenames must match what's
-- actually in data/raw/ after the manual download step in README.md.

CREATE OR REPLACE TABLE vsrr_raw AS
SELECT *
FROM read_csv_auto('data/raw/vsrr_overdose_raw_*.csv', union_by_name = true);
-- union_by_name = true lets multiple snapshot files coexist if you keep more than one;
-- swap to a single explicit filename if you only ever keep the latest download.

-- Base fact table: synthetic opioid deaths (T40.4) only, one row per state/month.
CREATE OR REPLACE TABLE fentanyl_deaths AS
SELECT
    state,
    state_name,
    region,
    year,
    month,
    date,
    data_value      AS deaths,
    predicted_value AS deaths_predicted,
    percent_complete
FROM vsrr_raw
WHERE indicator = 'Synthetic opioids, excl. methadone (T40.4)' -- CONFIRM exact label against raw file
;

-- Sanity check while building this out:
-- SELECT MIN(date), MAX(date), COUNT(*) FROM fentanyl_deaths;
