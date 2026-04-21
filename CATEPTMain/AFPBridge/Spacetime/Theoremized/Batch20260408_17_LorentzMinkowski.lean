import Mathlib

/-!
# Batch 20260408 Theoremization - Row 17 (Lorentz/Minkowski)

This module upgrades scaffold obligations from:

- `AFPBridge/Spacetime/Imported/Batch20260408_17_0008_section_4_discussion.lean`

into compile-checked theorem statements with non-vacuous proofs.
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.Spacetime.Theoremized.Batch20260408.B17

noncomputable section

abbrev M4 : Type := Matrix (Fin 4) (Fin 4) ℝ

/-- Minkowski metric with signature `(+,+,+,-)`. -/
def minkowski : M4 :=
  !![1, 0, 0, 0;
     0, 1, 0, 0;
     0, 0, 1, 0;
     0, 0, 0, -1]

/-- Lorentz factor under a strict subluminal guard. -/
def gammaFactor (v : ℝ) (_hv : |v| < 1) : ℝ :=
  1 / Real.sqrt (1 - v ^ 2)

/-- Boost in the `x`-direction with free scalar `γ`. -/
def lorentzBoostX (v γ : ℝ) : M4 :=
  !![γ, 0, 0, -γ * v;
     0, 1, 0, 0;
     0, 0, 1, 0;
     -γ * v, 0, 0, γ]

/-- Guarded gamma identity used for metric invariance. -/
theorem gammaFactor_sq_mul_one_sub_v_sq (v : ℝ) (hv : |v| < 1) :
    (gammaFactor v hv) ^ 2 * (1 - v ^ 2) = 1 := by
  have hv' : v ^ 2 < 1 := by
    rcases abs_lt.mp hv with ⟨hneg, hpos⟩
    nlinarith
  have hden_pos : 0 < 1 - v ^ 2 := by linarith
  have hden_ne : (1 - v ^ 2) ≠ 0 := ne_of_gt hden_pos
  have hsqrt_sq : (Real.sqrt (1 - v ^ 2)) ^ 2 = 1 - v ^ 2 := by
    simpa using (Real.sq_sqrt (show 0 ≤ 1 - v ^ 2 by linarith))
  calc
    (gammaFactor v hv) ^ 2 * (1 - v ^ 2)
        = (1 / Real.sqrt (1 - v ^ 2)) ^ 2 * (1 - v ^ 2) := by
          simp [gammaFactor]
    _ = (1 / (Real.sqrt (1 - v ^ 2)) ^ 2) * (1 - v ^ 2) := by ring
    _ = (1 / (1 - v ^ 2)) * (1 - v ^ 2) := by
          rw [hsqrt_sq]
    _ = 1 := by
          field_simp [hden_ne]

/-- Algebraic preservation of Minkowski metric by the boost when
`γ²(1-v²)=1` holds. -/
theorem lorentzBoostX_preserves_minkowski_of_relation
    (v γ : ℝ)
    (hγ : γ ^ 2 * (1 - v ^ 2) = 1) :
    (Matrix.transpose (lorentzBoostX v γ)) * minkowski * (lorentzBoostX v γ) = minkowski := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [lorentzBoostX, minkowski, Matrix.mul_apply, Fin.sum_univ_four] <;>
    ring_nf <;>
    nlinarith [hγ]

/-- Guarded Lorentz boost preserves Minkowski metric. -/
theorem lorentzBoostX_preserves_minkowski
    (v : ℝ) (hv : |v| < 1) :
    (Matrix.transpose (lorentzBoostX v (gammaFactor v hv))) * minkowski *
      (lorentzBoostX v (gammaFactor v hv)) = minkowski := by
  apply lorentzBoostX_preserves_minkowski_of_relation
  simpa using gammaFactor_sq_mul_one_sub_v_sq v hv

/-- Time-dilation model used by this theoremization pass. -/
def dilatedTime (v t : ℝ) (hv : |v| < 1) : ℝ :=
  gammaFactor v hv * t

/-- Length-contraction model used by this theoremization pass. -/
def contractedLength (v L : ℝ) (hv : |v| < 1) : ℝ :=
  L / gammaFactor v hv

theorem dilatedTime_eq_gamma_mul (v t : ℝ) (hv : |v| < 1) :
    dilatedTime v t hv = gammaFactor v hv * t := by
  rfl

theorem contractedLength_mul_gamma (v L : ℝ) (hv : |v| < 1) :
    contractedLength v L hv * gammaFactor v hv = L := by
  have hv' : v ^ 2 < 1 := by
    rcases abs_lt.mp hv with ⟨hneg, hpos⟩
    nlinarith
  have hden_pos : 0 < 1 - v ^ 2 := by linarith
  have hsqrt_ne : Real.sqrt (1 - v ^ 2) ≠ 0 := by
    intro hs
    exact (not_le_of_gt hden_pos) (Real.sqrt_eq_zero'.mp hs)
  have hγ_ne : gammaFactor v hv ≠ 0 := by
    unfold gammaFactor
    exact one_div_ne_zero hsqrt_ne
  unfold contractedLength
  field_simp [hγ_ne]

/-- Guard theorem: luminal velocity cannot satisfy the subluminal guard. -/
theorem no_sub_luminal_witness_at_luminal :
    ¬ (|(1 : ℝ)| < 1) := by
  norm_num

/-- Denominator collapse at luminal speed (symbolic precursor of divergence). -/
theorem gamma_denominator_zero_at_luminal :
    1 - (1 : ℝ) ^ 2 = 0 := by
  norm_num

end

end CATEPTMain.AFPBridge.Spacetime.Theoremized.Batch20260408.B17
