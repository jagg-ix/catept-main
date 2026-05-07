import CATEPTMain.Quantum.IMD.Deutsch
import CATEPTMain.Quantum.IMD.Binary_Nat
import CATEPTPluginDomainQuantum.IMD.Deutsch_Jozsa

/-!
# Deutsch_Jozsa — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Deutsch_Jozsa

export CATEPTPluginDomainQuantum.IMD.Deutsch_Jozsa (
  H_n
  H_n_dimCol
  H_n_dimRow
  H_n_uniform
  dj_balanced_output_not_all_zeros
  dj_constant_output_all_zeros
  dj_input
  dj_input_dim
  dj_input_norm
  dj_oracle
  dj_oracle_dimCol
  dj_oracle_dimRow
  dj_oracle_unitary
  dj_output
  dj_output_dim
  isBalancedN
  isConstantN
  zero_n_state
  zero_n_state_dim
  zero_n_state_norm
)

end CATEPTMain.Quantum.IMD.Deutsch_Jozsa
