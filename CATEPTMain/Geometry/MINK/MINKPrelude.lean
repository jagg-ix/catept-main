import CATEPTPluginDomainGeometry.MINK.MINKPrelude

/-!
# MINKPrelude — re-export shim
Authoritative source: `CATEPTPluginDomainGeometry.MINK.MINKPrelude` in
sibling repo [`jagg-ix/catept-domain-geometry`](https://github.com/jagg-ix/catept-domain-geometry).
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.MINK

export CATEPTPluginDomainGeometry.MINK (
  HasFiniteVolume
  IsCentrallySymmetric
  IsConvexBody
  latticePoint
  minkVolume
  minkowski_theorem
  smulConvexBody
  volume_smul_convexBody
)

end CATEPTMain.Geometry.MINK
