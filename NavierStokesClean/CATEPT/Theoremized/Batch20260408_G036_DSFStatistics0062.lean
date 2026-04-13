import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 036

DSF statistics scaffold with mean/variance-style invariants.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G036

structure rowG036Stats where
  mean : ℝ
  secondMoment : ℝ

/-- Variance proxy: `E[X²] - (E[X])²`. -/
def rowG036Variance (s : rowG036Stats) : ℝ :=
  s.secondMoment - s.mean ^ 2

/-- Shift of mean by constant `c` (second moment unchanged in this simple model). -/
def rowG036ShiftMean (c : ℝ) (s : rowG036Stats) : rowG036Stats :=
  { s with mean := s.mean + c }

/-- Variance is nonnegative whenever second moment dominates mean square. -/
theorem rowG036_variance_nonneg
    (s : rowG036Stats)
    (hdom : s.mean ^ 2 ≤ s.secondMoment) :
    0 ≤ rowG036Variance s := by
  unfold rowG036Variance
  linarith

/-- Zero shift preserves mean if and only if mean is unchanged (sanity check). -/
theorem rowG036_zero_shift (s : rowG036Stats) :
    rowG036ShiftMean 0 s = s := by
  cases s with
  | mk mean secondMoment =>
      unfold rowG036ShiftMean
      simp

/-- Bundle theorem for row-036 DSF statistics layer. -/
theorem rowG036_bundle
    (s : rowG036Stats)
    (hdom : s.mean ^ 2 ≤ s.secondMoment) :
    0 ≤ rowG036Variance s ∧ rowG036ShiftMean 0 s = s := by
  exact ⟨
    rowG036_variance_nonneg s hdom,
    rowG036_zero_shift s
  ⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G036
