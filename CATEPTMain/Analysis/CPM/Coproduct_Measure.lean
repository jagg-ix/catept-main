import CATEPTMain.Analysis.CPM.Lemmas_Coproduct_Measure
import CATEPTPluginDomainAnalysis.CPM.Coproduct_Measure

/-!
# Coproduct_Measure — re-export shim (sub-bundle `CPM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.CPM.Coproduct_Measure

export CATEPTPluginDomainAnalysis.CPM.Coproduct_Measure (
  coprodMeasure
  coprodMeasure_empty
  coprodMeasure_integral
  coprodMeasure_mono
  coprodMeasure_s_finite
  coprodMeasure_total
  coprodMeasure_total_tsum
  coproduct_measurable_iff
)

end CATEPTMain.Analysis.CPM.Coproduct_Measure
