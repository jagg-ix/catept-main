import CATEPTMain.Analysis.CPM.CPMPrelude
import CATEPTPluginDomainAnalysis.CPM.Lemmas_Coproduct_Measure

/-!
# Lemmas_Coproduct_Measure — re-export shim (sub-bundle `CPM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.CPM.Lemmas_Coproduct_Measure

export CATEPTPluginDomainAnalysis.CPM.Lemmas_Coproduct_Measure (
  coprod_sigma_algebra_minimal
  indicator_sigma_measurable
  isSFinite_iff
  sigmaFinite_isSFinite
  sigma_injections_disjoint
  sigma_section_measurable
)

end CATEPTMain.Analysis.CPM.Lemmas_Coproduct_Measure
