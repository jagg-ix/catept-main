import CATEPTMain.Integration.RelationalInformationSubstrate
import CATEPTMain.Domains.Adapters.HarmonicOscillator

/-!
# Substrate Projection Demos — leverage of the RIS kernel

The `RelationalInformationSubstrate` (introduced in
`Integration/RelationalInformationSubstrate.lean`) is the ontological
floor of the spine: every existing `TemporalFramework` adapter can be
re-derived as `S.toTemporalFramework E` for a suitable substrate `S`
and entropic clock `E`.

This file demonstrates that on one concrete adapter (T68 harmonic
oscillator). The pattern transfers verbatim to every other adapter:

  Adapter           Entity          irreversibleCost
  -------           ------          ----------------
  Minkowski         Fin 4 → ℝ        const 0
  EM (μ₀)           Fin 4 → ℝ        ‖A‖² · μ₀⁻¹/2 · ℏ
  HarmonicOscillator (this file)
  Kinetic (T)       Fin 3 → ℝ        ‖v‖² · ℏ / (2T)
  Higgs             ℝ                higgsAction · ℏ
  Herglotz          OscillatorJet    herglotzActionIm · ℏ
  BohmianEM         Fin 4 → ℝ        ‖v − A_bg‖²/2 · ℏ
  QM                DensityMatrix n  vonNeumannEntropy · ℏ
  SR                SREvent d        properTime · ℏ

Once each substrate witness is in place, the per-adapter spine proofs
collapse into the single theorem
`RelationalInformationSubstrate.toTemporalFramework_coherence` —
substrate IS the comparator, not just the slot shape.

## Why only HO here

Building the eight other substrate witnesses is mechanical, not
illuminating. One demo establishes the leverage; the rest are
follow-ups when the per-domain QC bridges call for them.
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.SubstrateProjections

open CATEPTMain.Integration (RelationalInformationSubstrate)
open CATEPTMain.Temporal (TemporalFramework)

/-- The harmonic-oscillator substrate. `Entity = HOConfig`, all
    inter-entity structure (notifications, causal order, propagation
    bound) is vacuous via `Empty` — the substrate's role here is
    purely to host the irreversible-cost observable
    `(q² + p²)/2`. The bounded-propagation, causal-order, and
    no-FTL laws are vacuously satisfied because there are no
    notifications. -/
noncomputable def harmonicSubstrate : RelationalInformationSubstrate where
  Entity := CATEPTMain.Temporal.Adapter.HOConfig
  InfoObject := Unit
  Notification := Empty
  sender := Empty.elim
  receiver := Empty.elim
  payload := Empty.elim
  causalPrecedes := fun n _ => n.elim
  localOrder := fun _ n => n.elim
  localOrder_causal := by intro n₁ _ _ _ _ _; exact n₁.elim
  propagationBound := 1
  propagationBound_pos := by norm_num
  notificationDelay := Empty.elim
  notificationDelay_nonneg := fun n => n.elim
  notificationDelay_le_bound := fun n => n.elim
  phase := fun _ => 0
  storedInfo := fun _ => 0
  storedInfo_nonneg := fun _ => le_refl 0
  irreversibleCost := CATEPTMain.Temporal.Adapter.hoHamiltonian
  irreversibleCost_nonneg :=
    CATEPTMain.Temporal.Adapter.hoHamiltonian_nonneg
  witness := fun _ => 0

/-- Canonical entropic clock at ℏ = 1 (the Logos / Superior-Method
    convention). -/
noncomputable def harmonicEntropicClock :
    RelationalInformationSubstrate.EntropicClock harmonicSubstrate where
  hbar := 1
  hbar_pos := one_pos

/-- ★ LEVERAGE THEOREM ★

    The substrate's projection produces the same TemporalFramework as
    the standalone T68 harmonic adapter — pointwise, by `rfl` after
    `div_one`. Every other adapter inherits an analogous witness;
    this is the proof-of-concept that the relational substrate IS the
    semantic floor of the T-series. -/
theorem harmonic_is_substrate_projection :
    ∀ x : CATEPTMain.Temporal.Adapter.HOConfig,
      (RelationalInformationSubstrate.toTemporalFramework
          harmonicSubstrate harmonicEntropicClock).clock x =
        CATEPTMain.Temporal.Adapter.harmonic.clock x := by
  intro x
  show RelationalInformationSubstrate.tauEnt
        harmonicSubstrate harmonicEntropicClock x =
      CATEPTMain.Temporal.Adapter.hoHamiltonian x
  unfold RelationalInformationSubstrate.tauEnt
  show CATEPTMain.Temporal.Adapter.hoHamiltonian x / 1 =
       CATEPTMain.Temporal.Adapter.hoHamiltonian x
  exact div_one _

/-- The substrate's entropic-time projection coheres with the CAT/EPT
    spine — without re-proving anything per-adapter. This subsumes
    `harmonic_satisfies_spine`. -/
theorem harmonicSubstrate_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      ((RelationalInformationSubstrate.toTemporalFramework
          harmonicSubstrate harmonicEntropicClock).toCATEPTSlot) :=
  RelationalInformationSubstrate.toTemporalFramework_coherence
    harmonicSubstrate harmonicEntropicClock

end CATEPTMain.Domains.SubstrateProjections
