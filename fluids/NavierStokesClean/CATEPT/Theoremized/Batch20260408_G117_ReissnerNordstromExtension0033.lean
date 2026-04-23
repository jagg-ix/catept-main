import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 117

Reissner-Nordstrom extension scaffold for charged black-hole lapse.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G117

structure rowG117Input where
  mass : ℝ
  charge : ℝ
  radius : ℝ

/-- Schwarzschild baseline lapse `1 - 2M/r`. -/
noncomputable def rowG117SchwarzschildPart (x : rowG117Input) : ℝ :=
  1 - (2 * x.mass) / x.radius

/-- Charged correction term `Q^2/r^2`. -/
noncomputable def rowG117ChargeCorrection (x : rowG117Input) : ℝ :=
  x.charge ^ 2 / x.radius ^ 2

/-- RN lapse `1 - 2M/r + Q^2/r^2`. -/
noncomputable def rowG117RNLapse (x : rowG117Input) : ℝ :=
  rowG117SchwarzschildPart x + rowG117ChargeCorrection x

/-- Charge correction is nonnegative for positive radius. -/
theorem rowG117_chargeCorrection_nonneg
    (x : rowG117Input)
    (hr : 0 < x.radius) :
    0 ≤ rowG117ChargeCorrection x := by
  unfold rowG117ChargeCorrection
  have hr2 : 0 ≤ x.radius ^ 2 := by positivity
  exact div_nonneg (by positivity) hr2

/-- RN lapse is always at least the Schwarzschild baseline. -/
theorem rowG117_lapse_ge_schwarzschild
    (x : rowG117Input)
    (hr : 0 < x.radius) :
    rowG117SchwarzschildPart x ≤ rowG117RNLapse x := by
  unfold rowG117RNLapse
  nlinarith [rowG117_chargeCorrection_nonneg x hr]

/-- If `2M ≤ r`, Schwarzschild baseline is nonnegative. -/
theorem rowG117_schwarzschild_nonneg
    (x : rowG117Input)
    (hr : 0 < x.radius)
    (hm : 2 * x.mass ≤ x.radius) :
    0 ≤ rowG117SchwarzschildPart x := by
  unfold rowG117SchwarzschildPart
  have hdiv : (2 * x.mass) / x.radius ≤ 1 := by
    exact (div_le_iff₀ hr).2 (by simpa [one_mul] using hm)
  linarith

/-- Bundle theorem for row-117 RN extension layer. -/
theorem rowG117_bundle
    (x : rowG117Input)
    (hr : 0 < x.radius)
    (hm : 2 * x.mass ≤ x.radius) :
    0 ≤ rowG117ChargeCorrection x ∧
      rowG117SchwarzschildPart x ≤ rowG117RNLapse x ∧
      0 ≤ rowG117SchwarzschildPart x := by
  exact ⟨
    rowG117_chargeCorrection_nonneg x hr,
    rowG117_lapse_ge_schwarzschild x hr,
    rowG117_schwarzschild_nonneg x hr hm
  ⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G117

