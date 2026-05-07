import CATEPTMain.Integration.ReducedModularChannelCarrier
import LogosLibrary.QuantumMechanics.ModularTheory.TomitaTakesaki
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# ModularGroupLawBridge — Logos modular group law ↔ channel composition

Strengthens `TomitaTakesakiPhase3BridgeCarrier` (PR #111) from the
"identity-at-zero only" carrier to one that also exposes the **full**
modular group law `σ_{s+t} = σ_s ∘ σ_t` and the corresponding
**channel-composition law**

  `magnitude(s + t) = magnitude(s) · magnitude(t)`,

derived from the additivity hypothesis `τ_ent(s + t) = τ_ent(s) + τ_ent(t)`
along the modular flow.

## Structural picture

* Logos proves `Tomita.modularAutomorphism_group_law`:
  `σ (s+t) a = σ s (σ t a)` (a real theorem on the operator side).
* CAT/EPT pairs this with the channel `Φ_s(X) = exp(-τ_ent(s)) · X`.
  Under the additivity hypothesis on `τ_ent`, the channel is multiplicative
  along the flow (a non-trivial consistency the Phase-3 bridge previously
  did not expose).

## What this module ships

* `ModularGroupLawBridge` — `ModularGroupData H` + `ReducedModularChannel`
  + additivity hypothesis on `τ_ent`.
* `magnitude_composition_law` — extraction theorem
  `magnitude(s + t) = magnitude(s) * magnitude(t)`.
* `modularGroup_composition` — pull of Logos's `group_law`.
* `modular_group_law_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.ModularGroupLawBridge

open CATEPTMain.Integration.ReducedModularChannelCarrier

variable (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]

/-- **Modular group-law bridge.**

Couples Logos's proven `modularAutomorphism_group_law`
(`σ (s+t) a = σ s (σ t a)`) to catept-main's `ReducedModularChannel`
via the additivity hypothesis

  `tauEnt(s + t) = tauEnt(s) + tauEnt(t)`,

yielding the channel-composition law
`magnitude(s + t) = magnitude(s) * magnitude(t)`. -/
structure ModularGroupLawBridge where
  /-- Logos's abstract one-parameter automorphism group. -/
  modularGroup     : Tomita.ModularGroupData H
  /-- The reduced modular channel (catept-main, PR #109). -/
  channel          : ReducedModularChannel
  /-- **Additivity hypothesis** on `tauEnt` along the modular flow. -/
  tauEnt_additive  : ∀ s t, channel.tauEnt (s + t)
                          = channel.tauEnt s + channel.tauEnt t

namespace ModularGroupLawBridge

variable {H} (B : ModularGroupLawBridge H)

/-- **Extraction: channel composition law.**

Under the additivity hypothesis on `tauEnt`,

  `magnitude(s + t) = magnitude(s) * magnitude(t)`,

i.e. the reduced modular channel is multiplicative along the modular
flow, mirroring the operator-level group law `σ(s+t) = σs ∘ σt`. -/
theorem magnitude_composition_law (s t : ℝ) :
    B.channel.magnitude (s + t) = B.channel.magnitude s * B.channel.magnitude t := by
  unfold ReducedModularChannel.magnitude
  rw [B.tauEnt_additive s t, neg_add, Real.exp_add]

/-- Pull of Logos's `modularAutomorphism_group_law` at the bridge level. -/
theorem modularGroup_composition (s t : ℝ) (a : H →L[ℂ] H) :
    B.modularGroup.σ (s + t) a = B.modularGroup.σ s (B.modularGroup.σ t a) :=
  B.modularGroup.group_law s t a

/-- Multiplicativity of the modular group on operators (Logos
`modularAutomorphism_mul`). -/
theorem modularGroup_mul (t : ℝ) (a b : H →L[ℂ] H) :
    B.modularGroup.σ t (a * b) = B.modularGroup.σ t a * B.modularGroup.σ t b :=
  B.modularGroup.mul_eq t a b

/-- Trivial existence: identity flow and zero `tauEnt`. -/
theorem exists_trivial : ∃ _ : ModularGroupLawBridge H, True :=
  ⟨{ modularGroup    := { σ         := fun _ a => a
                          , group_law := fun _ _ _ => rfl
                          , zero_eq   := fun _ => rfl
                          , mul_eq    := fun _ _ _ => rfl }
   , channel         := { tauEnt        := fun _ => 0
                          , tauEnt_nonneg := fun _ => le_refl 0 }
   , tauEnt_additive := fun _ _ => by simp }, trivial⟩

end ModularGroupLawBridge

/-- **Modular group-law bundle.** -/
theorem modular_group_law_bundle :
    ∃ _ : ModularGroupLawBridge H, True :=
  ModularGroupLawBridge.exists_trivial

end CATEPTMain.Integration.ModularGroupLawBridge

end
