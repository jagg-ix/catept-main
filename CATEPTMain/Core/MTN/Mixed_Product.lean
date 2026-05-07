import CATEPTMain.Core.MTN.MTNPrelude
import CATEPTMain.Core.MTN.Kronecker_Product
import CATEPTPluginDomainCore.MTN.Mixed_Product

/-!
# Mixed_Product — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Core.MTN.Mixed_Product

export CATEPTPluginDomainCore.MTN.Mixed_Product (
  kronecker_inv
  kronecker_mixed_product
  kronecker_rank
  kronecker_unitary
)

end CATEPTMain.Core.MTN.Mixed_Product
