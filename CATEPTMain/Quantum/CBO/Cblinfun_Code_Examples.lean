import CATEPTMain.Quantum.CBO.Cblinfun_Code
import CATEPTPluginDomainQuantum.CBO.Cblinfun_Code_Examples

/-!
# Cblinfun_Code_Examples — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Cblinfun_Code_Examples

export CATEPTPluginDomainQuantum.CBO.Cblinfun_Code_Examples (
  hadamard_mat
  hadamard_sq_eq_id
  pauliX_mat
  pauliX_sq_eq_id
  pauliZ_mat
  tr_identity_2
  tr_pauliX
)

end CATEPTMain.Quantum.CBO.Cblinfun_Code_Examples
