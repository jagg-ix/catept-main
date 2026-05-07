import CATEPTPluginDomainGeometry.GYR.GYRPrelude

/-!
# GYRPrelude — re-export shim
Authoritative source: `CATEPTPluginDomainGeometry.GYR.GYRPrelude` in sibling
[`jagg-ix/catept-domain-geometry`](https://github.com/jagg-ix/catept-domain-geometry).
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.GYR

export CATEPTPluginDomainGeometry.GYR (
  GyroCarrier
  einsteinAdd
  einsteinAdd_norm_lt_one
  gyroAdd
  gyroAdd_left_assoc
  gyroAdd_left_id
  gyroAdd_left_inv
  gyroAut
  gyroAut_homo
  gyroAut_inv
  gyroAut_left_loop
  gyroLine
  gyroNeg
  gyroNorm
  gyroNorm_gyroAut
  gyroNorm_nonneg
  gyroNorm_zero_iff
  gyroSmul
  gyroSmul_colinear_trivial
  gyroSmul_gyroAut
  gyroSmul_one
  gyroZero
  mobiusAdd
  mobiusAdd_norm_lt_one
  mobiusGyr
  mobiusGyr_isometry
)

end CATEPTMain.Geometry.GYR
