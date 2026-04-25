import CATEPTPluginThermodynamicsLean.IntegrationBridge

/-!
# Thermodynamics (Lieb-Yngvason) Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-thermodynamics-lean`
under [Target 5](../../docs/architecture/targets/target-4-plan.md)
(scale-out wave; 16th sibling).

Re-exports the witness, contract, and bridge theorem under the original
`CATEPTMain.Integration.ThermodynamicsLean` namespace.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ThermodynamicsLean

export CATEPTPluginThermodynamicsLean (
  ThermodynamicsLeanWitness
  ThermodynamicsLeanIntegrationContract
  thermodynamicsLean_integration_contract)

end CATEPTMain.Integration.ThermodynamicsLean
