import CATEPTMain.Quantum.CBO.Complex_Inner_Product0
import CATEPTPluginDomainQuantum.CBO.Complex_Inner_Product

/-!
# Complex_Inner_Product — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Inner_Product

export CATEPTPluginDomainQuantum.CBO.Complex_Inner_Product (
  IsONSeq
  hilbert_direct_sum
  parseval_hilbert
  riesz_representation
)

end CATEPTMain.Quantum.CBO.Complex_Inner_Product
