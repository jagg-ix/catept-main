import CATEPTMain.Geometry.MINK.MINKPrelude
import CATEPTPluginDomainGeometry.MINK.Convex_Body

/-!
# Convex_Body — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.MINK.Convex_Body

export CATEPTPluginDomainGeometry.MINK.Convex_Body (
  minkowski_from_overlap
  period_lattice_overlap
  smul_convexBody_convex
  symm_body_contains_zero
)

end CATEPTMain.Geometry.MINK.Convex_Body
