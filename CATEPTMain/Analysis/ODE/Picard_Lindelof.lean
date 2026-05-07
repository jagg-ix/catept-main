import CATEPTMain.Analysis.ODE.ODEPrelude
import CATEPTPluginDomainAnalysis.ODE.Picard_Lindelof

/-!
# Picard_Lindelof — re-export shim (sub-bundle `ODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.ODE.Picard_Lindelof

export CATEPTPluginDomainAnalysis.ODE.Picard_Lindelof (
  global_lipschitz_unique
  gronwall
  picardIter
  picardIter_converges
  picardIter_succ
  picardIter_zero
)

end CATEPTMain.Analysis.ODE.Picard_Lindelof
