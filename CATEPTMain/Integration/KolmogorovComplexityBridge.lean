import CATEPTPluginKolmogorovComplexity.IntegrationBridge

/-!
# Kolmogorov-Complexity Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-kolmogorov-complexity`
under [Target 5](../../docs/architecture/targets/target-4-plan.md)
(scale-out wave; 15th sibling).

Re-exports the witness, contract, and bridge theorem under the original
`CATEPTMain.Integration.KolmogorovComplexity` namespace.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.KolmogorovComplexity

export CATEPTPluginKolmogorovComplexity (
  KolmogorovComplexityWitness
  KolmogorovComplexityIntegrationContract
  kolmogorovComplexity_integration_contract)

end CATEPTMain.Integration.KolmogorovComplexity
