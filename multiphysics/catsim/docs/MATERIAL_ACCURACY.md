# Material Accuracy Push (Option C)

This repo has two distinct states for ENZ material modeling:

1. **Proxy-pass (Drude)** — reproducible, *not* paper-locked
2. **Paper-locked (Table)** — uses measured/fit complex permittivity ε(ω)

The goal of Option C is to migrate Phase 6.1 and downstream comparisons from **proxy** to **paper-locked**.

## Quickstart

### 1) Generate a table from the current Drude proxy (for debugging)
```bash
python scripts/materials/material_table_from_drude.py \
  --eps_inf 3.9 --omega_p 2.816683366100322e15 --gamma 1.0e14 \
  --out data/materials/ITO_eps_table_proxy.csv
```

### 2) Switch Phase 6.1 to table mode
Edit `configs/enz_model.yaml`:
- set `mode: table`
- set `eps_table_csv: data/materials/ITO_eps_table_proxy.csv` (or a measured table)

Then run:
```bash
python scripts/phase6_1_geometric_lambda.py
python scripts/materials/material_compare_tables.py
```

### 3) Fit a Drude model to a measured ε(ω) table (initializer)
```bash
python scripts/materials/fit_drude_to_eps_table.py \
  --in data/materials/ITO_eps_table_measured.csv \
  --outdir PAPER_TABLES/ADVANCED/MATERIALS/FIT_ITO
```

## What counts as “paper-locked”
A configuration is paper-locked when:
- ε(ω) comes from a measured characterization dataset (or a fit with provenance)
- the dataset is stored in-repo (or referenced with immutable hash + retrieval script)
- Phase 6.1 uses `mode: table`
- the run emits `PARAMETERS.txt` that includes the dataset provenance

## Optional: MEEP / PySCF / pymatgen loops
The repo already supports optional engine interop. For Option C:

- **MEEP**: validate that the fitted ε(ω) reproduces observed dispersion/phase
- **PySCF**: sanity-check effective carrier density ranges (order-of-magnitude constraints)
- **pymatgen**: keep sample metadata + composition consistent across tables

These are *optional* and should degrade gracefully when deps are absent.
