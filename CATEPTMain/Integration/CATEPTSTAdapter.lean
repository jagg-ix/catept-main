import CATEPTMain.Geometry.FiniteMinkowski
import CATEPTMain.Integration.CATEPTSpaceTime

/-!
# CATEPTSTAdapter — `FiniteMinkowski` ⟶ `CATEPTSpacetimeModel`

**Step 3 of the 2026-04-29 spacetime-harvest plan.** A small structural
adapter that lets the harvested `CATEPTMain.Geometry.FiniteMinkowski`
(PR #17) drive the canonical
`CATEPTMain.Integration.CATEPTSpaceTime.CATEPTSpacetimeModel`.

After this PR, the harvested geometry is end-to-end usable:

```text
Mathlib only
    ↓
FiniteMinkowski   (PR #17)              — pure geometry
    ↓
CATEPTSTAdapter  (THIS PR)              — bridge to canonical spine
    ↓
CATEPTSpacetimeModel + EPTAxiomPackage  — canonical spine theorems
```

## What is honestly proven

* `finiteMinkowski_CATEPTSpacetimeModel`: a finite-Minkowski adapter
  whose:
    - `SpaceTime` carrier is `CATEPTST = Fin 4 → ℝ` (from FiniteMinkowski),
    - `lorentzMetric x y := minkowskiNorm2 (y - x)` (from FiniteMinkowski),
    - `ept x := |x₀|` (non-vacuum reference clock on the harvested carrier).
* `finiteMinkowski_vacuum_CATEPTSpacetimeModel`: explicit legacy
  vacuum-tier variant with `ept ≡ 0` retained for compatibility.
* `finiteMinkowski_satisfies_ept_axioms`: discharges the
  `EPTAxiomPackage` for the active adapter, by direct projection through
  `catept_satisfies_ept_axioms`.
* `finiteMinkowski_lorentzMetric_eq_minkowskiNorm2`: definitional
  identity exposing that the adapter's metric IS `minkowskiNorm2 (y-x)`.

## Honest scope

The geometry remains **flat Minkowski** (`lorentzMetric := minkowskiNorm2 (y-x)`);
this file does not introduce curvature dynamics by itself.  It does,
however, expose a non-vacuum reference `ept` (`|x₀|`) as the default
`CATEPTSpacetimeModel` adapter, while keeping an explicit vacuum variant
for legacy uses that still need `ept ≡ 0`.

The Phase-2 stubs `ept_smooth`, `ept_causal_arrow`, `noFTL` remain `True`
in `CATEPTSpacetimeModel` itself; this adapter inherits them.  Phase-2
work to replace those stubs would compose with this adapter without
re-writing the bridge.

## Provenance & link

Closes step 3 of the spacetime-harvest sequence:
- step 1 (PR #17): `Geometry/FiniteMinkowski.lean`
- step 2 (PR #18): `Geometry/EntropicLapse.lean`
- step 3 (this PR): `Integration/CATEPTSTAdapter.lean`
- step 4 (todo):    `Integration/MISNoFTLBridge.lean`
- step 5 (todo):    `Integration/SpacetimeHarvestCatalog.lean`

Architecturally complementary to PR #19 (`QFTCurvedTemporalSpine`),
which lifted the curved-MTPI carrier into `TemporalFramework`; this
PR lifts FiniteMinkowski into `CATEPTSpacetimeModel`.  The two adapter
layers (`TemporalFramework` and `CATEPTSpacetimeModel`) are the canonical
abstract interfaces in catept-main; both are now reachable from the
harvested geometry.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CATEPTSTAdapter

open CATEPTMain.Geometry.FiniteMinkowski
open CATEPTMain.Integration.CATEPTSpaceTime

/-- **Legacy vacuum-tier `CATEPTSpacetimeModel` from FiniteMinkowski.**

Carrier: `CATEPTST = Fin 4 → ℝ` (the harvested geometric core).
Metric: `lorentzMetric x y := minkowskiNorm2 (y - x)` — the standard
Minkowski signature `(−+++)` from the harvest.
Entropic proper time: vacuum (identically zero).

The Phase-2 stubs (`ept_smooth`, `ept_causal_arrow`, `noFTL`) are
inherited as `True`; the adapter does not strengthen them. -/
def finiteMinkowski_vacuum_CATEPTSpacetimeModel : CATEPTSpacetimeModel where
  SpaceTime := CATEPTST
  lorentzMetric := fun x y => minkowskiNorm2 (y - x)
  ept := fun _ => 0
  ept_nonneg := fun _ => le_refl 0
  ept_smooth := trivial
  ept_causal_arrow := trivial
  noFTL := trivial

/-- The legacy vacuum adapter's `ept` is identically zero. -/
@[simp] theorem finiteMinkowski_vacuum_ept_eq_zero (x : CATEPTST) :
    finiteMinkowski_vacuum_CATEPTSpacetimeModel.ept x = 0 :=
  rfl

/-- Legacy vacuum adapter still satisfies the full `EPTAxiomPackage`. -/
theorem finiteMinkowski_vacuum_satisfies_ept_axioms :
    EPTAxiomPackage finiteMinkowski_vacuum_CATEPTSpacetimeModel :=
  catept_satisfies_ept_axioms finiteMinkowski_vacuum_CATEPTSpacetimeModel

/-- **Primary finite-Minkowski `CATEPTSpacetimeModel` adapter.**

Carrier: `CATEPTST = Fin 4 → ℝ`.
Metric: `lorentzMetric x y := minkowskiNorm2 (y - x)`.
Entropic proper time: non-vacuum reference clock `ept x = |x₀|`.

This keeps the harvested finite-Minkowski carrier usable through the
canonical `CATEPTSpacetimeModel` interface without forcing `ept ≡ 0`. -/
def finiteMinkowski_CATEPTSpacetimeModel : CATEPTSpacetimeModel where
  SpaceTime := CATEPTST
  lorentzMetric := fun x y => minkowskiNorm2 (y - x)
  ept := fun x => |CATEPTST.time x|
  ept_nonneg := fun x => abs_nonneg (CATEPTST.time x)
  ept_smooth := trivial
  ept_causal_arrow := trivial
  noFTL := trivial

/-- The adapter's Lorentz metric IS `minkowskiNorm2 (y - x)` —
definitional identity exposed for downstream consumers that need to
reason about the metric explicitly. -/
@[simp] theorem finiteMinkowski_lorentzMetric_eq_minkowskiNorm2 (x y : CATEPTST) :
    finiteMinkowski_CATEPTSpacetimeModel.lorentzMetric x y =
      minkowskiNorm2 (y - x) :=
  rfl

/-- The primary adapter's entropic proper time is the absolute coordinate
time component. -/
@[simp] theorem finiteMinkowski_ept_eq_abs_time (x : CATEPTST) :
    finiteMinkowski_CATEPTSpacetimeModel.ept x = |CATEPTST.time x| :=
  rfl

/-- The primary adapter is non-vacuum: at least one event has positive
entropic proper time. -/
theorem finiteMinkowski_ept_nonvacuum :
    ∃ x : CATEPTST, 0 < finiteMinkowski_CATEPTSpacetimeModel.ept x := by
  refine ⟨CATEPTST.ofTimeSpace 1 (fun _ => 0), ?_⟩
  simp [finiteMinkowski_CATEPTSpacetimeModel, CATEPTST.time, CATEPTST.ofTimeSpace]

/-- ★ HEADLINE ★ The harvested FiniteMinkowski geometry, lifted via the
primary adapter, satisfies the full `EPTAxiomPackage`.

Proof: by `catept_satisfies_ept_axioms` — the universal CATEPTSpacetimeModel
theorem, applied to the FiniteMinkowski instance.  No per-domain work. -/
theorem finiteMinkowski_satisfies_ept_axioms :
    EPTAxiomPackage finiteMinkowski_CATEPTSpacetimeModel :=
  catept_satisfies_ept_axioms finiteMinkowski_CATEPTSpacetimeModel

end CATEPTMain.Integration.CATEPTSTAdapter
