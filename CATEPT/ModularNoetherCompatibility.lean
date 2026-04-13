import NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge

/-!
# Modular/Noether Compatibility (Clean Spatial Carrier)

Compatibility shim for legacy `NSModularNoetherBridge` naming, mapped to the
clean spatial carrier and theoremized defect identities.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

open NavierStokesClean NavierStokesClean.Galerkin

noncomputable section

/-- Legacy-style defect name on the clean spatial carrier. -/
abbrev imaginaryNoetherDefect
    (traj : NSSpaceTrajectory) (t : ℝ) : ℝ :=
  spatialImaginaryNoetherDefect traj t

/-- Enstrophy-rate identity in defect form: `dΩ/dt = -2 D_I`. -/
theorem enstrophyRate_eq_neg_two_imaginaryNoetherDefect
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    deriv (fun s => spatialEnstrophy (traj s)) t =
      -2 * imaginaryNoetherDefect traj t := by
  simpa [imaginaryNoetherDefect] using
    spatial_enstrophy_rate_eq_neg_two_defect traj t hFull

/-- Defect nonnegativity is exactly `VS ≤ νP`. -/
theorem defect_nonneg_iff_vs_le_nuP
    (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ imaginaryNoetherDefect traj t ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) := by
  simpa [imaginaryNoetherDefect] using
    spatial_defect_nonneg_iff_vs_le_nuP traj t

/-- CAT/EPT spatial rate specialization: `lambda_NS = Ω/(2ν)`. -/
def catEptRateNS
    (traj : NSSpaceTrajectory) (t : ℝ) : ℝ :=
  nsArakiRelativeEntropySpatial traj t

theorem entropicRateNS_eq_catEptRateNS
    (traj : NSSpaceTrajectory) (t : ℝ) :
    catEptRateNS traj t = nsArakiRelativeEntropySpatial traj t :=
  rfl

/-- Degeneracy criterion on the clean spatial carrier. -/
theorem catEptRateNS_zero_iff_enstrophy_zero
    (traj : NSSpaceTrajectory) (t : ℝ) :
    catEptRateNS traj t = 0 ↔ spatialEnstrophy (traj t) = 0 := by
  unfold catEptRateNS nsArakiRelativeEntropySpatial
  constructor
  · intro h
    have hNu : (2 * (nsNu : ℝ) : ℝ) ≠ 0 := by nlinarith [nsNu_pos]
    have h0 : spatialEnstrophy (traj t) = 0 ∨ (2 * (nsNu : ℝ) : ℝ) = 0 :=
      (div_eq_zero_iff).1 h
    exact h0.resolve_right hNu
  · intro h
    simp [h]

/-- Division-free witness form:
`lambda * dΩ/dτ = dΩ/dt`. -/
def EnstrophyEntropicRateWitness
    (traj : NSSpaceTrajectory) (t dOmega_dTau : ℝ) : Prop :=
  catEptRateNS traj t * dOmega_dTau = deriv (fun s => spatialEnstrophy (traj s)) t

/-- Product-law form: `lambda * dΩ/dτ = -2 D_I` under witness contract. -/
theorem modular_product_law_of_witness
    (traj : NSSpaceTrajectory) (t dOmega_dTau : ℝ)
    (hW : EnstrophyEntropicRateWitness traj t dOmega_dTau)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    catEptRateNS traj t * dOmega_dTau = -2 * imaginaryNoetherDefect traj t := by
  calc
    catEptRateNS traj t * dOmega_dTau = deriv (fun s => spatialEnstrophy (traj s)) t := hW
    _ = -2 * imaginaryNoetherDefect traj t := by
      simpa [imaginaryNoetherDefect] using
        (spatial_enstrophy_rate_eq_neg_two_defect traj t hFull)

end

end NavierStokesClean.CATEPT
