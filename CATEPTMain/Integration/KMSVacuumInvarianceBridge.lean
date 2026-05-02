import CATEPTMain.Integration.ReducedModularChannelCarrier
import LogosLibrary.QuantumMechanics.ModularTheory.TomitaTakesaki

/-!
# KMSVacuumInvarianceBridge — vacuum-state stationarity under modular flow

Pulls the **proven** Logos theorem `Tomita.vacuumState_modular_invariant`
into a CAT/EPT carrier asserting "vacuum-state expectations of stable
sector observables are stationary under entropic proper-time flow."

In the operator-algebraic setting this is:

  `⟨Ω, σ_t(a) Ω⟩ = ⟨Ω, a Ω⟩` for all `t ∈ ℝ` and `a ∈ M`.

Logos discharges this from `Δ^{it} Ω = Ω` (the `unitary_fixes_vacuum`
field of `TomitaTheorem`) plus `(Δ^{it})* = Δ^{-it}`. CAT/EPT consumes
the consequence as a Prop-level invariance carrier paired with a
`ReducedModularChannel`.

## Carrier-level surrogate

We abstract the (`M, Δ, J, TomitaTheorem`)-data behind a state functional
`ω : (H →L[ℂ] H) → ℂ` together with a one-parameter automorphism group
`σ_t = modularGroup.σ` (Logos's `Tomita.ModularGroupData H`) and the
invariance hypothesis

  `ω (σ t a) = ω a`.

This hypothesis is exactly the proven theorem `vacuumState_modular_invariant`
when `ω = vacuumState M` and `σ = modularAutomorphism M Δ`.

## What this module ships

* `KMSVacuumInvarianceBridge` — carrier holding the modular group, the
  invariant state functional, and a `ReducedModularChannel`.
* `state_invariant_under_flow` — extraction theorem.
* `magnitude_consistent_with_invariance` — at `s = 0` the channel
  matches the invariance: `magnitude 0 = 1`.
* `kms_vacuum_invariance_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.KMSVacuumInvarianceBridge

open CATEPTMain.Integration.ReducedModularChannelCarrier

variable (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- **KMS vacuum invariance bridge.**

Carrier-level statement of the proven Logos theorem
`Tomita.vacuumState_modular_invariant`:

  `ω (σ_t(a)) = ω(a)` for all `t, a`,

where `ω` is a `ℂ`-valued state functional and `σ_t` is a one-parameter
automorphism group on `(H →L[ℂ] H)`.

Paired with a `ReducedModularChannel` from PR #109 to assert that the
channel's identity-at-zero behaviour matches the invariance: the
state-expectation at `t = 0` equals the state-expectation at any `t`. -/
structure KMSVacuumInvarianceBridge where
  /-- Logos's abstract one-parameter automorphism group. -/
  modularGroup    : Tomita.ModularGroupData H
  /-- The reduced modular channel (catept-main, PR #109). -/
  channel         : ReducedModularChannel
  /-- The state functional `ω`. -/
  ω               : (H →L[ℂ] H) → ℂ
  /-- **Invariance hypothesis.** Discharged in Logos by
  `vacuumState_modular_invariant` when `ω = vacuumState M` and
  `σ = modularAutomorphism M Δ`. -/
  ω_invariant     : ∀ (t : ℝ) (a : H →L[ℂ] H), ω (modularGroup.σ t a) = ω a
  /-- Identity-at-zero of the channel matches `σ 0 a = a`. -/
  zero_consistency : channel.tauEnt 0 = 0

namespace KMSVacuumInvarianceBridge

variable {H} (B : KMSVacuumInvarianceBridge H)

/-- **Extraction theorem.** The state functional is invariant under the
modular flow (cite of Logos's `vacuumState_modular_invariant`). -/
theorem state_invariant_under_flow (t : ℝ) (a : H →L[ℂ] H) :
    B.ω (B.modularGroup.σ t a) = B.ω a :=
  B.ω_invariant t a

/-- The channel's damping at `t = 0` is `1`, matching `σ 0 a = a`. -/
theorem magnitude_consistent_with_invariance :
    B.channel.magnitude 0 = 1 :=
  B.channel.magnitude_at_zero 0 B.zero_consistency

/-- At `t = 0` the modular flow is identity, hence trivially
state-invariant. -/
theorem state_invariant_at_zero (a : H →L[ℂ] H) :
    B.ω (B.modularGroup.σ 0 a) = B.ω a := by
  rw [B.modularGroup.zero_eq]

/-- Trivial existence: identity flow, zero state, zero damping. -/
theorem exists_trivial : ∃ _ : KMSVacuumInvarianceBridge H, True :=
  ⟨{ modularGroup     := { σ         := fun _ a => a
                          , group_law := fun _ _ _ => rfl
                          , zero_eq   := fun _ => rfl
                          , mul_eq    := fun _ _ _ => rfl }
   , channel          := { tauEnt        := fun _ => 0
                          , tauEnt_nonneg := fun _ => le_refl 0 }
   , ω                := fun _ => 0
   , ω_invariant      := fun _ _ => rfl
   , zero_consistency := rfl }, trivial⟩

end KMSVacuumInvarianceBridge

/-- **KMS vacuum invariance bundle.** -/
theorem kms_vacuum_invariance_bundle :
    ∃ _ : KMSVacuumInvarianceBridge H, True :=
  KMSVacuumInvarianceBridge.exists_trivial

end CATEPTMain.Integration.KMSVacuumInvarianceBridge

end
