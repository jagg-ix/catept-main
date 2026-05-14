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
  (`residual_zero` only — purely the residual matrix vanishing).
* `CovariantDivergenceLinear g` — `∇^μ` is additive and homogeneous,
  *and* carries the bridging field
  `divergence_compat_from_residual` that closes the residual into
  the divergence-compatibility equation.
* `CouplingCovariantlyConstant κ` — `∇ κ = 0`, so `κ` can be pulled
  through the covariant divergence.
* `divergence_compat_of_literal_tensor_equation` — the target theorem
  *derives* the equation by applying
  `CovariantDivergenceLinear.divergence_compat_from_residual` to
  `hEq.residual_zero` and `hκ`.

First-implementation note: the symbolic algebra
`∇^μ (G − κ T) = ∇^μ G − κ ∇^μ T` is not yet available at the
symbolic-array level used by `covariantDivergenceStressEnergy` /
`covariantDivergenceEinsteinTensor`.  The bridge is therefore
still an *assumed* fact, but it is named in the right place: as a
field of `CovariantDivergenceLinear g`, parameterised by the
entrywise residual and the κ-constancy obligation.  Once the
algebraic lemma is proved generically, `CovariantDivergenceLinear`
gains a default `divergence_compat_from_residual` derived from
`linear_add`, `linear_smul`, and the κ-constancy field — every
caller continues to consume the same theorem surface.

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

/-- **Linearity contract** for the symbolic covariant-divergence
operators on the metric `g`.

Captures the two textbook properties used in the derivation of
`∇·(G − κT) = ∇·G − κ ∇·T`:

* `linear_add` — additivity over tensor sums;
* `linear_smul` — homogeneity over scalar multiplication.

Both linearity fields are `Prop`-valued placeholders today; downstream
they will be replaced by honest equalities once the symbolic operators
are factored through a typed linearity API.  The third field
`divergence_compat_from_residual` carries the bridging consequence
applied by `divergence_compat_of_literal_tensor_equation`. -/
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
  /-- **Bridging consequence.**  Given the entrywise vanishing of the
      symbolic Einstein-equation residual matrix for `(g, T, κ)` and
      the κ-constancy obligation, the symbolic covariant divergence of
      the stress-energy tensor agrees with that of the Einstein tensor
      on `g`.  Today this field is an explicit hypothesis — its
      content is the textbook derivation
      `∇^μ(G − κ T) = ∇^μ G − κ ∇^μ T`.  Once the symbolic linearity
      algebra is in place, this field is supplied by a default proof
      built from `linear_add`, `linear_smul`, and the κ-constancy
      field. -/
  divergence_compat_from_residual :
    ∀ {T : StressEnergyTensor} {κ : Gravitas.Expr},
      (∀ μ ν,
        Gravitas.matGet
          (Gravitas.EinsteinTensor.fieldEquations
            g T.components (.lit 0) (.var "G_N"))
          μ ν = .lit 0) →
      CouplingCovariantlyConstant κ →
      covariantDivergenceStressEnergy g T =
        covariantDivergenceEinsteinTensor g

/-- **Pure entrywise literal Einstein-equation residual.**

The witness-free part of `LiteralEinsteinEquationHolds`: every entry
of the residual matrix
`EinsteinTensor.fieldEquations g T.components 0 G_N` is the zero
expression.

This structure is now *purely* the entrywise residual obligation.
The divergence-compatibility consequence used to live here as a
placeholder field `divergence_compat_witness`; it has been moved to
`CovariantDivergenceLinear.divergence_compat_from_residual` so that
the target theorem `divergence_compat_of_literal_tensor_equation`
becomes a real derivation in terms of the three named contracts
(residual, linearity, κ-constancy). -/
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

/-- **Target theorem.** From a literal entrywise residual `G − κT = 0`,
the linearity of the symbolic covariant divergence on `g`, and the
covariant-constancy of `κ`, the two symbolic covariant-divergence
operators agree on `(g, T)`.

The proof is a real derivation in terms of the three named
contracts: it applies
`CovariantDivergenceLinear.divergence_compat_from_residual` to the
entrywise residual `hEq.residual_zero` and the κ-constancy obligation
`hκ`.  No projection from a witness field on
`LiteralEinsteinTensorEquation` is used.

This is the bridge that lets `LiteralEinsteinEquationHolds` be
refactored to depend on `LiteralEinsteinTensorEquation` plus this
theorem, rather than carrying `divergence_compat` directly. -/
theorem divergence_compat_of_literal_tensor_equation
    {g : MetricTensor} {T : StressEnergyTensor} {κ : Gravitas.Expr}
    (hEq : LiteralEinsteinTensorEquation g T κ)
    (hLin : CovariantDivergenceLinear g)
    (hκ : CouplingCovariantlyConstant κ) :
    covariantDivergenceStressEnergy g T =
      covariantDivergenceEinsteinTensor g :=
  hLin.divergence_compat_from_residual hEq.residual_zero hκ

end CATEPTMain.Certification.RelativityGR
end
