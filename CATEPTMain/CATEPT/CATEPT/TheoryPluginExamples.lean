import CATEPTMain.CATEPT.CATEPT.TheoryPluginArchitecture

set_option autoImplicit false

namespace CATEPT.TheoryPlugin

noncomputable section

/-! # Theory Plugin Examples (Core)

Concrete, core-safe plugin instances proving end-to-end validator use.
-/

/-- Minimal witness with all measurement/communication capability flags enabled. -/
def quadraticMeasurementCommunicationWitness : MeasurementCommunicationCompatibilityWitness where
  finiteInstrumentAvailable := True
  observableModelAvailable := True
  outputExpectationConsistency := True
  entropicClockCompatibility := True

theorem quadraticMeasurementCommunicationWitness_valid :
    measurementCommunicationCompatibilityContract
      quadraticMeasurementCommunicationWitness := by
  exact ⟨trivial, trivial, trivial, trivial⟩

/-- Real-state path model with nontrivial imaginary action `S_I(x) = x^2`. -/
def quadraticPathModel : MeasurePathIntegralModel Real where
  mu := MeasureTheory.Measure.dirac 0
  hbar := 2
  hbar_pos := by norm_num
  actionRe := fun x => x
  actionIm := fun x => x ^ 2
  measurable_actionRe := measurable_id
  measurable_actionIm := by
    simpa [pow_two] using (measurable_id.mul measurable_id)
  actionIm_nonneg := by
    intro x
    nlinarith [sq_nonneg x]

/-- Nontrivial plugin with entropic clock `tau(x) = x^2 / 2`. -/
def quadraticClockPlugin : PluginSpec where
  name := "quadratic-clock-plugin"
  State := Real
  measurableState := inferInstance
  pathModel := quadraticPathModel
  eptClock := fun x => x ^ 2 / 2
  eptClock_nonneg := by
    intro x
    nlinarith [sq_nonneg x]
  measurementCommunication := quadraticMeasurementCommunicationWitness
  measurementCommunication_valid := quadraticMeasurementCommunicationWitness_valid

theorem quadraticClockPlugin_consistent :
    cateptConsistencyConstraint quadraticClockPlugin := by
  intro x
  simp [quadraticClockPlugin, quadraticPathModel, MeasurePathIntegralModel.actionImScaled]

theorem quadraticClockPlugin_valid :
    validatePlugin quadraticClockPlugin :=
  validatePlugin_of_consistency quadraticClockPlugin quadraticClockPlugin_consistent

theorem quadraticClockPlugin_fullValid :
    validatePluginFull quadraticClockPlugin :=
  validatePluginFull_of_validatePlugin quadraticClockPlugin quadraticClockPlugin_valid

instance : MeasureTheory.IsFiniteMeasure quadraticClockPlugin.pathModel.mu := by
  simpa [quadraticClockPlugin, quadraticPathModel] using
    (inferInstance : MeasureTheory.IsFiniteMeasure (MeasureTheory.Measure.dirac (0 : Real)))

/-- Automatic integrability certificate for the quadratic plugin. -/
def quadraticClockPlugin_measureCertificate : PluginMeasureCertificate quadraticClockPlugin :=
  pluginMeasureCertificate_of_finiteReference quadraticClockPlugin

theorem quadraticClockPlugin_complexMeasureContract :
    pluginComplexMeasureContract quadraticClockPlugin quadraticClockPlugin_measureCertificate :=
  pluginComplexMeasureContract_of_certificate
    quadraticClockPlugin
    quadraticClockPlugin_measureCertificate

theorem quadraticClockPlugin_eptClock_one :
  quadraticClockPlugin.eptClock (1 : Real) = (1 / 2 : Real) := by
  change ((1 : Real) ^ 2 / 2) = (1 / 2 : Real)
  norm_num

end

end CATEPT.TheoryPlugin
