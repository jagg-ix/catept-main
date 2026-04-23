import CATEPTMain.Geometry.NoFTL.Affine
import CATEPTMain.Geometry.NoFTL.WorldView

/-!
# AxDiff — Differentiability Axiom

Asserts that worldview transformations are differentiable wherever they
are defined — they can be approximated locally by invertible affine
transformations.

Isabelle: `class AxDiff = Affine + WorldView`.
-/

set_option autoImplicit false

namespace NoFTL.AxDiff

open NoFTL.Points NoFTL.Functions NoFTL.WorldView NoFTL.Affine

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q]

/-- `axDiff m k p`: if the worldview transformation from `m` to `k` is
    defined at `p`, then there exists an invertible affine map that
    approximates it at `p`. -/
def axDiff (m k : B) (p : Point Q) : Prop :=
  definedAt (wvtFunc (Q := Q) m k) p →
    ∃ A, affineApprox A (wvtFunc (Q := Q) m k) p

/-- AxDiff axiom class. -/
class AxDiff (B Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
    [NoFTL.AxEField Q] [WorldViewRel B Q] where
  axDiffAx : ∀ (m k : B) (p : Point Q), axDiff m k p

end NoFTL.AxDiff
