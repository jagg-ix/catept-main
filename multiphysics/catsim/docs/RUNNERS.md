# Runners and dependency gates

## SGI suite runner

Run the full SGI overlay suite (fig6a_dz, fig6b_dv, fig8_Td1), including DB verification:

```bash
make end2end_sgi_suite
```

Outputs:
- `PAPER_TABLES/ADVANCED/DIAG/END2END_SGI_SUITE/demo_001/`
  - `deps_check.json` (dependency matrix)
  - `sgidb_verify.json` (DB/table + source verification)
  - per-scan folders with `overlay_*.csv` and logs

## Enforcing QuTiP / EinsteinPy (fail-fast)

If you want to **guarantee** the run uses the intended numerical backends (no silent fallback),
use one of these targets:

```bash
make end2end_sgi_suite_require_qutip
make end2end_sgi_suite_require_qutip_einsteinpy
```

These set environment flags:
- `REQUIRE_QUTIP=1`
- `REQUIRE_EINSTEINPY=1`

The runner calls:
- `python scripts/diag/check_deps.py --require ...`

and exits with non-zero status if required modules are missing.


## Vendoring prebuilt wheels (recommended)

```bash
make vendor_wheels
make end2end_sgi_suite_require_qutip_einsteinpy
```
