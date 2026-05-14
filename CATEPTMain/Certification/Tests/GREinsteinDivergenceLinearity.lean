/-
# Tests — Einstein-divergence linearity contract

Smoke `#check`s for the new module isolating the algebraic obligations
that turn a literal entrywise Einstein-equation residual into the
divergence-compatibility equation consumed by
`LiteralEinsteinEquationHolds`.
-/

import CATEPTMain.Certification.RelativityGREinsteinDivergenceLinearity

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GREinsteinDivergenceLinearity

open CATEPTMain.Certification.RelativityGR

#check LiteralEinsteinTensorEquation
#check CovariantDivergenceLinear
#check CouplingCovariantlyConstant
#check divergence_compat_of_literal_tensor_equation

end CATEPTMain.Certification.Tests.GREinsteinDivergenceLinearity

end
