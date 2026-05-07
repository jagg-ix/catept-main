import CATEPTMain.Integration.SpectralSumPartition
import Mathlib.Analysis.Normed.Ring.InfiniteSum
import Mathlib.Algebra.BigOperators.Pi

/-!
# T³ Spectral Sum Partition (T-FF Phase 21)

Extends the 1-D scaffolding of P19 to a genuine three-dimensional
Stokes-spectral cutoff partition modelling the positive Fourier
cone of the 3-torus `T³`. The eigenvalues are
`λ_k = k₁² + k₂² + k₃²` for `k = (k₁, k₂, k₃) ∈ ℕ³`, and the
spectral term factorizes as

  `exp(-λ_k) = exp(-k₁²) · exp(-k₂²) · exp(-k₃²)`,

so the cube cutoff `|k|_∞ ≤ N` produces a partition that is the
**third power** of the 1-D partition:

  `Z_N^{T³} = (Z_N)³`,  `Z_∞^{T³} = (Z_∞)³`.

## Mathematical content

* **Factorization** of `spectralTerm3D` into three 1-D factors.
* **Summability** via `Summable.mul_of_nonneg` applied twice.
* **Cube-cutoff factorization**:
  `Z_N_3D N = (Z_N N)^3`, by `Finset.sum` over a triple product
  of `range`.
* **Continuum value factorization**:
  `Z_inf_3D = Z_inf ^ 3`, via `Summable.tsum_mul_tsum`.
* **Continuum convergence**:
  `Tendsto Z_N_3D atTop (𝓝 Z_inf_3D)`, derived from the 1-D case
  by composing with `(·)^3` continuity / monotonicity.

## Honest scope

* This treats only the **positive cone** `ℕ³` of the T³ Fourier
  lattice, not the bilateral lattice `ℤ³`. The structural
  product factorization is identical; the bilateral case
  introduces only finite combinatorial bookkeeping (`8` octants),
  deferred to a future ship.
* The **PhysicalEntropicModel instantiation** for the 3-D case
  is performed in P22 (where the explicit tail bound is also
  produced).
* The **Poisson-summation tail bound** — providing a sharper
  asymptotic than the `(k+N)² ≥ k² + N²` estimate used here —
  is also deferred to P22.

## Output

* `spectralTerm3D : ℕ × ℕ × ℕ → ℝ`.
* `Z_N_3D : ℕ → ℝ`,  `Z_inf_3D : ℝ`.
* `summable_spectralTerm3D : Summable spectralTerm3D`.
* `Z_N_3D_eq_Z_N_pow : Z_N_3D N = (Z_N N)^3`.
* `Z_inf_3D_eq_Z_inf_pow : Z_inf_3D = Z_inf^3`.
* `tendsto_Z_N_3D_atTop_Z_inf_3D`.
* `Z_inf_3D_pos`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.T3SpectralPartition

open CATEPTMain.Integration.SpectralSumPartition
open Filter Topology Real Finset

noncomputable section

/-- Stokes spectral term on the positive Fourier cone of `T³`,
`exp(-(k₁² + k₂² + k₃²))`. -/
def spectralTerm3D (k : ℕ × ℕ × ℕ) : ℝ :=
  Real.exp (-(((k.1 : ℝ))^2 + ((k.2.1 : ℝ))^2 + ((k.2.2 : ℝ))^2))

/-- Term-level factorization of the 3-D spectral term as a
triple product of the 1-D spectral term. -/
lemma spectralTerm3D_factor (k : ℕ × ℕ × ℕ) :
    spectralTerm3D k
      = spectralTerm k.1 * spectralTerm k.2.1 * spectralTerm k.2.2 := by
  unfold spectralTerm3D spectralTerm
  rw [show (-((k.1 : ℝ)^2 + (k.2.1 : ℝ)^2 + (k.2.2 : ℝ)^2))
        = (-((k.1 : ℝ)^2)) + (-((k.2.1 : ℝ)^2)) + (-((k.2.2 : ℝ)^2)) by ring]
  rw [Real.exp_add, Real.exp_add]

lemma spectralTerm3D_nonneg (k : ℕ × ℕ × ℕ) : 0 ≤ spectralTerm3D k :=
  (Real.exp_pos _).le

/-- Auxiliary: pair product `spectralTerm k.1 * spectralTerm k.2`
is summable over `ℕ × ℕ`. -/
lemma summable_spectralTerm_pair :
    Summable (fun k : ℕ × ℕ => spectralTerm k.1 * spectralTerm k.2) :=
  summable_spectralTerm.mul_of_nonneg summable_spectralTerm
    spectralTerm_nonneg spectralTerm_nonneg

/-- Auxiliary: triple-factor product is summable over `ℕ × ℕ × ℕ`. -/
lemma summable_spectralTerm_triple :
    Summable (fun k : ℕ × ℕ × ℕ =>
      spectralTerm k.1 * spectralTerm k.2.1 * spectralTerm k.2.2) := by
  -- Factor as `f x.1 * g x.2` where `g (k₂,k₃) = T k₂ * T k₃`.
  have hpair := summable_spectralTerm_pair
  have h := summable_spectralTerm.mul_of_nonneg hpair
    spectralTerm_nonneg
    (fun p : ℕ × ℕ => mul_nonneg (spectralTerm_nonneg _) (spectralTerm_nonneg _))
  -- Rewrite `(spectralTerm k.1) * (spectralTerm k.2.1 * spectralTerm k.2.2)`
  -- to the desired left-associated form.
  refine h.congr (fun k => ?_)
  ring

/-- **Summability of the 3-D spectral series.** -/
theorem summable_spectralTerm3D : Summable spectralTerm3D :=
  summable_spectralTerm_triple.congr (fun k => (spectralTerm3D_factor k).symm)

/-- 3-D cube cutoff partition
`Z_N^{T³} := ∑_{k ∈ range N × range N × range N} exp(-(k₁²+k₂²+k₃²))`. -/
def Z_N_3D (N : ℕ) : ℝ :=
  ∑ k ∈ (range N ×ˢ range N ×ˢ range N), spectralTerm3D k

/-- 3-D continuum partition `Z_∞^{T³} := ∑'_k exp(-(k₁²+k₂²+k₃²))`. -/
def Z_inf_3D : ℝ := ∑' k, spectralTerm3D k

/-- The 3-D cube sum re-expressed as an iterated 1-D sum. -/
private lemma Z_N_3D_eq_iterated (N : ℕ) :
    Z_N_3D N = ∑ k₁ ∈ range N, ∑ k₂ ∈ range N, ∑ k₃ ∈ range N,
        spectralTerm k₁ * spectralTerm k₂ * spectralTerm k₃ := by
  unfold Z_N_3D
  rw [show (∑ k ∈ range N ×ˢ range N ×ˢ range N, spectralTerm3D k)
        = ∑ k ∈ range N ×ˢ range N ×ˢ range N,
            spectralTerm k.1 * spectralTerm k.2.1 * spectralTerm k.2.2
      from Finset.sum_congr rfl (fun k _ => spectralTerm3D_factor k)]
  rw [Finset.sum_product]
  apply Finset.sum_congr rfl; intro k₁ _
  rw [Finset.sum_product]

/-- The cube of the 1-D cutoff re-expressed as an iterated 1-D sum. -/
private lemma Z_N_pow_three_eq_iterated (N : ℕ) :
    (Z_N N)^3 = ∑ k₁ ∈ range N, ∑ k₂ ∈ range N, ∑ k₃ ∈ range N,
        spectralTerm k₁ * spectralTerm k₂ * spectralTerm k₃ := by
  unfold Z_N
  rw [pow_three']
  rw [Finset.sum_mul_sum]
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl; intro k₁ _
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl; intro k₂ _
  rw [Finset.mul_sum]

/-- **Factorization of the cube cutoff** as the third power of
the 1-D cutoff. -/
theorem Z_N_3D_eq_Z_N_pow (N : ℕ) : Z_N_3D N = (Z_N N)^3 := by
  rw [Z_N_3D_eq_iterated, Z_N_pow_three_eq_iterated]

/-- **Factorization of the continuum value** as the third power
of the 1-D continuum value. -/
theorem Z_inf_3D_eq_Z_inf_pow : Z_inf_3D = Z_inf^3 := by
  unfold Z_inf_3D Z_inf
  -- First rewrite spectralTerm3D as the triple product.
  have hcongr : ∑' k : ℕ × ℕ × ℕ, spectralTerm3D k
      = ∑' k : ℕ × ℕ × ℕ,
          spectralTerm k.1 * spectralTerm k.2.1 * spectralTerm k.2.2 :=
    tsum_congr (fun k => spectralTerm3D_factor k)
  rw [hcongr]
  -- Compute via two applications of `Summable.tsum_mul_tsum`.
  -- Step 1 (inner): ∑'_(k₂,k₃), T k₂ * T k₃ = (∑' T) * (∑' T) = Z_∞².
  have h_inner : (∑' p : ℕ × ℕ, spectralTerm p.1 * spectralTerm p.2)
      = (∑' k, spectralTerm k) * (∑' k, spectralTerm k) :=
    (summable_spectralTerm.tsum_mul_tsum summable_spectralTerm
      summable_spectralTerm_pair).symm
  -- Step 2 (outer): ∑'_(k₁, p), T k₁ * (T p.1 * T p.2) factor.
  have h_outer :
      (∑' k : ℕ × ℕ × ℕ,
          spectralTerm k.1 * (spectralTerm k.2.1 * spectralTerm k.2.2))
        = (∑' k₁, spectralTerm k₁)
            * (∑' p : ℕ × ℕ, spectralTerm p.1 * spectralTerm p.2) :=
    (summable_spectralTerm.tsum_mul_tsum summable_spectralTerm_pair
      (summable_spectralTerm_triple.congr (fun k => by ring))).symm
  -- Reassociate the triple product so it matches `h_outer`.
  have hreassoc : (∑' k : ℕ × ℕ × ℕ,
        spectralTerm k.1 * spectralTerm k.2.1 * spectralTerm k.2.2)
      = ∑' k : ℕ × ℕ × ℕ,
          spectralTerm k.1 * (spectralTerm k.2.1 * spectralTerm k.2.2) :=
    tsum_congr (fun k => by ring)
  rw [hreassoc, h_outer, h_inner]
  ring

/-- The 3-D continuum partition is strictly positive. -/
theorem Z_inf_3D_pos : 0 < Z_inf_3D := by
  rw [Z_inf_3D_eq_Z_inf_pow]
  exact pow_pos Z_inf_pos 3

/-- **Continuum convergence (3-D)**: the cube-cutoff partition
tends to `Z_∞^{T³}` as the cutoff `N → ∞`. -/
theorem tendsto_Z_N_3D_atTop_Z_inf_3D :
    Tendsto Z_N_3D atTop (𝓝 Z_inf_3D) := by
  have h1 : Tendsto Z_N atTop (𝓝 Z_inf) := tendsto_Z_N_atTop_Z_inf
  have h3 : Tendsto (fun N => (Z_N N)^3) atTop (𝓝 (Z_inf^3)) :=
    (h1.pow 3)
  have hZN_eq : Z_N_3D = fun N => (Z_N N)^3 := by
    funext N; exact Z_N_3D_eq_Z_N_pow N
  rw [hZN_eq, Z_inf_3D_eq_Z_inf_pow]
  exact h3

end

end CATEPTMain.Integration.T3SpectralPartition
