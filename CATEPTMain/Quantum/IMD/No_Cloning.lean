import CATEPTMain.Quantum.IMD.Measurement
import CATEPTPluginDomainQuantum.IMD.No_Cloning

/-!
# No_Cloning — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.No_Cloning

export CATEPTPluginDomainQuantum.IMD.No_Cloning (
  ancilla_state
  ancilla_state_dim
  ancilla_state_norm
  cloning_inner_product_eq
  isCloner
  no_cloning
  no_cloning_nonorthogonal
)

end CATEPTMain.Quantum.IMD.No_Cloning
