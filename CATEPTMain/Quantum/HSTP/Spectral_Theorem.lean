import CATEPTMain.Quantum.HSTP.Compact_Operators
import CATEPTPluginDomainQuantum.HSTP.Spectral_Theorem

/-!
# Spectral_Theorem — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Spectral_Theorem

export CATEPTPluginDomainQuantum.HSTP.Spectral_Theorem (
  IsHSTPSpectralMeasure
  hstpFuncCalc
  hstpFuncCalc_id
  hstpFuncCalc_mul
  hstpSpectralMeasure_exists
  spectral_theorem
)

end CATEPTMain.Quantum.HSTP.Spectral_Theorem
