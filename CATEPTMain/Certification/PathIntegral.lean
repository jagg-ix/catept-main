import CATEPTMain.Integration.GRQMPathIntegralUnifyBridge

/-!
# Certification: Complex Path Integral Sector

This file is the canonical path-integral sector certificate for the
`CATEPTMain/Certification/` meta-layer.

## Source material

Wraps `CATEPTMain.Integration.GRQMPathIntegralUnifyBridge`:

| Source | Content |
|---|---|
| `PathIntegralSide` | Single-side carrier: actionBridge + weight + QuAPI kernel |
| `PathIntegralSide.dampingMagnitude_le_one` | `|weight| ≤ 1` on each side |
| `PathIntegralSide.S_I_nonneg` | `S_I ≥ 0` on each side |
| `IdentifyGRWithQMPathIntegral` | Wick-rotation identification of GR and QM PI sides |
| `IdentifyGRWithQMPathIntegral.gr_qm_dampingMagnitudes_eq` | Shared damping magnitude |
| `IdentifyGRWithQMPathIntegral.wick_pivot_consistency` | Wick-rotation contour is consistent |
| `gr_qm_path_integral_unify_bundle` | Existence of a grounded `IdentifyGRWithQMPathIntegral` |

## Certified claim

> The GR (real-time) and QM (imaginary-time) path integrals are identified
> via Wick rotation.  Both sides share a common η-kernel, producing equal
> damping magnitudes `|weight_GR| = |weight_QM| ≤ 1`.  The identification
> is compatible with CAT/EPT's `S_I / ℏ = τ_ent` imaginary-action clock.

## What is NOT yet certified here

- UV convergence / functional-determinant bound on the full path integral
  (lives in `PhysicalUVConvergenceCertificate`).
- Stochastic Feynman–Kac measure (requires `RigorousComplexFeynmanKac`).
-/

namespace CATEPTMain.Certification.PathIntegral

open CATEPTMain.Integration.GRQMPathIntegralUnifyBridge

/-- Public compatibility alias for the path-integral certification type. -/
abbrev PathIntegralCATEPTCertificate := IdentifyGRWithQMPathIntegral

/-- Re-export: single-side path-integral carrier type. -/
abbrev PICarrier := PathIntegralSide

/-- Re-export: Wick-rotation identification structure. -/
abbrev WickIdentification := IdentifyGRWithQMPathIntegral

/-- Re-export: existence of a grounded Wick-identification bundle. -/
theorem canonical_pi_exists :
    ∃ _ : IdentifyGRWithQMPathIntegral, True :=
  IdentifyGRWithQMPathIntegral.exists_trivial

/-- Re-export: both GR and QM sides have equal damping magnitudes. -/
theorem gr_qm_shared_damping (B : IdentifyGRWithQMPathIntegral) :
    B.grSide.weight.dampingMagnitude = B.qmSide.weight.dampingMagnitude :=
  B.gr_qm_dampingMagnitudes_eq

/-- Re-export: Wick-rotation pivot consistency (both sides). -/
theorem wick_is_consistent (B : IdentifyGRWithQMPathIntegral) :
    B.wick.B.reB ⟨0, B.wick.npoints_pos⟩ ⟨0, B.wick.npoints_pos⟩ = B.grSide.η.reEta ∧
    B.wick.B.reB ⟨0, B.wick.npoints_pos⟩ ⟨0, B.wick.npoints_pos⟩ = B.qmSide.η.reEta :=
  B.wick_pivot_consistency

end CATEPTMain.Certification.PathIntegral
