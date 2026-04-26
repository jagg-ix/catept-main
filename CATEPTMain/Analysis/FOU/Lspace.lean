import CATEPTMain.Analysis.FOU.Periodic
import CATEPTPluginDomainAnalysis.FOU.Lspace

/-!
# Lspace — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU.Lspace

export CATEPTPluginDomainAnalysis.FOU.Lspace (
  L1_le_L2
  L2inner
  L2inner_conj
  continuous_dense_L2
  eLpNorm
  sq_int_implies_integrable
)

end CATEPTMain.Analysis.FOU.Lspace
