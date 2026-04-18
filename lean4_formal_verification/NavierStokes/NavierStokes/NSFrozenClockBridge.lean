import NavierStokes.NSFourierFreqBoundBridge

/-!
# Stage 149: Frozen-Clock Linearization — Closing the T-Coercive Gap

## The nonlinearity gap (from Stage 148)

Stage 148 (`NSEntropicCoercivityDesign`) identified that the CAT/EPT entropic clock
`τ_ent(t) = (ν/ħ) ∫₀ᵗ Ω(s) ds` is **nonlinear in t** — solution-dependent via Ω(s).
In contrast, the T-coercive framework for wave equations uses **linear** rescaled time
`τ_μ = μ·t` where μ is a fixed stiffness parameter.

## Frozen-clock linearization

A **frozen-clock** fixes the enstrophy at a constant level `Ω₀ > 0`:

    τ_frozen(t) := (ν/ħ) · Ω₀ · t         (linear in t, stiffness μ = (ν/ħ)·Ω₀)

The frozen-clock BKM bound is then:

    BKM ≤ (ħ/ν)·(1+K)·τ_frozen(T) = (1+K)·Ω₀·T     [= F_FC(K, Ω₀, T)]

This is BI-LINEAR in (Ω₀, T) — the genuine T-coercive Céa estimate structure.

## The frozen-clock condition

The bound `BKM ≤ F_FC` holds whenever the actual entropic time satisfies:

    τ_ent(T) ≤ τ_frozen(T) = (ν/ħ)·Ω₀·T

i.e., `∫₀ᵀ Ω(s) ds ≤ Ω₀·T` — the running enstrophy average is bounded by Ω₀.

## Relationship to Galerkin iteration

In a Galerkin fixed-point, freeze `Ω₀ = Ω_prev` from the previous iterate.
The fixed-point equation `Ω_prev = Ω` recovers the nonlinear τ_ent.
A contraction argument `‖Ω_n+1 − Ω_n‖ ≤ C·‖Ω_n − Ω_{n-1}‖` would close the gap.
-/

namespace NavierStokes.FrozenClock

set_option autoImplicit false

open NavierStokes.FourierModel
open NavierStokes.Millennium
open NavierStokes.DiscreteKernel

/-! ## Frozen-clock trajectory type -/

/-- A Fourier trajectory with frequency cutoff K and frozen enstrophy level Ω₀.
    Wraps `BoundedFrequencyFourierTrajectory K` with a positive clock parameter. -/
structure FrozenClockFourierTrajectory (K : Rat) (Ω₀ : Rat) where
  base      : BoundedFrequencyFourierTrajectory K
  clock_pos : 0 < Ω₀

/-! ## Linear frozen clock -/

/-- Frozen-clock entropic time: τ_frozen(T) = (ν/ħ)·Ω₀·T. LINEAR in T. -/
noncomputable def frozenEntropicTimeF (Ω₀ T : Rat) : Rat :=
  nsNu / hbar * Ω₀ * T

theorem frozenEntropicTimeF_zero (Ω₀ : Rat) : frozenEntropicTimeF Ω₀ 0 = 0 := by
  unfold frozenEntropicTimeF; ring

theorem frozenEntropicTimeF_nonneg {Ω₀ T : Rat} (hΩ : 0 < Ω₀) (hT : 0 ≤ T) :
    0 ≤ frozenEntropicTimeF Ω₀ T :=
  mul_nonneg (mul_nonneg (le_of_lt (div_pos nsNu_pos hbar_pos)) (le_of_lt hΩ)) hT

/-- Frozen clock is linear in T — the T-coercive structure τ_μ = μ·T. -/
theorem frozenEntropicTimeF_linear (Ω₀ T₁ T₂ : Rat) :
    frozenEntropicTimeF Ω₀ (T₁ + T₂) =
    frozenEntropicTimeF Ω₀ T₁ + frozenEntropicTimeF Ω₀ T₂ := by
  unfold frozenEntropicTimeF; ring

/-- Frozen clock is monotone in T. -/
theorem frozenEntropicTimeF_mono {Ω₀ : Rat} (hΩ : 0 < Ω₀) {T₁ T₂ : Rat} (hT : T₁ ≤ T₂) :
    frozenEntropicTimeF Ω₀ T₁ ≤ frozenEntropicTimeF Ω₀ T₂ :=
  mul_le_mul_of_nonneg_left hT
    (mul_nonneg (le_of_lt (div_pos nsNu_pos hbar_pos)) (le_of_lt hΩ))

/-! ## Key algebraic identity -/

private theorem hbar_nu_cancel : hbar / nsNu * (nsNu / hbar) = 1 := by
  rw [div_mul_div_comm, show hbar * nsNu = nsNu * hbar from mul_comm _ _]
  exact div_self (mul_ne_zero nsNu_pos.ne' hbar_pos.ne')

/-! ## Frozen-clock BKM bound -/

/-- Frozen-clock BKM bound: F_FC(K, Ω₀, T) = (1+K)·Ω₀·T. Bilinear in (Ω₀, T). -/
noncomputable def frozenClockBKMBound (K Ω₀ T : Rat) : Rat :=
  (1 + K) * Ω₀ * T

/-- F_FC equals the Stage 147 bound evaluated at τ_frozen. -/
theorem frozenClockBKMBound_eq_stage147 (K Ω₀ T E₀ : Rat) :
    frozenClockBKMBound K Ω₀ T =
    agmonBKMBoundFBounded K (frozenEntropicTimeF Ω₀ T) E₀ nsNu := by
  unfold frozenClockBKMBound agmonBKMBoundFBounded frozenEntropicTimeF
  -- Goal: (1+K)*Ω₀*T = hbar/nsNu*(1+K)*(nsNu/hbar*Ω₀*T)
  have hbnu := hbar_nu_cancel
  have hkey : hbar / nsNu * (1 + K) * (nsNu / hbar * Ω₀ * T) = (1 + K) * Ω₀ * T := by
    have : hbar / nsNu * (1 + K) * (nsNu / hbar * Ω₀ * T) =
           (hbar / nsNu * (nsNu / hbar)) * ((1 + K) * Ω₀ * T) := by ring
    rw [this, hbnu, one_mul]
  linarith

/-! ## Core frozen-clock bound theorem -/

/-- **Core theorem**: given τ_ent(T) ≤ τ_frozen(T) and 0 ≤ K,
    the BKM integral satisfies BKM ≤ (1+K)·Ω₀·T. -/
theorem frozenClock_bkm_bound
    {K Ω₀ : Rat} (bt : BoundedFrequencyFourierTrajectory K) (T : Rat) (_hT : 0 < T)
    (hK : 0 ≤ K)
    (hτ_le : entropicProperTimeF bt.traj T ≤ frozenEntropicTimeF Ω₀ T) :
    bkmAgmonIntegralF bt.traj T ≤ frozenClockBKMBound K Ω₀ T := by
  -- Direct proof using underlying lemmas (avoids existential witness issue)
  unfold bkmAgmonIntegralF frozenClockBKMBound
  -- Step 1: intEns = (ħ/ν)·τ_ent  [definitional]
  have htau := integratedEnstrophy_eq_hbar_tau bt.traj T
  -- Step 2: intPal ≤ K·intEns  [freq_sq_bound]
  have hintPal := integratedPalinstrophyF_le_K_intEns bt T
  -- Step 3: intEns + intPal ≤ (ħ/ν)·(1+K)·τ_ent
  have hbkm_ent : integratedEnstrophyF bt.traj T + integratedPalinstrophyF bt.traj T ≤
      hbar / nsNu * (1 + K) * entropicProperTimeF bt.traj T := by
    have hintEns_nn : 0 ≤ integratedEnstrophyF bt.traj T := by
      unfold integratedEnstrophyF
      apply discreteIntegral_nonneg
      intro t
      exact enstrophyF_nonneg (trajFieldAt bt.traj t)
    calc integratedEnstrophyF bt.traj T + integratedPalinstrophyF bt.traj T
        ≤ integratedEnstrophyF bt.traj T + K * integratedEnstrophyF bt.traj T := by linarith
      _ = (1 + K) * integratedEnstrophyF bt.traj T := by ring
      _ = (1 + K) * (hbar / nsNu * entropicProperTimeF bt.traj T) := by rw [htau]
      _ = hbar / nsNu * (1 + K) * entropicProperTimeF bt.traj T := by ring
  -- Step 4: τ_ent ≤ τ_frozen → (ħ/ν)·(1+K)·τ_ent ≤ (ħ/ν)·(1+K)·τ_frozen
  have hbkm_frozen : hbar / nsNu * (1 + K) * entropicProperTimeF bt.traj T ≤
      hbar / nsNu * (1 + K) * frozenEntropicTimeF Ω₀ T := by
    apply mul_le_mul_of_nonneg_left hτ_le
    exact mul_nonneg (le_of_lt (div_pos hbar_pos nsNu_pos)) (by linarith)
  -- Step 5: (ħ/ν)·(1+K)·τ_frozen = (1+K)·Ω₀·T  [algebra: (ħ/ν)·(ν/ħ) = 1]
  have hbnu := hbar_nu_cancel
  have hfrozen_eq : hbar / nsNu * (1 + K) * frozenEntropicTimeF Ω₀ T = (1 + K) * Ω₀ * T := by
    unfold frozenEntropicTimeF
    have : hbar / nsNu * (1 + K) * (nsNu / hbar * Ω₀ * T) =
           (hbar / nsNu * (nsNu / hbar)) * ((1 + K) * Ω₀ * T) := by ring
    rw [this, hbnu, one_mul]
  linarith

/-! ## Enstrophy bound implies frozen-clock condition -/

/-- Constant-function Riemann sum ≤ c·T (Riemann sum approximation from below). -/
private theorem discreteIntegral_const_le {c T : Rat} (hc : 0 ≤ c) (hT : 0 ≤ T) :
    discreteIntegral (fun _ => c) T ≤ c * T := by
  unfold discreteIntegral
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  -- Goal: (diSteps T : Rat) * (c * diH) ≤ c * T
  rw [show (diSteps T : Rat) * (c * diH) = c * ((diSteps T : Rat) * diH) from by ring]
  apply mul_le_mul_of_nonneg_left _ hc
  -- Goal: (diSteps T : Rat) * diH ≤ T
  -- = floor(T * 1000) * (1/1000) ≤ T
  unfold diSteps diH diN
  have hfloor : (Nat.floor (T * 1000) : Rat) ≤ T * 1000 :=
    Nat.floor_le (mul_nonneg hT (by norm_num))
  have hcast : (0 : Rat) ≤ (Nat.floor (T * 1000) : Rat) := Nat.cast_nonneg _
  linarith

/-- If pointwise enstrophy ≤ Ω₀ everywhere, then τ_ent ≤ τ_frozen. -/
theorem enstrophyBound_implies_tau_le
    (traj : EnergyDissipatingFourierTrajectory) (Ω₀ T : Rat)
    (hΩ_bound : ∀ t : Rat, enstrophyFTraj traj t ≤ Ω₀)
    (hΩ_nn : 0 ≤ Ω₀) (hT : 0 ≤ T) :
    entropicProperTimeF traj T ≤ frozenEntropicTimeF Ω₀ T := by
  unfold entropicProperTimeF integratedEnstrophyF frozenEntropicTimeF
  -- Step 1: pointwise bound → integral bound
  have h1 : discreteIntegral (enstrophyFTraj traj) T ≤ discreteIntegral (fun _ => Ω₀) T :=
    discreteIntegral_le_of_pointwise _ _ T hΩ_bound
  -- Step 2: constant integral ≤ Ω₀ * T
  have h2 : discreteIntegral (fun _ => Ω₀) T ≤ Ω₀ * T :=
    discreteIntegral_const_le hΩ_nn hT
  -- Step 3: multiply by (ν/ħ) ≥ 0
  have hcoeff : (0 : Rat) ≤ nsNu / hbar := le_of_lt (div_pos nsNu_pos hbar_pos)
  calc nsNu / hbar * discreteIntegral (enstrophyFTraj traj) T
      ≤ nsNu / hbar * (Ω₀ * T) :=
          mul_le_mul_of_nonneg_left (by linarith) hcoeff
    _ = nsNu / hbar * Ω₀ * T := by ring

/-! ## Bilinearity of F_FC -/

theorem frozenClockBKMBound_linear_T (K Ω₀ T₁ T₂ : Rat) :
    frozenClockBKMBound K Ω₀ (T₁ + T₂) =
    frozenClockBKMBound K Ω₀ T₁ + frozenClockBKMBound K Ω₀ T₂ := by
  unfold frozenClockBKMBound; ring

theorem frozenClockBKMBound_linear_omega (K Ω₁ Ω₂ T : Rat) :
    frozenClockBKMBound K (Ω₁ + Ω₂) T =
    frozenClockBKMBound K Ω₁ T + frozenClockBKMBound K Ω₂ T := by
  unfold frozenClockBKMBound; ring

theorem frozenClockBKMBound_mono_omega (K Ω₁ Ω₂ T : Rat)
    (hΩ : Ω₁ ≤ Ω₂) (hT : 0 ≤ T) (hK : 0 ≤ K) :
    frozenClockBKMBound K Ω₁ T ≤ frozenClockBKMBound K Ω₂ T := by
  unfold frozenClockBKMBound
  nlinarith [mul_nonneg (mul_nonneg (by linarith : (0:Rat) ≤ 1 + K)
               (by linarith : (0:Rat) ≤ Ω₂ - Ω₁)) hT]

theorem frozenClockBKMBound_mono_T (K Ω₀ T₁ T₂ : Rat)
    (hT : T₁ ≤ T₂) (hΩ : 0 ≤ Ω₀) (hK : 0 ≤ K) :
    frozenClockBKMBound K Ω₀ T₁ ≤ frozenClockBKMBound K Ω₀ T₂ := by
  unfold frozenClockBKMBound
  nlinarith [mul_nonneg (by linarith : (0:Rat) ≤ 1 + K) hΩ]

/-! ## Stiffness parameter -/

/-- T-coercive stiffness: μ = (ν/ħ)·Ω₀ so τ_frozen = μ·T. -/
noncomputable def frozenClockStiffness (Ω₀ : Rat) : Rat := nsNu / hbar * Ω₀

theorem frozenClockStiffness_pos {Ω₀ : Rat} (hΩ : 0 < Ω₀) :
    0 < frozenClockStiffness Ω₀ :=
  mul_pos (div_pos nsNu_pos hbar_pos) hΩ

theorem frozenEntropicTime_eq_stiffness_times_T (Ω₀ T : Rat) :
    frozenEntropicTimeF Ω₀ T = frozenClockStiffness Ω₀ * T := by
  unfold frozenEntropicTimeF frozenClockStiffness; ring

/-- F_FC in T-coercive form: F_FC = (ħ/ν)·(1+K)·μ·T = (1+K)·Ω₀·T. -/
theorem frozenClockBKMBound_via_stiffness (K Ω₀ T : Rat) :
    frozenClockBKMBound K Ω₀ T =
    hbar / nsNu * (1 + K) * (frozenClockStiffness Ω₀ * T) := by
  unfold frozenClockBKMBound frozenClockStiffness
  have hbnu := hbar_nu_cancel
  have hkey : hbar / nsNu * (1 + K) * (nsNu / hbar * Ω₀ * T) =
              (hbar / nsNu * (nsNu / hbar)) * ((1 + K) * Ω₀ * T) := by ring
  rw [hkey, hbnu, one_mul]

/-! ## Combined theorem -/

/-- If pointwise enstrophy ≤ Ω₀ and K ≥ 0, then BKM ≤ (1+K)·Ω₀·T. -/
theorem frozenClock_bkm_bound_from_enstrophy
    {K Ω₀ : Rat} (bt : BoundedFrequencyFourierTrajectory K) (T : Rat) (hT : 0 < T)
    (hΩ_bound : ∀ t : Rat, enstrophyFTraj bt.traj t ≤ Ω₀)
    (hΩ_nn : 0 ≤ Ω₀) (hK : 0 ≤ K) :
    bkmAgmonIntegralF bt.traj T ≤ frozenClockBKMBound K Ω₀ T :=
  frozenClock_bkm_bound bt T (by linarith) hK
    (enstrophyBound_implies_tau_le bt.traj Ω₀ T hΩ_bound hΩ_nn (le_of_lt hT))

/-! ## Summary theorem -/

theorem frozen_clock_design_summary (K Ω₀ : Rat) (hΩ : 0 < Ω₀) (hK : 0 ≤ K) :
    PreciseGapStatementFourierBounded K ∧
    0 < frozenClockStiffness Ω₀ ∧
    (∀ T₁ T₂ : Rat, frozenEntropicTimeF Ω₀ (T₁ + T₂) =
        frozenEntropicTimeF Ω₀ T₁ + frozenEntropicTimeF Ω₀ T₂) ∧
    (∀ Ω₁ Ω₂ T : Rat, Ω₁ ≤ Ω₂ → 0 ≤ T →
        frozenClockBKMBound K Ω₁ T ≤ frozenClockBKMBound K Ω₂ T) :=
  ⟨pgs_fourier_bounded K,
   frozenClockStiffness_pos hΩ,
   frozenEntropicTimeF_linear Ω₀,
   fun Ω₁ Ω₂ T hΩ12 hT => frozenClockBKMBound_mono_omega K Ω₁ Ω₂ T hΩ12 hT hK⟩

end NavierStokes.FrozenClock
