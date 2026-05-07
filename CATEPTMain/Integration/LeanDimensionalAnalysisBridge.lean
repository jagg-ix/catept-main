import CATEPTPluginDimensionalAnalysis.IntegrationBridge

/-!
# LeanDimensionalAnalysis Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-dimensional-analysis`
under [Target 4](../../docs/architecture/targets/target-4-plan.md)
(third sibling, follow-up beyond the parent ≥2 minimum).

The witness, contract, and bridge theorem are now authoritatively in
`CATEPTPluginDimensionalAnalysis.IntegrationBridge`. This file
re-exports them under the original
`CATEPTMain.Integration.LeanDimensionalAnalysis` namespace so existing
consumers continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.LeanDimensionalAnalysis

export CATEPTPluginDimensionalAnalysis (
  LeanDimensionalAnalysisWitness
  LeanDimensionalAnalysisIntegrationContract
  leanDimensionalAnalysis_integration_contract)

end CATEPTMain.Integration.LeanDimensionalAnalysis
