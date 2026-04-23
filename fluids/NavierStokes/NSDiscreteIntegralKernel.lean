import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Data.Rat.Floor
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

/-!
# Stage 113A: Discrete Integral Kernel for Rat-Valued Integrals

## Purpose

Provides a certified Rat-valued left Riemann sum (discrete integral) with
a fixed step size `diH = 1/1000`. This replaces the opaque `axiom` declarations
for integrated quantities (integratedEnstrophy, entropicProperTime, integratedXiTr,
etc.) with concrete `noncomputable def`s whose monotonicity, nonnegativity, and
linearity are provable as **theorems** — introducing **zero new axioms**.

## Design

```
diN   : Nat  := 1000          -- number of steps per unit time
diH   : Rat  := 1/1000        -- fixed step size
diSteps T    := ⌊T * 1000⌋₊   -- number of steps for horizon T
discreteIntegral f T := Σᵢ₌₀^{diSteps T - 1} f(i * diH) * diH
```

The key lemmas provable without new axioms:
1. `discreteIntegral_zero`:          `discreteIntegral f 0 = 0`
2. `diSteps_mono`:                    `T₁ ≤ T₂ → diSteps T₁ ≤ diSteps T₂`
3. `discreteIntegral_nonneg`:         `(∀ t, 0 ≤ f t) → 0 ≤ discreteIntegral f T`
4. `discreteIntegral_le_of_pointwise`: `(∀ t, f t ≤ g t) → di f T ≤ di g T`
5. `discreteIntegral_mono`:           `(∀ t, 0 ≤ f t) → T₁ ≤ T₂ → di f T₁ ≤ di f T₂`
6. `discreteIntegral_linear`:         `di (a·f + b·g) T = a · di f T + b · di g T`

## Net counts (Stage 113A)

  - New axioms:   0
  - New theorems: 7 (zero + diSteps_mono + nonneg + pointwise + mono + linear + diH_pos)
  - New files:    1
-/

namespace NavierStokes.DiscreteKernel

set_option autoImplicit false

/-! ## Parameters -/

/-- Number of discrete steps per unit physical time. -/
def diN : Nat := 1000

/-- Fixed step size: diH = 1/1000. -/
def diH : Rat := 1 / diN

/-- diH is positive. -/
theorem diH_pos : (0 : Rat) < diH := by norm_num [diH, diN]

/-- diH is nonneg. -/
theorem diH_nonneg : (0 : Rat) ≤ diH := le_of_lt diH_pos

/-! ## Step Count -/

/-- Number of discrete steps for horizon T: ⌊T · 1000⌋₊.
    Equals 0 for T ≤ 0 (by the definition of Nat.floor for nonpositive arguments).
    Monotone in T (proved as `diSteps_mono`). -/
noncomputable def diSteps (T : Rat) : Nat :=
  Nat.floor (T * diN)

theorem diSteps_zero : diSteps 0 = 0 := by
  simp [diSteps, diN]

theorem diSteps_mono (T₁ T₂ : Rat) (h : T₁ ≤ T₂) : diSteps T₁ ≤ diSteps T₂ := by
  unfold diSteps
  apply Nat.floor_le_floor
  exact mul_le_mul_of_nonneg_right h (by norm_num [diN])

/-! ## Discrete Integral -/

/-- Left Riemann sum with fixed step `diH = 1/1000`:
    `∑_{i=0}^{diSteps T - 1} f(i · diH) · diH`. -/
noncomputable def discreteIntegral (f : Rat → Rat) (T : Rat) : Rat :=
  (Finset.range (diSteps T)).sum (fun i => f ((i : Rat) * diH) * diH)

/-! ## Core Theorems -/

/-- The discrete integral at T = 0 is zero (empty sum). -/
theorem discreteIntegral_zero (f : Rat → Rat) : discreteIntegral f 0 = 0 := by
  simp [discreteIntegral, diSteps_zero]

/-- The discrete integral of a nonneg function is nonneg. -/
theorem discreteIntegral_nonneg (f : Rat → Rat) (T : Rat) (hf : ∀ t, 0 ≤ f t) :
    0 ≤ discreteIntegral f T := by
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hf _) diH_nonneg

/-- Pointwise inequality lifts to discrete integral inequality. -/
theorem discreteIntegral_le_of_pointwise (f g : Rat → Rat) (T : Rat)
    (h : ∀ t, f t ≤ g t) :
    discreteIntegral f T ≤ discreteIntegral g T := by
  apply Finset.sum_le_sum
  intro i _
  exact mul_le_mul_of_nonneg_right (h _) diH_nonneg

/-- The discrete integral of a nonneg function is monotone in the horizon T. -/
theorem discreteIntegral_mono (f : Rat → Rat) (T₁ T₂ : Rat)
    (hf : ∀ t, 0 ≤ f t) (h : T₁ ≤ T₂) :
    discreteIntegral f T₁ ≤ discreteIntegral f T₂ := by
  simp only [discreteIntegral]
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · exact Finset.range_mono (diSteps_mono T₁ T₂ h)
  · intro i _ _
    exact mul_nonneg (hf _) diH_nonneg

/-- Linearity of the discrete integral:
    `∫(a·f + b·g) = a·∫f + b·∫g`. -/
theorem discreteIntegral_linear (f g : Rat → Rat) (a b T : Rat) :
    discreteIntegral (fun t => a * f t + b * g t) T =
      a * discreteIntegral f T + b * discreteIntegral g T := by
  simp only [discreteIntegral]
  conv_lhs =>
    arg 2
    ext i
    rw [show (a * f ((i : Rat) * diH) + b * g ((i : Rat) * diH)) * diH =
          a * (f ((i : Rat) * diH) * diH) + b * (g ((i : Rat) * diH) * diH) from by ring]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]

/-! ## Sample-Point Bounds (needed for range-restricted integration) -/

/-- Every sample point `i · diH` used in `discreteIntegral f T` satisfies
    `i · diH < T` (strictly below the horizon).

    Proof: `i < diSteps T = ⌊T · 1000⌋₊ ≤ T · 1000`, so
    `i · diH = i / 1000 < T · 1000 / 1000 = T`. -/
theorem diSample_lt_T (T : Rat) (hT : 0 ≤ T) (i : Nat) (hi : i < diSteps T) :
    (i : Rat) * diH < T := by
  have h1 : (i : Rat) < (diSteps T : Rat) := by exact_mod_cast hi
  have h2 : (diSteps T : Rat) ≤ T * diN := by
    unfold diSteps
    exact Nat.floor_le (mul_nonneg hT (by norm_num [diN]))
  have h3 : (i : Rat) < T * diN := lt_of_lt_of_le h1 h2
  rw [show (i : Rat) * diH = (i : Rat) / (diN : Rat) from by unfold diH diN; push_cast; ring]
  rw [div_lt_iff₀ (by norm_num [diN])]
  linarith

/-- The total span of all steps `diSteps T · diH ≤ T` (steps never overshoot horizon).

    Proof: `diSteps T ≤ T · 1000` from `⌊·⌋₊ ≤ id`, then multiply by `diH = 1/1000`. -/
theorem diSteps_mul_diH_le_T (T : Rat) (hT : 0 ≤ T) :
    (diSteps T : Rat) * diH ≤ T := by
  have h1 : (diSteps T : Rat) ≤ T * diN := by
    unfold diSteps
    exact Nat.floor_le (mul_nonneg hT (by norm_num [diN]))
  calc (diSteps T : Rat) * diH
      ≤ T * diN * diH := mul_le_mul_of_nonneg_right h1 diH_nonneg
    _ = T             := by unfold diH diN; push_cast; ring

end NavierStokes.DiscreteKernel
