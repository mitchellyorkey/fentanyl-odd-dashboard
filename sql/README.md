# sql/

DuckDB transform scripts, run in numeric order against a local `fentanyl.duckdb` file (gitignored - rebuild anytime by re-running these scripts from scratch).

## Run

```bash
duckdb fentanyl.duckdb -c ".read sql/01_load_raw.sql"
duckdb fentanyl.duckdb -c ".read sql/02_national_trend.sql"
duckdb fentanyl.duckdb -c ".read sql/03_regional_trend.sql"
duckdb fentanyl.duckdb -c ".read sql/04_state_outliers.sql"
```

Or from Python:

```python
import duckdb
con = duckdb.connect("fentanyl.duckdb")
for f in ["01_load_raw.sql", "02_national_trend.sql", "03_regional_trend.sql", "04_state_outliers.sql"]:
    con.execute(open(f"sql/{f}").read())
```

Each script after `01_load_raw.sql` ends with a `COPY ... TO 'data/processed/....csv'` (or `.parquet`) statement — that's the file the dashboard reads. Nothing here is hand-edited; if a transform is wrong, fix the SQL and re-run, don't patch the output.
