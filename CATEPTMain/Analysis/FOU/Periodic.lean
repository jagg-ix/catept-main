import CATEPTMain.Analysis.FOU.FOUPrelude
import CATEPTPluginDomainAnalysis.FOU.Periodic

/-!
# Periodic — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU.Periodic

export CATEPTPluginDomainAnalysis.FOU.Periodic (
  integral_one_period
  is2PiPeriodic_of_isPeriodic
  isPeriodic_shift
  periodic_continuous_bounded
  periodic_integrable
  periodic_integral_shift
)

end CATEPTMain.Analysis.FOU.Periodic
