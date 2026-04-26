import CATEPTMain.Quantum.HSTP.HSTPPrelude
import CATEPTPluginDomainQuantum.HSTP.Misc_TP

/-!
# Misc_TP — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Misc_TP

export CATEPTPluginDomainQuantum.HSTP.Misc_TP (
  hstpAssoc_exists
  hstpInner_antilinear_left
  hstpInner_linear_right
  hstpPair_dense
)

end CATEPTMain.Quantum.HSTP.Misc_TP
