import CATEPTMain.Quantum.CBO.Extra_Jordan_Normal_Form
import CATEPTPluginDomainQuantum.CBO.Cblinfun_Matrix

/-!
# Cblinfun_Matrix — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Cblinfun_Matrix

export CATEPTPluginDomainQuantum.CBO.Cblinfun_Matrix (
  opNorm_le_frobenius
  opToMatrix
  opToMatrix_adj
  opToMatrix_apply
  opToMatrix_comp
  rankOne_unit_projector_bridge
)

end CATEPTMain.Quantum.CBO.Cblinfun_Matrix
