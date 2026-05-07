import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Topology.Algebra.InfiniteSum.NatInt

/-!
# Spectral Sum Partition (T-FF Phase 19)

Replaces the toy scalar partitions of P16/P17
(`Z_N := exp(-N)` and `Z_N := exp(-N²)`) with a genuine
1D Stokes-spectral lattice partial sum

  `Z_N := ∑_{k=0}^{N-1} exp(-k²)`,  `Z_∞ := ∑'_{k}  exp(-k²)`.

This is the first step of the substantive mathematical
program: a real spectral sum, real `tsum` continuum value,
real summability proof (by comparison with the geometric
series `(exp(-1))^k`), real continuum convergence
(via `HasSum.tendsto_sum_nat`), and a residual identity
for the high-mode tail expressed as a tsum of shifted terms
(via `Summable.sum_add_tsum_nat_add`).

Honest scope:

* This is the **1D integer** spectral sum with eigenvalues
  `λ_k = k²`; it is not yet a 3D torus sum on
  `T³` with `λ_k = |k|²` (deferred to a follow-up ship).
* The **fully constructive geometric tail bound**
  `|Z_∞ - Z_N| ≤ M · exp(-N)` with explicit `M` is also
  deferred — here we only establish the residual identity
  `Z_∞ - Z_N = ∑'_{k} exp(-(k+N)²)`, which is the analytic
  hook on which a future tail bound is built.
* No instantiation as a `PhysicalEntropicModel` is performed
  here. That step (along with the explicit Poisson-summation
  tail and the lattice-action derivation of `C` and `α`)
  remains external.

Exposed items:

* `spectralTerm`, `geomTerm` — the term sequences.
* `spectralTerm_nonneg`, `spectralTerm_le_geomTerm`.
* `summable_spectralTerm` — by comparison.
* `Z_N`, `Z_inf` — the cutoff and continuum partition.
* `tendsto_Z_N_atTop_Z_inf` — continuum convergence.
* `Z_N_le_Z_inf` — monotonicity / partial-sum bound.
* `Z_inf_pos` — strict positivity (since `spectralTerm 0 = 1`).
* `Z_inf_sub_Z_N_eq_tsum_shift` — the residual identity
  exposing the high-mode tail as a tsum of shifted terms.
* `spectralTerm_zero_eq_one`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SpectralSumPartition

open Filter Topology Real Finset

noncomputable section

/-- Stokes spectral term `exp(-k²)`. Eigenvalues `λ_k = k²`
correspond to the canonical `α = 2` Laplacian growth. -/
def spectralTerm (k : ℕ) : ℝ := Real.exp (-((k : ℝ)^2))

/-- Geometric majorant `exp(-k) = (exp(-1))^k`. -/
def geomTerm (k : ℕ) : ℝ := Real.exp (-(k : ℝ))

@[simp] lemma spectralTerm_zero_eq_one : spectralTerm 0 = 1 := by
  unfold spectralTerm; simp

lemma spectralTerm_nonneg (k : ℕ) : 0 ≤ spectralTerm k :=
  (Real.exp_pos _).le

lemma geomTerm_nonneg (k : ℕ) : 0 ≤ geomTerm k :=
  (Real.exp_pos _).le

/-- For `k : ℕ`, `(k : ℝ) ≤ (k : ℝ)^2`. Trivial at `k = 0`;
for `k ≥ 1`, multiply both sides by `k ≥ 1`. -/
lemma nat_le_sq (k : ℕ) : (k : ℝ) ≤ (k : ℝ)^2 := by
  rcases Nat.eq_zero_or_pos k with hk | hk
  · subst hk; simp
  · have h1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hpos : (0 : ℝ) ≤ (k : ℝ) := by exact_mod_cast Nat.zero_le k
    have : (1 : ℝ) * (k : ℝ) ≤ (k : ℝ) * (k : ℝ) :=
      mul_le_mul_of_nonneg_right h1 hpos
    have hsq : ((k : ℝ))^2 = (k : ℝ) * (k : ℝ) := by ring
    linarith [this, hsq]

/-- `exp(-k²) ≤ exp(-k)` for all `k : ℕ`. -/
lemma spectralTerm_le_geomTerm (k : ℕ) : spectralTerm k ≤ geomTerm k := by
  unfold spectralTerm geomTerm
  apply Real.exp_le_exp.mpr
  have : (k : ℝ) ≤ (k : ℝ)^2 := nat_le_sq k
  linarith

/-- `geomTerm k = (exp(-1))^k`. -/
lemma geomTerm_eq_pow (k : ℕ) : geomTerm k = Real.exp (-1) ^ k := by
  unfold geomTerm
  rw [← Real.exp_nat_mul]
  congr 1
  ring

lemma exp_neg_one_lt_one : Real.exp (-1) < 1 := by
  have h0 : Real.exp 0 = 1 := Real.exp_zero
  have : Real.exp (-1) < Real.exp 0 :=
    Real.exp_lt_exp.mpr (by norm_num)
  linarith [h0]

lemma exp_neg_one_nonneg : 0 ≤ Real.exp (-1) :=
  (Real.exp_pos _).le

/-- The geometric majorant series is summable. -/
lemma summable_geomTerm : Summable geomTerm := by
  have h : Summable (fun k : ℕ => Real.exp (-1) ^ k) :=
    summable_geometric_of_lt_one exp_neg_one_nonneg exp_neg_one_lt_one
  refine h.congr (fun k => ?_)
  exact (geomTerm_eq_pow k).symm

/-- The Stokes spectral series is summable: a real, proven
fact obtained by comparison `exp(-k²) ≤ exp(-k)` against
the geometric series. -/
theorem summable_spectralTerm : Summable spectralTerm :=
  summable_geomTerm.of_nonneg_of_le spectralTerm_nonneg
    spectralTerm_le_geomTerm

/-- **Cutoff partition** `Z_N := ∑_{k<N} exp(-k²)`. -/
def Z_N (N : ℕ) : ℝ := ∑ k ∈ range N, spectralTerm k

/-- **Continuum partition** `Z_∞ := ∑'_k exp(-k²)`. -/
def Z_inf : ℝ := ∑' k, spectralTerm k

/-- The cutoff partition tends to the continuum partition.
This is the genuine analytic continuum convergence of the
real spectral sum, replacing the trivial reflexivity of the
toy P16/P17 cutoffs. -/
theorem tendsto_Z_N_atTop_Z_inf :
    Tendsto Z_N atTop (𝓝 Z_inf) :=
  summable_spectralTerm.hasSum.tendsto_sum_nat

/-- The cutoff partition is bounded above by the continuum
partition (monotonicity / partial sum ≤ tsum). -/
theorem Z_N_le_Z_inf (N : ℕ) : Z_N N ≤ Z_inf :=
  sum_le_hasSum (range N) (fun k _ => spectralTerm_nonneg k)
    summable_spectralTerm.hasSum

/-- The continuum partition is strictly positive: it is
bounded below by `Z_N 1 = spectralTerm 0 = 1`. -/
theorem Z_inf_pos : 0 < Z_inf := by
  have h1 : (1 : ℝ) = Z_N 1 := by
    unfold Z_N
    simp [spectralTerm_zero_eq_one]
  have h2 : Z_N 1 ≤ Z_inf := Z_N_le_Z_inf 1
  linarith

/-- **Residual identity**: the high-mode tail
`Z_∞ - Z_N` equals the tsum of shifted terms
`∑'_k exp(-(k+N)²)`. This is the analytic hook on which a
future explicit geometric tail bound will be built. -/
theorem Z_inf_sub_Z_N_eq_tsum_shift (N : ℕ) :
    Z_inf - Z_N N = ∑' k, spectralTerm (k + N) := by
  have h := summable_spectralTerm.sum_add_tsum_nat_add (k := N)
  unfold Z_inf Z_N
  linarith [h]

end

end CATEPTMain.Integration.SpectralSumPartition
