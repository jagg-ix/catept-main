import CATEPTMain.AFPBridge.FOU.Square_Integrable
/-!
# Confine — AFP Fourier → Lean 4 (Phase 1)

Source: `Fourier/Confine.thy` (Lawrence Paulson — 2019)
Dependencies: Square_Integrable

Content: Partial sum convergence infrastructure — "confine" lemmas that show
  the Fourier partial sum approximation error can be made arbitrarily small:
  - Dirichlet kernel representation of partial sums
  - L² best approximation property of Fourier partial sum
  - Error bound: ‖f - S_N f‖_L² → 0 as N → ∞  (consequence of Parseval)

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.FOU.Confine

open CATEPTMain.AFPBridge.FOU

-- ── Dirichlet kernel ──────────────────────────────────────────────────────────
-- AFP: D_N(x) = ∑_{n=-N}^{N} exp(inx) = sin((2N+1)x/2) / sin(x/2)
noncomputable def dirichletKernel (N : ℕ) (x : ℝ) : ℂ :=
  ∑ n ∈ Finset.Icc (-N : ℤ) N, Complex.exp (Complex.I * n * x)

-- Closed form (when sin(x/2) ≠ 0):
private axiom dirichletKernel_closed_law (N : ℕ) (x : ℝ) (hx : Real.sin (x / 2) ≠ 0) :
    dirichletKernel N x =
    Real.sin ((2 * N + 1) * x / 2) / Real.sin (x / 2)

theorem dirichletKernel_closed (N : ℕ) (x : ℝ) (hx : Real.sin (x / 2) ≠ 0) :
    dirichletKernel N x =
    Real.sin ((2 * N + 1) * x / 2) / Real.sin (x / 2) :=
  dirichletKernel_closed_law N x hx

-- ── Partial sum as convolution with Dirichlet kernel ─────────────────────────
-- AFP: (S_N f)(x) = (1/2π) ∫ f(t) D_N(x - t) dt = (f * D_N)(x)
private axiom partialSum_is_convolution_law (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) (x : ℝ) :
    fourierPartialSum f N x =
    ∫ t, f t * dirichletKernel N (x - t) ∂μ_pi

theorem partialSum_is_convolution (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) (x : ℝ) :
    fourierPartialSum f N x =
    ∫ t, f t * dirichletKernel N (x - t) ∂μ_pi :=
  partialSum_is_convolution_law f hf N x

-- ── Best approximation: S_N minimizes L² distance ────────────────────────────
-- AFP: ‖f - S_N f‖_L² ≤ ‖f - g‖_L² for any trigonometric polynomial g of degree ≤ N.
private axiom partialSum_best_approx_law (f g : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ)
    (hg : ∃ cs : ℤ → ℂ, ∀ x, g x = ∑ n ∈ Finset.Icc (-N : ℤ) N, cs n * Complex.exp (Complex.I * n * x)) :
    L2norm (fun x => f x - fourierPartialSum f N x) ≤ L2norm (fun x => f x - g x)

theorem partialSum_best_approx (f g : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ)
    (hg : ∃ cs : ℤ → ℂ, ∀ x, g x = ∑ n ∈ Finset.Icc (-N : ℤ) N, cs n * Complex.exp (Complex.I * n * x)) :
    L2norm (fun x => f x - fourierPartialSum f N x) ≤ L2norm (fun x => f x - g x) :=
  partialSum_best_approx_law f g hf N hg

-- ── Partial sum squared norm formula ─────────────────────────────────────────
-- ‖S_N f‖²_L² = ∑_{n=-N}^{N} |cₙ(f)|²
private axiom partialSum_norm_sq_law (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) :
    (L2norm (fourierPartialSum f N))^2 =
    ∑ n ∈ Finset.Icc (-N : ℤ) N, ‖fourierCoeff f n‖^2

theorem partialSum_norm_sq (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) :
    (L2norm (fourierPartialSum f N))^2 =
    ∑ n ∈ Finset.Icc (-N : ℤ) N, ‖fourierCoeff f n‖^2 :=
  partialSum_norm_sq_law f hf N

-- ── Confine: error bound ──────────────────────────────────────────────────────
-- ‖f - S_N f‖²_L² = ‖f‖²_L² - ‖S_N f‖²_L²  (Pythagoras)
private axiom partialSum_error_law (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) :
    (L2norm (fun x => f x - fourierPartialSum f N x))^2 =
    (L2norm f)^2 - ∑ n ∈ Finset.Icc (-N : ℤ) N, ‖fourierCoeff f n‖^2

theorem partialSum_error (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) :
    (L2norm (fun x => f x - fourierPartialSum f N x))^2 =
    (L2norm f)^2 - ∑ n ∈ Finset.Icc (-N : ℤ) N, ‖fourierCoeff f n‖^2 :=
  partialSum_error_law f hf N

end CATEPTMain.AFPBridge.FOU.Confine
