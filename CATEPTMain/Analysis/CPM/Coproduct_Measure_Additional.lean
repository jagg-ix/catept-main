import CATEPTMain.Analysis.CPM.Coproduct_Measure
import CATEPTPluginDomainAnalysis.CPM.Coproduct_Measure_Additional

/-!
# Coproduct_Measure_Additional — re-export shim (sub-bundle `CPM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.CPM.Coproduct_Measure_Additional

export CATEPTPluginDomainAnalysis.CPM.Coproduct_Measure_Additional (
  coprodMeasure_integral_formula
  coprodMeasure_lintegral
  coprodMeasure_prob_total
  coprodMeasure_prod_distrib
  coprodMeasure_pushforward
)

end CATEPTMain.Analysis.CPM.Coproduct_Measure_Additional
