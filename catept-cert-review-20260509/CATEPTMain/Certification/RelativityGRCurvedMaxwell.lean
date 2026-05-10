import CATEPTMain.Certification.RelativityGR
import CATEPTMain.Integration.NSCATEPTCoreBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open CATEPTMain.Integration.NSCATEPTCore
open NavierStokesClean.CATEPT

/-!
# Certification: General Relativity — Curved Maxwell Bridge Certificate

This module lifts the already-proved curved-Maxwell theorem surface from
`CATEPTMain.Integration.NSCATEPTCoreBridge` into the certification namespace.

The goal is declaration-level certifiability:

- proofs are real Lean declarations in `CATEPTMain.Certification.RelativityGR`,
- they are imported by `CATEPTMain.Certification`,
- and they are audited by `Certification/Audit.lean`.

No new Maxwell analysis is postulated here; we reuse existing bridge theorems.
-/

/-- Curved Maxwell law: Faraday tensor from a potential is antisymmetric. -/
abbrev CurvedMaxwellFaradayAntisymmLaw : Prop :=
  ∀ {n : Type} [Fintype n] [DecidableEq n]
    (A : OneForm n) (x : CoordVec n) (μ ν : n),
      faradayFromPotential A x μ ν = -faradayFromPotential A x ν μ

/-- Curved Maxwell law: homogeneous equation holds for `F = dA`
under mixed-partial symmetry. -/
abbrev CurvedMaxwellHomogeneousFromPotentialLaw : Prop :=
  ∀ {n : Type} [Fintype n] [DecidableEq n]
    (A : OneForm n) (_hSub : PartialDerivSubRule n) (_hA : MixedPartialSymmetric A),
      MaxwellHomogeneous (faradayFromPotential A)

/-- Curved Maxwell law: in Lorenz gauge, flat inhomogeneous potential form
reduces to the wave equation. -/
abbrev CurvedMaxwellFlatWaveReductionLaw : Prop :=
  ∀ {n : Type} [Fintype n] [DecidableEq n]
    (A : OneForm n) (J : VectorCurrent n)
    (_hSub : PartialDerivSubRule n)
    (_hMaxwell : MaxwellInhomogeneousFlatPotential A J)
    (_hLorenz : LorenzGaugeClosure A)
    (_hSymm : DivergenceMixedPartialSymmetric A),
      WaveEquationFlatPotential A J

/-- Certification record for the curved-Maxwell bridge surface reused by GR. -/
structure GRCurvedMaxwellBridgeCertificate where
  faraday_antisymm_law : CurvedMaxwellFaradayAntisymmLaw
  homogeneous_from_potential_law : CurvedMaxwellHomogeneousFromPotentialLaw
  flat_wave_reduction_law : CurvedMaxwellFlatWaveReductionLaw

/-- Canonical curved-Maxwell bridge certificate, reusing NSCATEPT core proofs. -/
def canonical_gr_curved_maxwell : GRCurvedMaxwellBridgeCertificate where
  faraday_antisymm_law := CATEPTMain.Integration.NSCATEPTCore.faraday_antisymm
  homogeneous_from_potential_law :=
    CATEPTMain.Integration.NSCATEPTCore.maxwell_homogeneous_of_potential
  flat_wave_reduction_law := CATEPTMain.Integration.NSCATEPTCore.flat_maxwell_wave_eq

/-- Projection: certified antisymmetry for `F = dA`. -/
theorem gr_curved_maxwell_faraday_antisymm
  {n : Type} [Fintype n] [DecidableEq n]
    (A : OneForm n) (x : CoordVec n) (μ ν : n) :
    faradayFromPotential A x μ ν = -faradayFromPotential A x ν μ :=
  canonical_gr_curved_maxwell.faraday_antisymm_law A x μ ν

/-- Projection: certified homogeneous Maxwell equation for potential-generated
tensors under mixed-partial symmetry. -/
theorem gr_curved_maxwell_homogeneous_of_potential
  {n : Type} [Fintype n] [DecidableEq n]
    (A : OneForm n) (hSub : PartialDerivSubRule n) (hA : MixedPartialSymmetric A) :
    MaxwellHomogeneous (faradayFromPotential A) :=
  canonical_gr_curved_maxwell.homogeneous_from_potential_law A hSub hA

/-- Projection: certified Lorenz-gauge reduction from inhomogeneous flat
potential-form Maxwell equation to wave equation. -/
theorem gr_curved_maxwell_flat_wave_eq
  {n : Type} [Fintype n] [DecidableEq n]
    (A : OneForm n) (J : VectorCurrent n)
    (hSub : PartialDerivSubRule n)
    (hMaxwell : MaxwellInhomogeneousFlatPotential A J)
    (hLorenz : LorenzGaugeClosure A)
    (hSymm : DivergenceMixedPartialSymmetric A) :
    WaveEquationFlatPotential A J :=
  canonical_gr_curved_maxwell.flat_wave_reduction_law
    A J hSub hMaxwell hLorenz hSymm

end CATEPTMain.Certification.RelativityGR

end
