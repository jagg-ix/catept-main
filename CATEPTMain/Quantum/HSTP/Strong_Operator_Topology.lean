import CATEPTMain.Quantum.HSTP.Misc_TP
import CATEPTPluginDomainQuantum.HSTP.Strong_Operator_Topology

/-!
# Strong_Operator_Topology — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Strong_Operator_Topology

export CATEPTPluginDomainQuantum.HSTP.Strong_Operator_Topology (
  HSTPStrongConv
  hstpOpComp
  norm_implies_sot
  sot_bounded_subnet
  sot_left_mult_cont
)

end CATEPTMain.Quantum.HSTP.Strong_Operator_Topology
