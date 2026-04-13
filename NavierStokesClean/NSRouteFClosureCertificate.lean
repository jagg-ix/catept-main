import NavierStokesClean.Millennium.BKMContinuationPipeline
import NavierStokesClean.Millennium.OpenBottleneckKernelRoute

/-!
Legacy-compat leverage surface for `NSRouteFClosureCertificate.lean`.
Provides explicit closure certificates through theoremized clean routes.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSRouteFClosureCertificate

open NavierStokesClean.Millennium

lemma route_f_closure_certificate : MillenniumNavierStokes.NavierStokesMillenniumProblem :=
  millennium_C_closed_via_pipeline

lemma route_f_kernel_contract_certificate
    (hRoute : KernelToPreciseGapRouteProp)
    (ν : ℝ)
    (hAll : NavierStokesClean.Galerkin.VSLeNuPAllTrajProp ν) :
    MillenniumNavierStokes.NavierStokesMillenniumProblem :=
  kernel_route_implies_millennium_problem hRoute ν hAll

end NavierStokesClean.LegacyCompat.NSRouteFClosureCertificate
