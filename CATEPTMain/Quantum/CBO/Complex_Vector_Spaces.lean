import CATEPTMain.Quantum.CBO.Complex_Vector_Spaces0
import CATEPTPluginDomainQuantum.CBO.Complex_Vector_Spaces

/-!
# Complex_Vector_Spaces — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Vector_Spaces

export CATEPTPluginDomainQuantum.CBO.Complex_Vector_Spaces (
  StrongOpConverge
  cboNeumann
  cboNeumann_spec
  cboOp_norm_complete
  norm_implies_strong
)

end CATEPTMain.Quantum.CBO.Complex_Vector_Spaces
