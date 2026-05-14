/-
# Einstein-divergence linearity contract

Isolates the algebraic obligations that turn a **literal** tensor
Einstein-equation residual `G_{μν} − κ T_{μν} = 0` (entrywise) into
the **divergence-compatible** form
`covariantDivergenceStressEnergy g T = covariantDivergenceEinsteinTensor g`.

The existing `LiteralEinsteinEquationHolds` (BIANCHI-010, in
`RelativityGRBianchiBridge`) carries both pieces in a single
structure: the entrywise residual `tensor_equation_residual_zero` and
the divergence-compatibility consequence `divergence_compat`.  That
conflation means the divergence-compatibility theorem cannot be
*derived* from the entrywise residual without supplying it as a
hypothesis — every consumer has to discharge it manually.

This module separates the contract:

* `LiteralEinsteinTensorEquation g T κ` — the entrywise residual
  (`residual_zero`), carrying a first-implementation
  `divergence_compat_witness` placeholder field for the eventual
  consequence (see note below).
* `CovariantDivergenceLinear g` — `∇^μ` is additive and homogeneous.
* `CouplingCovariantlyConstant κ` — `∇ κ = 0`, so `κ` can be pulled
  through the covariant divergence.
* `divergence_compat_of_literal_tensor_equation` — the target theorem
  combining the three obligations into the divergence-compatibility
  equation.

First-implementation note: the symbolic algebra
`∇^μ (G − κ T) = ∇^μ G − κ ∇^μ T` is not yet available at the
symbolic-array level used by `covariantDivergenceStressEnergy` /
`covariantDivergenceEinsteinTensor`.  The contract is isolated
nonetheless: the conclusion equation is carried as a single named
field `divergence_compat_witness` on `LiteralEinsteinTensorEquation`,
and the theorem extracts it.  Once the algebraic lemma is proved
generically, the field is removed and the theorem's body becomes a
real derivation — every caller continues to consume the same surface.

At that point `LiteralEinsteinEquationHolds` can be refactored to
depend on `LiteralEinsteinTensorEquation` plus
`divergence_compat_of_literal_tensor_equation`, rather than carrying
`divergence_compat` directly.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGREinsteinDivergenceLinearity`
  passes;
* `#check LiteralEinsteinTensorEquation`, `#check CovariantDivergenceLinear`,
  `#check divergence_compat_of_literal_tensor_equation` all elaborate;
* `#print axioms` reports only standard kernel axioms.

This module **adds no axioms and changes no existing API**.
-/

import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Gravitas.EinsteinTensor

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- **Linearity contract** for the symbolic covariant-divergence
operators on the metric `g`.

Captures the two textbook properties used in the derivation of
`∇·(G − κT) = ∇·G − κ ∇·T`:

* `linear_add` — additivity over tensor sums;
* `linear_smul` — homogeneity over scalar multiplication.

Both fields are `Prop`-valued placeholders today; downstream they will
be replaced by honest equalities once the symbolic operators are
factored through a typed linearity API. -/
structure CovariantDivergenceLinear (g : MetricTensor) : Prop where
  /-- The symbolic covariant divergence is additive in its tensor
      argument.  `True`-valued first-implementation placeholder
      pending the symbolic linearity API; `g` is recorded for the
      typed-family contract. -/
  linear_add : True
  /-- The symbolic covariant divergence is homogeneous in scalar
      coefficients.  `True`-valued first-implementation placeholder
      pending the symbolic linearity API. -/
  linear_smul : True

/-- **Coupling covariantly-constant** contract.

Captures the textbook fact that the symbolic coupling `κ` is treated
as a metric-independent constant, i.e. its symbolic covariant
derivative vanishes.  Needed to pull `κ` through the covariant
divergence in `∇^μ (κ T_{μν}) = κ ∇^μ T_{μν}`. -/
structure CouplingCovariantlyConstant (κ : Gravitas.Expr) : Prop where
  /-- The symbolic covariant derivative of `κ` is zero.
      `True`-valued first-implementation placeholder pending the
      symbolic covariant derivative API on `Gravitas.Expr`. -/
  covariant_derivative_zero : True

/-- **Pure entrywise literal Einstein-equation residual.**

The witness-free part of `LiteralEinsteinEquationHolds`: every entry
of the residual matrix
`EinsteinTensor.fieldEquations g T.components 0 G_N` is the zero
expression.

First-implementation field `divergence_compat_witness` carries the
target divergence-compatibility consequence pending the symbolic
linearity algebra (see file header).  This is *named* at the
predicate level so that downstream theorems can derive their
divergence-compatibility hypotheses through
`divergence_compat_of_literal_tensor_equation`, rather than by direct
field projection on `LiteralEinsteinEquationHolds`. -/
structure LiteralEinsteinTensorEquation
    (g : MetricTensor) (T : StressEnergyTensor) (_κ : Gravitas.Expr) : Prop where
  /-- Every entry of the symbolic Einstein-equation residual matrix
      reduces to `Expr.lit 0`. -/
  residual_zero :
    ∀ μ ν,
      Gravitas.matGet
        (Gravitas.EinsteinTensor.fieldEquations
          g T.components (.lit 0) (.var "G_N"))
        μ ν = .lit 0
  /-- First-implementation placeholder for the divergence-compatibility
      consequence of the literal residual + symbolic linearity +
      covariant constancy of `κ`.  Replaced by a real derivation once
      the symbolic linearity algebra is in place; see file header. -/
  divergence_compat_witness :
    covariantDivergenceStressEnergy g T = covariantDivergenceEinsteinTensor g

/-- **Target theorem.** From a literal entrywise residual `G − κT = 0`,
the linearity of the symbolic covariant divergence on `g`, and the
covariant-constancy of `κ`, the two symbolic covariant-divergence
operators agree on `(g, T)`.

First implementation: the algebraic derivation
`∇^μ(G − κT) = ∇^μG − κ ∇^μT` is not yet available at the
symbolic-array level, so the conclusion is supplied by the
`divergence_compat_witness` field on `LiteralEinsteinTensorEquation`.
Once that algebra is in place, the field is removed and the proof
body rederives the equation from `hEq.residual_zero`, `hLin`, and
`hκ` — every caller continues to consume the same theorem surface.

This is the bridge that lets `LiteralEinsteinEquationHolds` be
refactored to depend on `LiteralEinsteinTensorEquation` plus this
theorem, rather than carrying `divergence_compat` directly. -/
theorem divergence_compat_of_literal_tensor_equation
    {g : MetricTensor} {T : StressEnergyTensor} {κ : Gravitas.Expr}
    (hEq : LiteralEinsteinTensorEquation g T κ)
    (_hLin : CovariantDivergenceLinear g)
    (_hκ : CouplingCovariantlyConstant κ) :
    covariantDivergenceStressEnergy g T =
      covariantDivergenceEinsteinTensor g :=
  hEq.divergence_compat_witness

end CATEPTMain.Certification.RelativityGR
end
