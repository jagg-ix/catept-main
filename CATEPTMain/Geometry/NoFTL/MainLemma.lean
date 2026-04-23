import CATEPTMain.Geometry.NoFTL.Sublemma3
import CATEPTMain.Geometry.NoFTL.Sublemma4

/-!
# MainLemma — Tangent Line Preservation

Establishes conditions under which a function maps tangent lines to
tangent lines. The key result (`lemMainLemma`) shows that if `f` has
an affine approximation `A` at `x`, then `A` maps tangent lines at `x`
to tangent lines at `f(x)`.

Isabelle: `class MainLemma = Sublemma3 + Sublemma4`.
-/

set_option autoImplicit false

namespace NoFTL.MainLemma

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Norms
open NoFTL.Affine NoFTL.TangentLines

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

/-- Main lemma (origin version): if `f` has affine approximation `A` at
    the origin and maps the origin to itself, then `A` maps tangent
    lines of `wl` at origin to tangent lines of `f(wl)` at origin. -/
theorem lemMainLemmaBasic
    (l l' wl : Set (Point Q)) (f A : Point Q → Point Q)
    (htgt : tangentLine l wl origin)
    (hinj : injective (asFunc f))
    (haff : affineApprox A (asFunc f) origin)
    (hf0 : (asFunc f) origin origin)
    (hcts : cts (invFunc (asFunc f)) origin)
    (hline : applyAffineToLine A l l') :
    tangentLine l' (applyToSet (asFunc f) wl) origin := by
  sorry -- phase2: long proof (~250 lines in Isabelle)

/-- Main lemma (origin version, relational): version using relational
    function `f` instead of total function. -/
theorem lemMainLemmaOrigin
    (l l' wl : Set (Point Q)) (f : Point Q → Point Q → Prop) (A : Point Q → Point Q)
    (htgt : tangentLine l wl origin)
    (hinj : injective f)
    (haff : affineApprox A f origin)
    (hf0 : f origin origin)
    (hcts : cts (invFunc f) origin)
    (hline : applyAffineToLine A l l') :
    tangentLine l' (applyToSet f wl) origin := by
  sorry -- phase2: similar to lemMainLemmaBasic

/-- Main lemma (general version): translated to arbitrary base point `x`.
    If `f` has affine approximation `A` at `x`, then `A` maps tangent
    lines at `x` to tangent lines at `A(x)`. -/
theorem lemMainLemma
    (l l' wl : Set (Point Q)) (f : Point Q → Point Q → Prop) (A : Point Q → Point Q)
    (x : Point Q)
    (htgt : tangentLine l wl x)
    (hinj : injective f)
    (haff : affineApprox A f x)
    (hcts : cts (invFunc f) (A x))
    (hline : applyAffineToLine A l l') :
    tangentLine l' (applyToSet f wl) (A x) := by
  sorry -- phase2: reduces to lemMainLemmaOrigin via translation (~200 lines)

end NoFTL.MainLemma
