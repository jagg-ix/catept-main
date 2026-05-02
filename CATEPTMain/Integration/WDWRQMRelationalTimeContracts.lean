import Mathlib.Order.Basic

/-!
# WDWRQMRelationalTimeContracts — Event/Poset Core for Relational Time

This file is a **contract landing pad** for the “relational time” segment in:

`(private intake doc)`

Relevant artifact section:

- `# Geodesic Scheduling as Relational Evolution: Beyond External Time` (around L7312)

The reusable core is independent of any “virtual universe” framing:

- there is a set of **events** `E`
- there is a set of **actors/processes** `A`
- each actor induces a local preorder on its events (“participated before”)
- global causal/relational order is induced from these local relations

Honest scope:

- We only define the abstract structures + minimal closure lemmas.
- We do **not** attempt to derive these orders from physics, NS, or modular flow.
- Downstream files can interpret this model as:
  - vector-clock style partial order,
  - causal set order,
  - “synchronization event” order in a process network.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.WDWRQMRelationalTimeContracts

-- ============================================================================
-- 1. Per-actor event order (preorder)
-- ============================================================================

/-!
We treat each actor as providing its own “local time” in the weakest form:
a preorder `≼ₐ` on events.
-/

structure PerActorEventPreorder (Actor Event : Type*) where
  le : Actor → Event → Event → Prop
  refl : ∀ a e, le a e e
  trans : ∀ a e₁ e₂ e₃, le a e₁ e₂ → le a e₂ e₃ → le a e₁ e₃

namespace PerActorEventPreorder

variable {Actor Event : Type*} (ord : PerActorEventPreorder Actor Event)

theorem le_refl (a : Actor) (e : Event) : ord.le a e e :=
  ord.refl a e

theorem le_trans (a : Actor) (e₁ e₂ e₃ : Event) :
    ord.le a e₁ e₂ → ord.le a e₂ e₃ → ord.le a e₁ e₃ :=
  ord.trans a e₁ e₂ e₃

end PerActorEventPreorder

-- ============================================================================
-- 2. Relational-time model: participation + local preorders
-- ============================================================================

structure RelationalTimeModel where
  Actor : Type*
  Event : Type*
  participates : Actor → Event → Prop
  order : PerActorEventPreorder Actor Event

namespace RelationalTimeModel

variable (m : RelationalTimeModel)

/-!
The artifact describes a global relational order induced by local participation
orders. There are multiple possible “globalization” choices (union, transitive
closure, etc.).  We define a minimal, auditable base relation:

`happensBefore e₁ e₂`  iff there exists an actor that participated in both and
orders them locally.

Downstream files can take transitive closure if they need a true partial order.
-/

def happensBefore (e₁ e₂ : m.Event) : Prop :=
  ∃ a, m.participates a e₁ ∧ m.participates a e₂ ∧ m.order.le a e₁ e₂

theorem happensBefore_refl (e : m.Event) :
    (∃ a, m.participates a e) → m.happensBefore e e := by
  intro hex
  rcases hex with ⟨a, ha⟩
  refine ⟨a, ha, ha, ?_⟩
  exact m.order.refl a e

theorem happensBefore_trans_of_same_actor
    {e₁ e₂ e₃ : m.Event} {a : m.Actor}
    (h12 : m.participates a e₁ ∧ m.participates a e₂ ∧ m.order.le a e₁ e₂)
    (h23 : m.participates a e₂ ∧ m.participates a e₃ ∧ m.order.le a e₂ e₃) :
    m.happensBefore e₁ e₃ := by
  refine ⟨a, h12.1, h23.2.1, ?_⟩
  exact m.order.trans a e₁ e₂ e₃ h12.2.2 h23.2.2

end RelationalTimeModel

end CATEPTMain.Integration.WDWRQMRelationalTimeContracts

