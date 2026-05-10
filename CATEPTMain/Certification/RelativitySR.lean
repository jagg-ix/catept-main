import CATEPTMain.Bridges.PhyslibRelativityBridge.SRBridgeCertificate
import CATEPTMain.Bridges.PhyslibRelativityBridge.SpinorBridgeCertificate

/-!
# Certification: Special Relativity Sector

This file is the canonical SR-sector certificate for the
`CATEPTMain/Certification/` meta-layer.

It re-exports the two SR-bridge certificates from
`CATEPTMain/Bridges/PhyslibRelativityBridge/` and exposes one
canonical alias each:

| Alias | Source |
|---|---|
| `SRBridgeCertificate` | `PhyslibSRBridgeCertificate` (metric + causality + proper time) |
| `SRSpinorBridgeCertificate` | `PhyslibSRSpinorBridgeCertificate` (extends SR + SL(2,ℂ)) |
| `canonical_sr` | `cateptPhyslibSRBridge` |
| `canonical_sr_spinor` | `cateptPhyslibSRSpinorBridge` |

## Certified claim (Milestone 1)

> CAT/EPT finite Minkowski spacetime is sign-convention-equivalent to
> Physlib `SpaceTime 3`, preserving the Lorentz metric, timelike
> causality, proper time, and (via the spinor certificate) the SL(2,ℂ)
> self-adjoint spinor representation.

## What is NOT yet certified here

GR compatibility (curvature, Christoffel, Riemann, Ricci, Einstein,
ADM decomposition) requires a separate `RelativityGR.lean` layer
importing the Gravitas bridge theorems.
-/

namespace CATEPTMain.Certification.RelativitySR

open CATEPTMain.Bridges.PhyslibRelativityBridge

/-- Public compatibility alias for the spinor SR bridge certificate type. -/
abbrev PhyslibSRSpinorBridgeCertificate :=
  CATEPTMain.Bridges.PhyslibRelativityBridge.PhyslibSRSpinorBridgeCertificate

/-- Re-export: base SR certificate type (metric + causality + proper time). -/
abbrev SRBridgeCertificate := PhyslibSRBridgeCertificate

/-- Re-export: spinor extension certificate type (extends SR + SL(2,ℂ)). -/
abbrev SRSpinorBridgeCertificate := PhyslibSRSpinorBridgeCertificate

/-- The canonical SR bridge certificate.

Witnesses: `CATEPTST ≃ₗ[ℝ] SpaceTime 3` with
- metric: `minkowskiNorm2 x = −minkowskiProductMap (φ x) (φ x)`
- causality: `CausalTimelike x ↔ causalCharacter (φ x) = .timeLike`
- proper time: `√(−minkowskiNorm2 (p−q)) = SpaceTime.properTime (φ q) (φ p)` -/
noncomputable def canonical_sr : SRBridgeCertificate :=
  cateptPhyslibSRBridge

/-- The canonical SR + spinor bridge certificate.

Extends `canonical_sr` with:
- `det_compat`: determinant of self-adjoint image = `(−minkowskiNorm2 x : ℂ)`
- `sl2c_intertwines`: SL(2,ℂ) conjugation action commutes with the bridge -/
noncomputable def canonical_sr_spinor : SRSpinorBridgeCertificate :=
  cateptPhyslibSRSpinorBridge

/-- Any SR certificate implies positivity of the proper-time interval
for timelike-separated events. -/
theorem sr_properTime_pos
    (cert : SRBridgeCertificate) {q p : CATEPTMain.Geometry.FiniteMinkowski.CATEPTST}
    (h : CATEPTMain.Geometry.FiniteMinkowski.CausalTimelike (p - q)) :
    0 < Real.sqrt (-(CATEPTMain.Geometry.FiniteMinkowski.minkowskiNorm2 (p - q))) :=
  certificate_properTime_pos cert h

end CATEPTMain.Certification.RelativitySR
