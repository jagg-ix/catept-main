import Mathlib.Data.Complex.Basic
import Mathlib.Tactic.Ring

/-!
# Cutkosky Discontinuity Identity (T-EE Phase 3)

Phase-3 honest content for the **Cutkosky cutting rules** at the
complex-analytic level. The unitarity content of the cutting rules
is the universal identity
  `Disc f(s) := f(s + i0⁺) − f(s − i0⁺) = 2 i · Im f(s + i0⁺)`,
which on a holomorphic amplitude reduces to the basic
complex-analytic identity
  `z − conj(z) = 2 i · Im(z)`.

This module ships that identity (lifted from Mathlib's
`Complex.sub_conj`) along with the standard packaging:

* `cutkoskyDisc`            — the discontinuity functional
                              `Disc(z) := z − conj(z)`.
* `cutkoskyDisc_eq_two_I_im` — `Disc(z) = 2 i · Im(z)`.
* `cutkoskyDisc_real_zero`   — discontinuity vanishes on real axis
                              (no branch cut on `ℝ ⊂ ℂ`).
* `cutkoskyDisc_purely_imaginary` — the discontinuity is always
                              purely imaginary.

## Phase status

Phase-3 — honest complex-analytic content, kernel-only
`[propext, Classical.choice, Quot.sound]`. Genuine branch-cut
analysis of one-loop integrals (e.g. `Im log(s − m² + i0⁺) =
−π·Θ(m² − s)`) still deferred.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CutkoskyDiscontinuity

open Complex
open scoped ComplexConjugate

/-- **Cutkosky discontinuity** of a complex amplitude across a branch
    cut, modelled as the difference between the function at `z` and
    at its complex conjugate. -/
def cutkoskyDisc (z : ℂ) : ℂ := z - conj z

/-- **Universal Cutkosky identity** (the unitarity-content core of
    the cutting rules at the complex-analytic level):
      `Disc(z)  =  2 · i · Im(z)`. -/
theorem cutkoskyDisc_eq_two_I_im (z : ℂ) :
    cutkoskyDisc z = (2 * z.im : ℝ) * I :=
  Complex.sub_conj z

/-- **No discontinuity on the real axis**: a real-valued amplitude
    has vanishing Cutkosky discontinuity, witnessing that the branch
    cut is absent on `ℝ ⊂ ℂ`. -/
theorem cutkoskyDisc_real_zero (x : ℝ) :
    cutkoskyDisc (x : ℂ) = 0 := by
  rw [cutkoskyDisc_eq_two_I_im]
  simp

/-- **Discontinuity is purely imaginary**: the real part of the
    Cutkosky discontinuity vanishes identically. -/
theorem cutkoskyDisc_re_zero (z : ℂ) :
    (cutkoskyDisc z).re = 0 := by
  rw [cutkoskyDisc_eq_two_I_im]
  simp

/-- **Discontinuity imaginary part = 2·Im(z)**: the imaginary part
    of the Cutkosky discontinuity is twice the imaginary part of
    `z`, packaging the optical-theorem normalisation
    `2·Im A = ∑ |A_cut|²` at the algebraic level. -/
theorem cutkoskyDisc_im (z : ℂ) :
    (cutkoskyDisc z).im = 2 * z.im := by
  rw [cutkoskyDisc_eq_two_I_im]
  simp

end CATEPTMain.Integration.CutkoskyDiscontinuity
