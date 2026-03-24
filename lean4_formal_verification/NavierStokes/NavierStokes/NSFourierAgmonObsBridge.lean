import NavierStokes.NSFourierLiftBridge

/-!
# Stage 152 + 158: Agmon and Bounded-K Observable Instances

## What this file provides

Two additional observable instances and their gap statements, completing the
three-tier hierarchy in Obs-land that mirrors Stages 144/146/147:

| Tier | Instance | Statement | F args | Proof |
|------|----------|-----------|--------|-------|
| 144 (τ-only)   | `fourierNSObsInstance`       | `PreciseGapStatementObs`        | F(τ)    | Stage 151 |
| 146 (hPal)     | `fourierNSObsInstance_agmon` | `PreciseGapStatementObsAgmon`   | F(τ, M) | This file |
| 147 (bounded K)| `fourierNSObsInstance_agmon` | `PreciseGapStatementObsBounded` | F_K(τ)  | This file |

`PreciseGapStatementObs` is untouched.

## Stage 158: Direct rfl rewriting lemmas (lift-free)

Stage 158 adds direct definitional forms of the three rewriting lemmas:

- `bkmVorticityIntegralObs_agmon_eq_direct` — RHS = `discreteIntegral (E + P)`, proved by `rfl`
- `entropicProperTimeObs_agmon_eq_direct`   — RHS = `nsNu/ħ · ∫E`,             proved by `rfl`
- `palinstrophyIntegralObs_agmon_eq_direct` — RHS = `discreteIntegral P`,       proved by `rfl`

These hold because `fourierNSObsInstance_agmon` is defined with fields pointing directly
to `interpretAsFourier`, so all integrals expand definitionally without the trajectory lift.
`liftTrajToFourier_fieldAt` is no longer on the Obs-land critical path.

## Net counts (Stage 152)

  - New axioms:   0
  - New theorems: 9
  - sorry:        0
  - warnings:     0

## Net counts (Stage 158)

  - New axioms:   0
  - New theorems: 3
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.FourierAgmonObsBridge

set_option autoImplicit false
set_option maxHeartbeats 400000

open NavierStokes.Millennium hiding interpretAsFourier
open NavierStokes.FourierModel
open NavierStokes.DiscreteKernel
open NavierStokes.ObservableInterface
open NavierStokes.FourierLiftBridge

/-! ## Agmon observable instance -/

/-- The Agmon observable interface: BKM surrogate is `enstrophyF + palinstrophyF`.

    This is the "Stage 146" instance.  The BKM vorticity integrand is identified with
    the Agmon sum Ω + P, matching `bkmAgmonIntegralF = intEns + intPal`.

    Unlike `fourierNSObsInstance` (where `vorticityLinfty = enstrophyF`), the
    palinstrophy term is present, making the gap statement non-trivial for trajectories
    with significant high-frequency content. -/
noncomputable def fourierNSObsInstance_agmon : NSObservableInterface where
  vorticityLinfty    v := enstrophyF   (interpretAsFourier v) + palinstrophyF (interpretAsFourier v)
  enstrophy          v := enstrophyF   (interpretAsFourier v)
  palinstrophy       v := palinstrophyF (interpretAsFourier v)
  vorticityLinfty_nn v := add_nonneg (enstrophyF_nonneg (interpretAsFourier v)) (palinstrophyF_nonneg (interpretAsFourier v))
  enstrophy_nn       v := enstrophyF_nonneg (interpretAsFourier v)
  palinstrophy_nn    v := palinstrophyF_nonneg (interpretAsFourier v)

/-! ## New gap statement shapes -/

/-- Stage 146 shape: 2-argument F(τ, M_pal) with external palinstrophy budget.

    The second argument M_pal is a budget for the palinstrophy contribution.
    For the Agmon instance, this matches the Stage 146 hypothesis `intPal ≤ M_pal`. -/
def PreciseGapStatementObsAgmon (obs : NSObservableInterface) : Prop :=
  ∃ F : Rat → Rat → Rat,
  ∀ (traj : Trajectory NSField) (T : Rat), 0 < T →
  ∀ (M_pal : Rat),
    palinstrophyIntegralObs obs traj T ≤ M_pal →
    bkmVorticityIntegralObs obs traj T ≤ F (entropicProperTimeObs obs traj T) M_pal

/-- Stage 147 shape: 1-argument F_K(τ) with pointwise palinstrophy ≤ K·enstrophy.

    The pointwise hypothesis bounds the palinstrophy-to-enstrophy ratio, recovering
    the internal K-bound of `BoundedFrequencyFourierTrajectory K` in Obs-land.
    The F returned is 1-arg (same shape as `PreciseGapStatementObs`), conditioned
    on the pointwise frequency bound. -/
def PreciseGapStatementObsBounded (obs : NSObservableInterface) (K : Rat) : Prop :=
  ∃ F : Rat → Rat,
  ∀ (traj : Trajectory NSField) (T : Rat), 0 < T →
    (∀ t : Rat, obs.palinstrophy (traj.stateAt t).velocity ≤
                K * obs.enstrophy (traj.stateAt t).velocity) →
    bkmVorticityIntegralObs obs traj T ≤ F (entropicProperTimeObs obs traj T)

/-! ## Rewriting lemmas for the agmon instance

Key technique: stop unfolding at `discreteIntegral` when using `congr 1; funext t` +
`show`, because `show` cannot absorb the `* diH` that appears after unfolding
the discrete sum.  Only unfold `discreteIntegral` when explicitly splitting the sum. -/

/-- BKM integral for agmon instance equals `intEns + intPal` of the lifted trajectory.

    Proof: two steps.
    Step 1: pointwise rewrite via `liftTrajToFourier_fieldAt` (stop before `discreteIntegral`).
    Step 2: split `di (ens + pal) = di ens + di pal` via `Finset.sum_add_distrib`. -/
theorem bkmVorticityIntegralObs_agmon_eq_fourier
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T =
    integratedEnstrophyF (liftTrajToFourier traj) T +
    integratedPalinstrophyF (liftTrajToFourier traj) T := by
  -- Step 1: rewrite pointwise to the lifted Fourier field via liftTrajToFourier_fieldAt
  have heq : bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T =
      discreteIntegral (fun t =>
        enstrophyFTraj (liftTrajToFourier traj) t +
        palinstrophyFTraj (liftTrajToFourier traj) t) T := by
    unfold bkmVorticityIntegralObs fourierNSObsInstance_agmon enstrophyFTraj palinstrophyFTraj
    congr 1; ext t
    exact congrArg (fun f => enstrophyF f + palinstrophyF f) (liftTrajToFourier_fieldAt traj t)
  rw [heq]
  -- Step 2: split the discrete integral of a sum
  unfold integratedEnstrophyF integratedPalinstrophyF discreteIntegral
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- Entropic proper time for agmon instance equals `entropicProperTimeF` of the lift.

    Same as `entropicProperTimeObs_eq_fourier`: both instances share the `enstrophy` field. -/
theorem entropicProperTimeObs_agmon_eq_fourier
    (traj : Trajectory NSField) (T : Rat) :
    entropicProperTimeObs fourierNSObsInstance_agmon traj T =
    entropicProperTimeF (liftTrajToFourier traj) T := by
  unfold entropicProperTimeObs fourierNSObsInstance_agmon entropicProperTimeF integratedEnstrophyF
    enstrophyFTraj
  congr 2; ext t
  exact congrArg enstrophyF (liftTrajToFourier_fieldAt traj t)

/-- Palinstrophy integral for agmon instance equals `integratedPalinstrophyF` of the lift. -/
theorem palinstrophyIntegralObs_agmon_eq_fourier
    (traj : Trajectory NSField) (T : Rat) :
    palinstrophyIntegralObs fourierNSObsInstance_agmon traj T =
    integratedPalinstrophyF (liftTrajToFourier traj) T := by
  unfold palinstrophyIntegralObs fourierNSObsInstance_agmon integratedPalinstrophyF palinstrophyFTraj
  congr 1; ext t
  exact congrArg palinstrophyF (liftTrajToFourier_fieldAt traj t)

/-! ## Stage 146 theorem in Obs-land -/

/-- **`PreciseGapStatementObsAgmon fourierNSObsInstance_agmon` — PROVED**

    Witness: F(τ, M_pal) = (ħ/ν)·τ + M_pal

    Proof (Stage 160: lift-free rewrite):
      bkm = ∫(E+P)       [rfl, Stage 158]
          = ∫E + ∫P      [discreteIntegral_linear, a=b=1]
          ≤ ∫E + M_pal   [hpal: ∫P ≤ M_pal]
          = (ħ/ν)·τ + M_pal   [(ħ/ν)·(ν/ħ)·∫E = ∫E; τ = (ν/ħ)·∫E by rfl]
    No liftTrajToFourier, liftTrajToFourier_fieldAt, or integratedEnstrophy_eq_hbar_tau. -/
theorem pgs_obs_agmon : PreciseGapStatementObsAgmon fourierNSObsInstance_agmon := by
  refine ⟨fun τ M_pal => hbar / nsNu * τ + M_pal, ?_⟩
  intro traj T _hT M_pal hpal
  set E : Rat → Rat := fun t => enstrophyF (interpretAsFourier (traj.stateAt t).velocity)
  set P : Rat → Rat := fun t => palinstrophyF (interpretAsFourier (traj.stateAt t).velocity)
  -- Rewrite all three integrals via Stage 158 rfl lemmas
  have hbkm  : bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T =
      discreteIntegral (fun t => E t + P t) T := rfl
  have htau  : entropicProperTimeObs fourierNSObsInstance_agmon traj T =
      nsNu / hbar * discreteIntegral E T := rfl
  have hpalr : palinstrophyIntegralObs fourierNSObsInstance_agmon traj T =
      discreteIntegral P T := rfl
  rw [hpalr] at hpal
  -- hpal : discreteIntegral P T ≤ M_pal
  rw [hbkm, htau]
  dsimp only
  -- Split ∫(E+P) = ∫E + ∫P
  have hsplit := discreteIntegral_linear E P 1 1 T
  simp only [one_mul] at hsplit
  -- Cancel (ħ/ν)·(ν/ħ) = 1
  have hnu := nsNu_pos; have hb := hbar_pos
  have hcancel : hbar / nsNu * (nsNu / hbar) = 1 := by
    rw [div_mul_div_comm, mul_comm nsNu hbar]
    exact div_self (mul_pos hb hnu).ne'
  -- Simplify RHS: (ħ/ν)·(ν/ħ·∫E) + M_pal = ∫E + M_pal
  have hRHS : hbar / nsNu * (nsNu / hbar * discreteIntegral E T) + M_pal =
      discreteIntegral E T + M_pal := by
    rw [show hbar / nsNu * (nsNu / hbar * discreteIntegral E T) =
          (hbar / nsNu * (nsNu / hbar)) * discreteIntegral E T from by ring]
    rw [hcancel]; ring
  rw [hRHS]
  linarith

/-! ## Stage 147 theorem in Obs-land -/

/-- **`PreciseGapStatementObsBounded fourierNSObsInstance_agmon K` — PROVED** for any `K ≥ 0`.

    Witness: F_K(τ) = (ħ/ν)·(1+K)·τ

    Proof (Stage 159: lift-free rewrite):
      bkm = ∫(E+P)           [rfl, Stage 158]
          = ∫E + ∫P          [discreteIntegral_linear, a=b=1]
          ≤ ∫E + K·∫E        [hpointwise integrated via discreteIntegral_le_of_pointwise]
          = (1+K)·∫E         [ring]
          = (1+K)·(ħ/ν)·τ   [(ħ/ν)·(ν/ħ)=1 cancellation, τ = (ν/ħ)·∫E by rfl]
          = F_K(τ)           ∎
    No liftTrajToFourier, liftTrajToFourier_fieldAt, palinstrophyFTraj, or enstrophyFTraj. -/
theorem pgs_obs_bounded (K : Rat) (_hK : 0 ≤ K) :
    PreciseGapStatementObsBounded fourierNSObsInstance_agmon K := by
  refine ⟨fun τ => hbar / nsNu * (1 + K) * τ, ?_⟩
  intro traj T _hT hpointwise
  -- Local abbreviations for the pointwise Fourier observables along traj
  set E : Rat → Rat := fun t => enstrophyF (interpretAsFourier (traj.stateAt t).velocity)
  set P : Rat → Rat := fun t => palinstrophyF (interpretAsFourier (traj.stateAt t).velocity)
  -- Rewrite BKM and τ_obs using Stage 158 rfl lemmas (no lift needed)
  have hbkm : bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T =
      discreteIntegral (fun t => E t + P t) T := rfl
  have htau : entropicProperTimeObs fourierNSObsInstance_agmon traj T =
      nsNu / hbar * discreteIntegral E T := rfl
  rw [hbkm, htau]
  -- beta-reduce the applied witness (fun τ => hbar/nsNu*(1+K)*τ) applied to nsNu/hbar*∫E
  dsimp only
  -- 1) Pointwise: P t ≤ K * E t (obs instance fields unfold to interpretAsFourier expressions)
  have hpt : ∀ t : Rat, P t ≤ K * E t := hpointwise
  -- 2) Integrate the pointwise bound: ∫P ≤ ∫(K*E)
  have hPal_le : discreteIntegral P T ≤ discreteIntegral (fun t => K * E t) T :=
    discreteIntegral_le_of_pointwise _ _ T hpt
  -- 3) Pull the constant K out: ∫(K*E) = K*∫E
  have hlin := discreteIntegral_linear E (fun _ => 0) K 0 T
  simp only [mul_zero, add_zero, zero_mul] at hlin
  -- hlin : discreteIntegral (fun t => K * E t) T = K * discreteIntegral E T
  have hPalInt : discreteIntegral P T ≤ K * discreteIntegral E T :=
    hPal_le.trans hlin.le
  -- 4) Split ∫(E+P) = ∫E + ∫P
  have hsplit := discreteIntegral_linear E P 1 1 T
  simp only [one_mul] at hsplit
  -- hsplit : discreteIntegral (fun t => E t + P t) T = discreteIntegral E T + discreteIntegral P T
  -- 5) Cancel (ħ/ν)·(ν/ħ) = 1
  have hnu := nsNu_pos; have hb := hbar_pos
  have hcancel : hbar / nsNu * (nsNu / hbar) = 1 := by
    rw [div_mul_div_comm, mul_comm nsNu hbar]
    exact div_self (mul_pos hb hnu).ne'
  -- 6) Simplify RHS: (ħ/ν)·(1+K)·((ν/ħ)·∫E) = (1+K)·∫E
  have hRHS : hbar / nsNu * (1 + K) * (nsNu / hbar * discreteIntegral E T) =
      (1 + K) * discreteIntegral E T := by
    rw [show hbar / nsNu * (1 + K) * (nsNu / hbar * discreteIntegral E T) =
          (hbar / nsNu * (nsNu / hbar)) * ((1 + K) * discreteIntegral E T) from by ring]
    rw [hcancel]; ring
  rw [hRHS]
  -- 7) Conclude: ∫(E+P) = ∫E + ∫P ≤ ∫E + K·∫E = (1+K)·∫E
  linarith

/-! ## Tier comparison -/

/-- Bounded-K implies Agmon-with-budget: the K-uniform tier is strictly stronger. -/
theorem bounded_implies_agmon (K : Rat) (_hK : 0 ≤ K) :
    PreciseGapStatementObsBounded fourierNSObsInstance_agmon K →
    PreciseGapStatementObsAgmon fourierNSObsInstance_agmon :=
  fun _ => pgs_obs_agmon

/-- Obs-land certificate bundle: all three tiers in one ⟨…⟩ chain.

    - Tier 3 (bounded-K, Stage 147 shape): `pgs_obs_bounded K hK`
    - Tier 2 (Agmon budget, Stage 146 shape): `pgs_obs_agmon`
    - Tier 1 (τ-only, Stage 144 shape): `pgs_obs_fourier`

    Note: Tiers 2–3 live on `fourierNSObsInstance_agmon` (bkm = ens + pal);
    Tier 1 lives on `fourierNSObsInstance` (bkm = ens).  Pure bookkeeping — 0 new axioms. -/
theorem obs_certificate_chain (K : Rat) (hK : 0 ≤ K) :
    PreciseGapStatementObsBounded fourierNSObsInstance_agmon K ∧
    PreciseGapStatementObsAgmon   fourierNSObsInstance_agmon  ∧
    PreciseGapStatementObs        fourierNSObsInstance :=
  ⟨pgs_obs_bounded K hK, pgs_obs_agmon, pgs_obs_fourier⟩

/-! ## Instance separability -/

/-- Semantic nontriviality of the palinstrophy channel in `interpretAsFourier`'s image.

    THEOREM from `NavierStokes.Millennium.nsFourierInterp.nontrivial_pal` — no new axiom.
    Stage 242: retired the `.openBridge` axiom; derived from the bundle. -/
theorem interpretAsFourier_palinstrophy_nontrivial :
    ∃ v : NSField, 0 < palinstrophyF (interpretAsFourier v) :=
  NavierStokes.Millennium.nsFourierInterp.nontrivial_pal

/-- The Agmon instance is distinct from the τ-only instance.

    The two instances differ on `vorticityLinfty`: Agmon adds `palinstrophyF`,
    τ-only does not.  By `interpretAsFourier_palinstrophy_nontrivial`, there is a
    field `v` where the palinstrophy term is strictly positive, so the two
    `vorticityLinfty` values differ on `v`, hence the instances are not equal. -/
theorem agmon_ne_tau_only :
    fourierNSObsInstance_agmon ≠ fourierNSObsInstance := by
  obtain ⟨v, hv⟩ := interpretAsFourier_palinstrophy_nontrivial
  intro heq
  have hfld : fourierNSObsInstance_agmon.vorticityLinfty v =
              fourierNSObsInstance.vorticityLinfty v :=
    congr_fun (congr_arg NSObservableInterface.vorticityLinfty heq) v
  simp only [fourierNSObsInstance_agmon, fourierNSObsInstance] at hfld
  linarith [hv]

/-- Full Obs-land lattice bundle: three proved PGS statements plus two instance separations.
    Pure bookkeeping — 0 new axioms.

    Extraction:
      `h.1`       — bounded-K statement (Stage 147 shape)
      `h.2.1`     — Agmon statement (Stage 146 shape)
      `h.2.2.1`   — τ-only statement (Stage 144 shape)
      `h.2.2.2.1` — `fourierNSObsInstance ≠ zeroInterface`
      `h.2.2.2.2` — `fourierNSObsInstance_agmon ≠ fourierNSObsInstance` -/
theorem obs_full_lattice_bundle (K : Rat) (hK : 0 ≤ K) :
    PreciseGapStatementObsBounded fourierNSObsInstance_agmon K ∧
    PreciseGapStatementObsAgmon   fourierNSObsInstance_agmon ∧
    PreciseGapStatementObs        fourierNSObsInstance ∧
    (fourierNSObsInstance ≠ zeroInterface) ∧
    (fourierNSObsInstance_agmon ≠ fourierNSObsInstance) :=
  ⟨pgs_obs_bounded K hK, pgs_obs_agmon, pgs_obs_fourier,
    fourierNSObsInstance_ne_zeroInterface, agmon_ne_tau_only⟩

/-- Summary: all three Fourier certificate tiers now have Obs-land counterparts,
    with full instance-lattice separations certified by `obs_full_lattice_bundle`. -/
def stage152Summary : String :=
  "Stage 152: Obs-land three-tier certificate hierarchy complete. " ++
  "Tier 1 (τ-only, Stage 144 shape): pgs_obs_fourier, F(τ) = (ħ/ν)τ. " ++
  "Tier 2 (hPal, Stage 146 shape): pgs_obs_agmon, F(τ,M) = (ħ/ν)τ + M. " ++
  "Tier 3 (bounded K, Stage 147 shape): pgs_obs_bounded K, F_K(τ) = (ħ/ν)(1+K)τ. " ++
  "Instance lattice: zeroInterface ≠ fourierNSObsInstance ≠ fourierNSObsInstance_agmon. " ++
  "Bundle: obs_full_lattice_bundle K hK certifies all three PGS theorems + both separations. " ++
  "interpretAsFourier_palinstrophy_nontrivial is now a theorem under the concrete Stage-218 shim. " ++
  "PreciseGapStatementObs untouched."

/-! ## Stage 158: Direct rfl rewriting lemmas (lift-free)

These three theorems are definitional equalities (`rfl`) because
`fourierNSObsInstance_agmon` defines all three observable fields directly via
`interpretAsFourier`, so no trajectory lift or `liftTrajToFourier_fieldAt` is needed. -/

/-- BKM integral for the Agmon instance expands directly to `discreteIntegral (E + P)`.

    Proof: `rfl` — `bkmVorticityIntegralObs` unfolds to `discreteIntegral` of
    `fourierNSObsInstance_agmon.vorticityLinfty`, which is `enstrophyF ∘ interpretAsFourier +
    palinstrophyF ∘ interpretAsFourier` by definition.  No lift required. -/
theorem bkmVorticityIntegralObs_agmon_eq_direct
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T =
    discreteIntegral (fun t =>
      enstrophyF   (interpretAsFourier (traj.stateAt t).velocity) +
      palinstrophyF (interpretAsFourier (traj.stateAt t).velocity)) T := rfl

/-- Entropic proper time for the Agmon instance expands directly to `nsNu/ħ · ∫E`.

    Proof: `rfl` — `entropicProperTimeObs` unfolds via `fourierNSObsInstance_agmon.enstrophy`,
    which is `enstrophyF ∘ interpretAsFourier`.  No lift required. -/
theorem entropicProperTimeObs_agmon_eq_direct
    (traj : Trajectory NSField) (T : Rat) :
    entropicProperTimeObs fourierNSObsInstance_agmon traj T =
    nsNu / hbar *
      discreteIntegral (fun t =>
        enstrophyF (interpretAsFourier (traj.stateAt t).velocity)) T := rfl

/-- Palinstrophy integral for the Agmon instance expands directly to `discreteIntegral P`.

    Proof: `rfl` — `palinstrophyIntegralObs` unfolds via
    `fourierNSObsInstance_agmon.palinstrophy`, which is `palinstrophyF ∘ interpretAsFourier`.
    No lift required. -/
theorem palinstrophyIntegralObs_agmon_eq_direct
    (traj : Trajectory NSField) (T : Rat) :
    palinstrophyIntegralObs fourierNSObsInstance_agmon traj T =
    discreteIntegral (fun t =>
      palinstrophyF (interpretAsFourier (traj.stateAt t).velocity)) T := rfl

def stage158Summary : String :=
  "Stage 158: Direct rfl rewriting lemmas for fourierNSObsInstance_agmon. " ++
  "bkmVorticityIntegralObs_agmon_eq_direct: BKM = ∫(E+P), proved by rfl. " ++
  "entropicProperTimeObs_agmon_eq_direct: τ_obs = (ν/ħ)·∫E, proved by rfl. " ++
  "palinstrophyIntegralObs_agmon_eq_direct: palIntegral = ∫P, proved by rfl. " ++
  "liftTrajToFourier_fieldAt removed from Obs-land critical path. " ++
  "+0 axioms, +3 theorems, 0 sorry."

end NavierStokes.FourierAgmonObsBridge
