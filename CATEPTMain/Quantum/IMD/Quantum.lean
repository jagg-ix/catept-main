import CATEPTMain.Quantum.IMD.IMDPrelude
import CATEPTPluginDomainQuantum.IMD.Quantum

/-!
# Quantum — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Quantum

export CATEPTPluginDomainQuantum.IMD.Quantum (
  CNOT_gate_00
  CNOT_gate_11
  CNOT_gate_23
  CNOT_gate_32
  CNOT_gate_zero
  H_gate_index_real
  H_gate_involutory
  SWAP_gate
  SWAP_gate_dimCol
  SWAP_gate_dimRow
  SWAP_gate_involutory
  SWAP_gate_involutory_law
  SWAP_gate_square
  SWAP_gate_unitary
  X_gate_involutory
  X_times_Z
  Y_gate_involutory
  Z_gate_involutory
  bell00_state
  bell01_state
  bell10_state
  bell11_state
  gate_preserves_state
  innerProd_tensorVec
  phaseFactor
  phaseFactor_norm
  state_qbit_dim
  state_qbit_norm
  tensorVec
  tensorVec_dimVec
  tensorVec_norm_mul
  tensorVec_state
  unitaryMat_pow
  unitary_iff_dagger_inv
)

end CATEPTMain.Quantum.IMD.Quantum
