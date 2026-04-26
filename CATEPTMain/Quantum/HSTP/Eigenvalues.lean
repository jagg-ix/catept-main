import CATEPTMain.Quantum.HSTP.Misc_TP_TTS
import CATEPTPluginDomainQuantum.HSTP.Eigenvalues

/-!
# Eigenvalues — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Eigenvalues

export CATEPTPluginDomainQuantum.HSTP.Eigenvalues (
  IsHSTPCompact
  IsHSTPEigenvalue
  compact_selfadj_eigenbasis
)

end CATEPTMain.Quantum.HSTP.Eigenvalues
