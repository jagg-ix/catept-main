import NavierStokes.Core.PDEInterfaces

/-!
# Navier-Stokes Millennium: Periodic Existence & Smoothness (C)

Proves the C-path equivalence from the forward and backward bridge obligations.
This theorem has no local placeholders; remaining open obligations live in
`PDEInterfaces.lean` and `AxiomaticEstimates.lean`.
-/

namespace NavierStokes.Millennium

universe u

theorem millennium_C_periodic_existence_smoothness
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hForward : ForwardBridgeObligation ops spaces nu pi)
    (hBackward : BackwardBridgeObligation ops spaces nu pi) :
    IsPeriodicT3 spaces ->
      forall st0 : State X, GlobalRegularSolution ops spaces nu st0 <-> pi.PIWellPosed st0 := by
  intro _hPeriodic st0
  exact bridgeEquivalenceOfObligations ops spaces nu pi hForward hBackward st0

end NavierStokes.Millennium
