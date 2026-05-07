import CATEPTMain.Core.Framework.AFPBridgeFramework
import CATEPTMain.CATEPT.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.MeasurePathIntegral
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
--
-- M5.3 (orphan-triage Milestone 5): the duplicate `MeasurePathIntegralModel`
-- structure that was previously declared here has been retired in favor of
-- the canonical declaration from
-- `CATEPTMainExtracted.CATEPT.CATEPT.MeasurePathIntegral` (re-exported via
-- the `CATEPTMain.CATEPT.CATEPT.MeasurePathIntegral` shim, imported above).
-- This eliminates the second `noConfusionType` collision (the first was on
-- ComplexHamiltonian, fixed in M5.2). The catept-core version uses Latin
-- field names (`mu`, `alpha`) instead of catept-main's former Greek
-- (`μ`, `α`); the few catept-main consumers using Greek names migrate
-- alongside this gut (M5.3 same PR).

-- The structure `MeasurePathIntegralModel` and its theorem block
-- (`actionReScaled`, `actionImScaled`, `phase`, `damping`, `weight`,
-- `weight_factorizes`, `phase_norm_one`, `weight_norm_is_damping`,
-- `damping_pos`, `damping_le_one`, `weight_bochner_bounded`,
-- `cameron_condition`, `measurable_weight`, `measurable_actionImScaled`,
-- `measurable_damping`) previously declared here are now provided by
-- `CATEPTMainExtracted.CATEPT.CATEPT.MeasurePathIntegral` (Latin
-- field-name version: `mu : Measure alpha`). The eq-numbered theorems
-- and `weight_eq_damping_of_actionRe_zero` are extra deliveries from
-- the catept-core canonical extraction.

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
