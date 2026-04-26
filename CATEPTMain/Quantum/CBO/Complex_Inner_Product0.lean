import CATEPTMain.Quantum.CBO.Complex_Vector_Spaces
import CATEPTPluginDomainQuantum.CBO.Complex_Inner_Product0

/-!
# Complex_Inner_Product0 — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Inner_Product0

export CATEPTPluginDomainQuantum.CBO.Complex_Inner_Product0 (
  cauchy_schwarz
  ortho_ortho_eq_closure
  ortho_projection_exists
  polarization_identity
)

end CATEPTMain.Quantum.CBO.Complex_Inner_Product0
