import CATEPTMain.Quantum.HSTP.Weak_Operator_Topology
import CATEPTPluginDomainQuantum.HSTP.Misc_TP_TTS

/-!
# Misc_TP_TTS — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Misc_TP_TTS

export CATEPTPluginDomainQuantum.HSTP.Misc_TP_TTS (
  hstpInner_continuous_fst
  hstpPair_dense_transfer
  hstpPair_totalSpan
)

end CATEPTMain.Quantum.HSTP.Misc_TP_TTS
