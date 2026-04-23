import CATEPTMain.Integration.AdSCFT1907Port
import CATEPTMain.NHQM.NHQMCATEPTBridge
import Mathlib
/-!
# AdS/CFT 1907 Phase-2 Bridge (Replica Analytics + EP Continuity)

Phase-2 bridge for integrating additional reasoning from:

  Matthew Headrick, *Lectures on entanglement entropy in field theory and holography*
  arXiv:1907.08126v1 (`~/Downloads/1907.08126v1.pdf`)

Equation anchors used here:

- Eq. (2.40): `S_α = (1/(1-α)) log Tr(ρ^α)`
- Eq. (2.44): `I_α(A:B) = S_α(A) + S_α(B) - S_α(AB)`
- Eq. (2.45): monotonicity/convexity in α (`dS_α/dα ≤ 0`, `d²S_α/dα² ≥ 0`)
- Text after Eq. (2.45): analytic continuation + `α → 1` gives von Neumann entropy
- Eq. (5.52), (5.57): SSA and MMI are already wired in phase-1 bridge modules

This file adds:

1. A phase-2 replica analytic-continuation contract extending
   `ReplicaLimitContract`.
2. A phase-2 exceptional-point continuity contract instantiated directly from
   existing NHQM bridge theorems.
3. A unified witness that combines the 1907 phase-1 witness with both phase-2
   lanes.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.AdSCFT.Headrick1907

open CATEPTMain.NHQM
open CATEPTMain.NHQM.NHQMCATEPTBridge

noncomputable section

-- ── Replica phase-2 contract (Eq. 2.40 + Eq. 2.45 + α→1 reasoning) ─────────

/-- First α-derivative of the Rényi entropy profile for a replica dataset. -/
noncomputable def renyiAlphaSlope (R : ReplicaTraceData) (α : ℝ) : ℝ :=
  deriv (fun a : ℝ => renyiFromReplica R a) α

/-- Second α-derivative (curvature) of the Rényi entropy profile. -/
noncomputable def renyiAlphaCurvature (R : ReplicaTraceData) (α : ℝ) : ℝ :=
  deriv (fun a : ℝ => renyiAlphaSlope R a) α

/-- Eq. (2.41) side condition: one-sided `α → 0⁺` Rényi limit. -/
def renyiZeroOrderLimit (R : ReplicaTraceData) (S0 : ℝ) : Prop :=
  Filter.Tendsto (fun α : ℝ => renyiFromReplica R α)
    (nhdsWithin (0 : ℝ) {x : ℝ | 0 < x}) (nhds S0)

/-- Eq. (2.43) side condition: `α → ∞` Rényi limit. -/
def renyiInfinityOrderLimit (R : ReplicaTraceData) (SInf : ℝ) : Prop :=
  Filter.Tendsto (fun α : ℝ => renyiFromReplica R α) Filter.atTop (nhds SInf)

/-- Phase-2 contract that encodes the analytic continuation route from Eq. (2.40)
to von Neumann entropy (`α → 1`) and Eq. (2.45) shape constraints, with
explicit hooks for Eq. (2.41) and Eq. (2.43). -/
structure ReplicaAnalyticPhase2Contract (R : ReplicaTraceData) (S_vN : ℝ) where
  analyticNearOne : ContinuousAt R.trRhoPow 1
  trRhoPow_continuousOn_ge_one :
    ContinuousOn R.trRhoPow {α : ℝ | 1 ≤ α}
  continuation_from_integer_moments :
    ∀ n : ℕ, 2 ≤ n →
      renyiFromReplica R (n : ℝ) =
      renyiEntropyFormula (n : ℝ) (R.trRhoPow n)
  renyiLimit_to_zeroOrder :
    ∃ S0 : ℝ, renyiZeroOrderLimit R S0
  renyiLimit_to_inftyOrder :
    ∃ SInf : ℝ, renyiInfinityOrderLimit R SInf
  renyiSlope_nonpos :
    ∀ α : ℝ, 1 ≤ α → renyiAlphaSlope R α ≤ 0
  renyiCurvature_nonneg :
    ∀ α : ℝ, 1 ≤ α → 0 ≤ renyiAlphaCurvature R α
  renyiLimit_to_vonNeumann :
    Filter.Tendsto (fun α : ℝ => renyiFromReplica R α)
      (nhdsWithin (1 : ℝ) {x : ℝ | x ≠ 1}) (nhds S_vN)

/-- Any phase-2 replica analytic contract immediately gives the existing
`ReplicaLimitContract` consumed by phase-1 modules. -/
theorem replicaLimitContract_of_phase2
    {R : ReplicaTraceData} {S_vN : ℝ}
    (h : ReplicaAnalyticPhase2Contract R S_vN) :
    ReplicaLimitContract R S_vN :=
  ⟨h.analyticNearOne, h.renyiLimit_to_vonNeumann⟩

/-- Eq. (2.45) monotonicity accessor from a phase-2 contract. -/
theorem renyiSlope_nonpos_of_phase2
    {R : ReplicaTraceData} {S_vN : ℝ}
    (h : ReplicaAnalyticPhase2Contract R S_vN) :
    ∀ α : ℝ, 1 ≤ α → renyiAlphaSlope R α ≤ 0 :=
  h.renyiSlope_nonpos

/-- Eq. (2.45) convexity accessor from a phase-2 contract. -/
theorem renyiCurvature_nonneg_of_phase2
    {R : ReplicaTraceData} {S_vN : ℝ}
    (h : ReplicaAnalyticPhase2Contract R S_vN) :
    ∀ α : ℝ, 1 ≤ α → 0 ≤ renyiAlphaCurvature R α :=
  h.renyiCurvature_nonneg

/-- Eq. (2.41) accessor (`α → 0⁺`) from a phase-2 contract. -/
theorem renyiZeroOrderLimit_exists_of_phase2
    {R : ReplicaTraceData} {S_vN : ℝ}
    (h : ReplicaAnalyticPhase2Contract R S_vN) :
    ∃ S0 : ℝ, renyiZeroOrderLimit R S0 :=
  h.renyiLimit_to_zeroOrder

/-- Eq. (2.43) accessor (`α → ∞`) from a phase-2 contract. -/
theorem renyiInfinityOrderLimit_exists_of_phase2
    {R : ReplicaTraceData} {S_vN : ℝ}
    (h : ReplicaAnalyticPhase2Contract R S_vN) :
    ∃ SInf : ℝ, renyiInfinityOrderLimit R SInf :=
  h.renyiLimit_to_inftyOrder

-- ── Concrete toy phase-2 contract (pure-state proxy) ─────────────────────────

theorem renyiFromReplica_pureReplica_eq_zero (α : ℝ) :
    renyiFromReplica pureReplicaTraceData α = 0 := by
  simp [renyiFromReplica, pureReplicaTraceData, renyiEntropyFormula]

theorem renyiAlphaSlope_pureReplica_eq_zero (α : ℝ) :
    renyiAlphaSlope pureReplicaTraceData α = 0 := by
  have hconst :
      (fun a : ℝ => renyiFromReplica pureReplicaTraceData a) = fun _ : ℝ => (0 : ℝ) := by
    funext a
    simpa using renyiFromReplica_pureReplica_eq_zero a
  simp [renyiAlphaSlope, hconst]

theorem renyiAlphaCurvature_pureReplica_eq_zero (α : ℝ) :
    renyiAlphaCurvature pureReplicaTraceData α = 0 := by
  have hslope :
      (fun a : ℝ => renyiAlphaSlope pureReplicaTraceData a) = fun _ : ℝ => (0 : ℝ) := by
    funext a
    simpa using renyiAlphaSlope_pureReplica_eq_zero a
  simp [renyiAlphaCurvature, hslope]

/-- Concrete phase-2 contract for the pure-state toy replica dataset. -/
def pureReplicaAnalyticPhase2Contract :
    ReplicaAnalyticPhase2Contract pureReplicaTraceData 0 where
  analyticNearOne := pureReplicaTraceData.analyticNearOne
  trRhoPow_continuousOn_ge_one := by
    simpa [pureReplicaTraceData] using
      (continuousOn_const : ContinuousOn (fun _ : ℝ => (1 : ℝ)) {α : ℝ | 1 ≤ α})
  continuation_from_integer_moments := by
    intro n _hn
    simp [renyiFromReplica]
  renyiLimit_to_zeroOrder := by
    refine ⟨0, ?_⟩
    unfold renyiZeroOrderLimit
    convert (tendsto_const_nhds : Filter.Tendsto
      (fun _ : ℝ => (0 : ℝ))
      (nhdsWithin (0 : ℝ) {x : ℝ | 0 < x})
      (nhds (0 : ℝ))) using 1
    funext α
    simpa using renyiFromReplica_pureReplica_eq_zero α
  renyiLimit_to_inftyOrder := by
    refine ⟨0, ?_⟩
    unfold renyiInfinityOrderLimit
    convert (tendsto_const_nhds : Filter.Tendsto
      (fun _ : ℝ => (0 : ℝ))
      Filter.atTop
      (nhds (0 : ℝ))) using 1
    funext α
    simpa using renyiFromReplica_pureReplica_eq_zero α
  renyiSlope_nonpos := by
    intro α _hα
    simp [renyiAlphaSlope_pureReplica_eq_zero α]
  renyiCurvature_nonneg := by
    intro α _hα
    simp [renyiAlphaCurvature_pureReplica_eq_zero α]
  renyiLimit_to_vonNeumann := pureReplicaLimitContract.2

-- ── Exceptional point continuity contract (NHQM lane) ────────────────────────

/-- Phase-2 contract for exceptional-point continuity in the NHQM lane:
EP agreement of `eptClock`, FK weights, and persistent current continuity. -/
structure ExceptionalPointClockContract
    (N : ℕ) (H : NHHamiltonian N) (β μ ħ : ℝ) (hħ : 0 < ħ) where
  eptClock_equal :
    ∀ (m n : Fin N) (φ_EP : ℝ),
      exceptionalPointAt N H φ_EP m n →
      (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock m =
      (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock n
  fkWeight_equal :
    ∀ (m n : Fin N) (φ_EP : ℝ),
      exceptionalPointAt N H φ_EP m n →
      ∀ τ : ℝ,
        nhqmFKWeight N H φ_EP ħ hħ m τ =
        nhqmFKWeight N H φ_EP ħ hħ n τ
  persistentCurrent_continuousAtEP :
    ∀ (m n : Fin N) (φ_EP : ℝ),
      exceptionalPointAt N H φ_EP m n →
      ContinuousAt (nhPersistentCurrentField N H β μ) φ_EP

/-- The NHQM bridge already proves all fields of
`ExceptionalPointClockContract`, so we can package them as a reusable witness. -/
def nhqmExceptionalPointClockContract
    (N : ℕ) (H : NHHamiltonian N) (β μ ħ : ℝ) (hħ : 0 < ħ) :
    ExceptionalPointClockContract N H β μ ħ hħ where
  eptClock_equal := by
    intro m n φ_EP hEP
    exact nhqmCATEPTSlot_eptClock_at_EP N H φ_EP ħ hħ m n hEP
  fkWeight_equal := by
    intro m n φ_EP hEP τ
    exact nhqmFKWeight_at_EP N H φ_EP ħ hħ m n hEP τ
  persistentCurrent_continuousAtEP := by
    intro m n φ_EP hEP
    exact nhPersistentCurrentField_continuousAtEP N H β μ m n φ_EP hEP

-- ── Unified phase-2 witness ───────────────────────────────────────────────────

/-- Unified phase-2 witness:
phase-1 Headrick-1907 integration + replica analytics + EP continuity lane. -/
structure Headrick1907Phase2Witness
    (N : ℕ) (H : NHHamiltonian N) (β μ ħ : ℝ) (hħ : 0 < ħ) where
  phase1Port : Headrick1907PortWitness
  replicaPhase2 :
    ReplicaAnalyticPhase2Contract
      phase1Port.replicaWitness.data
      phase1Port.replicaWitness.S_vN
  epPhase2 : ExceptionalPointClockContract N H β μ ħ hħ

theorem headrick1907Phase2_replica_limit
    {N : ℕ} {H : NHHamiltonian N} {β μ ħ : ℝ} {hħ : 0 < ħ}
    (w : Headrick1907Phase2Witness N H β μ ħ hħ) :
    Filter.Tendsto
      (fun α : ℝ => renyiFromReplica w.phase1Port.replicaWitness.data α)
      (nhdsWithin (1 : ℝ) {x : ℝ | x ≠ 1})
      (nhds w.phase1Port.replicaWitness.S_vN) :=
  w.replicaPhase2.renyiLimit_to_vonNeumann

theorem headrick1907Phase2_zeroOrderLimit_exists
    {N : ℕ} {H : NHHamiltonian N} {β μ ħ : ℝ} {hħ : 0 < ħ}
    (w : Headrick1907Phase2Witness N H β μ ħ hħ) :
    ∃ S0 : ℝ, renyiZeroOrderLimit w.phase1Port.replicaWitness.data S0 :=
  w.replicaPhase2.renyiLimit_to_zeroOrder

theorem headrick1907Phase2_infinityOrderLimit_exists
    {N : ℕ} {H : NHHamiltonian N} {β μ ħ : ℝ} {hħ : 0 < ħ}
    (w : Headrick1907Phase2Witness N H β μ ħ hħ) :
    ∃ SInf : ℝ, renyiInfinityOrderLimit w.phase1Port.replicaWitness.data SInf :=
  w.replicaPhase2.renyiLimit_to_inftyOrder

theorem headrick1907Phase2_current_continuousAtEP
    {N : ℕ} {H : NHHamiltonian N} {β μ ħ : ℝ} {hħ : 0 < ħ}
    (w : Headrick1907Phase2Witness N H β μ ħ hħ)
    (m n : Fin N) (φ_EP : ℝ) (hEP : exceptionalPointAt N H φ_EP m n) :
    ContinuousAt (nhPersistentCurrentField N H β μ) φ_EP :=
  w.epPhase2.persistentCurrent_continuousAtEP m n φ_EP hEP

/-- Constructor that combines:
1) any phase-1 Headrick-1907 port witness,
2) a replica phase-2 analytic contract, and
3) the canonical NHQM EP continuity contract. -/
def mkHeadrick1907Phase2Witness
    (N : ℕ) (H : NHHamiltonian N) (β μ ħ : ℝ) (hħ : 0 < ħ)
    (phase1 : Headrick1907PortWitness)
    (replicaH :
      ReplicaAnalyticPhase2Contract phase1.replicaWitness.data phase1.replicaWitness.S_vN) :
    Headrick1907Phase2Witness N H β μ ħ hħ where
  phase1Port := phase1
  replicaPhase2 := replicaH
  epPhase2 := nhqmExceptionalPointClockContract N H β μ ħ hħ

/-- Canonical phase-2 witness using the toy phase-1 port and pure replica
analytic contract, with EP continuity supplied by NHQM bridge theorems. -/
def phase2PortWitness_pureToy
    (N : ℕ) (H : NHHamiltonian N) (β μ ħ : ℝ) (hħ : 0 < ħ) :
    Headrick1907Phase2Witness N H β μ ħ hħ :=
  mkHeadrick1907Phase2Witness N H β μ ħ hħ
    phase1PortWitness_pureToy pureReplicaAnalyticPhase2Contract

end  -- noncomputable section

end CATEPTMain.Integration.AdSCFT.Headrick1907
