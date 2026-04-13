import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 126

Numeric-layer evaluation scaffold with absolute-error contracts.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G126

structure rowG126Eval where
  predicted : ℝ
  observed : ℝ
  tolerance : ℝ

/-- Absolute evaluation error. -/
def rowG126AbsError (e : rowG126Eval) : ℝ :=
  |e.predicted - e.observed|

/-- Pass/fail predicate against tolerance. -/
def rowG126Passes (e : rowG126Eval) : Prop :=
  rowG126AbsError e ≤ e.tolerance

/-- Absolute error is always nonnegative. -/
theorem rowG126_absError_nonneg (e : rowG126Eval) :
    0 ≤ rowG126AbsError e := by
  unfold rowG126AbsError
  exact abs_nonneg _

/-- If tolerance increases, any previously passing evaluation still passes. -/
theorem rowG126_passes_monotone_tolerance
    (p o t1 t2 : ℝ)
    (ht : t1 ≤ t2)
    (hpass : rowG126Passes { predicted := p, observed := o, tolerance := t1 }) :
    rowG126Passes { predicted := p, observed := o, tolerance := t2 } := by
  unfold rowG126Passes at *
  exact le_trans hpass ht

/-- Bundle theorem for row-126 numeric-layer evaluations. -/
theorem rowG126_bundle
    (e : rowG126Eval)
    (hpass : rowG126Passes e)
    (ht : e.tolerance ≤ e.tolerance + 1) :
    0 ≤ rowG126AbsError e ∧
      rowG126Passes { e with tolerance := e.tolerance + 1 } := by
  have hmono :
      rowG126Passes { predicted := e.predicted, observed := e.observed, tolerance := e.tolerance + 1 } :=
    rowG126_passes_monotone_tolerance e.predicted e.observed e.tolerance (e.tolerance + 1) ht hpass
  exact ⟨rowG126_absError_nonneg e, hmono⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G126

