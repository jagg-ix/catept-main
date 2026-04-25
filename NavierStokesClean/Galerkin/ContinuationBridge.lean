import NavierStokesClean.Galerkin.EnstrophyNonIncrease
import NavierStokesClean.Core.EnergyFunctionals
import NavierStokesClean.Sobolev.PeriodicSobolev

/-!
# m05: Continuation Bridge

## Summary

This file assembles the **continuation bridge** — the passage from energy control
to BKM integral boundedness — in two lanes:

### Lane A: Abstract continuation (0 new axioms)

For abstract NS trajectories `traj : Trajectory` satisfying `SatisfiesNSPDE`,
`hEnergyDecay` gives `‖traj t‖ ≤ ‖traj 0‖` for all t ≥ 0. Since
  `bkmVorticityIntegral traj T = ∫₀^T ‖traj t‖² dt ≤ T · ‖traj 0‖²`
by monotone integration, the abstract BKM integral is bounded by `T · Ω₀`.

This is a **pure theorem** (0 new axioms) complementing the EPT algebraic identity.
While the EPT gives equality `BKM = (ħ/ν)·τ_ent`, this gives the energy-decay bound
`BKM ≤ T · Ω₀` which is physically the correct form of the continuation estimate.

### Lane B: Spatial continuation (conditional on SA-M05-Agmon)

For spatial NS trajectories satisfying `SatisfiesSpatialNSPDEFull`, the Agmon–Sobolev
inequality on T³ gives a pointwise L^∞ vorticity bound:
  `‖ω(t)‖_{L^∞} ≤ √(P(t) · Ω(t)) ≤ √(P(t) · Ω₀)`
using enstrophy non-increase (m04) and:

**SA-M05-Agmon** (new axiom, NSC-P33 target):
  `(vorticityLinfNorm u).toReal ≤ √(palinstrophySpatial u · spatialEnstrophy u)`

This is the Agmon–Sobolev inequality on T³: L^∞ norm bounded by geometric mean of
H¹ seminorm and L² norm of vorticity. Blocked on T³ Sobolev infrastructure (NSC-P33).

## Axiom surface

| Axiom | Content | Reference | Lean4 gap |
|-------|---------|-----------|-----------|
| SA-M05-Agmon | `‖ω‖_{L^∞} ≤ √(P·Ω)` on T³ | Agmon 1965; Temam §II.2 | T³ Sobolev; NSC-P33 |

SA-G1, SA-G1b from m01 consumed by `enstrophy_antitoneOn_small_data` (via m04).

## Zero sorry, zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean MeasureTheory Set

/-! ## §1. Abstract energy continuation bound (0 new axioms) -/

/-- **BKM integral bounded by T · initial enstrophy** (m05 Lane A).

    For any abstract NS trajectory satisfying `SatisfiesNSPDE`:
      bkmVorticityIntegral traj T ≤ T · enstrophy (traj 0)

    **Proof**: `hEnergyDecay` gives `‖traj t‖ ≤ ‖traj 0‖` for all t ≥ 0,
    so `enstrophy (traj t) = ‖traj t‖² ≤ ‖traj 0‖² = enstrophy (traj 0)`.
    Monotone integration over [0,T] and `∫₀^T Ω₀ dt = T · Ω₀`.

    **Comparison with EPT**: the EPT gives `BKM = (ħ/ν)·τ_ent` exactly.
    This bound is weaker but physically natural: energy decay prevents enstrophy
    accumulation, bounding the time-integrated BKM integral by time × initial energy.

    **Axioms consumed**: 0 (pure Mathlib interval integral + `hEnergyDecay`). -/
theorem bkm_le_time_init_enstrophy
    (traj : Trajectory)
    (hNS : SatisfiesNSPDE nsNu traj)
    (hEnergyDecay : ∀ t : ℝ, 0 ≤ t → ‖traj t‖ ≤ ‖traj 0‖)
    (T : ℝ)
    (hT : 0 ≤ T) :
    bkmVorticityIntegral traj T ≤ T * enstrophy (traj 0) := by
  unfold bkmVorticityIntegral integratedEnstrophy
  have hpoint : ∀ t ∈ Icc (0 : ℝ) T,
      enstrophy (traj t) ≤ enstrophy (traj 0) := fun t ht => by
    unfold enstrophy
    nlinarith [norm_nonneg (traj t), hEnergyDecay t ht.1]
  calc ∫ t in (0 : ℝ)..T, enstrophy (traj t)
      ≤ ∫ t in (0 : ℝ)..T, enstrophy (traj 0) := by
        apply intervalIntegral.integral_mono_on hT
        · exact (hNS.hCont.norm.pow 2).intervalIntegrable 0 T
        · exact intervalIntegrable_const
        · exact hpoint
    _ = T * enstrophy (traj 0) := by
        rw [intervalIntegral.integral_const, sub_zero]
        simp [smul_eq_mul]

/-- **BKM integral is finite** for all T ≥ 0, directly from energy decay.

    This is a sharper proof of `BKMIntegralFiniteAt` than via `pgs_ept_witness`:
    the witness is explicitly `T · enstrophy (traj 0)`.

    **Axioms consumed**: 0. -/
theorem bkm_finite_from_energy_decay
    (traj : Trajectory)
    (hNS : SatisfiesNSPDE nsNu traj)
    (hEnergyDecay : ∀ t : ℝ, 0 ≤ t → ‖traj t‖ ≤ ‖traj 0‖)
    (T : ℝ)
    (hT : 0 ≤ T) :
    BKMIntegralFiniteAt traj T :=
  ⟨T * enstrophy (traj 0), bkm_le_time_init_enstrophy traj hNS hEnergyDecay T hT⟩

/-! ## §2. SA-M05-Agmon: Agmon–Sobolev inequality on T³ -/

/-- **SA-M05-Agmon** (Agmon 1965 — T³ L^∞ vorticity bound).

    For C² velocity field `u : NSVelocityField`:
      `‖ω‖_{L^∞} ≤ √(P · Ω)` where P = ∫‖∇ω‖², Ω = ∫‖ω‖².

    **THEOREM** (promoted from axiom, 2026-03-30):
    `agmon_h2_linfty_periodic` (NSP38-C in `Sobolev/PeriodicSobolev.lean`) gives the squared
    form `‖ω‖²_{L^∞} ≤ P · Ω` for C² velocity fields. `sa_m05_agmon_t3_from_sub` takes sqrt.
    This file wraps the result under the original name with an explicit smoothness hypothesis.

    **Net**: `sa_m05_agmon_t3` is now a 0-axiom theorem (beyond `agmon_h2_linfty_periodic`).
    Axiom count: 14 → 13.

    **Reference**: Agmon 1965 Thm 13.2; Temam 1984 §II.2; FMRT 2001 §2.3. -/
theorem sa_m05_agmon_t3 (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u) :
    (vorticityLinfNorm u).toReal ≤
    Real.sqrt (palinstrophySpatial u * spatialEnstrophy u) :=
  NavierStokesClean.Sobolev.sa_m05_agmon_t3_from_sub u hSmooth

/-! ## §3. Pointwise spatial vorticity bound (SA-M05-Agmon + m04) -/

/-- **Pointwise L^∞ vorticity bound using enstrophy non-increase** (m05 Lane B).

    For small-data spatial NS trajectories satisfying `SatisfiesSpatialNSPDEFull`,
    combining Agmon (SA-M05-Agmon) with enstrophy non-increase (m04) gives:
      ‖ω(t)‖_{L^∞} ≤ √(palinstrophySpatial (traj t) · spatialEnstrophy (traj 0))

    Chain:
      ‖ω(t)‖_{L^∞} ≤ √(P(t) · Ω(t))     [SA-M05-Agmon]
                    ≤ √(P(t) · Ω₀)        [Ω(t) ≤ Ω₀ from enstrophy_antitoneOn_small_data]

    **Semantic gap** (`hCont`): same as in `enstrophy_antitoneOn_small_data` — explicit
    continuity hypothesis until NSC-P33 supplies integral parameter continuity.

    **Smoothness hypothesis** (`hSmooth : ContDiff ℝ 2 (traj t)`): needed by `sa_m05_agmon_t3`
    (which delegates to `agmon_h2_linfty_periodic` — the NSP38-C axiom).
    **Axioms consumed**: `agmon_h2_linfty_periodic` (NSP38-C; via `sa_m05_agmon_t3`);
    SA-G1, SA-G1b (via m04). -/
theorem vorticityLinf_pointwise_le
    (traj : NSSpaceTrajectory) (ν : ℝ) (t T : ℝ)
    (hν : 0 < ν)
    (_hT : 0 ≤ T)
    (ht : t ∈ Icc (0 : ℝ) T)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (hH1 : ∀ s ∈ Icc (0 : ℝ) T,
      ∫ x : Space, ‖fderiv ℝ (traj s) x‖ ^ 2 ≤ ν ^ 2)
    (hCont : ContinuousOn (fun s => spatialEnstrophy (traj s)) (Icc (0 : ℝ) T))
    (hSmooth : ContDiff ℝ 2 (traj t)) :
    (vorticityLinfNorm (traj t)).toReal ≤
    Real.sqrt (palinstrophySpatial (traj t) * spatialEnstrophy (traj 0)) := by
  -- Step 1: enstrophy non-increase → Ω(t) ≤ Ω₀
  -- Apply enstrophy_antitoneOn_small_data restricted to [0, t] ⊆ [0, T]
  have hΩ : spatialEnstrophy (traj t) ≤ spatialEnstrophy (traj 0) :=
    enstrophy_antitoneOn_small_data traj ν 0 t ht.1 hν hFull
      (fun s hs => hH1 s ⟨hs.1, le_trans hs.2 ht.2⟩)
      (hCont.mono (Icc_subset_Icc_right ht.2))
  -- Step 2: Agmon gives ‖ω(t)‖_{L^∞} ≤ √(P(t) · Ω(t))
  --         (from sa_m05_agmon_t3 = sa_m05_agmon_t3_from_sub, promoted from agmon_h2_linfty_periodic)
  have hAgmon := sa_m05_agmon_t3 (traj t) hSmooth
  -- Step 3: monotonicity of sqrt (P(t) · Ω(t) ≤ P(t) · Ω₀)
  have hPnn := palinstrophySpatial_nonneg (traj t)
  calc (vorticityLinfNorm (traj t)).toReal
      ≤ Real.sqrt (palinstrophySpatial (traj t) * spatialEnstrophy (traj t)) := hAgmon
    _ ≤ Real.sqrt (palinstrophySpatial (traj t) * spatialEnstrophy (traj 0)) :=
        Real.sqrt_le_sqrt (mul_le_mul_of_nonneg_left hΩ hPnn)

/-! ## §4. Time-integrated spatial BKM bounds (theoremized under explicit hypotheses) -/

/-- Uniform pointwise control implies an integrated spatial BKM bound.

    If `‖ω(t)‖_{L^∞} ≤ B` for all `t ∈ [0,T]` and the integrand is interval-integrable,
    then `∫₀ᵀ ‖ω(t)‖_{L^∞} dt ≤ T · B`.

    This is a pure interval-integral estimate (`integral_mono_on` + `integral_const`). -/
theorem spatialBKM_le_time_mul_uniform_bound
    (traj : NSSpaceTrajectory)
    (T : ℝ)
    (hT : 0 ≤ T)
    (B : ℝ)
    (hInt : IntervalIntegrable
      (fun t => (vorticityLinfNorm (traj t)).toReal) volume (0 : ℝ) T)
    (hBound : ∀ t ∈ Icc (0 : ℝ) T, (vorticityLinfNorm (traj t)).toReal ≤ B) :
    spatialBKMVorticityIntegral traj T ≤ T * B := by
  unfold spatialBKMVorticityIntegral
  calc
    ∫ t in (0 : ℝ)..T, (vorticityLinfNorm (traj t)).toReal
        ≤ ∫ t in (0 : ℝ)..T, B := by
          apply intervalIntegral.integral_mono_on hT hInt intervalIntegrable_const
          intro t ht
          exact hBound t ht
    _ = T * B := by
      rw [intervalIntegral.integral_const, sub_zero]
      simp [smul_eq_mul]

/-- Integrated spatial BKM bound from Agmon + enstrophy non-increase + uniform palinstrophy.

    On `[0,T]`, assume:
    - small-data H¹ control and enstrophy continuity (for the m04 antitone step),
    - `ContDiff ℝ 2 (traj t)` pointwise (for `sa_m05_agmon_t3`),
    - uniform palinstrophy bound `palinstrophySpatial (traj t) ≤ Pmax`,
    - interval-integrability of `t ↦ ‖ω(t)‖_{L^∞}`.

    Then
      `∫₀ᵀ ‖ω(t)‖_{L^∞} dt ≤ T · √(Pmax · Ω₀)`
    where `Ω₀ = spatialEnstrophy (traj 0)`.

    This theorem isolates the remaining bridge to full NSC-P38 discharge to a concrete
    hypothesis (`Pmax`) rather than an axiom-level placeholder. -/
theorem spatialBKM_le_time_mul_agmon_uniform_palinstrophy
    (traj : NSSpaceTrajectory) (ν T : ℝ)
    (hν : 0 < ν)
    (hT : 0 ≤ T)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (hH1 : ∀ s ∈ Icc (0 : ℝ) T,
      ∫ x : Space, ‖fderiv ℝ (traj s) x‖ ^ 2 ≤ ν ^ 2)
    (hCont : ContinuousOn (fun s => spatialEnstrophy (traj s)) (Icc (0 : ℝ) T))
    (hSmooth : ∀ s ∈ Icc (0 : ℝ) T, ContDiff ℝ 2 (traj s))
    (Pmax : ℝ)
    (hPal : ∀ s ∈ Icc (0 : ℝ) T, palinstrophySpatial (traj s) ≤ Pmax)
    (hInt : IntervalIntegrable
      (fun t => (vorticityLinfNorm (traj t)).toReal) volume (0 : ℝ) T) :
    spatialBKMVorticityIntegral traj T ≤
      T * Real.sqrt (Pmax * spatialEnstrophy (traj 0)) := by
  apply spatialBKM_le_time_mul_uniform_bound traj T hT
    (Real.sqrt (Pmax * spatialEnstrophy (traj 0))) hInt
  intro t ht
  have hPoint := vorticityLinf_pointwise_le traj ν t T hν hT ht hFull hH1 hCont
    (hSmooth t ht)
  have hMul :
      palinstrophySpatial (traj t) * spatialEnstrophy (traj 0)
        ≤ Pmax * spatialEnstrophy (traj 0) :=
    mul_le_mul_of_nonneg_right (hPal t ht) (spatialEnstrophy_nonneg (traj 0))
  exact hPoint.trans (Real.sqrt_le_sqrt hMul)

/-! ## §5. Continuation gap certificate -/

/-- Continuation gap certificate — records what remains for full spatial BKM bound.

    **Current state after m05**:
    - Lane A (abstract): `bkm_le_time_init_enstrophy` gives `BKM ≤ T · Ω₀` (0 new axioms)
    - Lane B (spatial, pointwise): `vorticityLinf_pointwise_le` gives `‖ω(t)‖_{L^∞} ≤ √(P(t)·Ω₀)`
      conditional on SA-M05-Agmon

    **Remaining gap** for time-integrated spatial BKM bound
    (`spatialBKMVorticityIntegral traj T ≤ C`):
    - Cauchy-Schwarz: `∫₀^T √P(t) dt ≤ √T · √(∫₀^T P(t) dt)` — pure Mathlib
    - **Palinstrophy H¹ bound**: `∫₀^T palinstrophySpatial (traj t) dt ≤ C`
      requires H² control of velocity (palinstrophy = ∫‖∇ω‖² ≈ ∫‖∇²u‖²),
      which is not available from `SatisfiesSpatialNSPDE.hH1Bound` (H¹ only)
    - Integrability of `t ↦ √(palinstrophySpatial (traj t))` — needs Sobolev parameter
      continuity (NSC-P33)

    **NSC-P33 discharge** would provide: T³ Sobolev embedding H²(T³) ↪ L^∞(T³)
    (refining SA-M05-Agmon) + parameter continuity of spatial integrals. -/
def continuationGapCertificate : List String :=
  [ "agmon_h2_linfty_periodic — Agmon 1965; T³ H²↪L^∞ Sobolev (NSP38-C); NSC-P33 discharge target"
  , "  (sa_m05_agmon_t3 is now a THEOREM from agmon_h2_linfty_periodic + ContDiff ℝ 2)"
  , "palinstrophy_H2_spacetime_bound — H² NS bound (not in SatisfiesSpatialNSPDE); NSC-P33"
  , "spatialBKM_integral_continuity — parameter continuity of ∫‖∇ω‖²; NSC-P33"
  ]

/-- Axiom surface for the m05 continuation bridge.
    `sa_m05_agmon_t3` has been PROMOTED TO THEOREM (from `agmon_h2_linfty_periodic` in PeriodicSobolev).
    Axiom surface: 14 → 13 (1 fewer axiom). -/
def continuationBridgeAxiomSurface : List String :=
  [ "agmon_h2_linfty_periodic — Agmon H²(T³)↪L^∞ (NSP38-C; NSC-P33 discharge target)"
  , "  NOTE: sa_m05_agmon_t3 is THEOREM proved from agmon_h2_linfty_periodic + ContDiff ℝ 2"
  ] ++ vsnupSpatialAxiomSurface

end NavierStokesClean.Galerkin
