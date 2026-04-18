# SGI suite + DB verification (v10.44)

This run implements the next steps suggested:

1) **DB completeness + source checksum verification**
2) **End-to-end SGI runner** that can execute:
   - `fig6a_dz`
   - `fig6b_dv`
   - `fig8_Td1`
   with the unified `sgi_scan` CLI using:
   - placement-aware `bath_density_field = scene`
   - Kerr clock knobs (`metric-mode kerr`, `a*`, `theta`, `observer-mode`)
   - multi-bath rate splitting (dephasing/relax/excite)
   - timegrid readout path (QuTiP when available; fallback otherwise)

## What was executed in this environment

- `scripts/diag/verify_sgi_db.py` (PASS)
  - Output: `PAPER_TABLES/ADVANCED/DIAG/DB_VERIFY/sgidb_verify.json`
  - Checks:
    - required tables exist and non-empty
    - `meta_source_files` has expected txt sources
    - recomputed sha256 of on-disk txt files match DB metadata

- `sgi_scan` for `fig6a_dz` (generated overlay table)
  - Output: `PAPER_TABLES/ADVANCED/DIAG/END2END_SGI_SUITE/demo_001/fig6a_dz/overlay_fig6a_dz_extended.csv`

### Dependency note

This container does not have `qutip` or `einsteinpy`, so the SGI physics readout uses the repo's fallback backend.
That means this run validates:
- data loading and table wiring
- scene → density-field → scale_path plumbing
- multi-bath rate construction path (and that the CLI passes knobs correctly)
- overlay generation + schemas

To validate QuTiP and EinsteinPy numerics, run `make end2end_sgi_suite` in a full environment with:
- `qutip`
- `einsteinpy`
installed.

## How to run the full suite locally

```bash
make end2end_sgi_suite
```

Outputs (one folder per scan):
- `PAPER_TABLES/ADVANCED/DIAG/END2END_SGI_SUITE/demo_001/fig6a_dz/`
- `.../fig6b_dv/`
- `.../fig8_Td1/`

DB verification:
- `PAPER_TABLES/ADVANCED/DIAG/END2END_SGI_SUITE/demo_001/sgidb_verify.json`
