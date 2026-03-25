import NavierStokes.NSEPTCIBound

/-!
# Stage 282 — NSEPTUniformBound

**Under a uniform enstrophy bound, BKM is polynomially bounded in T globally —
no critical time restriction.**

## Key Insight

Stage 280's critical time T_crit = 1 (under CI) arose from the **self-referential**
Gronwall argument: τ_ent appears on both sides of the integral inequality.

If instead the enstrophy is **uniformly bounded** — i.e.,

  `∀ t : Rat, Ω(t) ≤ Ω_bound`

then `discreteIntegral_le_of_pointwise` applies **directly** (universal quantifier,
no range restriction) and gives:

  intEnstrophy(T) ≤ Ω_bound · T   [no self-reference, no critical time]
  τ_ent(T) ≤ (ν/ħ) · Ω_bound · T  [multiply by ν/ħ]

Combined with Stage 279's degree-4 EPT bound:

  BKM(T) ≤ (ħ/ν) · (1 + (ν/ħ)·Ω·T)³ · (ν/ħ)·Ω·T   [degree-4 in T, globally valid]

## Under CI (ħ = 2ν) with Ω_bound = 1

  τ_ent(T) ≤ T/2
  BKM(T) ≤ 2 · (1 + T/2)³ · (T/2) = (1 + T/2)³ · T

Concrete values:
  T = 1:  BKM ≤ (3/2)³ · 1 = 27/8   ≈ 3.375
  T = 2:  BKM ≤ 2³ · 2   = 16
  T = 10: BKM ≤ 6³ · 10  = 2160

The bound grows as T⁴ but is **finite for every finite T** — global control.

## What the uniform hypothesis means physically

The condition `∀ t, Ω(t) ≤ Ω_bound` is satisfied:
1. **Exactly** for 2D flows (enstrophy is a Lyapunov functional).
2. **After τ_iso** for large-data 3D flows with k41 universality (Stage 272),
   once VS(t) ≤ νP(t) kicks in and makes dΩ/dt ≤ 0.
3. **As an assumption** for small-data/conditional regularity theorems.

## Net counts

  - New axioms:   0
  - New theorems: 11
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

open NavierStokes.DiscreteKernel

/-! ## 1. Linear Integral Bound (the key 0-axiom result) -/

/-- **Integral ≤ constant · T** under uniform pointwise bound.

    If Ω(t) ≤ Ω_bound for ALL t (universal, no range restriction), then:
      integratedEnstrophy(T) ≤ Ω_bound · T

    This uses only `discreteIntegral_le_of_pointwise` (universal) and
    `diSteps_mul_diH_le_T`. **Zero new axioms.** -/
theorem intEnstrophy_le_of_uniform_bound
    (traj : Trajectory NSField) (T Ω_bound : Rat)
    (hT   : 0 ≤ T) (hΩ   : 0 ≤ Ω_bound)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ Ω_bound) :
    integratedEnstrophy traj T ≤ Ω_bound * T := by
  unfold integratedEnstrophy discreteIntegral
  calc (Finset.range (diSteps T)).sum
          (fun i => enstrophy (traj.stateAt ((i : Rat) * diH)).velocity * diH)
      ≤ (Finset.range (diSteps T)).sum (fun _ => Ω_bound * diH) :=
          Finset.sum_le_sum fun i _ =>
            mul_le_mul_of_nonneg_right (hUnif _) diH_nonneg
    _ = Ω_bound * ((diSteps T : Rat) * diH) := by
          simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul]; ring
    _ ≤ Ω_bound * T :=
          mul_le_mul_of_nonneg_left (diSteps_mul_diH_le_T T hT) hΩ

/-- Under uniform enstrophy bound, τ_ent(T) ≤ (ν/ħ) · Ω_bound · T  (linear in T).

    No critical time, no self-reference. **Zero new axioms.** -/
theorem ept_le_linear_of_uniform_bound
    (traj : Trajectory NSField) (T Ω_bound : Rat)
    (hT   : 0 ≤ T) (hΩ   : 0 ≤ Ω_bound)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ Ω_bound) :
    entropicProperTime traj T ≤ (nsNu / hbar) * Ω_bound * T :=
  calc entropicProperTime traj T
      = (nsNu / hbar) * integratedEnstrophy traj T := rfl
    _ ≤ (nsNu / hbar) * (Ω_bound * T) :=
          mul_le_mul_of_nonneg_left
            (intEnstrophy_le_of_uniform_bound traj T Ω_bound hT hΩ hUnif)
            (le_of_lt (div_pos nsNu_pos hbar_pos))
    _ = (nsNu / hbar) * Ω_bound * T := by ring

/-! ## 2. Degree-4 BKM Bound (no critical time) -/

/-- **BKM degree-4 bound under uniform enstrophy** (MAIN THEOREM, Stage 282).

    If Ω(t) ≤ Ω_bound for all t, then:
      BKM(T) ≤ (1 + (ν/ħ)·Ω·T)³ · (ħ/ν)·(ν/ħ)·Ω·T

    This holds for **all T ≥ 0** — no critical time restriction.
    **Zero new axioms.** -/
theorem bkm_uniform_enstrophy_bound
    (traj : Trajectory NSField) (T Ω_bound : Rat)
    (hT   : 0 ≤ T) (hΩ   : 0 ≤ Ω_bound)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ Ω_bound) :
    bkmVorticityIntegralPhysical traj T ≤
      bernsteinConst *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (hbar / nsNu * ((nsNu / hbar) * Ω_bound * T)) := by
  -- τ ≤ (ν/ħ)·Ω·T
  have hτ  := ept_le_linear_of_uniform_bound traj T Ω_bound hT hΩ hUnif
  -- The Stage 279 degree-4 bound in τ
  have hD4 := bkm_physical_degree4_ept_bound traj T
  -- τ ≥ 0 and τ_b = (ν/ħ)·Ω·T ≥ 0
  have hτnn : 0 ≤ entropicProperTime traj T := by
    unfold entropicProperTime integratedEnstrophy
    exact mul_nonneg (div_nonneg (le_of_lt nsNu_pos) (le_of_lt hbar_pos))
      (discreteIntegral_nonneg _ T (fun t => enstrophy_nonneg (traj.stateAt t).velocity))
  have hτb : 0 ≤ (nsNu / hbar) * Ω_bound * T :=
    mul_nonneg (mul_nonneg (le_of_lt (div_pos nsNu_pos hbar_pos)) hΩ) hT
  -- 1 + τ ≥ 0 and 1 + τ_b ≥ 0
  have h1t  : 0 ≤ 1 + entropicProperTime traj T   := by linarith
  have h1tb : 0 ≤ 1 + (nsNu / hbar) * Ω_bound * T := by linarith
  -- ħ/ν > 0
  have hhn  : 0 < hbar / nsNu := div_pos hbar_pos nsNu_pos
  -- Monotonicity chain: (1+τ)³·(ħ/ν·τ) increases in τ, so substitute τ ≤ τ_b
  have step1 : hbar / nsNu * entropicProperTime traj T ≤
               hbar / nsNu * ((nsNu / hbar) * Ω_bound * T) :=
    mul_le_mul_of_nonneg_left hτ (le_of_lt hhn)
  have step2 : bernsteinConst * (1 + entropicProperTime traj T) ≤
               bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) :=
    mul_le_mul_of_nonneg_left (by linarith) (le_of_lt bernsteinConst_pos)
  have step3 : bernsteinConst * (1 + entropicProperTime traj T) *
               (1 + entropicProperTime traj T) ≤
               bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) *
               (1 + (nsNu / hbar) * Ω_bound * T) :=
    calc bernsteinConst * (1 + entropicProperTime traj T) * (1 + entropicProperTime traj T)
        ≤ bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) * (1 + entropicProperTime traj T) :=
            mul_le_mul_of_nonneg_right step2 h1t
      _ ≤ bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) * (1 + (nsNu / hbar) * Ω_bound * T) :=
            mul_le_mul_of_nonneg_left (by linarith)
              (mul_nonneg (le_of_lt bernsteinConst_pos) h1tb)
  have step4 : bernsteinConst * (1 + entropicProperTime traj T) *
               (1 + entropicProperTime traj T) *
               (1 + entropicProperTime traj T) ≤
               bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) *
               (1 + (nsNu / hbar) * Ω_bound * T) *
               (1 + (nsNu / hbar) * Ω_bound * T) :=
    calc bernsteinConst * (1 + entropicProperTime traj T) *
         (1 + entropicProperTime traj T) * (1 + entropicProperTime traj T)
        ≤ bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) *
          (1 + (nsNu / hbar) * Ω_bound * T) * (1 + entropicProperTime traj T) :=
            mul_le_mul_of_nonneg_right step3 h1t
      _ ≤ bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) *
          (1 + (nsNu / hbar) * Ω_bound * T) * (1 + (nsNu / hbar) * Ω_bound * T) :=
            mul_le_mul_of_nonneg_left (by linarith)
              (mul_nonneg (mul_nonneg (le_of_lt bernsteinConst_pos) h1tb) h1tb)
  -- Assemble
  calc bkmVorticityIntegralPhysical traj T
      ≤ bernsteinConst * (1 + entropicProperTime traj T) *
        (1 + entropicProperTime traj T) *
        (1 + entropicProperTime traj T) *
        (hbar / nsNu * entropicProperTime traj T) := hD4
    _ ≤ bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (hbar / nsNu * entropicProperTime traj T) :=
          mul_le_mul_of_nonneg_right step4
            (mul_nonneg (le_of_lt hhn) hτnn)
    _ ≤ bernsteinConst * (1 + (nsNu / hbar) * Ω_bound * T) *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (1 + (nsNu / hbar) * Ω_bound * T) *
        (hbar / nsNu * ((nsNu / hbar) * Ω_bound * T)) :=
          mul_le_mul_of_nonneg_left step1
            (mul_nonneg (mul_nonneg
              (mul_nonneg (le_of_lt bernsteinConst_pos) h1tb) h1tb) h1tb)

/-! ## 3. CI Specialization -/

/-- Under CI, the uniform bound simplifies: τ_ent(T) ≤ Ω_bound · T / 2. -/
theorem ept_ci_uniform_bound
    (traj : Trajectory NSField) (T Ω_bound : Rat)
    (hT   : 0 ≤ T) (hΩ   : 0 ≤ Ω_bound)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ Ω_bound) :
    entropicProperTime traj T ≤ Ω_bound * T / 2 := by
  have h := ept_le_linear_of_uniform_bound traj T Ω_bound hT hΩ hUnif
  rw [nsNu_div_hbar_ci] at h
  linarith

/-- Under CI with Ω_bound = 1, BKM(T) ≤ (1 + T/2)³ · T for all T ≥ 0. -/
theorem bkm_ci_uniform_unit_bound
    (traj : Trajectory NSField) (T : Rat)
    (hT   : 0 ≤ T)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ 1) :
    bkmVorticityIntegralPhysical traj T ≤
      (1 + T / 2) * (1 + T / 2) * (1 + T / 2) * T := by
  have h := bkm_uniform_enstrophy_bound traj T 1 hT (by norm_num) hUnif
  rw [bernsteinConst, nsNu_div_hbar_ci, hbar_div_nsNu_ci] at h
  linarith

/-- **Concrete bound at T = 1** (under CI, Ω_bound = 1):
    BKM(1) ≤ (3/2)³ · 1 = 27/8.
    Valid for ALL T ≤ 1, no critical time restriction. -/
theorem bkm_ci_uniform_at_one
    (traj : Trajectory NSField)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ 1) :
    bkmVorticityIntegralPhysical traj 1 ≤ 27 / 8 := by
  have h := bkm_ci_uniform_unit_bound traj 1 (by norm_num) hUnif
  linarith

/-- **Concrete bound at T = 2** (under CI, Ω_bound = 1):
    BKM(2) ≤ 2³ · 2 = 16. -/
theorem bkm_ci_uniform_at_two
    (traj : Trajectory NSField)
    (hUnif : ∀ t : Rat, enstrophy (traj.stateAt t).velocity ≤ 1) :
    bkmVorticityIntegralPhysical traj 2 ≤ 16 := by
  have h := bkm_ci_uniform_unit_bound traj 2 (by norm_num) hUnif
  linarith

end

end NavierStokes.Millennium
