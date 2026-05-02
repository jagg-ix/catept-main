import CATEPTMain.Integration.CanonicalEntropicModel

/-!
# Stokes-Spectral Concrete `PhysicalEntropicModel` (T-FF Phase 17)

Refines the Phase-16 `canonicalModel` by promoting the
Stokes spectral exponent `α = 2` from a *passive tag* on
`StokesSpectralGrowth.spectralExponent` to an *active
quadratic law* in the cutoff partition itself:

  `Z_N := Real.exp (-((N : ℝ)^2))`,  `Z_∞ := 0`.

This realizes the spectral pattern `λ_k ~ |k|^2` at the
level of the cutoff residual: the dominant mode at level
`N` decays like `exp(-N^2)`. The exponential tail bound
`|Z_N − 0| ≤ exp(-(C · N))` then holds with `C := 1` because
`(N : ℝ)^2 ≥ (N : ℝ)` for every `N : ℕ` (equality at
`N ∈ {0, 1}`, strict for `N ≥ 2`).

Items shipped:

* `stokesCutoff : CutoffFamily` with `Z_N := exp(-N^2)`.
* `stokesModel : PhysicalEntropicModel` (with `C := 1`,
  `α := 2`).
* Six kernel-only theorems:
  - `stokesModel_C_eq_one`
  - `stokesModel_alpha_eq_two`
  - `stokesModel_Z_inf_eq_zero`
  - `stokesModel_Z_N_eq` — closed-form `exp(-N^2)`
  - `stokesCertificate_strength_eq_one`
  - `stokesCertificate_no_counterterm_needed`

Honest scope: still a canonical placeholder — `λ_k ~ |k|^2`
on `T^3` is encoded only through the `N^2` exponent of the
*scalar partition residual*, not through a genuine spectral
sum on `L^2(T^3)`. A genuine derivation would replace
`Z_N := ∑_{|k| ≤ N} exp(-|k|^2 t)` and bound the tail via
the Poisson summation / `Real.tsum`. That refinement remains
an external mathematical obligation.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.StokesEntropicModel

open CATEPTMain.Integration.PhysicalUVConvergenceCertificate
open CATEPTMain.Integration.CanonicalEntropicModel
open Filter Topology

noncomputable section

/-- Stokes-spectral cutoff family: `Z_N := exp(-N^2)`,
`Z_∞ := 0`. The quadratic exponent reflects `λ_k ~ |k|^2`. -/
def stokesCutoff : CutoffFamily where
  Z_N := fun N : ℕ => Real.exp (-((N : ℝ) ^ 2))
  Z_inf := 0

/-- For every `N : ℕ`, `(N : ℝ) ≤ (N : ℝ) ^ 2`, with equality
at `N ∈ {0, 1}`. -/
private theorem nat_le_sq (N : ℕ) : (N : ℝ) ≤ (N : ℝ) ^ 2 := by
  rcases Nat.eq_zero_or_pos N with hN | hN
  · subst hN; simp
  · -- N ≥ 1, so (N : ℝ) ≥ 1 and (N : ℝ)^2 = (N : ℝ) * (N : ℝ) ≥ (N : ℝ) * 1
    have h1 : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
    have hpos : (0 : ℝ) ≤ (N : ℝ) := by exact_mod_cast Nat.zero_le N
    have : (N : ℝ) * 1 ≤ (N : ℝ) * (N : ℝ) :=
      mul_le_mul_of_nonneg_left h1 hpos
    simpa [pow_two, mul_one] using this

/-- Per-`N` tail bound: `|exp(-N^2) − 0| ≤ exp(-(1 · N))`. -/
private theorem stokes_tail_bound (N : ℕ) :
    |stokesCutoff.Z_N N - stokesCutoff.Z_inf|
      ≤ Real.exp (-(canonicalCoercivity.C * (N : ℝ))) := by
  show |Real.exp (-((N : ℝ) ^ 2)) - 0|
      ≤ Real.exp (-(1 * (N : ℝ)))
  have hpos : 0 ≤ Real.exp (-((N : ℝ) ^ 2)) := (Real.exp_pos _).le
  rw [sub_zero, abs_of_nonneg hpos, one_mul]
  -- Goal: exp(-N^2) ≤ exp(-N)
  have hle : -((N : ℝ) ^ 2) ≤ -(N : ℝ) := by
    have := nat_le_sq N
    linarith
  exact Real.exp_le_exp.mpr hle

/-- Continuum convergence: `exp(-N^2) → 0` as `N → ∞`. -/
private theorem tendsto_stokes_Z_N :
    Tendsto stokesCutoff.Z_N atTop (𝓝 stokesCutoff.Z_inf) := by
  -- Use monotonicity: -N^2 ≤ -N → -∞, then compose with exp.
  have hN : Tendsto (fun N : ℕ => (N : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop
  have hNegN : Tendsto (fun N : ℕ => -(N : ℝ)) atTop atBot :=
    Filter.tendsto_neg_atTop_atBot.comp hN
  have hNegSq : Tendsto (fun N : ℕ => -((N : ℝ) ^ 2)) atTop atBot := by
    refine tendsto_atBot_mono (fun N => ?_) hNegN
    have := nat_le_sq N
    linarith
  exact Real.tendsto_exp_atBot.comp hNegSq

/-- **Stokes-spectral concrete `PhysicalEntropicModel`**:
canonical `C = 1`, `α = 2`, with `Z_N := exp(-N^2)` reflecting
`λ_k ~ |k|^2` directly in the cutoff law. -/
def stokesModel : PhysicalEntropicModel where
  cutoff := stokesCutoff
  coercivity := canonicalCoercivity
  spectral := canonicalSpectral
  exponentialTailBound := stokes_tail_bound
  tendsToContinuum := tendsto_stokes_Z_N

/-- Coercivity constant `C = 1`. -/
theorem stokesModel_C_eq_one :
    stokesModel.coercivity.C = 1 := rfl

/-- Stokes spectral exponent `α = 2`. -/
theorem stokesModel_alpha_eq_two :
    stokesModel.spectral.spectralExponent = 2 := rfl

/-- Continuum partition `Z_∞ = 0`. -/
theorem stokesModel_Z_inf_eq_zero :
    stokesModel.cutoff.Z_inf = 0 := rfl

/-- Closed form of the cutoff partition: `Z_N = exp(-N^2)`. -/
theorem stokesModel_Z_N_eq (N : ℕ) :
    stokesModel.cutoff.Z_N N = Real.exp (-((N : ℝ) ^ 2)) := rfl

/-- Stokes-spectral certificate. -/
def stokesCertificate :
    CATEPTMain.CATEPT.CATEPT.UVConvergenceCertificate :=
  physical_uv_convergence_certificate stokesModel

/-- Certificate regularization strength is `1`. -/
theorem stokesCertificate_strength_eq_one :
    stokesCertificate.entropicRegStrength = 1 := rfl

/-- The Stokes certificate satisfies the Phase-9 / Phase-8
no-counterterm conjunction. -/
theorem stokesCertificate_no_counterterm_needed :
    Tendsto
        (CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate
            stokesCertificate).cutoffPartition
        atTop
        (𝓝 (CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate
            stokesCertificate).continuumPartition) ∧
      (CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate
          stokesCertificate).counterterm = 0 :=
  physical_uv_certificate_no_counterterm_needed stokesModel

end

end CATEPTMain.Integration.StokesEntropicModel
