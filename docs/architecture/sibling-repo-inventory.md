# Sibling-repo inventory — current state + end-state target

**Generated 2026-04-25** for the plugin-split program (Targets 4 → 6X).
This is the inventory the user was missing — what catept-main actually contains
today and what the final shape of the sibling-repo galaxy should be.

## TL;DR

| Metric | Value |
|---|---|
| Total catept-main monorepo size | **~259K LoC across ~1,565 .lean files** |
| Sibling repos already published | **21** |
| Additional siblings expected | **~12 — 17** |
| End-state sibling count target | **~33 — 38** |
| End-state catept-main "hub" target | < 5K LoC (lakefile, glue, paper artefacts) |

The "1-per-sub-bundle" trajectory we were on would have produced **~50+
siblings**. The fat-umbrella grouping (this doc's recommendation) caps it
near **~35**, closer to Mathlib's "one repo per topic family" model.

## Where the LoC actually lives in catept-main today

| Top-level lean_lib | Files | LoC | Disposition |
|---|---:|---:|---|
| `CATEPTMain/` | 538 | 83,032 | Source of all `catept-domain-*` extractions + 7 specialised ports |
| `NavierStokes/` | 284 | 82,735 | Candidate for a single `catept-ns-millennium` sibling |
| `NavierStokesClean/` | 522 | 53,930 | Same — folds into `catept-ns-millennium` |
| `QuantumInfo/` | 70 | 27,345 | Standalone sibling — `catept-quantum-info-port` |
| `CATEPT/` (top-level) | 126 | 9,367 | Rolls into `catept-core` (publication-bridge core) |
| `QuantumAlgebra/` | 16 | 1,273 | Either sibling or consolidate into `catept-domain-quantum` |
| `ClassicalInfo/` | 6 | 1,119 | Small — keep in catept-main or fold into `catept-quantum-info-port` |
| `StatMech/` | 3 | 442 | Tiny — keep in catept-main |
| **TOTAL** | **1,565** | **259,243** | |

### Inside `CATEPTMain/` — sub-bundles by physics/math category

| Category | Sub-bundles | LoC (sum) | Target sibling |
|---|---|---:|---|
| `Quantum/` | QUANTUM ✓, IMD, CBO, HSTP, PM, SCHTZ (6) | 9,060 | `catept-domain-quantum` (QUANTUM already extracted) |
| `Geometry/` | GYR, MINK, NoFTL, OCT, QUAT ✓, SM (6) | 7,907 | `catept-domain-geometry` (QUAT already extracted) |
| `GaugeTheory/` | ELECTROWEAK, EQFTRTFT, FBD, FEYNCALC, LDO, QCD (6) | 7,977 | `catept-domain-gauge` |
| `Analysis/` | CPM, FOU, LAPL, LSI, MODE, ODE (6) | 3,959 | `catept-domain-analysis` |
| `Core/` | Framework ✓ (already `catept-plugin-afp-framework`), MTN ✓, PDC, PHQ (3 left) | 1,162 | `catept-domain-core` (MTN already extracted) |
| `QuantumOps/` | Imported, IsabelleMarresDirac, PartialTrace, ProjectiveMeasurements, QuantumFourierTransform, Theoremized | 2,433 | `catept-quantum-ops-port` (Isabelle/HOL → Lean 4 port) |
| `Gravitas/` | (flat — 25 files) | 4,032 | `catept-gravitas-port` (Wolfram → Lean 4 port) |
| `Integration/` | 77 `*Bridge.lean` files (21 already extracted as `catept-plugin-*`) | ~13,830 | 56 remaining → 4 grouped `catept-integration-*` siblings |
| `CATEPT/CATEPT/` | 77 top-level files + Examples + PaperData | 15,824 | Rolls into `catept-core` + `catept-paper-artefacts` |
| `Spacetime/` (14) + `CALCULUS/` (3) + `NHQM/` (4) + `QuantumGravity/` (2) + `Probability` + `Hammer` + `Transforms` + `Units` + `External` + `Bridges` | small bits | 5,793 | Consolidate into `catept-domain-misc-physics` OR keep in catept-main |
| `Domains/` (the SuperiorMethod plugin slot) | 4 files | 378 | Stays in catept-main (this IS the plugin-slot abstraction) |

### Inside `NavierStokes*/` — the main scientific result

| Subdir | Files | LoC (NS + NSC combined) |
|---|---:|---:|
| `BKM/`, `Bohm/`, `Cameron/`, `Bridges/`, `DSF/`, `Fourier/`, `Analysis/`, `Audit/`, `Benchmark/`, `Core/`, … (NS) | 284 | 82,735 |
| `Galerkin/`, `Millennium/`, `Sobolev/`, `CATEPT/`, `AFPIsabellePilot/` (NSC) | 522 | 53,930 |

This is **~52% of catept-main by LoC**. It is the headline scientific
deliverable; extracting it gates whether catept-main can drop below 50K LoC.

## Sibling repos by class (current 21 + target additions)

### Class A — External-integration plugins (`catept-plugin-*`)
**1-per-upstream**, NOT grouped (each pins a distinct external SHA).

| # | Name | Status | Wraps |
|---|---|---|---|
| 1 | `catept-plugin-hille-yosida` | done | mrdouglasny/hille-yosida |
| 2 | `catept-plugin-brownian-motion` | done | abstract Brownian-motion contract |
| 3 | `catept-plugin-dimensional-analysis` | done | jagg-ix/LeanDimensionalAnalysis |
| 4 | `catept-plugin-cslib` | done | Timeroot/cslib |
| 5 | `catept-plugin-quantum-info` | done | quantum-information contract |
| 6 | `catept-plugin-gaussian-field-lsi` | done | jagg-ix/gaussian-field LSI |
| 7 | `catept-plugin-spectral-physics` | done | Spectral-Physics-Lean |
| 8 | `catept-plugin-degiorgi` | done | jagg-ix/DeGiorgi |
| 9 | `catept-plugin-maxwell-curvespace-pphi2` | done | Maxwell-curved-space ↔ pphi2 OS |
| 10 | `catept-plugin-vml-landau` | done | jagg-ix/aristotle (VML steady-state) |
| 11 | `catept-plugin-bochner-minlos` | done | mrdouglasny/bochner |
| 12 | `catept-plugin-carleson` | done | abstract Carleson witness |
| 13 | `catept-plugin-gibbs-measure` | done | abstract Gibbs-measure witness |
| 14 | `catept-plugin-hopf-lean` | done | abstract Hopf-algebra witness |
| 15 | `catept-plugin-kolmogorov-complexity` | done | abstract Kolmogorov-complexity witness |
| 16 | `catept-plugin-thermodynamics-lean` | done | LY thermodynamics |
| 17 | `catept-plugin-bt-compat` | done | Bridge Theory compatibility (Auci EM↔Relativity) |
| 18 | `catept-plugin-afp-framework` | done | Generic AFP carrier scaffold (T61 step 0) |

**Class A total:** 18 published, all kept as-is. ~3 more candidates may
emerge from the remaining `Integration/*Bridge.lean` cleanup, but most of
the remaining 57 bridges are already glue to existing plugins, not new
upstream wrappers. **Final Class A count: 18 — 21.**

### Class B — Domain bundles (`catept-domain-*`)
**Fat umbrellas, grouped by physics/math category.** Each ships multiple
`lean_lib`s so downstream `import` granularity is preserved.

| # | Name | Status | LoC | Sub-bundles |
|---|---|---|---:|---|
| 19 | `catept-domain-quantum` | partial (QUANTUM done) | 9,060 | QUANTUM ✓, IMD, CBO, HSTP, PM, SCHTZ |
| 20 | `catept-domain-geometry` | partial (QUAT done as standalone) | 7,907 | GYR, MINK, NoFTL, OCT, QUAT ✓, SM |
| 21 | `catept-domain-gauge` | not started | 7,977 | ELECTROWEAK, EQFTRTFT, FBD, FEYNCALC, LDO, QCD |
| 22 | `catept-domain-analysis` | not started | 3,959 | CPM, FOU, LAPL, LSI, MODE, ODE |
| 23 | `catept-domain-core` | partial (MTN done as standalone) | 1,162 | MTN ✓, PDC, PHQ |

**Class B total: 5 umbrellas.** Currently we have 3 *thin* siblings
(`catept-domain-quantum`, `catept-domain-quat`, `catept-domain-mtn`) —
two of those (`-quat` and `-mtn`) are misnamed under the fat scheme and
should be folded into `catept-domain-geometry` and `catept-domain-core`
respectively. See *Consolidation note* below.

### Class C — Standalone physics-port siblings
Each is too large or too distinct from the catept-domain-* category cuts
to belong inside a domain umbrella.

| # | Name | Status | LoC | Source / origin |
|---|---|---|---:|---|
| 24 | `catept-quantum-info-port` | not started | 27,345 | `QuantumInfo/` (Finite + InfiniteDim + ForMathlib) — IsabelleQuantumInfo Lean 4 port |
| 25 | `catept-quantum-ops-port` | not started | 2,433 | `CATEPTMain/QuantumOps/` (Isabelle/Marres/Dirac → Lean 4) |
| 26 | `catept-gravitas-port` | not started | 4,032 | `CATEPTMain/Gravitas/` (Wolfram Mathematica Gravitas → Lean 4) |

**Class C total: 3.**

### Class D — Publication/scientific-result siblings

| # | Name | Status | LoC | Source / origin |
|---|---|---|---:|---|
| 27 | `catept-core` | in-progress (helper-a) | ~1,400 | CAT/EPT publication-bridge core (Foundations, PathIntegrals, MeasurePathIntegral, Core.Assumptions). Should later absorb `CATEPT/` top-level (9.4K LoC) and parts of `CATEPTMain/CATEPT/`. |
| 28 | `catept-ns-millennium` | not started | ~136,665 | `NavierStokes/` + `NavierStokesClean/` — the headline NS-Millennium result. Largest sibling; would itself benefit from internal `lean_lib` splits. |
| 29 | `catept-paper-artefacts` (optional) | not started | ~5,000 | `CATEPTMain/CATEPT/CATEPT/{Examples, PaperData}` — pinning machine-checkable paper data away from the working core |

**Class D total: 2 — 3.**

### Class E — Integration-bridge groupings
The 56 remaining `CATEPTMain/Integration/*Bridge.lean` files are thin glue
between `catept-main` and external plugins. Most stay in `catept-main`
(they're the consumer side of the plugin slots). A handful with shared
upstreams could group:

| # | Name | Status | Files | Source |
|---|---|---|---:|---|
| 30 | `catept-integration-adscft` (optional) | not started | 8 | `Integration/AdSCFT*Bridge.lean` — holographic correspondence bridges |
| 31 | `catept-integration-stringalgebra` (optional) | not started | 6 | `Integration/String*Bridge.lean` — wraps the 6 existing StringAlgebra-* siblings |
| 32 | `catept-integration-gr` (optional) | not started | 6 | `Integration/{ADM, Bianchi, Einstein, Modular, Conditional, Complex}*Bridge.lean` — GR-domain bridges |
| 33 | `catept-integration-stochastic` (optional) | not started | 3 | `Integration/StochasticPDE*Bridge.lean` — stochastic-PDE bridges |

**Class E total: 0 — 4** (most likely keep all in catept-main as integration glue).

## Final end-state — the answer to "what siblings will I have?"

### Minimum scenario (33 siblings)
Skip Class E groupings entirely; keep all 56 remaining bridges in catept-main:
- Class A: 18
- Class B: 5
- Class C: 3
- Class D: 2 (`catept-core`, `catept-ns-millennium`)
- catept-main hub: 1 (still authoritative)
- → **33 repos including catept-main**

### Maximum scenario (38 siblings)
- Class A: 18 (no growth)
- Class B: 5
- Class C: 3
- Class D: 3 (adds `catept-paper-artefacts`)
- Class E: 4 (all 4 groupings extracted)
- catept-main hub: 1
- → **38 repos including catept-main**

The realistic target is **~33 — 35**. The variance is in Class E and whether
paper artefacts get pulled out separately.

## Consolidation note — the two misnamed thin siblings

We currently have:
- `jagg-ix/catept-domain-quat` (3 files / 264 LoC) — extracted standalone
- `jagg-ix/catept-domain-mtn` (5 files / 383 LoC) — extracted standalone

Under the fat-umbrella scheme these belong inside:
- `catept-domain-geometry` (would absorb `catept-domain-quat`'s content)
- `catept-domain-core` (would absorb `catept-domain-mtn`'s content)

**Two paths forward** when extracting subsequent bundles in those categories:

1. **Consolidate now** — when extracting MINK, OCT, NoFTL, GYR, SM, fold them
   plus QUAT into a fresh `catept-domain-geometry` repo; archive
   `catept-domain-quat` (delete or mark-readonly). Same for `-mtn` once PDC
   and PHQ are ready.
2. **Keep thin, add to umbrella later** — let `catept-domain-quat` and
   `-mtn` live as singletons until enough siblings exist to justify the
   rename pass; then do a batched migration that absorbs all thin siblings
   into their umbrellas in one commit.

Path 1 is cleaner (no rename later, fewer net repos), Path 2 ships faster.
Either is fine — the domain-umbrella scheme is robust to both.

## What stays in `catept-main` (the hub)

- `lakefile.lean` (pin manifest for all siblings)
- `lake-manifest.json`
- `README.md` (top-level docs)
- `CATEPTMain/Bridges.lean` (umbrella import — the integration entry point)
- `CATEPTMain/Domains/` (the `SuperiorMethodSlot` plugin-slot abstraction)
- `CATEPTMain/Integration/*Bridge.lean` (most of the 56 bridges — they're
   downstream-side glue, not upstream-side ports)
- `docs/architecture/` (this doc + playbooks)
- Re-export shim files under `CATEPTMain/{Quantum, Geometry, GaugeTheory,
   Analysis, Core, Gravitas, QuantumOps, …}/*` (one per sub-bundle that's
   moved out, preserving original namespaces)
- `.github/workflows/` (CI gates)
- LICENSE

**Estimated catept-main residual size:** under 5K LoC of "real" code (the
bridges + Domains + shims). The shim files are typically ~30 LoC each and
sum to a few thousand lines but have ~zero proof content.

This matches the **ModularPhysics coordination-hub pattern** noted in
`docs/architecture/plugin-rework-proposal.md`.

## Open questions for the maintainer

1. **Class E groupings** — extract them, or leave the 56 bridges in
   `catept-main`? Recommendation: leave them; bridges are the consumer
   side, not the producer side, and grouping them adds no compile-isolation
   benefit (they all import multiple Class A/B/C/D siblings anyway).
2. **`catept-ns-millennium`** — extract to its own repo, or keep in
   `catept-main`? The NS work is the headline result so there's a case for
   keeping it in the flagship repo. But it's 52% of LoC; extracting it
   massively shrinks `catept-main`.
3. **`catept-paper-artefacts`** — separate repo, or keep with `catept-core`?
   Examples/PaperData is presentation material rather than reusable
   formalisation; a separate repo is cleaner provenance, but adds friction
   when re-running paper-data examples after a core-API change.
4. **Visibility policy for Class B/C/D** — public or private? Class A
   plugins have been public (they wrap external upstreams that are public);
   Class B/C/D contain CAT/EPT *novel* work and the maintainer flagged
   2026-04-25 that **anything from sibling #18 onward is private by default**.
   That means catept-domain-* + catept-quantum-info-port + catept-gravitas-port
   + catept-quantum-ops-port + catept-core + catept-ns-millennium are all
   **private**. catept-main itself remains public.

## Cross-reference

- `docs/architecture/plugin-split.md` — the running coordination-hub README
- `docs/architecture/plugin-split-playbook.md` — extraction recipe (9 steps)
- `docs/architecture/plugin-rework-proposal.md` — original proposal that
  motivated this work
- `docs/architecture/targets/target-4-plan.md` — Target 4 (≥2 siblings) → Target 5 (scale-out wave)
- `docs/architecture/targets/helper-brief-T62b-LAPL.md` — helper-task brief template (LAPL example)
