import CATEPTPluginDomainQuantum.PM.PMPrelude

/-!
# PMPrelude — re-export shim (sub-bundle `PM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.PM

export CATEPTPluginDomainQuantum.PM (
  IsDichotomicObs
  IsFullDensityOp
  IsObservable
  IsPVM
  IsPartialDensityOp
  IsProjector
  fullDensityOp_partial
  measProbPM
  measProbPM_nonneg
  measProbPM_sum
  postMeasState
  postMeasState_density
  pvm_complete
)

end CATEPTMain.Quantum.PM
