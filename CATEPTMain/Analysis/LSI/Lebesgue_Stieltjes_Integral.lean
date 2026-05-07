import CATEPTMain.Analysis.LSI.Preliminaries_LSI
import CATEPTPluginDomainAnalysis.LSI.Lebesgue_Stieltjes_Integral

/-!
# Lebesgue_Stieltjes_Integral — re-export shim (sub-bundle `LSI`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.LSI.Lebesgue_Stieltjes_Integral

export CATEPTPluginDomainAnalysis.LSI.Lebesgue_Stieltjes_Integral (
  lebesgue_stieltjes_eq_density_integral
  lebesgue_stieltjes_integration_by_parts
  lsi_continuous_integrable
  lsi_from_integral_function
  lsi_fubini
  lsi_indicator_Ioc
  lsi_integral_linear
  lsi_integral_mono
  lsi_integral_nonneg
)

end CATEPTMain.Analysis.LSI.Lebesgue_Stieltjes_Integral
