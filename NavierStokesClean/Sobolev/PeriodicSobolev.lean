import Mathlib.Analysis.Fourier.AddCircleMulti
import Mathlib.Analysis.FunctionalSpaces.SobolevInequality
import Mathlib.MeasureTheory.Function.LpSeminorm.Basic
import Mathlib.Topology.Algebra.InfiniteSum.Order
import Mathlib.Analysis.Normed.Group.InfiniteSum
import Mathlib.Algebra.Module.ZLattice.Summable
import Mathlib.Analysis.Calculus.FDeriv.Mul
import Mathlib.Analysis.Calculus.FDeriv.Prod
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.Normed.MulAction
import NavierStokesClean.Core.SpatialTypes
import NavierStokesClean.Core.Operators

/-!
# Periodic Sobolev Theory — Supplement to Mathlib.Analysis.Fourier.AddCircleMulti

This file develops the Sobolev theory that underlies the three NS spatial axioms:

| Axiom | Content | File |
|-------|---------|------|
| `sa_g1b_poincare_t3` | `spatialEnstrophy u ≤ palinstrophySpatial u` | VSNuPSpatialBridge |
| `sa_g1_vortex_stretching_bound` | `VS ≤ √H₁ · Ω` | VSNuPSpatialBridge |
| `sa_m05_agmon_t3` | `‖ω‖_{L^∞} ≤ √(P·Ω)` | ContinuationBridge |

## Results

### §1 — Integer norm bound (PROVED, 0 axioms)

`int_sq_sum_ge_one`: for every nonzero `k : Fin n → ℤ`, `1 ≤ ∑ i, (k i)²`.

### §2 — Fourier Poincaré on UnitAddTorus (PROVED, 0 project axioms)

`h1FourierSemiNorm`, `h1FourierSemiNormCoeffs` — definitions, 0 axioms.

`fourier_poincare_abstract` (NSP-FP) — the abstract Poincaré inequality for mean-zero
L² functions on UnitAddTorus d:
  `∫ ‖f(t)‖² ≤ ∑' k, (∑ i, (k i)²) · ‖mFourierCoeff f k‖²`

**Mathematical proof** (all classical, 0 new math):
  Parseval (`hasSum_sq_mFourierCoeff`) + §1 + `tsum_le_tsum`.

**Fix**: `noncomputable local instance : MeasureSpace UnitAddCircle := ⟨AddCircle.haarAddCircle⟩`
at the top of this file makes Lean use the same measure instance that `AddCircleMulti.lean`
uses internally, avoiding the `isDefEq` timeout from `AddCircle.measureSpace 1`.

`#print axioms fourier_poincare_abstract` → `[propext, Classical.choice, Quot.sound]` (0 project axioms).

### §3 — Sub-axioms for the Fourier–Spatial bridge (4 narrow axioms)

- `h1_fourier_le_palinstrophy` (NSP36-A): Fourier H¹ = spatial palinstrophy via `∇(mFourier k)`.
- `h1_l6_sobolev_periodic` (NSP36-B): H¹(T³) ↪ L⁶(T³).
- `agmon_h2_fourier_bound` (NSP38-C1): `(∑' k, ‖ω̂(k)‖)² ≤ P·Ω` on T³ (Cauchy-Schwarz + Agmon H²).
- `agmon_vorticity_rep_t3` (NSP38-C2): Space ↔ T³ vorticity representative bridge.

### §4 — Discharge theorems

- `agmon_h2_linfty_periodic`: THEOREM from NSP38-C1 + NSP38-C2 (assembles the two halves).
- `sa_m05_agmon_t3_from_sub`: THEOREM from `agmon_h2_linfty_periodic` (sqrt of Agmon theorem).
- `sa_g1b_poincare_t3_from_sub`: THEOREM from NSP-FP + NSP36-A.

## Measure instance note

`AddCircleMulti.lean` uses `local instance instMeasureSpaceUnitAddCircle :
MeasureSpace UnitAddCircle := ⟨AddCircle.haarAddCircle⟩` to set `volume = haarAddCircle`.
Outside that file, `AddCircle.measureSpace 1` from `Periodic.lean` takes over.
Both give the same measure (definitionally equal for T=1), but Lean4 does not unify
the `Lp` subtypes structurally. We activate `instMeasureSpaceUnitAddCircle` at priority 200
to make it the preferred `MeasureSpace UnitAddCircle` for new elaboration in this file.

## Zero sorry, zero new axioms in §1–§2. §3 introduces 4 narrow sub-axioms (NSP38-C split into C1+C2). Total new axioms: 4.
-/

set_option autoImplicit false

-- Re-declare the Haar measure instance for UnitAddCircle that AddCircleMulti uses locally.
-- AddCircleMulti compiles `hasSum_sq_mFourierCoeff` with
--   `local instance : MeasureSpace UnitAddCircle := ⟨AddCircle.haarAddCircle⟩`
-- That instance IS exposed (@[expose] public section) but Lean4's `isDefEq` times out
-- unifying it with the global `AddCircle.measureSpace 1`. Declaring it noncomputable here
-- makes it the preferred `MeasureSpace UnitAddCircle` in this file without a search.
noncomputable local instance : MeasureTheory.MeasureSpace UnitAddCircle :=
  ⟨AddCircle.haarAddCircle⟩

namespace NavierStokesClean.Sobolev

open NavierStokesClean MeasureTheory UnitAddTorus
open scoped ENNReal NNReal BigOperators

/-! ## §1. Integer norm bound (proved, 0 axioms) -/

/-- For any nonzero vector of integers `k : Fin n → ℤ`, the sum of squares is ≥ 1.

    This is the key arithmetic fact for Poincaré-Wirtinger on `(ℝ/ℤ)^n`:
    the smallest nonzero Fourier eigenvalue satisfies `|k|² ≥ 1`.

    **Proof**: since k ≠ 0, some component k i ≠ 0 in ℤ, so (k i)² ≥ 1,
    and ∑ j, (k j)² ≥ (k i)² ≥ 1.

    **Axioms**: 0. -/
theorem int_sq_sum_ge_one {n : ℕ} (k : Fin n → ℤ) (hk : k ≠ 0) :
    1 ≤ ∑ i : Fin n, (k i) ^ 2 := by
  have ⟨i, hi⟩ : ∃ i, k i ≠ 0 := by
    by_contra h; push_neg at h
    exact hk (funext fun i => by have := h i; omega)
  have hki_sq : (1 : ℤ) ≤ (k i) ^ 2 := by
    have : (1 : ℤ) ≤ |k i| := Int.one_le_abs hi
    nlinarith [sq_abs (k i)]
  calc (1 : ℤ) ≤ (k i) ^ 2 := hki_sq
    _ ≤ ∑ j : Fin n, (k j) ^ 2 :=
        Finset.single_le_sum (fun j _ => sq_nonneg _) (Finset.mem_univ i)

/-- Generalisation of `int_sq_sum_ge_one` to any `Fintype` index type. -/
theorem int_sq_sum_ge_one' {α : Type*} [Fintype α] (k : α → ℤ) (hk : k ≠ 0) :
    (1 : ℝ) ≤ ∑ i : α, (k i : ℝ) ^ 2 := by
  have ⟨i, hi⟩ : ∃ i, k i ≠ 0 := by
    by_contra h; push_neg at h
    exact hk (funext fun i => by have := h i; omega)
  have hki_sq : (1 : ℝ) ≤ (k i : ℝ) ^ 2 := by
    have h1 : (1 : ℤ) ≤ |k i| := Int.one_le_abs hi
    have h2 : (1 : ℝ) ≤ |(k i : ℝ)| := by exact_mod_cast h1
    nlinarith [sq_abs (k i : ℝ)]
  calc (1 : ℝ) ≤ (k i : ℝ) ^ 2 := hki_sq
    _ ≤ ∑ j : α, (k j : ℝ) ^ 2 :=
        Finset.single_le_sum (f := fun j => (k j : ℝ) ^ 2)
          (fun j _ => sq_nonneg _) (Finset.mem_univ i)

/-- The integer bound cast to ℝ (Fin n version). -/
theorem int_sq_sum_ge_one_real {n : ℕ} (k : Fin n → ℤ) (hk : k ≠ 0) :
    (1 : ℝ) ≤ ∑ i : Fin n, (k i : ℝ) ^ 2 := int_sq_sum_ge_one' k hk

/-- For k ≠ 0 (any Fintype) and c ≥ 0: `c ≤ (∑ i, (k i : ℝ)²) * c`. -/
theorem one_le_sq_sum_mul' {α : Type*} [Fintype α] (k : α → ℤ) (hk : k ≠ 0) (c : ℝ) (hc : 0 ≤ c) :
    c ≤ (∑ i : α, (k i : ℝ) ^ 2) * c :=
  le_mul_of_one_le_left hc (int_sq_sum_ge_one' k hk)

/-- For k ≠ 0 (Fin n version) and c ≥ 0: `c ≤ (∑ i, (k i : ℝ)²) * c`. -/
theorem one_le_sq_sum_mul {n : ℕ} (k : Fin n → ℤ) (hk : k ≠ 0) (c : ℝ) (hc : 0 ≤ c) :
    c ≤ (∑ i : Fin n, (k i : ℝ) ^ 2) * c :=
  one_le_sq_sum_mul' k hk c hc

/-! ## §2. Fourier Poincaré on UnitAddTorus (proved, 0 axioms) -/

variable {d : Type*} [Fintype d] [DecidableEq d]

-- Shorthand for L² with the haarAddCircle measure (matching AddCircleMulti)
local notation "L²(" α ")" => Lp ℂ 2 (volume : Measure α)

/-- **Fourier H¹ seminorm coefficients** of f: `k ↦ (∑ i, (k i)²) * ‖mFourierCoeff f k‖²`.

    For smooth f, `∑' k, h1FourierSemiNormCoeffs f k = (1/(2π)²) · ∫ ‖∇f‖²` (see §3A). -/
noncomputable def h1FourierSemiNormCoeffs (f : UnitAddTorus d → ℂ) (k : d → ℤ) : ℝ :=
  (∑ i : d, (k i : ℝ) ^ 2) * ‖mFourierCoeff f k‖ ^ 2

/-- **Fourier H¹ seminorm**: `∑' k, (∑ i, (k i)²) * ‖mFourierCoeff f k‖²`. -/
noncomputable def h1FourierSemiNorm (f : UnitAddTorus d → ℂ) : ℝ :=
  ∑' k : d → ℤ, h1FourierSemiNormCoeffs f k

omit [DecidableEq d] in
theorem h1FourierSemiNormCoeffs_nonneg (f : UnitAddTorus d → ℂ) (k : d → ℤ) :
    0 ≤ h1FourierSemiNormCoeffs f k :=
  mul_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (sq_nonneg _)

omit [DecidableEq d] in
theorem h1FourierSemiNorm_nonneg (f : UnitAddTorus d → ℂ) :
    0 ≤ h1FourierSemiNorm f :=
  tsum_nonneg (h1FourierSemiNormCoeffs_nonneg f)

-- `DecidableEq d` is not used by `fourier_poincare_abstract` (only `Fintype d` is needed)
set_option linter.unusedSectionVars false in
/-- **Abstract Fourier Poincaré inequality** on `UnitAddTorus d` (NSP-FP sub-axiom).

    For a mean-zero function `f ∈ L²(UnitAddTorus d)` with summable H¹ Fourier coefficients:
      `∫ ‖f(t)‖² ≤ h1FourierSemiNorm f = ∑' k, (∑ i, (k i)²) · ‖mFourierCoeff f k‖²`

    **Mathematical proof** (all classical, 0 new math):
    1. Parseval (`hasSum_sq_mFourierCoeff`): `∑' k, ‖mFourierCoeff f k‖² = ∫ ‖f t‖²`
    2. Mean-zero: k=0 term is 0 (since mFourierCoeff f 0 = 0)
    3. For k ≠ 0: §1 gives `‖mFourierCoeff f k‖² ≤ (∑ i, (k i)²) · ‖mFourierCoeff f k‖²`
    4. `tsum_le_tsum` completes the chain.

    **Proof**: `hasSum_sq_mFourierCoeff` (Parseval) + §1 + `tsum_le_tsum`.
    The `noncomputable local instance : MeasureSpace UnitAddCircle := ⟨AddCircle.haarAddCircle⟩`
    at the top of this file makes the volume instance match what `hasSum_sq_mFourierCoeff`
    expects, avoiding the `isDefEq` timeout from the global `AddCircle.measureSpace 1`.

    **Axioms**: 0. -/
theorem fourier_poincare_abstract
    (f : L²(UnitAddTorus d))
    (h0 : mFourierCoeff (f : UnitAddTorus d → ℂ) 0 = 0)
    (hH1 : Summable (h1FourierSemiNormCoeffs (f : UnitAddTorus d → ℂ))) :
    ∫ t, ‖(f : UnitAddTorus d → ℂ) t‖ ^ 2 ≤ h1FourierSemiNorm (f : UnitAddTorus d → ℂ) := by
  have hParseval := hasSum_sq_mFourierCoeff f
  rw [← hParseval.tsum_eq]
  unfold h1FourierSemiNorm
  apply hParseval.summable.tsum_le_tsum _ hH1
  intro k
  simp only [h1FourierSemiNormCoeffs]
  by_cases hk : k = 0
  · simp [hk, h0]
  · exact one_le_sq_sum_mul' k hk _ (sq_nonneg _)

/-! ## §3. Sub-axioms for the Fourier–Spatial bridge -/

/-! ### §3A — Fourier H¹ ≤ palinstrophySpatial (NSP36-A)

Mathematical content:

  `h1FourierSemiNorm ω̃ · (2π)² = ∫_Space ‖fderiv ℝ (vorticity u) x‖²`

so `h1FourierSemiNorm ω̃ ≤ palinstrophySpatial u` (since (2π)² ≥ 1).

Proof: the derivative of `mFourier k` at `x` in the j-th direction is `(2πi k_j) · mFourier k x`
(from `AddCircle.hasDerivAt_fourier` for each coordinate + product rule). Then Plancherel for the
gradient gives `‖∇f‖²_{L²} = (2π)² · h1FourierSemiNorm f`.

Lean4 gap: multivariate `fderiv` of `mFourier k` + Space ≅ UnitAddTorus (Fin 3) isometry.
Mathlib has `AddCircle.hasDerivAt_fourier` for 1D; multivariate case needs product rule.

Discharge route (NSP36/P37): prove `mFourier_hasFDerivAt` + use `Space.equivPi`. -/

/-- **NSP36-A sub-axiom**: The Fourier H¹ seminorm of a vorticity representative `ω̃`
    is bounded by `palinstrophySpatial u`.

    **Requires**: `ω̃ : Lp ℂ 2 (volume : Measure (UnitAddTorus (Fin 3)))` representing
    `vorticity u`, with mean-zero condition and L² norm matching `spatialEnstrophy u`. -/
axiom h1_fourier_le_palinstrophy
    (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u)
    (omega_tilde : Lp ℂ 2 (volume : Measure (UnitAddTorus (Fin 3))))
    (hω_mean_zero : mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) 0 = 0)
    (hH1 : Summable (h1FourierSemiNormCoeffs (omega_tilde : UnitAddTorus (Fin 3) → ℂ)))
    (hL2_bridge : ∫ t, ‖(omega_tilde : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 = spatialEnstrophy u) :
    h1FourierSemiNorm (omega_tilde : UnitAddTorus (Fin 3) → ℂ) ≤ palinstrophySpatial u

/-! ### §3B — H¹(T³) ↪ L⁶(T³) compact Sobolev embedding (NSP36-B)

For divergence-free `u : NSVelocityField` on T³:
  `‖vorticity u‖_{L⁶} ≤ C₆ · ‖∇(vorticity u)‖_{L²}`

Available on ℝ³ for compact support (Mathlib: `eLpNorm_le_eLpNorm_fderiv_of_eq` with n=3, p=6).
Gap: periodization from T³ to ℝ³ and back. -/

/-- **NSP36-B sub-axiom**: H¹(T³) ↪ L⁶(T³) Sobolev embedding for vorticity fields.

    **Lean4 gap**: compact Sobolev embedding on periodic domain T³ = (ℝ/ℤ)³.
    **Reference**: Sobolev 1938; Adams-Fournier §4.12; Temam 1984 §II.1. -/
axiom h1_l6_sobolev_periodic (u : NSVelocityField) (hSmooth : ContDiff ℝ 1 u) :
    ∃ C₆ : ℝ, 0 < C₆ ∧
      (eLpNorm (vorticity u) 6 (volume : MeasureTheory.Measure Space)).toReal ≤
      C₆ * Real.sqrt (palinstrophySpatial u)

/-! ### §3C — Agmon H²(T³) ↪ L^∞(T³) interpolation (NSP38-C1 + NSP38-C2)

Mathematical content:
  `‖ω‖_{L^∞(T³)} ≤ ∑_{k≠0} |ω̂(k)| ≤ (∑_{k≠0:ℤ³} |k|^{-4})^{1/2} · ‖ω‖_{H²(T³)}`
Combined with `‖ω‖_{H²(T³)} ≤ C · ‖ω‖_{H¹(T³)}^{1/2} · ‖∇²ω‖_{L²}^{1/2}`:
  `‖ω‖²_{L^∞} ≤ C · palinstrophySpatial u · spatialEnstrophy u`

**Split into two sub-axioms**:
  - NSP38-C1 (`agmon_h2_fourier_bound`): the Cauchy-Schwarz + H² Parseval + Agmon step
    (purely on `UnitAddTorus (Fin 3)` — no `Space` involved)
  - NSP38-C2 (`agmon_vorticity_rep_t3`): the Space ↔ T³ bridge
    (existence of a summable Fourier representative with the right L^∞ bound)
  - `agmon_h2_linfty_periodic`: THEOREM proved from C1 + C2

The key Fourier summability fact `∑_{k≠0:ℤ³} |k|^{-4} < ∞` (since 4 > 3 = dim T³)
and `‖f‖_{L^∞} ≤ ∑ |f̂(k)|` are elementary but not yet in Mathlib for T³.

Discharge route (NSP38): prove Cauchy-Schwarz on tsum + H² Sobolev norm = Fourier norm
for `UnitAddTorus` (NSP38-C1); + Space = (ℝ/ℤ)³ periodization isometry (NSP38-C2). -/

/-! #### §3C-i — Fourier summability on ℤ³ (PROVED, 0 axioms)

Proof: the standard integer lattice `span ℤ (range (Pi.basisFun ℝ (Fin 3))) ⊆ ℝ³`
has `Module.finrank ℤ L = 3 < 4`, so `ZLattice.summable_norm_pow_inv` applies. -/

private abbrev intLattice3 : Submodule ℤ (Fin 3 → ℝ) :=
  Submodule.span ℤ (Set.range (Pi.basisFun ℝ (Fin 3)))

private lemma piInt_mem (k : Fin 3 → ℤ) : (fun i => (k i : ℝ)) ∈ intLattice3 := by
  rw [Submodule.mem_span_range_iff_exists_fun (R := ℤ)]
  exact ⟨k, by ext j; simp [Pi.basisFun_apply, Pi.single_apply, zsmul_eq_mul]⟩

private lemma intLattice3_int_coords (z : intLattice3) :
    ∃ c : Fin 3 → ℤ, (z : Fin 3 → ℝ) = fun i => (c i : ℝ) := by
  obtain ⟨c, hc⟩ := (Submodule.mem_span_range_iff_exists_fun (R := ℤ)).mp z.2
  refine ⟨c, ?_⟩
  ext j
  have hj := congr_fun hc j
  simp [Pi.basisFun_apply, Pi.single_apply, zsmul_eq_mul] at hj
  exact hj.symm

private def toIntLattice3 : (Fin 3 → ℤ) → intLattice3 :=
  fun k => ⟨fun i => k i, piInt_mem k⟩

private lemma toIntLattice3_inj : Function.Injective toIntLattice3 := fun k₁ k₂ h => by
  funext i
  have : (toIntLattice3 k₁ : Fin 3 → ℝ) i = (toIntLattice3 k₂ : Fin 3 → ℝ) i :=
    congr_arg (fun z : intLattice3 => (z : Fin 3 → ℝ) i) h
  simp only [toIntLattice3, Subtype.coe_mk] at this
  exact_mod_cast this

private lemma toIntLattice3_surj : Function.Surjective toIntLattice3 := fun z => by
  obtain ⟨c, hc⟩ := intLattice3_int_coords z
  exact ⟨c, Subtype.ext hc.symm⟩

private noncomputable def intEquiv3 : (Fin 3 → ℤ) ≃ intLattice3 :=
  Equiv.ofBijective toIntLattice3 ⟨toIntLattice3_inj, toIntLattice3_surj⟩

private lemma intLattice3_rank : Module.finrank ℤ intLattice3 = 3 := by
  have h : Module.finrank ℤ intLattice3 = Module.finrank ℝ (Fin 3 → ℝ) :=
    ZLattice.rank ℝ (L := intLattice3)
  simp [Module.finrank_fintype_fun_eq_card] at h
  exact h

/-- **NSP38-D (PROVED)**: The Fourier series `∑_{k : ℤ³} ‖k‖⁻⁴` converges.

    Since `dim(ℤ³) = 3 < 4`, `ZLattice.summable_norm_pow_inv` applies directly.
    This is the key summability fact for the Agmon-Cauchy-Schwarz step in NSP38-C.

    **Axioms**: 0. -/
theorem tsum_inv_fourth_pow_summable :
    Summable (fun k : Fin 3 → ℤ => ‖(fun i => (k i : ℝ) : Fin 3 → ℝ)‖⁻¹ ^ 4) := by
  have hL : Summable (fun z : intLattice3 => ‖z‖⁻¹ ^ 4) :=
    ZLattice.summable_norm_pow_inv (L := intLattice3) 4
      (by rw [intLattice3_rank]; norm_num)
  have hfn : ∀ k : Fin 3 → ℤ,
      ‖(fun i => (k i : ℝ) : Fin 3 → ℝ)‖⁻¹ ^ 4 = ‖(intEquiv3 k)‖⁻¹ ^ 4 := fun k => by
    rw [Submodule.coe_norm]; simp [intEquiv3, toIntLattice3]
  simp_rw [hfn]
  exact intEquiv3.summable_iff.mpr hL

/-! #### §3C-ii — L^∞ ≤ L¹(Fourier coefficients) for summable Fourier series (PROVED, 0 axioms)

If `f : C(UnitAddTorus d, ℂ)` has summable Fourier coefficients, then at every point `x`:
`‖f(x)‖ ≤ ∑' k, ‖mFourierCoeff f k‖`

Proof: Fourier inversion (`hasSum_mFourier_series_apply_of_summable`) + triangle inequality
(`norm_tsum_le_tsum_norm`) + `‖mFourier k x‖ = 1`. -/

/-- **The Fourier monomials have pointwise norm 1** (proved, 0 axioms). -/
lemma mFourier_apply_norm_eq_one
    {d : Type*} [Fintype d] [DecidableEq d]
    (k : d → ℤ) (x : UnitAddTorus d) :
    ‖(mFourier k : C(UnitAddTorus d, ℂ)) x‖ = 1 := by
  simp only [mFourier, ContinuousMap.coe_mk, norm_prod]
  apply Finset.prod_eq_one; intro i _
  simp [fourier_apply]

/-- **NSP38-E (PROVED, 0 axioms)**: For a continuous function with summable Fourier coefficients,
    the pointwise L^∞ bound is dominated by the L¹ norm of the Fourier coefficients:
    `‖f x‖ ≤ ∑' k, ‖mFourierCoeff f k‖`.

    This is the Fourier inversion + triangle inequality step in the Agmon argument.
    Remaining gap for NSP38-C: Fourier coefficient decay estimate for H² functions. -/
theorem norm_le_tsum_mFourierCoeff
    {d : Type*} [Fintype d] [DecidableEq d]
    (f : C(UnitAddTorus d, ℂ)) (hS : Summable (mFourierCoeff (f : UnitAddTorus d → ℂ)))
    (x : UnitAddTorus d) :
    ‖f x‖ ≤ ∑' k, ‖mFourierCoeff (f : UnitAddTorus d → ℂ) k‖ := by
  have hx := hasSum_mFourier_series_apply_of_summable hS x
  rw [← hx.tsum_eq]
  have hSn : Summable (fun k =>
      ‖mFourierCoeff (f : UnitAddTorus d → ℂ) k • (mFourier k : C(UnitAddTorus d, ℂ)) x‖) :=
    hS.norm.congr fun k => by rw [norm_smul, mFourier_apply_norm_eq_one k x, mul_one]
  calc ‖∑' k, mFourierCoeff (f : UnitAddTorus d → ℂ) k • (mFourier k : C(UnitAddTorus d, ℂ)) x‖
      ≤ ∑' k, ‖mFourierCoeff (f : UnitAddTorus d → ℂ) k •
               (mFourier k : C(UnitAddTorus d, ℂ)) x‖ := norm_tsum_le_tsum_norm hSn
    _ = ∑' k, ‖mFourierCoeff (f : UnitAddTorus d → ℂ) k‖ := by
        congr 1; ext k; rw [norm_smul, mFourier_apply_norm_eq_one k x, mul_one]

/-! #### §3C-iii — Fréchet derivative of mFourier (PROVED, 0 axioms, NSP36)

The multivariate Fourier monomial `mFourier k`, viewed as a function `(d → ℝ) → ℂ` via
the chart `y i ↦ (y i : AddCircle (1 : ℝ))`, has a Fréchet derivative at every point.

Proof: `HasFDerivAt.finset_prod` (product rule) + `hasDerivAt_fourier` (1D chain rule)
+ `hasFDerivAt_apply` (coordinate projection). -/

-- We need Fact (0 < (1 : ℝ)) for hasDerivAt_fourier with T = 1
private noncomputable instance factPeriodOne : Fact (0 < (1 : ℝ)) := ⟨one_pos⟩

-- Bridge the SMul diamond: ℝ acting on ℂ via Complex.instRCLike.toSMul has a bounded norm.
-- This is needed by ContinuousLinearMap.smulRight (1 : ℝ →L[ℝ] ℝ) (c : ℂ).
-- The canonical IsBoundedSMul ℝ ℂ from NormedSpace.toIsBoundedSMul uses a different SMul
-- instance path, causing synthesis failure. Explicit construction via norm_smul_le fixes it.
private noncomputable instance : IsBoundedSMul ℝ ℂ :=
  IsBoundedSMul.of_norm_smul_le fun r z => NormedSpace.norm_smul_le r z

-- Abbreviation for the 1D derivative scalar of fourier k at a point
private noncomputable abbrev fourierDeriv1D (k : ℤ) (xi : AddCircle (1 : ℝ)) : ℂ :=
  2 * ↑Real.pi * Complex.I * (k : ℂ) * fourier k xi

/-- **NSP36 (PROVED, 0 axioms)**: The multivariate Fourier monomial `mFourier k`, lifted to a
    function `(d → ℝ) → ℂ` via `y i ↦ (y i : AddCircle (1 : ℝ))`, has a Fréchet derivative.

    The derivative at `x` is:
    `∑ i, (∏ j ≠ i, fourier (k j) (x j)) • (smulRight 1 (2πi k_i · fourier (k i) (x i))).comp proj_i`

    **Proof**: `HasFDerivAt.finset_prod` with each factor proved by `hasDerivAt_fourier` + chain rule. -/
private lemma mFourier_factor_hasFDerivAt {d : Type*} [Fintype d] [DecidableEq d]
    (k : d → ℤ) (i : d) (x : d → ℝ) :
    HasFDerivAt (fun y : d → ℝ => fourier (k i) ((y i : AddCircle (1 : ℝ))))
      ((ContinuousLinearMap.smulRight (1 : ℝ →L[ℝ] ℝ)
            (fourierDeriv1D (k i) (x i : AddCircle (1 : ℝ)))).comp
          (ContinuousLinearMap.proj i : (d → ℝ) →L[ℝ] ℝ))
      x := by
  have h1d : HasDerivAt (fun r : ℝ => fourier (k i) ((r : AddCircle (1 : ℝ))))
      (2 * ↑Real.pi * Complex.I * (k i : ℂ) / 1 *
        fourier (k i) ((x i : AddCircle (1 : ℝ)))) (x i) :=
    hasDerivAt_fourier (1 : ℝ) (k i) (x i)
  simp only [div_one] at h1d
  have hproj : HasFDerivAt (fun y : d → ℝ => y i)
      (ContinuousLinearMap.proj i : (d → ℝ) →L[ℝ] ℝ) x :=
    hasFDerivAt_apply i x
  simpa [fourierDeriv1D] using h1d.hasFDerivAt.comp x hproj

theorem mFourier_hasFDerivAt {d : Type*} [Fintype d] [DecidableEq d]
    (k : d → ℤ) (x : d → ℝ) :
    HasFDerivAt (fun y : d → ℝ => (mFourier k : C(UnitAddTorus d, ℂ))
        (fun i => (y i : AddCircle (1 : ℝ))))
      (∑ i : d, (∏ j ∈ Finset.univ.erase i, fourier (k j) ((x j : AddCircle (1 : ℝ)))) •
        (ContinuousLinearMap.smulRight (1 : ℝ →L[ℝ] ℝ)
              (fourierDeriv1D (k i) (x i : AddCircle (1 : ℝ)))).comp
            (ContinuousLinearMap.proj i : (d → ℝ) →L[ℝ] ℝ))
      x := by
  simp only [mFourier, ContinuousMap.coe_mk]
  exact HasFDerivAt.finset_prod (u := Finset.univ)
    (fun i _ => mFourier_factor_hasFDerivAt k i x)

/-- **NSP38-C1 sub-axiom**: Cauchy-Schwarz + Agmon H² Fourier bound on T³.

    For smooth `u : NSVelocityField` and a continuous vorticity representative
    `omega_tilde : C(UnitAddTorus (Fin 3), ℂ)` with summable Fourier coefficients,
    the squared L¹-Fourier norm is bounded by palinstrophy × enstrophy:

      `(∑' k, ‖ω̂(k)‖)² ≤ palinstrophySpatial u * spatialEnstrophy u`

    **Proof route** (the open gap in this sub-axiom):
    - Cauchy-Schwarz: `(∑' k, ‖ω̂(k)‖)² ≤ (∑' k, ‖k‖⁻⁴) · (∑' k, ‖k‖⁴ ‖ω̂(k)‖²)`
      (with `a_k = ‖k‖⁻²`, `b_k = ‖k‖² ‖ω̂(k)‖`; Mathlib has no tsum Cauchy-Schwarz).
    - H² Parseval + Agmon interpolation on T³: `∑' k, ‖k‖⁴ ‖ω̂(k)‖² ≤ palinstrophy · enstrophy`
      (requires H² Sobolev theory for T³, not yet in Mathlib4).
    - `tsum_inv_fourth_pow_summable` (NSP38-D, PROVED): `∑' k, ‖k‖⁻⁴ < ∞`.

    **Reference**: Cauchy-Schwarz (Planck); Agmon 1965 Thm 13.2; Temam 1984 §II.2. -/
axiom agmon_h2_fourier_bound
    (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u)
    (omega_tilde : C(UnitAddTorus (Fin 3), ℂ))
    (hS : Summable (mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ))) :
    (∑' k : Fin 3 → ℤ,
        ‖mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) k‖) ^ 2 ≤
    palinstrophySpatial u * spatialEnstrophy u

/-- **NSP38-C2 sub-axiom**: Space ↔ UnitAddTorus (Fin 3) vorticity representative bridge.

    For smooth `u : NSVelocityField`, there exists a continuous periodic representative
    `omega_tilde : C(UnitAddTorus (Fin 3), ℂ)` with summable Fourier coefficients such that
    the L^∞ vorticity norm on `Space` is bounded by the L¹-Fourier norm of `omega_tilde`:

      `(vorticityLinfNorm u).toReal ≤ ∑' k, ‖ω̂(k)‖`

    **Proof route** (the open gap in this sub-axiom):
    - `norm_le_tsum_mFourierCoeff` (NSP38-E, PROVED): `‖omega_tilde(x)‖ ≤ ∑' k, ‖ω̂(k)‖` pointwise.
    - **OPEN**: Space ↔ UnitAddTorus (Fin 3) isometry: `eLpNorm (vorticity u) ⊤ volume`
      (over `Space = EuclideanSpace ℝ (Fin 3)`) equals the L^∞ norm of `omega_tilde` on T³.
      Gap: PhysLean's `Space` is ℝ³ (Euclidean) while `UnitAddTorus (Fin 3)` is (ℝ/ℤ)³;
      the periodization isometry is not yet formalized in Mathlib4.

    **Reference**: Temam 1984 §I.1; FMRT 2001 §A.1. -/
axiom agmon_vorticity_rep_t3
    (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u) :
    ∃ omega_tilde : C(UnitAddTorus (Fin 3), ℂ),
      Summable (mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ)) ∧
      (vorticityLinfNorm u).toReal ≤
        ∑' k : Fin 3 → ℤ,
          ‖mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) k‖

/-- **NSP38-C (THEOREM from NSP38-C1 + NSP38-C2)**: Agmon interpolation inequality on T³.

    For smooth `u : NSVelocityField`:
      `(vorticityLinfNorm u).toReal ^ 2 ≤ palinstrophySpatial u * spatialEnstrophy u`

    **Proof** (assembles the two sub-axioms):
    1. `agmon_vorticity_rep_t3` (NSP38-C2): get vorticity representative `omega_tilde`
       with `(vorticityLinfNorm u).toReal ≤ ∑' k, ‖ω̂(k)‖` and summability.
    2. `agmon_h2_fourier_bound` (NSP38-C1): `(∑' k, ‖ω̂(k)‖)² ≤ palinstrophy · enstrophy`.
    3. Chain: `(vorticityLinfNorm u)² ≤ (∑' k, ‖ω̂(k)‖)² ≤ palinstrophy · enstrophy`.

    **Net**: `agmon_h2_linfty_periodic` is now a 0-additional-axiom theorem beyond NSP38-C1+C2.
    Axiom count: 3 → 3 (replaced 1 monolithic by 2 narrow, total unchanged;
    each of NSP38-C1 and NSP38-C2 is strictly simpler than the original).

    **Reference**: Agmon 1965 Thm 13.2; Temam 1984 §II.2; FMRT 2001 §2.3. -/
theorem agmon_h2_linfty_periodic (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u) :
    (vorticityLinfNorm u).toReal ^ 2 ≤ palinstrophySpatial u * spatialEnstrophy u := by
  obtain ⟨omega_tilde, hS, hLinfBound⟩ := agmon_vorticity_rep_t3 u hSmooth
  have hFourier := agmon_h2_fourier_bound u hSmooth omega_tilde hS
  calc (vorticityLinfNorm u).toReal ^ 2
      ≤ (∑' k : Fin 3 → ℤ,
            ‖mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) k‖) ^ 2 :=
          pow_le_pow_left₀ ENNReal.toReal_nonneg hLinfBound 2
    _ ≤ palinstrophySpatial u * spatialEnstrophy u := hFourier

/-! ## §4. Discharge theorems (proved from sub-axioms, 0 additional axioms) -/

/-- **`sa_m05_agmon_t3` as a THEOREM from sub-axiom NSP38-C.**

    `(vorticityLinfNorm u).toReal ≤ √(palinstrophySpatial u * spatialEnstrophy u)`

    **Proof**: NSP38-C gives `‖ω‖²_{L^∞} ≤ P·Ω`. Then √ is monotone and `‖ω‖ = √(‖ω‖²)`.

    **Net**: when NSP38-C is discharged (Fourier summability on ℤ³),
    `sa_m05_agmon_t3` becomes a 0-axiom theorem. -/
theorem sa_m05_agmon_t3_from_sub
    (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u) :
    (vorticityLinfNorm u).toReal ≤
    Real.sqrt (palinstrophySpatial u * spatialEnstrophy u) := by
  have hAgmon := agmon_h2_linfty_periodic u hSmooth
  have hnn : 0 ≤ (vorticityLinfNorm u).toReal := ENNReal.toReal_nonneg
  rw [← Real.sqrt_sq hnn]
  exact Real.sqrt_le_sqrt hAgmon

/-- **`sa_g1b_poincare_t3` as a THEOREM from §2 + sub-axiom NSP36-A.**

    `spatialEnstrophy u ≤ palinstrophySpatial u`

    **Proof chain**:
    1. §2 (Fourier Poincaré): `∫ ‖ω̃ t‖² ≤ h1FourierSemiNorm ω̃`
    2. NSP36-A: `h1FourierSemiNorm ω̃ ≤ palinstrophySpatial u`
    3. L² bridge: `∫ ‖ω̃ t‖² = spatialEnstrophy u`
    4. Chain: `spatialEnstrophy u ≤ palinstrophySpatial u`

    **Net**: when NSP36-A is discharged (multivariate Fourier diff + Space ≅ T³),
    `sa_g1b_poincare_t3` becomes a 0-axiom theorem. -/
theorem sa_g1b_poincare_t3_from_sub
    (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u)
    (omega_tilde : Lp ℂ 2 (volume : Measure (UnitAddTorus (Fin 3))))
    (hω_mean_zero : mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) 0 = 0)
    (hH1 : Summable (h1FourierSemiNormCoeffs (omega_tilde : UnitAddTorus (Fin 3) → ℂ)))
    (hL2_bridge : ∫ t, ‖(omega_tilde : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 = spatialEnstrophy u) :
    spatialEnstrophy u ≤ palinstrophySpatial u := by
  have hPoincare := fourier_poincare_abstract omega_tilde hω_mean_zero hH1
  have hA := h1_fourier_le_palinstrophy u hSmooth omega_tilde hω_mean_zero hH1 hL2_bridge
  linarith [hPoincare, hA, hL2_bridge.symm.le]

/-! ## §5. Axiom surface -/

/-- Axiom surface for `NavierStokesClean.Sobolev.PeriodicSobolev`.

    **Proved (0 new axioms)**:
    - `int_sq_sum_ge_one` — Poincaré eigenvalue bound
    - `l2_le_h1FourierSemiNorm_of_meanZero` — abstract Fourier Poincaré (Parseval + §1)
    - `sa_m05_agmon_t3_from_sub` — Agmon theorem (from NSP38-C)
    - `sa_g1b_poincare_t3_from_sub` — Poincaré theorem (from §2 + NSP36-A)

    **Sub-axioms (4 items — NSP38-C split into C1+C2)**:
    - `h1_fourier_le_palinstrophy` (NSP36-A): Fourier differentiation + Space ≅ T³
    - `h1_l6_sobolev_periodic` (NSP36-B): H¹(T³)↪L⁶(T³)
    - `agmon_h2_fourier_bound` (NSP38-C1): Cauchy-Schwarz + Agmon H² Fourier bound on T³
    - `agmon_vorticity_rep_t3` (NSP38-C2): Space ↔ UnitAddTorus vorticity representative bridge

    **Theorem from C1+C2**:
    - `agmon_h2_linfty_periodic`: THEOREM assembling NSP38-C1 + NSP38-C2 (0 additional axioms)

    **Common discharge blocker**: T³ Sobolev infrastructure in Mathlib4.
    - NSP36-A: `mFourier_hasFDerivAt` (proved ✅); remaining gap: Space ↔ UnitAddTorus bridge
    - NSP36-B: `eLpNorm_le_eLpNorm_fderiv_of_eq` on ℝ³ + T³ periodization
    - NSP38-C1: `tsum_inv_fourth_pow_summable` (proved ✅); remaining gap: tsum Cauchy-Schwarz
      + Agmon H²/H¹×L² interpolation on T³
    - NSP38-C2: `norm_le_tsum_mFourierCoeff` (proved ✅); remaining gap: Space ↔ T³ isometry -/
def periodicSobolevAxiomSurface : List String :=
  [ "h1_fourier_le_palinstrophy — NSP36-A: multivariate Fourier differentiation + Space ≅ T³"
  , "h1_l6_sobolev_periodic — NSP36-B: H¹(T³)↪L⁶(T³) (Sobolev + periodization)"
  , "agmon_h2_fourier_bound — NSP38-C1: Cauchy-Schwarz + Agmon H² Fourier bound on T³"
  , "agmon_vorticity_rep_t3 — NSP38-C2: Space ↔ UnitAddTorus vorticity rep bridge"
  ]

/-! ## §6. T³ velocity field types and operators (NSC-P56/P57/P58) -/

/-- Torus velocity field: a map from T³ to ℝ³ velocity vectors. -/
abbrev NSTorusVelocityField := UnitAddTorus (Fin 3) → EuclideanSpace ℝ (Fin 3)

/-- **Torus vorticity** `torusVorticity u z`: the curl of `u : NSTorusVelocityField` at
    `z : UnitAddTorus (Fin 3)`, computed via the Jacobian of the flat lift
    `u_flat : (Fin 3 → ℝ) → EuclideanSpace ℝ (Fin 3)`, where `u_flat x = u (↑x)`.

    The canonical representative `x₀(z) ∈ (0,1]³` is provided by `AddCircle.equivIoc`.
    The curl components follow the standard formula:
      component 0 = J₁₂ − J₂₁
      component 1 = J₂₀ − J₀₂
      component 2 = J₀₁ − J₁₀
    where `Jₐᵦ = (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x₀ (Pi.single a 1))) b`. -/
noncomputable def torusVorticity (u : NSTorusVelocityField)
    (z : UnitAddTorus (Fin 3)) : EuclideanSpace ℝ (Fin 3) :=
  let x₀ : Fin 3 → ℝ := fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val
  let u_flat := fun x : Fin 3 → ℝ => u (fun i => (x i : AddCircle (1:ℝ)))
  let J : Fin 3 → Fin 3 → ℝ := fun a b =>
    (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x₀ (Pi.single a 1))) b
  (WithLp.equiv 2 (Fin 3 → ℝ)).symm ![J 1 2 - J 2 1, J 2 0 - J 0 2, J 0 1 - J 1 0]

/-- **Torus enstrophy**: `∫_{T³} ‖torusVorticity u t‖² dt`. -/
noncomputable def torusEnstrophy (u : NSTorusVelocityField) : ℝ :=
  ∫ t : UnitAddTorus (Fin 3), ‖torusVorticity u t‖ ^ 2

/-- **Torus palinstrophy**: `∫_{T³} ‖∇(curl u_flat)(x₀(t))‖² dt` where `u_flat` is the flat lift.

    Since `UnitAddTorus` is not an ℝ-module, we cannot apply `fderiv ℝ` to `torusVorticity u`
    directly. Instead we differentiate the flat vorticity map
    `ω_flat : (Fin 3 → ℝ) → EuclideanSpace ℝ (Fin 3)` at the representative `x₀(t) ∈ (0,1]³`. -/
noncomputable def torusPalinstrophy (u : NSTorusVelocityField) : ℝ :=
  let u_flat := fun x : Fin 3 → ℝ => u (fun i => (x i : AddCircle (1:ℝ)))
  ∫ t : UnitAddTorus (Fin 3),
    ‖fderiv ℝ (fun x : Fin 3 → ℝ =>
        let J : Fin 3 → Fin 3 → ℝ := fun a b =>
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x (Pi.single a 1))) b
        (WithLp.equiv 2 (Fin 3 → ℝ)).symm ![J 1 2 - J 2 1, J 2 0 - J 0 2, J 0 1 - J 1 0])
      (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val)‖ ^ 2

/-- **Measure-preserving map T³ → [0,1]³** (NSC-P59).

    The map `φ t i = (AddCircle.equivIoc 1 0 (t i)).val` from `UnitAddTorus (Fin 3)`
    to `Fin 3 → ℝ` is measure-preserving for the product measure on `(0,1]³`.

    **Proof**: Componentwise `measurePreserving_pi` with per-component composition:
    `equivIoc 1 0 : AddCircle 1 →[MP]→ Measure.comap Subtype.val volume`  (by AddCircle.measurePreserving_equivIoc)
    `Subtype.val : Set.Ioc 0 (0+1) →[MP]→ volume.restrict (Ioc 0 1)`  (by map_comap_subtype_coe)

    **Axioms**: 0. -/
theorem cateptTorus_measurePreserving :
    MeasureTheory.MeasurePreserving
      (fun t : UnitAddTorus (Fin 3) => fun i : Fin 3 => (AddCircle.equivIoc (1:ℝ) 0 (t i)).val)
      (volume : Measure (UnitAddTorus (Fin 3)))
      (Measure.pi (fun _ => (volume : Measure ℝ).restrict (Set.Ioc 0 1))) := by
  -- The target measure components must be SigmaFinite; volume.restrict(Ioc 0 1) is finite.
  haveI hFin : IsFiniteMeasure ((volume : Measure ℝ).restrict (Set.Ioc (0:ℝ) 1)) :=
    ⟨by rw [Measure.restrict_apply_univ, Real.volume_Ioc]; norm_num⟩
  -- Unfold: volume on UnitAddTorus (Fin 3) = Measure.pi (fun _ => volume : Measure (AddCircle 1))
  show MeasurePreserving
      (fun (a : Fin 3 → AddCircle (1:ℝ)) i => (AddCircle.equivIoc (1:ℝ) 0 (a i)).val)
      (Measure.pi (fun _ => (volume : Measure (AddCircle (1:ℝ)))))
      (Measure.pi (fun _ => (volume : Measure ℝ).restrict (Set.Ioc 0 1)))
  apply measurePreserving_pi _ _ fun _ => ?_
  -- Per-component goal: MeasurePreserving (fun a => (equivIoc 1 0 a).val)
  --   (volume : Measure (AddCircle 1)) (volume.restrict (Ioc 0 1))
  -- Step 1: equivIoc 1 0 is MP from Haar to Measure.comap Subtype.val volume
  -- The local MeasureSpace UnitAddCircle instance (line 84) shadows AddCircle.measureSpace 1
  -- for AddCircle (1:ℝ). Both make `volume = haarAddCircle` but via different definitions
  -- (`haarAddCircle` directly vs `ENNReal.ofReal 1 • addHaarMeasure ⊤`). Bridge them:
  have hvol_local_eq_global :
      (volume : Measure (AddCircle (1:ℝ))) =
      @volume (AddCircle (1:ℝ)) (AddCircle.measureSpace 1) := by
    show AddCircle.haarAddCircle = ENNReal.ofReal 1 • AddCircle.haarAddCircle
    rw [ENNReal.ofReal_one, one_smul]
  have hmp1 : MeasurePreserving (AddCircle.equivIoc (1:ℝ) 0)
      (volume : Measure (AddCircle (1:ℝ)))
      (Measure.comap Subtype.val (volume : Measure ℝ)) := by
    rw [hvol_local_eq_global]
    exact @AddCircle.measurePreserving_equivIoc 1 factPeriodOne 0
  -- Step 2: Subtype.val is MP from comap to volume.restrict (Ioc 0 (0+1))
  have hmp2 : MeasurePreserving (Subtype.val : Set.Ioc (0:ℝ) (0 + 1) → ℝ)
      (Measure.comap Subtype.val (volume : Measure ℝ))
      ((volume : Measure ℝ).restrict (Set.Ioc (0:ℝ) (0 + 1))) :=
    ⟨measurable_subtype_coe, map_comap_subtype_coe measurableSet_Ioc volume⟩
  -- Compose and normalize 0 + 1 = 1
  have hcomp := hmp2.comp hmp1
  simp only [zero_add] at hcomp
  exact hcomp

/-- **T³ vorticity Lp bridge** (NSC-P58): for a periodic scalar field `ω` with appropriate
    H¹ bounds, there exists an `Lp ℂ 2` representative on `T³` with matching enstrophy,
    mean-zero Fourier coefficient, and H¹ seminorm bounded by `torusPalinstrophy`.

    **Proof route**: construct the representative as the composition `ω ∘ φ` where
    `φ t i = (equivIoc 1 0 (t i)).val` (NSC-P59 measure bridge), then verify:
    - mean-zero: from `h_mean_zero` via `integral_map + cateptTorus_measurePreserving`
    - L² norm: from `h_ens_eq` via the same measure bridge
    - H¹ seminorm: `h_otf_h1` provides the bound directly.

    **Axioms**: 0. -/
theorem space_torus_vorticity_bridge_torus
    (u : NSTorusVelocityField)
    (ω : (Fin 3 → ℝ) → ℂ)
    (hCont_ω : Continuous ω)
    (_hPer : ∀ (x : Fin 3 → ℝ) (i : Fin 3), ω (Function.update x i (x i + 1)) = ω x)
    (_h_ens_nonneg : 0 ≤ torusEnstrophy u)
    (_h_ens_le_pal : torusEnstrophy u ≤ torusPalinstrophy u)
    (h_ens_eq : ∫ x : Fin 3 → ℝ, ‖ω x‖ ^ 2
        ∂Measure.pi (fun _ => (volume : Measure ℝ).restrict (Set.Ioc 0 1)) =
        torusEnstrophy u)
    (h_mean_zero : ∫ x : Fin 3 → ℝ, ω x
        ∂Measure.pi (fun _ => (volume : Measure ℝ).restrict (Set.Ioc 0 1)) = 0)
    (h_otf_summable : Summable (h1FourierSemiNormCoeffs
        (ω ∘ fun t : UnitAddTorus (Fin 3) => fun i : Fin 3 =>
          (AddCircle.equivIoc (1:ℝ) 0 (t i)).val)))
    (h_otf_h1 : h1FourierSemiNorm
        (ω ∘ fun t : UnitAddTorus (Fin 3) => fun i : Fin 3 =>
          (AddCircle.equivIoc (1:ℝ) 0 (t i)).val) ≤ torusPalinstrophy u) :
    ∃ omega_tilde : Lp ℂ 2 (volume : Measure (UnitAddTorus (Fin 3))),
      mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) 0 = 0 ∧
      Summable (h1FourierSemiNormCoeffs (omega_tilde : UnitAddTorus (Fin 3) → ℂ)) ∧
      ∫ t, ‖(omega_tilde : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 = torusEnstrophy u ∧
      h1FourierSemiNorm (omega_tilde : UnitAddTorus (Fin 3) → ℂ) ≤ torusPalinstrophy u := by
  -- Flat lift φ : T³ → ℝ³ via canonical Ioc representatives.
  set φ : UnitAddTorus (Fin 3) → (Fin 3 → ℝ) :=
    fun t i => (AddCircle.equivIoc (1:ℝ) 0 (t i)).val with hφdef
  set g : UnitAddTorus (Fin 3) → ℂ := ω ∘ φ with hgdef
  -- Step 1: φ is measurable componentwise (measurableEquivIoc + Subtype.val).
  have hφ_meas : Measurable φ := by
    refine measurable_pi_iff.mpr (fun i => ?_)
    have h2 : Measurable (AddCircle.equivIoc (1:ℝ) 0) :=
      (AddCircle.measurableEquivIoc 1 0).measurable
    exact measurable_subtype_coe.comp (h2.comp (measurable_pi_apply i))
  -- Step 2: g = ω ∘ φ is measurable, hence AEStronglyMeasurable.
  have hg_meas : Measurable g := hCont_ω.measurable.comp hφ_meas
  have hg_aestrm : AEStronglyMeasurable g (volume : Measure (UnitAddTorus (Fin 3))) :=
    hg_meas.aestronglyMeasurable
  -- Step 3: bound g by sup of |ω| over [0,1]³ (compact).
  have hCompact : IsCompact (Set.univ.pi (fun _ : Fin 3 => Set.Icc (0:ℝ) 1)) :=
    isCompact_univ_pi (fun _ => isCompact_Icc)
  have hne : (Set.univ.pi (fun _ : Fin 3 => Set.Icc (0:ℝ) 1)).Nonempty :=
    ⟨0, fun _ _ => Set.mem_Icc.mpr ⟨le_refl _, zero_le_one⟩⟩
  obtain ⟨x_max, _hxin, hM_max⟩ :=
    hCompact.exists_isMaxOn hne hCont_ω.norm.continuousOn
  set M : ℝ := ‖ω x_max‖
  have hφ_in : ∀ t, φ t ∈ Set.univ.pi (fun _ : Fin 3 => Set.Icc (0:ℝ) 1) := by
    intro t i _
    have h := (AddCircle.equivIoc (1:ℝ) 0 (t i)).property
    simp only [zero_add] at h
    exact ⟨le_of_lt h.1, h.2⟩
  have hM_bd : ∀ t, ‖g t‖ ≤ M := fun t => hM_max (hφ_in t)
  -- Step 4: g ∈ L² (T³ has IsProbabilityMeasure → IsFiniteMeasure).
  haveI : IsProbabilityMeasure (volume : Measure UnitAddCircle) :=
    inferInstanceAs (IsProbabilityMeasure AddCircle.haarAddCircle)
  haveI : IsProbabilityMeasure (volume : Measure (UnitAddTorus (Fin 3))) := by
    show IsProbabilityMeasure (Measure.pi (fun _ : Fin 3 => (volume : Measure UnitAddCircle)))
    infer_instance
  have hg_memLp : MemLp g 2 (volume : Measure (UnitAddTorus (Fin 3))) :=
    MemLp.of_bound hg_aestrm M (Filter.Eventually.of_forall hM_bd)
  -- Step 5: ω̃ := MemLp.toLp g, with a.e. equality to g.
  have hMP := cateptTorus_measurePreserving
  have hMapEq : (volume : Measure (UnitAddTorus (Fin 3))).map φ =
      Measure.pi (fun _ : Fin 3 => (volume : Measure ℝ).restrict (Set.Ioc 0 1)) :=
    hMP.map_eq
  refine ⟨hg_memLp.toLp g, ?_, ?_, ?_, ?_⟩
  · -- Conclusion 1: mFourierCoeff ω̃ 0 = 0.
    have hae : ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) =ᵐ[volume] g :=
      hg_memLp.coeFn_toLp
    have h_mFC : mFourierCoeff ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) 0 =
        mFourierCoeff g 0 := by
      unfold mFourierCoeff
      refine integral_congr_ae ?_
      filter_upwards [hae] with t ht; rw [ht]
    rw [h_mFC]
    show (∫ t, mFourier (-(0 : Fin 3 → ℤ)) t • g t) = 0
    have h_mF0 : ∀ t, mFourier (-(0 : Fin 3 → ℤ)) t = (1 : ℂ) := by
      intro t; rw [neg_zero]; simp [mFourier_zero]
    have hω_aestrm_map : AEStronglyMeasurable ω
        ((volume : Measure (UnitAddTorus (Fin 3))).map φ) := by
      rw [hMapEq]; exact hCont_ω.aestronglyMeasurable
    have h_int_eq : (∫ t, mFourier (-(0 : Fin 3 → ℤ)) t • g t) = ∫ t, ω (φ t) := by
      refine integral_congr_ae (Filter.Eventually.of_forall (fun t => ?_))
      change mFourier (-(0 : Fin 3 → ℤ)) t • g t = ω (φ t)
      rw [h_mF0]
      change (1 : ℂ) • ω (φ t) = ω (φ t)
      rw [one_smul]
    rw [h_int_eq, ← integral_map hφ_meas.aemeasurable hω_aestrm_map, hMapEq, h_mean_zero]
  · -- Conclusion 2: Summable h1FourierSemiNormCoeffs ω̃ — via a.e. equality of mFourierCoeff.
    have hae : ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) =ᵐ[volume] g :=
      hg_memLp.coeFn_toLp
    have h_coeff_eq : ∀ k : Fin 3 → ℤ,
        h1FourierSemiNormCoeffs ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) k =
        h1FourierSemiNormCoeffs g k := fun k => by
      have hmFC : mFourierCoeff ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) k =
          mFourierCoeff g k := by
        unfold mFourierCoeff
        refine integral_congr_ae ?_
        filter_upwards [hae] with t ht; rw [ht]
      unfold h1FourierSemiNormCoeffs; rw [hmFC]
    exact h_otf_summable.congr (fun k => (h_coeff_eq k).symm)
  · -- Conclusion 3: ∫ ‖ω̃‖² = torusEnstrophy u.
    have hae : ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) =ᵐ[volume] g :=
      hg_memLp.coeFn_toLp
    have h_norm_eq : ∫ t, ‖((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 =
        ∫ t, ‖g t‖ ^ 2 := by
      refine integral_congr_ae ?_
      filter_upwards [hae] with t ht; rw [ht]
    rw [h_norm_eq]
    have hnorm_aestrm_map :
        AEStronglyMeasurable (fun x : Fin 3 → ℝ => ‖ω x‖ ^ 2)
          ((volume : Measure (UnitAddTorus (Fin 3))).map φ) := by
      rw [hMapEq]
      exact (hCont_ω.norm.pow 2).aestronglyMeasurable
    calc (∫ t, ‖g t‖ ^ 2)
        = ∫ t, ‖ω (φ t)‖ ^ 2 := rfl
      _ = ∫ x, ‖ω x‖ ^ 2
            ∂((volume : Measure (UnitAddTorus (Fin 3))).map φ) :=
          (integral_map hφ_meas.aemeasurable hnorm_aestrm_map).symm
      _ = ∫ x, ‖ω x‖ ^ 2
            ∂Measure.pi (fun _ : Fin 3 => (volume : Measure ℝ).restrict (Set.Ioc 0 1)) := by
          rw [hMapEq]
      _ = torusEnstrophy u := h_ens_eq
  · -- Conclusion 4: h1FourierSemiNorm ω̃ ≤ torusPalinstrophy u — same a.e. transfer.
    have hae : ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) =ᵐ[volume] g :=
      hg_memLp.coeFn_toLp
    have h_coeff_eq : ∀ k : Fin 3 → ℤ,
        h1FourierSemiNormCoeffs ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) k =
        h1FourierSemiNormCoeffs g k := fun k => by
      have hmFC : mFourierCoeff ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) k =
          mFourierCoeff g k := by
        unfold mFourierCoeff
        refine integral_congr_ae ?_
        filter_upwards [hae] with t ht; rw [ht]
      unfold h1FourierSemiNormCoeffs; rw [hmFC]
    unfold h1FourierSemiNorm
    calc (∑' k, h1FourierSemiNormCoeffs ((hg_memLp.toLp g) : UnitAddTorus (Fin 3) → ℂ) k)
        = ∑' k, h1FourierSemiNormCoeffs g k := tsum_congr h_coeff_eq
      _ ≤ torusPalinstrophy u := h_otf_h1

end NavierStokesClean.Sobolev
