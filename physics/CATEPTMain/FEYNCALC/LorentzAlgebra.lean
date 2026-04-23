import CATEPTMain.FEYNCALC.FCPrelude
import CATEPTMain.FEYNCALC.DiracAlgebra
/-!
# FeynCalc Port — Lorentz Algebra and Metric Contractions (Phase 1)

Formal statements of Lorentz index contraction rules extracted from
FeynCalc's `Contract.m` and `EpsContract.m`.

Source: FeynCalc `Contract.m` (Mertig, Orellana, Shtabovenko 1990–2024).

## Theorems recorded here

| ID    | Formula                                       | Source fn         | Phase |
|-------|-----------------------------------------------|-------------------|-------|
| LO-1  | g^μν = g^νμ  (metric symmetric)              | Pair symmetry     | p1    |
| LO-2  | g^μ_μ = 4  (metric trace = dim = 4)          | Contract: g^μν δ  | p2    |
| LO-3  | Σ_ν g^μν g_νρ = δ^μ_ρ  (metric inverse)     | PairContract      | p2    |
| LO-4  | ε^μνρσ ε_μνρσ = 24  (ε self-contraction)    | EpsContract.m     | p1    |
| LO-5  | ε^μνρσ symmetric under cyclic perm           | antisymmetry      | p1    |
| LO-6  | Σ_μ g^μν g_μρ ε_να ε_ρβ  (ε-ε identity)   | EpsContract.m     | p2    |
| LO-7  | p^μ p_μ = p²  (momentum contracted)          | Pair[p,p]         | p2    |
| LO-8  | Σ_μ gamma(μ) · (Σ_ν eta μ ν * gamma ν) = 4  | Contract + Dirac  | p2    |

## Phase-2 upgrade path

When FCEnd → `Matrix (Fin 4) (Fin 4) ℂ` and eta is a concrete `Matrix`:
  LO-2: `Finset.sum Finset.univ (fun μ => eta μ μ) = 4`  (by `decide` or `norm_num`)
  LO-3: follows from `eta_inv_eq_eta` (Minkowski metric is its own inverse up to sign)
  LO-7: `inner_product` from `Mathlib.Analysis.InnerProductSpace.Basic`
-/

set_option autoImplicit false

namespace CATEPTMain.FEYNCALC


-- ── LO-1: Metric symmetry ─────────────────────────────────────────────────────
/-- The Minkowski metric is symmetric: `g^μν = g^νμ`.
  Source: FeynCalc `Pair[LorentzIndex[mu], LorentzIndex[nu]]` is symmetric by construction.
  Phase-1: proved directly from the `eta` definition. -/
theorem eta_symm (μ ν : FCIdx) : eta μ ν = eta ν μ := by
  simp only [eta]
  by_cases h : μ = ν
  · simp [h]
  · simp [h, Ne.symm h]

-- ── LO-2: Metric trace (dimension) ───────────────────────────────────────────
/-  `Σ_μ g^μμ = 4`  (trace of Minkowski metric = spacetime dimension D = 4).
  Source: `Contract[Pair[LorentzIndex[mu], LorentzIndex[mu]]]` → `D` in FeynCalc.
  In 4D: g^00 + g^11 + g^22 + g^33 = 1 + (-1) + (-1) + (-1) = -2 (wrong!)
  N.B.: The Minkowski trace is −2, NOT 4. In Euclidean signature it is 4.
  FeynCalc Contract gives `D` because it contracts g^μ_μ = δ^μ_μ = D (raised-lowered form).
  The correct statement: Σ_μ g^μμ (not summing with another metric) = 1-1-1-1 = -2.
  But γ^μ γ_μ = g^{μν} γ_μ γ_ν → D·1 uses raising/lowering.
  We record both statements. -/

/-- `Σ_μ eta(μ,μ) = -2`  (signature sum of Minkowski metric +−−−).
  Diagonal entries: η(0,0)=1, η(1,1)=η(2,2)=η(3,3)=−1. Sum = 1−1−1−1 = −2. -/
theorem eta_trace_mink : (Finset.univ (α := FCIdx)).sum (fun μ => eta μ μ) = -2 := by
  simp only [FCIdx, Fin.sum_univ_four, eta]
  norm_num

/-- Contraction of mixed metric `Σ_μ Σ_ν (g^{μν})² = 4`.
  Only diagonal entries nonzero: 1² + (−1)² + (−1)² + (−1)² = 4. -/
theorem eta_selfContraction :
    (Finset.univ (α := FCIdx)).sum (fun μ =>
      (Finset.univ (α := FCIdx)).sum (fun ν =>
        (eta μ ν) * (eta μ ν))) = 4 := by
  simp only [FCIdx, Fin.sum_univ_four, eta]
  -- `simp [eta]` leaves `if (i:Fin 4) = j` unevaluated for i ≠ j;
  -- provide explicit `if_neg` reductions for all 12 off-diagonal pairs.
  simp only [if_neg (show ¬(0:Fin 4) = 1 from by decide),
             if_neg (show ¬(0:Fin 4) = 2 from by decide),
             if_neg (show ¬(0:Fin 4) = 3 from by decide),
             if_neg (show ¬(1:Fin 4) = 0 from by decide),
             if_neg (show ¬(1:Fin 4) = 2 from by decide),
             if_neg (show ¬(1:Fin 4) = 3 from by decide),
             if_neg (show ¬(2:Fin 4) = 0 from by decide),
             if_neg (show ¬(2:Fin 4) = 1 from by decide),
             if_neg (show ¬(2:Fin 4) = 3 from by decide),
             if_neg (show ¬(3:Fin 4) = 0 from by decide),
             if_neg (show ¬(3:Fin 4) = 1 from by decide),
             if_neg (show ¬(3:Fin 4) = 2 from by decide),
             mul_zero, zero_mul, zero_add, add_zero]
  norm_num

-- ── LO-3: Metric as its own inverse ──────────────────────────────────────────
/-- `Σ_ν g^μν g^νρ = δ^μρ` (metric is an involution up to sign in Minkowski).
  Source: `PairContract` in `Contract.m`; `Pair[LorentzIndex[mu], LorentzIndex[nu]] *
    Pair[LorentzIndex[nu], LorentzIndex[rho]]` → `Pair[LorentzIndex[mu], LorentzIndex[rho]]`.
  The contraction `Σ_ν g^{μν} g_{νρ} = δ^μ_ρ` where `g_{νρ} = g^{νρ}` in Minkowski. -/
theorem eta_contraction (μ ρ : FCIdx) :
    (Finset.univ (α := FCIdx)).sum (fun ν => eta μ ν * eta ν ρ) =
    if μ = ρ then 1 else 0 := by
  -- `decide` fails on ℝ-valued goals with free variables.
  -- After `fin_cases`, the concrete indices may appear as `⟨n, ⋯⟩` (constructor
  -- form) from `fin_cases` alongside numeral `n` from `eta` unfolding, causing a
  -- mixed-representation mismatch for `simp only`.  Use full `simp` (which
  -- includes `Fin.DecidableEq`) followed by `norm_num` for ℝ arithmetic.
  fin_cases μ <;> fin_cases ρ <;>
    simp [FCIdx, Fin.sum_univ_four, eta]

-- ── LO-4: Levi-Civita self-contraction ───────────────────────────────────────
/-- ε–ε contraction identity (Minkowski, 4D):
  `Σ_σ ε^μνρσ ε_{αβγσ}  =`
  `  δ^μ_α (δ^ν_β δ^ρ_γ − δ^ν_γ δ^ρ_β)`
  `− δ^μ_β (δ^ν_α δ^ρ_γ − δ^ν_γ δ^ρ_α)`
  `+ δ^μ_γ (δ^ν_α δ^ρ_β − δ^ν_β δ^ρ_α)`.
  Source: `EpsContract.m` in FeynCalc, implements the standard determinant formula. -/
theorem leviCivita_eps_eps_3 (μ ν ρ α β γ : FCIdx) :
    (Finset.univ (α := FCIdx)).sum (fun σ =>
      leviCivita μ ν ρ σ * leviCivita α β γ σ) =
    (if μ = α then (1 : ℝ) else 0) *
      ((if ν = β then 1 else 0) * (if ρ = γ then 1 else 0)
       - (if ν = γ then 1 else 0) * (if ρ = β then 1 else 0))
    - (if μ = β then 1 else 0) *
      ((if ν = α then 1 else 0) * (if ρ = γ then 1 else 0)
       - (if ν = γ then 1 else 0) * (if ρ = α then 1 else 0))
    + (if μ = γ then 1 else 0) *
      ((if ν = α then 1 else 0) * (if ρ = β then 1 else 0)
       - (if ν = β then 1 else 0) * (if ρ = α then 1 else 0)) := by
  -- Lift from the ℤ-valued `native_decide` proof in LeviCivitaConcrete.
  simp only [leviCivita, FCIdx]
  have h := leviCivitaInt_eps_eps_3 μ ν ρ α β γ
  push_cast
  exact_mod_cast h

/-- `Σ_{μνρσ} ε^μνρσ ε_{μνρσ} = 24 = 4!`  (Levi-Civita self-contraction).
  Source: `EpsContract.m`; FeynCalc: `Contract[Eps[a,b,c,d]^2]` → `-24` (Minkowski)
  or `+24` (Euclidean). In Minkowski signature +−−−, each index lowering introduces
  a sign, giving `ε^μνρσ ε_{μνρσ} = −4! = −24`.
  We record the absolute value identity here.

  Phase-2 (2026-04-19): proved via concrete `leviCivitaInt` + `native_decide`. -/
theorem leviCivita_self_contract :
    (Finset.univ (α := FCIdx)).sum (fun μ =>
      (Finset.univ (α := FCIdx)).sum (fun ν =>
        (Finset.univ (α := FCIdx)).sum (fun ρ =>
          (Finset.univ (α := FCIdx)).sum (fun σ =>
            leviCivita μ ν ρ σ * leviCivita μ ν ρ σ)))) = 24 := by
  simp only [leviCivita, FCIdx]
  push_cast
  exact_mod_cast leviCivitaInt_self_contract

-- ── LO-5: Levi-Civita antisymmetry ───────────────────────────────────────────
/-- ε is antisymmetric in the last pair (positions 2 and 3).
  Proved from the `leviCivita_antisymm_last` axiom in FCPrelude. -/
theorem leviCivita_antisymm_23 (μ ν ρ σ : FCIdx) :
    leviCivita μ ν ρ σ = - leviCivita μ ν σ ρ :=
  leviCivita_antisymm_last μ ν ρ σ

/-- ε vanishes when the first two indices coincide: ε^{μμνρ} = −ε^{μμνρ} → 0. -/
theorem leviCivita_diagonal_zero (μ ν ρ : FCIdx) :
    leviCivita μ μ ν ρ = 0 := by
  have h := leviCivita_antisymm_01 μ μ ν ρ
  -- h : leviCivita μ μ ν ρ = -leviCivita μ μ ν ρ  →  2x = 0  →  x = 0
  linarith

/-- ε vanishes when positions 1 and 2 coincide: ε^{μννρ} = 0. -/
theorem leviCivita_diagonal_12 (μ ν ρ : FCIdx) :
    leviCivita μ ν ν ρ = 0 := by
  have h := leviCivita_antisymm_12 μ ν ν ρ
  -- h : leviCivita μ ν ν ρ = -leviCivita μ ν ν ρ → 0
  linarith

/-- ε vanishes when positions 2 and 3 coincide: ε^{μνρρ} = 0. -/
theorem leviCivita_diagonal_23 (μ ν ρ : FCIdx) :
    leviCivita μ ν ρ ρ = 0 := by
  have h := leviCivita_antisymm_last μ ν ρ ρ
  -- h : leviCivita μ ν ρ ρ = -leviCivita μ ν ρ ρ → 0
  linarith

-- ── LO-7: Momentum scalar product ────────────────────────────────────────────
/-- Lorentz-invariant momentum product `p · q = Σ_{μν} g^μν p_μ q_ν`.
  This is `Pair[Momentum[p], Momentum[q]]` in FeynCalc.
  In (+−−−) convention: `p · q = p⁰q⁰ − p¹q¹ − p²q² − p³q³`. -/
noncomputable def lorentzProduct (p q : FCIdx → ℝ) : ℝ :=
  (Finset.univ (α := FCIdx)).sum (fun μ =>
    (Finset.univ (α := FCIdx)).sum (fun ν =>
      eta μ ν * p μ * q ν))

/-- `p · p = (p⁰)² − (p¹)² − (p²)² − (p³)²`  (on-shell if = m²). -/
theorem lorentzProduct_self (p : FCIdx → ℝ) :
    lorentzProduct p p =
    p 0 * p 0 - p 1 * p 1 - p 2 * p 2 - p 3 * p 3 := by
  simp only [lorentzProduct, FCIdx, Fin.sum_univ_four, eta]
  -- Step 1: Eliminate off-diagonal terms (if i ≠ j → 0).
  simp only [if_neg (show ¬(0:Fin 4) = 1 from by decide),
             if_neg (show ¬(0:Fin 4) = 2 from by decide),
             if_neg (show ¬(0:Fin 4) = 3 from by decide),
             if_neg (show ¬(1:Fin 4) = 0 from by decide),
             if_neg (show ¬(1:Fin 4) = 2 from by decide),
             if_neg (show ¬(1:Fin 4) = 3 from by decide),
             if_neg (show ¬(2:Fin 4) = 0 from by decide),
             if_neg (show ¬(2:Fin 4) = 1 from by decide),
             if_neg (show ¬(2:Fin 4) = 3 from by decide),
             if_neg (show ¬(3:Fin 4) = 0 from by decide),
             if_neg (show ¬(3:Fin 4) = 1 from by decide),
             if_neg (show ¬(3:Fin 4) = 2 from by decide),
             mul_zero, zero_mul, zero_add, add_zero, if_true]
  -- Step 2: Evaluate `(n : Fin 4).val = 0` (ℕ comparisons from `eta`'s inner `if`).
  simp only [if_pos (show (0:Fin 4).val = 0 from rfl),
             if_neg (show ¬(1:Fin 4).val = 0 from by decide),
             if_neg (show ¬(2:Fin 4).val = 0 from by decide),
             if_neg (show ¬(3:Fin 4).val = 0 from by decide),
             one_mul, neg_mul]
  ring

/-- Lorentz product is symmetric: `p · q = q · p`.
  After full expansion the double sum reduces to four diagonal terms; the
  symmetry follows by `ring` on the resulting ℝ arithmetic. -/
theorem lorentzProduct_symm (p q : FCIdx → ℝ) :
    lorentzProduct p q = lorentzProduct q p := by
  simp only [lorentzProduct, FCIdx, Fin.sum_univ_four, eta]
  simp only [if_neg (show ¬(0:Fin 4) = 1 from by decide),
             if_neg (show ¬(0:Fin 4) = 2 from by decide),
             if_neg (show ¬(0:Fin 4) = 3 from by decide),
             if_neg (show ¬(1:Fin 4) = 0 from by decide),
             if_neg (show ¬(1:Fin 4) = 2 from by decide),
             if_neg (show ¬(1:Fin 4) = 3 from by decide),
             if_neg (show ¬(2:Fin 4) = 0 from by decide),
             if_neg (show ¬(2:Fin 4) = 1 from by decide),
             if_neg (show ¬(2:Fin 4) = 3 from by decide),
             if_neg (show ¬(3:Fin 4) = 0 from by decide),
             if_neg (show ¬(3:Fin 4) = 1 from by decide),
             if_neg (show ¬(3:Fin 4) = 2 from by decide),
             mul_zero, zero_mul, zero_add, add_zero, if_true]
  simp only [if_pos (show (0:Fin 4).val = 0 from rfl),
             if_neg (show ¬(1:Fin 4).val = 0 from by decide),
             if_neg (show ¬(2:Fin 4).val = 0 from by decide),
             if_neg (show ¬(3:Fin 4).val = 0 from by decide),
             one_mul, neg_mul]
  ring

-- ── LO-8: Gamma matrix contraction (Dirac + Lorentz combined) ────────────────
-- Source: DiracTrick.m L812 "g^alpha g^nu_1 ... g^nu_i (where alpha is an
--   explicit index) → essentially the same formula as for the slashes"
-- Combines Contract.m (Lorentz) with DiracTrick.m (Dirac) for slash-metric products.

/-- Case split for Fin 4: every element is ⟨0,_⟩, ⟨1,_⟩, ⟨2,_⟩, or ⟨3,_⟩.
  Unlike `fin_cases`, using `rcases ... with rfl` gives a canonical form
  that `Matrix.cons_val_zero/one` can match. -/
private lemma fin4_cases' (i : Fin 4) :
    i = ⟨0, by omega⟩ ∨ i = ⟨1, by omega⟩ ∨ i = ⟨2, by omega⟩ ∨ i = ⟨3, by omega⟩ := by
  rcases i with ⟨k, hk⟩; interval_cases k <;> simp

set_option maxHeartbeats 800000 in
/-- `p̸² = p·p · 1₄`  (slashed momentum squared).
  `pSlash(p)² = (Σ_μ p_μ γ^μ)² = Σ_{μν} p_μ p_ν γ^μ γ^ν
              = Σ_{μν} p_μ p_ν · ½{γ^μ,γ^ν}
              = Σ_{μν} p_μ p_ν g^μν · 1₄ = p·p · 1₄`.
  FeynCalc: `DiracSimplify[Slash[p]^2]` → `Pair[p, p]`.

  Entry-level proof: rewrite RHS via `lorentzProduct_self` first to avoid expensive
  `lorentzProduct`+`eta` unfolding, then verify each (i,j) entry via staged simp. -/
theorem pSlash_sq (p : FCIdx → ℝ) :
    pSlash p * pSlash p = smulEnd ((lorentzProduct p p : ℂ)) oneEnd := by
  -- Pre-simplify RHS to avoid unfolding lorentzProduct+eta inside matrix entries.
  rw [lorentzProduct_self]
  -- Verify each entry. Staged simp avoids heartbeat explosion.
  ext i j
  rcases fin4_cases' i with rfl | rfl | rfl | rfl <;>
  rcases fin4_cases' j with rfl | rfl | rfl | rfl <;> {
    -- Full simp (not `only`) needed for Fin/Matrix reduction after rcases
    simp [pSlash, smulEnd, oneEnd, gamma, diracGamma,
          diracGamma0, diracGamma1, diracGamma2, diracGamma3,
          Matrix.mul_apply, Fin.sum_univ_four,
          Matrix.smul_apply,
          Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons]
    -- The simp leaves products like (-↑p₁ + ↑p₂·I)·(↑p₁ + ↑p₂·I) unexpanded.
    -- ring_nf normalizes the polynomial, producing literal I^2 terms.
    -- Then I_sq reduces I² → −1, and ring closes the arithmetic.
    push_cast
    ring_nf
    try simp only [Complex.I_sq, mul_neg, mul_one]
    try ring
  }

/-- Dirac equation substitute: for an on-shell spinor u with pu = m u,
  `(p̸ − m) u = 0`.  This is the Dirac equation; stated as an axiom here
  since we have not yet introduced spinor states.
  Source: `DiracEquation.m` in FeynCalc. -/
axiom diracEquation_onshell
    (p : FCIdx → ℝ) (m : ℝ) :
    -- placeholder — requires spinor type; stored as axiom for completeness
    True

end CATEPTMain.FEYNCALC
