import CATEPTPluginHilleYosida.IntegrationBridge

/-!
# Hille–Yosida Integration Bridge — re-export shim

This file used to host the full Hille-Yosida integration bridge. It was
extracted to the sibling repo `jagg-ix/catept-plugin-hille-yosida` under
[Target 4](../../docs/architecture/targets/target-4-plan.md) of the
plugin-architecture rework (T4.2 + T4.3).

The five published theorems and two witness structures are now
authoritatively defined in `CATEPTPluginHilleYosida.IntegrationBridge`.
This file re-exports them under the original
`CATEPTMain.Integration.HilleYosida` and `CATEPTMain.Integration.HilleYosidaNS`
namespaces so existing consumers continue to compile without source
changes.

For the `#print axioms` regression check on the publication surface,
both the sibling repo's CI (`catept-plugin-hille-yosida/.github/workflows/axiom-gate.yml`)
and `catept-main/.github/workflows/axiom-gate.yml` cover these names.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.HilleYosida

export CATEPTPluginHilleYosida (
  HilleYosidaWitness
  HilleYosidaIntegrationContract
  hilleYosida_integration_contract)

end CATEPTMain.Integration.HilleYosida

namespace CATEPTMain.Integration.HilleYosidaNS

export CATEPTPluginHilleYosida (
  proved_semigroup_growth_bound
  proved_resolvent_bound
  contracting_has_optimal_growth_bound
  ProvedHilleYosidaWitness
  mkProvedHilleYosidaWitness
  ns_heat_semigroup_abstract_theory_proved)

end CATEPTMain.Integration.HilleYosidaNS
