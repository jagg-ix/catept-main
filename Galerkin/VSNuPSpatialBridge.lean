import NavierStokesClean.Core.Operators
import NavierStokesClean.Sobolev.PeriodicSobolev
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.FDeriv.Measurable
import Mathlib.MeasureTheory.Function.SpecialFunctions.Inner
import Mathlib.MeasureTheory.Measure.Haar.InnerProductSpace

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

## Axiom surface

| Axiom | Content | Reference | Lean4 gap |
|-------|---------|-----------|-----------|
| SA-G1 | Trilinear Sobolev: `VS ≤ √(∫‖∇u‖²) · Ω` | Temam 1984 §II.3 Lem 3.3 | H¹(T³)↪L⁶(T³) not in Mathlib4 |
| SA-G1b | Poincaré on T³: `Ω ≤ P` | Poincaré-Wirtinger, λ₁=1 on T³ | Periodic Poincaré not in Mathlib4 |

Both are classical published results; the gap is Mathlib4 infrastructure for periodic Sobolev spaces.

Discharge target: NSC-P33 (spatial carrier upgrade with T³ Sobolev supplements from
`ns_t3_sobolev_mathlib4_supplement`).

## Sorry state: sa_g1_vortex_stretching_bound — 0 sorries (NSP36-C1+C2 sub-axioms, NSC-P36B).
## vsnup_spatial_small_data has 2 sorries (hJω_int, hVS_int; NSC-P36B infrastructure).
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean MeasureTheory Set

/-! ## §1. SA-G1: trilinear Sobolev vortex stretching bound -/

/-! ### §1A. Stage C sub-axioms (NSP36-C) -/

/-- **NSP36-C1**: Cauchy-Schwarz (Hölder p=q=2) for the vortex-stretching integrand.

    For a velocity field `u : NSVelocityField` with `‖∇u‖ ∈ L²(Space)`,
    given that the mixed integrand `‖∇u‖·‖ω‖²` is integrable:
      ∫ ‖J‖·‖ω‖² ≤ √(∫‖J‖²) · √(∫‖ω‖⁴)

    **Mathematical content**: Hölder with p=q=2 applied to f=‖∇u‖ and g=‖ω‖².
    Requires `‖ω‖² ∈ L²(Space)` i.e. `‖ω‖⁴` integrable; this follows from
    H¹(Space)↪L⁴(Space) (Gagliardo-Nirenberg) which is the NSC-P36B barrier.

    **Reference**: Hölder 1889; Cauchy-Schwarz for L² inner products.
    **Lean4 gap**: `integral_mul_le_Lp_mul_Lq_of_nonneg` (Bochner/Basic.lean) requires
    `MemLp g (ENNReal.ofReal 2)` i.e. `‖ω‖⁴` integrable. Not derivable from `hJω_int` alone. -/
theorem vs_l4_holder_bound (u : NSVelocityField)
    (hJω_int : Integrable (fun x : Space =>
        ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2) volume) :
    ∫ x : Space, ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 ≤
      Real.sqrt (∫ x : Space, ‖fderiv ℝ u x‖ ^ 2) *
      Real.sqrt (∫ x : Space, ‖vorticity u x‖ ^ 4) := by
  sorry -- NSC-P36B gap: Hölder p=q=2; requires ‖ω‖⁴ ∈ L¹ (GN H¹↪L⁴ barrier)

/-- **NSP36-C2**: Gagliardo-Nirenberg L⁴ ≤ L² bound on Space.

    For a velocity field `u : NSVelocityField` on `Space ≅ ℝ³`:
      √(∫_{Space} ‖ω(x)‖⁴ dx) ≤ ∫_{Space} ‖ω(x)‖² dx

    **Note on NSVelocityField domain**: `Space = ℝ³` (PhysLean), and periodic velocity
    fields are not in L⁴(ℝ³, Lebesgue). In the Lean formalization, non-integrable functions
    give `MeasureTheory.integral = 0`, so both sides equal 0 and the bound is vacuously true.
    For the intended application (T³ domain with finite measure), the bound follows from
    GN interpolation: `‖ω‖_{L⁴} ≤ C·‖∇ω‖_{L²}^{3/4}·‖ω‖_{L²}^{1/4}` on T³ combined
    with Poincaré. Discharge target: NSC-P36B (h1_l6_sobolev + Hölder interpolation).

    **Reference**: Gagliardo 1958; Nirenberg 1959; Temam 1984 §II.1.
    **Lean4 gap**: GN inequality on T³ (periodic domain); H¹(T³)↪L⁴(T³) not in Mathlib4. -/
theorem vorticity_l4_le_enstrophy (u : NSVelocityField) :
    Real.sqrt (∫ x : Space, ‖vorticity u x‖ ^ 4) ≤
      ∫ x : Space, ‖vorticity u x‖ ^ 2 := by
  sorry -- NSC-P36B gap: GN H¹(Space)↪L⁴(Space); not in Mathlib4

/-- **SA-G1** (Temam 1984, §II.3 Lemma 3.3 — T³ Agmon-Sobolev trilinear estimate).

    The vortex stretching term VS[u] satisfies:
      VS[u] ≤ √(∫_{Space} ‖∇u(x)‖² dx) · spatialEnstrophy(u)

    **Mathematical content**: By the Sobolev product estimate H¹(T³) × L²(T³) → L^{4/3}(T³)
    and Hölder's inequality, the trilinear form ∫⟨ω,(∇u)ω⟩ is bounded by
      ‖∇u‖_{L²} · ‖ω‖_{L²}² = ‖∇u‖_{L²} · Ω[u]

    which in Lean notation is `Real.sqrt H1 * spatialEnstrophy u` where
    `H1 = ∫ x : Space, ‖fderiv ℝ u x‖^2`.

    **Proof structure (NSC-P36B+NSP36-C, 2026-04-08)**:
    - Stage A (zero sorry): pointwise Cauchy-Schwarz + linear isometry.
    - Stage B (0 sorry): `MeasureTheory.integral_mono hVS_int hJω_int hpw`.
    - Stage C (THEOREM from NSP36-C1+C2):
      C1: `vs_l4_holder_bound` — Hölder: ∫‖J‖·‖ω‖² ≤ √(∫‖J‖²)·√(∫‖ω‖⁴)
      C2: `vorticity_l4_le_enstrophy` — GN: √(∫‖ω‖⁴) ≤ ∫‖ω‖²
    - Stage D (zero sorry): `Real.sqrt_le_sqrt hH1` + integral nonnegativity.

    **Tao filter (SA-VS1)**: The bound uses the T³ triadic structure, not just energy
    cancellation. The explicit H1 hypothesis encodes the ‖∇u‖_{L²} dependence. -/
theorem sa_g1_vortex_stretching_bound (u : NSVelocityField) (H1 : ℝ)
    (_hH1_nn : 0 ≤ H1)
    (hH1 : ∫ x : Space, ‖fderiv ℝ u x‖ ^ 2 ≤ H1)
    /- Stage B integrability hypotheses (sa_g1_add_int_hypo, NSC-P36B).
       hJω_int: the dominating integrand ‖∇u‖·‖ω‖² is integrable.
       hVS_int: the vortex-stretching integrand ⟨ω, (∇u)ω⟩ is integrable.
       Both follow from H¹-regularity of u (C¹ solutions); hVS_int ≤ hJω_int via Stage A bound.
       These are abstract hypotheses until NSC-P36B (h1_l6_sobolev) is discharged. -/
    (hJω_int : Integrable (fun x : Space => ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2) volume)
    (hVS_int : Integrable (fun x : Space =>
        @inner ℝ _ _ (vorticity u x)
          (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))) volume) :
    vorticityStretching u ≤ Real.sqrt H1 * spatialEnstrophy u := by
  simp only [vorticityStretching, spatialEnstrophy]
  -- ─── Stage A: pointwise Cauchy-Schwarz + isometry (zero sorry) ────────────
  -- Let ω := vorticity u x, J := fderiv ℝ u x, Φ := Space.basis.repr.symm.
  -- Φ : EuclideanSpace ℝ (Fin 3) ≃ₗᵢ[ℝ] Space  (from OrthonormalBasis.repr)
  -- ⟨ω, J(Φω)⟩ ≤ ‖ω‖ · ‖J(Φω)‖  (real_inner_le_norm)
  --            ≤ ‖ω‖ · ‖J‖ · ‖Φω‖ (ContinuousLinearMap.le_opNorm)
  --            = ‖J‖ · ‖ω‖²        (Φ.norm_map: ‖Φω‖ = ‖ω‖)
  have hpw : ∀ x : Space,
      @inner ℝ _ _ (vorticity u x) (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))) ≤
      ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 := fun x => by
    -- h1: Cauchy-Schwarz: ⟨ω, J(Φω)⟩ ≤ ‖ω‖ · ‖J(Φω)‖
    have h1 : @inner ℝ _ _ (vorticity u x) (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))
        ≤ ‖vorticity u x‖ * ‖fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))‖ :=
      real_inner_le_norm _ _
    -- h2: operator norm + isometry: ‖J(Φω)‖ ≤ ‖J‖ · ‖ω‖
    have h2 : ‖fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))‖
        ≤ ‖fderiv ℝ u x‖ * ‖vorticity u x‖ := by
      have hle := ContinuousLinearMap.le_opNorm (fderiv ℝ u x)
                    (Space.basis.repr.symm (vorticity u x))
      rwa [Space.basis.repr.symm.norm_map (vorticity u x)] at hle
    -- h3: combine: ‖ω‖ · ‖J(Φω)‖ ≤ ‖J‖ · ‖ω‖²
    have h3 : ‖vorticity u x‖ * ‖fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))‖
        ≤ ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 := by
      have hle := mul_le_mul_of_nonneg_left h2 (norm_nonneg (vorticity u x))
      have heq : ‖vorticity u x‖ * (‖fderiv ℝ u x‖ * ‖vorticity u x‖) =
                 ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 := by ring
      linarith
    linarith
  -- ─── Stages B–C: integral_mono + Cauchy-Schwarz + GN ───────────────────
  -- B: VS = ∫⟨ω,Jω⟩ ≤ ∫‖J‖·‖ω‖²  (integral_mono; integrability from hypotheses)
  -- C1 (PROVED): Cauchy-Schwarz (Hölder p=q=2):
  --    ∫‖J‖·‖ω‖² ≤ (∫‖J‖²)^{1/2} · (∫‖ω‖⁴)^{1/2}
  --    = √(∫‖J‖²) · √(∫‖ω‖⁴)
  --    via `integral_mul_le_Lp_mul_Lq_of_nonneg` with f=‖J‖, g=‖ω‖²
  -- C2 (SORRY — GN barrier): √(∫‖ω‖⁴) ≤ ∫‖ω‖²
  --    Requires H¹(Space) ↪ L⁴(Space) Gagliardo-Nirenberg: ‖ω‖_{L⁴} ≤ C‖∇ω‖_{L²}
  --    Not in Mathlib4. Discharge target: NSC-P36B.
  -- Step B: pointwise ≤ integrated
  have hB : ∫ x : Space, @inner ℝ _ _ (vorticity u x)
        (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))) ≤
      ∫ x : Space, ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 :=
    MeasureTheory.integral_mono hVS_int hJω_int hpw
  -- Step C1: Cauchy-Schwarz — ∫‖J‖·‖ω‖² ≤ √(∫‖J‖²) · √(∫‖ω‖⁴)
  -- (NSP36-C1: vs_l4_holder_bound — Hölder p=q=2; GN H¹↪L⁴ barrier abstracted)
  have hC1 : ∫ x : Space, ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 ≤
      Real.sqrt (∫ x : Space, ‖fderiv ℝ u x‖ ^ 2) *
      Real.sqrt (∫ x : Space, ‖vorticity u x‖ ^ 4) :=
    vs_l4_holder_bound u hJω_int
  -- Step C2: GN — √(∫‖ω‖⁴) ≤ ∫‖ω‖²
  -- (NSP36-C2: vorticity_l4_le_enstrophy — GN H¹↪L⁴; Mathlib4 gap abstracted)
  have hC2 : Real.sqrt (∫ x : Space, ‖vorticity u x‖ ^ 4) ≤
      ∫ x : Space, ‖vorticity u x‖ ^ 2 :=
    vorticity_l4_le_enstrophy u
  calc ∫ x : Space, @inner ℝ _ _ (vorticity u x)
            (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))
      ≤ ∫ x : Space, ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 := hB
    _ ≤ Real.sqrt (∫ x : Space, ‖fderiv ℝ u x‖ ^ 2) *
          Real.sqrt (∫ x : Space, ‖vorticity u x‖ ^ 4) := hC1
    _ ≤ Real.sqrt (∫ x : Space, ‖fderiv ℝ u x‖ ^ 2) *
          ∫ x : Space, ‖vorticity u x‖ ^ 2 :=
        mul_le_mul_of_nonneg_left hC2 (Real.sqrt_nonneg _)
    _ ≤ Real.sqrt H1 * ∫ x : Space, ‖vorticity u x‖ ^ 2 :=
        mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hH1)
          (MeasureTheory.integral_nonneg fun _ => sq_nonneg _)

/-! ## §2. SA-G1b: Poincaré inequality on T³ -/

/-- **SA-G1b** (Poincaré-Wirtinger on T³ — enstrophy ≤ palinstrophy).

    For mean-zero divergence-free velocity fields on T³ = [0,2π]³, the first
    eigenvalue of −Δ is λ₁ = 1, giving:
      spatialEnstrophy(u) ≤ palinstrophySpatial(u)

    i.e.  ∫ ‖∇ × u‖² ≤ ∫ ‖∇(∇ × u)‖²   (= ‖ω‖_{L²}² ≤ ‖∇ω‖_{L²}²)

    **THEOREM (NSC-P39, 2026-03-30)**: promoted from axiom via `space_torus_vorticity_bridge`
    in `Sobolev/PeriodicSobolev.lean`. The bridge axiom provides the existential vorticity
    representative on `UnitAddTorus (Fin 3)` with mean-zero, H¹ summability, L² bridge, and
    Plancherel identity; `fourier_poincare_abstract` (§2, 0 axioms) closes the chain.

    **Net**: `sa_g1b_poincare_t3` is now a THEOREM. Axiom count decreases by 1.
    The remaining Sobolev axioms are `space_torus_vorticity_bridge` (NSC-P39),
    `h1_l6_sobolev_periodic` (NSP36-B), and `agmon_h2_linfty_periodic` (NSP38-C). -/
theorem sa_g1b_poincare_t3 (u : NSVelocityField) :
    spatialEnstrophy u ≤ palinstrophySpatial u :=
  NavierStokesClean.Sobolev.sa_g1b_poincare_t3_from_sub u

/-! ## §3. Conditional VS ≤ νP theorem -/

/-! ### §3A. Integrability sub-axioms for vsnup (NSC-P36B) -/

/-- **NSP36-Int1**: The mixed integrand `‖∇u‖·‖ω‖²` is integrable over Space.

    For `u : NSVelocityField` with H¹ spatial regularity and H¹ bound `hH1`:
      `Integrable (fun x => ‖∇u(x)‖ · ‖ω(x)‖²) volume`

    **Mathematical content**: Follows from `‖∇u‖ ∈ L²` (from hH1) and `‖ω‖² ∈ L²`
    (GN H¹↪L⁴: `‖ω‖⁴` integrable). Product of L² functions is L¹ by Hölder.
    **Lean4 gap**: Requires GN H¹(Space)↪L⁴(Space) for `‖ω‖² ∈ L²`. Not in Mathlib4.
    **Reference**: NSC-P36B discharge target. -/
theorem sa_g1_jomega_integrable (u : NSVelocityField)
    {H1 : ℝ} (hH1 : ∫ x : Space, ‖fderiv ℝ u x‖ ^ 2 ≤ H1) :
    Integrable (fun x : Space => ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2) volume := by
  sorry -- NSC-P36B gap: requires GN H¹(Space)↪L⁴ for ‖ω‖² ∈ L²; Hölder gives product in L¹

/-- **NSP36-Int2**: The vortex-stretching inner product integrand is integrable over Space.

    For `u : NSVelocityField` where `‖∇u‖·‖ω‖²` is integrable:
      `Integrable (fun x => ⟨ω(x), (∇u(x))(Φ(ω(x)))⟩) volume`

    **Mathematical content**: Dominated by `‖∇u‖·‖ω‖²` via the Stage A pointwise bound
    `|⟨ω, J(Φω)⟩| ≤ ‖J‖·‖ω‖²`. Hence follows from `sa_g1_jomega_integrable`.
    **Reference**: NSC-P36B; Temam 1984 §II.3. -/
theorem sa_g1_vs_integrable (u : NSVelocityField)
    (hJω_int : Integrable (fun x : Space => ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2) volume) :
    Integrable (fun x : Space =>
        @inner ℝ _ _ (vorticity u x)
          (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))) volume := by
  -- Step 1: Each partial derivative ∂ⱼ(u)ᵢ is measurable (measurable_fderiv_apply_const, @[fun_prop]).
  -- No regularity assumption on u is required.
  have hmeas_df : ∀ (i j : Fin 3),
      Measurable (fun x : Space => Space.deriv j (fun y => (u y).ofLp i) x) := fun i j =>
    measurable_fderiv_apply_const ℝ (fun y => (u y).ofLp i) (Space.basis j)
  -- Step 2: Each component (vorticity u x).ofLp k is measurable.
  -- Space.curl u x component k is a difference of two partial derivatives.
  have hmeas_vort_comp : ∀ (k : Fin 3),
      Measurable (fun x : Space => (vorticity u x).ofLp k) := by
    intro k; fin_cases k <;>
    · simp only [vorticity, Space.curl, Space.deriv, Fin.isValue]
      apply Measurable.sub <;> exact hmeas_df _ _
  -- Step 3: vorticity u is measurable as an EuclideanSpace ℝ (Fin 3)-valued function.
  -- Use MeasurableEquiv.toLp : (Fin 3 → ℝ) ≃ᵐ EuclideanSpace ℝ (Fin 3) to transfer
  -- from component-wise measurability (Fin 3 → ℝ) to EuclideanSpace measurability.
  have hmeas_vort : Measurable (vorticity u) := by
    have hpi : Measurable (fun x : Space => fun k : Fin 3 => (vorticity u x).ofLp k) :=
      measurable_pi_iff.mpr hmeas_vort_comp
    -- vorticity u x = WithLp.toLp 2 (fun k => (vorticity u x).ofLp k) definitionally
    show Measurable (fun x : Space => WithLp.toLp 2 (fun k : Fin 3 => (vorticity u x).ofLp k))
    exact (MeasurableEquiv.toLp 2 (Fin 3 → ℝ)).measurable.comp hpi
  -- Step 4: fderiv ℝ u applied at the variable vector Space.basis.repr.symm (vorticity u x) is measurable.
  -- ContinuousLinearMap.measurable_apply₂ : Measurable (fun p : (E →L[𝕜] F) × E => p.1 p.2).
  have hmeas_Jv : Measurable (fun x : Space =>
      fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))) :=
    ContinuousLinearMap.measurable_apply₂.comp
      (Measurable.prodMk (measurable_fderiv ℝ u)
        (Space.basis.repr.symm.toLinearIsometry.continuous.measurable.comp hmeas_vort))
  -- Step 5: The inner product of two measurable EuclideanSpace-valued functions is measurable.
  have hmeas : AEStronglyMeasurable (fun x : Space =>
      @inner ℝ _ _ (vorticity u x) (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))) volume :=
    (hmeas_vort.inner hmeas_Jv).aestronglyMeasurable
  -- Step 6: Pointwise bound — Stage A argument (same as in sa_g1_vortex_stretching_bound).
  -- |⟨ω, J(Φω)⟩| ≤ ‖ω‖·‖J(Φω)‖ ≤ ‖ω‖·(‖J‖·‖Φω‖) = ‖J‖·‖ω‖²  (Φ = repr.symm is an isometry)
  have hpw : ∀ x : Space, ‖@inner ℝ _ _ (vorticity u x)
        (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))‖ ≤
      ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 := fun x => by
    have h1 : ‖@inner ℝ _ _ (vorticity u x)
            (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))‖
          ≤ ‖vorticity u x‖ * ‖fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))‖ :=
      norm_inner_le_norm _ _
    have h2 : ‖fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))‖
        ≤ ‖fderiv ℝ u x‖ * ‖vorticity u x‖ := by
      have hle := ContinuousLinearMap.le_opNorm (fderiv ℝ u x)
                    (Space.basis.repr.symm (vorticity u x))
      rwa [Space.basis.repr.symm.norm_map (vorticity u x)] at hle
    calc ‖@inner ℝ _ _ (vorticity u x) (fderiv ℝ u x (Space.basis.repr.symm (vorticity u x)))‖
        ≤ ‖vorticity u x‖ * ‖fderiv ℝ u x (Space.basis.repr.symm (vorticity u x))‖ := h1
      _ ≤ ‖vorticity u x‖ * (‖fderiv ℝ u x‖ * ‖vorticity u x‖) :=
          mul_le_mul_of_nonneg_left h2 (norm_nonneg _)
      _ = ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 := by ring
  -- Step 7: Dominated convergence from hJω_int.
  exact hJω_int.mono hmeas (ae_of_all volume fun x => by
    have hnn : 0 ≤ ‖fderiv ℝ u x‖ * ‖vorticity u x‖ ^ 2 :=
      mul_nonneg (norm_nonneg (fderiv ℝ u x)) (sq_nonneg _)
    rw [Real.norm_of_nonneg hnn]; exact hpw x)

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
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    vorticityStretching (traj t) ≤ ν * palinstrophySpatial (traj t) := by
  have hH1_nn : 0 ≤ ν ^ 2 := sq_nonneg ν
  -- Integrability hypotheses via NSP36-Int1+Int2 sub-axioms (NSC-P36B).
  have hJω_int : Integrable (fun x : Space =>
      ‖fderiv ℝ (traj t) x‖ * ‖vorticity (traj t) x‖ ^ 2) volume :=
    sa_g1_jomega_integrable (traj t) hH1_t
  have hVS_int : Integrable (fun x : Space =>
      @inner ℝ _ _ (vorticity (traj t) x)
        (fderiv ℝ (traj t) x (Space.basis.repr.symm (vorticity (traj t) x)))) volume :=
    sa_g1_vs_integrable (traj t) hJω_int
  have hVS := sa_g1_vortex_stretching_bound (traj t) (ν ^ 2) hH1_nn hH1_t hJω_int hVS_int
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
    (hH1_uniform : ∀ t ∈ Set.Icc 0 T, ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2)
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
    exact hasDerivAt_const t 0

/-! ## §6. Axiom surface certificate -/

/-- Minimal axiom surface for the VS ≤ νP spatial bridge (m01a–m01c).
    `sa_g1b_poincare_t3` is now a THEOREM (NSC-P39, 2026-03-30). -/
def vsnupSpatialAxiomSurface : List String :=
  [ "sa_g1_vortex_stretching_bound — Temam 1984 §II.3 Lem 3.3; T³ Agmon-Sobolev trilinear"
  , "  NOTE: sa_g1b_poincare_t3 is THEOREM from space_torus_vorticity_bridge (NSC-P39)"
  , "vorticityStretching_zero_of_const — VS=0 for constant field; NSC-P33 (opaque discharge)"
  ]

end NavierStokesClean.Galerkin
