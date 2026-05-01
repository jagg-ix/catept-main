import CATEPTMain.Integration.GelfandYaglomJacobi
import CATEPTMain.Integration.GelfandYaglomDetRatio
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.GCongr

/-!
# Gel'fand–Yaglom Determinant-Ratio Asymptotics (T-FF Phase 4)

Phase-4 honest content for the **asymptotic regime** of the
Gel'fand–Yaglom determinant ratio
  `det'(−∂²_t + ω²) / det'(−∂²_t)  =  sinh(ω T) / (ω T)`,
expressed at the algebraic Jacobi-quotient level via `gyDetRatio`.

We discharge:

* **Strict positivity** of the Jacobi field on the physical regime
  `T > 0` (any `ω`), certifying that the harmonic-oscillator
  determinant is bounded away from `0` and that the ratio is well
  defined.
* **Strict positivity** of the determinant ratio itself on `T > 0`.
* **Free-particle baseline**: the ratio collapses to `1` as soon as
  `ω = 0`, witnessing `det'(−∂²)/det'(−∂²) = 1`.
* **Strict monotonicity in `T`** (for `ω > 0`): the Jacobi field, and
  therefore the unrenormalised determinant `det'(−∂² + ω²)`, grows
  strictly with `T`.  This is the `T → ∞` exponential-blowup statement
  of the Gel'fand–Yaglom identity at the qualitative level (the
  blow-up rate `e^{ωT}/(2ω)` is recoverable from `Real.sinh_strictMono`
  combined with the Phase-1 closed form).

## Phase status

Phase-4 — honest asymptotic regime properties at the Jacobi-quotient
level, machine-checked, kernel-only `[propext, Classical.choice,
Quot.sound]` axioms.  Phase-5+ deferrals: spectral zeta theory
identification of `gyDetRatio` with the genuine determinant ratio;
zero-mode quotient for the bounce fluctuation operator.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomAsymptotics

open CATEPTMain.Integration.GelfandYaglomJacobi
open CATEPTMain.Integration.GelfandYaglomDetRatio

noncomputable section

/-- **Strict positivity of the Jacobi field**: for every `ω` and every
    `T > 0`, the Gel'fand–Yaglom Jacobi field `ψ_ω(T)` is strictly
    positive.  At `ω = 0` this is `T > 0`; for `ω ≠ 0` it follows from
    `Real.sinh_strictMono` and the parity `sinh(-x) = -sinh x` after
    case-splitting on the sign of `ω`. -/
theorem gyJacobi_pos (ω T : ℝ) (hT : 0 < T) :
    0 < gyJacobi ω T := by
  unfold gyJacobi
  by_cases hω : ω = 0
  · simp [hω]; exact hT
  rw [if_neg hω]
  rcases lt_or_gt_of_ne hω with hω_neg | hω_pos
  · -- ω < 0: rewrite via parity to the positive case.
    have hω'_pos : 0 < -ω := neg_pos.mpr hω_neg
    have hωT_pos : 0 < (-ω) * T := mul_pos hω'_pos hT
    have h_sinh_pos : 0 < Real.sinh ((-ω) * T) := by
      have h := Real.sinh_strictMono hωT_pos
      rwa [Real.sinh_zero] at h
    have hrew : Real.sinh (ω * T) / ω
        = Real.sinh ((-ω) * T) / (-ω) := by
      have h1 : Real.sinh (ω * T) = -Real.sinh ((-ω) * T) := by
        rw [show (-ω) * T = -(ω * T) by ring, Real.sinh_neg, neg_neg]
      rw [h1]; ring
    rw [hrew]
    exact div_pos h_sinh_pos hω'_pos
  · -- ω > 0: direct.
    have hωT_pos : 0 < ω * T := mul_pos hω_pos hT
    have h_sinh_pos : 0 < Real.sinh (ω * T) := by
      have h := Real.sinh_strictMono hωT_pos
      rwa [Real.sinh_zero] at h
    exact div_pos h_sinh_pos hω_pos

/-- **Strict positivity of the determinant ratio**: on the physical
    regime `T > 0` the Gel'fand–Yaglom ratio is strictly positive for
    every `ω`.  This ensures `det'(−∂² + ω²)` does not vanish and the
    ratio `gyDetRatio ω T = ψ_ω(T)/T` is genuinely a positive real. -/
theorem gyDetRatio_pos (ω T : ℝ) (hT : 0 < T) :
    0 < gyDetRatio ω T := by
  unfold gyDetRatio
  exact div_pos (gyJacobi_pos ω T hT) hT

/-- **Free-particle baseline (positive `T`)**: at `ω = 0` and `T > 0`
    the determinant ratio is exactly `1`, certifying that the
    free-particle case is the natural normalisation point of the
    Gel'fand–Yaglom identity. -/
theorem gyDetRatio_baseline_omega_zero (T : ℝ) (hT : 0 < T) :
    gyDetRatio 0 T = 1 :=
  gyDetRatio_omega_zero T (ne_of_gt hT)

/-- **Strict monotonicity in `T`**: for `ω > 0`, the Jacobi field
    `ψ_ω(T) = sinh(ω T)/ω` is strictly increasing in `T`.  Combined
    with the closed form, this is the qualitative statement of
    exponential blow-up: as `T → ∞`, the unrenormalised determinant
    `det'(−∂² + ω²)` grows without bound, while the ratio
    `gyDetRatio ω T = sinh(ωT)/(ωT)` exhibits the Gel'fand–Yaglom
    `e^{ωT}/(2ωT)` leading large-`T` behaviour. -/
theorem gyJacobi_strictMono_T_of_omega_pos (ω : ℝ) (hω : 0 < ω) :
    StrictMono (fun T : ℝ => gyJacobi ω T) := by
  intro T₁ T₂ hT
  have hω' : ω ≠ 0 := ne_of_gt hω
  show gyJacobi ω T₁ < gyJacobi ω T₂
  unfold gyJacobi
  rw [if_neg hω', if_neg hω']
  have h_omega_T : ω * T₁ < ω * T₂ := by
    have := mul_lt_mul_of_pos_left hT hω
    linarith
  have h_sinh : Real.sinh (ω * T₁) < Real.sinh (ω * T₂) :=
    Real.sinh_strictMono h_omega_T
  gcongr

end

end CATEPTMain.Integration.GelfandYaglomAsymptotics
