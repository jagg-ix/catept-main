import CATEPTMain.Integration.SpectralSumPartition
import CATEPTMain.Integration.PhysicalUVConvergenceCertificate
import Mathlib.Topology.Algebra.InfiniteSum.Ring

/-!
# Real Spectral Physical Entropic Model (T-FF Phase 20)

This phase upgrades the P19 1-D spectral scaffolding to a
genuine instantiation of the Phase-15 abstract record
`PhysicalEntropicModel`, with an **explicit constructive
exponential tail bound** for the high-mode residual.

## Mathematical content

Starting from `Z_N := ∑_{k<N} exp(-k²)` and
`Z_∞ := ∑'_k exp(-k²)` (P19), we prove:

1. **Sum-of-squares dominance**: for `k, N : ℕ`,
   `(k + N)² ≥ k² + N²` (i.e. `2 k N ≥ 0`).
2. **Shifted-term factorization bound**:
   `exp(-(k+N)²) ≤ exp(-N²) · exp(-k²)`.
3. **Geometric-style tail bound** (compared with `Z_∞`):
   `∑'_k exp(-(k+N)²) ≤ exp(-N²) · Z_∞`.
4. **Quadratic ≥ linear on ℕ**: `exp(-N²) ≤ exp(-N)`.
5. Combining (3) and (4) and the P19 residual identity
   `Z_∞ - Z_N = ∑'_k exp(-(k+N)²)`:
   `|Z_∞ - Z_N| ≤ exp(-N) · Z_∞`.

Because `PhysicalEntropicModel` requires a tail bound of the
form `|Z_N - Z_∞| ≤ exp(-C·N)` with **no leading constant**,
we instantiate the model with the **normalized partition**

  `Z_N^norm := Z_N / Z_∞`,  `Z_∞^norm := 1`,

and `C := 1`, `α := 2`.  In normalized form

  `|Z_N^norm − 1| = |Z_N − Z_∞| / Z_∞ ≤ exp(-N)`,

discharging the abstract record.

## Output

* `realSpectralModel : PhysicalEntropicModel`
  — the first first-principles instantiation of
  `PhysicalEntropicModel` from a real, summable spectral
  series (no toy `Z_∞ = 0`).
* `realSpectralCertificate` — the resulting
  `UVConvergenceCertificate`.
* Six kernel-only audit theorems exposing the model's
  structural data.

## Honest scope

* This is the **1-D** integer Stokes-spectral lattice
  (`λ_k = k²`, `α = 2`); the 3-D torus extension is deferred
  to P21.
* The tail bound uses the elementary Cauchy-style estimate
  `(k+N)² ≥ k² + N²` rather than full Poisson summation;
  Poisson-summation tail bounds are deferred to P22.
* The values `C = 1` and `α = 2` here are **not** derived
  from a CAT/EPT lattice action but chosen to fit the bound
  proven above; lattice-action derivation is deferred to P23.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.RealSpectralEntropicModel

open CATEPTMain.Integration.SpectralSumPartition
open CATEPTMain.Integration.PhysicalUVConvergenceCertificate
open Filter Topology Real

noncomputable section

/-! ## Quadratic-form lemmas underpinning the tail bound. -/

/-- For `k, N : ℕ`, `(k + N : ℝ)^2 ≥ k^2 + N^2`. The
non-negative cross-term `2 · k · N` is dropped. -/
lemma sq_add_ge_add_sq (k N : ℕ) :
    ((k : ℝ))^2 + ((N : ℝ))^2 ≤ ((k : ℝ) + (N : ℝ))^2 := by
  have h : (0 : ℝ) ≤ 2 * (k : ℝ) * (N : ℝ) := by
    have hk : (0 : ℝ) ≤ (k : ℝ) := by exact_mod_cast Nat.zero_le k
    have hN : (0 : ℝ) ≤ (N : ℝ) := by exact_mod_cast Nat.zero_le N
    positivity
  nlinarith [h]

/-- **Shifted-term factorization**:
`exp(-(k+N)²) ≤ exp(-N²) · exp(-k²)`. -/
lemma spectralTerm_shift_le (k N : ℕ) :
    spectralTerm (k + N) ≤ Real.exp (-((N : ℝ)^2)) * spectralTerm k := by
  unfold spectralTerm
  have hkN : (((k + N : ℕ) : ℝ))^2 = ((k : ℝ) + (N : ℝ))^2 := by
    push_cast; ring
  rw [hkN]
  have hsum : ((k : ℝ))^2 + ((N : ℝ))^2 ≤ ((k : ℝ) + (N : ℝ))^2 :=
    sq_add_ge_add_sq k N
  have hexp_le : Real.exp (-(((k : ℝ) + (N : ℝ))^2))
      ≤ Real.exp (-(((k : ℝ))^2 + ((N : ℝ))^2)) := by
    apply Real.exp_le_exp.mpr
    linarith
  calc Real.exp (-(((k : ℝ) + (N : ℝ))^2))
      ≤ Real.exp (-(((k : ℝ))^2 + ((N : ℝ))^2)) := hexp_le
    _ = Real.exp (-((N : ℝ))^2) * Real.exp (-((k : ℝ))^2) := by
          rw [← Real.exp_add]; congr 1; ring
    _ = Real.exp (-((N : ℝ)^2)) * Real.exp (-((k : ℝ)^2)) := by ring

/-- The **tail summability** for any shift: shifted series is
summable since the unshifted series is summable. -/
lemma summable_shifted (N : ℕ) :
    Summable (fun k => spectralTerm (k + N)) :=
  summable_spectralTerm.comp_injective
    (fun _ _ h => Nat.add_right_cancel h)

/-- **Geometric-style tail bound**: the shifted-tsum is bounded
by `exp(-N²) · Z_∞`. -/
theorem tail_le_exp_neg_sq_mul_Z_inf (N : ℕ) :
    (∑' k, spectralTerm (k + N))
      ≤ Real.exp (-((N : ℝ)^2)) * Z_inf := by
  have hbound : ∀ k, spectralTerm (k + N)
        ≤ Real.exp (-((N : ℝ)^2)) * spectralTerm k :=
    fun k => spectralTerm_shift_le k N
  have hsum_majorant :
      Summable (fun k => Real.exp (-((N : ℝ)^2)) * spectralTerm k) :=
    summable_spectralTerm.mul_left _
  have hineq :
      (∑' k, spectralTerm (k + N))
        ≤ ∑' k, Real.exp (-((N : ℝ)^2)) * spectralTerm k :=
    (summable_shifted N).tsum_le_tsum hbound hsum_majorant
  have heq :
      (∑' k, Real.exp (-((N : ℝ)^2)) * spectralTerm k)
        = Real.exp (-((N : ℝ)^2)) * Z_inf := by
    unfold Z_inf
    exact tsum_mul_left
  linarith [hineq, heq]

/-- For `N : ℕ`, `exp(-N²) ≤ exp(-N)` since `N ≤ N²`. -/
lemma exp_neg_sq_le_exp_neg (N : ℕ) :
    Real.exp (-((N : ℝ)^2)) ≤ Real.exp (-(N : ℝ)) := by
  apply Real.exp_le_exp.mpr
  have h : (N : ℝ) ≤ ((N : ℝ))^2 := nat_le_sq N
  linarith

/-- **Geometric tail bound** in the canonical `exp(-N)` form
(absorbing the `exp(-N²)` factor into a weaker exponential): -/
theorem tail_le_exp_neg_mul_Z_inf (N : ℕ) :
    (∑' k, spectralTerm (k + N))
      ≤ Real.exp (-(N : ℝ)) * Z_inf :=
  (tail_le_exp_neg_sq_mul_Z_inf N).trans <| by
    have h₁ : Real.exp (-((N : ℝ)^2)) ≤ Real.exp (-(N : ℝ)) :=
      exp_neg_sq_le_exp_neg N
    have h₂ : (0 : ℝ) ≤ Z_inf := Z_inf_pos.le
    exact mul_le_mul_of_nonneg_right h₁ h₂

/-- **Absolute residual bound**: `|Z_N - Z_∞| ≤ exp(-N) · Z_∞`. -/
theorem abs_Z_N_sub_Z_inf_le (N : ℕ) :
    |Z_N N - Z_inf| ≤ Real.exp (-(N : ℝ)) * Z_inf := by
  have hres : Z_inf - Z_N N = ∑' k, spectralTerm (k + N) :=
    Z_inf_sub_Z_N_eq_tsum_shift N
  have hle : Z_N N ≤ Z_inf := Z_N_le_Z_inf N
  have habs : |Z_N N - Z_inf| = Z_inf - Z_N N := by
    rw [abs_sub_comm]; exact abs_of_nonneg (by linarith)
  rw [habs, hres]
  exact tail_le_exp_neg_mul_Z_inf N

/-! ## Normalized partition: `Z_N^norm := Z_N / Z_∞`. -/

/-- Normalized cutoff partition `Z_N^norm := Z_N / Z_∞`. -/
def normalizedZ_N (N : ℕ) : ℝ := Z_N N / Z_inf

/-- Normalized continuum value, equal to `1`. -/
def normalizedZ_inf : ℝ := 1

/-- `Z_∞^norm = Z_∞ / Z_∞`. -/
lemma normalizedZ_inf_eq_div : normalizedZ_inf = Z_inf / Z_inf := by
  unfold normalizedZ_inf
  rw [div_self Z_inf_pos.ne']

/-- **Normalized tail bound**: `|Z_N^norm - 1| ≤ exp(-N)`. -/
theorem abs_normalized_sub_one_le (N : ℕ) :
    |normalizedZ_N N - normalizedZ_inf| ≤ Real.exp (-(N : ℝ)) := by
  unfold normalizedZ_N normalizedZ_inf
  have hZpos : 0 < Z_inf := Z_inf_pos
  have hZne : Z_inf ≠ 0 := hZpos.ne'
  have hsubst : Z_N N / Z_inf - 1 = (Z_N N - Z_inf) / Z_inf := by
    field_simp
  rw [hsubst, abs_div, abs_of_pos hZpos]
  rw [div_le_iff₀ hZpos]
  exact abs_Z_N_sub_Z_inf_le N

/-- **Continuum convergence (normalized)**: the normalized
cutoff partition tends to `1`. -/
theorem tendsto_normalizedZ_N_atTop_one :
    Tendsto normalizedZ_N atTop (𝓝 normalizedZ_inf) := by
  unfold normalizedZ_N normalizedZ_inf
  have h := tendsto_Z_N_atTop_Z_inf
  have hZne : Z_inf ≠ 0 := Z_inf_pos.ne'
  have := h.div_const Z_inf
  simpa [div_self hZne] using this

/-! ## Instantiation as a `PhysicalEntropicModel`. -/

/-- Normalized cutoff family record. -/
def realCutoffFamily : CutoffFamily where
  Z_N := normalizedZ_N
  Z_inf := normalizedZ_inf

/-- Coercivity record with `C = 1`. -/
def realCoercivity : EntropicActionCoercive where
  C := 1
  C_pos := one_pos

/-- Stokes-spectral record with `α = 2`. -/
def realSpectralGrowth : StokesSpectralGrowth where
  spectralExponent := 2
  spectralExponent_pos := by norm_num

/-- **First-principles `PhysicalEntropicModel`** built from a
real summable Stokes-spectral series `∑'_k exp(-k²)`,
normalized so that `Z_∞ = 1`. -/
def realSpectralModel : PhysicalEntropicModel where
  cutoff := realCutoffFamily
  coercivity := realCoercivity
  spectral := realSpectralGrowth
  exponentialTailBound := by
    intro N
    show |normalizedZ_N N - normalizedZ_inf|
        ≤ Real.exp (-((1 : ℝ) * (N : ℝ)))
    have h := abs_normalized_sub_one_le N
    have hone : (1 : ℝ) * (N : ℝ) = (N : ℝ) := one_mul _
    rw [hone]
    exact h
  tendsToContinuum := tendsto_normalizedZ_N_atTop_one

/-- The real spectral UV convergence certificate. -/
def realSpectralCertificate :=
  physical_uv_convergence_certificate realSpectralModel

/-! ## Audit theorems. -/

/-- The model's coercivity constant is `1`. -/
theorem realSpectralModel_C_eq_one :
    realSpectralModel.coercivity.C = 1 := rfl

/-- The model's spectral exponent is `2`. -/
theorem realSpectralModel_alpha_eq_two :
    realSpectralModel.spectral.spectralExponent = 2 := rfl

/-- The normalized continuum value is `1` (not `0` as in the
toy P16/P17 models). -/
theorem realSpectralModel_Z_inf_eq_one :
    realSpectralModel.cutoff.Z_inf = 1 := rfl

/-- The normalized cutoff partition is `Z_N / Z_∞`. -/
theorem realSpectralModel_Z_N_eq (N : ℕ) :
    realSpectralModel.cutoff.Z_N N = Z_N N / Z_inf := rfl

/-- The certificate's regularization strength is `1`. -/
theorem realSpectralCertificate_strength_eq_one :
    realSpectralCertificate.entropicRegStrength = 1 := rfl

/-- The certificate requires no counterterm. -/
theorem realSpectralCertificate_no_counterterm_needed :
    Tendsto
        (CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate
            realSpectralCertificate).cutoffPartition
        atTop
        (𝓝 (CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate
            realSpectralCertificate).continuumPartition) ∧
      (CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate
          realSpectralCertificate).counterterm = 0 :=
  physical_uv_certificate_no_counterterm_needed realSpectralModel

end

end CATEPTMain.Integration.RealSpectralEntropicModel
