import CATEPTMain.Quantum.IMD.IMDPrelude
import CATEPTPluginDomainQuantum.IMD.Binary_Nat

/-!
# Binary_Nat — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Binary_Nat

export CATEPTPluginDomainQuantum.IMD.Binary_Nat (
  binRep_all_ones
  binRep_completeness
  binRep_elem_binary
  binRep_length
  binRep_nth
  binRep_sum_mod
  binRep_zero
  binRep_zero_len
)

end CATEPTMain.Quantum.IMD.Binary_Nat
