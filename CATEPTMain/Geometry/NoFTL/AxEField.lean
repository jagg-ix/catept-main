import CATEPTMain.Geometry.NoFTL.Sorts

/-!
# AxEField — Euclidean Field Axiom

The field of quantities is Euclidean: every non-negative element has a
square root. Isabelle: `class AxEField = axEField + assumes AxEField`.
-/

set_option autoImplicit false

namespace NoFTL

open Sorts

/-- A linearly ordered field where every non-negative element has a square root. -/
class AxEField (Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q] where
  axEField : ∀ x : Q, x ≥ 0 → hasRoot x

end NoFTL
