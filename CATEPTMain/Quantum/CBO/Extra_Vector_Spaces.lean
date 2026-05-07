import CATEPTMain.Quantum.CBO.Extra_General
import CATEPTPluginDomainQuantum.CBO.Extra_Vector_Spaces

/-!
# Extra_Vector_Spaces — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_Vector_Spaces

export CATEPTPluginDomainQuantum.CBO.Extra_Vector_Spaces (
  complexDim_eq_half_realDim
  directSum_projections
  linIndep_extend
  span_ortho_closed
)

end CATEPTMain.Quantum.CBO.Extra_Vector_Spaces
