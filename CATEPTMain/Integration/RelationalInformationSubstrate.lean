import CATEPTMain.Domains.TemporalFramework

/-!
# RelationalInformationSubstrate

An abstract kernel for the repo's process-first reading of CAT/EPT.

This module is intentionally small. It provides:

- a relational substrate with entities, information objects, and notifications,
- a local causal-order law,
- a bounded-propagation law,
- phase / storage / irreversible-cost observables,
- a canonical projection into `TemporalFramework`.

The point is to give future bridges one common semantic layer without forcing an
early commitment to a concrete physics implementation.
-/

set_option autoImplicit false

open CATEPTMain.Temporal

namespace CATEPTMain.Integration

/-- Abstract relational-information substrate.

The fields are chosen to match the repo's current architectural seams:

- `localOrder_causal` is the local temporal-consistency law,
- `notificationDelay_le_bound` is the bounded-propagation law,
- `phase` supports later coherent/Bell-facing adapters,
- `irreversibleCost` is the raw source for entropic-time projection. -/
structure RelationalInformationSubstrate where
  /-- Carrier of local information-processing entities. -/
  Entity : Type
  /-- Carrier of persistent information objects. -/
  InfoObject : Type
  /-- Carrier of local notifications or access events. -/
  Notification : Type
  /-- Sender of a notification. -/
  sender : Notification → Entity
  /-- Receiver of a notification. -/
  receiver : Notification → Entity
  /-- Information object referenced by a notification. -/
  payload : Notification → InfoObject
  /-- Causal precedence relation between notifications. -/
  causalPrecedes : Notification → Notification → Prop
  /-- Local ordinal clock attached to an entity's received notifications. -/
  localOrder : Entity → Notification → Nat
  /-- Local temporal-consistency law: causally ordered notifications addressed
      to the same entity are strictly increasing in the entity's local order. -/
  localOrder_causal :
    ∀ {n₁ n₂ e},
      receiver n₁ = e → receiver n₂ = e →
      causalPrecedes n₁ n₂ → localOrder e n₁ < localOrder e n₂
  /-- Global propagation bound for notifications. -/
  propagationBound : ℝ
  /-- The propagation bound is positive. -/
  propagationBound_pos : 0 < propagationBound
  /-- Delay assigned to each notification. -/
  notificationDelay : Notification → ℝ
  /-- Delays are nonnegative. -/
  notificationDelay_nonneg : ∀ n, 0 ≤ notificationDelay n
  /-- Delays are bounded by the propagation constant. -/
  notificationDelay_le_bound : ∀ n, notificationDelay n ≤ propagationBound
  /-- Coherent phase observable carried by each entity. -/
  phase : Entity → ℝ
  /-- Stored information observable carried by each entity. -/
  storedInfo : Entity → ℝ
  /-- Stored information is nonnegative. -/
  storedInfo_nonneg : ∀ e, 0 ≤ storedInfo e
  /-- Irreversible-cost observable used for the CAT/EPT clock projection. -/
  irreversibleCost : Entity → ℝ
  /-- Irreversible cost is nonnegative. -/
  irreversibleCost_nonneg : ∀ e, 0 ≤ irreversibleCost e
  /-- Witness that the substrate is inhabited. -/
  witness : Entity

namespace RelationalInformationSubstrate

/-- The local temporal-consistency law extracted as a named Prop. -/
def TemporalConsistent (S : RelationalInformationSubstrate) : Prop :=
  ∀ {n₁ n₂ e},
    S.receiver n₁ = e → S.receiver n₂ = e →
    S.causalPrecedes n₁ n₂ → S.localOrder e n₁ < S.localOrder e n₂

/-- Every substrate carries its temporal-consistency law by construction. -/
theorem temporalConsistent (S : RelationalInformationSubstrate) :
    TemporalConsistent S := by
  intro n₁ n₂ e h₁ h₂ hcausal
  exact S.localOrder_causal h₁ h₂ hcausal

/-- The no-FTL notification law extracted as a named Prop. -/
def NoFTLNotifications (S : RelationalInformationSubstrate) : Prop :=
  ∀ n, S.notificationDelay n ≤ S.propagationBound

/-- Every substrate satisfies the bounded-propagation law by construction. -/
theorem noFTLNotifications (S : RelationalInformationSubstrate) :
    NoFTLNotifications S :=
  S.notificationDelay_le_bound

/-- Minimal local reference frame attached to a substrate entity. -/
structure ReferenceFrame (S : RelationalInformationSubstrate) where
  /-- Entity whose local perspective this frame records. -/
  owner : S.Entity
  /-- Local ordinal clock for received notifications. -/
  order : S.Notification → Nat
  /-- The frame's local order respects substrate causality. -/
  order_causal :
    ∀ {n₁ n₂},
      S.receiver n₁ = owner → S.receiver n₂ = owner →
      S.causalPrecedes n₁ n₂ → order n₁ < order n₂
  /-- Local phase coordinate. -/
  phaseCoordinate : ℝ
  /-- Local stored-information coordinate. -/
  storedInfo : ℝ
  /-- Stored information is nonnegative. -/
  storedInfo_nonneg : 0 ≤ storedInfo

/-- Canonical frame induced by the substrate data of a single entity. -/
def canonicalFrame (S : RelationalInformationSubstrate) (e : S.Entity) :
    ReferenceFrame S where
  owner := e
  order := S.localOrder e
  order_causal := by
    intro n₁ n₂ h₁ h₂ hcausal
    exact S.localOrder_causal h₁ h₂ hcausal
  phaseCoordinate := S.phase e
  storedInfo := S.storedInfo e
  storedInfo_nonneg := S.storedInfo_nonneg e

/-- Positive scaling constant used to project irreversible cost to entropic
time. This is intentionally small: the substrate supplies the cost, while the
clock structure supplies the scale. -/
structure EntropicClock (S : RelationalInformationSubstrate) where
  hbar : ℝ
  hbar_pos : 0 < hbar

/-- Canonical CAT/EPT entropic-time projection from irreversible cost. -/
noncomputable def tauEnt (S : RelationalInformationSubstrate) (E : EntropicClock S) :
    S.Entity → ℝ :=
  fun e => S.irreversibleCost e / E.hbar

/-- Definitional form of the entropic-time projection. -/
theorem tauEnt_def (S : RelationalInformationSubstrate) (E : EntropicClock S)
    (e : S.Entity) :
    tauEnt S E e = S.irreversibleCost e / E.hbar :=
  rfl

/-- The entropic-time projection is nonnegative. -/
theorem tauEnt_nonneg (S : RelationalInformationSubstrate)
    (E : EntropicClock S) (e : S.Entity) :
    0 ≤ tauEnt S E e := by
  exact div_nonneg (S.irreversibleCost_nonneg e) (le_of_lt E.hbar_pos)

/-- Project the substrate into the CAT/EPT kernel contract. -/
noncomputable def toTemporalFramework (S : RelationalInformationSubstrate)
    (E : EntropicClock S) : TemporalFramework where
  Config := S.Entity
  clock := tauEnt S E
  clock_nonneg := tauEnt_nonneg S E
  witness := S.witness

/-- The substrate's entropic projection satisfies the universal CAT/EPT spine. -/
theorem toTemporalFramework_coherence (S : RelationalInformationSubstrate)
    (E : EntropicClock S) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (toTemporalFramework S E).toCATEPTSlot :=
  (toTemporalFramework S E).coherence_spine

/-- Live version of the entropic clock: at least one entity has strictly
positive irreversible cost. -/
structure LiveEntropicClock (S : RelationalInformationSubstrate)
    extends EntropicClock S where
  live_entity : ∃ e : S.Entity, 0 < S.irreversibleCost e

/-- A live entropic clock yields a live CAT/EPT framework. -/
noncomputable def toLiveTemporalFramework (S : RelationalInformationSubstrate)
    (E : LiveEntropicClock S) : LiveTemporalFramework where
  toTemporalFramework := toTemporalFramework S E.toEntropicClock
  live_witness := by
    rcases E.live_entity with ⟨e, he⟩
    refine ⟨e, ?_⟩
    show 0 < tauEnt S E.toEntropicClock e
    exact div_pos he E.hbar_pos

/-- Live entropic projections also satisfy the kernel CAT/EPT spine. -/
theorem toLiveTemporalFramework_coherence (S : RelationalInformationSubstrate)
    (E : LiveEntropicClock S) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (toLiveTemporalFramework S E).toTemporalFramework.toCATEPTSlot :=
  (toLiveTemporalFramework S E).coherence_spine

end RelationalInformationSubstrate

end CATEPTMain.Integration
