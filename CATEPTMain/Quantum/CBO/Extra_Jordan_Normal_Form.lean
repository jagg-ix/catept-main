import CATEPTMain.Quantum.CBO.Complex_L2
import CATEPTPluginDomainQuantum.CBO.Extra_Jordan_Normal_Form

/-!
# Extra_Jordan_Normal_Form — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_Jordan_Normal_Form

export CATEPTPluginDomainQuantum.CBO.Extra_Jordan_Normal_Form (
  charPoly_degree_n
  eigenspace
  hermitian_eigenspaces_ortho
  rankOne_unit_projector_bridge
  spectralDecomp_finite
)

end CATEPTMain.Quantum.CBO.Extra_Jordan_Normal_Form
