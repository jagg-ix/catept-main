import CATEPTMain.Core.Assumptions
import CATEPTMain.Integration.RelationalInformationSubstrate
import CATEPTMain.Integration.ConstructorInformationSubstrate

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
open CATEPTMain.Integration.ConstructorInformationSubstrate
  (HasNontrivialNotifications)

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

/-- A "Minkowski-type substrate" is one whose `causalPrecedes` is the
    structural shape of a Minkowski-future relation: it is irreflexive
    AND transitive (a strict partial order on notifications), AND the
    substrate's `Notification` carrier is nontrivial (so the property
    is not satisfied vacuously by the empty substrate).

    Earlier drafts shipped this as `:= True`, which any substrate —
    including `Notification := Empty` — discharged for free.  The
    upgraded definition encodes the *structural* shape of Minkowski
    causal future without requiring the substrate to carry coordinates;
    Phase-2 work can refine further to a coordinate-aware predicate. -/
def IsMinkowskiSubstrate (S : RelationalInformationSubstrate) : Prop :=
  HasNontrivialNotifications S ∧
  (∀ n : S.Notification, ¬ S.causalPrecedes n n) ∧
  (∀ n₁ n₂ n₃ : S.Notification,
    S.causalPrecedes n₁ n₂ → S.causalPrecedes n₂ n₃ →
      S.causalPrecedes n₁ n₃)

/-- Tag-discharge for `substrateCausalIsMinkowskiFuture` from a
    structural witness.  No longer `trivial`: requires the consumer to
    supply nontrivial notifications + irreflexivity + transitivity. -/
theorem substrateCausalIsMinkowskiFuture_tag
    (S : RelationalInformationSubstrate) (h : IsMinkowskiSubstrate S) :
    CATEPTAssumption substrateCausalIsMinkowskiFuture
      (IsMinkowskiSubstrate S) :=
  h

-- ─── Substrate-to-quantum (phase) ────────────────────────────────────

/-- Claim that the substrate's `phase` observable on entities matches
    a quantum-mechanical phase (de Broglie / Hamilton-Jacobi).  The
    minimal Phase-1 strengthening: there exist two distinct entities
    whose phases differ.  Earlier drafts shipped this as `:= True`,
    which the trivial substrate satisfied vacuously.  The upgraded
    form requires a phase distinction — the structural seed of any
    quantum-phase identification (a constant phase carries no
    information).  Phase-2 plan: refine to discharge through the QM
    density-matrix adapter and the modular-flow bridge. -/
def SubstratePhaseIsQuantumPhaseClaim
    (S : RelationalInformationSubstrate) : Prop :=
  ∃ e₁ e₂ : S.Entity, S.phase e₁ ≠ S.phase e₂

theorem substratePhaseIsQuantumPhase_tag
    (S : RelationalInformationSubstrate)
    (h : SubstratePhaseIsQuantumPhaseClaim S) :
    CATEPTAssumption substratePhaseIsQuantumPhase
      (SubstratePhaseIsQuantumPhaseClaim S) :=
  h

-- ─── Substrate-to-quantum (notifications/channels) ───────────────────

/-- Claim that the substrate's `Notification` carrier corresponds to
    a quantum measurement event / channel application (Kraus picture).
    The minimal Phase-1 strengthening: the substrate has nontrivial
    notifications AND there exists a notification crossing distinct
    entities (sender ≠ receiver) — the structural seed of any
    Kraus-channel identification (a self-loop notification carries no
    inter-entity quantum channel content).  Earlier drafts shipped
    this as `:= True`.  Phase-2 plan: refine to discharge through the
    quantum-information bridge. -/
def SubstrateNotificationIsQuantumChannelClaim
    (S : RelationalInformationSubstrate) : Prop :=
  HasNontrivialNotifications S ∧
  ∃ n : S.Notification, S.sender n ≠ S.receiver n

theorem substrateNotificationIsQuantumChannel_tag
    (S : RelationalInformationSubstrate)
    (h : SubstrateNotificationIsQuantumChannelClaim S) :
    CATEPTAssumption substrateNotificationIsQuantumChannel
      (SubstrateNotificationIsQuantumChannelClaim S) :=
  h

-- ─── Bundled Target-E discharge ──────────────────────────────────────

/-- **Target-E discharge bundle.** For any substrate `S` with entropic
    clock `E`, entity `e`, and the three structural witnesses for the
    Phase-1 placeholder claims, all four substrate-facing assumption
    ids are trackable from a single conjoined statement:

      - `entropicTimeDefinition` (provable: substrate's `tauEnt_def`)
      - `substrateCausalIsMinkowskiFuture` (from `hMink`)
      - `substratePhaseIsQuantumPhase` (from `hPhase`)
      - `substrateNotificationIsQuantumChannel` (from `hChan`)

    Earlier drafts of this theorem produced the latter three by
    `trivial`, dispatching `True := trivial` placeholders.  The
    upgraded definitions of the placeholder Props now require concrete
    structural witnesses; the bundle no longer falls out for free. -/
theorem substrate_assumption_tags_discharge
    (S : RelationalInformationSubstrate)
    (E : RelationalInformationSubstrate.EntropicClock S)
    (e : S.Entity)
    (hMink : IsMinkowskiSubstrate S)
    (hPhase : SubstratePhaseIsQuantumPhaseClaim S)
    (hChan : SubstrateNotificationIsQuantumChannelClaim S) :
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
   substrateCausalIsMinkowskiFuture_tag S hMink,
   substratePhaseIsQuantumPhase_tag S hPhase,
   substrateNotificationIsQuantumChannel_tag S hChan⟩

end CATEPTMain.Integration.SubstrateAssumptionTags
