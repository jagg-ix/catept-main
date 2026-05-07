import CATEPTPluginCslib.IntegrationBridge

/-!
# CSLib Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-cslib` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; fourth sibling).

The witness, contract, and bridge theorem are now authoritatively in
`CATEPTPluginCslib.IntegrationBridge`. This file re-exports them under
the original `CATEPTMain.Integration.Cslib` namespace so existing
consumers continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.Cslib

export CATEPTPluginCslib (
  CslibWitness
  CslibIntegrationContract
  cslib_integration_contract)

end CATEPTMain.Integration.Cslib
