# Data provenance (Tirole temporal double-slit)

## Raw sources (bundled)
The original Excel workbooks provided by the paper are bundled **verbatim** in:

- `data_pipeline/source_data/Extended_Data_Fig_1_Source data.xlsx`
- `data_pipeline/source_data/Extended_Data_Fig_2_Source_Data.xlsx`
- `data_pipeline/source_data/Extended_Data_Fig_3_Source_data.xlsx`
- `data_pipeline/source_data/Fig_1_Source_data.xlsx`
- `data_pipeline/source_data/Fig_2_Source_data.xlsx`

These are treated as **read-only** inputs.

## Deterministic extraction pipeline
The repo provides a deterministic extraction pipeline that:

1. Splits each workbook into per-panel `.xlsx` files (`data_pipeline/user_scripts/output/...`).
2. Converts each panel into tidy `.csv` files (`data_pipeline/user_scripts/tidy_output/...`).
3. Loads the tidy CSVs into a SQLite database (`data_pipeline/user_scripts/double_slit.sqlite3`).

Run (recommended):

```bash
make xlsx_pipeline
```

Or directly:

```bash
cd data_pipeline/user_scripts
python build_and_verify_pipeline.py run
```

The pipeline includes a DB-vs-CSV verification report (`verification_report.csv`).

## Downstream usage
The main analysis pipeline reads:

- `data_pipeline/user_scripts/double_slit.sqlite3`
- `data_pipeline/user_scripts/tidy_output/`

and writes all outputs under `PAPER_TABLES/` and `PAPER_LOGS/`.
