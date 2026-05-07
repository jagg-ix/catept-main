import CATEPTPluginSpectralPhysics.IntegrationBridge

/-!
# Spectral Physics Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-spectral-physics`
under [Target 5](../../docs/architecture/targets/target-4-plan.md)
(scale-out wave; seventh sibling, T5.5).

The proved spectral-gap / Rayleigh / heat-semigroup / Bakry-Émery
results are now authoritatively in
`CATEPTPluginSpectralPhysics.IntegrationBridge`. This file re-exports
them under the original `CATEPTMain.Integration.SpectralPhysicsBridge`
namespace so the existing umbrella consumer (`CATEPTMain.lean`)
continues to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SpectralPhysicsBridge

export CATEPTPluginSpectralPhysics (
  proved_spectral_gap_pos
  proved_laplacian_self_adjoint
  proved_laplacian_pos_semidef
  proved_rayleigh_nonneg
  proved_rayleigh_ge_gap
  proved_heat_kernel_psd
  proved_heat_contraction
  proved_correlator_decay
  proved_lichnerowicz
  spectral_physics_content_available)

end CATEPTMain.Integration.SpectralPhysicsBridge
