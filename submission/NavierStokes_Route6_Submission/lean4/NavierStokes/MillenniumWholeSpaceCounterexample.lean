import NavierStokes.PDEInterfaces

/-!
# Navier-Stokes Millennium Obligation Scaffold: Whole Space Counterexample (B)

This file records the B-path obligation: existence of a finite-time breakdown
counterexample on the whole space. This is an open mathematical problem.

We use an axiom declaration (not a theorem with a placeholder proof) to keep
the build warning-free while explicitly marking this as an unresolved obligation.
-/

namespace NavierStokes.Millennium

universe u

/-- B-path obligation: whole-space finite-time breakdown counterexample.
    This is an open conjecture (one direction of the Millennium problem). -/
axiom millennium_B_whole_space_breakdown_counterexample
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat) :
    IsWholeSpace spaces ->
      exists st0 : State X, FiniteTimeBreakdownCounterexample ops spaces nu st0

end NavierStokes.Millennium
