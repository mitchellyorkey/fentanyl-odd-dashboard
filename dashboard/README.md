# dashboard/

Power BI Desktop (free) file lives here: `fentanyl_monitoring.pbip`.

## Data source setup in Power BI

Get Data -> Text/CSV (or Folder, to pull all of `data/processed/` at once) -> point at:

- `data/processed/national_trend.csv`
- `data/processed/regional_trend.csv`
- `data/processed/state_outliers.csv`
- `data/processed/state_monthly.csv`

Using "Import" mode, not DirectQuery since the files are small and local, no need for a live connection.

## Refresh (Future Development)

After re-running the `sql/` scripts, open the .pbix and click Refresh (Home tab). No scheduled/automated refresh for now - manual is fine at this data volume and update cadence.

## Tentative Page Design Plan

1. **National** - single trend line, peak vs. current callout
2. **Regional** - small multiples or one chart with region as a legend/slicer
3. **State outliers** — table of currently-flagged states (from `state_outliers.csv`) + a state-level drilldown chart (from `state_monthly.csv`)

## Caveats to carry into the dashboard

- Every trend value is a **12-month period ending [month]**, not a single month's count - label chart titles/axes accordingly, don't call it "monthly deaths."
- `state_outliers.csv` / `state_monthly.csv` carry `deaths_imputed` and `population_imputed` flags - filter or visually mark rows where either is true before treating a flagged state as a real signal.
