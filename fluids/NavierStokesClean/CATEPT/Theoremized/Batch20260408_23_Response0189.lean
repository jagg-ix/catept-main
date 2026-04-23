import NavierStokesClean.CATEPT.MeasurePathIntegral

/-!
# Batch 20260408 Theoremization - CATEPT Row 23 (Response 0189)

Expectation/normalization theorem wrappers for next-tranche row `#23`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B23

noncomputable section

open MeasureTheory
open NavierStokesClean.CATEPT

/-- Zero-source coupling recovers base normalized expectation. -/
theorem row23_zero_source_expectation
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (O : α → ℂ) :
    m.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = m.normalizedExpectation O :=
  m.sourceCoupledExpectation_zero O

/-- Normalized expectation recovers unnormalized expectation by multiplication with `Z`. -/
theorem row23_normalized_mul_partition
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (O : α → ℂ)
    (hZ : m.partition ≠ 0) :
    m.normalizedExpectation O * m.partition = m.unnormalizedExpectation O :=
  m.normalizedExpectation_mul_partition O hZ

/-- Connected generating functional at zero source equals `log Z`. -/
theorem row23_connected_functional_zero
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) :
    m.connectedGeneratingFunctional (fun _ => (0 : ℂ)) = Complex.log m.partition :=
  m.connectedGeneratingFunctional_zero

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B23
