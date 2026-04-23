import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 224

Classical CHSH toy scaffold adapted from
`0101_1_._classicalchsh_toy.lean.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G224

noncomputable section

def chshExpr (E00 E01 E10 E11 : ℝ) : ℝ := E00 + E01 + E10 - E11

theorem abs_chsh_le_four
    (E00 E01 E10 E11 : ℝ)
    (h00 : |E00| ≤ 1) (h01 : |E01| ≤ 1)
    (h10 : |E10| ≤ 1) (h11 : |E11| ≤ 1) :
    |chshExpr E00 E01 E10 E11| ≤ 4 := by
  unfold chshExpr
  have hA : |E00 + E01| ≤ |E00| + |E01| := abs_add_le _ _
  have hB : |E10 - E11| ≤ |E10| + |E11| := by
    simpa [sub_eq_add_neg, abs_neg] using (abs_add_le E10 (-E11))
  have hMain : |(E00 + E01) + (E10 - E11)| ≤ |E00 + E01| + |E10 - E11| := by
    exact abs_add_le _ _
  have hBound : |(E00 + E01) + (E10 - E11)| ≤ (|E00| + |E01|) + (|E10| + |E11|) := by
    linarith
  have hFourAbs : (|E00| + |E01|) + (|E10| + |E11|) ≤ 4 := by
    linarith
  have hMain' : |E00 + E01 + E10 - E11| ≤ (|E00| + |E01|) + (|E10| + |E11|) := by
    have hEq : E00 + E01 + E10 - E11 = (E00 + E01) + (E10 - E11) := by ring
    calc
      |E00 + E01 + E10 - E11| = |(E00 + E01) + (E10 - E11)| := by simpa [hEq]
      _ ≤ (|E00| + |E01|) + (|E10| + |E11|) := hBound
  exact le_trans hMain' hFourAbs

theorem chshExpr_zero_zero_zero_zero : chshExpr 0 0 0 0 = 0 := by
  simp [chshExpr]

theorem chshExpr_all_one : chshExpr 1 1 1 1 = 2 := by
  norm_num [chshExpr]

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G224
