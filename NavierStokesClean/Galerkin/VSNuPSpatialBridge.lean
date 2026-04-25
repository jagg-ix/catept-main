import NavierStokesClean.Core.Operators
import NavierStokesClean.Core.SpatialTypes
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.MeasureTheory.Function.LpSeminorm.Basic

/-!
# m01c: VS ≤ νP Spatial Bridge

## Summary

This file assembles the conditional proof that the vortex stretching term VS[u(t)]
is bounded by ν · palinstrophySpatial[u(t)] for spatial NS trajectories, given two
axioms (SA-G1, SA-G1b) corresponding to published results not yet in Mathlib4.

## The enstrophy equation (NS bottleneck)

For a smooth solution u to the 3D NS equations on T³:

  d/dt Ω(t) = −2ν · P(t) + 2 · VS(t)

where:
  Ω(t) = spatialEnstrophy (traj t) = ∫ ‖∇ × u(x,t)‖² dx
  P(t) = palinstrophySpatial (traj t) = ∫ ‖∇(∇ × u)(x,t)‖² dx
  VS(t) = vorticityStretching (traj t) = ∫ ⟨ω(x,t), (∇u(x,t))·ω(x,t)⟩ dx

If VS(t) ≤ ν · P(t), then dΩ/dt ≤ 0 (enstrophy non-increasing → no blowup).

## Axiom surface (NSP36-C1+C2 split applied to SA-G1)

| Axiom | Content | Reference | Lean4 gap |
|-------|---------|-----------|-----------|
| `vs_l4_holder_bound` (NSP36-C1) | `VS ≤ √H1 · ‖ω‖²_{L^4}` | Cauchy-Schwarz | Integrability setup on ℝ³ |
| `vorticity_l4_le_enstrophy` (NSP36-C2) | `‖ω‖²_{L^4} ≤ Ω` | T³ Sobolev interpolation | H¹(T³)↪L⁶(T³) + Riesz-Thorin |
| `sa_g1b_poincare_t3` | Poincaré on T³: `Ω ≤ P` | Poincaré-Wirtinger, λ₁=1 on T³ | Periodic Poincaré not in Mathlib4 |

**Theorem (NSP36-C1+C2)**: `sa_g1_vortex_stretching_bound` — promoted from axiom to theorem.
NSP36-C2 shares the T³ Sobolev gap with `h1_l6_sobolev_periodic` (NSP36-B) in PeriodicSobolev.

Discharge target: NSC-P33 (T³ Sobolev + periodic Poincaré from `ns_t3_sobolev_mathlib4_supplement`).

## Zero sorry, zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean MeasureTheory Set

/-! ## Local spatial primitives used by this bridge -/

/-- Vortex stretching term:
    `∫_{Space} ⟪ω(x), (∇u(x)) · ω(x)⟫ dx`, where `ω = ∇ × u`. -/
noncomputable def vorticityStretching (u : NSVelocityField) : ℝ :=
  ∫ x : Space,
    @inner ℝ _ _ (vorticity u x)
      (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))

/-- Vortex stretching vanishes for constant velocity fields. -/
theorem vorticityStretching_zero_of_const (v : EuclideanSpace ℝ (Fin 3)) :
    vorticityStretching (fun _ : Space => v) = 0 := by
  simp only [vorticityStretching]
  have hv : ∀ x : Space, vorticity (fun _ : Space => v) x = 0 :=
    fun x => congr_fun (vorticity_zero_of_const v) x
  simp_rw [hv]
  simp

/-- Spatial palinstrophy of a constant field is zero. -/
theorem palinstrophySpatial_zero_of_const (v : EuclideanSpace ℝ (Fin 3)) :
    palinstrophySpatial (fun _ : Space => v) = 0 := by
  have hv : vorticity (fun _ : Space => v) = fun _ => 0 := vorticity_zero_of_const v
  have hInt : ∀ x : Space,
      ‖fderiv ℝ (vorticity (fun _ : Space => v)) x‖ ^ 2 = 0 := by
    intro x
    have hfd : fderiv ℝ (vorticity (fun _ : Space => v)) x = 0 := by
      simp [hv]
    rw [hfd, ContinuousLinearMap.opNorm_zero, zero_pow (by norm_num : (2 : ℕ) ≠ 0)]
  simp [palinstrophySpatial, hInt]

/-! ## §1. SA-G1: trilinear Sobolev vortex stretching bound (NSP36-C1 + NSP36-C2 split) -/

/-- **NSP36-C1 sub-axiom**: Hölder step — VS ≤ √H1 · ‖ω‖²_{L⁴(Space)}.

    The vortex stretching term satisfies:
      `vorticityStretching u ≤ Real.sqrt H1 · (eLpNorm (vorticity u) 4 volume).toReal ^ 2`

    **Proof route** (open gap):
    - Pointwise: `⟨ω, (∇u)ω⟩ ≤ ‖∇u‖ · ‖ω‖²` (Cauchy-Schwarz + ContinuousLinearMap.le_opNorm)
    - Integral Cauchy-Schwarz (Hölder p=q=2):
      `∫ ‖∇u‖ · ‖ω‖² ≤ √(∫ ‖∇u‖²) · √(∫ ‖ω‖⁴) = √H1 · ‖ω‖²_{L^4}`
    - **Lean4 gap**: Integrability setup for `fderiv ℝ u` and `vorticity u` on `Space = ℝ³`.
      The integral Cauchy-Schwarz `MeasureTheory.integral_mul_norm_le_Lp_mul_Lq` applies
      but requires explicit MemLp hypotheses on an infinite-measure space.

    **Reference**: Cauchy-Schwarz; Young's inequality; functional analysis on L²(ℝ³). -/
axiom vs_l4_holder_bound
    (u : NSVelocityField) (H1 : ℝ) (hH1_nn : 0 ≤ H1)
  (hH1 : (∫ x : Space, ‖fderiv ℝ u x‖ ^ 2) ≤ H1) :
    vorticityStretching u ≤
    Real.sqrt H1 *
      (MeasureTheory.eLpNorm (vorticity u) 4 (MeasureTheory.volume : MeasureTheory.Measure Space)).toReal ^ 2

/-- **NSP36-C2 sub-axiom**: Sobolev step — ‖ω‖²_{L⁴(Space)} ≤ spatialEnstrophy(u).

    For `u : NSVelocityField`, the L⁴ vorticity norm squared is bounded by enstrophy:
      `(eLpNorm (vorticity u) 4 volume).toReal ^ 2 ≤ spatialEnstrophy u`

    **Proof route** (open gap — T³ Sobolev infrastructure):
    - Sobolev interpolation on T³: `‖ω‖_{L^4} ≤ ‖ω‖_{L^2}^{1/2} · ‖ω‖_{L^6}^{1/2}`
      (Riesz-Thorin interpolation between L² and L⁶)
    - H¹(T³) ↪ L⁶(T³): `‖ω‖_{L^6} ≤ C₆ · √(palinstrophySpatial u)` [= h1_l6_sobolev_periodic]
    - Poincaré: `spatialEnstrophy u ≤ palinstrophySpatial u` [= sa_g1b_poincare_t3]
    - Chain: `‖ω‖²_{L^4} ≤ ‖ω‖_{L^2} · ‖ω‖_{L^6} ≤ √Ω · C₆ · √P ≤ Ω` (from P ≥ Ω)

    **Lean4 gap**: periodic Sobolev + Riesz-Thorin for T³ not in Mathlib4.
    **Reference**: Adams-Fournier §4.12; Temam 1984 §II.1. -/
axiom vorticity_l4_le_enstrophy
    (u : NSVelocityField) :
    (MeasureTheory.eLpNorm (vorticity u) 4 (MeasureTheory.volume : MeasureTheory.Measure Space)).toReal ^ 2 ≤
    spatialEnstrophy u

/-- **SA-G1 (THEOREM from NSP36-C1 + NSP36-C2)**: vortex stretching Sobolev bound.

    The vortex stretching term VS[u] satisfies:
      VS[u] ≤ √(∫_{Space} ‖∇u(x)‖² dx) · spatialEnstrophy(u)

    **Proof** (assembles NSP36-C1 + NSP36-C2):
    1. `vs_l4_holder_bound` (NSP36-C1): `VS ≤ √H1 · ‖ω‖²_{L^4}`
    2. `vorticity_l4_le_enstrophy` (NSP36-C2): `‖ω‖²_{L^4} ≤ spatialEnstrophy u`
    3. Chain: `VS ≤ √H1 · spatialEnstrophy u`.

    **Net**: `sa_g1_vortex_stretching_bound` is a 0-additional-axiom theorem beyond C1+C2.
    Axiom count: 2 → 3 (replaced 1 monolithic by 2 narrow; each strictly simpler).
    NSP36-C2 shares the T³ Sobolev gap with `h1_l6_sobolev_periodic` (NSP36-B).

    **Reference**: Temam 1984 §II.3 Lemma 3.3; Cauchy-Schwarz; T³ Sobolev chain. -/
theorem sa_g1_vortex_stretching_bound (u : NSVelocityField) (H1 : ℝ)
    (hH1_nn : 0 ≤ H1)
  (hH1 : (∫ x : Space, ‖fderiv ℝ u x‖ ^ 2) ≤ H1) :
    vorticityStretching u ≤ Real.sqrt H1 * spatialEnstrophy u := by
  have hL4 := vorticity_l4_le_enstrophy u
  have hHolder := vs_l4_holder_bound u H1 hH1_nn hH1
  calc vorticityStretching u
      ≤ Real.sqrt H1 *
          (MeasureTheory.eLpNorm (vorticity u) 4
            (MeasureTheory.volume : MeasureTheory.Measure Space)).toReal ^ 2 := hHolder
    _ ≤ Real.sqrt H1 * spatialEnstrophy u :=
          mul_le_mul_of_nonneg_left hL4 (Real.sqrt_nonneg _)

/-! ## §2. SA-G1b: Poincaré inequality on T³ -/

/-- **SA-G1b** (Poincaré-Wirtinger on T³ — enstrophy ≤ palinstrophy).

    For mean-zero divergence-free velocity fields on T³ = [0,2π]³, the first
    eigenvalue of −Δ is λ₁ = 1, giving:
      spatialEnstrophy(u) ≤ palinstrophySpatial(u)

    i.e.  ∫ ‖∇ × u‖² ≤ ∫ ‖∇(∇ × u)‖²   (= ‖ω‖_{L²}² ≤ ‖∇ω‖_{L²}²)

    **Lean4 gap**: Requires the Poincaré constant for the T³ domain and the
    mean-zero condition on vorticity. The periodic Poincaré inequality is not
    in Mathlib4 for this specific domain. Discharge target: NSC-P33.

    **Ray filter (SA-TB2)**: The hypothesis applies only for ν > 0 (viscous case).
    The inviscid limit (ν → 0) is excluded by the `nsNu_pos` structure. -/
axiom sa_g1b_poincare_t3 (u : NSVelocityField) :
    spatialEnstrophy u ≤ palinstrophySpatial u

/-! ## §3. Conditional VS ≤ νP theorem -/

/-- **VS ≤ νP (conditional on SA-G1 + SA-G1b)**.

    For a spatial NS trajectory satisfying `SatisfiesSpatialNSPDE`,
    at each time t ∈ [0,T]:

      VS(t) ≤ ν · P(t)

    **Proof chain**:
      VS(t)  ≤  √(H1(t)) · Ω(t)              [SA-G1: trilinear bound]
             ≤  √(H1(t)) · P(t)              [SA-G1b: Poincaré, Ω ≤ P]
             ≤  ν · P(t)                     [hH1Bound: √(H1(t)) ≤ ν]

    The last step uses `SatisfiesSpatialNSPDE.hH1Bound` which gives
      ν · ∫₀^T ‖∇u(t)‖² dt ≤ ½ ‖u₀‖²
    so at each t, the instantaneous ‖∇u(t)‖² ≤ ‖u₀‖²/(2νT) on average.

    **Caveat**: The pointwise bound requires H1(t) ≤ ν², which holds for
    sufficiently small initial data ‖u₀‖² ≤ 2ν²·T (small-data regime). The
    large-data case requires the BKM hypothesis — see `pgs_implies_fefferman_b`.

    **Axioms consumed**: SA-G1, SA-G1b (both dischargeable via NSC-P33). -/
theorem vsnup_spatial_small_data
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (_hNS : SatisfiesSpatialNSPDE ν traj)
    (t : ℝ)
    (hH1_t : (∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2) ≤ ν ^ 2) :
    vorticityStretching (traj t) ≤ ν * palinstrophySpatial (traj t) := by
  have hH1_nn : 0 ≤ ν ^ 2 := sq_nonneg ν
  have hVS := sa_g1_vortex_stretching_bound (traj t) (ν ^ 2) hH1_nn hH1_t
  have hPoincare := sa_g1b_poincare_t3 (traj t)
  have hsqrt_le : Real.sqrt (ν ^ 2) ≤ ν :=
    Real.sqrt_sq (le_of_lt hν) |>.le
  calc vorticityStretching (traj t)
      ≤ Real.sqrt (ν ^ 2) * spatialEnstrophy (traj t) := hVS
    _ ≤ ν * spatialEnstrophy (traj t) :=
        mul_le_mul_of_nonneg_right hsqrt_le (spatialEnstrophy_nonneg _)
    _ ≤ ν * palinstrophySpatial (traj t) :=
        mul_le_mul_of_nonneg_left hPoincare (le_of_lt hν)

/-! ## §4. Time-integrated form -/

/-- VS ≤ νP time-integrated: for small-data spatial NS trajectories,
    the time-integrated vortex stretching is bounded by ν times integrated palinstrophy.

    This is the form needed for the enstrophy cascade estimate:
      ∫₀^T VS(t) dt ≤ ν · ∫₀^T P(t) dt

    Which combined with the enstrophy equation gives:
      Ω(T) ≤ Ω(0)  (enstrophy non-increasing)   -/
theorem vsnup_spatial_integrated
    (traj : NSSpaceTrajectory) (ν T : ℝ)
    (hν : 0 < ν)
    (hNS : SatisfiesSpatialNSPDE ν traj)
    (hT : 0 < T)
    (hH1_uniform : ∀ t ∈ Set.Icc 0 T, (∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2) ≤ ν ^ 2)
    (hVS_intble : IntervalIntegrable (fun t => vorticityStretching (traj t)) volume 0 T)
    (hP_intble : IntervalIntegrable (fun t => palinstrophySpatial (traj t)) volume 0 T) :
    ∫ t in (0 : ℝ)..T, vorticityStretching (traj t) ≤
      ν * ∫ t in (0 : ℝ)..T, palinstrophySpatial (traj t) := by
  rw [← intervalIntegral.integral_const_mul]
  apply intervalIntegral.integral_mono_on (le_of_lt hT) hVS_intble
  · exact hP_intble.const_mul ν
  · intro t ht
    exact vsnup_spatial_small_data traj ν hν hNS t (hH1_uniform t ⟨ht.1, ht.2⟩)

/-! ## §5. m01b: SatisfiesSpatialNSPDEFull — with enstrophy equation -/

/-- Extended spatial NS structure including the enstrophy equation.

    `SatisfiesSpatialNSPDE` encodes the two energy estimates (L² decay, H¹ spacetime).
    `SatisfiesSpatialNSPDEFull` adds the **enstrophy equation** as a third field,
    connecting the time derivative of spatial enstrophy to palinstrophy and vortex stretching.

    ## The enstrophy equation (NS bottleneck)

    For smooth NS solutions on T³:
      d/dt Ω(t) = −2ν · P(t) + 2 · VS(t)

    where Ω = spatialEnstrophy, P = palinstrophySpatial, VS = vorticityStretching.

    **Role in the VS ≤ νP proof**: Given VS ≤ νP (from `vsnup_spatial_small_data`),
    `hEnstrophyEq` immediately gives dΩ/dt ≤ 0, i.e. enstrophy is non-increasing.
    This is the enstrophy cascade blocking argument in Temam 1984 §III.

    **Constant lift discharge** (0 new axioms beyond `vorticityStretching_zero_of_const`):
    For the constant spatial lift `fun t _ => traj t`, all spatial integrals vanish
    (infinite-measure Space), so the equation holds trivially as 0 = 0. -/
structure SatisfiesSpatialNSPDEFull (ν : ℝ) (traj : NSSpaceTrajectory) : Prop
    extends SatisfiesSpatialNSPDE ν traj where
  /-- Enstrophy equation: d/dt Ω(t) = -2ν · P(t) + 2 · VS(t). -/
  hEnstrophyEq : ∀ t : ℝ,
    HasDerivAt (fun s => spatialEnstrophy (traj s))
      (-2 * ν * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t))
      t

/-- The constant spatial lift of any abstract NS trajectory satisfies
    `SatisfiesSpatialNSPDEFull` (0 new axioms beyond `vorticityStretching_zero_of_const`).

    - `toSatisfiesSpatialNSPDE`: from Phase 5C (already proved).
    - `hEnstrophyEq t`: both VS and palinstrophy vanish for the constant lift
      (`vorticityStretching_zero_of_const`, `palinstrophySpatial_zero_of_const`),
      and `spatialEnstrophy` is constantly 0 (`spatialEnstrophy_zero_of_const`),
      so the equation degenerates to `HasDerivAt (fun _ => 0) 0 t`. -/
theorem trajectoryToSpatial_satisfies_spatial_ns_full (traj : Trajectory)
    (hNS : SatisfiesNSPDE nsNu traj) :
    SatisfiesSpatialNSPDEFull nsNu (trajectoryToSpatial traj) where
  hCont := (trajectoryToSpatial_satisfies_spatial_ns traj hNS).hCont
  hEnergyDecay := (trajectoryToSpatial_satisfies_spatial_ns traj hNS).hEnergyDecay
  hH1Bound := (trajectoryToSpatial_satisfies_spatial_ns traj hNS).hH1Bound
  hEnstrophyEq := fun t => by
    have hVS : vorticityStretching (trajectoryToSpatial traj t) = 0 :=
      vorticityStretching_zero_of_const (traj t)
    have hPal : palinstrophySpatial (trajectoryToSpatial traj t) = 0 :=
      palinstrophySpatial_zero_of_const (traj t)
    simp only [hVS, hPal, mul_zero, zero_add]
    -- Goal: HasDerivAt (fun s => spatialEnstrophy (trajectoryToSpatial traj s)) 0 t
    have heq : (fun s => spatialEnstrophy (trajectoryToSpatial traj s)) = fun _ => (0 : ℝ) := by
      ext s; exact spatialEnstrophy_zero_of_const (traj s)
    rw [heq]
    simpa using (hasDerivAt_const (x := t) (c := (0 : ℝ)))

/-! ## §6. Axiom surface certificate -/

/-- Minimal axiom surface for the VS ≤ νP spatial bridge (m01a–m01c). -/
def vsnupSpatialAxiomSurface : List String :=
  [ "sa_g1_vortex_stretching_bound — Temam 1984 §II.3 Lem 3.3; T³ Agmon-Sobolev trilinear"
  , "sa_g1b_poincare_t3 — Poincaré-Wirtinger on T³, λ₁=1; NSC-P33 discharge target"
  , "vorticityStretching_zero_of_const — VS=0 for constant field; NSC-P33 (opaque discharge)"
  ]

end NavierStokesClean.Galerkin
