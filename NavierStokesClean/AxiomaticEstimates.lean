import NavierStokesClean.Core.EnergyFunctionals
import NavierStokesClean.Millennium.PreciseGapStatement

/-!
Legacy-compat leverage surface for `AxiomaticEstimates.lean`.
Maps high-value foundational estimates to the clean theoremized stack.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.AxiomaticEstimates

open NavierStokesClean
open NavierStokesClean.Millennium

lemma nsNu_pos : (0 : ℝ) < NavierStokesClean.nsNu := NavierStokesClean.nsNu_pos
lemma hbar_pos : (0 : ℝ) < NavierStokesClean.hbar := NavierStokesClean.hbar_pos

lemma enstrophy_nonneg (v : NSField) : (0 : ℝ) ≤ NavierStokesClean.enstrophy v :=
  NavierStokesClean.enstrophy_nonneg v

lemma bkmVorticityIntegral_nonneg (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    (0 : ℝ) ≤ NavierStokesClean.bkmVorticityIntegral traj T :=
  NavierStokesClean.bkm_nonneg traj T hT

lemma integratedEnstrophy_eq_hbar_nu_ept (traj : Trajectory) (T : ℝ) :
    NavierStokesClean.integratedEnstrophy traj T =
      (NavierStokesClean.hbar / NavierStokesClean.nsNu) * NavierStokesClean.entropicProperTime traj T :=
  NavierStokesClean.integratedEnstrophy_eq_hbar_nu_ept traj T

lemma nsBKMVorticityToRegularity : PreciseGapStatement :=
  pgs_ept_witness

end NavierStokesClean.LegacyCompat.AxiomaticEstimates
