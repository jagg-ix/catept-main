import CATEPTMain.Quantum.HSTP.Weak_Star_Topology
import CATEPTPluginDomainQuantum.HSTP.Hilbert_Space_Tensor_Product

/-!
# Hilbert_Space_Tensor_Product — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product

export CATEPTPluginDomainQuantum.HSTP.Hilbert_Space_Tensor_Product (
  IsEntangled
  IsSeparable
  hstpOpTensor_unitary
  hstpUniversal
  schmidt1_iff_separable
)

end CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product
