import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

set_option autoImplicit false

/-!
# Normalization layer: no-jump, normalized conditional, and Lindblad

Encodes the three normalization regimes for CAT/EPT open evolution
and the amplitude vs probability damping distinction.
-/

namespace CATEPTMain.Integration.NormalizationOpenSystemBridge

noncomputable section

/-- Abstract placeholders for state and operator levels. -/
constant HilbertState : Type
constant DensityMatrix : Type
constant Operator : Type

constant normSq : HilbertState → ℝ
constant expectation : HilbertState → Operator → ℝ
constant trace : DensityMatrix → ℝ

/-- No-jump evolution: norm decay driven by H_I. -/
structure NoJumpEvolution where
  hbar : ℝ
  hbar_pos : 0 < hbar
  H_I : Operator
  HI_positive : Prop
  norm_decay : ∀ ψ : HilbertState, Prop

/-- Normalized conditional evolution: centered H_I removes norm drift. -/
structure NormalizedConditionalEvolution where
  H_I : Operator
  centered_HI : Operator
  preserves_norm : ∀ ψ : HilbertState, Prop

/-- Lindblad evolution: trace-preserving open-system dynamics. -/
structure LindbladEvolution where
  jumpOps : List Operator
  effective_HI : Operator
  trace_preserving : ∀ ρ : DensityMatrix, Prop

/-- Amplitude damping factor exp(-S_I/ℏ). -/
def amplitudeDamping (S_I hbar : ℝ) : ℝ :=
  Real.exp (-(S_I / hbar))

/-- Probability damping factor exp(-2 S_I/ℏ). -/
def probabilityDamping (S_I hbar : ℝ) : ℝ :=
  Real.exp (-(2 * S_I / hbar))

/-- Probability damping is the square of amplitude damping. -/
theorem probabilityDamping_eq_sq
    (S_I hbar : ℝ) :
    probabilityDamping S_I hbar = (amplitudeDamping S_I hbar) ^ 2 := by
  unfold probabilityDamping amplitudeDamping
  ring_nf
  simp [Real.exp_add]

/-- If S_I >= 0, amplitude damping is in (0, 1]. -/
theorem amplitudeDamping_le_one
    (S_I hbar : ℝ) (hS : 0 ≤ S_I) (hh : 0 < hbar) :
    amplitudeDamping S_I hbar ≤ 1 := by
  unfold amplitudeDamping
  have hneg : -(S_I / hbar) ≤ 0 := by
    have hdiv : 0 ≤ S_I / hbar := div_nonneg hS (le_of_lt hh)
    linarith
  exact (Real.exp_le_one_iff).mpr hneg

/-- If S_I >= 0, probability damping is in (0, 1]. -/
theorem probabilityDamping_le_one
    (S_I hbar : ℝ) (hS : 0 ≤ S_I) (hh : 0 < hbar) :
    probabilityDamping S_I hbar ≤ 1 := by
  unfold probabilityDamping
  have hneg : -(2 * S_I / hbar) ≤ 0 := by
    have hdiv : 0 ≤ S_I / hbar := div_nonneg hS (le_of_lt hh)
    linarith
  exact (Real.exp_le_one_iff).mpr hneg

end

end CATEPTMain.Integration.NormalizationOpenSystemBridge
