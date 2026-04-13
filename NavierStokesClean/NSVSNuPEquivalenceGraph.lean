import NavierStokesClean.CATEPT.ModularNoetherCompatibility
import NavierStokesClean.Galerkin.VSNuPLegacyCompatibility
import NavierStokesClean.Millennium.OpenBottleneckKernelRoute

/-!
Legacy-compat leverage surface for `NSVSNuPEquivalenceGraph.lean`.
Encodes the key equivalence edges with the clean theoremized VS<=nuP route.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSVSNuPEquivalenceGraph

open NavierStokesClean
open NavierStokesClean.CATEPT
open NavierStokesClean.Galerkin
open NavierStokesClean.Millennium

lemma realNoether_contract_implies_vsnup_pointwise
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hDef : 0 ≤ spatialImaginaryNoetherDefect traj t) :
    vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) :=
  (defect_nonneg_iff_vs_le_nuP traj t).1 hDef

lemma realNoether_contract_implies_precise_gap
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hAll : VSLeNuPAllTrajProp ν) :
    PreciseGapStatement :=
  kernel_route_implies_precise_gap hRoute ν hAll

lemma realNoether_contract_implies_millennium_problem
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hAll : VSLeNuPAllTrajProp ν) :
    MillenniumNavierStokes.NavierStokesMillenniumProblem :=
  kernel_route_implies_millennium_problem hRoute ν hAll

end NavierStokesClean.LegacyCompat.NSVSNuPEquivalenceGraph
