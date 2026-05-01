import CATEPTMain.Integration.GelfandYaglomJacobi
import CATEPTMain.Integration.GelfandYaglomDetRatio
import CATEPTMain.Integration.GelfandYaglomAsymptotics
import CATEPTMain.Integration.GelfandYaglomPartition
import CATEPTMain.Integration.GelfandYaglomPartitionPos
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.Ring

/-!
# Gel'fand–Yaglom Inversion API (T-FF Phase 7)

Phase-7 honest content: the algebraic inversion bridge between
`gyDetRatio` (Phase 3) and `gyPartRatio` (Phase 5) is a genuine
multiplicative pair on the physical regime `T > 0`. We expose:

* the symmetric cancellation identity (commuted form),
* the reverse inversion bridge `gyDetRatio = (gyPartRatio)⁻¹`,
* non-vanishing of `gyPartRatio` on `T > 0`.

Three honest theorems, each a kernel-only corollary of the
Phase-5/6 content, completing the ratio-pair API.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomInversionAPI

open CATEPTMain.Integration.GelfandYaglomJacobi
open CATEPTMain.Integration.GelfandYaglomDetRatio
open CATEPTMain.Integration.GelfandYaglomAsymptotics
open CATEPTMain.Integration.GelfandYaglomPartition
open CATEPTMain.Integration.GelfandYaglomPartitionPos

noncomputable section

/-- **Symmetric cancellation**: commuted form of Phase-5's
    `gyDetRatio_mul_partRatio_eq_one`, asserting the multiplicative
    pair on `T > 0` is genuinely symmetric. -/
theorem gyPartRatio_mul_gyDetRatio_eq_one (ω T : ℝ) (hT : 0 < T) :
    gyPartRatio ω T * gyDetRatio ω T = 1 := by
  rw [mul_comm]
  exact gyDetRatio_mul_partRatio_eq_one ω T hT

/-- **Reverse inversion bridge**: `gyDetRatio` equals the
    multiplicative inverse of `gyPartRatio` on `T > 0`. Companion
    to Phase-6's `gyPartRatio_eq_inv_gyDetRatio`, completing the
    bridge in both directions. -/
theorem gyDetRatio_eq_inv_gyPartRatio (ω T : ℝ) (hT : 0 < T) :
    gyDetRatio ω T = (gyPartRatio ω T)⁻¹ := by
  have hpart : gyPartRatio ω T ≠ 0 := ne_of_gt (gyPartRatio_pos ω T hT)
  have hcancel : gyPartRatio ω T * gyDetRatio ω T = 1 :=
    gyPartRatio_mul_gyDetRatio_eq_one ω T hT
  have h' : gyDetRatio ω T = 1 / gyPartRatio ω T := by
    rw [eq_div_iff hpart]
    linear_combination hcancel
  rw [h', one_div]

/-- **Non-vanishing of the partition ratio** on the physical
    regime `T > 0`, for every `ω`. Direct corollary of Phase-6
    strict positivity, packaged for downstream use. -/
theorem gyPartRatio_ne_zero (ω T : ℝ) (hT : 0 < T) :
    gyPartRatio ω T ≠ 0 :=
  ne_of_gt (gyPartRatio_pos ω T hT)

end

end CATEPTMain.Integration.GelfandYaglomInversionAPI
