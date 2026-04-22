import NavierStokes.NSGalerkinCayleyNearIdentityBridge
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-!
# Stage 188 — NSGalerkinConvStepHBridge: h-Parametric Cayley Step

Introduces `convStepH basis h u := cayleySolveDef basis h u` — a Cayley convective
step at an *arbitrary* step size `h : Rat` — and proves that it is near-identity
stable for any `0 < h ≤ 1`:

  `|convStepH h u − convStepH h v|² ≤ (1 + (h/2)·(1 + 9·C_K·E₀)) · |u − v|²`

Combined with `viscStep_nonexpansive`, the full h-parametric splitting step

  `S_h := viscStep ν h ∘ convStepH h`

satisfies the same bound (the **h-parametric SA1 theorem**).

## Why this is SA1 as a theorem

The current `galerkinSplitting_step_lipschitz` axiom claims the O(h) contraction
form `(lipC/2)·h·|e|²` for the fixed-`convStep` scheme.  That statement is
mathematically problematic (the Cayley step is energy-preserving, not contracting),
so it cannot be derived from near-identity analysis.

For the *h-parametric scheme* with `convStepH`, the correct stability statement is:

  `|S_h u − S_h v|² ≤ (1 + (h/2)·L)·|u−v|²`

where `L = 1 + 9·C_K·E₀`.  This is proved here as a theorem (`galerkinFullStepH_near_identity`)
for any `h ≤ 1` (the working range for Grönwall estimates). The Grönwall factor
`(1 + (h/2)·L)^{T/h} → exp(L·T/2)` remains bounded for any fixed time T.

## Proof structure

`convStepH_near_identity` generalizes Stage 185's proof:

1. **`convStepH_cayley_eq`** — Cayley defining equation for general h
2. **`convStepH_subtract_form`** — algebraic identity for differences (generalizes Stage 184)
3. **`convStepH_delta_le_cayley_apply`** — `|δ|² ≤ |A_h(u)δ|²` (cayleyMap_norm_sq, general h)
4. **`convStepH_delta_normSq_le_rhs`** — `|δ|² ≤ ∑|e + α·Bue + α·Bev|²` (combines above)
5. **`convStepH_near_identity`** — main bound (needs `h ≤ 1` for `2α² ≤ α` absorption)
6. **`galerkinFullStepH_near_identity`** — full step = viscStep ∘ convStepH near-identity

## Net counts

  - New defs:     1  (convStepH)
  - New axioms:   0
  - New theorems: 8  (including 4 private helpers)
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 800000

namespace NavierStokes.GalerkinConvStepHBridge

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinConvDef
open NavierStokes.GalerkinSplittingLemmata
open NavierStokes.DiscreteKernel
open NavierStokes.GalerkinCayleyStabilityBridge
open NavierStokes.GalerkinCayleyNearIdentityBridge
open NavierStokes.GalerkinCayleySolveDef
open NavierStokes.GalerkinInjectivity

/-! ## h-Parametric convective step -/

/-- **h-Parametric Cayley convective step**: `convStepH basis h u := cayleySolveDef basis h u`.

    For `h = diH` this equals `convStep basis u` (via `convStepDef`).
    Unlike `convStep`, this depends on h explicitly, making the step size
    a first-class parameter for convergence analysis. -/
noncomputable def convStepH {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N) :
    CoeffC N :=
  cayleySolveDef basis h u

/-- **Energy preservation** for `convStepH`. -/
theorem convStepH_energy_preserving {N : Nat} (basis : GalerkinBasis N) (h : Rat)
    (u : CoeffC N) :
    coeffNormSq (convStepH basis h u) = coeffNormSq u := by
  simp only [coeffNormSq, convStepH]
  exact NavierStokes.GalerkinCayleyLegacyAudit.cayleySolveDef_energy_preserving basis h u

/-! ## Cayley defining equation for convStepH -/

/-- **convStepH_cayley_eq** — the Cayley defining equation for `convStepH basis h`.

    `convStepH basis h u i − u i = (h/2) · B(u, convStepH basis h u + u) i`

    Proof: unfold `convStepH`, rewrite via `cayleySolveDef_eq_cayleySolve`,
    then apply `cayleySolve_eq_from_def` (Stage 168, general h). -/
theorem convStepH_cayley_eq {N : Nat} (basis : GalerkinBasis N) (h : Rat) (u : CoeffC N)
    (i : Fin N) :
    convStepH basis h u i - u i =
    CRat.smul (h / 2)
      (galerkinConvection basis u (fun j => convStepH basis h u j + u j) i) := by
  simp only [convStepH]
  exact cayleySolveDef_eq basis h u i

/-! ## Cayley subtraction identity for convStepH -/

/-- **convStepH_subtract_form** — algebraic identity for Cayley step differences.

    Let `p = convStepH basis h u`, `q = convStepH basis h v`, `δ = p − q`, `e = u − v`.
    Then:

    `δ i − (h/2)·B(u, δ) i = e i + (h/2)·B(u, e) i + (h/2)·B(e, q+v) i`

    Proof: subtract the Cayley equations for u and v, use `galerkinConvection_split`
    to expand `B(u, p+u) − B(v, q+v)`, and right-additivity to split `B(u, (p−q)+(u−v))`.
    Identical to Stage 184 `convStep_subtract_form` with `h/2` in place of `diH/2`. -/
theorem convStepH_subtract_form {N : Nat} (basis : GalerkinBasis N) (h : Rat)
    (u v : CoeffC N) (i : Fin N) :
    (convStepH basis h u i - convStepH basis h v i) -
    CRat.smul (h / 2) (galerkinConvection basis u
      (fun j => convStepH basis h u j - convStepH basis h v j) i) =
    (u i - v i) +
    CRat.smul (h / 2) (galerkinConvection basis u (fun j => u j - v j) i) +
    CRat.smul (h / 2) (galerkinConvection basis (fun j => u j - v j)
      (fun j => convStepH basis h v j + v j) i) := by
  have hp := convStepH_cayley_eq basis h u i
  have hq := convStepH_cayley_eq basis h v i
  have hfun : (fun j => (convStepH basis h u j + u j) - (convStepH basis h v j + v j)) =
      (fun j => (convStepH basis h u j - convStepH basis h v j) + (u j - v j)) :=
    funext (fun j => Prod.ext
      (by simp only [Prod.fst_sub, Prod.fst_add]; ring)
      (by simp only [Prod.snd_sub, Prod.snd_add]; ring))
  have hsplit := galerkinConvection_split basis u v
    (fun j => convStepH basis h u j + u j) (fun j => convStepH basis h v j + v j) i
  rw [hfun] at hsplit
  have hadd : galerkinConvection basis u
      (fun j => (convStepH basis h u j - convStepH basis h v j) + (u j - v j)) i =
      galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i +
      galerkinConvection basis u (fun j => u j - v j) i :=
    congr_fun (galerkinConvection_add_right_from_def basis u
      (fun j => convStepH basis h u j - convStepH basis h v j)
      (fun j => u j - v j)) i
  apply Prod.ext
  · have hp_re := congr_arg Prod.fst hp
    have hq_re := congr_arg Prod.fst hq
    have hsplit_re := congr_arg Prod.fst hsplit
    have hadd_re := congr_arg Prod.fst hadd
    simp only [CRat.smul, CRat.re, CRat.im, Prod.fst_sub, Prod.fst_add] at *
    have hcombined_re :
        (galerkinConvection basis u (fun j => convStepH basis h u j + u j) i).1 -
        (galerkinConvection basis v (fun j => convStepH basis h v j + v j) i).1 =
        (galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i).1 +
        (galerkinConvection basis u (fun j => u j - v j) i).1 +
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStepH basis h v j + v j) i).1 := by linarith
    have hscale_re := congr_arg (h / 2 * ·) hcombined_re
    linarith [
      mul_sub (h / 2)
        (galerkinConvection basis u (fun j => convStepH basis h u j + u j) i).1
        (galerkinConvection basis v (fun j => convStepH basis h v j + v j) i).1,
      mul_add (h / 2)
        ((galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i).1 +
         (galerkinConvection basis u (fun j => u j - v j) i).1)
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStepH basis h v j + v j) i).1,
      mul_add (h / 2)
        (galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i).1
        (galerkinConvection basis u (fun j => u j - v j) i).1]
  · have hp_im := congr_arg Prod.snd hp
    have hq_im := congr_arg Prod.snd hq
    have hsplit_im := congr_arg Prod.snd hsplit
    have hadd_im := congr_arg Prod.snd hadd
    simp only [CRat.smul, CRat.re, CRat.im, Prod.snd_sub, Prod.snd_add] at *
    have hcombined :
        (galerkinConvection basis u (fun j => convStepH basis h u j + u j) i).2 -
        (galerkinConvection basis v (fun j => convStepH basis h v j + v j) i).2 =
        (galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i).2 +
        (galerkinConvection basis u (fun j => u j - v j) i).2 +
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStepH basis h v j + v j) i).2 := by linarith
    have hscale := congr_arg (h / 2 * ·) hcombined
    linarith [
      mul_sub (h / 2)
        (galerkinConvection basis u (fun j => convStepH basis h u j + u j) i).2
        (galerkinConvection basis v (fun j => convStepH basis h v j + v j) i).2,
      mul_add (h / 2)
        ((galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i).2 +
         (galerkinConvection basis u (fun j => u j - v j) i).2)
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStepH basis h v j + v j) i).2,
      mul_add (h / 2)
        (galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i).2
        (galerkinConvection basis u (fun j => u j - v j) i).2]

/-! ## Cayley norm lower bound for convStepH -/

/-- **convStepH_delta_le_cayley_apply** — `|δ|² ≤ |A_h(u)δ|²` for `convStepH`. -/
theorem convStepH_delta_le_cayley_apply {N : Nat} (basis : GalerkinBasis N)
    (h : Rat) (u v : CoeffC N) :
    coeffNormSq (coeffSub (convStepH basis h u) (convStepH basis h v)) ≤
    ∑ i : Fin N, normSqC
      ((convStepH basis h u i - convStepH basis h v i) -
       CRat.smul (h / 2) (galerkinConvection basis u
         (fun j => convStepH basis h u j - convStepH basis h v j) i)) := by
  have hcayley := cayleyMap_norm_sq basis h u
    (fun j => convStepH basis h u j - convStepH basis h v j)
  simp only [coeffNormSq, coeffSub]
  have hnn : 0 ≤ (h / 2) ^ 2 *
      ∑ i : Fin N, normSqC
        (galerkinConvection basis u (fun j => convStepH basis h u j - convStepH basis h v j) i) :=
    mul_nonneg (sq_nonneg _) (Finset.sum_nonneg fun i _ => normSqC_nonneg _)
  linarith

/-- **convStepH_delta_normSq_le_rhs** — `|δ|² ≤ ∑|e + α·Bue + α·Bev|²` for `convStepH`. -/
theorem convStepH_delta_normSq_le_rhs {N : Nat} (basis : GalerkinBasis N)
    (h : Rat) (u v : CoeffC N) :
    coeffNormSq (coeffSub (convStepH basis h u) (convStepH basis h v)) ≤
    ∑ i : Fin N, normSqC
      ((u i - v i) +
       CRat.smul (h / 2) (galerkinConvection basis u (fun j => u j - v j) i) +
       CRat.smul (h / 2) (galerkinConvection basis (fun j => u j - v j)
         (fun j => convStepH basis h v j + v j) i)) := by
  have hle := convStepH_delta_le_cayley_apply basis h u v
  have heq : ∀ i : Fin N,
      (convStepH basis h u i - convStepH basis h v i) -
      CRat.smul (h / 2) (galerkinConvection basis u
        (fun j => convStepH basis h u j - convStepH basis h v j) i) =
      (u i - v i) +
      CRat.smul (h / 2) (galerkinConvection basis u (fun j => u j - v j) i) +
      CRat.smul (h / 2) (galerkinConvection basis (fun j => u j - v j)
        (fun j => convStepH basis h v j + v j) i) :=
    fun i => convStepH_subtract_form basis h u v i
  simp_rw [heq] at hle
  exact hle

/-! ## Main near-identity bound for convStepH -/

/-- **Exact norm expansion**: `normSqC(a + r·b) = |a|² + 2r·⟨a,b⟩ + r²·|b|²`. -/
private lemma normSqC_add_smul_expand' (a b : CRat) (r : Rat) :
    normSqC (a + CRat.smul r b) =
    normSqC a + 2 * r * realInnerC a b + r ^ 2 * normSqC b := by
  simp only [normSqC, realInnerC, CRat.re, CRat.im, CRat.smul, Prod.fst_add, Prod.snd_add]
  ring

/-- **AM-GM for real inner product**: `2 · ⟨a, b⟩ ≤ |a|² + |b|²`. -/
private lemma two_realInnerC_le' (a b : CRat) :
    2 * realInnerC a b ≤ normSqC a + normSqC b := by
  simp only [normSqC, realInnerC, CRat.re, CRat.im]
  nlinarith [sq_nonneg (a.1 - b.1), sq_nonneg (a.2 - b.2)]

/-- **2α² ≤ α** for `α = h/2` when `h ≤ 1`. -/
private lemma two_alpha_sq_le_alpha_h {h : Rat} (hh : 0 < h) (hh1 : h ≤ 1) :
    2 * (h / 2) ^ 2 ≤ h / 2 := by
  nlinarith [sq_nonneg h]

/-- **h-Parametric near-identity stability**: for any `0 < h ≤ 1`,

  `|convStepH h u − convStepH h v|² ≤ (1 + (h/2)·(1 + 9·C_K·E₀)) · |u − v|²`

Proof: identical strategy to Stage 185 (`convStep_near_identity`), generalized from
`diH` to arbitrary `h ≤ 1`. The only change is `two_alpha_sq_le_alpha_h` in place of
`two_alpha_sq_le_alpha`. -/
theorem convStepH_near_identity {N : Nat} (basis : GalerkinBasis N)
    (h E₀ : Rat) (hh : 0 < h) (hh1 : h ≤ 1)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub (convStepH basis h u) (convStepH basis h v)) ≤
    (1 + h / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
      coeffNormSq (coeffSub u v) := by
  have hE₀ : 0 ≤ E₀ := le_trans (Finset.sum_nonneg (fun i _ => normSqC_nonneg _)) hv
  have hCK  := triadKernelBound_nonneg (standardTriadK basis)
  have hnn  : 0 ≤ coeffNormSq (coeffSub u v) :=
    Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
  have hα_pos : (0 : Rat) < h / 2 := div_pos hh (by norm_num)
  -- Step 1: apply delta bound (convStepH version)
  have hS := convStepH_delta_normSq_le_rhs basis h u v
  -- Abbreviate bilinear terms
  set Bue : Fin N → CRat :=
    fun i => galerkinConvection basis u (fun j => u j - v j) i
  set Bev : Fin N → CRat :=
    fun i => galerkinConvection basis (fun j => u j - v j)
               (fun j => convStepH basis h v j + v j) i
  -- convStepH preserves energy → |convStepH h v|² = |v|² ≤ E₀
  have hqe : coeffNormSq (fun j => convStepH basis h v j) ≤ E₀ := by
    have heq := convStepH_energy_preserving basis h v
    simp only [coeffNormSq] at heq hv ⊢; linarith
  -- |q + v|² ≤ 4·E₀
  have hqv : coeffNormSq (fun j => convStepH basis h v j + v j) ≤ 4 * E₀ := by
    simp only [coeffNormSq]
    calc ∑ i : Fin N, normSqC (convStepH basis h v i + v i)
        ≤ ∑ i : Fin N, (2 * normSqC (convStepH basis h v i) + 2 * normSqC (v i)) := by
          apply Finset.sum_le_sum; intro i _
          simp only [normSqC, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add]
          nlinarith [sq_nonneg ((convStepH basis h v i).1 - (v i).1),
                     sq_nonneg ((convStepH basis h v i).2 - (v i).2)]
      _ = 2 * ∑ i : Fin N, normSqC (convStepH basis h v i) +
          2 * ∑ i : Fin N, normSqC (v i) := by
            simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
      _ ≤ 4 * E₀ := by
          have heq := convStepH_energy_preserving basis h v
          simp only [coeffNormSq] at heq hqe hv; linarith
  -- Bilinear bounds (same as Stage 185)
  have hBue_bd :
      ∑ i : Fin N, normSqC (Bue i) ≤
      triadKernelBound (standardTriadK basis) * coeffNormSq u * coeffNormSq (coeffSub u v) := by
    have hkey := galerkinConvDef_normSq_le (standardTriadK basis) u (fun j => u j - v j)
    have heq : ∀ i : Fin N, normSqC (Bue i) =
        normSqC (galerkinConvDef (standardTriadK basis) u (fun j => u j - v j) i) :=
      fun i => congr_arg normSqC
        (galerkinConvDef_is_galerkinConvection basis u (fun j => u j - v j) i).symm
    have hcsub : coeffNormSq (fun j : Fin N => u j - v j) = coeffNormSq (coeffSub u v) := by
      simp only [coeffNormSq, coeffSub]
    simp_rw [heq]; rw [← hcsub]; exact hkey
  have hBev_bd :
      ∑ i : Fin N, normSqC (Bev i) ≤
      triadKernelBound (standardTriadK basis) *
        coeffNormSq (coeffSub u v) *
        coeffNormSq (fun j => convStepH basis h v j + v j) := by
    have hkey := galerkinConvDef_normSq_le (standardTriadK basis)
      (fun j => u j - v j) (fun j => convStepH basis h v j + v j)
    have heq : ∀ i : Fin N, normSqC (Bev i) =
        normSqC (galerkinConvDef (standardTriadK basis) (fun j => u j - v j)
          (fun j => convStepH basis h v j + v j) i) :=
      fun i => congr_arg normSqC
        (galerkinConvDef_is_galerkinConvection basis (fun j => u j - v j)
          (fun j => convStepH basis h v j + v j) i).symm
    have hcsub : coeffNormSq (fun j : Fin N => u j - v j) = coeffNormSq (coeffSub u v) := by
      simp only [coeffNormSq, coeffSub]
    simp_rw [heq]; rw [← hcsub]; exact hkey
  -- Energy-bounded versions
  have hBue_E : ∑ i : Fin N, normSqC (Bue i) ≤
      triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) :=
    calc ∑ i : Fin N, normSqC (Bue i)
        ≤ triadKernelBound (standardTriadK basis) * coeffNormSq u * coeffNormSq (coeffSub u v) :=
          hBue_bd
      _ ≤ triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) := by
          nlinarith [mul_nonneg hCK hnn]
  have hBev_E : ∑ i : Fin N, normSqC (Bev i) ≤
      triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀) :=
    calc ∑ i : Fin N, normSqC (Bev i)
        ≤ triadKernelBound (standardTriadK basis) *
          coeffNormSq (coeffSub u v) *
          coeffNormSq (fun j => convStepH basis h v j + v j) := hBev_bd
      _ ≤ triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀) :=
          mul_le_mul_of_nonneg_left hqv (mul_nonneg hCK hnn)
  -- Step 2: exact expansion (reuse Stage 185's private lemma via definitional equality)
  have hexpand : ∀ i : Fin N,
      normSqC ((u i - v i) + CRat.smul (h / 2) (Bue i) + CRat.smul (h / 2) (Bev i)) =
      normSqC (u i - v i) +
      2 * (h / 2) * realInnerC (u i - v i) (Bue i + Bev i) +
      (h / 2) ^ 2 * normSqC (Bue i + Bev i) := fun i => by
    have hreg : (u i - v i) + CRat.smul (h / 2) (Bue i) + CRat.smul (h / 2) (Bev i) =
        (u i - v i) + CRat.smul (h / 2) (Bue i + Bev i) := by
      apply Prod.ext <;>
        simp only [CRat.smul, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add] <;> ring
    rw [hreg]; exact normSqC_add_smul_expand' _ _ _
  -- Sum the expansion
  have hexpand_sum :
      ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (h / 2) (Bue i) +
                             CRat.smul (h / 2) (Bev i)) =
      coeffNormSq (coeffSub u v) +
      2 * (h / 2) * ∑ i : Fin N, realInnerC (u i - v i) (Bue i + Bev i) +
      (h / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i) := by
    simp_rw [hexpand]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    have hcsub : ∑ i : Fin N, normSqC (u i - v i) = coeffNormSq (coeffSub u v) := by
      simp only [coeffNormSq, coeffSub]
    linarith
  -- Step 3: cancel ∑⟨e, Bue⟩ = 0
  have hinner_eq :
      ∑ i : Fin N, realInnerC (u i - v i) (Bue i + Bev i) =
      ∑ i : Fin N, realInnerC (u i - v i) (Bev i) := by
    have hsplit : ∀ i : Fin N,
        realInnerC (u i - v i) (Bue i + Bev i) =
        realInnerC (u i - v i) (Bue i) + realInnerC (u i - v i) (Bev i) :=
      fun i => NavierStokes.GalerkinConvDef.realInnerC_add_right _ _ _
    rw [Finset.sum_congr rfl (fun i _ => hsplit i), Finset.sum_add_distrib]
    have hcancel : ∑ i : Fin N, realInnerC (u i - v i) (Bue i) = 0 :=
      B_bilinear_self_zero basis u (fun j => u j - v j)
    linarith
  have hRHS :
      ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (h / 2) (Bue i) +
                             CRat.smul (h / 2) (Bev i)) =
      coeffNormSq (coeffSub u v) +
      2 * (h / 2) * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) +
      (h / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i) := by
    rw [hexpand_sum, hinner_eq]
  -- Step 4: AM-GM: 2*(h/2)*∑⟨e,Bev⟩ ≤ (h/2)*|e|² + (h/2)*∑|Bev|²
  have hamgm :
      2 * (h / 2) * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) ≤
      (h / 2) * coeffNormSq (coeffSub u v) +
      (h / 2) * ∑ i : Fin N, normSqC (Bev i) := by
    have hraw : 2 * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) ≤
        coeffNormSq (coeffSub u v) + ∑ i : Fin N, normSqC (Bev i) := by
      have hpt : ∑ i : Fin N, 2 * realInnerC (u i - v i) (Bev i) ≤
          ∑ i : Fin N, (normSqC (u i - v i) + normSqC (Bev i)) := by
        apply Finset.sum_le_sum; intro i _; exact two_realInnerC_le' (u i - v i) (Bev i)
      rw [Finset.sum_add_distrib] at hpt
      have hcsub : ∑ i : Fin N, normSqC (u i - v i) = coeffNormSq (coeffSub u v) := by
        simp only [coeffNormSq, coeffSub]
      have hfact : ∑ i : Fin N, 2 * realInnerC (u i - v i) (Bev i) =
          2 * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) := by
        simp_rw [← Finset.mul_sum]
      linarith
    have hBev_nn : 0 ≤ ∑ i : Fin N, normSqC (Bev i) :=
      Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
    nlinarith [le_of_lt hα_pos, hraw, hBev_nn]
  -- Step 5: parallelogram for ∑|Bue + Bev|²
  have hpara_sum :
      ∑ i : Fin N, normSqC (Bue i + Bev i) ≤
      2 * ∑ i : Fin N, normSqC (Bue i) + 2 * ∑ i : Fin N, normSqC (Bev i) :=
    calc ∑ i : Fin N, normSqC (Bue i + Bev i)
        ≤ ∑ i : Fin N, (2 * normSqC (Bue i) + 2 * normSqC (Bev i)) := by
          apply Finset.sum_le_sum; intro i _
          simp only [normSqC, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add]
          nlinarith [sq_nonneg ((Bue i).1 - (Bev i).1),
                     sq_nonneg ((Bue i).2 - (Bev i).2)]
      _ = 2 * ∑ i : Fin N, normSqC (Bue i) + 2 * ∑ i : Fin N, normSqC (Bev i) := by
          simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
  -- Step 6: bound (h/2)²·∑|Bue+Bev|²
  have hquad :
      (h / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i) ≤
      2 * (h / 2) ^ 2 *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) +
      2 * (h / 2) ^ 2 *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) := by
    have hBev_E4 : ∑ i : Fin N, normSqC (Bev i) ≤
        triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4 := by
      nlinarith [mul_nonneg (mul_nonneg hCK hnn) hE₀]
    calc (h / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i)
        ≤ (h / 2) ^ 2 *
          (2 * ∑ i : Fin N, normSqC (Bue i) + 2 * ∑ i : Fin N, normSqC (Bev i)) :=
            mul_le_mul_of_nonneg_left hpara_sum (sq_nonneg _)
      _ ≤ (h / 2) ^ 2 *
          (2 * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) +
           2 * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4)) := by
            apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
            have hBue_nn : 0 ≤ ∑ i : Fin N, normSqC (Bue i) :=
              Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
            have h1 : 2 * ∑ i : Fin N, normSqC (Bue i) ≤
                2 * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) :=
              by nlinarith [hBue_E, hBue_nn]
            have hBev_scaled : 2 * ∑ i : Fin N, normSqC (Bev i) ≤
                2 * (triadKernelBound (standardTriadK basis) * E₀ *
                     coeffNormSq (coeffSub u v) * 4) :=
              mul_le_mul_of_nonneg_left hBev_E4 (by norm_num)
            linarith [h1, hBev_scaled]
      _ = 2 * (h / 2) ^ 2 *
            (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) +
          2 * (h / 2) ^ 2 *
            (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) := by
              ring
  -- Step 7: assemble using 2α² ≤ α (h ≤ 1)
  have hα_sq := two_alpha_sq_le_alpha_h hh hh1
  have hS_le :
      ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (h / 2) (Bue i) +
                             CRat.smul (h / 2) (Bev i)) ≤
      (1 + h / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
        coeffNormSq (coeffSub u v) := by
    rw [hRHS]
    have hamgm_E :
        (h / 2) * coeffNormSq (coeffSub u v) +
        (h / 2) * ∑ i : Fin N, normSqC (Bev i) ≤
        (h / 2) * coeffNormSq (coeffSub u v) +
        (h / 2) *
          (triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀)) := by
      have h := mul_le_mul_of_nonneg_left hBev_E (le_of_lt hα_pos)
      linarith
    have habs1 :
        2 * (h / 2) ^ 2 *
          (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) ≤
        (h / 2) * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) :=
      mul_le_mul_of_nonneg_right hα_sq (mul_nonneg (mul_nonneg hCK hE₀) hnn)
    have habs2 :
        2 * (h / 2) ^ 2 *
          (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) ≤
        (h / 2) * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) :=
      mul_le_mul_of_nonneg_right hα_sq
        (mul_nonneg (mul_nonneg (mul_nonneg hCK hE₀) hnn) (by norm_num))
    have hring1 : (h / 2) *
        (triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀)) =
        4 * (h / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    have hring2 : (h / 2) *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) =
        (h / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    have hring3 : (h / 2) *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) =
        4 * (h / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    have hgoal_ring :
        (1 + h / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
        coeffNormSq (coeffSub u v) =
        coeffNormSq (coeffSub u v) +
        (h / 2) * coeffNormSq (coeffSub u v) +
        9 * (h / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    linarith [mul_nonneg (mul_nonneg hCK hE₀) hnn,
              mul_nonneg (le_of_lt hα_pos) (mul_nonneg (mul_nonneg hCK hE₀) hnn)]
  linarith [hS, hS_le]

/-! ## Full h-parametric splitting step near-identity -/

/-- **h-Parametric SA1 theorem**: the full splitting step `viscStep ν h ∘ convStepH h`
    is near-identity stable for any `0 < h ≤ 1`:

  `|S_h u − S_h v|² ≤ (1 + (h/2)·(1 + 9·C_K·E₀)) · |u − v|²`

Proof: `viscStep_nonexpansive` (any h > 0) + `convStepH_near_identity`. -/
theorem galerkinFullStepH_near_identity {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h u))
      (viscStep basis ν h (convStepH basis h v))) ≤
    (1 + h / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
      coeffNormSq (coeffSub u v) :=
  calc coeffNormSq (coeffSub
          (viscStep basis ν h (convStepH basis h u))
          (viscStep basis ν h (convStepH basis h v)))
      ≤ coeffNormSq (coeffSub (convStepH basis h u) (convStepH basis h v)) :=
          viscStep_nonexpansive basis ν h hν hh (convStepH basis h u) (convStepH basis h v)
    _ ≤ (1 + h / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
          coeffNormSq (coeffSub u v) :=
          convStepH_near_identity basis h E₀ hh hh1 u v hu hv

def stage188Summary : String :=
  "Stage 188: NSGalerkinConvStepHBridge — h-parametric Cayley step near-identity. " ++
  "convStepH: DEF (cayleySolveDef basis h u). " ++
  "convStepH_energy_preserving: THEOREM. " ++
  "convStepH_cayley_eq: THEOREM (cayleySolve_eq_from_def, general h). " ++
  "convStepH_subtract_form: THEOREM (algebraic identity, Stage 184 generalized). " ++
  "convStepH_delta_le_cayley_apply: THEOREM (cayleyMap_norm_sq, general h). " ++
  "convStepH_delta_normSq_le_rhs: THEOREM (combining above). " ++
  "convStepH_near_identity: THEOREM (|convStepH h u - convStepH h v|² ≤ (1+L·h)|u-v|², h≤1). " ++
  "galerkinFullStepH_near_identity: THEOREM (full step SA1 for h-parametric scheme). " ++
  "Net: +1 def, +0 axioms, +8 theorems (1 private), 0 sorry."

end NavierStokes.GalerkinConvStepHBridge
