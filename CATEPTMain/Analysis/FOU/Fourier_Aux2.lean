import CATEPTMain.Analysis.FOU.Confine
import CATEPTPluginDomainAnalysis.FOU.Fourier_Aux2

/-!
# Fourier_Aux2 — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU.Fourier_Aux2

export CATEPTPluginDomainAnalysis.FOU.Fourier_Aux2 (
  fejerKernel
  fejerKernel_nonneg
  fourierCoeff_c1_decay
  fourierCoeff_deriv
  riemann_lebesgue
  riemann_lebesgue_neg
  riemann_lebesgue_pos
)

end CATEPTMain.Analysis.FOU.Fourier_Aux2
