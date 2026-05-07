import CATEPTMain.Core.Framework.AFPBridgeFramework
import CATEPTMain.CATEPT.CATEPT.Foundations
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Function.SpecialFunctions.Basic
/-!
# CATEPT Port — Prelude

Core structures for the Complex Action / Entropic Time (CAT/EPT) framework
within the AFPBridge plugin architecture.

## Physical framework

The CAT/EPT action splits as:
  S[φ] = S_R[φ] + i S_I[φ],   S_I[φ] ≥ 0

The path weight is:
  w(φ) = exp(i S_R/ħ − S_I/ħ) = exp(i S_R/ħ) · exp(−τ_ent)

where:
  τ_ent = S_I/ħ ≥ 0    (entropic proper time)
  |w(φ)| = exp(−τ_ent) ∈ (0, 1]   (damping — Feynman–Kac factor)

## Source

Ported (originally from an external `navier-stokes-project-clean-translator`
sibling directory — no longer maintained here). The corresponding content
now lives in-repo at:
  - `NavierStokesClean/CATEPT/Foundations.lean`
  - `NavierStokesClean/CATEPT/MeasurePathIntegral.lean`
  - (historical external) `entropic-time/lean4_formal_verification/NavierStokes/NSCATEPTModularFlowQFTKucharBridge.lean`

## Theorem status

| Name                              | Status   | Notes                              |
|-----------------------------------|----------|------------------------------------|
| `ComplexAction`                   | defined  | S = S_R + i S_I, S_I ≥ 0         |
| `MeasurePathIntegralModel`        | defined  | measurable state space + weight    |
| `weight_factorizes`               | proved   | w = phase · damping                |
| `weight_norm_is_damping`          | proved   | |w| = exp(−τ_ent)                  |
| `damping_pos`                     | proved   | exp(−τ_ent) > 0                   |
| `damping_le_one`                  | proved   | exp(−τ_ent) ≤ 1 when S_I ≥ 0     |
| `phase_norm_one`                  | proved   | |exp(iS_R/ħ)| = 1                  |
| `cameron_condition`               | proved   | Re(weight exponent) ≤ 0           |
| `weight_bochner_bounded`          | proved   | ‖w‖ ≤ 1                           |
-/

set_option autoImplicit false

open MeasureTheory Complex Real

namespace CATEPTMain.CATEPT.CATEPT

-- ── Complex action / Hamiltonian / entropicTime ─────────────────────────────
--
-- M5.2 (orphan-triage Milestone 5): the duplicates of `ComplexAction`,
-- `ComplexHamiltonian`, and `entropicTime` that were previously declared
-- here have been retired in favor of the canonical declarations from
-- `CATEPTMainExtracted.CATEPT.CATEPT.Foundations` (re-exported via the
-- `CATEPTMain.CATEPT.CATEPT.Foundations` shim, imported at line 2 above).
-- This eliminates a `noConfusionType` collision that previously blocked
-- `OrphanAggregator`, `QMOrphanBundle`, and `GTDEntropyAffineBridge`
-- whenever both files were in the same import closure.
--
-- The catept-core canonical version uses snake-case `entropic_time`. To
-- preserve the catept-main camelCase consumer surface (~15 references
-- across Domains/Adapters/*, Integration/*, Spacetime/*), we keep
-- `entropicTime` as a local alias plus the camelCase theorem aliases.

/-- Camel-case alias for `entropic_time` (back-compat with the
~15 catept-main consumers that reference `entropicTime` directly). -/
noncomputable def entropicTime (hbar S_I : ℝ) : ℝ := entropic_time hbar S_I

/-- Camel-case re-export of `eq003_entropic_time_nonneg`. -/
theorem entropicTime_nonneg (hbar S_I : ℝ) (hh : 0 < hbar) (hS : 0 ≤ S_I) :
    0 ≤ entropicTime hbar S_I :=
  div_nonneg hS hh.le

/-- Camel-case re-export of `eq003_entropic_time_linear`. -/
theorem entropicTime_linear (hbar S_I S_I' : ℝ) :
    entropicTime hbar (S_I + S_I') =
    entropicTime hbar S_I + entropicTime hbar S_I' := by
  unfold entropicTime entropic_time; rw [add_div]

-- ── Measurable path integral model ───────────────────────────────────────────

/-- Measurable CAT/EPT path integral model on state space α.
    Ported from `NavierStokesClean.CATEPT.MeasurePathIntegral`. -/
structure MeasurePathIntegralModel (α : Type*) [MeasurableSpace α] where
  μ                   : Measure α
  hbar                : ℝ
  hbar_pos            : 0 < hbar
  actionRe            : α → ℝ
  actionIm            : α → ℝ
  measurable_actionRe : Measurable actionRe
  measurable_actionIm : Measurable actionIm
  actionIm_nonneg     : ∀ x, 0 ≤ actionIm x

namespace MeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (m : MeasurePathIntegralModel α)

noncomputable section

/-- Scaled real action S_R / ħ. -/
def actionReScaled (x : α) : ℝ := m.actionRe x / m.hbar

/-- Scaled imaginary action S_I / ħ = τ_ent. -/
def actionImScaled (x : α) : ℝ := m.actionIm x / m.hbar

/-- Oscillatory phase exp(i S_R/ħ). -/
def phase (x : α) : ℂ :=
  Complex.exp ((m.actionReScaled x : ℂ) * Complex.I)

/-- FK damping factor exp(−S_I/ħ) = exp(−τ_ent) ∈ (0,1]. -/
def damping (x : α) : ℝ := Real.exp (-(m.actionImScaled x))

/-- Full CAT/EPT weight exp(i S_R/ħ − S_I/ħ). -/
def weight (x : α) : ℂ :=
  Complex.exp
    ((-(m.actionImScaled x) : ℂ) +
     ((m.actionReScaled x : ℂ) * Complex.I))

-- ── Core weight theorems ──────────────────────────────────────────────────────

/-- Weight factorizes: w = phase · damping. -/
theorem weight_factorizes (x : α) :
    m.weight x =
      Complex.exp ((m.actionReScaled x : ℂ) * Complex.I) *
      (Real.exp (-(m.actionImScaled x)) : ℂ) := by
  unfold weight
  rw [show (Real.exp (-(m.actionImScaled x)) : ℂ) =
      Complex.exp (-(m.actionImScaled x : ℂ)) from by
    simp [Complex.ofReal_exp, Complex.ofReal_neg]]
  rw [← Complex.exp_add]
  congr 1; ring

/-- The oscillatory phase has unit norm. -/
theorem phase_norm_one (x : α) :
    ‖m.phase x‖ = 1 := by
  unfold phase
  rw [Complex.norm_exp_ofReal_mul_I]

/-- The weight norm equals the damping factor. -/
theorem weight_norm_is_damping (x : α) :
    ‖m.weight x‖ = Real.exp (-(m.actionImScaled x)) := by
  rw [weight_factorizes]
  rw [norm_mul]
  have hphase : ‖Complex.exp ((m.actionReScaled x : ℂ) * Complex.I)‖ = 1 :=
    Complex.norm_exp_ofReal_mul_I _
  rw [hphase, one_mul]
  rw [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]

/-- Damping is strictly positive. -/
theorem damping_pos (x : α) : 0 < m.damping x :=
  Real.exp_pos _

/-- Damping is at most 1 (since S_I ≥ 0). -/
theorem damping_le_one (x : α) : m.damping x ≤ 1 := by
  unfold damping actionImScaled
  rw [Real.exp_le_one_iff]
  linarith [div_nonneg (m.actionIm_nonneg x) m.hbar_pos.le]

/-- The weight has norm at most 1. -/
theorem weight_bochner_bounded (x : α) : ‖m.weight x‖ ≤ 1 := by
  rw [weight_norm_is_damping]
  exact damping_le_one m x

/-- Cameron condition: Re(weight exponent) = −S_I/ħ ≤ 0. -/
theorem cameron_condition (x : α) :
    (-(m.actionImScaled x : ℂ) +
     ((m.actionReScaled x : ℂ) * Complex.I)).re ≤ 0 := by
  simp only [Complex.add_re, Complex.neg_re, Complex.ofReal_re,
             Complex.mul_re, Complex.I_re, Complex.I_im, Complex.ofReal_im,
             mul_zero, mul_one, sub_zero]
  unfold actionImScaled
  linarith [div_nonneg (m.actionIm_nonneg x) m.hbar_pos.le]

/-- The weight is measurable. -/
theorem measurable_weight : Measurable m.weight := by
  unfold weight
  apply Complex.measurable_exp.comp
  apply Measurable.add
  · exact (Complex.measurable_ofReal.comp
      (m.measurable_actionIm.div_const m.hbar)).neg
  · exact (Complex.measurable_ofReal.comp
      (m.measurable_actionRe.div_const m.hbar)).mul_const Complex.I

/-- The scaled imaginary action is measurable. -/
theorem measurable_actionImScaled : Measurable m.actionImScaled :=
  m.measurable_actionIm.div_const m.hbar

/-- The damping factor is measurable. -/
theorem measurable_damping : Measurable m.damping :=
  Real.measurable_exp.comp m.measurable_actionImScaled.neg

end  -- noncomputable section

end MeasurePathIntegralModel

-- ── Complex Schrödinger functional ───────────────────────────────────────────

/-- Measure-theoretic complex Schrödinger functional scheme.
    Source: NSCATEPTModularFlowQFTKucharBridge §2. -/
structure ComplexSchrodingerFunctional (α : Type*) [MeasurableSpace α] where
  μ                   : Measure α
  phase               : α → ℝ
  entropicReg         : α → ℝ
  measurable_phase    : Measurable phase
  measurable_reg      : Measurable entropicReg
  entropicReg_nonneg  : ∀ x, 0 ≤ entropicReg x
  integrable_damping  : Integrable (fun x => Real.exp (-entropicReg x)) μ

namespace ComplexSchrodingerFunctional

variable {α : Type*} [MeasurableSpace α] (s : ComplexSchrodingerFunctional α)

/-- The complex kernel k(x) = exp(−reg(x) + i·phase(x)). -/
noncomputable def kernel (x : α) : ℂ :=
  Complex.exp
    ((-s.entropicReg x : ℂ) + Complex.I * (s.phase x : ℂ))

/-- |k(x)| = exp(−reg(x)). -/
@[simp] theorem norm_kernel (x : α) :
    ‖s.kernel x‖ = Real.exp (-s.entropicReg x) := by
  simp [kernel, Complex.norm_exp]

/-- The kernel is measurable. -/
theorem measurable_kernel : Measurable s.kernel := by
  unfold kernel
  apply Complex.measurable_exp.comp
  apply Measurable.add
  · exact (Complex.measurable_ofReal.comp s.measurable_reg).neg
  · exact (Complex.measurable_ofReal.comp s.measurable_phase).const_mul _

/-- The kernel is integrable (Bochner) via dominated convergence by the real damping. -/
theorem kernel_integrable : Integrable s.kernel s.μ := by
  apply (integrable_norm_iff s.measurable_kernel.aestronglyMeasurable).mp
  simpa [norm_kernel] using s.integrable_damping

/-- Partition function Z = ∫ k(x) dμ. -/
noncomputable def partition : ℂ := ∫ x, s.kernel x ∂s.μ

/-- Observable expectation ⟨O⟩ = ∫ O(x) k(x) dμ. -/
noncomputable def expectation (obs : α → ℂ) : ℂ := ∫ x, obs x * s.kernel x ∂s.μ

end ComplexSchrodingerFunctional

end CATEPTMain.CATEPT.CATEPT
