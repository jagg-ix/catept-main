import Mathlib.Analysis.Calculus.Deriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral

/-!
Entropic proper time (`τ_ent`) core lemmas.

We keep this conservative: τ_ent is defined as an integral of a nonnegative
rate λ(t) over coordinate time.

This corresponds to the repository contract used in Python artifacts:
  - `t_s`      : coordinate time samples
  - `tau_ent_s`: entropic proper time samples
  - `lambda_eff_s_inv`: 1/λ_eff(t)

The Python pipeline enforces the contract numerically; Lean aims to capture the
minimal symbolic invariants (monotonicity, change-of-variables safety).
-/

namespace CatsimLean

open scoped BigOperators

variable (λ : ℝ → ℝ)

def tauEnt (t0 t1 : ℝ) : ℝ :=
  ∫ x in Set.Icc t0 t1, λ x

theorem tauEnt_eq_zero_of_eq (t : ℝ) : tauEnt λ t t = 0 := by
  simp [tauEnt]

theorem tauEnt_nonneg (hλ : ∀ t, 0 ≤ λ t) (t0 t1 : ℝ) : 0 ≤ tauEnt λ t0 t1 := by
  simp [tauEnt, hλ]

theorem tauEnt_monotone_right
    (hλ : ∀ t, 0 ≤ λ t) (t0 : ℝ)
    (hInt : ∀ t1, IntegrableOn λ (Set.Icc t0 t1)) :
    Monotone (fun t1 => tauEnt λ t0 t1) := by
  intro a b hab
  have hsubset : Set.Icc t0 a ⊆ Set.Icc t0 b := by
    intro x hx
    exact ⟨hx.1, le_trans hx.2 hab⟩
  have h_nonneg : 0 ≤ᵐ[volume.restrict (Set.Icc t0 b)] λ := by
    exact Filter.Eventually.of_forall hλ
  have hst : Set.Icc t0 a ≤ᵐ[volume] Set.Icc t0 b := by
    exact Filter.Eventually.of_forall hsubset
  simpa [tauEnt] using
    (MeasureTheory.setIntegral_mono_set
      (f := λ) (μ := volume)
      (s := Set.Icc t0 a) (t := Set.Icc t0 b)
      (hfi := hInt b) h_nonneg hst)

end CatsimLean
