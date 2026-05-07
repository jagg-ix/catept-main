import CATEPTMain.Quantum.CBO.Extra_Ordered_Fields
import CATEPTPluginDomainQuantum.CBO.Extra_Operator_Norm

/-!
# Extra_Operator_Norm — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_Operator_Norm

export CATEPTPluginDomainQuantum.CBO.Extra_Operator_Norm (
  cboNorm_adj
  cboNorm_adj_comp
  cboNorm_comp_le'
  cboNorm_one
  cboNorm_sub_triangle
  cboNorm_sup_def
)

end CATEPTMain.Quantum.CBO.Extra_Operator_Norm
