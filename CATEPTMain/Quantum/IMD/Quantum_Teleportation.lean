import CATEPTMain.Quantum.IMD.Entanglement
import CATEPTPluginDomainQuantum.IMD.Quantum_Teleportation

/-!
# Quantum_Teleportation — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Quantum_Teleportation

export CATEPTPluginDomainQuantum.IMD.Quantum_Teleportation (
  aliceCircuit
  aliceCircuit_dimCol
  aliceCircuit_dimRow
  aliceCircuit_unitary
  bobCorrection
  bobCorrection_dimRow
  bobCorrection_unitary
  quantum_teleportation_correct
  teleportInitState
  teleportInitState_dim
  teleportation_fidelity_one
)

end CATEPTMain.Quantum.IMD.Quantum_Teleportation
