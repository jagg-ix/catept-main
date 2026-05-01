import CATEPTMain.Integration.RelationalInformationSubstrate
import CATEPTMain.Integration.SubstrateAssumptionTags
import CATEPTMain.Integration.ConstructorInformationSubstrate

/-!
# Concrete Substrate Example (T103 partial)

Partial close of `catept_substrate_placeholder_refinement_20260427`
(T103: refine T86 substrate placeholder Props with concrete witness
data).

This module provides a **concrete non-trivial** `RelationalInformation
Substrate` instance — `aliceBobSubstrate` — that:

  1. has a non-empty `Notification` carrier (contrast with the
     existing `harmonicSubstrate` and analogues in
     `SubstrateProjections.lean` which use `Notification := Empty`);
  2. exhibits cross-entity notifications (sender ≠ receiver);
  3. assigns distinct phases to its two entities;
  4. has a trivially irreflexive + trivially transitive
     `causalPrecedes` relation.

The substrate's purpose is to **witness** the three structural Props
from `SubstrateAssumptionTags` (PR #27 upgrade):
  - `IsMinkowskiSubstrate` (irreflexive + transitive causalPrecedes
    + nontrivial notifications)
  - `SubstratePhaseIsQuantumPhaseClaim` (distinct phases)
  - `SubstrateNotificationIsQuantumChannelClaim` (cross-entity
    notification + nontrivial notifications)

Each of the three is **proved** for `aliceBobSubstrate`, demonstrating
the Props are not vacuous in a concrete instance.

## Honest scope

* This is a **structural-level** witness, not a physical model.  The
  point is to confirm the upgraded substrate Props admit a concrete
  non-trivial example.
* The substrate has only two entities (`Bool`) and one notification
  shape; real physical substrates are vastly more complex.
* The instance does not contribute to any computational claim;
  consumers should not depend on it for measurement / quantum
  channel claims.

## What is honestly proven

* `aliceBobSubstrate` (def): the concrete two-entity substrate.
* `aliceBobSubstrate.hasNontrivialNotifications` — anti-vacuity
  guard satisfied.
* `aliceBobSubstrate.isMinkowskiSubstrate` — Minkowski-style
  causal-future structural claim satisfied.
* `aliceBobSubstrate.phaseIsQuantumPhase` — distinct-phase witness
  claim satisfied.
* `aliceBobSubstrate.notificationIsQuantumChannel` — non-self-loop
  notification claim satisfied.
* `aliceBobSubstrate.satisfies_T103_witness_bundle` — bundles all
  four into a single named theorem.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ConcreteSubstrateExample

open CATEPTMain.Integration
open CATEPTMain.Integration.SubstrateAssumptionTags
open CATEPTMain.Integration.ConstructorInformationSubstrate (HasNontrivialNotifications)

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- The concrete substrate
-- ═══════════════════════════════════════════════════════════════════════

/-- **Concrete two-entity Alice/Bob substrate.**

  - `Entity := Bool` — `false` is "Alice", `true` is "Bob".
  - `InfoObject := ℕ` — info objects are natural numbers.
  - `Notification := Bool` — `false` is "Alice → Bob", `true` is
    "Bob → Alice".  Non-empty: this is the anti-vacuity-guard payload.
  - `sender / receiver` cross-entity: each notification has distinct
    sender and receiver, satisfying the
    `SubstrateNotificationIsQuantumChannelClaim` shape.
  - `phase` distinct on the two entities (`0` for Alice, `1` for Bob),
    satisfying `SubstratePhaseIsQuantumPhaseClaim`.
  - `causalPrecedes ≡ False`, which is trivially irreflexive and
    transitive — so `IsMinkowskiSubstrate` holds vacuously on the
    causal-side, with the anti-vacuity guard `Nonempty Notification`
    discharged by Bool's inhabitedness. -/
def aliceBobSubstrate : RelationalInformationSubstrate where
  Entity := Bool
  InfoObject := ℕ
  Notification := Bool
  sender := fun n => match n with | false => false | true => true
  receiver := fun n => match n with | false => true | true => false
  payload := fun _ => 0
  causalPrecedes := fun _ _ => False
  localOrder := fun _ _ => 0
  localOrder_causal := by intros _ _ _ _ _ h; exact absurd h id
  propagationBound := 1
  propagationBound_pos := by norm_num
  notificationDelay := fun _ => 0
  notificationDelay_nonneg := fun _ => le_refl 0
  notificationDelay_le_bound := fun _ => by norm_num
  phase := fun e => if e then 1 else 0
  storedInfo := fun _ => 0
  storedInfo_nonneg := fun _ => le_refl 0
  irreversibleCost := fun _ => 0
  irreversibleCost_nonneg := fun _ => le_refl 0
  witness := false  -- Alice as the canonical witness entity

-- ═══════════════════════════════════════════════════════════════════════
-- The substrate satisfies the three structural Props
-- ═══════════════════════════════════════════════════════════════════════

/-- **Anti-vacuity guard satisfied.**  `aliceBobSubstrate` has
non-empty `Notification`. -/
theorem aliceBobSubstrate_hasNontrivialNotifications :
    HasNontrivialNotifications aliceBobSubstrate := ⟨false⟩

/-- **`IsMinkowskiSubstrate` satisfied.**  The Alice/Bob substrate is
"Minkowski-style" in the structural sense: irreflexive + transitive
`causalPrecedes` (vacuously, since `causalPrecedes ≡ False`), plus
nontrivial notifications. -/
theorem aliceBobSubstrate_isMinkowskiSubstrate :
    IsMinkowskiSubstrate aliceBobSubstrate := by
  refine ⟨aliceBobSubstrate_hasNontrivialNotifications, ?_, ?_⟩
  · intro _ h; exact absurd h id
  · intro _ _ _ h; exact absurd h id

/-- **`SubstratePhaseIsQuantumPhaseClaim` satisfied.**  Alice's phase
(`0`) and Bob's phase (`1`) are distinct. -/
theorem aliceBobSubstrate_phaseIsQuantumPhase :
    SubstratePhaseIsQuantumPhaseClaim aliceBobSubstrate := by
  refine ⟨false, true, ?_⟩
  -- aliceBobSubstrate.phase false = 0, .phase true = 1; 0 ≠ 1
  show (if false then (1 : ℝ) else 0) ≠ (if true then (1 : ℝ) else 0)
  norm_num

/-- **`SubstrateNotificationIsQuantumChannelClaim` satisfied.**  The
Alice→Bob notification (`false`) has sender ≠ receiver. -/
theorem aliceBobSubstrate_notificationIsQuantumChannel :
    SubstrateNotificationIsQuantumChannelClaim aliceBobSubstrate := by
  refine ⟨aliceBobSubstrate_hasNontrivialNotifications, false, ?_⟩
  -- aliceBobSubstrate.sender false = false, .receiver false = true
  show (false : Bool) ≠ true
  decide

-- ═══════════════════════════════════════════════════════════════════════
-- Bundle theorem (T103 witness)
-- ═══════════════════════════════════════════════════════════════════════

/-- ★ **T103 witness bundle.** ★

`aliceBobSubstrate` satisfies all three structural Props from the
upgraded `SubstrateAssumptionTags` (PR #27):

  1. `HasNontrivialNotifications` (anti-vacuity guard)
  2. `IsMinkowskiSubstrate` (Minkowski-style causal future)
  3. `SubstratePhaseIsQuantumPhaseClaim` (distinct phases)
  4. `SubstrateNotificationIsQuantumChannelClaim` (cross-entity
     notification)

This demonstrates the upgraded Props are non-vacuous in a concrete
substrate instance — the trivial `Notification := Empty` projections
fail all four. -/
theorem aliceBobSubstrate_satisfies_T103_witness_bundle :
    HasNontrivialNotifications aliceBobSubstrate ∧
      IsMinkowskiSubstrate aliceBobSubstrate ∧
      SubstratePhaseIsQuantumPhaseClaim aliceBobSubstrate ∧
      SubstrateNotificationIsQuantumChannelClaim aliceBobSubstrate :=
  ⟨aliceBobSubstrate_hasNontrivialNotifications,
   aliceBobSubstrate_isMinkowskiSubstrate,
   aliceBobSubstrate_phaseIsQuantumPhase,
   aliceBobSubstrate_notificationIsQuantumChannel⟩

end

end CATEPTMain.Integration.ConcreteSubstrateExample
