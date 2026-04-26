import CATEPTMain.Quantum.IMD.More_Tensor
import CATEPTMain.Quantum.IMD.Measurement
import CATEPTPluginDomainQuantum.IMD.Deutsch

/-!
# Deutsch — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Deutsch

export CATEPTPluginDomainQuantum.IMD.Deutsch (
  deutsch_correct_balanced
  deutsch_correct_constant
  deutsch_input
  deutsch_input_00
  deutsch_input_01
  deutsch_input_dim
  deutsch_input_norm
  deutsch_oracle
  deutsch_oracle_dimCol
  deutsch_oracle_dimRow
  deutsch_oracle_unitary
  deutsch_oracle_xor
  deutsch_output
  deutsch_output_dim
  isBalanced
  isConstant
)

end CATEPTMain.Quantum.IMD.Deutsch
