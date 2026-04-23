import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Data.Rat.Floor
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

/-!
# Discrete Integral Kernel (Rat-valued)

Ported from Stage 113 of the reference implementation.

Provides a certified Rat-valued left Riemann sum with fixed step `diH = 1/1000`.
Used for the numerical bound certificate (Wolfram-verified, 77000× margin).

The continuous ℝ-valued integrals (integratedEnstrophy, entropicProperTime) are
defined via Mathlib intervalIntegral in EnergyFunctionals.lean.
This kernel is kept separate for the numerical certificate only.

## Zero new axioms — all results proved.
-/

namespace NavierStokesClean.DiscreteKernel

set_option autoImplicit false

/-- Steps per unit time. -/
def diN : Nat := 1000

/-- Fixed step size: 1/1000. -/
def diH : Rat := 1 / diN

theorem diH_pos : (0 : Rat) < diH := by norm_num [diH, diN]
theorem diH_nonneg : (0 : Rat) ≤ diH := le_of_lt diH_pos

/-- Number of steps for horizon T: ⌊T · 1000⌋₊. Monotone in T. -/
noncomputable def diSteps (T : Rat) : Nat := Nat.floor (T * diN)

theorem diSteps_zero : diSteps 0 = 0 := by simp [diSteps, diN]

theorem diSteps_mono (T₁ T₂ : Rat) (h : T₁ ≤ T₂) : diSteps T₁ ≤ diSteps T₂ :=
  Nat.floor_le_floor (mul_le_mul_of_nonneg_right h (by norm_num [diN]))

/-- Left Riemann sum: `∑_{i=0}^{diSteps T − 1} f(i·diH)·diH`. -/
noncomputable def discreteIntegral (f : Rat → Rat) (T : Rat) : Rat :=
  (Finset.range (diSteps T)).sum (fun i => f ((i : Rat) * diH) * diH)

theorem discreteIntegral_zero (f : Rat → Rat) : discreteIntegral f 0 = 0 := by
  simp [discreteIntegral, diSteps_zero]

theorem discreteIntegral_nonneg (f : Rat → Rat) (T : Rat) (hf : ∀ t, 0 ≤ f t) :
    0 ≤ discreteIntegral f T :=
  Finset.sum_nonneg fun _ _ => mul_nonneg (hf _) diH_nonneg

theorem discreteIntegral_le_of_pointwise (f g : Rat → Rat) (T : Rat) (h : ∀ t, f t ≤ g t) :
    discreteIntegral f T ≤ discreteIntegral g T :=
  Finset.sum_le_sum fun _ _ => mul_le_mul_of_nonneg_right (h _) diH_nonneg

theorem discreteIntegral_mono (f : Rat → Rat) (T₁ T₂ : Rat)
    (hf : ∀ t, 0 ≤ f t) (h : T₁ ≤ T₂) :
    discreteIntegral f T₁ ≤ discreteIntegral f T₂ :=
  Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono (diSteps_mono T₁ T₂ h))
    fun _ _ _ => mul_nonneg (hf _) diH_nonneg

theorem discreteIntegral_linear (f g : Rat → Rat) (a b T : Rat) :
    discreteIntegral (fun t => a * f t + b * g t) T =
      a * discreteIntegral f T + b * discreteIntegral g T := by
  simp only [discreteIntegral]
  conv_lhs =>
    arg 2; ext i
    rw [show (a * f ((i : Rat) * diH) + b * g ((i : Rat) * diH)) * diH =
          a * (f ((i : Rat) * diH) * diH) + b * (g ((i : Rat) * diH) * diH) from by ring]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]

end NavierStokesClean.DiscreteKernel
