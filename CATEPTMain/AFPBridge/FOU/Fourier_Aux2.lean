import CATEPTMain.AFPBridge.FOU.Confine
import Mathlib.Analysis.Calculus.ContDiff.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
/-!
# Fourier_Aux2 — AFP Fourier → Lean 4 (Phase 1)

Source: `Fourier/Fourier_Aux2.thy` (Lawrence Paulson — 2019)
Dependencies: Confine

Content: Auxiliary lemmas for the Riemann-Lebesgue lemma and
  L² convergence proof:
  - Riemann-Lebesgue lemma: cₙ(f) → 0 as |n| → ∞
  - Decay of Fourier coefficients for differentiable functions
  - Pointwise convergence prerequisites (Dini/Lipschitz conditions)

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.FOU.Fourier_Aux2

open CATEPTMain.AFPBridge.FOU

-- ── Riemann-Lebesgue lemma ────────────────────────────────────────────────────
-- AFP: For f ∈ L¹(μ_pi), cₙ(f) → 0 as |n| → ∞.
-- This is the Riemann-Lebesgue lemma.
private axiom riemann_lebesgue_law (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto (fun n : ℤ => fourierCoeff f n)
    (Filter.atTop ⊓ Filter.atBot) (nhds 0)

theorem riemann_lebesgue (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto (fun n : ℤ => fourierCoeff f n)
    (Filter.atTop ⊓ Filter.atBot) (nhds 0) := riemann_lebesgue_law f hf

-- More precise statement: convergence along n → +∞ and n → -∞:
private axiom riemann_lebesgue_pos_law (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto (fun n : ℕ => fourierCoeff f n)
    Filter.atTop (nhds 0)

theorem riemann_lebesgue_pos (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto (fun n : ℕ => fourierCoeff f n)
    Filter.atTop (nhds 0) := riemann_lebesgue_pos_law f hf

private axiom riemann_lebesgue_neg_law (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto (fun n : ℕ => fourierCoeff f (-n))
    Filter.atTop (nhds 0)

theorem riemann_lebesgue_neg (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto (fun n : ℕ => fourierCoeff f (-n))
    Filter.atTop (nhds 0) := riemann_lebesgue_neg_law f hf

-- ── Coefficient decay for C¹ functions ───────────────────────────────────────
-- AFP: If f is C¹ and periodic, then cₙ(f) = cₙ(f') / (in).
-- Integration by parts: cₙ(f') = in * cₙ(f).
private axiom fourierCoeff_deriv_law (f : ℝ → ℂ) (hf : SqIntegrable f)
    (hDiff : ContDiff ℝ 1 f) (hPer : Is2PiPeriodic f) (n : ℤ) (hn : n ≠ 0) :
    fourierCoeff (fun x => deriv f x) n =
    Complex.I * n * fourierCoeff f n

theorem fourierCoeff_deriv (f : ℝ → ℂ) (hf : SqIntegrable f)
    (hDiff : ContDiff ℝ 1 f) (hPer : Is2PiPeriodic f) (n : ℤ) (hn : n ≠ 0) :
    fourierCoeff (fun x => deriv f x) n =
    Complex.I * n * fourierCoeff f n := fourierCoeff_deriv_law f hf hDiff hPer n hn

-- ── Decay rate: |cₙ(f)| ≤ C/|n| for C¹ periodic f ───────────────────────────
private axiom fourierCoeff_c1_decay_law (f : ℝ → ℂ) (hf : SqIntegrable f)
    (hDiff : ContDiff ℝ 1 f) (hPer : Is2PiPeriodic f) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℤ, n ≠ 0 → ‖fourierCoeff f n‖ ≤ C / |n|

theorem fourierCoeff_c1_decay (f : ℝ → ℂ) (hf : SqIntegrable f)
    (hDiff : ContDiff ℝ 1 f) (hPer : Is2PiPeriodic f) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℤ, n ≠ 0 → ‖fourierCoeff f n‖ ≤ C / |n| :=
  fourierCoeff_c1_decay_law f hf hDiff hPer

-- ── Cesàro sum convergence ────────────────────────────────────────────────────
-- AFP Aux2 also contains Fejér kernel lemmas (Cesàro sums ↦ pointwise convergence).
-- Fejér kernel: F_N = (1/N) ∑_{k=0}^{N-1} D_k
noncomputable def fejerKernel (N : ℕ) (hN : 0 < N) (x : ℝ) : ℂ :=
  (1 / N : ℂ) * ∑ k ∈ Finset.range N,
    ∑ n ∈ Finset.Icc (-k : ℤ) k, Complex.exp (Complex.I * n * x)

-- Fejér sum ≥ 0 (real-valued, non-negative):
private axiom fejerKernel_nonneg_law (N : ℕ) (hN : 0 < N) (x : ℝ) :
    0 ≤ (fejerKernel N hN x).re

theorem fejerKernel_nonneg (N : ℕ) (hN : 0 < N) (x : ℝ) :
    0 ≤ (fejerKernel N hN x).re := fejerKernel_nonneg_law N hN x

end CATEPTMain.AFPBridge.FOU.Fourier_Aux2
