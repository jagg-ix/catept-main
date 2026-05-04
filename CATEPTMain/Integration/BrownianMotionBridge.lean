import CATEPTMain.Integration.AbstractWitnessContracts.BrownianMotion
/-!
# Brownian Motion Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-brownian-motion` under
[Target 4](../../docs/architecture/targets/target-4-plan.md) (T4.5,
second extraction validating the playbook).

The witness, contract, and bridge theorem are now authoritatively in
`CATEPTPluginBrownianMotion.IntegrationBridge`. This file re-exports
them under the original `CATEPTMain.Integration.BrownianMotion`
namespace so existing consumers continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.BrownianMotion

export CATEPTPluginBrownianMotion (
  BrownianMotionWitness
  BrownianMotionIntegrationContract
  brownianMotion_integration_contract)

end CATEPTMain.Integration.BrownianMotion
