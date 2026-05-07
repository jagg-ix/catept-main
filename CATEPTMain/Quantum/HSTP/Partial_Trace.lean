import CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product
import CATEPTPluginDomainQuantum.HSTP.Partial_Trace

/-!
# Partial_Trace — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Partial_Trace

export CATEPTPluginDomainQuantum.HSTP.Partial_Trace (
  partialTrace_add
  partialTrace_density
  partialTrace_positive
  partialTrace_tensor
  partialTrace_tensor'
)

end CATEPTMain.Quantum.HSTP.Partial_Trace
