import NavierStokes.Galerkin.NSGalerkinConvectionCore

/-!
# NSGalerkinConvectionInterface

Minimal interface for the Stage-163 abstract Galerkin convection operator.
-/

namespace NavierStokes.GalerkinConvection

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel

/-- Abstract Galerkin-truncated bilinear convection operator:
    `(basis : GalerkinBasis N) → CoeffC N → CoeffC N → CoeffC N`.

    Kept as an axiom at the interface layer while downstream modules provide
    concrete definitional bridges and theorem transport. -/
axiom galerkinConvection {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) : CoeffC N

end NavierStokes.GalerkinConvection

