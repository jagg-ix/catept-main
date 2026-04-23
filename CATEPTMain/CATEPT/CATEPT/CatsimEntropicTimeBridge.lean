import CATEPTMain.CATEPT.CATEPT.Foundations
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic

set_option autoImplicit false

/-!
# Catsim Integral Form of Entropic Proper Time

## Purpose

The CAT/EPT paper's operational definition of entropic proper time is

  τ_ent(t) = ∫₀ᵗ λ(s) ds,    λ ≥ 0

This is the rate-integral form used in the Python simulator
(`cat_ept_doubleslit.clock.entropic_clock`) and in the auxiliary
Lean project `catsim/lean/CatsimLean/EntropicTime.lean`.

The existing `CATEPT.entropic_time ℏ S_I = S_I / ℏ` is the **algebraic**
form: when λ(t) ≡ S_I/ℏ is constant, the integral collapses to
(S_I/ℏ) · Δt — giving the same physical quantity.

This module adds the integral form to catept-core and proves the
equivalence so downstream lemmas can use whichever is convenient.

## References

- `catsim/lean/CatsimLean/EntropicTime.lean` (external sub-project)
- `cat_ept_doubleslit/clock/entropic_clock.py::EntropicClock`

## Key results

1. Integral form τ_ent is zero on degenerate interval (t=t)
2. Integral form is non-negative when λ ≥ 0 on a forward interval
3. Constant-rate integral equals rate × duration
4. Equivalence to algebraic form when λ = S_I/ℏ is constant
-/

noncomputable section

namespace CATEPTMain.CATEPT.CATEPT

open MeasureTheory

/-- Catsim-style operational entropic proper time:
    τ_ent(t0, t1) = ∫ λ(s) ds on [t0, t1]. -/
def entropic_time_integral (rate : ℝ → ℝ) (t0 t1 : ℝ) : ℝ :=
  ∫ x in t0..t1, rate x

/-- Degenerate interval gives zero. -/
theorem entropic_time_integral_same (rate : ℝ → ℝ) (t : ℝ) :
    entropic_time_integral rate t t = 0 := by
  unfold entropic_time_integral
  exact intervalIntegral.integral_same

/-- Non-negativity for forward intervals with non-negative rate. -/
theorem entropic_time_integral_nonneg
    (rate : ℝ → ℝ) (t0 t1 : ℝ)
    (hrate : ∀ t, 0 ≤ rate t) (hle : t0 ≤ t1) :
    0 ≤ entropic_time_integral rate t0 t1 := by
  unfold entropic_time_integral
  exact intervalIntegral.integral_nonneg hle (fun x _ => hrate x)

/-- Constant-rate case: λ ≡ c on [t0, t1] gives c · (t1 - t0). -/
theorem entropic_time_integral_const (c t0 t1 : ℝ) :
    entropic_time_integral (fun _ => c) t0 t1 = c * (t1 - t0) := by
  unfold entropic_time_integral
  simp [intervalIntegral.integral_const, mul_comm]

/-- Bridge to the algebraic form: when the rate is the constant S_I/ℏ
    over duration Δt, the integral τ_ent equals the algebraic τ_ent × Δt.
    This is the unification of the two CAT/EPT entropic-time definitions. -/
theorem entropic_time_integral_eq_algebraic
    (S_I ℏ duration : ℝ) :
    entropic_time_integral (fun _ => S_I / ℏ) 0 duration =
      entropic_time ℏ S_I * duration := by
  rw [entropic_time_integral_const]
  unfold entropic_time
  rw [sub_zero]

/-- Special case: at t=0, the integral form coincides with the algebraic
    form evaluated over unit duration. -/
theorem entropic_time_integral_unit_duration
    (S_I ℏ : ℝ) :
    entropic_time_integral (fun _ => S_I / ℏ) 0 1 =
      entropic_time ℏ S_I := by
  rw [entropic_time_integral_eq_algebraic, mul_one]

end CATEPTMain.CATEPT.CATEPT
