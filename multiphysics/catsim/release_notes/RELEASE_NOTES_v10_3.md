# Release Notes — v10.3-material-backends-meep-validate

Date: 2026-01-21

Adds an optional MEEP validation runner that:
- Loads the generated MEEP material stub (table-driven ε(ω))
- Runs a minimal dispersive sanity simulation if `meep` is installed
- Always emits deterministic artifacts (including dry-run manifests)

Guarantees:
- Paper-companion reproduction remains unchanged.
- Validation is opt-in; no gates are altered.
