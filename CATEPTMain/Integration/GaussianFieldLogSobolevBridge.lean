import CATEPTPluginGaussianFieldLSI.IntegrationBridge

/-!
# Gaussian Field Log-Sobolev Bridge — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-gaussian-field-lsi`
under [Target 5](../../docs/architecture/targets/target-4-plan.md)
(scale-out wave; sixth sibling, T5.4).

The proved Gross log-Sobolev / 1D log-Sobolev / spectral-gap /
second-moment results are now authoritatively in
`CATEPTPluginGaussianFieldLSI.IntegrationBridge`. This file re-exports
them under the original `CATEPTMain.Integration.GaussianFieldLogSobolev`
namespace so the existing consumer (`CATEPTMain.lean` umbrella +
`DeGiorgiBridge` docstring references) continues to compile unchanged.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GaussianFieldLogSobolev

export CATEPTPluginGaussianFieldLSI (
  proved_gross_log_sobolev
  proved_log_sobolev_1d
  provedHasSpectralGap
  discrete_poincare_from_spectral_gap
  gaussian_field_content_available
  log_sobolev_is_bkm_ingredient_1_backbone
  proved_second_moment_eq_covariance)

end CATEPTMain.Integration.GaussianFieldLogSobolev
