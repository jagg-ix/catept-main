import CATEPTMain.Geometry.QUAT.QUATPrelude
import CATEPTPluginDomainGeometry.OCT.OCTPrelude

/-!
# OCTPrelude — re-export shim
Authoritative source: `CATEPTPluginDomainGeometry.OCT.OCTPrelude`.
Cross-bundle dep on QUAT.QUATPrelude in the same umbrella.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.OCT

export CATEPTPluginDomainGeometry.OCT (
  OctonionR
  octAdd
  octAdd_comm
  octAdd_neg
  octAdd_zero
  octBasis
  octBasis_zero_eq_one
  octConj
  octConj_conj
  octConj_mul
  octMul
  octMul_add_left
  octMul_smul_left
  octNeg
  octNorm
  octNorm_mul
  octNorm_nonneg
  octNorm_smul
  octNorm_zero_iff
  octPair
  octSmul
  octZero
)

end CATEPTMain.Geometry.OCT
