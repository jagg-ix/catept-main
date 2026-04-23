import Mathlib.Tactic
import Mathlib.Algebra.Order.Ring.Defs

/-!
# AFP No Faster-Than-Light Observers — Lean 4 Prelude

Faithful port of the AFP entry `No_FTL_observers_Gen_Rel` by
Sulzbacher & Martins (2023) into idiomatic Lean 4 / Mathlib.

The original Isabelle formalization is a 2-sorted first-order theory:
- **Bodies**: photons and observers
- **Quantities**: a linearly ordered field (Isabelle class `linordered_field`)

This prelude establishes the namespace and common notation conventions.
The Isabelle `class Quantities = linordered_field` maps directly to
Lean 4's `LinearOrderedField Q` from Mathlib. No opaque axiom types
are needed — all proofs go through on the concrete algebraic structure.

## Dependency chain (from Isabelle)

```
Sorts (Quantities = linordered_field)
  └── Points (Point Q = 4-component record)
        ├── Functions (relations, composition, injectivity)
        ├── Norms (requires AxEField for sqrt)
        │     └── Vectors (dot products, timelike/spacelike)
        └── WorldView (observer relations)
```
-/

set_option autoImplicit false

namespace NoFTL

/-- Bodies in the NoFTL formalization. A body is either a photon, an observer,
    both, or neither. -/
structure Body where
  Ph : Bool
  Ob : Bool
  deriving DecidableEq, Repr

/-- Typeclass providing photon / observer predicates on an abstract body type.
    Mirrors the Isabelle `Body` record fields `Ph` and `Ob`. -/
class BodySorts (B : Type*) where
  Ph : B → Prop
  Ob : B → Prop

export BodySorts (Ph Ob)

instance : BodySorts NoFTL.Body where
  Ph b := b.Ph = true
  Ob b := b.Ob = true

end NoFTL
