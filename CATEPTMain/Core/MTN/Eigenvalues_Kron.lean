import CATEPTMain.Core.MTN.MTNPrelude
import CATEPTMain.Core.MTN.Kronecker_Product
import CATEPTMain.Core.MTN.Mixed_Product
import CATEPTPluginDomainMtn.Eigenvalues_Kron

/-!
# Eigenvalues_Kron — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Core.MTN.Eigenvalues_Kron

export CATEPTPluginDomainMtn.Eigenvalues_Kron (
  IsPosDef
  kronecker_eigenvector
  kronecker_id_eigenvalue
  kronecker_posdef
  kronecker_spectrum
)

end CATEPTMain.Core.MTN.Eigenvalues_Kron
