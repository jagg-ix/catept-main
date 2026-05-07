import CATEPTMain.Integration.AbstractWitnessContracts.BTCompat
/-!
# Bridge Theory Compatibility — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-bt-compat` under
[Target 60 step 1](../../../docs/architecture/targets/target-4-plan.md)
(plugin-slot decoupling; first extraction from the CAT/EPT *core* tree).

The 11 scalar BT-equation defs + 10 sanity/invariance theorems are now
authoritatively in `CATEPTPluginBTCompat.IntegrationBridge`. This file
re-exports them under the original `CATEPTMain.CATEPT.CATEPT` namespace
so existing consumers (`CATEPTPort` barrel + downstream Integration
plugins) continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

export CATEPTPluginBTCompat (
  btTotalEnergy
  btTotalMomentum
  btInvariantEnergySq
  btPhotonEnergyEq6
  btDopplerFactor
  btObservedFrequency
  btObservedPhotonEnergy
  btPeriodPrime
  btWavelengthPrime
  btLorentzTime
  btLorentzSpace
  btRelativisticEnergy
  btRelativisticMomentumTimesC
  btInvariantEnergySq_at_rest
  btDopplerFactor_at_rest
  btObservedFrequency_at_rest
  btObservedPhotonEnergy_at_rest
  btPeriodPrime_at_rest
  btWavelengthPrime_at_rest
  btLorentzTime_at_rest
  btLorentzSpace_at_rest
  btInvariant_from_relativistic_param)

end CATEPTMain.CATEPT.CATEPT
