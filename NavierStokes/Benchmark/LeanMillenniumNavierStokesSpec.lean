import NavierStokes.MillenniumWholeSpace
import NavierStokes.MillenniumPeriodic
import NavierStokes.MillenniumWholeSpaceCounterexample
import NavierStokes.MillenniumPeriodicCounterexample

/-!
# LeanMillennium Navier-Stokes Mirror Spec (External Benchmark Interface)

This module defines local mirror propositions for the external benchmark symbols
from `lean-dojo/LeanMillenniumPrizeProblems` (Fefferman A/B/C/D + combined
Millennium disjunction).

Purpose:
- provide a stable, machine-checkable local interface for statement conformance;
- keep benchmark mapping explicit without importing the external repository as a
  compile-time dependency in this package.

These are *statement-level* mirrors, not closure proofs.
-/

namespace NavierStokes.Benchmark

set_option autoImplicit false

universe u

open NavierStokes.Millennium

/-- Mirror of external Fefferman-A family in local abstraction:
whole-space existence/smoothness route endpoint (A-like). -/
def ExternalFeffermanAProp
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  IsWholeSpace spaces ->
    forall st0 : State X, GlobalRegularSolution ops spaces nu st0 <-> pi.PIWellPosed st0

/-- Mirror of external Fefferman-C family in local abstraction:
periodic existence/smoothness route endpoint (C-like). -/
def ExternalFeffermanCProp
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  IsPeriodicT3 spaces ->
    forall st0 : State X, GlobalRegularSolution ops spaces nu st0 <-> pi.PIWellPosed st0

/-- Mirror of external Fefferman-B family in local abstraction:
whole-space finite-time breakdown counterexample endpoint (B-like). -/
def ExternalFeffermanBProp
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat) : Prop :=
  IsWholeSpace spaces ->
    exists st0 : State X, FiniteTimeBreakdownCounterexample ops spaces nu st0

/-- Mirror of external Fefferman-D family in local abstraction:
periodic finite-time breakdown counterexample endpoint (D-like). -/
def ExternalFeffermanDProp
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat) : Prop :=
  IsPeriodicT3 spaces ->
    exists st0 : State X, FiniteTimeBreakdownCounterexample ops spaces nu st0

/-- Mirror of external combined Millennium statement (A ∨ B ∨ C ∨ D). -/
def ExternalNavierStokesMillenniumProblemProp
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) : Prop :=
  ExternalFeffermanAProp ops spaces nu pi ∨
    ExternalFeffermanBProp ops spaces nu ∨
      ExternalFeffermanCProp ops spaces nu pi ∨
        ExternalFeffermanDProp ops spaces nu

end NavierStokes.Benchmark
