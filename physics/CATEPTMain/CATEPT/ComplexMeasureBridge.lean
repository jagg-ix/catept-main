import CATEPTMain.CATEPT.MeasurePathIntegral
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.VectorMeasure.Basic

set_option autoImplicit false

open MeasureTheory Complex Real Function Classical

namespace CATEPTMain.CATEPT

noncomputable section

/-- CAT/EPT partition function `Z0 = ∫ exp(-S_I/hbar) dmu`. -/
def partitionFunction
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) : ℝ :=
  ∫ x, m.damping x ∂m.mu

/-- `Z0` is nonnegative. -/
theorem partitionFunction_nonneg
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha) :
    0 <= partitionFunction m :=
  integral_nonneg (fun x => (m.damping_pos x).le)

/-- If damping is integrable, the full complex weight is integrable. -/
theorem weight_integrable_of_damping_integrable
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu) :
    Integrable m.weight m.mu := by
  rw [<- integrable_norm_iff m.measurable_weight.aestronglyMeasurable]
  simp_rw [m.weight_norm_is_damping]
  exact hL1

/-- Weight is integrable on every set when damping is integrable. -/
theorem weight_integrableOn_of_damping_integrable
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (s : Set alpha) :
    IntegrableOn m.weight s m.mu :=
  (weight_integrable_of_damping_integrable m hL1).integrableOn

/-- Countable additivity for set integrals of the CAT/EPT weight. -/
theorem integral_weight_hasSum
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (s : ℕ -> Set alpha)
    (hs : ∀ i, MeasurableSet (s i))
    (hd : Pairwise (Disjoint on s)) :
    HasSum (fun n => ∫ x in s n, m.weight x ∂m.mu)
      (∫ x in ⋃ n, s n, m.weight x ∂m.mu) :=
  hasSum_integral_iUnion hs hd
    (weight_integrableOn_of_damping_integrable m hL1 _)

/-- Norm bound for set integrals of the CAT/EPT weight. -/
theorem setIntegral_weight_norm_le_damping
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
  (_hL1 : Integrable (fun x => m.damping x) m.mu)
    (s : Set alpha) :
    ‖∫ x in s, m.weight x ∂m.mu‖ <= ∫ x in s, m.damping x ∂m.mu := by
  calc
    ‖∫ x in s, m.weight x ∂m.mu‖
        <= ∫ x in s, ‖m.weight x‖ ∂m.mu := norm_integral_le_integral_norm _
    _ = ∫ x in s, m.damping x ∂m.mu := by
      congr 1
      ext x
      exact m.weight_norm_is_damping x

/-- CAT/EPT complex measure defined by set integration of the weight. -/
def catept_complex_measure
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu) :
    VectorMeasure alpha ℂ where
  measureOf' s :=
    if MeasurableSet s then ∫ x in s, m.weight x ∂m.mu else 0
  empty' := by simp [MeasurableSet.empty]
  not_measurable' s hs := by simp [hs]
  m_iUnion' := fun s hs hd => by
    rw [if_pos (MeasurableSet.iUnion hs)]
    simp only [if_pos (hs _)]
    exact integral_weight_hasSum m hL1 s hs hd

/-- On measurable sets, the complex measure is the corresponding set integral. -/
theorem catept_complex_measure_apply
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (s : Set alpha) (hs : MeasurableSet s) :
    catept_complex_measure m hL1 s = ∫ x in s, m.weight x ∂m.mu := by
  simp [catept_complex_measure, hs]

/-- Total-variation style bound by the partition function. -/
theorem catept_complex_measure_norm_le
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    (hL1 : Integrable (fun x => m.damping x) m.mu)
    (s : Set alpha) (hs : MeasurableSet s) :
    ‖catept_complex_measure m hL1 s‖ <= partitionFunction m := by
  rw [catept_complex_measure_apply m hL1 s hs]
  calc
    ‖∫ x in s, m.weight x ∂m.mu‖
        <= ∫ x in s, m.damping x ∂m.mu :=
          setIntegral_weight_norm_le_damping m hL1 s
    _ <= ∫ x, m.damping x ∂m.mu := by
      apply setIntegral_le_integral hL1
      exact Filter.Eventually.of_forall (fun x => (m.damping_pos x).le)
    _ = partitionFunction m := rfl

/-- Finite reference measure implies damping integrability automatically. -/
theorem catept_measure_exists_from_finite_reference
    {alpha : Type*} [MeasurableSpace alpha]
    (m : MeasurePathIntegralModel alpha)
    [IsFiniteMeasure m.mu] :
    Integrable (fun x => m.damping x) m.mu := by
  apply Integrable.mono' (integrable_const 1)
  · exact m.measurable_damping.aestronglyMeasurable
  · exact Filter.Eventually.of_forall (fun x => by
      simp only [Real.norm_of_nonneg (m.damping_pos x).le]
      exact m.damping_le_one x)

end
