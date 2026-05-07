import CATEPTMain.Integration.GelfandYaglomJacobi
import CATEPTMain.Integration.GelfandYaglomDetRatio
import CATEPTMain.Integration.GelfandYaglomAsymptotics
import CATEPTMain.Integration.GelfandYaglomPartition
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.Ring

/-!
# Gel'fand–Yaglom Partition-Function Ratio: positivity & inversion (T-FF Phase 6)

Phase-6 honest content: on the physical regime `T > 0`, the
partition-function ratio `gyPartRatio` is strictly positive, equals
the free-particle baseline `1` at `ω = 0`, and is the multiplicative
inverse of the determinant ratio `gyDetRatio`. This complements
Phase-4 (which proved the analogous facts for `gyDetRatio`) and
Phase-5 (closed-form / parity / cancellation), bringing the
partition side of the GY ladder to Phase-4 parity.

Three honest theorems:

* `gyPartRatio_pos`                  — strict positivity on `T > 0`
* `gyPartRatio_baseline_omega_zero` — free baseline `= 1` at `ω = 0`
* `gyPartRatio_eq_inv_gyDetRatio`   — explicit inversion bridge
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomPartitionPos

open CATEPTMain.Integration.GelfandYaglomJacobi
open CATEPTMain.Integration.GelfandYaglomDetRatio
open CATEPTMain.Integration.GelfandYaglomAsymptotics
open CATEPTMain.Integration.GelfandYaglomPartition

noncomputable section

/-- **Strict positivity** of the partition ratio on `T > 0`, any `ω`.
    Reduces to `T > 0` divided by `ψ_ω(T) > 0` (Phase-4). -/
theorem gyPartRatio_pos (ω T : ℝ) (hT : 0 < T) :
    0 < gyPartRatio ω T := by
  unfold gyPartRatio
  exact div_pos hT (gyJacobi_pos ω T hT)

/-- **Free-particle baseline on `T > 0`**: at `ω = 0` the partition
    ratio is identically `1`. Specialisation of Phase-5's
    `gyPartRatio_omega_zero` with `T ≠ 0` derived from `T > 0`. -/
theorem gyPartRatio_baseline_omega_zero (T : ℝ) (hT : 0 < T) :
    gyPartRatio 0 T = 1 :=
  gyPartRatio_omega_zero T (ne_of_gt hT)

/-- **Inversion bridge**: on `T > 0`, the partition ratio is the
    multiplicative inverse of the determinant ratio,
        `gyPartRatio ω T = (gyDetRatio ω T)⁻¹`,
    obtained from the Phase-5 cancellation identity together with
    Phase-4 strict positivity (and hence non-vanishing) of
    `gyDetRatio`. -/
theorem gyPartRatio_eq_inv_gyDetRatio (ω T : ℝ) (hT : 0 < T) :
    gyPartRatio ω T = (gyDetRatio ω T)⁻¹ := by
  have hdet : gyDetRatio ω T ≠ 0 := ne_of_gt (gyDetRatio_pos ω T hT)
  have hcancel : gyDetRatio ω T * gyPartRatio ω T = 1 :=
    gyDetRatio_mul_partRatio_eq_one ω T hT
  have h' : gyPartRatio ω T = 1 / gyDetRatio ω T := by
    rw [eq_div_iff hdet]
    linear_combination hcancel
  rw [h', one_div]

end

end CATEPTMain.Integration.GelfandYaglomPartitionPos
