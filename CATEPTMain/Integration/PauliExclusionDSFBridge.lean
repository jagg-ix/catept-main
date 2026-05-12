import NavierStokesClean.CATEPT.Theoremized.Batch20260408_G129_PauliExclusionDSF0097

/-!
# Pauli Exclusion DSF Bridge

Lean-facing bridge for the theoremized Global Row 129 lane
(`Batch20260408_G129_PauliExclusionDSF0097`) from NavierStokesClean.

The bridge keeps the original theoremized implementation as the source of truth
and exposes stable CATEPTMain integration aliases for downstream modules.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.PauliExclusionDSF

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.G129

/-- Bridged model alias for the theoremized Pauli-exclusion DSF structure. -/
abbrev Model (H : Type) := PauliExclusionDSF H

/-- Bridged integer-dimension predicate. -/
abbrev isIntegerDimension {H : Type} (P : Model H) : Bool :=
  P.isIntegerDimension

/-- Bridged exclusion checker. -/
abbrev checkExclusion
    {H : Type} (P : Model H)
    (isAntisymmetric : H → Bool) (occupationOk : H → ℝ → Bool)
    (state : H) : Bool :=
  P.checkExclusion isAntisymmetric occupationOk state

/-- Canonical bridge constructor for generalized statistics on `ℂ`. -/
abbrev generalizedModel (d : ℝ) : Model ℂ :=
  createGeneralizedStatistics d

/-- Constructor dimension is preserved exactly. -/
theorem generalizedModel_dimension (d : ℝ) :
    (generalizedModel d).dimension = d :=
  createGeneralizedStatistics_dimension d

/-- Complex approximate equality is reflexive. -/
theorem approximatelyEqual_self (a : ℂ) :
    approximatelyEqual a a = true :=
  approximatelyEqual_refl a

/-- Integer-dimension branch reduces to antisymmetry check. -/
theorem checkExclusion_integer_branch_bridge
    {H : Type} (P : Model H)
    (hInt : P.isIntegerDimension = true)
    (isAntisymmetric : H → Bool) (occupationOk : H → ℝ → Bool) (state : H) :
    checkExclusion P isAntisymmetric occupationOk state = isAntisymmetric state :=
  checkExclusion_integer_branch P hInt isAntisymmetric occupationOk state

/-- Fractional-dimension branch reduces to an occupation bound check. -/
theorem checkExclusion_fractional_branch_bridge
    {H : Type} (P : Model H)
    (hFrac : P.isIntegerDimension = false)
    (isAntisymmetric : H → Bool) (occupationOk : H → ℝ → Bool) (state : H) :
    ∃ m : ℝ, checkExclusion P isAntisymmetric occupationOk state = occupationOk state m :=
  checkExclusion_fractional_branch P hFrac isAntisymmetric occupationOk state

end CATEPTMain.Integration.PauliExclusionDSF
