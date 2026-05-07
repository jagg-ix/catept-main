import CATEPTPluginDomainAnalysis.FOU.FOUPrelude

/-!
# FOUPrelude — re-export shim (sub-bundle `FOU`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.FOU

export CATEPTPluginDomainAnalysis.FOU (
  Is2PiPeriodic
  IsPeriodic
  IsPeriodicR
  L2norm
  SqIntegrable
  SqIntegrableR
  fourierCoeff
  fourierCoeff_def
  fourierPartialSum
)

end CATEPTMain.Analysis.FOU
