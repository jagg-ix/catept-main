import CATEPTMain.Analysis.FOU.Square_Integrable
import CATEPTPluginDomainAnalysis.FOU.Confine

/-!
# Confine — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU.Confine

export CATEPTPluginDomainAnalysis.FOU.Confine (
  dirichletKernel
  dirichletKernel_closed
  partialSum_best_approx
  partialSum_error
  partialSum_is_convolution
  partialSum_norm_sq
)

end CATEPTMain.Analysis.FOU.Confine
