# fentanyl-odd

Monitoring dashboard for US fentanyl / synthetic opioid overdose deaths: national, regional, and state-level trends, with recent state-level outliers flagged.

Earlier exploratory work (multi-source hypothesis testing against the Vangelov et al. 2026 supply-shock paper) is archived in `archive/eda-v1/` and continues as a separate research track, not part of this dashboard.

## Pipeline

```
data/raw/  ->  sql/  (DuckDB)  ->  data/processed/  ->  dashboard/  (Power BI)
```

1. **Download raw data manually** (see Data Sources below) into `data/raw/`. Not committed, see `.gitignore`.
2. **Transform with DuckDB SQL**. Run the scripts in `sql/` in order against a local `.duckdb` file. See `sql/README.md`.
3. **Processed output** lands in `data/processed/` as small CSV/Parquet files. These ARE committed, since they're what the dashboard reads and they're too small to matter.
4. **Dashboard**. Power BI Desktop (free) reads directly from `data/processed/`. See `dashboard/README.md`.

## Data Sources

| Dataset | Source | Manual download |
|---|---|---|
| VSRR Provisional Drug Overdose Deaths | CDC | https://data.cdc.gov/National-Center-for-Health-Statistics/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a -- Export to CSV |
| Population estimates | US Census | https://www2.census.gov/programs-surveys/popest/datasets/ |

Save files into `data/raw/` using the same names referenced in `sql/01_load_raw.sql`.

## Setup

```bash
pip install -r requirements.txt
```

Requires the DuckDB CLI or Python `duckdb` package, and Power BI Desktop for the dashboard.

## Scope

This repo is intentionally narrow: descriptive monitoring only (trend + outlier detection). Causal/hypothesis-testing work (supply shock, treatment access, seizure correlation) lives in the archived EDA and any future research-track repo, not here — a dashboard is the wrong shape for that kind of analysis.

## References

Vangelov K, Humphreys K, Caulkins JP, Pollack H, Pardo B, Reuter P. *Did the illicit fentanyl trade experience a supply shock?* Science. 2026;391(6781):134-136. https://doi.org/10.1126/science.aea6130

Pardo B, Taylor J, Caulkins JP, Kilmer B, Reuter P, Stein BD. *The Future of Fentanyl and Other Synthetic Opioids.* RAND Corporation; 2019. https://www.rand.org/pubs/research_reports/RR3117.html
