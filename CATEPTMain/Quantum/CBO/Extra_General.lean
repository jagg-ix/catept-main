import CATEPTMain.Quantum.CBO.CBOPrelude
import CATEPTPluginDomainQuantum.CBO.Extra_General

/-!
# Extra_General — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_General

export CATEPTPluginDomainQuantum.CBO.Extra_General (
  cont_of_uniform_limit
  norm_sum_le_finset
  sSup_le_of_forall
  seq_compact_of_bounded_norm
  summable_telescoping
)

end CATEPTMain.Quantum.CBO.Extra_General
