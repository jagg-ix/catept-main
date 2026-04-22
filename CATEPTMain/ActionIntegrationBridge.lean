import CATEPT.TheoryPluginArchitecture
import QuantumAlgebra.ActionIntegration
import Mathlib.Data.Complex.Basic

namespace CATEPTMain.Integration

open QuantumAlgebra
open QuantumAlgebra.Integration

/--
Integration Bridge: Mapping the QuantumAlgebra VEV 
from `catept-core` into the overarching plugin parameters.

This allows us to evaluate a discrete interaction Lagrangian
V(\phi) = \phi^4 and inject its vacuum trace directly into the 
macroscopic field parameters of the continuous Action functionals.
-/
def compute_phi4_perturbative_correction : ℂ :=
  let idx := Index.name "x"
  vev_phi_4 idx

end CATEPTMain.Integration
