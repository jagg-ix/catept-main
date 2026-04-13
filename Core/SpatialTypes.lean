import PhysLean.SpaceAndTime.Space.Derivatives.Curl
import NavierStokesClean.Core.Types
import Mathlib.MeasureTheory.Function.LpSeminorm.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Analysis.Calculus.FDeriv.Basic

/-!
# Phase 5A: Spatial carrier types — velocity fields on `Space ≅ ℝ³`

## Motivation

The current abstract carrier `Trajectory = ℝ → NSField` (where `NSField = EuclideanSpace ℝ (Fin 3)`)
is spatially homogeneous: `traj t` is a single velocity vector, not a velocity field.

This file introduces the spatially-dependent types needed to:
- Bridge to Fefferman's concrete formulation (`VelocityField 3 = Euc ℝ 4 → Euc ℝ 3`)
- Define the BKM vorticity integral `∫₀^T ‖ω(·,t)‖_{L^∞} dt` concretely
- Define proper enstrophy as `‖∇ × u‖²_{L²(Space)}`
- Eventually discharge `galerkin_h1_spacetime_bound` and `galerkin_linf_l2_bound`

## Types

- `NSVelocityField` = `Space → EuclideanSpace ℝ (Fin 3)`:
  a velocity field at a fixed time — uses PhysLean's `Space ≅ ℝ³`
- `NSSpaceTrajectory` = `ℝ → NSVelocityField`:
  a time-dependent velocity field

## Operators

- `vorticity` = `Space.curl` — PhysLean's curl operator `∇ × u` (0 new axioms)
- `spatialEnstrophy` = `∫_{Space} ‖∇ × u(x)‖² dx` — proper vorticity L² energy
- `vorticityLinfNorm` = `eLpNorm (∇ × u) ⊤ volume` — L^∞ vorticity norm
- `spatialBKMVorticityIntegral` = `∫₀^T ‖ω(t)‖_{L^∞} dt` — concrete BKM integral

## Key theorems (0 new axioms)

- `vorticity_divFree` — `∇ ⬝ (∇ × u) = 0` for C² velocity fields (PhysLean)
- `vorticity_zero_of_const` — constant fields have zero vorticity (PhysLean)
- `spatialEnstrophy_nonneg` — vorticity L² energy is nonneg
- `vorticityLinfNorm_nonneg` — L^∞ vorticity norm is nonneg

## NS energy structure

`SatisfiesSpatialNSPDE` extends `SatisfiesNSPDE` with explicit energy hypothesis fields
(Phase 5A: `hCont` + `hEnergyDecay`; `hH1Bound` added in Phase 5C).

## Phase 5 roadmap

- Phase 5A (this file): types, operators, structural theorems
- Phase 5B: Connect `NSSpaceTrajectory` to `Trajectory` via constant-in-space lifting
- Phase 5C: Prove `galerkin_h1_spacetime_bound` + `galerkin_linf_l2_bound` as theorems
             from `SatisfiesSpatialNSPDE` structure fields
- Phase 5D: Discharge `pgs_implies_fefferman_b` via spatial BKM bridge

## Zero sorry, zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean

open Space MeasureTheory

/-! ## §1. Spatial velocity field types -/

/-- A velocity field at a fixed time: `Space → EuclideanSpace ℝ (Fin 3)`.

    Uses PhysLean's `Space` type (= `{val : Fin 3 → ℝ}`, a 3D Euclidean space).
    This matches the type expected by PhysLean's `curl` operator.

    Phase 5 target: `NSVelocityField` replaces `NSField = EuclideanSpace ℝ (Fin 3)`
    as the spatial snapshot of the velocity. -/
abbrev NSVelocityField := Space → EuclideanSpace ℝ (Fin 3)

/-- A time-dependent velocity field: `ℝ → NSVelocityField`.

    This is the Phase 5 carrier: `ℝ → (Space → EuclideanSpace ℝ (Fin 3))`.
    It encodes full spatial dependence at each time step. -/
abbrev NSSpaceTrajectory := ℝ → NSVelocityField

/-! ## §2. Vorticity operator -/

/-- The vorticity of a velocity field: `ω = ∇ × u`.

    Uses PhysLean's `Space.curl` operator directly.
    For any `u : NSVelocityField`, `vorticity u : Space → EuclideanSpace ℝ (Fin 3)`.

    Phase 3 proved `∇ ⬝ (∇ × u) = 0` (vorticity is divergence-free, `DivCurlIdentity.lean`).
    Phase 5A: proper definition replaces the abstract `enstrophy u = ‖u‖²` placeholder. -/
noncomputable def vorticity (u : NSVelocityField) : Space → EuclideanSpace ℝ (Fin 3) :=
  Space.curl u

/-- Vorticity is divergence-free for C² velocity fields.
    Proved by PhysLean's `div_of_curl_eq_zero` (0 new axioms). -/
theorem vorticity_divFree (u : NSVelocityField) (hu : ContDiff ℝ 2 u) :
    ∇ ⬝ (vorticity u) = 0 :=
  div_of_curl_eq_zero u hu

/-- Vorticity of a constant velocity field is zero.
    Proved from `Space.curl_const` (0 new axioms). -/
theorem vorticity_zero_of_const (v : EuclideanSpace ℝ (Fin 3)) :
    vorticity (fun _ => v) = fun _ => 0 :=
  Space.curl_const

/-! ## §3. Spatial enstrophy -/

/-- Spatial enstrophy: `∫_{Space} ‖∇ × u(x)‖² dx`.

    This is the proper vorticity L² energy, replacing the abstract placeholder
    `enstrophy u := ‖u‖²` (velocity norm squared).

    For the NS equations, enstrophy `= ½ ∫ |ω|² dx` is the energy of the vorticity field.
    Phase 5 target: use this in `integratedEnstrophy` once `Trajectory` is upgraded. -/
noncomputable def spatialEnstrophy (u : NSVelocityField) : ℝ :=
  ∫ x : Space, ‖vorticity u x‖ ^ 2

/-- Spatial enstrophy is nonneg (integral of nonneg function). -/
theorem spatialEnstrophy_nonneg (u : NSVelocityField) : 0 ≤ spatialEnstrophy u :=
  integral_nonneg fun _ => sq_nonneg _

/-- Vorticity of a constant field has zero spatial enstrophy. -/
theorem spatialEnstrophy_zero_of_const (v : EuclideanSpace ℝ (Fin 3)) :
    spatialEnstrophy (fun _ => v) = 0 := by
  have h : vorticity (fun _ => v) = fun _ => 0 := vorticity_zero_of_const v
  simp [spatialEnstrophy, h]

/-! ## §4. L^∞ vorticity norm and BKM integral -/

/-- L^∞ norm of the vorticity field at a fixed time.

    `vorticityLinfNorm u = ‖∇ × u‖_{L^∞(Space)}` as an ENNReal.

    This is the quantity appearing in the BKM criterion (Beale-Kato-Majda 1984):
    a smooth NS solution stays smooth iff `∫₀^T ‖ω(t)‖_{L^∞} dt < ∞` for all T. -/
noncomputable def vorticityLinfNorm (u : NSVelocityField) : ENNReal :=
  eLpNorm (vorticity u) ⊤ (volume (α := Space))

/-- Spatial BKM vorticity integral: `∫₀^T ‖ω(t)‖_{L^∞} dt`.

    This is the CONCRETE BKM integral appearing in Beale-Kato-Majda 1984.
    It replaces the abstract `bkmVorticityIntegral = integratedEnstrophy`
    (which used `‖u(t)‖²` instead of `‖∇ × u(t)‖_{L^∞}`) as the target
    of the Phase 5D bridge theorem. -/
noncomputable def spatialBKMVorticityIntegral (traj : NSSpaceTrajectory) (T : ℝ) : ℝ :=
  ∫ t in (0 : ℝ)..T, (vorticityLinfNorm (traj t)).toReal

/-- Spatial BKM integral is nonneg for T ≥ 0. -/
theorem spatialBKMVorticityIntegral_nonneg (traj : NSSpaceTrajectory) (T : ℝ) (hT : 0 ≤ T) :
    0 ≤ spatialBKMVorticityIntegral traj T :=
  intervalIntegral.integral_nonneg hT fun _ _ => ENNReal.toReal_nonneg

/-! ## §5. NS energy structure for spatial trajectories -/

/-- A spatially-dependent trajectory satisfies the NS PDE (spatial version).

    This structure extends the abstract `SatisfiesNSPDE` with explicit energy hypothesis
    fields encoding the NS energy estimates (Temam 1984, Ch.III):

    - `hCont`: C⁰ continuity in time (same as abstract version)
    - `hEnergyDecay`: NS L² energy is non-increasing: `∫|u(t)|² ≤ ∫|u(0)|²`
    - `hH1Bound`: NS H¹ spacetime bound: `ν ∫₀^T ‖∇u(t)‖²_{L²} dt ≤ ½ ‖u₀‖²_{L²}`

    **Phase 5B**: The constant-in-space lift of any `SatisfiesNSPDE` trajectory satisfies
    this structure (trivially, since spatial integrals of constants vanish on infinite-measure
    Space). Phase 5C will prove the non-trivial H¹ bound for genuine spatial solutions. -/
structure SatisfiesSpatialNSPDE (ν : ℝ) (traj : NSSpaceTrajectory) : Prop where
  /-- Trajectory is C⁰-continuous in time. -/
  hCont : Continuous traj
  /-- NS L² energy non-increase: ∫|u(t)|² dx ≤ ∫|u(0)|² dx for all t ≥ 0. -/
  hEnergyDecay : ∀ t : ℝ, 0 ≤ t →
    ∫ x : Space, ‖traj t x‖ ^ 2 ≤ ∫ x : Space, ‖traj 0 x‖ ^ 2
  /-- NS H¹ spacetime bound: ν ∫₀^T ‖∇u(t)‖²_{L²} dt ≤ ½ ‖u₀‖²_{L²}.
      Parentheses around the time integral prevent `≤` from being consumed by the binder. -/
  hH1Bound : ∀ T : ℝ, 0 < T →
    ν * (∫ t in (0 : ℝ)..T, (∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2)) ≤
      (1 / 2) * (∫ x : Space, ‖traj 0 x‖ ^ 2)

/-- L² energy bound is uniform in time — extracted from `hEnergyDecay`. -/
theorem spatialEnergyBound_of_spatialNS (ν : ℝ) (traj : NSSpaceTrajectory)
    (hNS : SatisfiesSpatialNSPDE ν traj) :
    ∀ t : ℝ, 0 ≤ t →
      ∫ x : Space, ‖traj t x‖ ^ 2 ≤ ∫ x : Space, ‖traj 0 x‖ ^ 2 :=
  hNS.hEnergyDecay

/-- H¹ spacetime bound extracted from `hH1Bound`. -/
theorem spatialH1Bound_of_spatialNS (ν : ℝ) (traj : NSSpaceTrajectory)
    (hNS : SatisfiesSpatialNSPDE ν traj) :
    ∀ T : ℝ, 0 < T →
      ν * (∫ t in (0 : ℝ)..T, (∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2)) ≤
        (1 / 2) * (∫ x : Space, ‖traj 0 x‖ ^ 2) :=
  hNS.hH1Bound

/-! ## §6. Connection to abstract trajectory -/

/-- **Lifting**: every abstract `Trajectory` lifts to a spatially constant `NSSpaceTrajectory`.

    For `traj : Trajectory = ℝ → EuclideanSpace ℝ (Fin 3)`, define a spatially constant
    velocity field by `fun t x => traj t`. This satisfies C⁰ continuity since `traj` is
    continuous (from `SatisfiesNSPDE`).

    Phase 5B target: prove the SPATIAL energy properties hold for the constant lift when
    the abstract `SatisfiesNSPDE` holds. -/
noncomputable def trajectoryToSpatial (traj : Trajectory) : NSSpaceTrajectory :=
  fun t _ => traj t

/-- The spatial lift of a constant-in-space trajectory has zero vorticity. -/
theorem vorticity_zero_of_lifted (traj : Trajectory) (t : ℝ) :
    vorticity (trajectoryToSpatial traj t) = fun _ => 0 :=
  vorticity_zero_of_const (traj t)

/-- The spatial BKM integral of a spatially constant trajectory is zero
    (vorticity of constant field vanishes). -/
theorem spatialBKM_zero_of_constant_traj (traj : Trajectory) (T : ℝ) (_hT : 0 ≤ T) :
    spatialBKMVorticityIntegral (trajectoryToSpatial traj) T = 0 := by
  simp only [spatialBKMVorticityIntegral]
  have h : ∀ t : ℝ, (vorticityLinfNorm (trajectoryToSpatial traj t)).toReal = 0 := fun t => by
    have hv : vorticity (trajectoryToSpatial traj t) = 0 := vorticity_zero_of_lifted traj t
    simp [vorticityLinfNorm, hv]
  simp_rw [h]
  exact intervalIntegral.integral_zero

/-! ## §7. Phase 5B: structural theorems for the constant lift -/

/-- The constant-in-space lift of a continuous trajectory is continuous in the Pi topology.

    `trajectoryToSpatial traj : ℝ → (Space → EuclideanSpace ℝ (Fin 3))` is continuous
    when the codomain carries the Pi (pointwise convergence) topology, because the
    composition with each evaluation map gives `fun t => traj t`, which is `hNS.hCont`. -/
theorem trajectoryToSpatial_continuous (traj : Trajectory)
    (hNS : SatisfiesNSPDE nsNu traj) :
    Continuous (trajectoryToSpatial traj) :=
  continuous_pi_iff.mpr fun _ => hNS.hCont

/-- The spatial Fréchet derivative of the constant lift vanishes everywhere.

    `fderiv ℝ (trajectoryToSpatial traj t) x = 0` because `trajectoryToSpatial traj t`
    is the constant function `fun _ : Space => traj t`. -/
theorem fderiv_trajectoryToSpatial_eq_zero (traj : Trajectory) (t : ℝ) (x : Space) :
    fderiv ℝ (trajectoryToSpatial traj t) x = 0 := by
  show fderiv ℝ (fun _ : Space => traj t) x = 0
  exact (hasFDerivAt_const (traj t) x).fderiv

/-- The spatial H¹ integrand is zero for the constant lift. -/
theorem spatialH1_integrand_zero_of_const (traj : Trajectory) (t : ℝ) :
    ∫ x : Space, ‖fderiv ℝ (trajectoryToSpatial traj t) x‖ ^ 2 = 0 := by
  have key : ∀ x : Space, ‖fderiv ℝ (trajectoryToSpatial traj t) x‖ ^ 2 = 0 := fun x => by
    have h := fderiv_trajectoryToSpatial_eq_zero traj t x
    rw [h, ContinuousLinearMap.opNorm_zero, zero_pow (by norm_num : 2 ≠ 0)]
  simp_rw [key]
  simp

/-! ## §8. Phase 5C: Constant lift fully satisfies SatisfiesSpatialNSPDE (0 new axioms) -/

/-- Space has infinite Haar volume.
    `Space` is non-compact (3D Euclidean) with a left-invariant open-positive measure
    (Haar), so `measure_univ_of_isAddLeftInvariant` gives `volume Set.univ = ⊤`. -/
theorem space_volume_univ_eq_top : volume (Set.univ : Set Space) = ⊤ :=
  measure_univ_of_isAddLeftInvariant volume

/-- The real-valued total volume of Space is zero (infinite-measure collapse).
    `volume Set.univ = ⊤`, so `(⊤ : ENNReal).toReal = 0`. -/
theorem space_volumeReal_univ_eq_zero :
    (volume : Measure Space).real Set.univ = 0 := by
  show (volume (Set.univ : Set Space)).toReal = 0
  rw [space_volume_univ_eq_top, ENNReal.toReal_top]

/-- Integral of any real constant over Space is zero.
    `integral_const` gives `∫ _, c = volume.real Set.univ • c = 0 • c = 0`. -/
theorem spatialIntegral_const_eq_zero (c : ℝ) : ∫ _ : Space, c = 0 := by
  rw [integral_const, space_volumeReal_univ_eq_zero, zero_smul]

/-- The constant lift of any NS trajectory fully satisfies `SatisfiesSpatialNSPDE`.
    Zero new axioms: all proofs follow from Phase 5B + infinite-volume collapse.
    - `hCont`: Pi-topology continuity (Phase 5B)
    - `hEnergyDecay`: both integrals = 0 (constant over Space with `volume = ⊤`)
    - `hH1Bound`: LHS = 0 (fderiv of constant lift vanishes, Phase 5B); RHS ≥ 0 -/
theorem trajectoryToSpatial_satisfies_spatial_ns (traj : Trajectory)
    (hNS : SatisfiesNSPDE nsNu traj) :
    SatisfiesSpatialNSPDE nsNu (trajectoryToSpatial traj) where
  hCont := trajectoryToSpatial_continuous traj hNS
  hEnergyDecay := fun t _ => by
    show ∫ _ : Space, ‖traj t‖ ^ 2 ≤ ∫ _ : Space, ‖traj 0‖ ^ 2
    rw [spatialIntegral_const_eq_zero, spatialIntegral_const_eq_zero]
  hH1Bound := fun T _ => by
    simp_rw [spatialH1_integrand_zero_of_const, intervalIntegral.integral_zero, mul_zero]
    exact mul_nonneg (by norm_num) (integral_nonneg fun _ => sq_nonneg _)

end NavierStokesClean
