import CATEPTMain.Quantum.HSTP.Trace_Class
import CATEPTPluginDomainQuantum.HSTP.Weak_Star_Topology

/-!
# Weak_Star_Topology — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Weak_Star_Topology

export CATEPTPluginDomainQuantum.HSTP.Weak_Star_Topology (
  HSTPWeakStarConv
  kaplansky_density
  wot_eq_weakstar
)

end CATEPTMain.Quantum.HSTP.Weak_Star_Topology
