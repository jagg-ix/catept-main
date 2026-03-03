# Changelog

## v9.13
- Added deterministic per-phase `data_sources.json` provenance artifacts for Phase 6 outputs (and QuTiP runner), so offline bundles can state which public datasets/APIs the repository references.
- Patched additional Phase 6 scripts to emit `data_sources.json` alongside `STATUS.md` and `summary.json`.

## v9.14
- Added a deterministic Materials Project subset fetch helper (`scripts/fetch_materials_project_subset.py`) that writes a small offline cache under `data/cache/materials_project/`.
- Added Phase 6.18 MP cache gate (`scripts/phase6_18_materials_project_cache.py`) that validates any existing cache and registers it in provenance outputs.
- Extended the data-sources manifest generator to include `data/cache/**` file hashes when present.

## v9.x (prior)
- See previous bundle notes.


## v9.15+optionC (material accuracy scaffolding)
- Added scripts/materials/* to generate eps tables, fit Drude to measured eps(ω), and emit material accuracy tables.
- Added data/materials/ITO_eps_table_proxy.csv as deterministic baseline for table-mode.
- Added docs/MATERIAL_ACCURACY.md and Makefile targets for Option C workflows.
