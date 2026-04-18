# Reproducing the temporal double-slit comparison (Tirole) with and without CAT/EPT

This repository contains:

- `data_pipeline/user_scripts/`: Excel → tidy CSV → SQLite (`double_slit.sqlite3`)
- `scripts/paper_faithful_tables_from_xlsx.py`: **paper-faithful** protocol
  - fit one slit-separation S-set
  - predict the other S-set **without refitting**
  - writes artifacts to `PAPER_TABLES/`

The data files required to reproduce are included under:

- `data_pipeline/source_data/` (original `.xlsx` + the paper PDF)

## Setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

## 1) Build the SQLite database from Excel

```bash
cd data_pipeline/user_scripts
export DATA_DIR="../../data_pipeline/source_data"
make run
```

This produces:

- `data_pipeline/user_scripts/double_slit.sqlite3`
- `data_pipeline/user_scripts/verification_report.csv`

## 2) Generate paper-faithful tables (standard vs CAT/EPT)

From the repo root:

```bash
PYTHONPATH=src python scripts/paper_faithful_tables_from_xlsx.py \
  --db data_pipeline/user_scripts/double_slit.sqlite3 \
  --pdf data_pipeline/source_data/double-slit-optical-2206.04362v2.pdf \
  --calibrate 500 \
  --out PAPER_TABLES
```

Outputs:

- `PAPER_TABLES/calibration_S500fs.csv`
- `PAPER_TABLES/prediction_S800fs.csv`
- overlay plots (`overlay_*.png`)
- `PAPER_TABLES/PAPER_VISIBILITY_SUMMARY.json`

## Notes on the CAT/EPT hook used here

In the *temporal* model (`src/cat_ept_doubleslit/models.py`), CAT/EPT differs from the
standard model via an **entropic phase reparameterization**:

- damping term stays monotone: `exp(-λ * Δt / 2)`
- the interference phase uses an "openness" factor
  `g(λ) = 1 / (1 + λ/λ0)` so that the effective separation becomes `Δt_eff = g(λ) Δt`

This is implemented as a **minimal**, bounded, numerically-stable proxy for
"entropic proper time" effects and can be replaced by a more paper-specific mapping
once the exact operational definition is pinned down.

## 3) Phase 3 — Standard theory reproduction (IFF gates)

Before making CAT/EPT claims, run the baseline reproduction gates.

```bash
PYTHONPATH=src python scripts/phase3_iff_baseline_gates.py \
  --db data_pipeline/user_scripts/double_slit.sqlite3 \
  --out PAPER_TABLES \
  --carrier_THz 230.2 \
  --band_THz 10.0 \
  --cal_S_fs 500
```

This writes:

* `PAPER_TABLES/IFF_BASELINE/status.json` (PASS/FAIL + fitted constant k)
* `PAPER_TABLES/IFF_BASELINE/iff_baseline_compare.csv` (experimental vs simulated observables)
* `PAPER_TABLES/IFF_BASELINE/*.png` plots
