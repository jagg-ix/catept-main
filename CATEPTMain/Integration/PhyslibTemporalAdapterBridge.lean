import Physlib.SpaceAndTime.Time.Derivatives
import Physlib.Electromagnetism.Kinematics.EMPotential
import Physlib.Units.FDeriv
import Physlib.StatisticalMechanics.CanonicalEnsemble.Lemmas

/-!
# Physlib Temporal Adapter Bridge

Root-safe temporal adapter contracts backed by narrow Physlib imports.

This bridge contributes theorem-level witnesses for the single-time strategy:
- calculus over `Time` (regularity of `Time.deriv`);
- Lorentz-equivariant derivative identity for EM potential actions;
- dimensional correctness of derivatives (`fderiv_isDimensionallyCorrect`);
- thermodynamic `k_B * β = 1 / T` identity.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.PhyslibTemporalAdapter

open scoped SpaceTime

abbrev PhyslibTemporalSafeModulePath := String

/-- Root-safe Physlib modules used by the temporal adapter bridge. -/
def temporalAdapterSafeSubmodules : List PhyslibTemporalSafeModulePath :=
  [ "Physlib.SpaceAndTime.Time.Derivatives"
  , "Physlib.Electromagnetism.Kinematics.EMPotential"
  , "Physlib.Units.FDeriv"
  , "Physlib.StatisticalMechanics.CanonicalEnsemble.Lemmas"
  ]

/-- Coverage contract for root-safe temporal adapter module lanes. -/
structure TemporalAdapterSafeCoverageContract : Prop where
  hasTimeDerivatives :
    "Physlib.SpaceAndTime.Time.Derivatives" ∈ temporalAdapterSafeSubmodules
  hasElectromagnetismPotential :
    "Physlib.Electromagnetism.Kinematics.EMPotential" ∈ temporalAdapterSafeSubmodules
  hasUnitsFDeriv :
    "Physlib.Units.FDeriv" ∈ temporalAdapterSafeSubmodules
  hasCanonicalEnsembleLemmas :
    "Physlib.StatisticalMechanics.CanonicalEnsemble.Lemmas" ∈ temporalAdapterSafeSubmodules

theorem temporalAdapterSafeSubmodules_coverage :
    TemporalAdapterSafeCoverageContract where
  hasTimeDerivatives := by simp [temporalAdapterSafeSubmodules]
  hasElectromagnetismPotential := by simp [temporalAdapterSafeSubmodules]
  hasUnitsFDeriv := by simp [temporalAdapterSafeSubmodules]
  hasCanonicalEnsembleLemmas := by simp [temporalAdapterSafeSubmodules]

/-- Theorem-level temporal adapter core witness used by CAT/EPT integration. -/
structure TemporalAdapterCoreContract : Prop where
  hasTimeDerivRegularity :
    ∀ {f : Time → ℝ},
      ContDiff ℝ (⊤ : ℕ∞) f →
      Differentiable ℝ (Time.deriv f)
  hasLorentzDerivativeEquivariance :
    ∀ {d : ℕ} {μ ν : Fin 1 ⊕ Fin d} {x : SpaceTime d}
      (Λ : LorentzGroup d) (A : Electromagnetism.ElectromagneticPotential d),
      Differentiable ℝ A →
      ∂_ μ (fun y => Λ • A (Λ⁻¹ • y)) x ν =
        ∑ κ, ∑ ρ, (Λ.1 ν κ * Λ⁻¹.1 ρ μ) * ∂_ ρ A (Λ⁻¹ • x) κ
  hasDimensionallyCorrectFDeriv :
    ∀ {M1 M2 : Type}
      [NormedAddCommGroup M1] [NormedSpace ℝ M1] [ContinuousConstSMul ℝ M1] [HasDim M1]
      [NormedAddCommGroup M2] [NormedSpace ℝ M2] [SMulCommClass ℝ ℝ M2]
      [ContinuousConstSMul ℝ M2] [HasDim M2]
      (f : M1 → M2),
      IsDimensionallyCorrect f →
      Differentiable ℝ f →
      IsDimensionallyCorrect (fderiv ℝ f)
  hasThermoBetaIdentity :
    ∀ (T : Temperature),
      0 < T.val →
      (Constants.kB : ℝ) * (T.β : ℝ) = 1 / T.val

theorem physlibTemporalAdapterCoreContract :
    TemporalAdapterCoreContract where
  hasTimeDerivRegularity := by
    intro f hf
    simpa using (Time.deriv_differentiable_of_contDiff f hf)
  hasLorentzDerivativeEquivariance := by
    intro d μ ν x Λ A hA
    simpa using
      (Electromagnetism.ElectromagneticPotential.spaceTime_deriv_action_eq_sum
        (μ := μ) (ν := ν) (x := x) Λ A hA)
  hasDimensionallyCorrectFDeriv := by
    intro M1 M2 _ _ _ _ _ _ _ _ _ f hf hdiff
    simpa using (fderiv_isDimensionallyCorrect (f := f) hf hdiff)
  hasThermoBetaIdentity := by
    intro T hT
    simpa using (CanonicalEnsemble.kB_mul_beta (T := T) hT)

end CATEPTMain.Integration.PhyslibTemporalAdapter
