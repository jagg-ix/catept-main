import CATEPTPluginDomainCore.PDC.PDCPrelude

/-!
# PDCPrelude — re-export shim
Authoritative source: `CATEPTPluginDomainCore.PDC.PDCPrelude` in sibling
[`jagg-ix/catept-domain-core`](https://github.com/jagg-ix/catept-domain-core).
-/

set_option autoImplicit false

namespace CATEPTMain.Core.PDC

export CATEPTPluginDomainCore.PDC (
  PDCLine
  PDCPoint
  onLine
  pdcCrossRatio
  pdcCrossRatio_mobius_invariant
  pdcDist
  pdcDist_comm
  pdcDist_nonneg
  pdcDist_triangle
  pdcDist_zero_iff
  pdcHyperbolicParallel
  pdcLine_unique
  pdcMobius
  pdcMobiusVal
  pdcMobiusVal_lt_one
  pdcMobius_involution
  pdcMobius_isometry
  pdcMobius_sends_to_zero
  pdcOrigin
  pdcParallel
)

end CATEPTMain.Core.PDC
