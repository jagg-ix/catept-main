import CATEPTMain.Quantum.HSTP.Partial_Trace
import CATEPTPluginDomainQuantum.HSTP.Von_Neumann_Algebras

/-!
# Von_Neumann_Algebras — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Von_Neumann_Algebras

export CATEPTPluginDomainQuantum.HSTP.Von_Neumann_Algebras (
  BH_is_vna
  IsVonNeumannAlgebra
  bicommutant
  commutant
)

end CATEPTMain.Quantum.HSTP.Von_Neumann_Algebras
