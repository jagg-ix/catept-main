import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 223

Bell-angle/CFT projection scaffold extracted from
`0222_bell_inequalities_and_cft_projection.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G223

noncomputable section

open Real

def thetaN (n : Fin 5) : ℝ := (n : ℝ) * (2 * π / 5)

def omegaN (R hbar : ℝ) (n : Fin 5) : ℝ := R / hbar * cos (thetaN n)

def tickDuration (R hbar : ℝ) (n : Fin 5) : ℝ := 2 * π / omegaN R hbar n

def spinorUp (n : Fin 5) : ℝ := cos (thetaN n / 2)
def spinorDown (n : Fin 5) : ℝ := sin (thetaN n / 2)

def bornProjection (n : Fin 5) : ℝ := spinorUp n ^ 2 + spinorDown n ^ 2

def entropyFlow (R hbar : ℝ) (n : Fin 5) : ℝ := omegaN R hbar n

def bellAngleSet : List ℝ := List.map thetaN (List.finRange 5)

theorem bornProjection_eq_one (n : Fin 5) : bornProjection n = 1 := by
  unfold bornProjection spinorUp spinorDown
  nlinarith [Real.cos_sq_add_sin_sq (thetaN n / 2)]

theorem bellAngleSet_length : bellAngleSet.length = 5 := by
  unfold bellAngleSet
  simp

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G223
