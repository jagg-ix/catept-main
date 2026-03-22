import NavierStokes.NSGalerkinConvectionCore

/-!
# NSGalerkinConvectionInterface

Concrete interface for the Galerkin convection operator.
-/

namespace NavierStokes.GalerkinConvection

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel

/-- Local complex multiplication helper:
    `(a+bi)(c+di) = (ac-bd, ad+bc)`. -/
def crMul (z w : CRat) : CRat :=
  (z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re)

/-- Concrete Galerkin-truncated bilinear convection operator:
    `(basis : GalerkinBasis N) → CoeffC N → CoeffC N → CoeffC N`. -/
noncomputable def galerkinConvection {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) : CoeffC N :=
  fun k =>
    ∑ j : Fin N, ∑ l : Fin N, CRat.smul (basis.triadK k j l) (crMul (u j) (v l))

end NavierStokes.GalerkinConvection
