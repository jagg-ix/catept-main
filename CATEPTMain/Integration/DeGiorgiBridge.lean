import CATEPTPluginDeGiorgi.IntegrationBridge

/-!
# De Giorgi–Nash–Moser Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-degiorgi` under
[Target 5](../../docs/architecture/targets/target-4-plan.md) (Phase 2 /
scale-out wave; eighth sibling, T5.6 — hits the ≥8 sibling milestone).

The eight proved theorems re-exporting De Giorgi–Nash–Moser elliptic-
PDE regularity (GNS, Poincaré, Sobolev-Poincaré, Harnack, Hölder-Moser,
Lax-Milgram weak existence) are now authoritatively in
`CATEPTPluginDeGiorgi.IntegrationBridge`. This file re-exports them
under the original `CATEPTMain.Integration.DeGiorgiBridge` namespace
so the existing umbrella consumer (`CATEPTMain.lean`) continues to
compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.DeGiorgiBridge

export CATEPTPluginDeGiorgi (
  proved_gns_smooth
  proved_gns_approx
  proved_poincare_unitBall
  proved_poincare_smooth
  proved_sobolev_poincare_unitBall
  proved_harnack
  proved_holder_Moser
  proved_weak_existence
  deGiorgi_content_available)

end CATEPTMain.Integration.DeGiorgiBridge
