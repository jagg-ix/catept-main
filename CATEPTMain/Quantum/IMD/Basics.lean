import CATEPTMain.Quantum.IMD.IMDPrelude
import CATEPTPluginDomainQuantum.IMD.Basics

/-!
# Basics — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Basics

export CATEPTPluginDomainQuantum.IMD.Basics (
  cos_of_quarter_pi
  div_mult_mod_eq_minus
  exp_of_real_cnj
  exp_of_real_im
  exp_of_real_re
  index_div_eq
  index_matrix_prod
  index_mod_eq
  less_power_add_imp_div_less
  neq_imp_neq_div_or_mod
  set_2
  set_4
  set_8
  sin_of_quarter_pi
  sin_squared_le_one
  sum_insert_iff
  sum_of_index_diff
)

end CATEPTMain.Quantum.IMD.Basics
