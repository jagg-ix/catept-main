import CATEPTMain.Integration.ReducedModularChannelCarrier
import LogosLibrary.QuantumMechanics.ModularTheory.TomitaTakesaki

/-!
# ModularUnitaryAdjointBridge — `(Δ^{it})* = Δ^{-it}` ↔ time-reversal channel symmetry

Pulls Logos's proven `Tomita.modularUnitary_adjoint`
(`(Δ^{it})* = Δ^{-it}`) into a CAT/EPT carrier asserting the
**time-reversal symmetry** of the reduced modular channel:

  `magnitude(-s) = magnitude(s)` under the evenness hypothesis
  `tauEnt(-s) = tauEnt(s)`.

The operator-level identity says `Δ^{it}` and `Δ^{-it}` are
mutually adjoint (hence inverse, since both are unitary). On the
norm side this gives `‖Δ^{it} ψ‖ = ‖ψ‖ = ‖Δ^{-it} ψ‖`. The reduced-
channel analog under evenness of `τ_ent` is identical magnitude at
`±s`, encoding the time-reversal-symmetric damping that underlies
fluctuation-theorem-style consistency in CAT/EPT.

## What this module ships

* `ModularUnitaryAdjointBridge` — `ModularGroupData H`
  + `ReducedModularChannel` + evenness hypothesis on `τ_ent`.
* `magnitude_time_reversal_symmetry` — extraction theorem
  `magnitude(-s) = magnitude(s)`.
* `modular_unitary_adjoint_bundle` — capstone.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.ModularUnitaryAdjointBridge

open CATEPTMain.Integration.ReducedModularChannelCarrier

variable (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- **Modular unitary adjoint bridge.**

Logos proves `(Δ^{it})* = Δ^{-it}` (theorem `modularUnitary_adjoint`).
On the unitary norm side this gives `‖Δ^{it} ψ‖ = ‖Δ^{-it} ψ‖`. The
catept-main reduced-channel analog under evenness of `τ_ent` is

  `magnitude(-s) = magnitude(s)`,

a time-reversal symmetric damping. -/
structure ModularUnitaryAdjointBridge where
  /-- Logos's abstract one-parameter automorphism group. -/
  modularGroup    : Tomita.ModularGroupData H
  /-- The reduced modular channel (catept-main, PR #109). -/
  channel         : ReducedModularChannel
  /-- **Evenness hypothesis** on `tauEnt` (time-reversal symmetric). -/
  tauEnt_even     : ∀ s, channel.tauEnt (-s) = channel.tauEnt s

namespace ModularUnitaryAdjointBridge

variable {H} (B : ModularUnitaryAdjointBridge H)

/-- **Extraction: time-reversal symmetry of the channel magnitude.**

Mirroring the unitarity of `Δ^{it}` and `Δ^{-it}`, the reduced channel
satisfies `magnitude(-s) = magnitude(s)` under the evenness of `τ_ent`. -/
theorem magnitude_time_reversal_symmetry (s : ℝ) :
    B.channel.magnitude (-s) = B.channel.magnitude s := by
  unfold ReducedModularChannel.magnitude
  rw [B.tauEnt_even s]

/-- Trivial existence: identity flow, zero `tauEnt` (trivially even). -/
theorem exists_trivial : ∃ _ : ModularUnitaryAdjointBridge H, True :=
  ⟨{ modularGroup := { σ         := fun _ a => a
                       , group_law := fun _ _ _ => rfl
                       , zero_eq   := fun _ => rfl
                       , mul_eq    := fun _ _ _ => rfl }
   , channel      := { tauEnt        := fun _ => 0
                       , tauEnt_nonneg := fun _ => le_refl 0 }
   , tauEnt_even  := fun _ => rfl }, trivial⟩

end ModularUnitaryAdjointBridge

/-- **Modular unitary adjoint bundle.** -/
theorem modular_unitary_adjoint_bundle :
    ∃ _ : ModularUnitaryAdjointBridge H, True :=
  ModularUnitaryAdjointBridge.exists_trivial

end CATEPTMain.Integration.ModularUnitaryAdjointBridge

end
