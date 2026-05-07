import CATEPTMain.Quantum.PM.Projective_Measurements
import CATEPTPluginDomainQuantum.PM.CHSH_Inequality

/-!
# CHSH_Inequality — re-export shim (sub-bundle `PM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.PM.CHSH_Inequality

export CATEPTPluginDomainQuantum.PM.CHSH_Inequality (
  bellDensity
  chshA
  chshA'
  chshA'_dichotomic
  chshA_dichotomic
  chshB
  chshB'
  chshB'_dichotomic
  chshB_dichotomic
  chshExpect
  chsh_bell_achieves_tsirelson
  chsh_classical_bound
  chsh_quantum_bound
  chsh_quantum_exceeds_classical
)

end CATEPTMain.Quantum.PM.CHSH_Inequality
