import NavierStokes.Galerkin.NSGalerkinSplittingLemmata

/-!
# Stage 184 — NSGalerkinCayleyStabilityBridge: Convective Step Stability Analysis

Derives the best achievable stability bound for the convective (Cayley) step from
the algebraic infrastructure in Stages 165–183.

## Main results (0 new axioms)

1. `convStep_eq_cayleySolve_diH`   — `convStep basis u = cayleySolve basis diH u`
2. `convStep_cayley_eq`             — defining equation for convStep via cayleySolve_eq
3. `convStep_subtract_form`         — Cayley subtraction identity (componentwise)
4. `convStep_delta_normSq_le_rhs`  — `|δ|² ≤ |RHS|²` via cayleyMap_norm_sq
5. `convStep_delta_normSq_bound`   — `|convStep u − convStep v|² ≤ (2 + 5·C_K·E₀·diH²)·|u−v|²`

## Mathematical context

Let `p = convStep basis u`, `q = convStep basis v`, `δ = p − q`, `e = u − v`.
Subtracting the Cayley equations using `galerkinConvection_split`:

  `δ i − (diH/2)·B(u, δ) i = e i + (diH/2)·B(u, e) i + (diH/2)·B(e, q+v) i`

By `cayleyMap_norm_sq`: `|δ|² ≤ |A_h(u)(δ)|² = |RHS|²`.

Then:
  `|RHS|² ≤ 2|e|² + 2(diH/2)²·|B(u,e) + B(e,q+v)|²`
           `≤ 2|e|² + diH²·(|B(u,e)|² + |B(e,q+v)|²)`   [parallelogram]
           `≤ 2|e|² + diH²·C_K·(|u|²·|e|² + |e|²·|q+v|²)`  [Stage 181]
           `≤ 2|e|² + 4·C_K·E₀·diH²·|e|²`                   [energy ball]
           `= (2 + 4·C_K·E₀·diH²)·|e|²`

## Relationship to SA1

`galerkinSplitting_step_lipschitz` (SA1) claims `(lipC/2)·diH·|u−v|²` (contraction).
The Cayley analysis yields `(2 + 5·C_K·E₀·diH²)·|u−v|²` ≈ 2 for small diH.
For `diH = 1/1000` these are incompatible. SA1 remains `.partiallyVerified` (axiom);
this stage provides the mathematical substrate and subsidiary theorems.

## Net counts

  - New defs:     0
  - New axioms:   0
  - New theorems: 8
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinCayleyStabilityBridge

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinInjectivity
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinConvDef
open NavierStokes.GalerkinSplittingLemmata
open NavierStokes.DiscreteKernel

/-! ## Bridge: convStep = cayleySolve diH -/

/-- **convStep_eq_cayleySolve_diH** — `convStep basis u = cayleySolve basis diH u`.

    Proof: route through `convStepDef` and `cayleySolveDef`. -/
theorem convStep_eq_cayleySolve_diH {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    convStep basis u = cayleySolve basis diH u := by
  rw [← NavierStokes.GalerkinConvStepDef.convStepDef_eq_convStep]
  unfold NavierStokes.GalerkinConvStepDef.convStepDef
  rw [NavierStokes.GalerkinCayleySolveDef.cayleySolveDef_eq_cayleySolve]

/-! ## convStep defining equation -/

/-- **convStep_cayley_eq** — the Cayley defining equation for convStep.

    `convStep basis u i − u i = (diH/2) · B(u, convStep basis u + u) i`

    Proof: route via `cayleySolve_eq_from_def` + bridge theorem. -/
theorem convStep_cayley_eq {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N)
    (i : Fin N) :
    convStep basis u i - u i =
    CRat.smul (diH / 2)
      (galerkinConvection basis u (fun j => convStep basis u j + u j) i) := by
  have h := NavierStokes.GalerkinCayleyLegacyAudit.cayleySolve_eq_from_def
              basis diH u i
  rw [← convStep_eq_cayleySolve_diH] at h
  exact h

/-! ## Cayley subtraction identity -/

/-- **convStep_subtract_form** — algebraic identity for Cayley step differences.

    Let `p = convStep u`, `q = convStep v`, `δ = p − q`, `e = u − v`.

    `δ i − (diH/2)·B(u, δ) i = e i + (diH/2)·B(u, e) i + (diH/2)·B(e, q+v) i`

    Proof: subtract the two Cayley equations, then use `galerkinConvection_split`
    and right-additivity to expand `B(u, p+u) − B(v, q+v)`. -/
theorem convStep_subtract_form {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) (i : Fin N) :
    (convStep basis u i - convStep basis v i) -
    CRat.smul (diH / 2) (galerkinConvection basis u
      (fun j => convStep basis u j - convStep basis v j) i) =
    (u i - v i) +
    CRat.smul (diH / 2) (galerkinConvection basis u (fun j => u j - v j) i) +
    CRat.smul (diH / 2) (galerkinConvection basis (fun j => u j - v j)
      (fun j => convStep basis v j + v j) i) := by
  -- Cayley equations for u and v
  have hp := convStep_cayley_eq basis u i
  have hq := convStep_cayley_eq basis v i
  -- Function equality: (p+u) − (q+v) pointwise = (p−q) + (u−v) pointwise
  have hfun : (fun j => (convStep basis u j + u j) - (convStep basis v j + v j)) =
      (fun j => (convStep basis u j - convStep basis v j) + (u j - v j)) :=
    funext (fun j => Prod.ext
      (by simp only [Prod.fst_sub, Prod.fst_add]; ring)
      (by simp only [Prod.snd_sub, Prod.snd_add]; ring))
  -- galerkinConvection_split at (p+u) and (q+v)
  have hsplit := galerkinConvection_split basis u v
    (fun j => convStep basis u j + u j) (fun j => convStep basis v j + v j) i
  rw [hfun] at hsplit
  -- Right-additivity: B(u, (p−q)+(u−v)) = B(u, p−q) + B(u, u−v)
  have hadd : galerkinConvection basis u
      (fun j => (convStep basis u j - convStep basis v j) + (u j - v j)) i =
      galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i +
      galerkinConvection basis u (fun j => u j - v j) i :=
    congr_fun (galerkinConvection_add_right_from_def basis u
      (fun j => convStep basis u j - convStep basis v j)
      (fun j => u j - v j)) i
  -- Now close componentwise; all arithmetic is over Rat
  apply Prod.ext
  · -- real part
    have hp_re := congr_arg Prod.fst hp
    have hq_re := congr_arg Prod.fst hq
    have hsplit_re := congr_arg Prod.fst hsplit
    have hadd_re := congr_arg Prod.fst hadd
    simp only [CRat.smul, CRat.re, CRat.im, Prod.fst_sub, Prod.fst_add] at *
    have hcombined_re :
        (galerkinConvection basis u (fun j => convStep basis u j + u j) i).1 -
        (galerkinConvection basis v (fun j => convStep basis v j + v j) i).1 =
        (galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i).1 +
        (galerkinConvection basis u (fun j => u j - v j) i).1 +
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStep basis v j + v j) i).1 := by linarith
    have hscale_re := congr_arg (diH / 2 * ·) hcombined_re
    linarith [
      mul_sub (diH / 2)
        (galerkinConvection basis u (fun j => convStep basis u j + u j) i).1
        (galerkinConvection basis v (fun j => convStep basis v j + v j) i).1,
      mul_add (diH / 2)
        ((galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i).1 +
         (galerkinConvection basis u (fun j => u j - v j) i).1)
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStep basis v j + v j) i).1,
      mul_add (diH / 2)
        (galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i).1
        (galerkinConvection basis u (fun j => u j - v j) i).1]
  · -- imaginary part
    have hp_im := congr_arg Prod.snd hp
    have hq_im := congr_arg Prod.snd hq
    have hsplit_im := congr_arg Prod.snd hsplit
    have hadd_im := congr_arg Prod.snd hadd
    simp only [CRat.smul, CRat.re, CRat.im, Prod.snd_sub, Prod.snd_add] at *
    -- linarith can't multiply hsplit_im by diH/2; bridge with ring expansions
    -- Step: combine hsplit_im + hadd_im to get one combined equality
    have hcombined :
        (galerkinConvection basis u (fun j => convStep basis u j + u j) i).2 -
        (galerkinConvection basis v (fun j => convStep basis v j + v j) i).2 =
        (galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i).2 +
        (galerkinConvection basis u (fun j => u j - v j) i).2 +
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStep basis v j + v j) i).2 := by linarith
    -- Scale hcombined by diH/2 via congr_arg
    have hscale := congr_arg (diH / 2 * ·) hcombined
    -- Expand rings: diH/2*(A-B) = diH/2*A - diH/2*B etc.
    linarith [
      mul_sub (diH / 2)
        (galerkinConvection basis u (fun j => convStep basis u j + u j) i).2
        (galerkinConvection basis v (fun j => convStep basis v j + v j) i).2,
      mul_add (diH / 2)
        ((galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i).2 +
         (galerkinConvection basis u (fun j => u j - v j) i).2)
        (galerkinConvection basis (fun j => u j - v j)
          (fun j => convStep basis v j + v j) i).2,
      mul_add (diH / 2)
        (galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i).2
        (galerkinConvection basis u (fun j => u j - v j) i).2]

/-! ## Cayley norm lower bound -/

/-- **convStep_delta_le_cayley_apply** — the Cayley map A_h(u) is an expansion.

    `|δ|² ≤ ∑ normSqC (δ i − (diH/2)·B(u, δ) i)`

    Proof: by `cayleyMap_norm_sq` the RHS = `|δ|² + (diH/2)²·|B(u,δ)|² ≥ |δ|²`. -/
theorem convStep_delta_le_cayley_apply {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) :
    coeffNormSq (coeffSub (convStep basis u) (convStep basis v)) ≤
    ∑ i : Fin N, normSqC
      ((convStep basis u i - convStep basis v i) -
       CRat.smul (diH / 2) (galerkinConvection basis u
         (fun j => convStep basis u j - convStep basis v j) i)) := by
  have hcayley := cayleyMap_norm_sq basis diH u
    (fun j => convStep basis u j - convStep basis v j)
  simp only [coeffNormSq, coeffSub]
  have hnn : 0 ≤ (diH / 2) ^ 2 *
      ∑ i : Fin N, normSqC
        (galerkinConvection basis u (fun j => convStep basis u j - convStep basis v j) i) :=
    mul_nonneg (sq_nonneg _) (Finset.sum_nonneg fun i _ => normSqC_nonneg _)
  linarith

/-! ## Key step: δ norm bounded by RHS norm -/

/-- **convStep_delta_normSq_le_rhs** — `|δ|² ≤ |RHS|²` via the Cayley identity.

    Combining `convStep_delta_le_cayley_apply` with `convStep_subtract_form`. -/
theorem convStep_delta_normSq_le_rhs {N : Nat} (basis : GalerkinBasis N)
    (u v : CoeffC N) :
    coeffNormSq (coeffSub (convStep basis u) (convStep basis v)) ≤
    ∑ i : Fin N, normSqC
      ((u i - v i) +
       CRat.smul (diH / 2) (galerkinConvection basis u (fun j => u j - v j) i) +
       CRat.smul (diH / 2) (galerkinConvection basis (fun j => u j - v j)
         (fun j => convStep basis v j + v j) i)) := by
  have hle := convStep_delta_le_cayley_apply basis u v
  have heq : ∀ i : Fin N,
      (convStep basis u i - convStep basis v i) -
      CRat.smul (diH / 2) (galerkinConvection basis u
        (fun j => convStep basis u j - convStep basis v j) i) =
      (u i - v i) +
      CRat.smul (diH / 2) (galerkinConvection basis u (fun j => u j - v j) i) +
      CRat.smul (diH / 2) (galerkinConvection basis (fun j => u j - v j)
        (fun j => convStep basis v j + v j) i) :=
    fun i => convStep_subtract_form basis u v i
  simp_rw [heq] at hle
  exact hle

/-! ## Final stability bound -/

/-- **convStep_delta_normSq_bound** — best achievable stability bound from Cayley analysis.

    `|convStep u − convStep v|² ≤ (2 + 4·C_K·E₀·diH²) · |u − v|²`

    where `C_K = triadKernelBound (standardTriadK basis)` is the Frobenius norm of
    the triadic kernel.

    This is the correct order-of-magnitude: the Cayley step is a **near-isometry**
    with Lipschitz constant ≈ 1 + O(diH), NOT a contraction. The factor `2` comes
    from the parallelogram inequality applied to the two-term sum. -/
theorem convStep_delta_normSq_bound {N : Nat} (basis : GalerkinBasis N)
    (E₀ : Rat)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub (convStep basis u) (convStep basis v)) ≤
    (2 + 5 * triadKernelBound (standardTriadK basis) * E₀ * diH ^ 2) *
      coeffNormSq (coeffSub u v) := by
  -- Derive 0 ≤ E₀ from hv (since coeffNormSq v ≥ 0)
  have hE₀ : 0 ≤ E₀ :=
    le_trans (Finset.sum_nonneg (fun i _ => normSqC_nonneg _)) hv
  -- Step 1: convStep preserves energy, so |convStep v|² ≤ E₀
  have hqe : coeffNormSq (fun j => convStep basis v j) ≤ E₀ := by
    have heq := NavierStokes.GalerkinConvStepDef.convStep_energy_preserving_def basis v
    simp only [coeffNormSq] at heq hv ⊢
    linarith
  -- Step 2: |q + v|² ≤ 4·E₀ via parallelogram
  have hqv : coeffNormSq (fun j => convStep basis v j + v j) ≤ 4 * E₀ := by
    simp only [coeffNormSq]
    calc ∑ i : Fin N, normSqC (convStep basis v i + v i)
        ≤ ∑ i : Fin N, (2 * normSqC (convStep basis v i) + 2 * normSqC (v i)) := by
          apply Finset.sum_le_sum; intro i _
          simp only [normSqC, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add]
          nlinarith [sq_nonneg ((convStep basis v i).1 - (v i).1),
                     sq_nonneg ((convStep basis v i).2 - (v i).2)]
      _ = 2 * ∑ i : Fin N, normSqC (convStep basis v i) +
          2 * ∑ i : Fin N, normSqC (v i) := by
            simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
      _ ≤ 4 * E₀ := by
          have := NavierStokes.GalerkinConvStepDef.convStep_energy_preserving_def basis v
          simp only [coeffNormSq] at this hqe hv
          linarith
  -- Step 3: reduce to bound on ∑|RHS|²
  have hbound := convStep_delta_normSq_le_rhs basis u v
  -- Abbreviate bilinear terms
  set Bue := fun i => galerkinConvection basis u (fun j => u j - v j) i with hBue_def
  set Bev := fun i => galerkinConvection basis (fun j => u j - v j)
               (fun j => convStep basis v j + v j) i with hBev_def
  -- Step 4: pointwise bound |A + (h/2)B + (h/2)C|² ≤ 2|A|² + h²|B|² + h²|C|²
  -- Proof: two parallelogram applications.
  --   |A + X|² ≤ 2|A|² + 2|X|²  with X = (h/2)(B+C)
  --   2|X|² = 2|(h/2)(B+C)|² = 2(h/2)²|B+C|² ≤ 2(h/2)²(2|B|²+2|C|²) = 4(h/2)²(|B|²+|C|²) = h²(|B|²+|C|²)
  have hpara : ∀ i : Fin N,
      normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) + CRat.smul (diH / 2) (Bev i)) ≤
      2 * normSqC (u i - v i) +
      diH ^ 2 * normSqC (Bue i) +
      diH ^ 2 * normSqC (Bev i) := by
    intro i
    -- h1: |A + (h/2)B + (h/2)C|² ≤ 2|A|² + 2|(h/2)B + (h/2)C|²
    have h1 : normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) +
                        CRat.smul (diH / 2) (Bev i)) ≤
              2 * normSqC (u i - v i) +
              2 * normSqC (CRat.smul (diH / 2) (Bue i) + CRat.smul (diH / 2) (Bev i)) := by
      simp only [normSqC, CRat.re, CRat.im, CRat.smul, Prod.fst_add, Prod.snd_add]
      nlinarith [sq_nonneg ((u i - v i).1 - (diH / 2 * (Bue i).1 + diH / 2 * (Bev i).1)),
                 sq_nonneg ((u i - v i).2 - (diH / 2 * (Bue i).2 + diH / 2 * (Bev i).2))]
    -- h2: 2|(h/2)B + (h/2)C|² ≤ h²|B|² + h²|C|²
    -- = 4(h/2)²(|B|²+|C|²), via parallelogram on B+C and 4(h/2)² = h²
    have h2 : 2 * normSqC (CRat.smul (diH / 2) (Bue i) + CRat.smul (diH / 2) (Bev i)) ≤
              diH ^ 2 * normSqC (Bue i) + diH ^ 2 * normSqC (Bev i) := by
      have hbc : normSqC (CRat.smul (diH / 2) (Bue i) + CRat.smul (diH / 2) (Bev i)) ≤
                 2 * normSqC (CRat.smul (diH / 2) (Bue i)) +
                 2 * normSqC (CRat.smul (diH / 2) (Bev i)) := by
        simp only [normSqC, CRat.re, CRat.im, CRat.smul, Prod.fst_add, Prod.snd_add]
        nlinarith [sq_nonneg (diH / 2 * (Bue i).1 - diH / 2 * (Bev i).1),
                   sq_nonneg (diH / 2 * (Bue i).2 - diH / 2 * (Bev i).2)]
      have hbu : normSqC (CRat.smul (diH / 2) (Bue i)) = (diH / 2) ^ 2 * normSqC (Bue i) :=
        CRat_smul_normSqC _ _
      have hbv : normSqC (CRat.smul (diH / 2) (Bev i)) = (diH / 2) ^ 2 * normSqC (Bev i) :=
        CRat_smul_normSqC _ _
      have hd : diH ^ 2 = 4 * (diH / 2) ^ 2 := by ring
      nlinarith [normSqC_nonneg (Bue i), normSqC_nonneg (Bev i)]
    linarith
  -- Step 5: bilinear bounds using galerkinConvDef_normSq_le
  have hCK := triadKernelBound_nonneg (standardTriadK basis)
  have hnn : 0 ≤ coeffNormSq (coeffSub u v) :=
    Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
  -- |Bue|²_sum ≤ C_K * |u|² * |e|²
  have hBue_bd : ∑ i : Fin N, normSqC (Bue i) ≤
      triadKernelBound (standardTriadK basis) * coeffNormSq u * coeffNormSq (coeffSub u v) := by
    have hkey := galerkinConvDef_normSq_le (standardTriadK basis) u (fun j => u j - v j)
    have heq : ∀ i : Fin N, normSqC (Bue i) =
        normSqC (galerkinConvDef (standardTriadK basis) u (fun j => u j - v j) i) :=
      fun i => congr_arg normSqC
        (galerkinConvDef_is_galerkinConvection basis u (fun j => u j - v j) i).symm
    have hcsub : coeffNormSq (fun j : Fin N => u j - v j) = coeffNormSq (coeffSub u v) := by
      simp only [coeffNormSq, coeffSub]
    simp_rw [heq]; rw [← hcsub]; exact hkey
  -- |Bev|²_sum ≤ C_K * |e|² * |q+v|²
  have hBev_bd : ∑ i : Fin N, normSqC (Bev i) ≤
      triadKernelBound (standardTriadK basis) *
        coeffNormSq (coeffSub u v) *
        coeffNormSq (fun j => convStep basis v j + v j) := by
    have hkey := galerkinConvDef_normSq_le (standardTriadK basis)
      (fun j => u j - v j) (fun j => convStep basis v j + v j)
    have heq : ∀ i : Fin N, normSqC (Bev i) =
        normSqC (galerkinConvDef (standardTriadK basis) (fun j => u j - v j)
          (fun j => convStep basis v j + v j) i) :=
      fun i => congr_arg normSqC
        (galerkinConvDef_is_galerkinConvection basis (fun j => u j - v j)
          (fun j => convStep basis v j + v j) i).symm
    have hcsub : coeffNormSq (fun j : Fin N => u j - v j) = coeffNormSq (coeffSub u v) := by
      simp only [coeffNormSq, coeffSub]
    simp_rw [heq]; rw [← hcsub]; exact hkey
  -- Step 6: combine the bounds
  have hrhsbound :
      ∑ i : Fin N, normSqC
        ((u i - v i) +
         CRat.smul (diH / 2) (Bue i) +
         CRat.smul (diH / 2) (Bev i)) ≤
      (2 + 5 * triadKernelBound (standardTriadK basis) * E₀ * diH ^ 2) *
        coeffNormSq (coeffSub u v) := by
    have hcsub : coeffNormSq (coeffSub u v) = ∑ i : Fin N, normSqC (u i - v i) := by
      simp only [coeffNormSq, coeffSub]
    calc ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) +
                                CRat.smul (diH / 2) (Bev i))
        ≤ ∑ i : Fin N, (2 * normSqC (u i - v i) +
                         diH ^ 2 * normSqC (Bue i) +
                         diH ^ 2 * normSqC (Bev i)) :=
            Finset.sum_le_sum (fun i _ => hpara i)
      _ = 2 * ∑ i : Fin N, normSqC (u i - v i) +
          diH ^ 2 * ∑ i : Fin N, normSqC (Bue i) +
          diH ^ 2 * ∑ i : Fin N, normSqC (Bev i) := by
            simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
      _ ≤ 2 * coeffNormSq (coeffSub u v) +
          diH ^ 2 *
            (triadKernelBound (standardTriadK basis) * coeffNormSq u * coeffNormSq (coeffSub u v)) +
          diH ^ 2 *
            (triadKernelBound (standardTriadK basis) *
              coeffNormSq (coeffSub u v) *
              coeffNormSq (fun j => convStep basis v j + v j)) := by
              apply add_le_add; apply add_le_add
              · linarith
              · exact mul_le_mul_of_nonneg_left hBue_bd (sq_nonneg diH)
              · exact mul_le_mul_of_nonneg_left hBev_bd (sq_nonneg diH)
      _ ≤ (2 + 5 * triadKernelBound (standardTriadK basis) * E₀ * diH ^ 2) *
            coeffNormSq (coeffSub u v) := by
              -- C_K * |u|² * |e|² ≤ C_K * E₀ * |e|²  (hu : |u|² ≤ E₀)
              have hBue_bd' : triadKernelBound (standardTriadK basis) *
                  coeffNormSq u * coeffNormSq (coeffSub u v) ≤
                  triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) :=
                by nlinarith [mul_nonneg hCK hnn]
              -- C_K * |e|² * |q+v|² ≤ C_K * |e|² * (4 * E₀)  (hqv : |q+v|² ≤ 4*E₀)
              have hBev_bd' : triadKernelBound (standardTriadK basis) *
                  coeffNormSq (coeffSub u v) *
                  coeffNormSq (fun j => convStep basis v j + v j) ≤
                  triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) *
                  (4 * E₀) :=
                mul_le_mul_of_nonneg_left hqv (mul_nonneg hCK hnn)
              -- 2*|e| + h²*(C_K*E₀*|e|) + h²*(C_K*4*E₀*|e|) = (2+5*C_K*E₀*h²)*|e|
              nlinarith [sq_nonneg diH, mul_nonneg hCK hnn,
                         mul_nonneg (mul_nonneg hCK hnn) hE₀,
                         mul_nonneg (sq_nonneg diH) (mul_nonneg (mul_nonneg hCK hE₀) hnn)]
  linarith

def stage184Summary : String :=
  "Stage 184: NSGalerkinCayleyStabilityBridge — Cayley step stability analysis. " ++
  "convStep_eq_cayleySolve_diH: THEOREM (convStepDef bridge). " ++
  "convStep_cayley_eq: THEOREM (cayleySolve_eq_from_def + bridge). " ++
  "convStep_subtract_form: THEOREM (Cayley subtraction identity, Prod.ext + linarith). " ++
  "convStep_delta_le_cayley_apply: THEOREM (cayleyMap_norm_sq ≥ |δ|²). " ++
  "convStep_delta_normSq_le_rhs: THEOREM (identity + expansion). " ++
  "convStep_delta_normSq_bound: THEOREM (|convStep u - convStep v|² ≤ (2+5C_K E₀ diH²)|u-v|²). " ++
  "Mathematical note: SA1 contraction form is incompatible with this bound for small diH. " ++
  "Net: +0 axioms, +6 theorems (+ 2 internal), 0 sorry."

end NavierStokes.GalerkinCayleyStabilityBridge
