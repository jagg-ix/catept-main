# Materials Project cache (optional)

This directory is **empty by default**.

If you run `scripts/fetch_materials_project_subset.py`, it will write a small, deterministic JSON subset here so the rest of the repo can reference it **offline**.

We do not vend Materials Project data in this repository.

- Expected files: `mp_subset__<chemsys>__limit<N>.json` + `.sha256`
- These files (if present) will be listed in `PAPER_LOGS/data_sources.json` via the v2 schema.
