import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.MeasureTheory.Function.SpecialFunctions.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic

set_option autoImplicit false

open MeasureTheory Complex Real

namespace CATEPTMain.CATEPT

noncomputable section

/-- Measurable CAT/EPT path-integral model on state space `alpha`. -/
structure MeasurePathIntegralModel (alpha : Type*) [MeasurableSpace alpha] where
  mu : Measure alpha
  hbar : ℝ
  hbar_pos : 0 < hbar
  actionRe : alpha -> ℝ
  actionIm : alpha -> ℝ
  measurable_actionRe : Measurable actionRe
  measurable_actionIm : Measurable actionIm
  actionIm_nonneg : ∀ x, 0 <= actionIm x

namespace MeasurePathIntegralModel

variable {alpha : Type*} [MeasurableSpace alpha] (m : MeasurePathIntegralModel alpha)

/-- Scaled real action `S_R / hbar`. -/
def actionReScaled (x : alpha) : ℝ := m.actionRe x / m.hbar

/-- Scaled imaginary action `S_I / hbar`. -/
def actionImScaled (x : alpha) : ℝ := m.actionIm x / m.hbar

/-- Oscillatory phase factor `exp(i*S_R/hbar)`. -/
def phase (x : alpha) : ℂ :=
  Complex.exp ((m.actionReScaled x : ℂ) * Complex.I)

/-- Damping factor `exp(-S_I/hbar)`. -/
def damping (x : alpha) : ℝ :=
  Real.exp (-(m.actionImScaled x))

/-- Full CAT/EPT weight `exp(i*S_R/hbar - S_I/hbar)`. -/
def weight (x : alpha) : ℂ :=
  Complex.exp
    ((-(m.actionImScaled x) : ℂ) +
      ((m.actionReScaled x : ℂ) * Complex.I))

/-- Weight factorization into phase and damping. -/
theorem weight_factorizes (x : alpha) :
    m.weight x =
      Complex.exp ((m.actionReScaled x : ℂ) * Complex.I) *
      (Real.exp (-(m.actionImScaled x)) : ℂ) := by
  unfold weight
  rw [show (Real.exp (-(m.actionImScaled x)) : ℂ) =
      Complex.exp (-(m.actionImScaled x : ℂ)) from by
    simp [Complex.ofReal_exp, Complex.ofReal_neg]]
  rw [<- Complex.exp_add]
  congr 1
  ring

/-- The oscillatory phase has unit norm. -/
theorem phase_norm_one (x : alpha) :
    ‖m.phase x‖ = 1 := by
  unfold phase
  rw [Complex.norm_exp_ofReal_mul_I]

/-- The norm of the CAT/EPT weight is exactly the damping profile. -/
theorem weight_norm_is_damping (x : alpha) :
    ‖m.weight x‖ = Real.exp (-(m.actionImScaled x)) := by
  rw [m.weight_factorizes]
  rw [norm_mul]
  have hphase : ‖Complex.exp ((m.actionReScaled x : ℂ) * Complex.I)‖ = 1 :=
    Complex.norm_exp_ofReal_mul_I _
  rw [hphase, one_mul]
  rw [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]

/-- Damping is strictly positive. -/
theorem damping_pos (x : alpha) : 0 < m.damping x := by
  unfold damping
  exact Real.exp_pos _

/-- Damping is at most one due to nonnegative imaginary action. -/
theorem damping_le_one (x : alpha) : m.damping x <= 1 := by
  unfold damping actionImScaled
  rw [Real.exp_le_one_iff]
  linarith [div_nonneg (m.actionIm_nonneg x) m.hbar_pos.le]

/-- Weight norm is globally bounded by one. -/
theorem weight_bochner_bounded (x : alpha) : ‖m.weight x‖ <= 1 := by
  rw [m.weight_norm_is_damping]
  exact m.damping_le_one x

/-- The CAT/EPT weight is measurable. -/
theorem measurable_weight : Measurable m.weight := by
  unfold weight
  apply Complex.measurable_exp.comp
  apply Measurable.add
  · exact (Complex.measurable_ofReal.comp
      (m.measurable_actionIm.div_const m.hbar)).neg
  · exact (Complex.measurable_ofReal.comp
      (m.measurable_actionRe.div_const m.hbar)).mul_const Complex.I

/-- The scaled imaginary action is measurable. -/
theorem measurable_actionImScaled : Measurable m.actionImScaled :=
  m.measurable_actionIm.div_const m.hbar

/-- The damping profile is measurable. -/
theorem measurable_damping : Measurable m.damping :=
  Real.measurable_exp.comp m.measurable_actionImScaled.neg

/-- In the Euclidean sector (`S_R = 0`), weight is purely real damping. -/
theorem weight_eq_damping_of_actionRe_zero
    (hRe : ∀ x, m.actionRe x = 0) (x : alpha) :
    m.weight x = (m.damping x : ℂ) := by
  rw [m.weight_factorizes]
  have hscaled : m.actionReScaled x = 0 := by
    unfold actionReScaled
    simp [hRe x]
  simp [hscaled, damping]

end MeasurePathIntegralModel

end
