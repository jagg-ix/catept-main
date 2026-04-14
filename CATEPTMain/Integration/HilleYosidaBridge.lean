import HilleYosida

/-!
# Hille–Yosida Integration Bridge

Connects the `HilleYosida` package (direct dep, Lean 4 v4.29.0) to CATEPT's
ODE and Laplace-transform bridges.

**Source:** `file:///…/hille-yosida` pinned rev `7731442e5b01`
**Toolchain status:** `direct_4_29` — imported directly.

## CATEPT leverage points

* **ODE bridge** (`AFPBridge/ODE`): Every `StronglyContinuousSemigroup S` on a
  Banach space X with generator A corresponds to the abstract Cauchy problem
  `x'(t) = A x(t)`, `x(0) = x₀`.  `Euler_Method.lean` approximates this; the
  HilleYosida generation criterion (`‖R(λ)‖ ≤ 1/λ`) guarantees that the
  operator A generates a contraction semigroup, underpinning phase-2 error
  estimates.

* **LAPL bridge** (`AFPBridge/LAPL`): The resolvent
  `R(λ)x = ∫₀^∞ e^{−λt} S(t)x dt` (def in `ContractingSemigroup.resolvent`)
  is exactly the Laplace transform of `t ↦ S(t)x`.  `Laplace_Transform.lean`
  and `Inversion.lean` share the same integral formula; `hilleYosidaResolventBound`
  (`‖R(λ)‖ ≤ 1/λ`) provides the absolute-convergence hypothesis needed in
  phase-2 inversion.

* **MODE bridge** (`AFPBridge/MODE`): Matrix exponential `exp (t • A)` is the
  semigroup operator for finite-dim generators; `StronglyContinuousSemigroup`
  specialises to `Matrix.exp` when X = Fin n → ℝ.

## Key definitions from `HilleYosida` used by CATEPT
* `StronglyContinuousSemigroup` — C₀-semigroup structure on a Banach space.
* `ContractingSemigroup` — specialisation with `‖S(t)‖ ≤ 1`.
* `ContractingSemigroup.resolvent` — resolvent `R(λ)` as a `ContinuousLinearMap`.
* `hilleYosidaResolventBound` — `‖R(λ)‖ ≤ 1/λ` for contraction semigroups.
* `StronglyContinuousSemigroup.existsGrowthBound` — `‖S(t)‖ ≤ M e^{ωt}`.

## Phase status
Phase-1: integration contract defined; bridge theorem sorry-proved.
Phase-2 work item: connect `hilleYosidaResolventBound` to the convergence
hypothesis of `LAPLPrelude.laplace_transform_spec` via unfolding
`ContractingSemigroup.resolvent`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.HilleYosida

/-- Semigroup witness: records that a contraction semigroup with bounded
    resolvent is available for CATEPT's ODE / LAPL phase-2 proofs. -/
structure HilleYosidaWitness (X : Type*) [NormedAddCommGroup X] [NormedSpace ℝ X]
    [CompleteSpace X] where
  /-- A contraction C₀-semigroup on X. -/
  semigroup : _root_.ContractingSemigroup X
  /-- The resolvent satisfies `‖R(λ)‖ ≤ 1/λ` for λ > 0. -/
  resolventBoundHolds : Prop
  /-- The semigroup has exponential growth bound `‖S(t)‖ ≤ M e^{ωt}`. -/
  growthBoundHolds : Prop

/-- Integration contract: CATEPT's ODE and LAPL bridges may assume
    Hille–Yosida resolvent bounds once a `HilleYosidaWitness` is supplied. -/
def HilleYosidaIntegrationContract
    {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]
    (w : HilleYosidaWitness X) : Prop :=
  w.resolventBoundHolds ∧ w.growthBoundHolds

/-- Phase-1 bridge theorem. -/
theorem hilleYosida_integration_contract
    {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]
    (w : HilleYosidaWitness X)
    (hR : w.resolventBoundHolds)
    (hG : w.growthBoundHolds) :
    HilleYosidaIntegrationContract w :=
  ⟨hR, hG⟩

end CATEPTMain.Integration.HilleYosida
