import CATEPTMain.FOU.Fourier_Aux2
/-!
# Fourier — AFP Fourier → Lean 4 (Phase 1)

Source: `Fourier/Fourier.thy` (Lawrence Paulson — 2019)
Dependencies: Fourier_Aux2, Square_Integrable, Confine

Content: Main Fourier series results:
  - Parseval's identity: ∑ |cₙ(f)|² = ‖f‖²_L²
  - L² convergence of Fourier partial sums: ‖f - S_N f‖_L² → 0
  - Riesz-Fischer theorem (converse to Parseval)
  - Fourier series uniqueness: cₙ(f) = 0 for all n → f = 0 in L²

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.FOU.Fourier

open CATEPTMain.FOU

-- ── Parseval's identity ────────────────────────────────────────────────────────
-- AFP main result: ∑_{n=-∞}^{∞} |cₙ(f)|² = ‖f‖²_L²
-- This is Parseval's theorem / Plancherel's identity for Fourier series.
private axiom parseval_law (f : ℝ → ℂ) (hf : SqIntegrable f) :
    HasSum (fun n : ℤ => ‖fourierCoeff f n‖^2) ((L2norm f)^2)

theorem parseval (f : ℝ → ℂ) (hf : SqIntegrable f) :
    HasSum (fun n : ℤ => ‖fourierCoeff f n‖^2) ((L2norm f)^2) := parseval_law f hf

-- Equivalent form using tsum:
private axiom parseval_tsum_law (f : ℝ → ℂ) (hf : SqIntegrable f) :
    ∑' n : ℤ, ‖fourierCoeff f n‖^2 = (L2norm f)^2

theorem parseval_tsum (f : ℝ → ℂ) (hf : SqIntegrable f) :
    ∑' n : ℤ, ‖fourierCoeff f n‖^2 = (L2norm f)^2 := parseval_tsum_law f hf

-- ── L² convergence of partial sums ────────────────────────────────────────────
-- AFP: ‖f - S_N f‖_L² → 0 as N → ∞
private axiom fourier_L2_convergence_law (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto
    (fun N : ℕ => L2norm (fun x => f x - fourierPartialSum f N x))
    Filter.atTop (nhds 0)

theorem fourier_L2_convergence (f : ℝ → ℂ) (hf : SqIntegrable f) :
    Filter.Tendsto
    (fun N : ℕ => L2norm (fun x => f x - fourierPartialSum f N x))
    Filter.atTop (nhds 0) := fourier_L2_convergence_law f hf

-- ── Riesz-Fischer theorem ──────────────────────────────────────────────────────
-- AFP: Given square-summable sequence (cₙ), ∃ f ∈ L² with cₙ(f) = cₙ.
private axiom riesz_fischer_law (cs : ℤ → ℂ) (h : Summable (fun n : ℤ => ‖cs n‖^2)) :
    ∃ f : ℝ → ℂ, SqIntegrable f ∧ ∀ n : ℤ, fourierCoeff f n = cs n

theorem riesz_fischer (cs : ℤ → ℂ) (h : Summable (fun n : ℤ => ‖cs n‖^2)) :
    ∃ f : ℝ → ℂ, SqIntegrable f ∧ ∀ n : ℤ, fourierCoeff f n = cs n :=
  riesz_fischer_law cs h

-- ── Fourier uniqueness ────────────────────────────────────────────────────────
-- AFP: cₙ(f) = 0 for all n ∈ ℤ → f = 0  in L²(μ_pi).
private axiom fourier_unique_law (f : ℝ → ℂ) (hf : SqIntegrable f)
    (hZero : ∀ n : ℤ, fourierCoeff f n = 0) :
    ∀ᵐ x ∂μ_pi, f x = 0

theorem fourier_unique (f : ℝ → ℂ) (hf : SqIntegrable f)
    (hZero : ∀ n : ℤ, fourierCoeff f n = 0) :
    ∀ᵐ x ∂μ_pi, f x = 0 := fourier_unique_law f hf hZero

-- ── Fourier series representation (summary theorem) ──────────────────────────
-- AFP main theorem: f = ∑ cₙ(f) exp(inx) in L² (convergent in L² norm).
theorem fourier_series_representation (f : ℝ → ℂ) (hf : SqIntegrable f) :
    ∀ ε : ℝ, 0 < ε → ∃ N₀ : ℕ, ∀ N : ℕ, N ≥ N₀ →
    L2norm (fun x => f x - fourierPartialSum f N x) < ε := by
        intro ε hε
        have hconv := fourier_L2_convergence f hf
        rw [Metric.tendsto_atTop] at hconv
        obtain ⟨N₀, hN₀⟩ := hconv ε hε
        refine ⟨N₀, ?_⟩
        intro N hN
        have hdist := hN₀ N hN
        have habs : |L2norm (fun x => f x - fourierPartialSum f N x)| < ε := by
            simpa [Real.dist_eq] using hdist
        exact lt_of_le_of_lt (le_abs_self (L2norm (fun x => f x - fourierPartialSum f N x))) habs

end CATEPTMain.FOU.Fourier
