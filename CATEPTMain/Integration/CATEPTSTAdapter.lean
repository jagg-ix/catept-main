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

* `finiteMinkowski_CATEPTSpacetimeModel`: a vacuum-tier instance of
  `CATEPTSpacetimeModel` whose:
    - `SpaceTime` carrier is `CATEPTST = Fin 4 → ℝ` (from FiniteMinkowski),
    - `lorentzMetric x y := minkowskiNorm2 (y - x)` (from FiniteMinkowski),
    - `ept` is identically zero (vacuum tier — entropic time vanishes
      on the Minkowski reference geometry, consistent with
      `Adapters/Minkowski.minkowski`'s vacuum classification).
* `finiteMinkowski_satisfies_ept_axioms`: discharges the
  `EPTAxiomPackage` for the adapter, by direct projection through
  `catept_satisfies_ept_axioms`.
* `finiteMinkowski_lorentzMetric_eq_minkowskiNorm2`: definitional
  identity exposing that the adapter's metric IS `minkowskiNorm2 (y-x)`.

## Honest scope

This is a **vacuum-tier** adapter — `ept ≡ 0`.  It does not introduce
any new physical content; it gives the harvested FiniteMinkowski
primitives a clean type-level handshake with the canonical spine.  Live
entropic content (non-zero `ept`, dynamic clocks) lives in domain-
specific adapters (Adapters/Minkowski uses a `TemporalFramework` shape
with `ept` baked into the framework; this adapter populates the older
`CATEPTSpacetimeModel` interface with the same vacuum classification).

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

/-- **Vacuum-tier `CATEPTSpacetimeModel` from FiniteMinkowski.**

Carrier: `CATEPTST = Fin 4 → ℝ` (the harvested geometric core).
Metric: `lorentzMetric x y := minkowskiNorm2 (y - x)` — the standard
Minkowski signature `(−+++)` from the harvest.
Entropic proper time: vacuum (identically zero) — same classification as
`Adapters/Minkowski.minkowski` in the temporal-framework world.

The Phase-2 stubs (`ept_smooth`, `ept_causal_arrow`, `noFTL`) are
inherited as `True`; the adapter does not strengthen them. -/
def finiteMinkowski_CATEPTSpacetimeModel : CATEPTSpacetimeModel where
  SpaceTime := CATEPTST
  lorentzMetric := fun x y => minkowskiNorm2 (y - x)
  ept := fun _ => 0
  ept_nonneg := fun _ => le_refl 0
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

/-- The adapter's `ept` is identically zero (vacuum tier). -/
@[simp] theorem finiteMinkowski_ept_eq_zero (x : CATEPTST) :
    finiteMinkowski_CATEPTSpacetimeModel.ept x = 0 :=
  rfl

/-- ★ HEADLINE ★ The harvested FiniteMinkowski geometry, lifted via this
adapter, satisfies the full `EPTAxiomPackage`.

Proof: by `catept_satisfies_ept_axioms` — the universal CATEPTSpacetimeModel
theorem, applied to the FiniteMinkowski instance.  No per-domain work. -/
theorem finiteMinkowski_satisfies_ept_axioms :
    EPTAxiomPackage finiteMinkowski_CATEPTSpacetimeModel :=
  catept_satisfies_ept_axioms finiteMinkowski_CATEPTSpacetimeModel

end CATEPTMain.Integration.CATEPTSTAdapter
