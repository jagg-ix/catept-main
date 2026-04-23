import Mathlib

set_option autoImplicit false

namespace CATEPTMain.CATEPT

noncomputable section

/-! # Measurement and Communication Core Abstractions

Core-safe contracts for measurement/communication bridge lanes, extracted as
lightweight finite-dimensional witness surfaces.
-/

/-- Finite instrument with normalized outcome weights and nonnegative responses. -/
structure FiniteInstrument where
  outcomes : ℕ
  outcomeWeight : Fin outcomes → ℝ
  responseValue : Fin outcomes → ℝ
  outcomeWeight_nonneg : ∀ i, 0 <= outcomeWeight i
  responseValue_nonneg : ∀ i, 0 <= responseValue i
  outcomeWeight_sum_one : (Finset.univ.sum outcomeWeight) = 1

/-- Communication-side output proxy as a weighted response average. -/
def communicationOutput (I : FiniteInstrument) : ℝ :=
  Finset.univ.sum (fun i => I.outcomeWeight i * I.responseValue i)

theorem communicationOutput_nonneg (I : FiniteInstrument) :
    0 <= communicationOutput I := by
  unfold communicationOutput
  refine Finset.sum_nonneg ?_
  intro i hi
  exact mul_nonneg (I.outcomeWeight_nonneg i) (I.responseValue_nonneg i)

/-- Von Neumann observable model with normalized Born weights. -/
structure VonNeumannObservableModel where
  levels : ℕ
  eigenvalue : Fin levels → ℝ
  bornWeight : Fin levels → ℝ
  bornWeight_nonneg : ∀ i, 0 <= bornWeight i
  bornWeight_sum_one : (Finset.univ.sum bornWeight) = 1

/-- Observable expectation proxy in finite spectral form. -/
def observableExpectation (M : VonNeumannObservableModel) : ℝ :=
  Finset.univ.sum (fun i => M.bornWeight i * M.eigenvalue i)

/-- Measurement-communication discrepancy functional. -/
def measurementCommunicationGap
    (I : FiniteInstrument) (M : VonNeumannObservableModel) : ℝ :=
  communicationOutput I - observableExpectation M

/-- Equality of communication and measurement expectations implies zero gap. -/
theorem measurement_as_communication_equivalence
    (I : FiniteInstrument) (M : VonNeumannObservableModel)
    (hEq : communicationOutput I = observableExpectation M) :
    measurementCommunicationGap I M = 0 := by
  unfold measurementCommunicationGap
  linarith

/-- Zero gap rewrites communication output as observable expectation. -/
theorem communication_equals_measurement_of_gap_zero
    (I : FiniteInstrument) (M : VonNeumannObservableModel)
    (hGap : measurementCommunicationGap I M = 0) :
    communicationOutput I = observableExpectation M := by
  unfold measurementCommunicationGap at hGap
  linarith

/-- Entropic-time scaling of a nonnegative measurement mismatch proxy. -/
def measurementEntropicTime (hbar mismatch : ℝ) : ℝ :=
  mismatch / hbar

theorem measurementEntropicTime_nonneg
    (hbar mismatch : ℝ)
    (hhbar : 0 < hbar)
    (hmismatch : 0 <= mismatch) :
    0 <= measurementEntropicTime hbar mismatch := by
  unfold measurementEntropicTime
  exact div_nonneg hmismatch hhbar.le

/-- Compatibility witness used by integration-facing measurement bridge lanes. -/
structure MeasurementCommunicationCompatibilityWitness where
  finiteInstrumentAvailable : Prop
  observableModelAvailable : Prop
  outputExpectationConsistency : Prop
  entropicClockCompatibility : Prop

def measurementCommunicationCompatibilityContract
    (w : MeasurementCommunicationCompatibilityWitness) : Prop :=
  w.finiteInstrumentAvailable ∧
    w.observableModelAvailable ∧
    w.outputExpectationConsistency ∧
    w.entropicClockCompatibility

theorem measurementCommunicationCompatibility_contract_of_fields
    (w : MeasurementCommunicationCompatibilityWitness)
    (h1 : w.finiteInstrumentAvailable)
    (h2 : w.observableModelAvailable)
    (h3 : w.outputExpectationConsistency)
    (h4 : w.entropicClockCompatibility) :
    measurementCommunicationCompatibilityContract w :=
  ⟨h1, h2, h3, h4⟩

end

end CATEPTMain.CATEPT
