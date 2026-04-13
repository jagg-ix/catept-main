import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.NormNum

/-!
# CFL Clock + Entropic Reparameterization Bridge

Formalizes the core equations appearing in the external CFL/entropic-time notes:

- `dτ = λ dt`
- CFL invariance under time reparameterization
- roundtrip conversion between `dt` and `dτ`
- operational `dt` suggestion as `min(CFL bound, dissipation bound)`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

namespace CFLClock

noncomputable section

/-- CFL coordinate-time bound `dt ≤ cflMax * dx / aMax`. -/
def cflDtBound (dx aMax cflMax : ℝ) : ℝ :=
  cflMax * dx / aMax

/-- Dissipation stability bound `dt ≤ alphaScheme / lambdaMax`. -/
def dissipationDtBound (lambdaMax alphaScheme : ℝ) : ℝ :=
  alphaScheme / lambdaMax

/-- Entropic clock step from coordinate step: `dτ = λ dt`. -/
def dtauFromDt (dt lam : ℝ) : ℝ :=
  lam * dt

/-- Coordinate step recovered from entropic step: `dt = dτ / λ`. -/
def dtFromDtau (dtau lam : ℝ) : ℝ :=
  dtau / lam

/-- Operational clock profile matching the software-level API. -/
structure Clock where
  dx : ℝ
  cflMax : ℝ
  alphaScheme : ℝ

/-- Suggested coordinate step is the tighter of CFL and dissipation bounds. -/
def Clock.suggestDt (clk : Clock) (aMax lambdaMax : ℝ) : ℝ :=
  min (cflDtBound clk.dx aMax clk.cflMax)
      (dissipationDtBound lambdaMax clk.alphaScheme)

theorem dt_dtau_roundtrip (dt lam : ℝ) (hlam : lam ≠ 0) :
    dtFromDtau (dtauFromDt dt lam) lam = dt := by
  unfold dtFromDtau dtauFromDt
  field_simp [hlam]

theorem dtau_dt_roundtrip (dtau lam : ℝ) (hlam : lam ≠ 0) :
    dtauFromDt (dtFromDtau dtau lam) lam = dtau := by
  unfold dtFromDtau dtauFromDt
  field_simp [hlam]

/-- CFL condition in `t` is equivalent to the entropic-time form
`dτ ≤ λ * dx/a` when `λ > 0`. -/
theorem cfl_invariant_under_entropic_reparam
    (dt dx a lam : ℝ) (hlam : 0 < lam) :
    (dt ≤ dx / a) ↔ (dtauFromDt dt lam ≤ lam * (dx / a)) := by
  constructor
  · intro h
    simpa [dtauFromDt, mul_assoc] using
      (mul_le_mul_of_nonneg_left h (le_of_lt hlam))
  · intro h
    have h' : (lam * dt) / lam ≤ (lam * (dx / a)) / lam := by
      exact div_le_div_of_nonneg_right
        (by simpa [dtauFromDt, mul_assoc] using h)
        (le_of_lt hlam)
    simpa [hlam.ne', mul_assoc] using h'

/-- Same invariance written using an explicit relation `dτ = λ dt`. -/
theorem cfl_invariant_with_relation
    (dt dtau dx a lam : ℝ) (hlam : 0 < lam)
    (hrel : dtau = dtauFromDt dt lam) :
    (dt ≤ dx / a) ↔ (dtau ≤ lam * (dx / a)) := by
  rw [hrel]
  exact cfl_invariant_under_entropic_reparam dt dx a lam hlam

/-- Recover a coordinate-time CFL bound from entropic-step bound. -/
  theorem dt_bound_from_dtau_bound
    (dtau dx a lam : ℝ) (hlam : 0 < lam)
    (h : dtau ≤ lam * (dx / a)) :
    dtFromDtau dtau lam ≤ dx / a := by
  have h' : dtau / lam ≤ (lam * (dx / a)) / lam := by
    exact div_le_div_of_nonneg_right h (le_of_lt hlam)
  simpa [dtFromDtau, hlam.ne', mul_assoc] using h'

theorem suggestDt_le_cfl
    (clk : Clock) (aMax lambdaMax : ℝ) :
    clk.suggestDt aMax lambdaMax ≤ cflDtBound clk.dx aMax clk.cflMax := by
  unfold Clock.suggestDt
  exact min_le_left _ _

theorem suggestDt_le_dissipation
    (clk : Clock) (aMax lambdaMax : ℝ) :
    clk.suggestDt aMax lambdaMax ≤ dissipationDtBound lambdaMax clk.alphaScheme := by
  unfold Clock.suggestDt
  exact min_le_right _ _

/-! ## Concrete checks matching the Python tests -/

theorem cfl_dt_bound_basic :
    cflDtBound 0.1 2.0 1.0 = 0.05 := by norm_num [cflDtBound]

theorem dissipation_dt_bound_basic :
    dissipationDtBound 4.0 2.0 = 0.5 := by norm_num [dissipationDtBound]

theorem clock_suggests_min_bound_basic :
    (Clock.suggestDt { dx := 0.1, cflMax := 1.0, alphaScheme := 2.0 } 2.0 4.0) = 0.05 := by
  norm_num [Clock.suggestDt, cflDtBound, dissipationDtBound]

end

end CFLClock

end NavierStokesClean.CATEPT
