import CATEPTMain.Integration.LorentzInvariantSymmetryActions

set_option autoImplicit false

/-!
# Lorentz-invariant phase-space measure carrier

Structural carrier for a Lorentz-invariant measure acting on invariant
integrands.
-/

namespace CATEPTMain.Integration.LorentzInvariantPhaseSpaceMeasure

noncomputable section

open CATEPTMain.Integration.LorentzInvariantSymmetryActions

/-- Invariant integrands respect permutation and parity actions. -/
def invariantIntegrand (f : InvariantList -> ℝ) : Prop :=
  (∀ σ inv, f (permuteSTU σ inv) = f inv) ∧
  (∀ inv, f (parity inv) = f inv)

/-- Lorentz-invariant phase-space measure carrier. -/
structure LorentzInvariantPhaseSpaceCarrier where
  integrate : (InvariantList -> ℝ) -> ℝ
  respects_invariant_integrand :
    ∀ f g, invariantIntegrand f -> invariantIntegrand g ->
      (∀ inv, f inv = g inv) -> integrate f = integrate g

/-- Constant measure carrier (structural witness). -/
def constantCarrier (c : ℝ) : LorentzInvariantPhaseSpaceCarrier :=
  { integrate := fun _ => c
    respects_invariant_integrand := by
      intro f g hf hg hfg
      rfl }

end

end CATEPTMain.Integration.LorentzInvariantPhaseSpaceMeasure
