import NavierStokes.Benchmark.LeanMillenniumNavierStokesSpec
import NavierStokes.Millennium.MillenniumWholeSpace
import NavierStokes.Millennium.MillenniumPeriodic
import NavierStokes.Millennium.MillenniumWholeSpaceCounterexample
import NavierStokes.Millennium.MillenniumPeriodicCounterexample

/-!
# LeanMillennium Navier-Stokes Conformance Bridge

This module provides theorem-level adapters from local Navier-Stokes Millennium
endpoint statements to the local mirror-spec of external LeanMillennium symbols.

Scope:
- statement conformance only (A/B/C/D + disjunction);
- no claim of solving the open Millennium content;
- explicit status preserved (B/D are currently axiom-anchored locally).
-/

namespace NavierStokes.Benchmark

set_option autoImplicit false

universe u

open NavierStokes.Millennium

/-- Conformance adapter (A):
local whole-space existence/smoothness endpoint implies the external mirror
Fefferman-A proposition shape. -/
theorem local_A_implies_external_A
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hForward : ForwardBridgeObligation ops spaces nu pi)
    (hBackward : BackwardBridgeObligation ops spaces nu pi) :
    ExternalFeffermanAProp ops spaces nu pi := by
  intro hWhole st0
  exact millennium_A_whole_space_existence_smoothness
    ops spaces nu pi hForward hBackward hWhole st0

/-- Conformance adapter (C):
local periodic existence/smoothness endpoint implies the external mirror
Fefferman-C proposition shape. -/
theorem local_C_implies_external_C
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hForward : ForwardBridgeObligation ops spaces nu pi)
    (hBackward : BackwardBridgeObligation ops spaces nu pi) :
    ExternalFeffermanCProp ops spaces nu pi := by
  intro hPeriodic st0
  exact millennium_C_periodic_existence_smoothness
    ops spaces nu pi hForward hBackward hPeriodic st0

/-- Conformance adapter (B):
local whole-space breakdown endpoint implies the external mirror
Fefferman-B proposition shape. -/
theorem local_B_implies_external_B
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat) :
    ExternalFeffermanBProp ops spaces nu :=
  millennium_B_whole_space_breakdown_counterexample ops spaces nu

/-- Conformance adapter (D):
local periodic breakdown endpoint implies the external mirror
Fefferman-D proposition shape. -/
theorem local_D_implies_external_D
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat) :
    ExternalFeffermanDProp ops spaces nu :=
  millennium_D_periodic_breakdown_counterexample ops spaces nu

/-- Combined conformance theorem:
the local A/B/C/D endpoint family implies the external mirrored disjunction. -/
theorem local_endpoints_imply_external_millennium_disjunction
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X)
    (hForward : ForwardBridgeObligation ops spaces nu pi)
    (hBackward : BackwardBridgeObligation ops spaces nu pi) :
    ExternalNavierStokesMillenniumProblemProp ops spaces nu pi :=
  Or.inl (local_A_implies_external_A ops spaces nu pi hForward hBackward)

/-- Alternative assembly theorem:
if local disjunction is provided explicitly, it transports directly to the
external mirrored disjunction (identity on proposition shape). -/
theorem local_disjunction_implies_external_millennium_disjunction
    {X : Type u}
    (ops : FieldOps X)
    (spaces : FunctionSpaceAssumptions X)
    (nu : Rat)
    (pi : PathIntegralInterface X) :
    (ExternalFeffermanAProp ops spaces nu pi ∨
      ExternalFeffermanBProp ops spaces nu ∨
      ExternalFeffermanCProp ops spaces nu pi ∨
      ExternalFeffermanDProp ops spaces nu) →
    ExternalNavierStokesMillenniumProblemProp ops spaces nu pi := by
  intro h
  exact h

end NavierStokes.Benchmark
