import NavierStokes.PDEInterfaces

/-!
# Navier-Stokes Millennium: Whole Space Existence & Smoothness (A)

Proves the A-path equivalence from the forward and backward bridge obligations.
This theorem has no local placeholders; remaining open obligations live in
`PDEInterfaces.lean` and `AxiomaticEstimates.lean`.
-/

namespace NavierStokes.Millennium

universe u

theorem millennium_A_whole_space_existence_smoothness
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hForward : ForwardBridgeObligation ops spaces nu pi)
    (hBackward : BackwardBridgeObligation ops spaces nu pi) :
    IsWholeSpace spaces ->
      forall st0 : State X, GlobalRegularSolution ops spaces nu st0 <-> pi.PIWellPosed st0 := by
  intro _hWholeSpace st0
  exact bridgeEquivalenceOfObligations ops spaces nu pi hForward hBackward st0

end NavierStokes.Millennium
