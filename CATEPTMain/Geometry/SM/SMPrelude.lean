import CATEPTPluginDomainGeometry.SM.SMPrelude

/-!
# SMPrelude — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM

export CATEPTPluginDomainGeometry.SM (
  IsDiffeomorphism
  IsSmooth
  SmoothPartUnity
  smModel
  whitney_extension
)

end CATEPTMain.Geometry.SM
