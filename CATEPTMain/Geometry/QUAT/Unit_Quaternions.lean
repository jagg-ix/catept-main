import CATEPTMain.Geometry.QUAT.QUATPrelude
import CATEPTPluginDomainGeometry.QUAT.Unit_Quaternions

/-!
# Unit_Quaternions — re-export shim
Authoritative source: `CATEPTPluginDomainGeometry.QUAT.Unit_Quaternions`.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.QUAT.Unit_Quaternions

export CATEPTPluginDomainGeometry.QUAT.Unit_Quaternions (
  fromAngleAxis
  fromAngleAxis_unit
  quatRotate
  quatRotate_neg
  quatRotate_norm
  quatRotate_pure
  unitQuat_mul
)

end CATEPTMain.Geometry.QUAT.Unit_Quaternions
