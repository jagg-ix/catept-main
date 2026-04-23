import NavierStokesClean.CATEPT.Theoremized.Batch20260408_61_DiscreteMeasurementExtension0074
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_54_DiscreteMeasurementSuperpositionVariant0070

/-!
# Batch 20260408 Theoremization - CATEPT Row 66 (Discrete Energy Measurement Grid 0065)

Discrete grid/eigenstate-collapse wrappers aligned with row-61 selector and
row-54 collapse-variant contracts.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B66

noncomputable section

open NavierStokesClean.CATEPT

/-- Canonical grid size carried by the source implementation. -/
def row66_gridSize : Nat := 100

/-- Grid spacing skeleton for the normalized interval `[0, 1]`. -/
def row66_gridSpacing : ℝ := 1 / (row66_gridSize : ℝ)

/-- Collapse branch inherited from the row-54 variant stream. -/
def row66_branchCollapse (psi p : ℝ) : ℝ :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_collapseVariant psi p

/-- Measurement selector inherited from row 61. -/
def row66_selector (w1 w2 : ℝ) : ℝ :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.B61.row61_measurementSelector w1 w2

/-- Selector picks the left branch under `w1 ≥ w2`. -/
theorem row66_selector_eq_left_of_ge (w1 w2 : ℝ) (h : w1 ≥ w2) :
    row66_selector w1 w2 = w1 := by
  simpa [row66_selector] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.B61.row61_selector_eq_left_of_ge w1 w2 h

/-- Selector picks the right branch under `w1 < w2`. -/
theorem row66_selector_eq_right_of_lt (w1 w2 : ℝ) (h : w1 < w2) :
    row66_selector w1 w2 = w2 := by
  simpa [row66_selector] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.B61.row61_selector_eq_right_of_lt w1 w2 h

/-- Branch-collapse additivity inherited from row 54. -/
theorem row66_branchCollapse_additivity
    (psi1 psi2 p : ℝ) (hp : 0 < p) :
    row66_branchCollapse psi1 p + row66_branchCollapse psi2 p =
      (psi1 ^ 2 + psi2 ^ 2) / p := by
  simpa [row66_branchCollapse] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54.row54_variant_additivity psi1 psi2 p hp

/-- Constructive measurement closure inherited from row 61. -/
theorem row66_measurement_problem_closed
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    0 < s.s6 :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.B61.row61_measurement_problem_closed s hs

/-- Combined row-66 grid/collapse witness package. -/
theorem row66_discrete_energy_grid_bundle
    (w1 w2 psi1 psi2 p : ℝ)
    (hp : 0 < p)
    (hSel : w1 ≥ w2)
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    row66_gridSize = 100 ∧
      row66_selector w1 w2 = w1 ∧
      row66_branchCollapse psi1 p + row66_branchCollapse psi2 p =
        (psi1 ^ 2 + psi2 ^ 2) / p ∧
      0 < s.s6 := by
  exact ⟨rfl,
    row66_selector_eq_left_of_ge w1 w2 hSel,
    row66_branchCollapse_additivity psi1 psi2 p hp,
    row66_measurement_problem_closed s hs⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B66
