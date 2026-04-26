import CATEPTMain.Quantum.PM.PMPrelude
import CATEPTPluginDomainQuantum.PM.Linear_Algebra_Complements

/-!
# Linear_Algebra_Complements — re-export shim (sub-bundle `PM`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.PM.Linear_Algebra_Complements

export CATEPTPluginDomainQuantum.PM.Linear_Algebra_Complements (
  SpectralDecomp
  hermitian_eigenvalues_real
  projector_complement
  projector_eigenvalues
  projector_iff
  projector_ortho
  projectors_orthogonal_iff
)

end CATEPTMain.Quantum.PM.Linear_Algebra_Complements
