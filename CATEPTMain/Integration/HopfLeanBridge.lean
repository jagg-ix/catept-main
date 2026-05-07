import CATEPTMain.Integration.AbstractWitnessContracts.HopfLean
/-!
# Hopf-Algebra Integration Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-hopf-lean` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; 14th sibling).

Re-exports the witness, contract, and bridge theorem under the original
`CATEPTMain.Integration.HopfLean` namespace.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.HopfLean

export CATEPTPluginHopfLean (
  HopfLeanWitness
  HopfLeanIntegrationContract
  hopfLean_integration_contract)

end CATEPTMain.Integration.HopfLean
