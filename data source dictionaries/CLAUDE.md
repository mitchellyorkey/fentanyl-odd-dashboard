# CLAUDE.md — Fentanyl Overdose Death (ODD) Dashboard

This file is for Claude Code and Claude AI. Read it at the start of every session.

---

## What This Project Is

A monitoring dashboard for US fentanyl / synthetic opioid overdose deaths: national trend, regional trend, and state-level outlier detection. Descriptive only — no causal or hypothesis-testing work happens here.

Earlier exploratory/hypothesis-testing work (Vangelov et al. supply-shock investigation, CBP/SAMHSA integration plans) is archived in `archive/eda-v1/`. It is a separate research track and is not being actively developed as part of this repo right now.

---

## Repo Structure

```
fentanyl-odd/
├── CLAUDE.md
├── PRD.md
├── README.md
├── .env                    <- API keys, never commit
├── .gitignore
├── requirements.txt
│
├── data/
│   ├── raw/                <- gitignored. Manually downloaded, see README.
│   └── processed/          <- committed. Small final tables the dashboard reads.
│
├── sql/                    <- DuckDB SQL scripts, run in numeric order
│   ├── 01_load_raw.sql
│   ├── 02_national_trend.sql
│   ├── 03_regional_trend.sql
│   ├── 04_state_outliers.sql
│   └── README.md
│
├── dashboard/               <- Power BI file + notes
│   └── README.md
│
└── archive/
    └── eda-v1/              <- old notebooks, figures, references. Preserved, not deleted.
```

---

## Raw Data Files (manual download, not committed)

| File | Description |
|---|---|
| `vsrr_overdose_raw_YYYYMMDD.csv` | CDC VSRR export |
| population estimate files | US Census, per `sql/01_load_raw.sql` |

---

## Pipeline

1. Download raw files into `data/raw/` per README.
2. Run `sql/01_load_raw.sql` through `sql/04_state_outliers.sql` against a local `fentanyl.duckdb` (gitignored, rebuilt from these scripts — never hand-edited).
3. Each script's final step exports its output table to `data/processed/*.csv` or `.parquet`.
4. Power BI Desktop reads `data/processed/` directly. Refresh manually after re-running the pipeline.

---

## Key Domain Notes

- **VSRR data** is provisional and subject to revision.
- **ICD-10 code T40.4** ("Synthetic opioids, excl. methadone") is the primary indicator for fentanyl-involved deaths.
- **Every VSRR row is a "12 month-ending" total, not a single month's count** (confirmed: `SELECT DISTINCT "Period"` returns only `'12 month-ending'` — there is no monthly-only period in this dataset). `national_trend`/`regional_trend`/`state_monthly` are all trailing 12-month totals labeled by their ending month. Any chart title/axis built from these should say "12-month period ending [month]," not "monthly deaths" — and this is also why the visible decline from the 2023 peak understates the true recent-month drop (true single-month figures aren't recoverable from this data without further work — flagged as a possible future project, out of scope here).
- "Outlier" state = state whose most recent month deviates from its own trailing baseline beyond a threshold (defined in `sql/04_state_outliers.sql`) — not a cross-state comparison. Since the underlying series is already a 12-month rolling total, this baseline is not double-smoothed further beyond that.
- `fentanyl_deaths.deaths_imputed` and `state_population.population_imputed` flag rows where the number isn't a real reported/published value — always check these before trusting an outlier flag (e.g. Virginia's latest-month figure is a suppressed/missing raw value imputed to 5, which alone produces a z-score of -8.4; treat as a data artifact, not a real signal).
- **State population for 2026 is imputed** (2025 pop × 2025/2024 growth rate) — Census's Vintage 2026 estimates aren't published until Dec 2026 (confirmed against census.gov's release schedule). Swap in the real figures once released; until then, `deaths_per_100k` and any 2026 outlier flagging rides on this estimate.
- NYC has historically needed separate treatment from NY State in this data — flagged again if it recurs.

---

## Current Status

| Area | Status |
|---|---|
| Repo reset / raw data untracked | ✅ Done |
| `sql/` transform scripts | ✅ All 4 run cleanly against real data |
| `data/processed/` outputs | ✅ Generated (national/regional/state_monthly/state_outliers) |
| Power BI dashboard | ⬜ Not started — next milestone |
| Archived EDA / hypothesis testing | ⏸ Paused, preserved in `archive/eda-v1/` |
