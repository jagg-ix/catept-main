import CATEPTMain.Geometry.MINK.MINKPrelude
import CATEPTMain.Geometry.MINK.Convex_Body
import CATEPTMain.Geometry.MINK.Lattice_Points
import CATEPTPluginDomainGeometry.MINK.Minkowski_Main

/-!
# Minkowski_Main — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.MINK.Minkowski_Main

export CATEPTPluginDomainGeometry.MINK.Minkowski_Main (
  dirichlet_simultaneous
  minkowski_compact
  minkowski_four_square_ball
  minkowski_general_lattice
  minkowski_open_ge
)

end CATEPTMain.Geometry.MINK.Minkowski_Main
