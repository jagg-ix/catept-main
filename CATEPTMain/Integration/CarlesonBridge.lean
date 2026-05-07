import CATEPTMain.Integration.AbstractWitnessContracts.Carleson
/-!
# Carleson Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-carleson` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; twelfth sibling).

The witness, contract, theorem, and proof-carrying witness are now
authoritatively in `CATEPTPluginCarleson.IntegrationBridge`. This file
re-exports them under the original `CATEPTMain.Integration.Carleson`
namespace so existing consumers continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.Carleson

export CATEPTPluginCarleson (
  CarlesonWitness
  CarlesonIntegrationContract
  carleson_integration_contract
  CarlesonConcreteWitness
  concrete_witness_contract
  mkConcreteWitness)

end CATEPTMain.Integration.Carleson
