# SGI Reproducibility (TXT → SQLite → Harness)

This repo includes paper-extracted SGI figure tables (TXT) and a deterministic ingestion pipeline to
build a canonical SQLite database (from CSV-formatted TXT exports), similar to the double-slit dataset pipeline.

## Source files

`data/sgi_txt/` includes:
- `master-params.txt`
- `fig3.txt (CSV)`, `fig4.txt`, `fig5.txt`, `fig6A.txt`, `fig6B.txt`, `fig8.txt`
- `page1.txt` (notes / references)

## Checksum verification

Expected SHA256 values are stored in:
- `data/sgi_txt/EXPECTED_SHA256.json`

Verify:
```bash
make verify_sgi_sources
```

## Build the SGI sqlite database

```bash
make sgi_ingest
```

This produces:
- `data/sgi/sgidb.sqlite`

The database includes provenance (file hashes) in `meta_source_files`.

## Run SGI harness (GR baseline) after ingest

```bash
make sgi_repro
```

Outputs into:
- `PAPER_TABLES/ADVANCED/UI/SGI/run_from_db_001/`

## Notes

This first step provides a reproducible data backbone. A subsequent step will wire the SGI harness/UI
to query `sgidb.sqlite` for measured curves and produce measured-vs-predicted overlays.


## UI overlay
When SGI runs with `--sgidb`, the runner exports measured tables to `meas_sgi_db/` inside the run folder, and the SGI UI page can display these paper-extracted curves.


## Scan harness overlays
Generate measured-vs-predicted overlay CSVs using the scan harness:

```bash
make sgi_scan_fig6a
make sgi_scan_fig6b
make sgi_scan_fig8
```

Each scan writes overlay CSVs into the scan output folder (e.g. `overlay_fig6a_dz.csv`).


### Extended backend overlays
The scan harness can run `baseline`, `extended`, or `both` backends. Default Make targets use `both` and write separate overlay files.

You can pass extended-backend knobs:
- `--lambda0 <s^-1>`
- `--metric-mode minkowski|schwarzschild`
- `--metric-mass-kg <kg>`


### Lambda preset registry
Extended backend runs accept `--lambda-preset` (default: `off`) and optional `--lambda0` to override.
Presets are defined in `src/catsim_core/clock/lambda_presets.py`.

List presets in Python:
```python
from catsim_core.clock.lambda_presets import list_presets
print(list_presets())
```


## QuTiP quantum readout
The scan harness can optionally compute visibility using a path-qubit dephasing model.
If `qutip` is installed, it uses `qutip.mesolve`; otherwise it falls back to a closed-form dephasing approximation.

Examples:
```bash
make sgi_scan_fig6a_qutip
make sgi_scan_fig6b_qutip
```

Control dephasing with:
- `--channel-preset off|demo_low|demo_med|demo_high`
- `--gamma-phi <1/s>` (override)


## Database completeness gate
```bash
make sgi_db_validate
```
This verifies TXT hashes, expected tables, provenance rows in `meta_source_files`, and row count consistency.


## Kerr metric redshift (optional)
The extended SGI backend supports `--metric-mode kerr` with a dimensionless spin parameter:
```bash
python -m scripts.ui_modules.sgi_scan \
  --metric-mode kerr --metric-mass-kg 1.9885e30 --metric-a-star 0.9 \
  ...
```
Notes:
- This uses an analytic Kerr g_tt to compute the redshift factor sqrt(-g00) for static observers.
- Inside the ergosphere g_tt>=0 and the redshift factor is undefined; the code will raise.


### Kerr fixed-latitude mode
You can optionally fix the Kerr polar angle rather than deriving it from z/r:
```bash
python -m scripts.ui_modules.sgi_scan \
  --metric-mode kerr --metric-mass-kg 1.9885e30 --metric-a-star 0.9 --metric-theta-deg 90 \
  ...
```

### EinsteinPy cross-check
If EinsteinPy exposes a Kerr metric in your installed version, run:
```bash
make kerr_check
```
This compares our analytic `g_tt` against EinsteinPy at a sample point.


## Kerr observer models (dtau/dt)
For Kerr runs you can optionally replace the static redshift factor sqrt(-g_tt) with an observer-dependent dtau/dt factor:
- static (default)
- zamo
- circular_prograde
- circular_retrograde

Example:
```bash
make sgi_scan_fig6a_kerr_zamo
```
Or directly:
```bash
python -m scripts.ui_modules.sgi_scan \
  --metric-mode kerr --metric-mass-kg 1.9885e30 --metric-a-star 0.9 --metric-theta-deg 90 \
  --observer-mode zamo \
  ...
```


## Scene knobs (matter density + black hole placement)
Use `--scene-width-m/--scene-height-m` to enable placement anchors, then set `--bh-placement` and `--matter-placement`.
