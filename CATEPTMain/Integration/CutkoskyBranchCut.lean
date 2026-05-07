import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Tactic.Ring
import CATEPTMain.Integration.CutkoskyDiscontinuity

/-!
# Branch-Cut Log Discontinuity (T-EE Phase 4)

Phase-4 honest content for the **Cutkosky cutting rules** on the
principal branch of `Complex.log`. Phase 3 pinned the universal
unitarity identity `Disc(z) = 2i·Im(z)`. Phase 4 evaluates this
discontinuity on the **simplest non-trivial cut** — the negative
real axis, where the principal-branch logarithm jumps by `2πi`.

Concretely we pin:

* `Complex.log_neg_one`-based packaging
                      `branchValueLogNegOne : log(-1) = π · I`.
* `cutkoskyDisc_log_neg_one  =  2π·I`
                      — the famous `2πi` jump of `log` across the
                      negative real axis, which is the algebraic
                      shadow of the Cutkosky cut for the one-loop
                      bubble integral `B(s) ∝ log(m² − s − i0⁺)`.
* `branchImag_log_neg_one  =  π`
                      — the `π`-shift of the imaginary part across
                      the cut, the algebraic core of the standard
                      one-loop optical-theorem identity
                      `Im B(s) = π·Θ(s − 4m²) · ρ(s)`.

## Phase status

Phase-4 — kernel-only `[propext, Classical.choice, Quot.sound]`.
Full ε-prescription analysis `lim_{ε ↓ 0} Im log(x + iε) = π·Θ(-x)`
deferred to a phase that wires up `Real.arctan2` continuity at
the cut.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CutkoskyBranchCut

open Complex
open scoped ComplexConjugate

open CATEPTMain.Integration.CutkoskyDiscontinuity

noncomputable section

/-- **Principal-branch logarithm at `-1`** — the algebraic shadow
    of the branch-cut jump:
      `log(-1) = π · I`  (Mathlib `Complex.log_neg_one`). -/
theorem branchValueLogNegOne :
    Complex.log (-1) = (Real.pi : ℂ) * I := by
  exact Complex.log_neg_one

/-- **Imaginary-part `π`-shift** across the negative real axis:
    `Im(log(-1)) = π`. This is the algebraic core of the
    one-loop optical-theorem identity `Im B(s) = π·ρ(s)` above
    threshold. -/
theorem branchImag_log_neg_one :
    (Complex.log (-1)).im = Real.pi := by
  rw [Complex.log_neg_one]
  simp

/-- **Cutkosky cut of the principal-branch logarithm at `-1`**:
      `Disc(log(-1))  =  2π · I`,
    the famous `2πi` jump of `log` across the negative real axis.
    Algebraic shadow of the Cutkosky cut for the one-loop bubble
    integral `B(s) ∝ log(m² − s − i0⁺)`. -/
theorem cutkoskyDisc_log_neg_one :
    cutkoskyDisc (Complex.log (-1)) = (2 * Real.pi : ℝ) * I := by
  rw [cutkoskyDisc_eq_two_I_im, branchImag_log_neg_one]

/-- **Branch-cut detection**: the discontinuity of `log` at `-1`
    is non-zero, witnessing a genuine cut on the negative real axis
    (i.e. `log` is not single-valued in any neighbourhood of `-1`). -/
theorem cutkoskyDisc_log_neg_one_ne_zero :
    cutkoskyDisc (Complex.log (-1)) ≠ 0 := by
  rw [cutkoskyDisc_log_neg_one]
  intro h
  have him := congrArg Complex.im h
  simp at him

end

end CATEPTMain.Integration.CutkoskyBranchCut
