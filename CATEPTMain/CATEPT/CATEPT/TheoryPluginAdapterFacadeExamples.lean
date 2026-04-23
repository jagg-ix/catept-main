import CATEPTMain.CATEPT.CATEPT.TheoryPluginAdapterFacade
import CATEPTMain.CATEPT.CATEPT.TheoryPluginExamples

set_option autoImplicit false

namespace CATEPT.TheoryPlugin

noncomputable section

/-! # Theory Plugin Adapter Facade Examples (Core)

Concrete core-safe examples showing how an external payload is adapted through
`ExternalTheoryPayload.toPluginSpec` and validated with canonical unit context.
-/

/-- Example external payload reusing the quadratic core model. -/
def quadraticExternalPayload : ExternalTheoryPayload where
  name := "quadratic-external-payload"
  State := Real
  measurableState := inferInstance
  pathModel := quadraticPathModel
  eptClock := fun x => x ^ 2 / 2
  eptClock_nonneg := by
    intro x
    nlinarith [sq_nonneg x]
  measurementCommunication := quadraticMeasurementCommunicationWitness
  measurementCommunication_valid := quadraticMeasurementCommunicationWitness_valid
  clock_matches_path := by
    intro x
    simp [quadraticPathModel, MeasurePathIntegralModel.actionImScaled]

/-- Adapter map immediately yields core plugin validity. -/
theorem quadraticExternalPayload_valid :
    validatePlugin quadraticExternalPayload.toPluginSpec :=
  quadraticExternalPayload.toPluginSpec_valid

/-- Full validity including the dimensional certificate slot. -/
theorem quadraticExternalPayload_fullValid :
    validatePluginFull quadraticExternalPayload.toPluginSpec :=
  quadraticExternalPayload.toPluginSpec_fullValid

/-- Canonical unit context closes the end-to-end adapter theorem. -/
theorem quadraticExternalPayload_adapted_with_canonical_units :
    validatePluginFull quadraticExternalPayload.toPluginSpec :=
  ExternalTheoryPayload.adapted_full_validation
    quadraticExternalPayload
    CATEPT.canonicalInfoUnitContext

/-- Adapter dimensional report remains canonical under canonical units. -/
theorem quadraticExternalPayload_dimReport_canonical :
    externalPayloadDimReport quadraticExternalPayload CATEPT.canonicalInfoUnitContext =
      canonicalPluginDimReport := rfl

end

end CATEPT.TheoryPlugin
