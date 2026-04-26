import CATEPTMain.Analysis.FOU.Fourier_Aux2
import CATEPTPluginDomainAnalysis.FOU.Fourier

/-!
# Fourier — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU.Fourier

export CATEPTPluginDomainAnalysis.FOU.Fourier (
  fourier_L2_convergence
  fourier_series_representation
  fourier_unique
  parseval
  parseval_tsum
  riesz_fischer
)

end CATEPTMain.Analysis.FOU.Fourier
