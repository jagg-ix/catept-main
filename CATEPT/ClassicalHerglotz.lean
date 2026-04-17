import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Calculus.Deriv.Basic

noncomputable section
set_option autoImplicit false
set_option linter.unusedVariables false

namespace CATEPT

open Complex
open Real

structure SplitLagrangian (Q : Type) where
  Lre : Q → Q → ℝ → ℝ
  Lim : Q → Q → ℝ → ℝ → ℝ

def SplitLagrangian.toComplex {Q : Type} (L : SplitLagrangian Q) : Q → Q → ℝ → ℝ → ℂ :=
  fun q qdot t s => (L.Lre q qdot t : ℂ) + Complex.I * (L.Lim q qdot t s : ℂ)

def SatisfiesActionAccumulation {Q : Type} (L : SplitLagrangian Q) (q qdot : ℝ → Q) (s : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, ∃ dsdt : ℝ, dsdt = L.Lre (q t) (qdot t) t - L.Lim (q t) (qdot t) t (s t)

structure HerglotzJet where
  q      : ℝ
  v      : ℝ
  a      : ℝ
  s      : ℝ
  dL_dq  : ℝ
  dL_dv  : ℝ
  ddt_dL_dv : ℝ
  dL_ds  : ℝ

def SatisfiesHerglotzEL (J : HerglotzJet) : Prop :=
  J.ddt_dL_dv - J.dL_dq = J.dL_ds * J.dL_dv

structure DampedOscillatorParams where
  m : ℝ
  k : ℝ
  gamma : ℝ
  m_pos : 0 < m

def effectiveHerglotzLagrangian (Lre : ℝ → ℝ → ℝ → ℝ) (contactRate : ℝ → ℝ → ℝ → ℝ) : ℝ → ℝ → ℝ → ℝ → ℝ :=
  fun q v t s => Lre q v t - contactRate q v t * s

theorem herglotz_to_damped_oscillator
    (p : DampedOscillatorParams)
    (J : HerglotzJet)
    (hEL  : SatisfiesHerglotzEL J)
    (hdv  : J.dL_dv = p.m * J.v)
    (hddv : J.ddt_dL_dv = p.m * J.a)
    (hdq  : J.dL_dq = -p.k * J.q)
    (hds  : J.dL_ds = -(p.gamma / p.m)) :
    p.m * J.a + p.k * J.q = -p.gamma * J.v := by
  have hm : p.m ≠ 0 := ne_of_gt p.m_pos
  unfold SatisfiesHerglotzEL at hEL
  rw [hdv, hddv, hdq, hds] at hEL
  calc
    p.m * J.a + p.k * J.q = (p.m * J.a - (-p.k * J.q)) := by ring
    _ = (-(p.gamma / p.m)) * (p.m * J.v) := by rw [hEL]
    _ = -(p.gamma * J.v) := by rw [neg_mul, ← mul_assoc, div_mul_cancel₀ p.gamma hm]
    _ = -p.gamma * J.v := by ring

def IsLinearImaginarySector (Lim : ℝ → ℝ → ℝ → ℝ → ℝ) (ρ : ℝ → ℝ → ℝ → ℝ) : Prop :=
  ∀ q v t s, Lim q v t s = ρ q v t * s

def CATContactRateFromImaginary (Lim : ℝ → ℝ → ℝ → ℝ → ℝ) (ρ : ℝ → ℝ → ℝ → ℝ) (hρ : IsLinearImaginarySector Lim ρ) : ℝ → ℝ → ℝ → ℝ :=
  ρ

def oscillatorLre (p : DampedOscillatorParams) : ℝ → ℝ → ℝ → ℝ :=
  fun x v _t => (p.m / 2) * v^2 - (p.k / 2) * x^2

def oscillatorLim (p : DampedOscillatorParams) : ℝ → ℝ → ℝ → ℝ → ℝ :=
  fun _x _v _t s => (p.gamma / p.m) * s

def oscillatorLeff (p : DampedOscillatorParams) : ℝ → ℝ → ℝ → ℝ → ℝ :=
  effectiveHerglotzLagrangian (oscillatorLre p) (fun _ _ _ => p.gamma / p.m)

end CATEPT
