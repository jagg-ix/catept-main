import NavierStokes.PDEInterfaces

/-!
# Navier-Stokes Bridge Decomposition

Decomposes forward/backward bridge obligations into explicit intermediate
assumptions so the logical dependencies are machine-visible.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

/-- Assumption package for constructing the forward bridge obligation. -/
structure ForwardBridgeDecomposition
    {X : Type}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) where
  regularity_to_dissipation :
    ∀ st0 : State X,
      GlobalRegularSolution ops spaces nu st0 →
      DissipationNonnegative ops spaces nu
  dissipation_to_pi :
    DissipationNonnegative ops spaces nu →
    ∀ st0 : State X, pi.PIWellPosed st0

/-- Builds `ForwardBridgeObligation` from decomposed assumptions. -/
theorem forward_bridge_of_decomposition
    {X : Type}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu : Rat}
    {pi : PathIntegralInterface X}
    (D : ForwardBridgeDecomposition ops spaces nu pi) :
    ForwardBridgeObligation ops spaces nu pi := by
  intro st0 hReg
  exact D.dissipation_to_pi (D.regularity_to_dissipation st0 hReg) st0

/-- Assumption package for constructing the backward bridge obligation. -/
structure BackwardBridgeDecomposition
    {X : Type}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) where
  pi_to_vorticity_control :
    ∀ st0 : State X, pi.PIWellPosed st0 →
      VorticityBlowupControl ops spaces nu pi
  vorticity_control_to_regularity :
    VorticityBlowupControl ops spaces nu pi →
    ∀ st0 : State X, GlobalRegularSolution ops spaces nu st0

/-- Builds `BackwardBridgeObligation` from decomposed assumptions. -/
theorem backward_bridge_of_decomposition
    {X : Type}
    {ops : FieldOps X}
    {spaces : FunctionSpaceAssumptions X}
    {nu : Rat}
    {pi : PathIntegralInterface X}
    (D : BackwardBridgeDecomposition ops spaces nu pi) :
    BackwardBridgeObligation ops spaces nu pi := by
  intro st0 hPI
  exact D.vorticity_control_to_regularity (D.pi_to_vorticity_control st0 hPI) st0

end NavierStokes.Millennium
