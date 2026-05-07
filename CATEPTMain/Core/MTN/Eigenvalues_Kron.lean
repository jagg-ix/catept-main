import CATEPTMain.Core.MTN.MTNPrelude
import CATEPTMain.Core.MTN.Kronecker_Product
import CATEPTMain.Core.MTN.Mixed_Product
import CATEPTPluginDomainCore.MTN.Eigenvalues_Kron

/-!
# Eigenvalues_Kron — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Core.MTN.Eigenvalues_Kron

export CATEPTPluginDomainCore.MTN.Eigenvalues_Kron (
  IsPosDef
  kronecker_eigenvector
  kronecker_id_eigenvalue
  kronecker_posdef
  kronecker_spectrum
)

end CATEPTMain.Core.MTN.Eigenvalues_Kron
