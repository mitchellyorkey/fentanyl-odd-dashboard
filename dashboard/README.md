# dashboard/

Power BI Desktop (free) file lives here: `fentanyl_dashboard.pbix` (not created yet).

## Data source setup in Power BI

Get Data -> Text/CSV (or Folder, to pull all of `data/processed/` at once) -> point at:

- `data/processed/national_trend.csv`
- `data/processed/regional_trend.csv`
- `data/processed/state_outliers.csv`
- `data/processed/state_monthly.csv`

Use "Import" mode, not DirectQuery — these files are small and local, no need for a live connection.

## Refresh

After re-running the `sql/` scripts, open the .pbix and click Refresh (Home tab). No scheduled/automated refresh for now — manual is fine at this data volume and update cadence.

## Suggested pages

1. **National** — single trend line, peak vs. current callout
2. **Regional** — small multiples or one chart with region as a legend/slicer
3. **State outliers** — table of currently-flagged states (from `state_outliers.csv`) + a state-level drilldown chart (from `state_monthly.csv`)
