import CATEPTPluginGibbsMeasure.IntegrationBridge

/-!
# Gibbs Measure Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-gibbs-measure` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; 13th sibling).

Re-exports the witness, contract, and bridge theorem under the original
`CATEPTMain.Integration.GibbsMeasure` namespace so existing consumers
continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GibbsMeasure

export CATEPTPluginGibbsMeasure (
  GibbsMeasureWitness
  GibbsMeasureIntegrationContract
  gibbsMeasure_integration_contract)

end CATEPTMain.Integration.GibbsMeasure
