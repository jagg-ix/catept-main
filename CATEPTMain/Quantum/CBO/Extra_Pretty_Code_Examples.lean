import CATEPTMain.Quantum.CBO.Extra_Operator_Norm
import CATEPTPluginDomainQuantum.CBO.Extra_Pretty_Code_Examples

/-!
# Extra_Pretty_Code_Examples — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples

export CATEPTPluginDomainQuantum.CBO.Extra_Pretty_Code_Examples (
  cboInner_self_of_unit
  cboSmul_one_op
  cboVecNorm
  cboVecNorm_nonneg
  rankOneOp
  rankOneOp_adj
  rankOneOp_apply
  rankOneOp_comp
  rankOneOp_idempotent
  rankOneOp_norm
  rankOneOp_projector
)

end CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples
