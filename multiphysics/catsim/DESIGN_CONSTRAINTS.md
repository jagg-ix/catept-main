# DESIGN CONSTRAINTS

These are engineering invariants for the **catsim** repository.

## Anchor and gates
1. **Tirole reproduction is anchor.** Baseline optical-temporal predictions must not regress.
2. **Gates are law.** Every new backend must:
   - run behind a toggle
   - export machine-parsable `summary.json` + human `STATUS.md`
   - be SKIP (not FAIL) when optional deps are missing

## CAT/EPT time contract
All time-aware modules must be able to export (or consume) a shared contract:

* `t_s` (coordinate time)
* `tau_ent_s` (entropic proper time)
* `lambda_eff_s_inv` (effective entropy/visibility rate)

The repo already contains a CFL-aware entropic stepping controller; do not reimplement.

## Optional backends
Backends must be **soft-imported** and activated only when:
* `cat_ept_mode` and/or backend toggle is true, and
* the dependency is importable.

### MEEP↔PySCF bridge
* Must remain optional (`meep_pyscf_mode`).
* Must not require long FDTD runs in CI/quick runs.
* Must export `epsilon_timeline.csv` with the CAT/EPT time contract.

### Complex EFE residual models
* Complex-EFE residuals are **scalar probes** used only for coupling/gating.
* Configuration may select a residual model under `spacetime.efe.model`.
* Default behavior must remain *identity* when no model is selected.

### Thermodynamics engines
* Thermodynamics engines (e.g. pycalphad, ThermoPack) are **optional** and must be behind `thermo_mode`.
* They must reuse the CAT/EPT time contract and export `entropy_timeline.csv`.
* When deps are missing, phase scripts must output **SKIP** with clear provenance.

### Symbolic tooling (SymPy extensions)
* Any SymPy extension (entropic time reparameterization or information/bit dimensions) must live in a **bridge module** in this repo.
* Do **not** vendor or fork SymPy inside catsim; keep patches local and opt-in via `cat_ept_mode`.

## Data provenance is mandatory
- Any file under `data/vendor/` must have a neighboring `PROVENANCE.yaml` describing upstream, license, and how the subset was obtained.
- Large dataset fetching must be explicit via `scripts/fetch_*.py` (no silent network downloads in core code).
- Add/modify data => update `PROVENANCE.yaml` and keep subsets minimal (prefer query-driven cache over shipping bulk).

## Optics backends are optional
- Optics libraries (Diffractio, LightPipes, POPPY, HCIPy, Legume) must remain optional. Missing deps => SKIP.
- The portable contract lives in `src/cat_ept_doubleslit/optics/` and is the only place that should encode backend-specific glue.

## Lean / PhysLean formalization is optional
- Lean lives under `./lean` and is not required for running simulations.
- Phase 6.22 must SKIP cleanly when `lake` is not installed.
- Formalization targets should start by mirroring existing contracts/gates (e.g., entropic time contract, CFL step relation) before attempting full physics derivations.

## External databases (cache-only)

- catsim never fetches databases during runs.
- Materials Project integration is **cache-only** via `data/cache/materials_project/mp_subset__*.json`.
- Phase 6.19 synthesizes conservative material priors and writes generated configs to `configs/generated/` without overwriting baseline configs.
