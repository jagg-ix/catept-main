import NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge
import Mathlib.Tactic.Linarith

/-!
# CATEPT Imaginary-Action Concavity Bridge (Spatial NS Carrier)

This module ports the Stage-79 channel split to the clean spatial carrier:

1. `S_I^Ω` channel (enstrophy-driven):
   - first rate: `dS_I^Ω/dt := ν Ω`
   - second-rate witness: `d²S_I^Ω/dt² := ν dΩ/dt`
   - concavity criterion: `d²S_I^Ω/dt² ≤ 0 ↔ D_I ≥ 0 ↔ VS ≤ νP`

2. `S_I^BKM` channel (BKM-driven):
   - first rate: `dS_I^BKM/dt := ν ‖ω‖_{L∞}`
   - first-rate nonnegativity is theorem-level via `vorticityLinfNorm_nonneg`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

open NavierStokesClean NavierStokesClean.Galerkin

noncomputable section

/-- Enstrophy-driven imaginary-action first rate: `dS_I^Ω/dt := ν Ω(t)`. -/
def imaginaryActionOmegaRateSpatial (traj : NSSpaceTrajectory) (t : ℝ) : ℝ :=
  nsNu * spatialEnstrophy (traj t)

/-- BKM-driven imaginary-action first rate: `dS_I^BKM/dt := ν ‖ω‖_{L∞}(t)`. -/
def imaginaryActionBKMRateSpatial (traj : NSSpaceTrajectory) (t : ℝ) : ℝ :=
  nsNu * (vorticityLinfNorm (traj t)).toReal

/-- Positivity of the enstrophy-driven first-rate channel. -/
theorem imaginary_action_omega_rate_spatial_nonneg
    (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ imaginaryActionOmegaRateSpatial traj t := by
  unfold imaginaryActionOmegaRateSpatial
  exact mul_nonneg (le_of_lt nsNu_pos) (spatialEnstrophy_nonneg (traj t))

/-- Positivity of the BKM-driven first-rate channel. -/
theorem imaginary_action_bkm_rate_spatial_nonneg
    (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ imaginaryActionBKMRateSpatial traj t := by
  unfold imaginaryActionBKMRateSpatial
  exact mul_nonneg (le_of_lt nsNu_pos) (ENNReal.toReal_nonneg)

/-- Witness for the second-rate form of the enstrophy-driven channel:
`d²S_I^Ω/dt² = ν dΩ/dt`. -/
def ImaginaryActionOmegaSecondRateWitnessSpatial
    (traj : NSSpaceTrajectory) (t : ℝ) (d2SI_Omega : ℝ) : Prop :=
  d2SI_Omega = nsNu * deriv (fun s => spatialEnstrophy (traj s)) t

/-- Under the witness, second rate equals `-2ν D_I`. -/
theorem imaginary_action_omega_second_rate_eq_neg_two_nu_defect_of_witness
    (traj : NSSpaceTrajectory) (t d2SI_Omega : ℝ)
    (hW : ImaginaryActionOmegaSecondRateWitnessSpatial traj t d2SI_Omega)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    d2SI_Omega = -2 * nsNu * spatialImaginaryNoetherDefect traj t := by
  unfold ImaginaryActionOmegaSecondRateWitnessSpatial at hW
  calc
    d2SI_Omega = nsNu * deriv (fun s => spatialEnstrophy (traj s)) t := hW
    _ = nsNu * (-2 * spatialImaginaryNoetherDefect traj t) := by
          rw [spatial_enstrophy_rate_eq_neg_two_defect traj t hFull]
    _ = -2 * nsNu * spatialImaginaryNoetherDefect traj t := by ring

/-- Concavity criterion:
`d²S_I^Ω/dt² ≤ 0 ↔ D_I ≥ 0` under the witness. -/
theorem imaginary_action_omega_concavity_iff_defect_nonneg_of_witness
    (traj : NSSpaceTrajectory) (t d2SI_Omega : ℝ)
    (hW : ImaginaryActionOmegaSecondRateWitnessSpatial traj t d2SI_Omega)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    d2SI_Omega ≤ 0 ↔ 0 ≤ spatialImaginaryNoetherDefect traj t := by
  have hEq :
      d2SI_Omega = -2 * nsNu * spatialImaginaryNoetherDefect traj t :=
    imaginary_action_omega_second_rate_eq_neg_two_nu_defect_of_witness
      traj t d2SI_Omega hW hFull
  constructor
  · intro hConc
    have hScaled : -2 * nsNu * spatialImaginaryNoetherDefect traj t ≤ 0 := by
      simpa [hEq] using hConc
    nlinarith [hScaled, nsNu_pos]
  · intro hDefect
    have hScaled : -2 * nsNu * spatialImaginaryNoetherDefect traj t ≤ 0 := by
      nlinarith [hDefect, nsNu_pos]
    simpa [hEq] using hScaled

/-- Equivalent bottleneck form:
`d²S_I^Ω/dt² ≤ 0 ↔ VS ≤ νP` under the witness. -/
theorem imaginary_action_omega_concavity_iff_vs_le_nuP_of_witness
    (traj : NSSpaceTrajectory) (t d2SI_Omega : ℝ)
    (hW : ImaginaryActionOmegaSecondRateWitnessSpatial traj t d2SI_Omega)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    d2SI_Omega ≤ 0 ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) := by
  calc
    d2SI_Omega ≤ 0
        ↔ 0 ≤ spatialImaginaryNoetherDefect traj t :=
      imaginary_action_omega_concavity_iff_defect_nonneg_of_witness traj t d2SI_Omega hW hFull
    _ ↔ vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) :=
      spatial_defect_nonneg_iff_vs_le_nuP traj t

end

end NavierStokesClean.CATEPT
