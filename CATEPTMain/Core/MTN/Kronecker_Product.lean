import CATEPTMain.Core.MTN.MTNPrelude
import CATEPTPluginDomainMtn.Kronecker_Product

/-!
# Kronecker_Product — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Core.MTN.Kronecker_Product

export CATEPTPluginDomainMtn.Kronecker_Product (
  kronecker_add_left
  kronecker_add_right
  kronecker_diagonal
  kronecker_vec_identity
  kronecker_zero_left
  kronecker_zero_right
)

end CATEPTMain.Core.MTN.Kronecker_Product
