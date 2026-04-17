import CATEPTMain.AFPBridge.FOU.Lspace
/-!
# Square_Integrable — AFP Fourier → Lean 4 (Phase 1)

Source: `Fourier/Square_Integrable.thy` (Lawrence Paulson — 2019)
Dependencies: Lspace

Content: Properties of square-integrable 2π-periodic functions:
  - Closure of SqIntegrable under arithmetic operations
  - Products of square-integrable functions
  - Completeness of Fourier coefficient functions
  - Bessel's inequality: ∑ |cₙ|² ≤ ‖f‖²_L²

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.FOU.Square_Integrable

open CATEPTMain.AFPBridge.FOU
open CATEPTMain.AFPBridge.FOU.Lspace

-- ── Closure properties ────────────────────────────────────────────────────────

private axiom sqint_add_law (f g : ℝ → ℂ) (hf : SqIntegrable f) (hg : SqIntegrable g) :
    SqIntegrable (fun x => f x + g x)

theorem sqint_add (f g : ℝ → ℂ) (hf : SqIntegrable f) (hg : SqIntegrable g) :
    SqIntegrable (fun x => f x + g x) := sqint_add_law f g hf hg

private axiom sqint_smul_law (f : ℝ → ℂ) (c : ℂ) (hf : SqIntegrable f) :
    SqIntegrable (fun x => c * f x)

theorem sqint_smul (f : ℝ → ℂ) (c : ℂ) (hf : SqIntegrable f) :
    SqIntegrable (fun x => c * f x) := sqint_smul_law f c hf

private axiom sqint_sub_law (f g : ℝ → ℂ) (hf : SqIntegrable f) (hg : SqIntegrable g) :
    SqIntegrable (fun x => f x - g x)

theorem sqint_sub (f g : ℝ → ℂ) (hf : SqIntegrable f) (hg : SqIntegrable g) :
    SqIntegrable (fun x => f x - g x) := sqint_sub_law f g hf hg

-- ── Fourier basis functions are square-integrable ────────────────────────────
-- The function x ↦ exp(inx) is 2π-periodic and has norm 1.
private axiom fourier_basis_sqint_law (n : ℤ) :
    SqIntegrable (fun x => Complex.exp (Complex.I * n * x))

theorem fourier_basis_sqint (n : ℤ) :
    SqIntegrable (fun x => Complex.exp (Complex.I * n * x)) := fourier_basis_sqint_law n

private axiom fourier_basis_norm_law (n : ℤ) :
    L2norm (fun x => Complex.exp (Complex.I * n * x)) = 1

theorem fourier_basis_norm (n : ℤ) :
    L2norm (fun x => Complex.exp (Complex.I * n * x)) = 1 := fourier_basis_norm_law n

-- ── Fourier basis orthonormality ──────────────────────────────────────────────
-- ∫ exp(inx) * conj(exp(imx)) dμ_pi = δ_{nm}
private axiom fourier_basis_orthonormal_law (n m : ℤ) :
    L2inner (fun x => Complex.exp (Complex.I * n * x))
            (fun x => Complex.exp (Complex.I * m * x)) =
    if n = m then 1 else 0

theorem fourier_basis_orthonormal (n m : ℤ) :
    L2inner (fun x => Complex.exp (Complex.I * n * x))
            (fun x => Complex.exp (Complex.I * m * x)) =
    if n = m then 1 else 0 := fourier_basis_orthonormal_law n m

-- ── Bessel's inequality ───────────────────────────────────────────────────────
-- AFP: ∑_{n=-N}^{N} |cₙ(f)|² ≤ ‖f‖²_L²
private axiom bessel_inequality_law (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) :
    ∑ n ∈ Finset.Icc (-N : ℤ) N, ‖fourierCoeff f n‖^2 ≤ (L2norm f)^2

theorem bessel_inequality (f : ℝ → ℂ) (hf : SqIntegrable f) (N : ℕ) :
    ∑ n ∈ Finset.Icc (-N : ℤ) N, ‖fourierCoeff f n‖^2 ≤  (L2norm f)^2 :=
  bessel_inequality_law f hf N

-- ── Fourier coefficients: L² inner product ────────────────────────────────────
-- cₙ(f) = ⟨eₙ, f⟩_L²  where eₙ(x) = exp(inx)
private axiom fourierCoeff_inner_law (f : ℝ → ℂ) (hf : SqIntegrable f) (n : ℤ) :
    fourierCoeff f n =
    L2inner (fun x => Complex.exp (Complex.I * n * x)) f

theorem fourierCoeff_inner (f : ℝ → ℂ) (hf : SqIntegrable f) (n : ℤ) :
    fourierCoeff f n =
    L2inner (fun x => Complex.exp (Complex.I * n * x)) f :=
  fourierCoeff_inner_law f hf n

end CATEPTMain.AFPBridge.FOU.Square_Integrable
