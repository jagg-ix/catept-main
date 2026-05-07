import CATEPTMain.Quantum.HSTP.HS2Ell2
import CATEPTPluginDomainQuantum.HSTP.Weak_Operator_Topology

/-!
# Weak_Operator_Topology — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Weak_Operator_Topology

export CATEPTPluginDomainQuantum.HSTP.Weak_Operator_Topology (
  HSTPWeakConv
  IsHSTPUnitary
  sot_implies_wot
  wot_limit_of_unitaries_is_isometry
  wot_unit_ball_compact
)

end CATEPTMain.Quantum.HSTP.Weak_Operator_Topology
