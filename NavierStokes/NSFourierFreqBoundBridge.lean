import NavierStokes.NSFourierAgmonBridge

/-!
# Stage 147: Frequency-Bounded Fourier Trajectories — 3-Argument Collapse

## Goal

Stage 146 proved `pgs_fourier_agmon : PreciseGapStatementFourierAgmon` with F taking **four**
arguments `(τ, E₀, ν, M_pal)`, where `M_pal` is an external palinstrophy budget parameter.

This file collapses that to a **3-argument** `F(τ, E₀, ν)` by restricting to the class of
`BoundedFrequencyFourierTrajectory K` — trajectories whose wavenumber squares are bounded by a
fixed global constant `K`.  Within this class, palinstrophy is bounded pointwise by `K · enstrophy`,
so the `M_pal` budget is determined internally: `M_pal := K · τ`.

## Quantifier structure

The resulting statement has the correct ∃F∀traj universality:

    ∃ F : Rat → Rat → Rat → Rat,
    ∀ (bt : BoundedFrequencyFourierTrajectory K) (T : Rat), 0 < T →
      bkmAgmonIntegralF bt.traj T ≤ F (entropicProperTimeF bt.traj T) ... nsNu

Here `F` is **independent of `bt`** (it only involves the fixed `K` and physical constants), so
the quantifier order is correct: the same `F` works for every trajectory in the class.

## The collapse

    F_K(τ, E₀, ν) = (hbar/nsNu) · (1 + K) · τ

This follows from:
  1. `palinstrophyFTraj bt.traj t ≤ K · enstrophyFTraj bt.traj t`  (pointwise, freq bound)
  2. `integratedPalinstrophyF bt.traj T ≤ K · integratedEnstrophyF bt.traj T`  (lift via Riemann sum)
  3. `bkmAgmonIntegralF = intEns + intPal ≤ (hbar/nsNu)·τ + K·(hbar/nsNu)·τ = (hbar/nsNu)(1+K)τ`

## Relationship to Stage 146

Stage 146 `pgs_fourier_agmon` is the general (4-arg) form.
Stage 147 `pgs_fourier_bounded K` is a **corollary**: it instantiates Stage 146's `M_pal` with
the computed bound `K · entropicProperTimeF`, producing the 3-arg `F_K`.

## Why `K` is a parameter of the type, not the trajectory

If `K` were per-trajectory data, `F` would still depend on the trajectory, and the existential
`∃F` would be vacuous. By parameterizing the **type** `BoundedFrequencyFourierTrajectory K`,
we fix `K` outside the universal quantifier, so `F_K` is a genuine witness.
-/

namespace NavierStokes.FourierModel

set_option autoImplicit false

open NavierStokes.DiscreteKernel

/-! ## Frequency-bounded trajectory type -/

/-- A Fourier trajectory whose mode wavenumber-squares are globally bounded by `K`.

    `K` is a fixed parameter of the type — the same `K` governs all modes and all times.
    This is the Galerkin cutoff condition: `∀ i, (freqs i)² ≤ K`.

    Wraps `EnergyDissipatingFourierTrajectory` with one additional hypothesis. -/
structure BoundedFrequencyFourierTrajectory (K : Rat) where
  traj          : EnergyDissipatingFourierTrajectory
  freq_sq_bound : ∀ i : Fin traj.N, (traj.freqs i : Rat) ^ 2 ≤ K

/-! ## Pointwise palinstrophy ≤ K · enstrophy -/

/-- For a frequency-bounded trajectory, palinstrophy is bounded pointwise by K · enstrophy.

    Proof: at each mode i,
      (kᵢ)⁴ · aᵢ² = (kᵢ)² · ((kᵢ)² · aᵢ²) ≤ K · ((kᵢ)² · aᵢ²)
    using `(kᵢ)² ≤ K` and `0 ≤ (kᵢ)² · aᵢ²`. Then sum over all modes. -/
theorem palinstrophyFTraj_le_K_enstrophy
    {K : Rat} (bt : BoundedFrequencyFourierTrajectory K) (t : Rat) :
    palinstrophyFTraj bt.traj t ≤ K * enstrophyFTraj bt.traj t := by
  unfold palinstrophyFTraj enstrophyFTraj palinstrophyF enstrophyF trajFieldAt
  simp only
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  calc (bt.traj.freqs i : Rat) ^ 4 * bt.traj.stateAt t i ^ 2
      = (bt.traj.freqs i : Rat) ^ 2 * ((bt.traj.freqs i : Rat) ^ 2 * bt.traj.stateAt t i ^ 2) := by
          ring
    _ ≤ K * ((bt.traj.freqs i : Rat) ^ 2 * bt.traj.stateAt t i ^ 2) :=
          mul_le_mul_of_nonneg_right (bt.freq_sq_bound i)
            (mul_nonneg (sq_nonneg _) (sq_nonneg _))

/-! ## Integral bound: integratedPalinstrophyF ≤ K · integratedEnstrophyF -/

/-- `integratedPalinstrophyF ≤ K · integratedEnstrophyF` from the pointwise bound. -/
theorem integratedPalinstrophyF_le_K_intEns
    {K : Rat} (bt : BoundedFrequencyFourierTrajectory K) (T : Rat) :
    integratedPalinstrophyF bt.traj T ≤ K * integratedEnstrophyF bt.traj T := by
  unfold integratedPalinstrophyF integratedEnstrophyF
  -- Step 1: discreteIntegral palinstrophyFTraj ≤ discreteIntegral (K * enstrophyFTraj)
  have h1 := discreteIntegral_le_of_pointwise
    (palinstrophyFTraj bt.traj)
    (fun t => K * enstrophyFTraj bt.traj t)
    T
    (palinstrophyFTraj_le_K_enstrophy bt)
  -- Step 2: discreteIntegral (K * enstrophyFTraj) = K * discreteIntegral enstrophyFTraj
  have h2 : discreteIntegral (fun t => K * enstrophyFTraj bt.traj t) T =
      K * discreteIntegral (enstrophyFTraj bt.traj) T := by
    simp only [discreteIntegral]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _; ring
  linarith

/-! ## Bound definition and main statement -/

/-- The 3-argument BKM bound for frequency-bounded trajectories.
    F_K(τ, E₀, ν) = (hbar/nsNu) · (1 + K) · τ -/
noncomputable def agmonBKMBoundFBounded (K : Rat) (τ _E₀ _ν : Rat) : Rat :=
  NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu * (1 + K) * τ

/-- PreciseGapStatementFourierBounded K: 3-argument F version, universal over
    all `BoundedFrequencyFourierTrajectory K`. -/
def PreciseGapStatementFourierBounded (K : Rat) : Prop :=
  ∃ F : Rat → Rat → Rat → Rat,
    ∀ (bt : BoundedFrequencyFourierTrajectory K) (T : Rat), 0 < T →
      bkmAgmonIntegralF bt.traj T ≤
        F (entropicProperTimeF bt.traj T)
          (kineticEnergyFTraj bt.traj 0)
          NavierStokes.Millennium.nsNu

/-- **MAIN THEOREM (Stage 147)**: `PreciseGapStatementFourierBounded K` is PROVED.

    Witness: `F_K(τ, E₀, ν) = (hbar/nsNu) · (1 + K) · τ`

    **F is independent of the trajectory** — it depends only on K (the class parameter)
    and the physical constants hbar, nsNu.  The ∃F∀traj quantifier order is correct.

    Proof calc chain:
      bkmAgmonIntegralF
      = intEns + intPal                                  [def, rfl]
      = (hbar/nsNu)·τ + intPal                          [integratedEnstrophy_eq_hbar_tau]
      ≤ (hbar/nsNu)·τ + K · intEns                      [integratedPalinstrophyF_le_K_intEns]
      = (hbar/nsNu)·τ + K · (hbar/nsNu)·τ               [integratedEnstrophy_eq_hbar_tau]
      = (hbar/nsNu) · (1 + K) · τ                       [ring]

    **`freq_sq_bound` is essential**: without it, `intPal` is unbounded. -/
theorem pgs_fourier_bounded (K : Rat) : PreciseGapStatementFourierBounded K := by
  refine ⟨agmonBKMBoundFBounded K, ?_⟩
  intro bt T _hT
  unfold bkmAgmonIntegralF agmonBKMBoundFBounded
  have htau  := integratedEnstrophy_eq_hbar_tau bt.traj T
  have hintPal := integratedPalinstrophyF_le_K_intEns bt T
  calc integratedEnstrophyF bt.traj T + integratedPalinstrophyF bt.traj T
      = NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu *
          entropicProperTimeF bt.traj T + integratedPalinstrophyF bt.traj T := by
          rw [htau]
    _ ≤ NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu *
          entropicProperTimeF bt.traj T +
          K * integratedEnstrophyF bt.traj T := by
          linarith
    _ = NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu *
          entropicProperTimeF bt.traj T +
          K * (NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu *
            entropicProperTimeF bt.traj T) := by
          rw [htau]
    _ = NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu *
          (1 + K) * entropicProperTimeF bt.traj T := by ring

/-! ## Stability: monotonicity of F_K in K and τ -/

/-- **F_K is monotone in K** (tightening the cutoff tightens the bound):
    K₁ ≤ K₂ → F_{K₁}(τ,…) ≤ F_{K₂}(τ,…) for τ ≥ 0.

    Use this to "upgrade" a proof when you substitute a larger/looser cutoff,
    or to confirm that the bound deteriorates gracefully as K grows. -/
theorem agmonBKMBoundFBounded_mono_K
    (K₁ K₂ τ E₀ ν : Rat) (hK : K₁ ≤ K₂) (hτ : 0 ≤ τ) :
    agmonBKMBoundFBounded K₁ τ E₀ ν ≤ agmonBKMBoundFBounded K₂ τ E₀ ν := by
  unfold agmonBKMBoundFBounded
  have hbnu : (0 : Rat) ≤ NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu :=
    le_of_lt (div_pos NavierStokes.Millennium.hbar_pos NavierStokes.Millennium.nsNu_pos)
  -- (hbar/nsNu)*(1+K₂)*τ - (hbar/nsNu)*(1+K₁)*τ = (hbar/nsNu)*(K₂-K₁)*τ ≥ 0
  nlinarith [mul_nonneg (mul_nonneg hbnu (by linarith : (0:Rat) ≤ K₂ - K₁)) hτ]

/-- **F_K is monotone in τ**: τ₁ ≤ τ₂ → F_K(τ₁,…) ≤ F_K(τ₂,…) for K ≥ 0. -/
theorem agmonBKMBoundFBounded_mono_tau
    (K τ₁ τ₂ E₀ ν : Rat) (hτ : τ₁ ≤ τ₂) (hK : 0 ≤ K) :
    agmonBKMBoundFBounded K τ₁ E₀ ν ≤ agmonBKMBoundFBounded K τ₂ E₀ ν := by
  unfold agmonBKMBoundFBounded
  have hbnu : (0 : Rat) ≤ NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu :=
    le_of_lt (div_pos NavierStokes.Millennium.hbar_pos NavierStokes.Millennium.nsNu_pos)
  -- (hbar/nsNu)*(1+K)*(τ₂-τ₁) ≥ 0 since all three factors are nonneg
  nlinarith [mul_nonneg (mul_nonneg hbnu (by linarith : (0:Rat) ≤ 1 + K)) (by linarith : (0:Rat) ≤ τ₂ - τ₁)]

/-! ## Non-vacuousness: example trajectory fits the bounded class -/

/-- The example trajectory from Stage 144 (N=1, freq=1) has freq² = 1 ≤ K for any K ≥ 1. -/
def exampleBoundedTraj (K : Rat) (hK : 1 ≤ K) : BoundedFrequencyFourierTrajectory K :=
  { traj          := exampleNontrivialTraj
    freq_sq_bound := fun _ => by
        simp [exampleNontrivialTraj]
        exact hK }

theorem exampleBoundedTraj_satisfies_bound (K : Rat) (hK : 1 ≤ K) :
    ∀ i : Fin (exampleNontrivialTraj).N,
      ((exampleNontrivialTraj).freqs i : Rat) ^ 2 ≤ K := by
  intro i
  simp [exampleNontrivialTraj]
  exact hK

/-! ## Refinement lattice: 147 → 146 → 144 -/

/-- **(A) Bounded → palinstrophy budget**: a `BoundedFrequencyFourierTrajectory K` satisfies
    the Stage 146 external palinstrophy budget condition with `M_pal = K · τ`.

    This is the bridge from the trajectory-type parameter `K` to the budget hypothesis
    `hPal` in Stage 146.  It makes the 147→146 implication explicit. -/
theorem bounded_implies_pal_budget
    {K : Rat} (bt : BoundedFrequencyFourierTrajectory K) (T : Rat) :
    entropicPalinstrophyF bt.traj T ≤ K * entropicProperTimeF bt.traj T := by
  unfold entropicPalinstrophyF entropicProperTimeF
  have hintPal := integratedPalinstrophyF_le_K_intEns bt T
  have hbnu_nn : (0 : Rat) ≤
      NavierStokes.Millennium.nsNu / NavierStokes.Millennium.hbar :=
    le_of_lt (div_pos NavierStokes.Millennium.nsNu_pos NavierStokes.Millennium.hbar_pos)
  calc NavierStokes.Millennium.nsNu / NavierStokes.Millennium.hbar *
          integratedPalinstrophyF bt.traj T
      ≤ NavierStokes.Millennium.nsNu / NavierStokes.Millennium.hbar *
          (K * integratedEnstrophyF bt.traj T) :=
          mul_le_mul_of_nonneg_left hintPal hbnu_nn
    _ = K * (NavierStokes.Millennium.nsNu / NavierStokes.Millennium.hbar *
              integratedEnstrophyF bt.traj T) := by ring

/-- **(B) BKM surrogate hierarchy**: the Stage 144 enstrophy-surrogate BKM integral is ≤ the
    Stage 146 Agmon-surrogate BKM integral (which also includes palinstrophy).

        bkmVorticityIntegralF ≤ bkmAgmonIntegralF
        [= integratedEnstrophyF ≤ integratedEnstrophyF + integratedPalinstrophyF]

    Combined with `pgs_fourier_agmon`, this gives a bound on `bkmVorticityIntegralF` too. -/
theorem bkmVorticity_le_bkmAgmon
    (traj : EnergyDissipatingFourierTrajectory) (T : Rat) :
    bkmVorticityIntegralF traj T ≤ bkmAgmonIntegralF traj T := by
  rw [bkm_eq_integrated_enstrophy]
  unfold bkmAgmonIntegralF integratedPalinstrophyF
  have hpal := discreteIntegral_nonneg (palinstrophyFTraj traj) T
    (fun t => palinstrophyF_nonneg (trajFieldAt traj t))
  linarith

/-- **(C) Stage 147 as a corollary of Stage 146**:
    `pgs_fourier_bounded K` is an instance of `pgs_fourier_agmon` with `M_pal := K · τ`.

    This makes the implication **147 → 146** executable inside Lean:
    the bounded-frequency certificate is literally a specialization of the pal-budget
    certificate at `M_pal = K · entropicProperTimeF bt.traj T`.

    Note: this gives an alternative proof of `pgs_fourier_bounded`; both proofs share the
    same witness `F_K(τ,E₀,ν) = (hbar/nsNu)·(1+K)·τ` (up to definitional unfolding). -/
theorem pgs_fourier_bounded_via_agmon (K : Rat) : PreciseGapStatementFourierBounded K := by
  obtain ⟨F_agmon, hF_agmon⟩ := pgs_fourier_agmon
  exact ⟨fun τ E₀ ν => F_agmon τ E₀ ν (K * τ),
    fun bt T hT =>
      hF_agmon bt.traj T (K * entropicProperTimeF bt.traj T) hT
        (bounded_implies_pal_budget bt T)⟩

/-! ## Chain summary: all three tiers simultaneously proved -/

/-- **Refinement chain**: the three Fourier certificate tiers hold simultaneously for any `K`.

    ```
    PreciseGapStatementFourierBounded K    (Stage 147, ∀ BoundedFreq(K), 3-arg F_K)
    ∧ PreciseGapStatementFourierAgmon      (Stage 146, ∀ traj with hPal, 4-arg F)
    ∧ PreciseGapStatementFourier           (Stage 144, ∀ traj, tautological τ-only F)
    ```

    Proof is a single term: `⟨pgs_fourier_bounded K, pgs_fourier_agmon, pgs_fourier⟩`.

    **Use for future maintainers**: to verify all three tiers in one shot, or to obtain
    any tier via `h.1`, `h.2.1`, `h.2.2`. -/
theorem fourier_certificate_chain (K : Rat) :
    PreciseGapStatementFourierBounded K ∧
    PreciseGapStatementFourierAgmon ∧
    PreciseGapStatementFourier :=
  ⟨pgs_fourier_bounded K, pgs_fourier_agmon, pgs_fourier⟩

end NavierStokes.FourierModel
