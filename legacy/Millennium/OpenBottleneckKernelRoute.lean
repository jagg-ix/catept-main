import NavierStokesClean.Millennium.MillenniumClosure
import NavierStokesClean.Galerkin.VSNuPLegacyCompatibility

/-!
# Open Bottleneck Kernel Route (Clean Compatibility Layer)

Route-level API that mirrors the legacy "open bottleneck" style while staying
compatible with the clean stack.

This module does **not** introduce new physics axioms. It exposes explicit
contract-driven routing theorems:

- legacy-compatible kernel obligations (`VSLeNuPAllTrajProp`, `SliceProjectionCouplingBoundProp`)
  can be carried as hypotheses,
- a caller-provided route contract maps them to `PreciseGapStatement`,
- existing clean closures then give `FeffermanB` and `NavierStokesMillenniumProblem`.
-/

set_option autoImplicit false

namespace NavierStokesClean.Millennium

open NavierStokesClean
open MillenniumNavierStokes MillenniumNS_BoundedDomain

/-! ## 1. Route contracts -/

/-- Contract form: a universal VS≤νP kernel witness yields `PreciseGapStatement`. -/
def KernelToPreciseGapRouteProp : Prop :=
  ∀ ν : ℝ, Galerkin.VSLeNuPAllTrajProp ν → PreciseGapStatement

/-- Contract form: a slice-projection kernel witness yields `PreciseGapStatement`. -/
def SliceKernelToPreciseGapRouteProp : Prop :=
  ∀ ν : ℝ, Galerkin.SliceProjectionCouplingBoundProp ν → PreciseGapStatement

/-! ## 2. Kernel route reducers -/

/-- VS≤νP-kernel route to `PreciseGapStatement` via an explicit contract. -/
theorem kernel_route_implies_precise_gap
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hAll : Galerkin.VSLeNuPAllTrajProp ν) :
    PreciseGapStatement :=
  hRoute ν hAll

/-- Slice-kernel route to `PreciseGapStatement` via an explicit contract. -/
theorem slice_kernel_route_implies_precise_gap
    (hRoute : SliceKernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hSlice : Galerkin.SliceProjectionCouplingBoundProp ν) :
    PreciseGapStatement :=
  hRoute ν hSlice

/-- Derived route: slice-kernel witness reduces to VS≤νP-kernel witness,
then applies the VS≤νP route contract. -/
theorem slice_kernel_route_implies_precise_gap_via_vsnup_route
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hSlice : Galerkin.SliceProjectionCouplingBoundProp ν) :
    PreciseGapStatement := by
  exact hRoute ν (Galerkin.slice_projection_kernel_implies_vs_le_nu_p_all ν hSlice)

/-! ## 3. Closure routing -/

/-- Any kernel-route `PreciseGapStatement` yields `FeffermanB` through
the existing clean bridge theorem. -/
theorem kernel_route_implies_fefferman_b
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hAll : Galerkin.VSLeNuPAllTrajProp ν) :
    FeffermanB := by
  exact pgs_implies_fefferman_b (kernel_route_implies_precise_gap hRoute ν hAll)

/-- Any slice-kernel-route `PreciseGapStatement` yields `FeffermanB`. -/
theorem slice_kernel_route_implies_fefferman_b
    (hRoute : SliceKernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hSlice : Galerkin.SliceProjectionCouplingBoundProp ν) :
    FeffermanB := by
  exact pgs_implies_fefferman_b (slice_kernel_route_implies_precise_gap hRoute ν hSlice)

/-- Kernel-route closure all the way to the Clay statement type. -/
theorem kernel_route_implies_millennium_problem
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hAll : Galerkin.VSLeNuPAllTrajProp ν) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl (kernel_route_implies_fefferman_b hRoute ν hAll))

/-- Slice-kernel-route closure all the way to the Clay statement type. -/
theorem slice_kernel_route_implies_millennium_problem
    (hRoute : SliceKernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hSlice : Galerkin.SliceProjectionCouplingBoundProp ν) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl (slice_kernel_route_implies_fefferman_b hRoute ν hSlice))

/-- Compatibility reducer: if a caller supplies only a VS≤νP route contract,
we can still close a slice-kernel witness to the Clay statement. -/
theorem slice_kernel_route_implies_millennium_problem_via_vsnup_route
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hSlice : Galerkin.SliceProjectionCouplingBoundProp ν) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl (kernel_route_implies_fefferman_b hRoute ν
    (Galerkin.slice_projection_kernel_implies_vs_le_nu_p_all ν hSlice)))

end NavierStokesClean.Millennium
