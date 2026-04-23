import CATEPTMain.CATEPT.TheoryPluginArchitecture
import CATEPTMain.CATEPT.TheoryPluginDimCategoryCore

set_option autoImplicit false

namespace CATEPT.TheoryPlugin

/-! # Theory Plugin Adapter Facade (Core)

Core-safe adapter boundary for importing external plugin payloads into the
`PluginSpec` validation surface without depending on integration-specific code.
-/

/-- External payload contract accepted by the core adapter facade. -/
structure ExternalTheoryPayload where
  name : String
  State : Type
  measurableState : MeasurableSpace State
  pathModel : @MeasurePathIntegralModel State measurableState
  eptClock : State -> Real
  eptClock_nonneg : forall x, 0 <= eptClock x
  measurementCommunication : MeasurementCommunicationCompatibilityWitness
  measurementCommunication_valid :
    measurementCommunicationCompatibilityContract measurementCommunication
  clock_matches_path : forall x, pathModel.actionImScaled x = eptClock x

/-- Core adapter map from an external payload into `PluginSpec`. -/
def ExternalTheoryPayload.toPluginSpec (payload : ExternalTheoryPayload) : PluginSpec where
  name := payload.name
  State := payload.State
  measurableState := payload.measurableState
  pathModel := payload.pathModel
  eptClock := payload.eptClock
  eptClock_nonneg := payload.eptClock_nonneg
  measurementCommunication := payload.measurementCommunication
  measurementCommunication_valid := payload.measurementCommunication_valid

/-- Adapted plugin is CATEPT-consistent by the payload clock/path contract. -/
theorem ExternalTheoryPayload.toPluginSpec_consistent
    (payload : ExternalTheoryPayload) :
    cateptConsistencyConstraint payload.toPluginSpec := by
  intro x
  simpa [ExternalTheoryPayload.toPluginSpec] using payload.clock_matches_path x

/-- Adapted plugin satisfies the core validator. -/
theorem ExternalTheoryPayload.toPluginSpec_valid
    (payload : ExternalTheoryPayload) :
    validatePlugin payload.toPluginSpec :=
  validatePlugin_of_consistency payload.toPluginSpec payload.toPluginSpec_consistent

/-- Adapted plugin satisfies the full validator (including dimensional slot). -/
theorem ExternalTheoryPayload.toPluginSpec_fullValid
    (payload : ExternalTheoryPayload) :
    validatePluginFull payload.toPluginSpec :=
  validatePluginFull_of_validatePlugin payload.toPluginSpec payload.toPluginSpec_valid

/-- Dimensional report selected by the adapter under a declared unit context. -/
def externalPayloadDimReport
    (_payload : ExternalTheoryPayload)
    (_ctx : CATEPT.TheoryUnitContext) : PluginDimReport :=
  canonicalPluginDimReport

theorem externalPayloadDimReport_eq_canonical
    (payload : ExternalTheoryPayload)
    (ctx : CATEPT.TheoryUnitContext) :
    externalPayloadDimReport payload ctx = canonicalPluginDimReport := rfl

/-- End-to-end adapter theorem parameterized by a unit context declaration. -/
theorem ExternalTheoryPayload.adapted_full_validation
    (payload : ExternalTheoryPayload)
    (_ctx : CATEPT.TheoryUnitContext) :
    validatePluginFull payload.toPluginSpec :=
  payload.toPluginSpec_fullValid

end CATEPT.TheoryPlugin
