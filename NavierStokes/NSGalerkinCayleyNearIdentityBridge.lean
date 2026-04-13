import NavierStokes.NSGalerkinCayleyStabilityBridge
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-!
# Stage 185 — NSGalerkinCayleyNearIdentityBridge: Sharp SA1 Bound

Proves the SA1-compatible near-identity stability bound for the convective step:

  `|convStep u − convStep v|² ≤ (1 + (diH/2)·(1 + 9·C_K·E₀)) · |u − v|²`

This replaces the crude `(2 + …)` bound of Stage 184. The leading constant `1`
(vs. `2`) is essential for Grönwall estimates to remain bounded over finite time.

## Proof strategy

Starting from `convStep_delta_normSq_le_rhs` (Stage 184):
  `|δ|² ≤ ∑ normSqC(e_i + α·Bue_i + α·Bev_i)` where `α = diH/2`

1. **Regroup**: `α·Bue + α·Bev = α·(Bue + Bev)` (CRat.smul linearity)
2. **Exact expansion**: `normSqC(e + α·B) = |e|² + 2α·⟨e,B⟩ + α²·|B|²`
3. **Cancellation**: `∑⟨e_i, Bue_i⟩ = 0` via `B_bilinear_self_zero`
4. **AM-GM**: `2⟨e,Bev⟩ ≤ |e|² + |Bev|²` (from `0 ≤ |e − Bev|²`)
5. **Parallelogram + bilinear bounds**: bound `α²·∑|Bue+Bev|²`
6. **Absorption**: `2α² ≤ α` since `2α = diH ≤ 1`

## Net counts

  - New defs:     0
  - New axioms:   0
  - New theorems: 5
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 800000

namespace NavierStokes.GalerkinCayleyNearIdentityBridge

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

/-! ## Auxiliary lemmas -/

/-- **Exact norm expansion**: `normSqC(a + r·b) = |a|² + 2r·⟨a,b⟩ + r²·|b|²`. -/
private lemma normSqC_add_smul_expand (a b : CRat) (r : Rat) :
    normSqC (a + CRat.smul r b) =
    normSqC a + 2 * r * realInnerC a b + r ^ 2 * normSqC b := by
  simp only [normSqC, realInnerC, CRat.re, CRat.im, CRat.smul, Prod.fst_add, Prod.snd_add]
  ring

/-- **AM-GM for real inner product**: `2 · ⟨a, b⟩ ≤ |a|² + |b|²`. -/
private lemma two_realInnerC_le (a b : CRat) :
    2 * realInnerC a b ≤ normSqC a + normSqC b := by
  simp only [normSqC, realInnerC, CRat.re, CRat.im]
  nlinarith [sq_nonneg (a.1 - b.1), sq_nonneg (a.2 - b.2)]

/-- **diH ≤ 1**: the step size is at most 1. -/
private lemma diH_le_one : diH ≤ 1 := by norm_num [diH, diN]

/-- **2α² ≤ α** where `α = diH/2`, since `diH = 1/1000`. -/
private lemma two_alpha_sq_le_alpha : 2 * (diH / 2) ^ 2 ≤ diH / 2 := by
  norm_num [diH, diN]

/-! ## Main near-identity bound -/

/-- **SA1-compatible stability**: `|convStep u − convStep v|² ≤ (1 + α(1 + 9·C_K·E₀)) · |u−v|²`
    where `α = diH/2`.

    The leading coefficient is **1** (not **2**), enabling finite-time Grönwall estimates. -/
theorem convStep_near_identity {N : Nat} (basis : GalerkinBasis N)
    (E₀ : Rat)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub (convStep basis u) (convStep basis v)) ≤
    (1 + diH / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
      coeffNormSq (coeffSub u v) := by
  -- Basic nonnegativity
  have hE₀ : 0 ≤ E₀ := le_trans (Finset.sum_nonneg (fun i _ => normSqC_nonneg _)) hv
  have hCK  := triadKernelBound_nonneg (standardTriadK basis)
  have hnn  : 0 ≤ coeffNormSq (coeffSub u v) :=
    Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
  have hα_pos : (0 : Rat) < diH / 2 := div_pos diH_pos (by norm_num)
  -- Step 1: apply Stage 184 bound (must be BEFORE set so that set rewrites in it)
  have hS := convStep_delta_normSq_le_rhs basis u v
  -- Abbreviate bilinear terms (same as Stage 184; set rewrites hS)
  set Bue : Fin N → CRat :=
    fun i => galerkinConvection basis u (fun j => u j - v j) i
  set Bev : Fin N → CRat :=
    fun i => galerkinConvection basis (fun j => u j - v j)
               (fun j => convStep basis v j + v j) i
  -- convStep preserves energy → |q|² ≤ E₀
  have hqe : coeffNormSq (fun j => convStep basis v j) ≤ E₀ := by
    have h := NavierStokes.GalerkinConvStepDef.convStep_energy_preserving_def basis v
    simp only [coeffNormSq] at h hv ⊢; linarith
  -- |q + v|² ≤ 4·E₀  (identical to Stage 184)
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
          have h := NavierStokes.GalerkinConvStepDef.convStep_energy_preserving_def basis v
          simp only [coeffNormSq] at h hqe hv; linarith
  -- Bilinear bounds (identical to Stage 184)
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
          coeffNormSq (fun j => convStep basis v j + v j) := hBev_bd
      _ ≤ triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀) :=
          mul_le_mul_of_nonneg_left hqv (mul_nonneg hCK hnn)
  -- Step 2: expand sum exactly
  -- Pointwise: e + α·Bue + α·Bev = e + α·(Bue + Bev), then use exact formula
  have hexpand : ∀ i : Fin N,
      normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) + CRat.smul (diH / 2) (Bev i)) =
      normSqC (u i - v i) +
      2 * (diH / 2) * realInnerC (u i - v i) (Bue i + Bev i) +
      (diH / 2) ^ 2 * normSqC (Bue i + Bev i) := fun i => by
    have hreg : (u i - v i) + CRat.smul (diH / 2) (Bue i) + CRat.smul (diH / 2) (Bev i) =
        (u i - v i) + CRat.smul (diH / 2) (Bue i + Bev i) := by
      apply Prod.ext <;>
        simp only [CRat.smul, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add] <;> ring
    rw [hreg]; exact normSqC_add_smul_expand _ _ _
  -- Sum the expansion
  have hexpand_sum :
      ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) +
                             CRat.smul (diH / 2) (Bev i)) =
      coeffNormSq (coeffSub u v) +
      2 * (diH / 2) * ∑ i : Fin N, realInnerC (u i - v i) (Bue i + Bev i) +
      (diH / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i) := by
    simp_rw [hexpand]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    have hcsub : ∑ i : Fin N, normSqC (u i - v i) = coeffNormSq (coeffSub u v) := by
      simp only [coeffNormSq, coeffSub]
    linarith
  -- Step 3: split inner product sum + cancel ∑⟨e, Bue⟩ = 0
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
  -- The RHS sum after cancellation:
  have hRHS :
      ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) +
                             CRat.smul (diH / 2) (Bev i)) =
      coeffNormSq (coeffSub u v) +
      2 * (diH / 2) * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) +
      (diH / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i) := by
    rw [hexpand_sum, hinner_eq]
  -- Step 4: AM-GM: 2*(diH/2)*∑⟨e,Bev⟩ ≤ (diH/2)*|e|² + (diH/2)*∑|Bev|²
  have hamgm :
      2 * (diH / 2) * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) ≤
      (diH / 2) * coeffNormSq (coeffSub u v) +
      (diH / 2) * ∑ i : Fin N, normSqC (Bev i) := by
    -- First get the sum-level AM-GM
    have hraw : 2 * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) ≤
        coeffNormSq (coeffSub u v) + ∑ i : Fin N, normSqC (Bev i) := by
      have hpt : ∑ i : Fin N, 2 * realInnerC (u i - v i) (Bev i) ≤
          ∑ i : Fin N, (normSqC (u i - v i) + normSqC (Bev i)) := by
        apply Finset.sum_le_sum; intro i _; exact two_realInnerC_le (u i - v i) (Bev i)
      rw [Finset.sum_add_distrib] at hpt
      have hcsub : ∑ i : Fin N, normSqC (u i - v i) = coeffNormSq (coeffSub u v) := by
        simp only [coeffNormSq, coeffSub]
      -- bridge ∑ i, 2 * f i and 2 * ∑ i, f i
      have hfact : ∑ i : Fin N, 2 * realInnerC (u i - v i) (Bev i) =
          2 * ∑ i : Fin N, realInnerC (u i - v i) (Bev i) := by
        simp_rw [← Finset.mul_sum]
      linarith
    -- Multiply by α = diH/2 > 0
    have hBev_nn : 0 ≤ ∑ i : Fin N, normSqC (Bev i) :=
      Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
    nlinarith [le_of_lt hα_pos, hraw, hBev_nn]
  -- Step 5: parallelogram bound for ∑|Bue + Bev|²
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
  -- Step 6: bound (diH/2)²·∑|Bue+Bev|² ≤ 2*(diH/2)²*(C·E₀·E + 4·C·E₀·E)
  have hquad :
      (diH / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i) ≤
      2 * (diH / 2) ^ 2 *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) +
      2 * (diH / 2) ^ 2 *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) := by
    have hBev_E4 : ∑ i : Fin N, normSqC (Bev i) ≤
        triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4 := by
      nlinarith [mul_nonneg (mul_nonneg hCK hnn) hE₀]
    calc (diH / 2) ^ 2 * ∑ i : Fin N, normSqC (Bue i + Bev i)
        ≤ (diH / 2) ^ 2 *
          (2 * ∑ i : Fin N, normSqC (Bue i) + 2 * ∑ i : Fin N, normSqC (Bev i)) :=
            mul_le_mul_of_nonneg_left hpara_sum (sq_nonneg _)
      _ ≤ (diH / 2) ^ 2 *
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
      _ = 2 * (diH / 2) ^ 2 *
            (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) +
          2 * (diH / 2) ^ 2 *
            (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) := by
              ring
  -- Step 7: assemble final bound
  -- We have: |δ|² ≤ RHS (hS)
  -- and: RHS = E + 2α·∑⟨e,Bev⟩ + α²·∑|Bue+Bev|² (hRHS)
  -- Bound:
  --   2α·∑⟨e,Bev⟩  ≤ α·E + α·∑|Bev|²              (hamgm)
  --              ≤ α·E + 4α·C·E₀·E               (hBev_E + monotonicity)
  --   α²·∑|Bue+Bev|² ≤ 2α²·C·E₀·E + 8α²·C·E₀·E   (hquad)
  --                 ≤ α·C·E₀·E + 4α·C·E₀·E       (2α² ≤ α)
  -- Total: E + α·E + 4α·C·E₀·E + α·C·E₀·E + 4α·C·E₀·E
  --      = E·(1 + α·(1 + 9·C·E₀))
  have hS_le :
      ∑ i : Fin N, normSqC ((u i - v i) + CRat.smul (diH / 2) (Bue i) +
                             CRat.smul (diH / 2) (Bev i)) ≤
      (1 + diH / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
        coeffNormSq (coeffSub u v) := by
    rw [hRHS]
    -- Bound α·∑|Bev|² ≤ α·(C·E·(4·E₀))  [matches hBev_E form directly]
    have hamgm_E :
        (diH / 2) * coeffNormSq (coeffSub u v) +
        (diH / 2) * ∑ i : Fin N, normSqC (Bev i) ≤
        (diH / 2) * coeffNormSq (coeffSub u v) +
        (diH / 2) *
          (triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀)) := by
      have h := mul_le_mul_of_nonneg_left hBev_E (le_of_lt hα_pos)
      linarith
    -- 2α²·C·E₀·E ≤ α·C·E₀·E  and  8α²·C·E₀·E ≤ 4α·C·E₀·E  (using 2α² ≤ α)
    have habs1 :
        2 * (diH / 2) ^ 2 *
          (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) ≤
        (diH / 2) * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) :=
      mul_le_mul_of_nonneg_right two_alpha_sq_le_alpha
        (mul_nonneg (mul_nonneg hCK hE₀) hnn)
    have habs2 :
        2 * (diH / 2) ^ 2 *
          (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) ≤
        (diH / 2) * (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) :=
      mul_le_mul_of_nonneg_right two_alpha_sq_le_alpha
        (mul_nonneg (mul_nonneg (mul_nonneg hCK hE₀) hnn) (by norm_num))
    -- Ring normalizations to resolve product order mismatches
    -- (diH/2)*(C*E*(4*E₀)) = 4*(diH/2)*C*E₀*E  (from hamgm_E, form-matches hBev_E)
    have hring1 : (diH / 2) *
        (triadKernelBound (standardTriadK basis) * coeffNormSq (coeffSub u v) * (4 * E₀)) =
        4 * (diH / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    -- (diH/2)*(C*E₀*E) = (diH/2)*C*E₀*E  (trivial, ensures linarith sees the form)
    have hring2 : (diH / 2) *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v)) =
        (diH / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    -- (diH/2)*(C*E₀*E*4) = 4*(diH/2)*C*E₀*E  (from habs2)
    have hring3 : (diH / 2) *
        (triadKernelBound (standardTriadK basis) * E₀ * coeffNormSq (coeffSub u v) * 4) =
        4 * (diH / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    -- Target ring form: (1+(diH/2)*(1+9*C*E₀))*E = E + (diH/2)*E + 9*(diH/2)*C*E₀*E
    have hgoal_ring :
        (1 + diH / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
        coeffNormSq (coeffSub u v) =
        coeffNormSq (coeffSub u v) +
        (diH / 2) * coeffNormSq (coeffSub u v) +
        9 * (diH / 2) * triadKernelBound (standardTriadK basis) * E₀ *
        coeffNormSq (coeffSub u v) := by ring
    linarith [mul_nonneg (mul_nonneg hCK hE₀) hnn,
              mul_nonneg (le_of_lt hα_pos) (mul_nonneg (mul_nonneg hCK hE₀) hnn)]
  linarith [hS, hS_le]

def stage185Summary : String :=
  "Stage 185: NSGalerkinCayleyNearIdentityBridge — sharp SA1 near-identity bound. " ++
  "normSqC_add_smul_expand: LEMMA (exact norm expansion by ring). " ++
  "two_realInnerC_le: LEMMA (AM-GM: 2⟨a,b⟩ ≤ |a|²+|b|²). " ++
  "diH_le_one: LEMMA (norm_num). " ++
  "two_alpha_sq_le_alpha: LEMMA (2*(diH/2)² ≤ diH/2). " ++
  "convStep_near_identity: THEOREM " ++
    "(|convStep u - convStep v|² ≤ (1+(diH/2)(1+9C_K E₀))|u-v|²). " ++
  "Net: +0 axioms, +5 theorems (4 private lemmas + 1 main), 0 sorry."

end NavierStokes.GalerkinCayleyNearIdentityBridge
