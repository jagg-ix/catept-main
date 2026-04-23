import CATEPTMain.Geometry.NoFTL.Cones
import CATEPTMain.Geometry.NoFTL.AxLightMinus

/-!
# Proposition 1 — Observer's Cone Equals Regular Cone

If observer `m` sees itself at `x`, then the cone of `m` at `x` equals
the regular cone at `x`.

Isabelle: `class Proposition1 = Cones + AxLightMinus`.
-/

set_option autoImplicit false

namespace NoFTL.Proposition1

open NoFTL.Points NoFTL.WorldView NoFTL.WorldLine NoFTL.Cones

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxLightMinus B Q]

/-- Proposition 1: if `m` sees itself at `x`, then `cone m x p ↔ regularCone x p`. -/
theorem lemProposition1 (m : B) (x p : Point Q)
    (hx : x ∈ wline (Q := Q) m m) :
    cone m x p ↔ regularCone x p := by
  sorry -- phase2: uses AxLightMinus (120 lines in Isabelle)

end NoFTL.Proposition1
