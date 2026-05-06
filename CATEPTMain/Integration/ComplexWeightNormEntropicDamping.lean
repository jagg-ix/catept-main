import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Complex Weight Norm = Entropic Damping (T-FF Phase 12)

Honest Lean realization of the user's plan target

  `complex_weight_norm_eq_entropic_damping`

For real `S_R`, `S_I` with `ℏ > 0`, the complex path-integral
weight `exp(i S_R/ℏ − S_I/ℏ)` has modulus exactly
`exp(−S_I/ℏ)`. The phase `i S_R/ℏ` does not contribute to the
UV size; only the imaginary action `S_I` controls magnitude.

This is the standard fact `‖exp z‖ = exp z.re` specialized to
the path-integral weight, isolated as a small reusable
identity that the abstract `EntropicCoercivityModel` from
Phase 11 can be populated against.

Three honest theorems:

* `norm_phase_imaginary_weight` — phase-only weight has unit
  modulus.
* `norm_complex_path_weight_eq_real_damping` — full identity
  `‖exp(i S_R/ℏ − S_I/ℏ)‖ = exp(−S_I/ℏ)`.
* `complex_weight_norm_eq_entropic_damping` — packaged
  variant taking `ℏ > 0` as hypothesis and exposing
  `−S_I/ℏ` directly.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ComplexWeightNormEntropicDamping

open Complex

noncomputable section

/-- Pure-phase weight has unit modulus: for any real `θ`,
`‖exp(i θ)‖ = 1`. -/
theorem norm_phase_imaginary_weight (θ : ℝ) :
    ‖Complex.exp ((θ : ℂ) * Complex.I)‖ = 1 := by
  rw [Complex.norm_exp]
  simp [mul_comm, Complex.I_re, Complex.I_im]

/-- **Core identity** (target #2 of the plan): the complex
path-integral weight has modulus equal to the real entropic
damping factor.
For real `a`, `b`:
  `‖exp(a · i − b)‖ = exp(−b)`. -/
theorem norm_complex_path_weight_eq_real_damping (a b : ℝ) :
    ‖Complex.exp ((a : ℂ) * Complex.I - (b : ℂ))‖ = Real.exp (-b) := by
  rw [Complex.norm_exp]
  congr 1
  simp [Complex.sub_re, Complex.mul_re, Complex.I_re, Complex.I_im, Complex.ofReal_re,
        Complex.ofReal_im]

/-- **Packaged variant** (`complex_weight_norm_eq_entropic_damping`):
for `ℏ > 0`, the path-integral weight `exp(i S_R/ℏ − S_I/ℏ)`
has modulus exactly `exp(−S_I/ℏ)`. The real action `S_R` only
contributes a phase and leaves the UV size unchanged. -/
theorem complex_weight_norm_eq_entropic_damping
    (S_R S_I hbar : ℝ) (_hbar_pos : 0 < hbar) :
    ‖Complex.exp ((S_R / hbar : ℂ) * Complex.I - (S_I / hbar : ℂ))‖
      = Real.exp (-(S_I / hbar)) := by
  have h := norm_complex_path_weight_eq_real_damping (S_R / hbar) (S_I / hbar)
  simpa using h

end

end CATEPTMain.Integration.ComplexWeightNormEntropicDamping
