import CATEPTMain.NoFTL.MainLemma
import CATEPTMain.NoFTL.AxDiff
import CATEPTMain.NoFTL.Cones

/-!
# TangentLineLemma — Worldview Transformations and Tangent Lines

Shows that worldview transformations are functions, are injective, are
continuous, and preserve tangent lines. The key result is `lemTangentLines`:
if `A` approximates `wvt m k` at `x`, then `A` maps tangent lines of `m`'s
worldlines at `x` to tangent lines of `k`'s worldlines at `A(x)`.

Isabelle: `class TangentLineLemma = MainLemma + AxDiff + Cones`.
-/

set_option autoImplicit false

namespace NoFTL.TangentLineLemma

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Affine
open NoFTL.WorldView NoFTL.WorldLine NoFTL.TangentLines NoFTL.Cones

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxDiff.AxDiff B Q] [NoFTL.AxSelfMinus.AxSelfMinus B Q]

theorem lemWVTImpliesFunction (k h : B) :
    isFunction (wvtFunc (Q := Q) k h) := by
  sorry -- phase2: uses AxDiff + affineApprox uniqueness

theorem lemWVTCts (h k : B) (p : Point Q)
    (hdef : definedAt (wvtFunc (Q := Q) h k) p) :
    cts (wvtFunc (Q := Q) h k) p := by
  sorry -- phase2: uses AxDiff + sublemma4

theorem lemWVTInverse (k h : B) :
    invFunc (wvtFunc (Q := Q) k h) = wvtFunc h k := by
  sorry -- phase2: direct from definitions

theorem lemWVTInverseCts (k h : B) (p q : Point Q)
    (hwvt : wvtFunc (Q := Q) k h p q) :
    cts (wvtFunc (Q := Q) h k) q := by
  sorry -- phase2: uses lemWVTCts

theorem lemWVTInjective (k h : B) :
    injective (wvtFunc (Q := Q) k h) := by
  sorry -- phase2: uses invFunc properties

theorem lemPresentation (m k b : B) (x y : Point Q)
    (l l' : Set (Point Q)) (A : Point Q → Point Q)
    (hx : x ∈ wline (Q := Q) m b)
    (htl : tangentLine l (wline (Q := Q) m b) x)
    (haff : affineApprox A (wvtFunc (Q := Q) m k) x)
    (hwvt : wvtFunc (Q := Q) m k x y)
    (hline : applyAffineToLine A l l') :
    tangentLine l' (wline (Q := Q) k b) y := by
  sorry -- phase2: uses lemMainLemma

theorem lemTangentLines (m k b : B) (x y : Point Q)
    (l l' : Set (Point Q)) (A : Point Q → Point Q)
    (haff : affineApprox A (wvtFunc (Q := Q) m k) x)
    (htl : tl l m b x)
    (hline : applyAffineToLine A l l')
    (hwvt : wvtFunc (Q := Q) m k x y) :
    tl l' k b y := by
  sorry -- phase2: uses lemPresentation

theorem lemSelfTangentIsTimeAxis (k : B) (x : Point Q)
    (l : Set (Point Q))
    (htl : tangentLine l (wline (Q := Q) k k) x) :
    l = timeAxis := by
  sorry -- phase2: uses AxSelfMinus + time-axis geometry

theorem lemTangentLineUnique (m k : B) (x y : Point Q)
    (l1 l2 : Set (Point Q)) (A : Point Q → Point Q)
    (htl1 : tl l1 m k x) (htl2 : tl l2 m k x)
    (haff : affineApprox A (wvtFunc (Q := Q) m k) x)
    (hwvt : wvtFunc (Q := Q) m k x y)
    (hx : x ∈ wline (Q := Q) m k) :
    l1 = l2 := by
  sorry -- phase2: long proof using lemPresentation + affine injectivity

end NoFTL.TangentLineLemma
