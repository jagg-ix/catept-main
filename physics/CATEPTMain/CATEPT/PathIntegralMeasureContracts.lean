import Mathlib.Analysis.Complex.Basic
import CATEPTMain.CATEPT.MeasurePathIntegral

set_option autoImplicit false

namespace CATEPTMain.CATEPT

noncomputable section

/-- Core exponent form for CAT/EPT path-integral weights. -/
def weightExponent
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) (x : alpha) : Complex :=
  (-(m.actionImScaled x) : Complex) +
    ((m.actionReScaled x : Complex) * Complex.I)

/-- Imaginary-action scaling is nonnegative under the model assumptions. -/
theorem actionImScaled_nonneg
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) (x : alpha) :
    0 <= m.actionImScaled x := by
  unfold MeasurePathIntegralModel.actionImScaled
  exact div_nonneg (m.actionIm_nonneg x) m.hbar_pos.le

/-- Real part of the weight exponent is always nonpositive. -/
theorem weightExponent_re_nonpos
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) (x : alpha) :
    (weightExponent m x).re <= 0 := by
  unfold weightExponent
  simp [Complex.add_re, Complex.mul_re, Complex.I_re, Complex.I_im]
  have hs : 0 <= m.actionImScaled x := actionImScaled_nonneg m x
  linarith

/-- Pointwise contract bundle for CAT/EPT path-integral well-posedness. -/
def pathIntegralPointwiseContract
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) (x : alpha) : Prop :=
  0 <= m.actionImScaled x ∧
    0 < m.damping x ∧
    m.damping x <= 1 ∧
    ‖m.weight x‖ <= 1 ∧
    (weightExponent m x).re <= 0

/-- Pointwise contract is certified by the base measure-path-integral model. -/
theorem pathIntegralPointwiseContract_of_model
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) (x : alpha) :
    pathIntegralPointwiseContract m x := by
  refine ⟨actionImScaled_nonneg m x, m.damping_pos x, m.damping_le_one x,
    m.weight_bochner_bounded x, weightExponent_re_nonpos m x⟩

/-- Global measurability contract used by integration-facing bridge lanes. -/
def pathIntegralMeasurabilityContract
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) : Prop :=
  Measurable m.weight ∧ Measurable m.damping

/-- Measurability contract is certified by the base model. -/
theorem pathIntegralMeasurabilityContract_of_model
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) :
    pathIntegralMeasurabilityContract m :=
  ⟨m.measurable_weight, m.measurable_damping⟩

/-- Euclidean reduction used in FK-compatible bridge lanes. -/
theorem pathIntegralEuclideanReduction
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hRe : ∀ x, m.actionRe x = 0) (x : alpha) :
    m.weight x = (m.damping x : Complex) :=
  m.weight_eq_damping_of_actionRe_zero hRe x

/-- Lightweight compatibility witness for path-integral bridge assertions. -/
structure PathIntegralCompatibilityWitness where
  pointwiseBoundsAvailable : Prop
  measurabilityAvailable : Prop
  euclideanReductionAvailable : Prop

/-- Composite contract surface for path-integral bridge compatibility. -/
def pathIntegralCompatibilityContract
    (w : PathIntegralCompatibilityWitness) : Prop :=
  w.pointwiseBoundsAvailable ∧
    w.measurabilityAvailable ∧
    w.euclideanReductionAvailable

theorem pathIntegralCompatibility_contract_of_fields
    (w : PathIntegralCompatibilityWitness)
    (h1 : w.pointwiseBoundsAvailable)
    (h2 : w.measurabilityAvailable)
    (h3 : w.euclideanReductionAvailable) :
    pathIntegralCompatibilityContract w :=
  ⟨h1, h2, h3⟩

end

end CATEPTMain.CATEPT
