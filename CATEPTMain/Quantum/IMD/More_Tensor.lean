import CATEPTMain.Quantum.IMD.Tensor
import CATEPTPluginDomainQuantum.IMD.More_Tensor

/-!
# More_Tensor — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.More_Tensor

export CATEPTPluginDomainQuantum.IMD.More_Tensor (
  id_tensor_gate_action
  tensorPow
  tensorPow_dimCol
  tensorPow_dimRow
  tensorPow_succ
  tensorPow_succ_def
  tensorPow_unitary
  tensorPow_zero
  tensorPow_zero_def
  tensorWithIdLeft
  tensorWithIdLeft_dimRow
  tensorWithIdRight
  tensorWithIdRight_dimRow
)

end CATEPTMain.Quantum.IMD.More_Tensor
