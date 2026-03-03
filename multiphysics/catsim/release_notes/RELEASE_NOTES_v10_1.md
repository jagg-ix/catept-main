# Release Notes — v10.1-material-backends

Date: 2026-01-21

This release extends v10.0-RC with **optional material backends**.
The paper-companion reproducibility path remains unchanged.

## What's new
- Optional `pymatgen` integration for structure ingestion & provenance
- Material-backend interface skeleton under `scripts/materials/backends/`
- New Make targets to run backend summaries without affecting paper gates

## Guarantee
- `make repro_from_xlsx` remains deterministic and does not require `pymatgen`.
