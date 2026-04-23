import NavierStokesClean.Galerkin.VSNuPSpatialBridge
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# CATEPT Araki Relative Entropy Bridge (Spatial NS Carrier)

This module ports the high-value Stage-78 bridge idea onto the clean spatial
carrier (`NSSpaceTrajectory`) and existing m01/m04 infrastructure.

Core analog:
`S_rel^NS(t) := Ω(t) / (2ν)` with `Ω(t) = spatialEnstrophy (traj t)`.

Defect object:
`D_I(t) := ν P(t) - VS(t)` with
- `P(t) = palinstrophySpatial (traj t)`
- `VS(t) = vorticityStretching (traj t)`.

Using `SatisfiesSpatialNSPDEFull.hEnstrophyEq`, we derive:
`dΩ/dt = -2 D_I`,
hence
`dS_rel^NS/dt = -D_I / ν`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

open NavierStokesClean NavierStokesClean.Galerkin

noncomputable section

/-- NS Araki-relative-entropy analog on the spatial carrier:
`S_rel^NS(t) = Ω(t)/(2ν)`. -/
def nsArakiRelativeEntropySpatial (traj : NSSpaceTrajectory) (t : ℝ) : ℝ :=
  spatialEnstrophy (traj t) / (2 * nsNu)

/-- Imaginary Noether defect on the spatial carrier:
`D_I(t) = ν P(t) - VS(t)`. -/
def spatialImaginaryNoetherDefect (traj : NSSpaceTrajectory) (t : ℝ) : ℝ :=
  nsNu * palinstrophySpatial (traj t) - vorticityStretching (traj t)

/-- Positivity of `S_rel^NS` from `Ω ≥ 0` and `ν > 0`. -/
theorem ns_araki_rel_entropy_spatial_nonneg
    (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ nsArakiRelativeEntropySpatial traj t := by
  unfold nsArakiRelativeEntropySpatial
  exact div_nonneg (spatialEnstrophy_nonneg (traj t))
    (le_of_lt (mul_pos two_pos nsNu_pos))

/-- Enstrophy-rate identity in defect form:
`dΩ/dt = -2 D_I`. -/
theorem spatial_enstrophy_rate_eq_neg_two_defect
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    deriv (fun s => spatialEnstrophy (traj s)) t =
      -2 * spatialImaginaryNoetherDefect traj t := by
  calc
    deriv (fun s => spatialEnstrophy (traj s)) t
      = -2 * nsNu * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t) := by
          rw [(hFull.hEnstrophyEq t).deriv]
    _ = -2 * (nsNu * palinstrophySpatial (traj t) - vorticityStretching (traj t)) := by ring
    _ = -2 * spatialImaginaryNoetherDefect traj t := by
          simp [spatialImaginaryNoetherDefect]

/-- Relative-entropy rate identity:
`dS_rel^NS/dt = -D_I/ν`. -/
theorem ns_araki_rel_entropy_spatial_rate_eq_neg_defect_over_nu
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    deriv (fun s => nsArakiRelativeEntropySpatial traj s) t =
      -spatialImaginaryNoetherDefect traj t / nsNu := by
  have hNu : (nsNu : ℝ) ≠ 0 := ne_of_gt nsNu_pos
  have hTwoNu : (2 * nsNu : ℝ) ≠ 0 := by nlinarith [nsNu_pos]
  have hDeriv :
      deriv (fun s => nsArakiRelativeEntropySpatial traj s) t =
        (-2 * nsNu * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t)) / (2 * nsNu) := by
    have hRate :
        HasDerivAt (fun s => nsArakiRelativeEntropySpatial traj s)
          ((-2 * nsNu * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t)) / (2 * nsNu))
          t := by
      simpa [nsArakiRelativeEntropySpatial] using
        (hFull.hEnstrophyEq t).div_const (2 * nsNu)
    exact hRate.deriv
  calc
    deriv (fun s => nsArakiRelativeEntropySpatial traj s) t
      = (-2 * nsNu * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t)) / (2 * nsNu) :=
        hDeriv
    _ = -spatialImaginaryNoetherDefect traj t / nsNu := by
          unfold spatialImaginaryNoetherDefect
          field_simp [hNu, hTwoNu]
          ring

/-- Defect positivity is exactly `VS ≤ νP`. -/
theorem spatial_defect_nonneg_iff_vs_le_nuP
    (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ spatialImaginaryNoetherDefect traj t ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) := by
  unfold spatialImaginaryNoetherDefect
  constructor <;> intro h <;> nlinarith [h]

/-- Relative-entropy monotonicity criterion in defect form. -/
theorem ns_araki_rel_entropy_spatial_decreasing_iff_defect_nonneg
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    deriv (fun s => nsArakiRelativeEntropySpatial traj s) t ≤ 0 ↔
      0 ≤ spatialImaginaryNoetherDefect traj t := by
  have hRate :
      deriv (fun s => nsArakiRelativeEntropySpatial traj s) t =
        -spatialImaginaryNoetherDefect traj t / nsNu :=
    ns_araki_rel_entropy_spatial_rate_eq_neg_defect_over_nu traj t hFull
  have hNu : (nsNu : ℝ) ≠ 0 := ne_of_gt nsNu_pos
  constructor
  · intro h
    have hScaled : -spatialImaginaryNoetherDefect traj t / nsNu ≤ 0 := by
      simpa [hRate] using h
    have hMul :
        (-spatialImaginaryNoetherDefect traj t / nsNu) * nsNu ≤ (0 : ℝ) * nsNu :=
      mul_le_mul_of_nonneg_right hScaled (le_of_lt nsNu_pos)
    have hNeg : -spatialImaginaryNoetherDefect traj t ≤ 0 := by
      have hLeft :
          (-spatialImaginaryNoetherDefect traj t / nsNu) * nsNu =
            -spatialImaginaryNoetherDefect traj t := by
        field_simp [hNu]
      simpa [hLeft] using hMul
    nlinarith [hNeg]
  · intro hDefect
    have hNeg : -spatialImaginaryNoetherDefect traj t ≤ 0 := by nlinarith [hDefect]
    have hInvNonneg : 0 ≤ (1 / nsNu : ℝ) := le_of_lt (one_div_pos.mpr nsNu_pos)
    have hScaledMul :
        (1 / nsNu : ℝ) * (-spatialImaginaryNoetherDefect traj t) ≤
          (1 / nsNu : ℝ) * 0 :=
      mul_le_mul_of_nonneg_left hNeg hInvNonneg
    have hScaled : -spatialImaginaryNoetherDefect traj t / nsNu ≤ 0 := by
      simpa [div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using hScaledMul
    simpa [hRate] using hScaled

/-- Relative-entropy monotonicity criterion in VS≤νP form. -/
theorem ns_araki_rel_entropy_spatial_decreasing_iff_vs_le_nuP
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hFull : SatisfiesSpatialNSPDEFull nsNu traj) :
    deriv (fun s => nsArakiRelativeEntropySpatial traj s) t ≤ 0 ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) := by
  calc
    deriv (fun s => nsArakiRelativeEntropySpatial traj s) t ≤ 0
        ↔ 0 ≤ spatialImaginaryNoetherDefect traj t :=
      ns_araki_rel_entropy_spatial_decreasing_iff_defect_nonneg traj t hFull
    _ ↔ vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) :=
      spatial_defect_nonneg_iff_vs_le_nuP traj t

end

end NavierStokesClean.CATEPT
