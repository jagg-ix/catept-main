import CATEPTMain.Bridges.PhyslibRelativityBridge.SRBridgeCertificate
import CATEPTMain.Bridges.PhyslibRelativityBridge.SpinorBridge

/-!
# Spinor Bridge Certificate

This module extends `PhyslibSRBridgeCertificate` with the SL(2,ℂ) spinor
layer, producing `PhyslibSRSpinorBridgeCertificate`.

## What is certified here

In addition to the SR-sector fields (metric, causality, proper time), this
certificate records:

- `toSelfAdjoint` — a linear map `CATEPTST →ₗ[ℝ] selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)`
  compatible with `toPhys`.
- `det_compat` — the determinant of the self-adjoint image equals
  `(−minkowskiNorm2 x : ℂ)`, connecting the metric to the spinor geometry.
- `sl2c_intertwines` — the Physlib SL(2,ℂ) conjugation action
  `A ↦ M·A·M†` commutes with the bridge, via `SL2C.toMatrix_apply_contrMod`.

## Correct milestone label

This completes:

> **Milestone 1: Physlib SR compatibility under the CATEPT finite-Minkowski
> bridge, including the SL(2,ℂ) spinor/Lorentz representation.**

GR compatibility (Christoffel, Riemann, Einstein) requires a further layer.

## Certificate structure

```
PhyslibSRSpinorBridgeCertificate extends PhyslibSRBridgeCertificate
  toSelfAdjoint  : CATEPTST →ₗ[ℝ] selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)
  det_compat     : ∀ x, (toSelfAdjoint x).1.det = (−minkowskiNorm2 x : ℂ)
  sl2c_intertwines :
    ∀ M x, SL2C.toSelfAdjointMap M (toSelfAdjoint x) =
           toSelfAdjoint (toPhys.symm (ContrMod.toFin1dℝEquiv
             (SL2C.toMatrix M *ᵥ ⟨toPhys x⟩)))
```
-/

open CATEPTMain.Geometry.FiniteMinkowski
open Lorentz PauliMatrix MatrixGroups SpaceTime Vector

namespace CATEPTMain.Bridges.PhyslibRelativityBridge

/-- A certificate extending `PhyslibSRBridgeCertificate` with SL(2,ℂ) spinor
compatibility.

The three spinor fields certify:
1. A linear map into self-adjoint 2×2 complex matrices (the Weyl/Pauli embedding).
2. Determinant = `−minkowskiNorm2` (spinor-to-metric compatibility).
3. The SL(2,ℂ) conjugation action intertwines with the spacetime bridge
   (the Lorentz double-cover structure is preserved). -/
structure PhyslibSRSpinorBridgeCertificate extends PhyslibSRBridgeCertificate where
  /-- Linear map to self-adjoint 2×2 complex matrices, compatible with `toPhys`. -/
  toSelfAdjointMap :
    CATEPTST →ₗ[ℝ] selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)
  /-- Spinor-to-metric compatibility: the determinant of the self-adjoint image
  equals `−minkowskiNorm2 x` (coerced to ℂ). -/
  det_compat :
    ∀ x : CATEPTST,
      (toSelfAdjointMap x).1.det = (-(minkowskiNorm2 x) : ℂ)
  /-- SL(2,ℂ) intertwining: the conjugation action `A ↦ M·A·M†` commutes
  with `toSelfAdjointMap` via the Lorentz/ContrMod bridge. -/
  sl2c_intertwines :
    ∀ (M : SL(2, ℂ)) (x : CATEPTST),
      SL2C.toSelfAdjointMap M (toSelfAdjointMap x) =
      toSelfAdjointMap
        (toPhys.symm (ContrMod.toFin1dℝEquiv
          (SL2C.toMatrix M *ᵥ ⟨toPhys x⟩)))

/-- The canonical spinor bridge certificate, instantiated from `cateptToSelfAdjoint`
and the theorems proved in `SpinorBridge`. -/
noncomputable def cateptPhyslibSRSpinorBridge : PhyslibSRSpinorBridgeCertificate where
  -- SR base layer
  toPhys            := cateptEquivPhyslib
  metric_compat     := minkowskiNorm2_eq_neg_physlib
  timelike_compat   := causalTimelike_iff_physlib_timeLike
  properTime_compat := catept_sqrt_interval_eq_physlib_properTime
  -- Spinor layer
  toSelfAdjointMap  := cateptToSelfAdjoint
  det_compat        := cateptToSelfAdjoint_det
  sl2c_intertwines  := cateptToSelfAdjoint_intertwines_sl2c

end CATEPTMain.Bridges.PhyslibRelativityBridge
