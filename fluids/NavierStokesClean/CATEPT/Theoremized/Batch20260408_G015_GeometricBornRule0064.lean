import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 015

Geometric Born-rule scaffold in a compile-safe probabilistic form.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G015

structure rowG015GeometricState where
  amplitude : ℂ
  metricWeight : ℝ

/-- Geometric Born weight from amplitude norm squared and metric weight. -/
def rowG015BornWeight (s : rowG015GeometricState) : ℝ :=
  s.metricWeight * Complex.normSq s.amplitude

/-- A state is admissible if the metric weight is nonnegative. -/
def rowG015Admissible (s : rowG015GeometricState) : Prop :=
  0 ≤ s.metricWeight

/-- Born weight is nonnegative for admissible states. -/
theorem rowG015_bornWeight_nonneg
    (s : rowG015GeometricState) (hs : rowG015Admissible s) :
    0 ≤ rowG015BornWeight s := by
  unfold rowG015BornWeight rowG015Admissible at *
  nlinarith [Complex.normSq_nonneg s.amplitude]

/-- If `metricWeight ≤ 1`, Born weight is bounded by amplitude norm square. -/
theorem rowG015_bornWeight_le_normSq
    (s : rowG015GeometricState)
    (h1 : s.metricWeight ≤ 1) :
    rowG015BornWeight s ≤ Complex.normSq s.amplitude := by
  unfold rowG015BornWeight
  nlinarith [Complex.normSq_nonneg s.amplitude]

/-- Bundle theorem for geometric Born-rule layer. -/
theorem rowG015_bundle
    (s : rowG015GeometricState)
    (h0 : 0 ≤ s.metricWeight)
    (h1 : s.metricWeight ≤ 1) :
    0 ≤ rowG015BornWeight s ∧
      rowG015BornWeight s ≤ Complex.normSq s.amplitude := by
  exact ⟨
    rowG015_bornWeight_nonneg s h0,
    rowG015_bornWeight_le_normSq s h1
  ⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G015
