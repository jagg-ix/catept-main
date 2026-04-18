# Vendored data

This directory provides **stable paths** for datasets used by optional backends.

Principles:
- **No silent large downloads.** Fetch scripts are explicit.
- **No ambiguous provenance.** Every vendored subtree must contain a `PROVENANCE.yaml`.
- **Tirole reproduction stays anchor.** Vendored data must never change baselines unless enabled via config.

What we ship by default:
- `constants/constants_si_exact.csv`: minimal SI-exact constants.
- Placeholder folders for larger datasets (Materials Project, NIST ASD, HITRAN, OQMD).

See also:
- `src/catsim_core/data_sources/registry.py`
- `scripts/data_license_check.py`
