import CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant
import CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions
import CATEPTMain.CATEPT_ProperTime.ClosedTimePathEffectiveAction
import CATEPTMain.Integration.ADMEntropyPathIntegralBridge
import CATEPTMain.Integration.SchwingerKeldyshADMBridge
import CATEPTMain.Integration.ProperTimePathIntegralBridge

/-! Kernel-axiom audit for the post-axiom-cleanup carrier surface.

CATEPT_ProperTime carriers — PR #50 (7 axioms retired):
  HeatKernelDeterminant: heatKernelTrace, properTimeDeterminantIntegral
  ThermalBoundaryConditions: bosonPartitionFunction, fermionPartitionFunction,
    thermal_boson_periodic, thermal_fermion_antiperiodic
  ClosedTimePathEffectiveAction: ctp_required_for_finite_temp_effective_action (deleted)

ADMEntropyPathIntegralBridge — PR #52 (5 axioms retired):
  Time, SpacePoint (carrier-type axioms → defs)
  admIntegral, normalDerivative, entropicNormalAccumulation (function-axioms → trivial-witness defs)

SchwingerKeldyshADMBridge — PR #(this PR) (3 axioms retired):
  ADMMetric (carrier-type axiom → def := Unit)
  ADMMomentum, MatterField (carrier-type axioms — both were unused; deleted)

Each `#print axioms` directive must report `[propext, Classical.choice, Quot.sound]`. -/

-- CATEPT_ProperTime carriers
#print axioms CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant.heatKernelTrace
#print axioms CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant.properTimeDeterminantIntegral
#print axioms CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions.bosonPartitionFunction
#print axioms CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions.fermionPartitionFunction
#print axioms CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions.thermal_boson_periodic
#print axioms CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions.thermal_fermion_antiperiodic

-- ADMEntropyPathIntegralBridge function-witnesses
#print axioms CATEPTMain.Integration.ADMEntropyPathIntegralBridge.admIntegral
#print axioms CATEPTMain.Integration.ADMEntropyPathIntegralBridge.normalDerivative
#print axioms CATEPTMain.Integration.ADMEntropyPathIntegralBridge.entropicNormalAccumulation

-- SchwingerKeldyshADMBridge carrier + downstream substantive theorem
#print axioms CATEPTMain.Integration.SchwingerKeldyshADMBridge.ADMMetric
#print axioms CATEPTMain.Integration.SchwingerKeldyshADMBridge.admEntropyActionDensity_nonneg

-- ProperTimePathIntegralBridge function-witness
#print axioms CATEPTMain.Integration.ProperTimePathIntegralBridge.properTimeIntegral
