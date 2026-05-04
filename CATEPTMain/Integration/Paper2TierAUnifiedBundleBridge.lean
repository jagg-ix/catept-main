-- Tier A (paper §3.2, §4.3, App. A)
import CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge
import CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge
import CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge
-- Tier B Modules 2/3 (paper §3.3, App. B); this file IS Tier B Module 1.
import CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge
import CATEPTMain.Integration.EverettBranchSuppressionBridge
-- Tier C (paper §3.3, §4.2, §5, App. C)
import CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge
import CATEPTMain.Integration.DBBQuantumPotentialBridge
import CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Paper2TierAUnifiedBundleBridge — Tier B follow-up to Tier A

Source: `Paper2_CAT_EPT_Foundations (6).pdf`

Composes the three Tier A carriers
* `ThermalHamiltonianFromDensityMatrix`  (paper §4.3 eq. 28-31)
* `PageWoottersDissipativeCarrier`        (paper Appendix A)
* `UVCoercivityCarrier ℝ`                 (paper §3.2 / Prop 1)

into a **single unified witness** showing that the operational identity
`H_th = -ln ρ = S_I/ℏ = τ_ent` (Matsubara/Connes-Rovelli), the
dissipative amplitude `|amp|² = exp(-S_I/ℏ)` (Page-Wootters) and
the absolute damping bound `exp(-S_I/ℏ) ≤ exp(-C·‖φ‖²/ℏ)` (UV
coercivity) are *simultaneously realisable on a common substrate*.

This is the paper-level statement that the three independent
formalisations are mutually consistent (no carrier holds an
identification that contradicts another).

## What this module ships

* `Paper2TierAUnifiedCarrier` — bundles `T`, `D`, `U` with two
  coherence hypotheses (matching `ℏ`, matching `S_I`).
* `four_fold_identity` — proven `H_th = -ln ρ = S_I/ℏ = τ_ent` extracted
  from the bundle.
* `dissipative_amp_squared_eq_exp_neg_H_th` — proven the dissipative
  squared amplitude equals `exp(-H_th)`.
* `uv_envelope_at_carrier` — proven the UV coercivity envelope
  realises the dissipative damping at any field configuration.
* `exists_trivial` capstone using degenerate witnesses.

## Honest scope

* The carrier-level coherence hypotheses (`hbar_match_TD`,
  `S_I_match`) are *Prop carriers*, not derived equalities — they
  encode that the consumer chose a single physical substrate before
  splitting it into the three views.  The trivial witness shows the
  bundle is inhabited.

## Citations

* Paper §3.2, §4.3, Appendix A: `Paper2_CAT_EPT_Foundations (6).pdf`.
* `ThermalHamiltonianEntropicTimeBridge` (Tier A Module 1).
* `PageWoottersDissipativeExtensionBridge`  (Tier A Module 2).
* `UVCoercivityAbsoluteDampingBridge`       (Tier A Module 3).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge

open CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge
open CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge
open CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge

/-- **Tier A unified carrier** (Tier B follow-up).

Bundles the three Tier A carriers with two coherence hypotheses:
* `hbar_match_TD` — the dissipative PW carrier `D` shares the
  Matsubara/LW witness's `ℏ` (the underlying clock-Hilbert constant
  is the same as the temperature-quantum constant).
* `hbar_match_TU` — the UV-coercivity carrier `U` shares the same
  `ℏ`.
* `S_I_match` — the imaginary action `S_I` accumulated in the PW
  conditional state matches the Matsubara/LW partition-level `S_I`. -/
structure Paper2TierAUnifiedCarrier where
  T : ThermalHamiltonianFromDensityMatrix
  D : PageWoottersDissipativeCarrier
  U : UVCoercivityCarrier ℝ
  /-- Coherence: PW carrier shares Matsubara `ℏ`. -/
  hbar_match_TD : T.M.ℏ = D.pw.ℏ
  /-- Coherence: UV carrier shares Matsubara `ℏ`. -/
  hbar_match_TU : T.M.ℏ = U.ℏ
  /-- Coherence: PW dissipative `S_I` matches Matsubara macroscopic
      `S_I`. -/
  S_I_match : D.S_I = T.M.S_I

namespace Paper2TierAUnifiedCarrier

variable (P : Paper2TierAUnifiedCarrier)

/-! ## Spine theorems -/

/-- **★ Four-fold identity** (paper eq. 31): the thermal Hamiltonian
realises `-ln ρ = S_I/ℏ = τ_ent` simultaneously. -/
theorem four_fold_identity :
    P.T.H_th = - Real.log P.T.rho ∧
    P.T.H_th = P.T.M.S_I / P.T.M.ℏ ∧
    P.T.H_th = P.T.M.τ_ent :=
  ⟨P.T.H_th_eq_neg_log_rho, P.T.H_th_eq_S_I_over_hbar,
   P.T.H_th_eq_tau_ent⟩

/-- **Proven**: the dissipative-PW squared amplitude equals
`exp(-H_th)` — the Page-Wootters factorisation lands on the same
`H_th` as the Connes-Rovelli identification. -/
theorem dissipative_amp_squared_eq_exp_neg_H_th :
    P.D.dissipativeAmplitude ^ 2 = Real.exp (- P.T.H_th) := by
  rw [P.D.dissipativeProbability_eq_exp_neg_S_I_over_hbar]
  congr 1
  rw [P.T.H_th_eq_S_I_over_hbar, P.S_I_match, P.hbar_match_TD]

/-- **Proven UV envelope at the unified carrier**: at any field
configuration `φ`, the path-integral damping factor falls under the
UV-coercivity envelope. -/
theorem uv_envelope_at_carrier (φ : ℝ) :
    CATEPTMain.CATEPT.CATEPT.path_integral_damping P.U.ℏ (P.U.S_I φ)
      ≤ Real.exp (- P.U.C * ‖φ‖ ^ 2 / P.U.ℏ) :=
  P.U.paper_proposition_1 φ

/-- **Proven UV non-negativity at the unified carrier**: the per-φ
imaginary action is non-negative. -/
theorem uv_S_I_nonneg (φ : ℝ) : 0 ≤ P.U.S_I φ :=
  P.U.S_I_nonneg φ

/-- **Coherence projection**: the PW carrier's `ℏ` equals the
UV-coercivity carrier's `ℏ`. -/
theorem hbar_match_DU : P.D.pw.ℏ = P.U.ℏ := by
  rw [← P.hbar_match_TD, P.hbar_match_TU]

end Paper2TierAUnifiedCarrier

/-! ## Capstone -/

/-- **Trivial unified witness**: degenerate but inhabited, all
three Tier A carriers built on `ℏ = 1`, `S_I = 0`. -/
theorem exists_trivial : ∃ _ : Paper2TierAUnifiedCarrier, True := by
  -- Build the Matsubara/LW witness (same as Tier A Module 1's trivial)
  let M : CATEPTMain.Integration.MatsubaraLuttingerWardCarrier.MatsubaraLuttingerWardCarrier :=
    { β        := 1
    , ℏ        := 1
    , Ω        := 0
    , Z        := 1
    , S_I      := 0
    , τ_ent    := 0
    , β_pos    := by norm_num
    , ℏ_pos    := by norm_num
    , Z_eq_exp := by simp
    , τ_ent_eq := by ring
    , S_I_eq   := by ring }
  let T : ThermalHamiltonianFromDensityMatrix :=
    { M                       := M
    , rho                     := 1
    , H_th                    := 0
    , rho_pos                 := by norm_num
    , rho_le_one              := by norm_num
    , H_th_eq_neg_log_rho     := by simp
    , H_th_eq_S_I_over_hbar_hyp := by show (0 : ℝ) = 0 / 1; norm_num }
  let pw : CATEPTMain.Integration.PageWoottersQuantumTimeCarrier.PageWoottersCarrier :=
    { t              := 0
    , ℏ              := 1
    , E_S            := 0
    , E_C            := 0
    , tauPW          := 0
    , phaseS         := 0
    , ℏ_pos          := by norm_num
    , WDW_constraint := by ring
    , tauPW_eq       := by ring
    , phaseS_eq      := by ring }
  let D : PageWoottersDissipativeCarrier :=
    { pw                          := pw
    , S_I                         := 0
    , dissipativeAmplitude        := 1
    , S_I_nonneg                  := le_refl 0
    , dissipativeAmplitude_eq     := by
        show (1 : ℝ) = Real.exp (-(0 / (2 * 1)))
        simp }
  let U : UVCoercivityCarrier ℝ :=
    { C := 1
    , C_pos := one_pos
    , S_I := fun φ => φ ^ 2
    , ℏ := 1
    , ℏ_pos := one_pos
    , uv_coercivity_bound := by
        intro φ
        show (1 : ℝ) * ‖φ‖ ^ 2 ≤ φ ^ 2
        rw [one_mul, Real.norm_eq_abs, sq_abs] }
  refine ⟨{ T := T
          , D := D
          , U := U
          , hbar_match_TD := rfl
          , hbar_match_TU := rfl
          , S_I_match := rfl }, trivial⟩

/-- **Capstone bundle.** -/
theorem paper2_tier_a_unified_bundle :
    ∃ _ : Paper2TierAUnifiedCarrier, True :=
  exists_trivial

/-! ## Paper 2 spine aggregation

  Following the `UnificationSpine.CATEPTUnificationBundle` pattern,
  this file is also the **single-source aggregator** for the full Paper
  2 foundations spine (Tiers A/B/C: 9 carrier-level bridges).  The
  Tier B unified bundle above already composes Tier A; here we extend
  the aggregation to cover Tier B Modules 2/3 and all of Tier C, plus
  ship a joint-existence capstone over the nine bridges so any
  downstream consumer (e.g. the root barrel `CATEPTMain.lean`) only
  needs to import this one module. -/

-- Re-exports of the nine Tier A/B/C capstones into the
-- `Paper2TierAUnifiedBundleBridge` namespace.
export CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge (
  thermal_hamiltonian_entropic_time_bundle)
export CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge (
  page_wootters_dissipative_extension_bundle)
export CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge (
  uv_coercivity_absolute_damping_bundle)
export CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge (
  entropic_propagator_envelope_bundle)
export CATEPTMain.Integration.EverettBranchSuppressionBridge (
  everett_branch_suppression_bundle)
export CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge (
  zero_dim_quadratic_action_concrete_bundle)
export CATEPTMain.Integration.DBBQuantumPotentialBridge (
  dbb_quantum_potential_bundle)
export CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge (
  entropy_increase_along_worldline_bundle)

/-- **★ Paper 2 foundations capstone**: the nine carrier-level bridges
of Tiers A/B/C are simultaneously inhabited.  Existence-statement
form of the Paper 2 foundational spine. -/
theorem paper2_foundations_bundle :
    (∃ _ : CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge.ThermalHamiltonianFromDensityMatrix, True) ∧
    (∃ _ : CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge.PageWoottersDissipativeCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge.UVCoercivityCarrier ℝ, True) ∧
    (∃ _ : Paper2TierAUnifiedCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge.EntropicPropagatorEnvelopeCarrier ℝ, True) ∧
    (∃ _ : CATEPTMain.Integration.EverettBranchSuppressionBridge.EverettBranchPairCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge.ZeroDimQuadraticActionCarrier, True) ∧
    (∃ _ : CATEPTMain.Integration.DBBQuantumPotentialBridge.DBBQuantumPotentialCarrier ℝ, True) ∧
    (∃ _ : CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge.EntropyIncreaseWorldlineCarrier, True) :=
  ⟨ CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge.exists_trivial
  , CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge.exists_trivial
  , CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge.exists_trivial
  , exists_trivial
  , CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge.exists_trivial
  , CATEPTMain.Integration.EverettBranchSuppressionBridge.exists_trivial
  , CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge.exists_trivial
  , CATEPTMain.Integration.DBBQuantumPotentialBridge.exists_trivial
  , CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge.exists_trivial ⟩

end CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge

end
