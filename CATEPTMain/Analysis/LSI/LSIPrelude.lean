import CATEPTPluginDomainAnalysis.LSI.LSIPrelude

/-!
# LSIPrelude — re-export shim (sub-bundle `LSI`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.LSI

export CATEPTPluginDomainAnalysis.LSI (
  LSIAbsCont
  lsiChangeOfVariables
  lsiIntByParts
  lsiIntegral
  lsiIntegralOn
  lsiMeasure
  lsiMeasure_Ioc
  lsiMeasure_right_cont
)

end CATEPTMain.Analysis.LSI
