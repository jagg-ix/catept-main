import Mathlib.Data.Real.Basic

/-!
# CATEPT Plugin — Maxwell-CurveSpace ↔ pphi2 Bridge

Sibling repo of `jagg-ix/catept-main`. Provides an interface-level
integration contract that links:

* CAT/EPT curved-space Maxwell side conditions,
* CurveSpace geometric energy controls,
* pphi2 OS / reconstruction witness assumptions.

It is intentionally interface-level so it remains stable while concrete
models evolve.

## Re-import contract for `catept-main`

```lean
import CATEPTPluginMaxwellCurveSpacePphi2.IntegrationBridge

open CATEPTPluginMaxwellCurveSpacePphi2 (
  CatEptMaxwellCurveSpaceModel
  Pphi2IntegrationWitness
  CatEptPphi2IntegrationContract
  catEpt_maxwell_curveSpace_pphi2_bridge)
```

## Phase status

Phase-1: interface + 1 term-proved theorem, **0 sorry**, kernel-only
axiom surface (`propext`, `Classical.choice`, `Quot.sound`).

Phase-2 work item: replace the abstract `Pphi2IntegrationWitness` Prop
fields with direct imports from `mrdouglasny/pphi2` once the OS
reconstruction theorems land in catept-main's pphi2 pin.
-/

set_option autoImplicit false

namespace CATEPTPluginMaxwellCurveSpacePphi2

/-- Minimal CAT/EPT-side model carrying curve-space and Maxwell observables. -/
structure CatEptMaxwellCurveSpaceModel where
  CurveSpace : Type
  MaxwellState : Type
  curvatureEnergy : CurveSpace → Real
  maxwellAction : MaxwellState → Real
  couplingEnergy : CurveSpace → MaxwellState → Real

/-- Interface-level witness extracted from a pphi2 lane.
    Kept abstract so the bridge can be used with multiple pphi2 formulations. -/
structure Pphi2IntegrationWitness where
  os0Analyticity : Prop
  os1Regularity : Prop
  os2EuclideanInvariance : Prop
  os3ReflectionPositivity : Prop
  os4Clustering : Prop
  hasReconstruction : Prop
  massGapLowerBound : Real
  massGapPositive : 0 < massGapLowerBound

/-- Combined integration contract: geometric and electromagnetic
    nonnegativity controls plus the full pphi2 OS package. -/
def CatEptPphi2IntegrationContract
    (m : CatEptMaxwellCurveSpaceModel)
    (w : Pphi2IntegrationWitness) : Prop :=
  (∀ x : m.CurveSpace, 0 ≤ m.curvatureEnergy x) ∧
  (∀ a : m.MaxwellState, 0 ≤ m.maxwellAction a) ∧
  (∀ x : m.CurveSpace, ∀ a : m.MaxwellState, 0 ≤ m.couplingEnergy x a) ∧
  w.os0Analyticity ∧ w.os1Regularity ∧ w.os2EuclideanInvariance ∧
  w.os3ReflectionPositivity ∧ w.os4Clustering ∧
  w.hasReconstruction ∧ 0 < w.massGapLowerBound

/-- Primary bridge theorem: if all CAT/EPT-side nonnegativity assumptions
    hold and a pphi2 witness is present, the integrated contract is
    satisfied. -/
theorem catEpt_maxwell_curveSpace_pphi2_bridge
    (m : CatEptMaxwellCurveSpaceModel)
    (w : Pphi2IntegrationWitness)
    (hCurve : ∀ x : m.CurveSpace, 0 ≤ m.curvatureEnergy x)
    (hMaxwell : ∀ a : m.MaxwellState, 0 ≤ m.maxwellAction a)
    (hCoupling : ∀ x : m.CurveSpace, ∀ a : m.MaxwellState, 0 ≤ m.couplingEnergy x a)
    (hOS0 : w.os0Analyticity)
    (hOS1 : w.os1Regularity)
    (hOS2 : w.os2EuclideanInvariance)
    (hOS3 : w.os3ReflectionPositivity)
    (hOS4 : w.os4Clustering)
    (hRec : w.hasReconstruction) :
    CatEptPphi2IntegrationContract m w :=
  ⟨hCurve, hMaxwell, hCoupling, hOS0, hOS1, hOS2, hOS3, hOS4, hRec, w.massGapPositive⟩

end CATEPTPluginMaxwellCurveSpacePphi2
