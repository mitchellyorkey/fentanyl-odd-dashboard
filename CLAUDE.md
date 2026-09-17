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
- "Outlier" state = state whose most recent month deviates from its own trailing baseline beyond a threshold (defined in `sql/04_state_outliers.sql`) — not a cross-state comparison.
- NYC has historically needed separate treatment from NY State in this data — flagged again if it recurs.

---

## Current Status

| Area | Status |
|---|---|
| Repo reset / raw data untracked | ✅ Done |
| `sql/` transform scripts | 🔄 Skeletons in place, logic pending |
| `data/processed/` outputs | ⬜ Not yet generated |
| Power BI dashboard | ⬜ Not started |
| Archived EDA / hypothesis testing | ⏸ Paused, preserved in `archive/eda-v1/` |
