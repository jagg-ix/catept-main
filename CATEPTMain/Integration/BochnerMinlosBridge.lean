import CATEPTPluginBochnerMinlos.IntegrationBridge

/-!
# Bochner–Minlos Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-bochner-minlos` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; eleventh sibling).

The witness, contract, and bridge theorem are now authoritatively in
`CATEPTPluginBochnerMinlos.IntegrationBridge`. This file re-exports
them under the original `CATEPTMain.Integration.BochnerMinlos`
namespace so existing consumers (`CATEPTMain.lean` umbrella,
`External/Registry.lean` registry entry) continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.BochnerMinlos

export CATEPTPluginBochnerMinlos (
  BochnerMinlosWitness
  BochnerMinlosIntegrationContract
  bochnerMinlos_integration_contract)

end CATEPTMain.Integration.BochnerMinlos
