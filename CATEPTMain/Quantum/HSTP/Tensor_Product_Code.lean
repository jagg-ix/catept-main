import CATEPTMain.Quantum.HSTP.Von_Neumann_Algebras
import CATEPTPluginDomainQuantum.HSTP.Tensor_Product_Code

/-!
# Tensor_Product_Code — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Tensor_Product_Code

export CATEPTPluginDomainQuantum.HSTP.Tensor_Product_Code (
  HasEntanglementWitness
  hstpOpTensor_kronecker
  hstpOpTensor_norm_computable
  hstpPair_norm
  separable_no_witness
)

end CATEPTMain.Quantum.HSTP.Tensor_Product_Code
