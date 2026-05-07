import CATEPTMain.Quantum.IMD.Entanglement
import CATEPTMain.Quantum.IMD.Measurement
import CATEPTPluginDomainQuantum.IMD.Quantum_Prisoners_Dilemma

/-!
# Quantum_Prisoners_Dilemma — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Quantum_Prisoners_Dilemma

export CATEPTPluginDomainQuantum.IMD.Quantum_Prisoners_Dilemma (
  D_gate
  D_gate_dimCol
  D_gate_dimRow
  D_gate_unitary
  J_gate
  J_gate_dimCol
  J_gate_dimRow
  J_gate_half_pi_entangling
  J_gate_unitary
  J_gate_zero
  Q_is_nash_equilibrium
  classicPayoff_Alice
  cooperate
  defect
  ewlFinalState
  init_00
  init_00_dim
  init_00_index_0
  init_00_index_k
  init_00_norm
  quantumPayoff
  quantum_beats_classical_defect
  stratQ
  su2_strategy
  su2_strategy_dimCol
  su2_strategy_dimRow
  su2_strategy_unitary
)

end CATEPTMain.Quantum.IMD.Quantum_Prisoners_Dilemma
