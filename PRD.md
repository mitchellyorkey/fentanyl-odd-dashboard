# PRD: Fentanyl Overdose Death Monitoring Dashboard

## Purpose

A simple, always-current monitoring dashboard for US fentanyl overdose deaths: national trend, regional trend, state-level outliers. Secondary goal: practice SQL-first ETL (DuckDB) and a lightweight BI tool (Power BI), as a deliberate simplification from a prior notebook + cloud-pipeline direction.

This is descriptive monitoring, not causal analysis. Hypothesis-testing (supply shock, treatment access, seizure correlation) is out of scope for this repo, see `archive/eda-v1/` for that earlier work, which continues, if at all, as a separate research track.

---

## Questions This Dashboard Answers

1. What is the current national trend in synthetic opioid deaths, and how does it compare to the 2023 peak?
2. How does the trend differ by region (Census division or similar grouping)?
3. Which states are currently deviating from their own recent baseline, i.e. which are outliers right now?

Anything beyond "what is happening" (why it's happening, whether X causes Y) is explicitly out of scope here.

---

## Data Sources

| Dataset | Source | Coverage | Status |
|---|---|---|---|
| VSRR Provisional Drug Overdose Deaths | CDC | 2015-present, monthly | Manual CSV download |
| Population estimates | US Census | Matches death data years | Manual download, used for per-capita normalization |

No other datasets are in scope for this dashboard. CBP seizure data, SAMHSA treatment data, and the Vangelov replication data are archived, not part of this build.

---

## Pipeline Design

- **Ingest:** manual download into `data/raw/` (not automated, deliberate simplification; revisit later if worth automating)
- **Transform:** DuckDB SQL scripts in `sql/`, run in order, output small tables to `data/processed/`
- **Serve:** Power BI Desktop reads `data/processed/` directly

No BigQuery, no dbt, no GitHub Actions scheduling for now. If the manual-refresh cadence becomes a real pain point, revisit automation then, not before.

---

## Findings Carried Forward (from archived EDA)

- Synthetic opioid deaths peaked June 2023 at 77,695
- ~51% decline from peak to Oct 2025 (37,920)
- These numbers ground the dashboard's baseline/outlier logic but the underlying causal questions are not re-litigated here

---

## Explicitly Out of Scope (for now)

- Causal inference on the supply-shock hypothesis
- CBP seizure / SAMHSA treatment integration
- Predictive modeling
- Automated scheduled refresh / cloud pipeline

These may resume as a separate research-track effort, informed by whatever the monitoring dashboard surfaces.
