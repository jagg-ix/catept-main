import CATEPTPluginDomainAnalysis.CPM.CPMPrelude

/-!
# CPMPrelude — re-export shim (sub-bundle `CPM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.CPM

export CATEPTPluginDomainAnalysis.CPM (
  IsSFinite
  coprodMeasure
  coprodMeasure_injection_eq
  coprodMeasure_injection_measurable
  coprodMeasure_measurable_iff
  coprodMeasure_sfin
  isFinite_isSFinite
  isSFinite_sum
)

end CATEPTMain.Analysis.CPM
