import NavierStokesClean.CATEPT.CurvedMaxwellUnified
import NavierStokesClean.CATEPT.BianchiComplexEFEContracts

/-!
# Curved Maxwell ↔ PhysLean Bridge

This module provides a concrete interoperability layer between:

- curved-space Maxwell formalization in `CurvedMaxwellUnified`, and
- PhysLean spatial vector-calculus theorems (`div∘curl=0`, `curl∘curl`).

The bridge is theoremized (no new axioms, no `sorry`) and packages both sides
into a single certificate type that downstream CATEPT modules can consume.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open Space

/-- Combined certificate carrying curved-Maxwell and PhysLean hypotheses. -/
structure PhysLeanCurvedMaxwellCertificate where
  A : OneForm (Fin 4)
  J : VectorCurrent (Fin 4)
  hSub : PartialDerivSubRule (Fin 4)
  hMixed : MixedPartialSymmetric A
  hGauge : LorenzGaugeClosure A
  hCurved : MaxwellInhomogeneousCurved minkowskiMetric (faradayFromPotential A) J

  spatialField : Space → EuclideanSpace ℝ (Fin 3)
  hSpatialSmooth : ContDiff ℝ 2 spatialField

namespace PhysLeanCurvedMaxwellCertificate

/-- Upgrade rule: strong mixed-partial symmetry implies the divergence-level
mixed-partial symmetry required by the Lorenz-wave reduction theorem. -/
theorem divMixedFromMixed (C : PhysLeanCurvedMaxwellCertificate) :
    DivergenceMixedPartialSymmetric C.A := by
  intro μ ν x
  have h := C.hMixed μ ν μ x
  unfold mixedPartialCommutator at h
  exact sub_eq_zero.mp h

/-- Homogeneous Maxwell equation (`dF = 0`) for the certificate potential. -/
theorem homogeneousMaxwell (C : PhysLeanCurvedMaxwellCertificate) :
    MaxwellHomogeneous (faradayFromPotential C.A) := by
  exact maxwellHomogeneous_of_potential (A := C.A) C.hSub C.hMixed

/-- Inhomogeneous Maxwell + Lorenz closure imply flat wave equation for `A`. -/
theorem waveEquationFromCurved (C : PhysLeanCurvedMaxwellCertificate) :
    WaveEquationFlatPotential C.A C.J := by
  exact curvedMaxwell_minkowski_implies_wave_of_lorenzGauge
    (A := C.A) (J := C.J) C.hSub C.hCurved C.hGauge C.divMixedFromMixed

/-- PhysLean seed: divergence of curl vanishes for the spatial field. -/
theorem spatialFirstBianchiSeed (C : PhysLeanCurvedMaxwellCertificate) :
    ∇ ⬝ (∇ × C.spatialField) = 0 :=
  physlean_first_bianchi_seed C.spatialField C.hSpatialSmooth

/-- PhysLean seed: curl-of-curl identity for the spatial field. -/
theorem spatialSecondBianchiSeed (C : PhysLeanCurvedMaxwellCertificate) :
    ∇ × (∇ × C.spatialField) = ∇ (∇ ⬝ C.spatialField) - Δ C.spatialField :=
  physlean_second_bianchi_seed C.spatialField C.hSpatialSmooth

/-- Unified theorem surface: curved Maxwell + PhysLean dual-Bianchi seeds. -/
theorem unifiedMaxwellBianchiSurface (C : PhysLeanCurvedMaxwellCertificate) :
    MaxwellHomogeneous (faradayFromPotential C.A) ∧
      WaveEquationFlatPotential C.A C.J ∧
      (∇ ⬝ (∇ × C.spatialField) = 0) ∧
      (∇ × (∇ × C.spatialField) = ∇ (∇ ⬝ C.spatialField) - Δ C.spatialField) := by
  exact ⟨C.homogeneousMaxwell, C.waveEquationFromCurved,
    C.spatialFirstBianchiSeed, C.spatialSecondBianchiSeed⟩

end PhysLeanCurvedMaxwellCertificate

end

end NavierStokesClean.CATEPT
