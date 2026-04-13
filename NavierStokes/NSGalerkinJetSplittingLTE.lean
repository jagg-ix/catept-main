import NavierStokes.NSGalerkinODEJetBridge

/-!
# Stage 201 — NSGalerkinJetSplittingLTE: Splitting LTE from Jet Triangle (0 new axioms)

Derives the full Lie-splitting LTE via the triangle inequality through the
first-order Euler jet `jet(t) := uExact(t) + h·G(uExact(t))`:

```
‖S_h(uExact(t)) − uExact(t+h)‖²
  ≤ 2·‖S_h(uExact(t)) − jet(t)‖² + 2·‖jet(t) − uExact(t+h)‖²
  ≤ 2·methodJetC·h^4 + 2·odeJetC·h^3          [200B + 200A]
  ≤ 2·(methodJetC + odeJetC)·h^3              [h^4 ≤ h^3 for h ≤ 1]
  = jetSplittingLteC · h^3
```

This provides an **alternative** to the 196B/198D route in `NSGalerkinStepLTE`,
cross-checking the splitting LTE from the jet decomposition angle.

## Net counts

  - New defs:     1  (jetSplittingLteC)
  - New axioms:   0
  - New theorems: 3  (jetSplittingLteC_pos, coeffNormSq_sub_symm, lie_splitting_lte_from_jet)
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinJetSplittingLTE

set_option autoImplicit false

open NavierStokes.GalerkinConvergence      -- coeffSub, coeffNormSq, coeffNormSq_nonneg, SolvesGalerkinODE
open NavierStokes.GalerkinComplexModel     -- CRat, CoeffC, normSqC, normSqC_nonneg
open NavierStokes.GalerkinConvection       -- GalerkinBasis
open NavierStokes.GalerkinODE              -- viscStep
open NavierStokes.GalerkinConvStepHBridge  -- convStepH
open NavierStokes.GalerkinConvDef          -- standardTriadK
open NavierStokes.GalerkinSplittingLemmata -- triadKernelBound, triadKernelBound_nonneg
open NavierStokes.GalerkinODERHSBound      -- galerkinODE_rhs
open NavierStokes.GalerkinODEJet           -- coeffAdd, coeffScale, odeJetC, methodJetC, axioms

/-! ## Combined constant -/

/-- **Combined jet splitting LTE constant**.

    `jetSplittingLteC basis ν E₀ := 2 · (odeJetC + methodJetC) = 16 · (C_K·E₀ + ν)^2`

    Satisfies `jetSplittingLteC > 0` for `ν > 0`. -/
noncomputable def jetSplittingLteC {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) : Rat :=
  2 * (odeJetC basis ν E₀ + methodJetC basis ν E₀)

theorem jetSplittingLteC_pos {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 < ν) (hE₀ : 0 ≤ E₀) : 0 < jetSplittingLteC basis ν E₀ := by
  unfold jetSplittingLteC
  linarith [odeJetC_pos basis ν E₀ hν hE₀, methodJetC_pos basis ν E₀ hν hE₀]

/-! ## Auxiliary: pair subtraction projections (definitional rfl proofs) -/

private lemma rat_pair_sub_fst (ar br : Rat) (ai bi : Rat) :
    ((ar, ai) - (br, bi)).1 = ar - br := rfl

private lemma rat_pair_sub_snd (ar br : Rat) (ai bi : Rat) :
    ((ar, ai) - (br, bi)).2 = ai - bi := rfl

/-! ## Auxiliary: coeffNormSq is symmetric in coeffSub -/

/-- `coeffNormSq (coeffSub a b) = coeffNormSq (coeffSub b a)` — symmetry of squared norm. -/
theorem coeffNormSq_sub_symm {N : Nat} (a b : CoeffC N) :
    coeffNormSq (coeffSub a b) = coeffNormSq (coeffSub b a) := by
  simp only [coeffNormSq, coeffSub]
  apply Finset.sum_congr rfl
  intro i _
  obtain ⟨ar, ai⟩ := a i
  obtain ⟨br, bi⟩ := b i
  simp only [normSqC, CRat.re, CRat.im,
             rat_pair_sub_fst ar br ai bi, rat_pair_sub_snd ar br ai bi,
             rat_pair_sub_fst br ar bi ai, rat_pair_sub_snd br ar bi ai]
  ring

/-! ## Inline triangle inequality -/

/-- Squared-norm triangle inequality:
    `‖a − c‖² ≤ 2·‖a − b‖² + 2·‖b − c‖²` -/
private lemma coeffNormSq_triangle_sq {N : Nat} (a b c : CoeffC N) :
    coeffNormSq (coeffSub a c) ≤
    2 * coeffNormSq (coeffSub a b) + 2 * coeffNormSq (coeffSub b c) := by
  -- Prove mode-wise first
  have key : ∀ i : Fin N,
      normSqC (a i - c i) ≤
      2 * normSqC (a i - b i) + 2 * normSqC (b i - c i) := by
    intro i
    obtain ⟨ar, ai⟩ := a i
    obtain ⟨br, bi⟩ := b i
    obtain ⟨cr, ci⟩ := c i
    simp only [normSqC, CRat.re, CRat.im,
               rat_pair_sub_fst ar cr ai ci, rat_pair_sub_snd ar cr ai ci,
               rat_pair_sub_fst ar br ai bi, rat_pair_sub_snd ar br ai bi,
               rat_pair_sub_fst br cr bi ci, rat_pair_sub_snd br cr bi ci]
    -- (ar-cr)² ≤ 2(ar-br)² + 2(br-cr)²: AM-GM on cross-term of (ar-br)+(br-cr)
    nlinarith [sq_nonneg ((ar - br) - (br - cr)), sq_nonneg ((ai - bi) - (bi - ci))]
  -- Sum the mode-wise bound
  simp only [coeffNormSq, coeffSub]
  calc ∑ i : Fin N, normSqC (a i - c i)
      ≤ ∑ i : Fin N, (2 * normSqC (a i - b i) + 2 * normSqC (b i - c i)) :=
          Finset.sum_le_sum (fun i _ => key i)
    _ = 2 * ∑ i : Fin N, normSqC (a i - b i) + 2 * ∑ i : Fin N, normSqC (b i - c i) := by
          rw [Finset.sum_add_distrib]; simp [Finset.mul_sum]

/-! ## 201: The jet splitting LTE theorem -/

/-- **Lie-splitting LTE from jet triangle** — **THEOREM** (0 new axioms).

    Derives `‖S_h(uExact(t)) − uExact(t+h)‖² ≤ jetSplittingLteC · h^3` via:
    1. Triangle: `‖S_h − uExact(t+h)‖² ≤ 2‖S_h − jet‖² + 2‖jet − uExact(t+h)‖²`
    2. 200B: `‖S_h − jet‖² ≤ methodJetC · h^4`
    3. 200A: `‖uExact(t+h) − jet‖² ≤ odeJetC · h^3` (+ symmetry of coeffSub)
    4. `h^4 ≤ h^3` for `h ≤ 1`

    **Net: 0 new axioms** (uses only 200A and 200B). -/
theorem lie_splitting_lte_from_jet
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hODE    : SolvesGalerkinODE basis ν uExact)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h (uExact t)))
      (uExact (t + h))) ≤
    jetSplittingLteC basis ν E₀ * h ^ 3 := by
  -- Abbreviate key subterms
  set u₀  := uExact t
  set Sh  := viscStep basis ν h (convStepH basis h u₀)
  set ut1 := uExact (t + h)
  set jet := coeffAdd u₀ (coeffScale h (galerkinODE_rhs basis ν u₀))
  -- Step 1: squared-norm triangle inequality through jet
  have htri : coeffNormSq (coeffSub Sh ut1) ≤
      2 * coeffNormSq (coeffSub Sh jet) + 2 * coeffNormSq (coeffSub jet ut1) :=
    coeffNormSq_triangle_sq Sh jet ut1
  -- Step 2 (200B): method jet remainder: ‖S_h(u₀) − jet‖² ≤ methodJetC · h^4
  have hB : coeffNormSq (coeffSub Sh jet) ≤ methodJetC basis ν E₀ * h ^ 4 :=
    splitting_method_jet_remainder basis ν h E₀ hν hh hh1 hE₀ u₀ (hEnergy t)
  -- Step 3 (200A): ODE jet remainder: ‖uExact(t+h) − jet‖² ≤ odeJetC · h^3
  have hA_raw : coeffNormSq (coeffSub ut1 jet) ≤ odeJetC basis ν E₀ * h ^ 3 :=
    galerkinODE_jet_remainder basis ν h E₀ hν hh hh1 hE₀ uExact hODE hEnergy t
  -- Flip orientation via symmetry: ‖jet − uExact(t+h)‖² = ‖uExact(t+h) − jet‖²
  have hA : coeffNormSq (coeffSub jet ut1) ≤ odeJetC basis ν E₀ * h ^ 3 :=
    coeffNormSq_sub_symm jet ut1 ▸ hA_raw
  -- Step 4: h^4 ≤ h^3 for h ≤ 1
  have hh4_le_3 : h ^ 4 ≤ h ^ 3 := by nlinarith [pow_pos hh 3]
  -- Nonnegativity for the constant
  have hmC_nn : 0 ≤ methodJetC basis ν E₀ :=
    le_of_lt (methodJetC_pos basis ν E₀ hν hE₀)
  -- Assemble via calc
  calc coeffNormSq (coeffSub Sh ut1)
      ≤ 2 * coeffNormSq (coeffSub Sh jet) + 2 * coeffNormSq (coeffSub jet ut1) := htri
    _ ≤ 2 * (methodJetC basis ν E₀ * h ^ 4) + 2 * (odeJetC basis ν E₀ * h ^ 3) := by
          have h1 := mul_le_mul_of_nonneg_left hB (by norm_num : (0:Rat) ≤ 2)
          have h2 := mul_le_mul_of_nonneg_left hA (by norm_num : (0:Rat) ≤ 2)
          linarith
    _ ≤ 2 * (methodJetC basis ν E₀ * h ^ 3) + 2 * (odeJetC basis ν E₀ * h ^ 3) := by
          have hstep : methodJetC basis ν E₀ * h ^ 4 ≤ methodJetC basis ν E₀ * h ^ 3 :=
            mul_le_mul_of_nonneg_left hh4_le_3 hmC_nn
          linarith
    _ = jetSplittingLteC basis ν E₀ * h ^ 3 := by
          simp only [jetSplittingLteC]; ring

def stage201Summary : String :=
  "Stage 201: NSGalerkinJetSplittingLTE — splitting LTE from jet triangle. " ++
  "jetSplittingLteC: DEF (2*(odeJetC+methodJetC) = 16*(C_K*E₀+ν)^2). " ++
  "jetSplittingLteC_pos: THEOREM. " ++
  "coeffNormSq_sub_symm: THEOREM (symmetry of squared norm under swap). " ++
  "coeffNormSq_triangle_sq: PRIVATE LEMMA (inline ‖a-c‖²≤2‖a-b‖²+2‖b-c‖², nlinarith). " ++
  "lie_splitting_lte_from_jet: THEOREM (0 new axioms, triangle+200A+200B+h^4≤h^3). " ++
  "Net: +0 axioms, +3 theorems, 0 sorry."

end NavierStokes.GalerkinJetSplittingLTE
