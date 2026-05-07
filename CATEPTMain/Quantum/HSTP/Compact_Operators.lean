import CATEPTMain.Quantum.HSTP.Eigenvalues
import CATEPTPluginDomainQuantum.HSTP.Compact_Operators

/-!
# Compact_Operators — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Compact_Operators

export CATEPTPluginDomainQuantum.HSTP.Compact_Operators (
  IsHSTPFiniteRank
  compact_selfadj_has_eigenvalue
  finiteRank_compact
  hs_compact
  normLim_compact
)

end CATEPTMain.Quantum.HSTP.Compact_Operators
