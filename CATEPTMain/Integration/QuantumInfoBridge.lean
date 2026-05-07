import CATEPTMain.Integration.AbstractWitnessContracts.QuantumInfo
/-!
# Quantum Information Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-quantum-info` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; fifth sibling, T5.3).

The witness, contract, and bridge theorem are now authoritatively in
`CATEPTPluginQuantumInfo.IntegrationBridge`. This file re-exports them
under the original `CATEPTMain.Integration.QuantumInfo` namespace so
existing consumers (`CATEPTMain.lean` umbrella + `QuantumInfoStandalone`)
continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.QuantumInfo

export CATEPTPluginQuantumInfo (
  QuantumInfoWitness
  QuantumInfoIntegrationContract
  quantumInfo_integration_contract)

end CATEPTMain.Integration.QuantumInfo
