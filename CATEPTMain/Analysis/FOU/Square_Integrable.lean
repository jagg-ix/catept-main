import CATEPTMain.Analysis.FOU.Lspace
import CATEPTPluginDomainAnalysis.FOU.Square_Integrable

/-!
# Square_Integrable — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU.Square_Integrable

export CATEPTPluginDomainAnalysis.FOU.Square_Integrable (
  bessel_inequality
  fourierCoeff_inner
  fourier_basis_norm
  fourier_basis_orthonormal
  fourier_basis_sqint
  sqint_add
  sqint_smul
  sqint_sub
)

end CATEPTMain.Analysis.FOU.Square_Integrable
