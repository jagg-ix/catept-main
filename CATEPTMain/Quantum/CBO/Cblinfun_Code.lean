import CATEPTMain.Quantum.CBO.Cblinfun_Matrix
import CATEPTPluginDomainQuantum.CBO.Cblinfun_Code

/-!
# Cblinfun_Code — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Cblinfun_Code

export CATEPTPluginDomainQuantum.CBO.Cblinfun_Code (
  cboFromMatrix
  cboFromMatrix_toMatrix
  finDim_op_eq_iff_matrix
  trace_eq_diag_sum
)

end CATEPTMain.Quantum.CBO.Cblinfun_Code
