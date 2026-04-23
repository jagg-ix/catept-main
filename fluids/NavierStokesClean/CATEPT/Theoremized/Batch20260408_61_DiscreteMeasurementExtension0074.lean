import NavierStokesClean.CATEPT.Theoremized.Batch20260408_54_DiscreteMeasurementSuperpositionVariant0070
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_31_PhysicalMeasurementProcess0011

/-!
# Batch 20260408 Theoremization - CATEPT Row 61 (Discrete Measurement Extension 0074)

Discrete measurement-extension wrappers anchored to the row-54 variant collapse
and row-31 constructive measurement closure.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B61

noncomputable section

open MeasureTheory
open NavierStokesClean.CATEPT

/-- Deterministic selector skeleton from two branch scores. -/
def row61_measurementSelector (w1 w2 : ℝ) : ℝ :=
  if w1 ≥ w2 then w1 else w2

/-- Selector returns the first branch when `w1 ≥ w2`. -/
theorem row61_selector_eq_left_of_ge (w1 w2 : ℝ) (h : w1 ≥ w2) :
    row61_measurementSelector w1 w2 = w1 := by
  unfold row61_measurementSelector
  simp [h]

/-- Selector returns the second branch when `w1 < w2`. -/
theorem row61_selector_eq_right_of_lt (w1 w2 : ℝ) (h : w1 < w2) :
    row61_measurementSelector w1 w2 = w2 := by
  unfold row61_measurementSelector
  simp [h, not_le_of_gt h]

/-- Variant collapse additivity reused from row 54. -/
theorem row61_variant_additivity
    (psi1 psi2 p : ℝ) (hp : 0 < p) :
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_collapseVariant psi1 p +
      NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_collapseVariant psi2 p =
        (psi1 ^ 2 + psi2 ^ 2) / p :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_variant_additivity psi1 psi2 p hp

/-- Constructive Kuchar closure implies positive measurement score. -/
theorem row61_measurement_problem_closed
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    0 < s.s6 :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.B31.row31_measurement_problem_closed s hs

/-- Combined row-61 discrete-measurement extension witness package. -/
theorem row61_discrete_measurement_extension_bundle
    (w1 w2 psi1 psi2 p : ℝ)
    (hp : 0 < p)
    (hSel : w1 ≥ w2)
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    row61_measurementSelector w1 w2 = w1 ∧
      NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_collapseVariant psi1 p +
        NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_collapseVariant psi2 p =
          (psi1 ^ 2 + psi2 ^ 2) / p ∧
      0 < s.s6 := by
  exact ⟨row61_selector_eq_left_of_ge w1 w2 hSel,
    row61_variant_additivity psi1 psi2 p hp,
    row61_measurement_problem_closed s hs⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B61

