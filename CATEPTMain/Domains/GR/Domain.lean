import CATEPTMain.Domains.SuperiorMethod
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Algebra.Order.Field.Basic

/-!
# GR Superior-Method Domain

Defines the General-Relativity domain slots for the CATEPT plugin architecture
using the Superior-Method pattern.  Two slots are provided:

1. **Minkowski vacuum** (`minkowskiSuperiorSlot`): flat background, S_I = 0.
   The Feynman-Kac weight is 1 everywhere.  No entropic damping from gravity.

2. **Electromagnetic** (`emSuperiorSlot μ₀ hμ₀`): 4-potential A^μ on flat
   background.  S_I(A) = ‖A‖² / (2μ₀) — electromagnetic field energy density.

## Import profile (core-free)

This file does NOT import `CATEPTMain.CATEPT.CATEPT.CATEPTPort` or any
`CATEPTMain.CATEPT.CATEPT.*` core module.  It depends only on:
  - `CATEPTMain.Domains.SuperiorMethod`  (the slot interface)
  - Mathlib  (real arithmetic, `Finset.sum_nonneg`, `sq_nonneg`)
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.GR

/-- The GR Minkowski-vacuum Superior-Method slot.

    Configuration space: `Fin 4 → ℝ` (a spacetime point).
    Imaginary action: S_I = 0 everywhere (flat vacuum, no entropic damping).
    Feynman-Kac weight: exp(0) = 1 on every configuration. -/
def minkowskiSuperiorSlot : SuperiorMethodSlot where
  ConfigSpaceTy   := Fin 4 → ℝ
  actionRe        := fun _ => 0
  actionFn        := fun _ => 0
  actionFn_nonneg := fun _ => le_refl 0

/-- The Minkowski slot satisfies the CATEPT consistency constraint.
    Proof: `0 / 1 = 0` by `div_one`.  No slot unfolding. -/
theorem minkowskiSuperiorSlot_consistent :
    CATEPTMain.Integration.cateptConsistencyConstraint
      minkowskiSuperiorSlot.toCATEPTSlot :=
  minkowskiSuperiorSlot.consistent

/-- The GR electromagnetic Superior-Method slot.

    Configuration space: `Fin 4 → ℝ` (the 4-potential A^μ).
    Imaginary action: S_I(A) = ‖A‖² / (2μ₀) = (∑ μ, A μ²) / (2μ₀) ≥ 0.
    The entropic clock τ_ent(A) = S_I(A) measures EM field irreversibility. -/
noncomputable def emSuperiorSlot (μ₀ : ℝ) (hμ₀ : 0 < μ₀) : SuperiorMethodSlot where
  ConfigSpaceTy   := Fin 4 → ℝ
  actionRe        := fun _ => 0
  actionFn        := fun A => (∑ μ : Fin 4, A μ ^ 2) / (2 * μ₀)
  actionFn_nonneg := fun A =>
    div_nonneg (Finset.sum_nonneg fun μ _ => sq_nonneg (A μ)) (by linarith)

/-- The EM slot satisfies the CATEPT consistency constraint.
    Proof: `S_I(A) / 1 = S_I(A)` by `div_one`.  No slot unfolding. -/
theorem emSuperiorSlot_consistent (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (emSuperiorSlot μ₀ hμ₀).toCATEPTSlot :=
  (emSuperiorSlot μ₀ hμ₀).consistent

/-- At zero 4-potential the EM action vanishes: S_I(0) = 0. -/
theorem emSuperiorSlot_vacuum_action_zero (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    (emSuperiorSlot μ₀ hμ₀).actionFn (fun _ => 0) = 0 := by
  simp [emSuperiorSlot]

/-- The Bohmian-EM (minimally-coupled) Superior-Method slot.

    Configuration space: `Fin 4 → ℝ` (the 4-velocity/4-potential v^μ).
    Imaginary action: `S_I(v) = Σ_μ (v^μ − A_bg^μ)² / 2 ≥ 0` (natural units
    `m = ħ = e = 1`).  The background field `A_bg` shifts the origin of the
    Gaussian; at `A_bg = 0` this reduces to the free Bohmian action `‖v‖²/2`. -/
noncomputable def bohmianEMSuperiorSlot (A_bg : Fin 4 → ℝ) : SuperiorMethodSlot where
  ConfigSpaceTy   := Fin 4 → ℝ
  actionRe        := fun _ => 0
  actionFn        := fun v => (∑ μ : Fin 4, (v μ - A_bg μ) ^ 2) / 2
  actionFn_nonneg := fun v =>
    div_nonneg (Finset.sum_nonneg fun μ _ => sq_nonneg (v μ - A_bg μ)) (by norm_num)

/-- The Bohmian-EM slot satisfies the CATEPT consistency constraint by `div_one`. -/
theorem bohmianEMSuperiorSlot_consistent (A_bg : Fin 4 → ℝ) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (bohmianEMSuperiorSlot A_bg).toCATEPTSlot :=
  (bohmianEMSuperiorSlot A_bg).consistent

end CATEPTMain.Domains.GR
