import CATEPTMain.Core.Assumptions
import CATEPTMain.Integration.RelationalInformationSubstrate

/-!
# Substrate-Facing Assumption Tags — Architecture-Note Target E

The relational-information substrate (T78) describes universe structure
in process-first / information-first terms. Mapping its primitives onto
spacetime / quantum / entropic-time content requires *cross-layer
identifications* — claims that cannot yet be derived but must be
trackable from source for audit purposes.

Per the architecture note's Target E:
  "Add them only when a cross-layer claim cannot yet be proved but
  needs to be tracked. Expected categories:
    - substrate-to-quantum identification,
    - substrate-to-causal-geometry identification,
    - substrate-to-entropic-time identification."

This file:

1. **Retrofits** the existing `entropicTimeDefinition` id (which was
   dead per the registry audit) by wrapping the substrate's
   `tauEnt_def` theorem — the substrate-side discharge of
   "τ_ent = S_I / ℏ".

2. **Adds** three NEW substrate-facing tracking tags:
     - `substrateCausalIsMinkowskiFuture` (substrate ↔ causal-geometry)
     - `substratePhaseIsQuantumPhase` (substrate ↔ quantum phase)
     - `substrateNotificationIsQuantumChannel` (substrate ↔ quantum channel)

The three new tags are wrapped over named Phase-1 placeholder Props
(`IsMinkowskiSubstrate`, `SubstratePhaseIsQuantumPhaseClaim`,
`SubstrateNotificationIsQuantumChannelClaim`) currently realised as
`True`. When concrete bridge files mature, refining the placeholder
Props to non-trivial statements is mechanical — the AssumptionId
wrap stays in place, the proof obligation gets stronger.

This is the **minimal** Target E delivery. We add three ids only
because each represents a genuinely missing cross-layer derivation.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SubstrateAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open CATEPTMain.Integration (RelationalInformationSubstrate)

-- ─── Retrofit: substrate's tauEnt_def discharges entropicTimeDefinition ──

/-- The substrate's `tauEnt = irreversibleCost / ℏ` is the substrate-
    side realisation of the CATEPT identity `τ_ent = S_I / ℏ`. Wrapped
    with `entropicTimeDefinition` to retire the (previously dead) id. -/
theorem substrate_tauEnt_def
    (S : RelationalInformationSubstrate)
    (E : RelationalInformationSubstrate.EntropicClock S)
    (e : S.Entity) :
    CATEPTAssumption entropicTimeDefinition
      (RelationalInformationSubstrate.tauEnt S E e =
        S.irreversibleCost e / E.hbar) :=
  RelationalInformationSubstrate.tauEnt_def S E e

-- ─── Substrate-to-causal-geometry ────────────────────────────────────

/-- A "Minkowski-type substrate" is one whose `causalPrecedes` aligns
    with the Minkowski causal future relation. Phase-1: placeholder
    `True`; Phase-2: refine to a concrete Minkowski-future predicate
    on the substrate's `Notification` carrier. -/
def IsMinkowskiSubstrate (_S : RelationalInformationSubstrate) : Prop := True

theorem substrateCausalIsMinkowskiFuture_tag
    (S : RelationalInformationSubstrate) :
    CATEPTAssumption substrateCausalIsMinkowskiFuture
      (IsMinkowskiSubstrate S) :=
  trivial

-- ─── Substrate-to-quantum (phase) ────────────────────────────────────

/-- Claim that the substrate's `phase` observable on entities matches
    a quantum-mechanical phase (de Broglie / Hamilton-Jacobi). Phase-1
    placeholder; Phase-2 plan: discharge through the QM density-matrix
    adapter and the modular-flow bridge. -/
def SubstratePhaseIsQuantumPhaseClaim
    (_S : RelationalInformationSubstrate) : Prop := True

theorem substratePhaseIsQuantumPhase_tag
    (S : RelationalInformationSubstrate) :
    CATEPTAssumption substratePhaseIsQuantumPhase
      (SubstratePhaseIsQuantumPhaseClaim S) :=
  trivial

-- ─── Substrate-to-quantum (notifications/channels) ───────────────────

/-- Claim that the substrate's `Notification` carrier corresponds to
    a quantum measurement event / channel application (Kraus picture).
    Phase-1 placeholder; Phase-2 plan: discharge through the
    quantum-information bridge. -/
def SubstrateNotificationIsQuantumChannelClaim
    (_S : RelationalInformationSubstrate) : Prop := True

theorem substrateNotificationIsQuantumChannel_tag
    (S : RelationalInformationSubstrate) :
    CATEPTAssumption substrateNotificationIsQuantumChannel
      (SubstrateNotificationIsQuantumChannelClaim S) :=
  trivial

-- ─── Bundled Target-E discharge ──────────────────────────────────────

/-- **Target-E discharge bundle.** For any substrate `S` with entropic
    clock `E` and entity `e`, all four substrate-facing assumption ids
    are trackable from a single conjoined statement:

      - `entropicTimeDefinition` (provable: substrate's `tauEnt_def`)
      - `substrateCausalIsMinkowskiFuture` (Phase-1 placeholder)
      - `substratePhaseIsQuantumPhase` (Phase-1 placeholder)
      - `substrateNotificationIsQuantumChannel` (Phase-1 placeholder)

    The first is fully discharged; the latter three are tracking-only
    until concrete bridges land. -/
theorem substrate_assumption_tags_discharge
    (S : RelationalInformationSubstrate)
    (E : RelationalInformationSubstrate.EntropicClock S)
    (e : S.Entity) :
    CATEPTAssumption entropicTimeDefinition
      (RelationalInformationSubstrate.tauEnt S E e =
        S.irreversibleCost e / E.hbar)
    ∧ CATEPTAssumption substrateCausalIsMinkowskiFuture
        (IsMinkowskiSubstrate S)
    ∧ CATEPTAssumption substratePhaseIsQuantumPhase
        (SubstratePhaseIsQuantumPhaseClaim S)
    ∧ CATEPTAssumption substrateNotificationIsQuantumChannel
        (SubstrateNotificationIsQuantumChannelClaim S) :=
  ⟨substrate_tauEnt_def S E e,
   substrateCausalIsMinkowskiFuture_tag S,
   substratePhaseIsQuantumPhase_tag S,
   substrateNotificationIsQuantumChannel_tag S⟩

end CATEPTMain.Integration.SubstrateAssumptionTags
