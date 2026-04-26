import CATEPTPluginDomainQuantum.CBO.CBOPrelude

/-!
# CBOPrelude — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO

export CATEPTPluginDomainQuantum.CBO (
  BLTExtend
  CBOHilbert
  CBOLoewner
  CBOOp
  CBOVec
  Ell2Space
  IsCBOProjector
  IsCBOUnitary
  IsHS
  IsHermitian
  IsPositive
  IsTraceClass
  cblinfunToMatrix
  cblinfunToMatrix_roundtrip
  cboAdd
  cboAdj
  cboAdj_add
  cboAdj_adj
  cboAdj_comp
  cboAdj_smul
  cboApply
  cboComp
  cboHSInner
  cboHSInner_adj
  cboInner
  cboInner_pos_re
  cboNorm
  cboNorm_comp_le
  cboNorm_nonneg
  cboNorm_smul
  cboNorm_triangle
  cboNorm_zero_iff
  cboOne
  cboSmul
  cboTrace
  cboTrace_adj
  cboTrace_comp_comm
  cboZero
  isTraceClass_of_isHS
  matrixToCblinfun
  matrixToCblinfun_adjoint
  rieszRep
  rieszRep_spec
)

end CATEPTMain.Quantum.CBO
