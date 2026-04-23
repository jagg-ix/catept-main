import NavierStokesClean.CATEPT.MeasurePathIntegral
import NavierStokesClean.CATEPT.QFTGRClosures
import NavierStokesClean.CATEPT.QuantumGravity

/-!
# Batch 20260408 Theoremization - CATEPT Row 31 (Physical Measurement Process 0011)

Measurement-process wrappers over normalized expectations and constructive
Kuchar measurement closure.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B31

noncomputable section

open MeasureTheory
open NavierStokesClean.CATEPT

/-- Zero-source coupling recovers the normalized expectation. -/
theorem row31_zero_source_expectation
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (O : α → ℂ) :
    m.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = m.normalizedExpectation O :=
  m.sourceCoupledExpectation_zero O

/-- Normalized expectation recovers unnormalized moment by multiplication with `Z`. -/
theorem row31_normalized_mul_partition
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (O : α → ℂ)
    (hZ : m.partition ≠ 0) :
    m.normalizedExpectation O * m.partition = m.unnormalizedExpectation O :=
  m.normalizedExpectation_mul_partition O hZ

/-- Constructive Kuchar solved-state implies measurement-problem closure score. -/
theorem row31_measurement_problem_closed
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    0 < s.s6 := by
  have hcomp :
      KucharComplete {
        problem_of_time := 0 < s.s1,
        problem_of_observables := 0 < s.s2,
        problem_of_hilbert := 0 < s.s3,
        problem_of_ordering := 0 < s.s4,
        problem_of_regularization := 0 < s.s5,
        problem_of_measurement := 0 < s.s6
      } :=
    kuchar_constructive_complete s hs
  exact hcomp.2.2.2.2.2

/-- Combined row-31 measurement-process witness package. -/
theorem row31_measurement_process_bundle
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (O : α → ℂ)
    (hZ : m.partition ≠ 0)
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    m.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = m.normalizedExpectation O ∧
      m.normalizedExpectation O * m.partition = m.unnormalizedExpectation O ∧
      0 < s.s6 := by
  exact ⟨row31_zero_source_expectation m O,
    row31_normalized_mul_partition m O hZ,
    row31_measurement_problem_closed s hs⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B31
