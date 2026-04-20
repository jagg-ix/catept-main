import CATEPTMain.AFPBridge.NoFTL.Norms

/-!
# AxTriangleInequality — Triangle Inequality Axiom

Asserts the triangle inequality for spacetime norms. Although this can
be proved rather than asserted, the Isabelle development leaves it as
an axiom to focus on the physics.

Isabelle: `class AxTriangleInequality = Norms + assumes AxTriangleInequality`.
-/

set_option autoImplicit false

namespace NoFTL.AxTriangleInequality

open NoFTL.Points NoFTL.Norms

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

/-- AxTriangleInequality: for all points `p` and `q`,
    `norm (p ⊕ q) ≤ norm p + norm q`. -/
class AxTriangleInequality (Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
    [NoFTL.AxEField Q] where
  axTriangleInequality : ∀ (p q : Point Q), axTriangleInequality p q

end NoFTL.AxTriangleInequality
