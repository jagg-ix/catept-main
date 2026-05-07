# M5 — sibling-vs-local namespace dedup plan (2026-05-07)

Tracks `catept_spine_orphan_triage_audit_20260503` Milestone 5. The only remaining obstacle to a fully-green default `lake build` after M1–M4. Multi-day, multi-repo work.

## The collision

Three sibling sources all populate `namespace CATEPTMain.CATEPT.CATEPT` with overlapping declarations:

| Source | What it declares |
|---|---|
| **catept-main** `CATEPTMain/CATEPT/CATEPT/CATEPTPrelude.lean` | `ComplexAction Φ`, `ComplexHamiltonian`, `entropicTime`+ 2 theorems, `MeasurePathIntegralModel α` (with field `μ : Measure α`) + ~25 theorems, `ComplexSchrodingerFunctional α` |
| **catept-core sibling** `CATEPTMainExtracted/CATEPT/CATEPT/Foundations.lean` + `MeasurePathIntegral.lean` | `ComplexAction`, `ComplexHamiltonian`, `entropic_time`, `MeasurePathIntegralModel alpha` (with field `mu : Measure alpha`), plus eq-numbered theorems (eq001, eq002, eq003, eq012–14, eq017, eq046+, eq049, eq075+) |
| **NavierStokesClean sibling** `CATEPTMain/AFPBridge/CATEPT/CATEPTPrelude.lean` (vendored) | Same content as catept-main's `CATEPTPrelude.lean` (3-way duplicate) |

When any two are loaded into the same import closure, Lean reports e.g.

```
environment already contains 'CATEPTMain.CATEPT.CATEPT.ComplexHamiltonian.recOn'
from CATEPTMainExtracted.CATEPT.CATEPT.Foundations
```

This blocks `OrphanAggregator`, `QMOrphanBundle`, and `GTDEntropyAffineBridge`.

## Field-name divergence — the migration cost

`MeasurePathIntegralModel` is declared with **different field names** across the three sources:

```lean
-- catept-main CATEPTPrelude.lean (Greek):
structure MeasurePathIntegralModel (α : Type*) [MeasurableSpace α] where
  μ                   : Measure α
  ...

-- catept-core MeasurePathIntegral.lean (Latin):
structure MeasurePathIntegralModel (alpha : Type*) [MeasurableSpace alpha] where
  mu : Measure alpha
  ...
```

Catept-main consumers are **split** between the two conventions:

| Convention | File | `.μ`/`.mu` hits |
|---|---|---:|
| **Latin (catept-core)** | `CATEPTMain/CATEPT/CATEPT/ComplexMeasureBridge.lean` | 23 |
| Latin | `CATEPTMain/Integration/RigorousComplexFeynmanKac.lean` | 14 |
| Latin | `CATEPTMain/CATEPT/CATEPT/FeynmanKacBridge.lean` | 8 |
| Latin | `CATEPTMain/Integration/EntropicTimeScaleNoetherBridge.lean` | 7 |
| Latin | `CATEPTMain/CATEPT/CATEPT/TheoryPluginArchitecture.lean` | 3 |
| Latin | `CATEPTMain/Integration/UnifiedTheorySpine.lean` | 2 |
| Latin | `CATEPTMain/CATEPT/CATEPT/ModularFlowBridge.lean` | 2 |
| Latin | `CATEPTMain/CATEPT/CATEPT/TheoryPluginExamples.lean` | 1 |
| **Greek (catept-main)** | `CATEPTMain/Integration/NSCATEPTCoreBridge.lean` | 4 |
| Greek | `CATEPTMain/Integration/UnifiedTheorySpine.lean` | 5 |
| Greek | `CATEPTMain/Integration/WDWRQMMeasureBridge.lean` | 3 |
| Greek | `CATEPTMain/CATEPT/CATEPT/CATEPTPrelude.lean` | 3 (self-ref) |
| Greek | `CATEPTMain/CATEPT/CATEPT/ModularFlowBridge.lean` | 4 |

`UnifiedTheorySpine.lean` and `ModularFlowBridge.lean` use BOTH conventions — already aware of the divergence (line 223 of `UnifiedTheorySpine` has the comment _"`(modularFlowToPathIntegral ...).mu = clk.μ` definitionally"_ — confirming the carrier types are distinct).

## Decision: canonicalize on the Latin (catept-core) names

Rationale:

1. **Catept-core was extracted to be the source-of-truth.** The shim file `CATEPTMain/CATEPT/CATEPT/Foundations.lean` is already a one-liner re-export of `CATEPTMainExtracted/CATEPT/CATEPT/Foundations.lean`. The pattern was already established for `Foundations`; extending it to `MeasurePathIntegral` is the consistent move.

2. **Eight catept-main files already use the Latin names** (60+ field references) versus four files using Greek (~20 references). Migrating the smaller side is less work.

3. **The eq-numbered theorems (eq001 … eq075) are useful** and live in catept-core's Foundations. Catept-main's loose theorems (`entropicTime_nonneg`, `entropicTime_linear`) can be replaced by aliases pointing at the eq-numbered versions.

4. **NavierStokesClean's vendored copy** can be dropped after catept-main does the migration (sibling PR).

## Sub-milestones

| # | Title | Repo | Estimated effort |
|---|---|---|---|
| **M5.1** | Planning doc (this file) | catept-main | (this PR) |
| **M5.2** | Gut catept-main `CATEPTPrelude.lean` of `ComplexAction`, `ComplexHamiltonian`, `entropicTime`+theorems; replace with re-export of catept-core's | catept-main | ~1 hr |
| **M5.3** | Gut catept-main `CATEPTPrelude.lean` of `MeasurePathIntegralModel` + ~25 theorems; migrate ~4 Greek-using catept-main consumer files (~20 line changes) to use catept-core's Latin names | catept-main | ~3–4 hr |
| **M5.4** | Drop NavierStokesClean's vendored `CATEPTMain/AFPBridge/CATEPT/CATEPTPrelude.lean` | navier-stokes-project-clean | ~30 min sibling PR |
| **M5.5** | Bump catept-main's NavierStokesClean pin; verify `OrphanAggregator` compiles; wire it into root barrel | catept-main | ~30 min |

After M5 lands, the orphan-triage initiative can declare done: `OrphanAggregator` + `QMOrphanBundle` + `GTDEntropyAffineBridge` all reachable, default `lake build` fully green except for any new issues that surface deeper in the import graph.

## Risk

- The `ComplexAction` / `ComplexHamiltonian` rewrite is straightforward (no field name divergence; same fields `S_R`, `S_I`, `S_I_nonneg` and `H_R`, `H_I`, `H_I_nonneg`).

- The `MeasurePathIntegralModel` rewrite touches ~5 files with `m.μ` / `m.α` references. Each rename `μ → mu`, `α → alpha`. Mechanical via `sed`, but each file should be re-built individually after to verify the change is local.

- Catept-main has theorems named `entropicTime_nonneg`, `entropicTime_linear` (camelCase) that have ~15 consumers. After M5.2 they become `eq003_entropic_time_nonneg`, `eq003_entropic_time_linear` (snake_case from catept-core). To preserve consumer surface, keep camelCase aliases in `CATEPTPrelude.lean`:

  ```lean
  /-- Camel-case alias for `eq003_entropic_time_nonneg` (back-compat). -/
  theorem entropicTime_nonneg (hbar S_I : ℝ) (hh : 0 < hbar) (hS : 0 ≤ S_I) :
      0 ≤ entropic_time hbar S_I :=
    eq003_entropic_time_nonneg hbar S_I hh hS
  ```

  This way M5.2 doesn't ripple into 15 consumer migrations.

- After M5.3, `OrphanAggregator` should compile; this validates the migration end-to-end.

## What this PR ships

Just this planning doc. Implementation lands in M5.2–M5.5 PRs.
