import CATEPTMain.Integration.AbstractWitnessContracts.MaxwellCurveSpacePphi2
/-!
# Maxwell-CurveSpace ↔ pphi2 Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-maxwell-curvespace-pphi2`
under [Target 5](../../docs/architecture/targets/target-4-plan.md)
(scale-out wave; ninth sibling, T5.8). Distinct from the parallel VML /
Vlasov-Maxwell-Landau extraction (different physics, different upstream).

The two structures + integration contract + bridge theorem are now
authoritatively in `CATEPTPluginMaxwellCurveSpacePphi2.IntegrationBridge`.
This file re-exports them under the original `CATEPTMain.Integration`
namespace (the source used the bare integration namespace, not a
sub-namespace) so existing consumers continue to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration

export CATEPTPluginMaxwellCurveSpacePphi2 (
  CatEptMaxwellCurveSpaceModel
  Pphi2IntegrationWitness
  CatEptPphi2IntegrationContract
  catEpt_maxwell_curveSpace_pphi2_bridge)

end CATEPTMain.Integration
