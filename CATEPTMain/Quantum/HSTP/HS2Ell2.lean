import CATEPTMain.Quantum.HSTP.Positive_Operators
import CATEPTPluginDomainQuantum.HSTP.HS2Ell2

/-!
# HS2Ell2 — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.HS2Ell2

export CATEPTPluginDomainQuantum.HSTP.HS2Ell2 (
  IsHilbertSchmidt
  hs_norm_complete
  hstpHSNorm
  hstpHSNorm_nonneg
  schmidt_decomp
  schmidt_rank1_iff_pure
)

end CATEPTMain.Quantum.HSTP.HS2Ell2
