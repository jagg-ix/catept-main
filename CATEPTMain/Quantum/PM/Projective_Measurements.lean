import CATEPTMain.Quantum.PM.Linear_Algebra_Complements
import CATEPTPluginDomainQuantum.PM.Projective_Measurements

/-!
# Projective_Measurements — re-export shim (sub-bundle `PM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.PM.Projective_Measurements

export CATEPTPluginDomainQuantum.PM.Projective_Measurements (
  IsONB
  IsONB_inner
  measProbPM_eq_trace
  meas_prob_sum_two
  meas_repeatability
  postMeasState_eq
  pvmFromONB
  pvmFromONB_is_pvm
  pvm_complete_two
  pvm_self_adj
  traceMat
  traceMat_cyclic
  traceMat_linear
)

end CATEPTMain.Quantum.PM.Projective_Measurements
