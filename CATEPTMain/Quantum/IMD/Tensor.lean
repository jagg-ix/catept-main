import CATEPTMain.Quantum.IMD.Quantum
import CATEPTPluginDomainQuantum.IMD.Tensor

/-!
# Tensor — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Tensor

export CATEPTPluginDomainQuantum.IMD.Tensor (
  tensorMat_assoc
  tensorMat_dagger
  tensorMat_dimCol_eq
  tensorMat_dimRow_eq
  tensorMat_distrib_left
  tensorMat_distrib_right
  tensorMat_index
  tensorMat_mixed_product
  tensorMat_smul_left
  tensorMat_unitary
)

end CATEPTMain.Quantum.IMD.Tensor
