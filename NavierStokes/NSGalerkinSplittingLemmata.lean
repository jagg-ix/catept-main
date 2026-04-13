import NavierStokes.NSGalerkinSplittingCore
import NavierStokes.NSGalerkinCayleyBridge
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-!
# Stage 181 — NSGalerkinSplittingLemmata: Foundational Bounds for the One-Step Recurrence

Proves all zero-axiom consequences of the existing infrastructure that are needed to
justify `galerkinSplitting_one_step_recurrence` and to make the `lipC`/`lteC` constants
explicit.  No new axioms.

## What is proved (0 new axioms)

1. **`normSqC_CRat_mul`** — `normSqC(z ⊗ w) = normSqC z * normSqC w` (ring)
2. **`CRat_smul_normSqC`** — `normSqC(r · z) = r² · normSqC z` (ring)
3. **`coeffSub_viscStep`** — `coeffSub (viscStep u) (viscStep v) = viscStep (coeffSub u v)`;
   viscStep is mode-indexed (denom depends only on the wavevector, not on u), so it
   commutes with pointwise subtraction exactly.
4. **`viscStep_nonexpansive`** — `coeffNormSq(S_visc u − S_visc v) ≤ coeffNormSq(u − v)`
   Direct consequence of (3) + `viscStep_energy_le`.
5. **`triadKernelBound`** — `∑ k j l, K(k,j,l)²` — the Cauchy-Schwarz constant for `B`.
6. **`rat_cs_sq`** — `(∑ aᵢbᵢ)² ≤ (∑ aᵢ²)(∑ bᵢ²)` via Mathlib's `sum_mul_sq_le_sq_mul_sq`
7. **`normSqC_smul_sum_le`** — `normSqC(∑ᵢ rᵢ · zᵢ) ≤ (∑ rᵢ²) · ∑ normSqC(zᵢ)`
8. **`galerkinConvDef_normSq_le_mode`** — pointwise bilinear bound per output mode k
9. **`galerkinConvDef_normSq_le`** — `coeffNormSq(B(u,v)) ≤ triadKernelBound · |u|² · |v|²`

## Net counts

  - New defs:     1  (triadKernelBound)
  - New axioms:   0
  - New theorems: 9
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinSplittingLemmata

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinConvDef

/-! ## 1. normSqC is multiplicative under CRat.mul -/

/-- **Complex norm is multiplicative**: `normSqC(z ⊗ w) = normSqC z * normSqC w`. -/
theorem normSqC_CRat_mul (z w : CRat) :
    normSqC (CRat.mul z w) = normSqC z * normSqC w := by
  simp only [normSqC, CRat.mul, CRat.re, CRat.im]
  ring

/-- **Scalar scaling of normSqC**: `normSqC(r · z) = r² · normSqC z`. -/
theorem CRat_smul_normSqC (r : Rat) (z : CRat) :
    normSqC (CRat.smul r z) = r ^ 2 * normSqC z := by
  simp only [normSqC, CRat.smul, CRat.re, CRat.im]
  ring

/-! ## 2. viscStep commutes with subtraction -/

/-- The viscous step satisfies `viscStep u i − viscStep v i = viscStep (u − v) i`.
    The denominator depends only on mode `i`, not on the coefficients. -/
theorem viscStep_sub_linearInMode {N : Nat} (basis : GalerkinBasis N)
    (ν h : Rat) (u v : CoeffC N) (i : Fin N) :
    viscStep basis ν h u i - viscStep basis ν h v i =
    viscStep basis ν h (fun j => u j - v j) i := by
  simp only [viscStep, CRat.re, CRat.im]
  apply Prod.ext <;> simp [sub_div]

/-- **viscStep commutes with coeffSub**. -/
theorem coeffSub_viscStep {N : Nat} (basis : GalerkinBasis N)
    (ν h : Rat) (u v : CoeffC N) :
    coeffSub (viscStep basis ν h u) (viscStep basis ν h v) =
    viscStep basis ν h (coeffSub u v) := by
  funext i
  simp only [coeffSub]
  exact viscStep_sub_linearInMode basis ν h u v i

/-! ## 3. viscStep is non-expansive for differences -/

/-- **Viscous step is non-expansive** for differences. -/
theorem viscStep_nonexpansive {N : Nat} (basis : GalerkinBasis N)
    (ν h : Rat) (hν : 0 < ν) (hh : 0 < h) (u v : CoeffC N) :
    coeffNormSq (coeffSub (viscStep basis ν h u) (viscStep basis ν h v)) ≤
    coeffNormSq (coeffSub u v) := by
  rw [coeffSub_viscStep]
  exact viscStep_energy_le basis ν h hν hh (coeffSub u v)

/-! ## 4. Triadic kernel Cauchy-Schwarz constant -/

/-- **Triadic kernel bound** — the squared Frobenius norm of the convolution kernel. -/
noncomputable def triadKernelBound {N : Nat} (eb : ExtGalerkinBasis N) : Rat :=
  ∑ k : Fin N, ∑ j : Fin N, ∑ l : Fin N, (eb.triadK k j l) ^ 2

theorem triadKernelBound_nonneg {N : Nat} (eb : ExtGalerkinBasis N) :
    0 ≤ triadKernelBound eb :=
  Finset.sum_nonneg (fun _ _ =>
    Finset.sum_nonneg (fun _ _ =>
      Finset.sum_nonneg (fun _ _ => sq_nonneg _)))

/-! ## 5. Cauchy-Schwarz for Rat sums -/

/-- **Cauchy-Schwarz** `(∑ aᵢbᵢ)² ≤ (∑ aᵢ²)(∑ bᵢ²)` for Rat. -/
private theorem rat_cs_sq {ι : Type*} (s : Finset ι) (a b : ι → Rat) :
    (∑ i ∈ s, a i * b i) ^ 2 ≤ (∑ i ∈ s, a i ^ 2) * (∑ i ∈ s, b i ^ 2) :=
  Finset.sum_mul_sq_le_sq_mul_sq s a b

/-! ## 6. Cauchy-Schwarz for CRat-smul sums -/

/-- **Cauchy-Schwarz for `CRat.smul` sums**:
    `normSqC(∑ᵢ rᵢ · zᵢ) ≤ (∑ rᵢ²) · ∑ normSqC(zᵢ)`. -/
theorem normSqC_smul_sum_le {ι : Type*} (s : Finset ι)
    (r : ι → Rat) (z : ι → CRat) :
    normSqC (∑ i ∈ s, CRat.smul (r i) (z i)) ≤
    (∑ i ∈ s, (r i) ^ 2) * ∑ i ∈ s, normSqC (z i) := by
  -- Extract .1 and .2 of the sum using AddMonoidHom.map_sum
  have hre : (∑ i ∈ s, CRat.smul (r i) (z i)).1 = ∑ i ∈ s, r i * (z i).1 := by
    have h := map_sum (AddMonoidHom.fst Rat Rat) (fun i => CRat.smul (r i) (z i)) s
    simp only [AddMonoidHom.coe_fst, CRat.smul] at h
    exact h
  have him : (∑ i ∈ s, CRat.smul (r i) (z i)).2 = ∑ i ∈ s, r i * (z i).2 := by
    have h := map_sum (AddMonoidHom.snd Rat Rat) (fun i => CRat.smul (r i) (z i)) s
    simp only [AddMonoidHom.coe_snd, CRat.smul] at h
    exact h
  -- Apply component-wise Cauchy-Schwarz
  have hre' := rat_cs_sq s r (fun i => (z i).1)
  have him' := rat_cs_sq s r (fun i => (z i).2)
  -- Unfold normSqC and rewrite using the extracted components
  simp only [normSqC, CRat.re, CRat.im, hre, him]
  -- Goal: (∑ r_i z_i.1)^2 + (∑ r_i z_i.2)^2 ≤ (∑ r_i^2) * ∑ (z_i.1^2 + z_i.2^2)
  calc (∑ i ∈ s, r i * (z i).1) ^ 2 + (∑ i ∈ s, r i * (z i).2) ^ 2
      ≤ (∑ i ∈ s, (r i) ^ 2) * ∑ i ∈ s, (z i).1 ^ 2 +
        (∑ i ∈ s, (r i) ^ 2) * ∑ i ∈ s, (z i).2 ^ 2 :=
          add_le_add hre' him'
    _ = (∑ i ∈ s, (r i) ^ 2) * (∑ i ∈ s, (z i).1 ^ 2 + ∑ i ∈ s, (z i).2 ^ 2) := by
          ring
    _ = (∑ i ∈ s, (r i) ^ 2) * ∑ i ∈ s, ((z i).1 ^ 2 + (z i).2 ^ 2) := by
          rw [← Finset.sum_add_distrib]

/-! ## 7. Bilinear bound for galerkinConvDef -/

/-- **Pointwise bilinear bound** per output mode k:
    `normSqC(B(u,v)_k) ≤ (∑_{j,l} K(k,j,l)²) · coeffNormSq u · coeffNormSq v`. -/
theorem galerkinConvDef_normSq_le_mode {N : Nat} (eb : ExtGalerkinBasis N)
    (u v : CoeffC N) (k : Fin N) :
    normSqC (galerkinConvDef eb u v k) ≤
    (∑ j : Fin N, ∑ l : Fin N, (eb.triadK k j l) ^ 2) *
    (coeffNormSq u * coeffNormSq v) := by
  simp only [galerkinConvDef]
  -- Flatten double sums to product sums via Finset.sum_product'
  have hflat : ∑ j : Fin N, ∑ l : Fin N,
      CRat.smul (eb.triadK k j l) (CRat.mul (u j) (v l)) =
      ∑ p : Fin N × Fin N,
      CRat.smul (eb.triadK k p.1 p.2) (CRat.mul (u p.1) (v p.2)) := by
    rw [← Finset.sum_product', Finset.univ_product_univ]
  have hflat_sq : ∑ j : Fin N, ∑ l : Fin N, (eb.triadK k j l) ^ 2 =
      ∑ p : Fin N × Fin N, (eb.triadK k p.1 p.2) ^ 2 := by
    rw [← Finset.sum_product', Finset.univ_product_univ]
  -- Compute ∑_p normSqC(u_p.1 ⊗ v_p.2) = coeffNormSq u * coeffNormSq v
  have hprod : ∑ p : Fin N × Fin N, normSqC (CRat.mul (u p.1) (v p.2)) =
      coeffNormSq u * coeffNormSq v := by
    simp only [normSqC_CRat_mul, coeffNormSq]
    rw [← Finset.univ_product_univ, Finset.sum_product]
    simp_rw [← Finset.mul_sum]
    rw [← Finset.sum_mul]
  rw [hflat]
  calc normSqC (∑ p : Fin N × Fin N,
          CRat.smul (eb.triadK k p.1 p.2) (CRat.mul (u p.1) (v p.2)))
      ≤ (∑ p : Fin N × Fin N, (eb.triadK k p.1 p.2) ^ 2) *
        ∑ p : Fin N × Fin N, normSqC (CRat.mul (u p.1) (v p.2)) :=
          normSqC_smul_sum_le Finset.univ _ _
    _ = (∑ j : Fin N, ∑ l : Fin N, (eb.triadK k j l) ^ 2) *
        (coeffNormSq u * coeffNormSq v) := by
          rw [hflat_sq.symm, hprod]

/-- **Global bilinear bound**:
    `coeffNormSq(B(u,v)) ≤ triadKernelBound eb · coeffNormSq u · coeffNormSq v`. -/
theorem galerkinConvDef_normSq_le {N : Nat} (eb : ExtGalerkinBasis N)
    (u v : CoeffC N) :
    coeffNormSq (galerkinConvDef eb u v) ≤
    triadKernelBound eb * coeffNormSq u * coeffNormSq v := by
  unfold coeffNormSq triadKernelBound
  calc ∑ k : Fin N, normSqC (galerkinConvDef eb u v k)
      ≤ ∑ k : Fin N, ((∑ j : Fin N, ∑ l : Fin N, (eb.triadK k j l) ^ 2) *
          (coeffNormSq u * coeffNormSq v)) :=
        Finset.sum_le_sum (fun k _ => galerkinConvDef_normSq_le_mode eb u v k)
    _ = (∑ k : Fin N, ∑ j : Fin N, ∑ l : Fin N, (eb.triadK k j l) ^ 2) *
        coeffNormSq u * coeffNormSq v := by
          rw [← Finset.sum_mul]
          ring

def stage181Summary : String :=
  "Stage 181: NSGalerkinSplittingLemmata — foundational bounds for one-step recurrence. " ++
  "normSqC_CRat_mul: THEOREM (ring). " ++
  "CRat_smul_normSqC: THEOREM (ring). " ++
  "coeffSub_viscStep: THEOREM (sub commutes with viscStep). " ++
  "viscStep_nonexpansive: THEOREM (|visc u - visc v|² ≤ |u-v|²). " ++
  "triadKernelBound: DEF (∑_{k,j,l} K(k,j,l)²). " ++
  "rat_cs_sq: PRIVATE THEOREM (Finset.sum_mul_sq_le_sq_mul_sq). " ++
  "normSqC_smul_sum_le: THEOREM (AddMonoidHom.map_sum + CS). " ++
  "galerkinConvDef_normSq_le_mode: THEOREM (sum_product' + normSqC_smul_sum_le). " ++
  "galerkinConvDef_normSq_le: THEOREM (|B(u,v)|² ≤ triadKernelBound·|u|²·|v|²). " ++
  "Net: +0 axioms, +9 theorems (1 private), 0 sorry."

end NavierStokes.GalerkinSplittingLemmata
