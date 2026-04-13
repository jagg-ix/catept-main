import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 148

q-deformed partition/energy scaffold extracted from
`0014_qssg_qdeform_annotated.lean_updated_.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G148

noncomputable section

structure CommParams where
  M : ℝ
  e : ℝ
  B : ℝ
  ω : ℝ

def eta (P : CommParams) : ℝ :=
  Real.sqrt ((P.e ^ 2 * P.B ^ 2) / 4 + (P.M ^ 2 * P.ω ^ 2))

def Ec (P : CommParams) (n : ℕ) (m : ℤ) : ℝ :=
  (2 * eta P / P.M) * ((n : ℝ) + (((|m| : ℤ) : ℝ) + 1) / 2)
    - (P.e * P.B / (2 * P.M)) * (m : ℝ)

structure NCParams where
  M : ℝ
  e : ℝ
  B : ℝ
  ω : ℝ
  θ : ℝ

def lambdaNC (P : NCParams) : ℝ :=
  1 + (P.e ^ 2 * P.B ^ 2 * P.θ ^ 2) / 16 + (P.e * P.B * P.θ) / 2
    + (P.M ^ 2 * P.ω ^ 2 * P.θ ^ 2) / 4

def tauNC (P : NCParams) : ℝ :=
  P.θ ^ 2 / 4 + (P.e ^ 2 * P.B ^ 2) / 4 + (P.e * P.B * P.θ) / 2
    + (P.M ^ 2 * P.ω ^ 2)

def chiNC (P : NCParams) : ℝ :=
  2 * P.θ + (P.e ^ 2 * P.B ^ 2 * P.θ) / 4 + (P.e * P.B)
    + (P.e * P.B * P.θ ^ 2) / 4

def ENC (P : NCParams) (n : ℕ) (m : ℤ) : ℝ :=
  let lam := lambdaNC P
  let tau := tauNC P
  let chi := chiNC P
  (2 * lam / P.M) * ((n : ℝ) + (((|m| : ℤ) : ℝ) + 1) / 2) * Real.sqrt (tau / lam)
    - (chi / (2 * P.M)) * (m : ℝ)

def Bq (β q E : ℝ) : ℝ :=
  Real.exp (-(β * E)) * (1 + (q / 2) * (β ^ 2) * (E ^ 2))

theorem Bq_at_q_zero (β E : ℝ) :
    Bq β 0 E = Real.exp (-(β * E)) := by
  unfold Bq
  ring_nf

theorem Ec_m0 (P : CommParams) (n : ℕ) :
    Ec P n 0 = (2 * eta P / P.M) * ((n : ℝ) + (1 / 2 : ℝ)) := by
  unfold Ec
  simp

theorem ENC_m0 (P : NCParams) (n : ℕ) :
    ENC P n 0 =
      (2 * lambdaNC P / P.M) * ((n : ℝ) + (1 / 2 : ℝ))
        * Real.sqrt (tauNC P / lambdaNC P) := by
  unfold ENC
  simp

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G148
