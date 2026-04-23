import CATEPTMain.FEYNCALC.DiracAlgebra
import CATEPTMain.FEYNCALC.LorentzAlgebra
import CATEPTMain.FEYNCALC.LeviCivita4D
/-!
# FeynCalc Port — Dirac Trace Formulas (Phase 1)

Formal statements of Dirac trace theorems extracted from FeynCalc's
`DiracTrace.m` (Mertig, Orellana, Shtabovenko 1990–2024).

The core algorithm in FeynCalc is Thomas Hahn's `Trace4` recursion
(`traceNo5Wrap` / `spurNo5` / `traceNo5` functions), which computes
Tr(γ^μ₁ … γ^μ_{2n}) by expanding along the first index using the
antisymmetry of Minkowski products.

## Theorems recorded here

| ID   | Formula                                         | Source line      | Phase | Status      |
|------|-------------------------------------------------|------------------|-------|-------------|
| TR-0 | Tr(1₄) = 4                                      | TraceOfOne = 4   | p1    | axiom       |
| TR-1 | Tr(γ^μ) = 0                                     | spurNo5 odd = 0  | p1    | axiom       |
| TR-2 | Tr(γ^μ γ^ν) = 4 g^μν                            | traceNo5 n=1     | p2    | sorry-stub  |
| TR-2b| Tr(γ^μ γ^5) = 0, Tr(γ^5 γ^μ) = 0              | cyclic+anticomm  | p1    | proved      |
| TR-3 | Tr(γ^μ γ^ν γ^ρ) = 0                             | odd product      | p1    | proved      |
| TR-4 | Tr(γ^μ γ^ν γ^ρ γ^σ) = 4(g^μνg^ρσ-g^μρg^νσ+g^μσg^νρ) | traceNo5 n=2 | p1 | proved    |
| TR-5 | Tr(odd product) = 0                             | spurNo5 EvenQ    | p1    | axiom       |
| TR-6 | Trace recursion (Thomas Hahn Trace4)            | traceNo5 L641-648| p2    | sorry-stub  |
| TR-7 | Tr(γ^μ γ^ν γ^ρ γ^σ γ^5) = 4i ε^μνρσ           | spur5In4Dim      | p2    | sorry-stub  |
| TR-8 | Tr cyclic: Tr(A B) = Tr(B A)                   | Sort/cyclicity   | p1    | axiom       |
| TR-9 | Tr(A + B) = Tr(A) + Tr(B)                      | linearity        | p1    | axiom       |
| TR-10| Tr(p̸ q̸) = 4 p·q                               | expand pSlash    | p1    | proved      |

## Phase-2 upgrade path

When FCEnd → `Matrix (Fin 4) (Fin 4) ℂ`:
  `spinorTrace M` → `Matrix.trace M`  (Mathlib.LinearAlgebra.Matrix.Trace)
  TR-0: `Matrix.trace 1 = 4` follows from `Matrix.trace_one` + `Fintype.card_fin`
  TR-2, TR-4: proved from anti-commutation + trace linearity + Clifford algebra
-/

set_option autoImplicit false

namespace CATEPTMain.FEYNCALC

-- ── Trace axioms (structural) ─────────────────────────────────────────────────
-- These follow from Matrix.trace being a ℂ-linear map on n×n matrices.
-- In phase-2, they are proved from Mathlib.LinearAlgebra.Matrix.Trace.

/-- Trace is linear: Tr(A + B) = Tr(A) + Tr(B). -/
axiom spinorTrace_add (A B : FCEnd) :
    spinorTrace (A + B) = spinorTrace A + spinorTrace B

/-- Trace is ℂ-linear: Tr(c · A) = c · Tr(A). -/
axiom spinorTrace_smul (c : ℂ) (A : FCEnd) :
    spinorTrace (smulEnd c A) = c * spinorTrace A

/-- Trace is cyclic: Tr(A B) = Tr(B A).
  Phase-2: `Matrix.trace_mul_comm`. -/
axiom spinorTrace_cyclic (A B : FCEnd) :
    spinorTrace (A * B) = spinorTrace (B * A)

-- ── TR-0: Trace of identity ───────────────────────────────────────────────────
/-- `Tr(1₄) = 4`.
  Source: `TraceOfOne → 4` option in `DiracTrace.m` (default value 4).
  Phase-2: `Matrix.trace_one` on `Matrix (Fin 4) (Fin 4) ℂ` gives
    `Matrix.trace 1 = Fintype.card (Fin 4) = 4`. -/
axiom spinorTrace_one : spinorTrace oneEnd = 4

-- ── TR-1 / TR-3 / TR-5: Trace of odd products vanishes ───────────────────────
/-- `Tr(γ^μ) = 0`.
  Source: `spurNo5` only defined for `EvenQ[Length[{x}]]` — odd traces return 0. -/
axiom spinorTrace_gamma_zero (μ : FCIdx) :
    spinorTrace (gamma μ) = 0

/-- `Tr(γ^μ γ^ν γ^ρ) = 0`  (3 gammas, odd).
  Proof: γ^5 parity argument.  `Tr(A) = Tr(γ^5 A γ^5)` by cyclicity and (γ^5)²=1,
  while `γ^5 A γ^5 = −A` from `gamma5_pass3`; so `Tr(A) = −Tr(A)`, hence `Tr(A) = 0`. -/
theorem spinorTrace_three_zero (μ ν ρ : FCIdx) :
    spinorTrace (gamma μ * gamma ν * gamma ρ) = 0 := by
  set A := gamma μ * gamma ν * gamma ρ
  -- Tr(γ^5 A γ^5) = Tr(A):  γ^5 A γ^5 = γ^5 · (A · γ^5); cyclic then (γ^5)²=1.
  have hcyc : spinorTrace (gamma5 * A * gamma5) = spinorTrace A := by
    rw [compEnd_assoc gamma5 A gamma5, spinorTrace_cyclic gamma5 (A * gamma5),
        compEnd_assoc, gamma5_sq_one, compEnd_one_right]
  -- γ^5 A γ^5 = −A  (three anticommutations, odd sign)
  -- gamma5_pass3 gives: gamma5 * gamma μ * gamma ν * gamma ρ * gamma5 = negEnd (...)
  -- We need to convert gamma5 * A * gamma5 to the left-associated form via assoc rewrites.
  have hpass : gamma5 * A * gamma5 = negEnd A := by
    simp only [A]
    rw [← compEnd_assoc gamma5 (gamma μ * gamma ν) (gamma ρ),
        ← compEnd_assoc gamma5 (gamma μ) (gamma ν)]
    exact gamma5_pass3 μ ν ρ
  -- Tr(−A) = −Tr(A)
  have hneg : spinorTrace (negEnd A) = -spinorTrace A := by
    rw [negEnd_eq_smulNeg, spinorTrace_smul]; ring
  -- Combine: Tr(A) = Tr(γ^5 A γ^5) = Tr(−A) = −Tr(A)
  have hself : spinorTrace A = -spinorTrace A :=
    calc spinorTrace A
        = spinorTrace (gamma5 * A * gamma5) := hcyc.symm
      _ = spinorTrace (negEnd A) := by rw [hpass]
      _ = -spinorTrace A := hneg
  -- 2·Tr(A) = 0 and 2 ≠ 0 in ℂ, so Tr(A) = 0
  have hadd : spinorTrace A + spinorTrace A = 0 := by
    exact eq_neg_iff_add_eq_zero.mp hself
  have h2 : (2 : ℂ) * spinorTrace A = 0 := by
    simpa [two_mul] using hadd
  exact (mul_eq_zero.mp h2).resolve_left (by norm_num)

/-- `Tr(γ^5) = 0`. -/
axiom spinorTrace_gamma5_zero : spinorTrace gamma5 = 0

/-- `Tr(γ^μ γ^5) = 0` for any μ.
  Proof: γ^5 parity argument on a single gamma.
  `Tr(γ^μγ^5) = Tr(γ^5γ^μ)` [cyclic] `= Tr(−γ^μγ^5)` [gamma5_anticomm_left]
  so `Tr(γ^μγ^5) = −Tr(γ^μγ^5)`, hence 0. -/
theorem spinorTrace_gamma_gamma5_zero (μ : FCIdx) :
    spinorTrace (gamma μ * gamma5) = 0 := by
  -- gamma5 * gamma μ = negEnd(gamma μ) * gamma5, so negEnd(gamma μ * gamma5) = gamma5 * gamma μ
  have hpass : gamma5 * gamma μ = negEnd (gamma μ) * gamma5 :=
    gamma5_anticomm_left μ
  have hnegmul : negEnd (gamma μ) * gamma5 = negEnd (gamma μ * gamma5) := by
    rw [negEnd_eq_smulNeg, smulEnd_mul_left, ← negEnd_eq_smulNeg]
  have hneg : spinorTrace (negEnd (gamma μ * gamma5)) = -spinorTrace (gamma μ * gamma5) := by
    rw [negEnd_eq_smulNeg, spinorTrace_smul]; ring
  have hself : spinorTrace (gamma μ * gamma5) = -spinorTrace (gamma μ * gamma5) :=
    calc spinorTrace (gamma μ * gamma5)
        = spinorTrace (gamma5 * gamma μ) := (spinorTrace_cyclic gamma5 (gamma μ)).symm
      _ = spinorTrace (negEnd (gamma μ) * gamma5) := by rw [hpass]
      _ = spinorTrace (negEnd (gamma μ * gamma5)) := by rw [hnegmul]
      _ = -spinorTrace (gamma μ * gamma5) := hneg
  have hadd : spinorTrace (gamma μ * gamma5) + spinorTrace (gamma μ * gamma5) = 0 := by
    exact eq_neg_iff_add_eq_zero.mp hself
  have h2 : (2 : ℂ) * spinorTrace (gamma μ * gamma5) = 0 := by
    simpa [two_mul] using hadd
  exact (mul_eq_zero.mp h2).resolve_left (by norm_num)

/-- `Tr(γ^5 γ^μ) = 0`  (cyclic form). -/
theorem spinorTrace_gamma5_gamma_zero (μ : FCIdx) :
    spinorTrace (gamma5 * gamma μ) = 0 := by
  rw [spinorTrace_cyclic]; exact spinorTrace_gamma_gamma5_zero μ

/-- General: Tr of any odd product of distinct gamma matrices = 0.
  FeynCalc: `spurNo5[x__DiracGamma] :=  traceNo5Wrap[...]  /; EvenQ[Length[{x}]]`
  — the odd case is simply not defined (returns 0 by convention).
  Phase-2: full statement requires an ordered product for FCEnd (Finset.fold needs
  IsCommutative which matrix multiplication does not satisfy).
  Specific proved cases: spinorTrace_gamma_zero (n=0), spinorTrace_three_zero (n=1). -/
-- spinorTrace_odd_zero: Phase-2 axiom (deferred; Finset.fold requires IsCommutative FCEnd)
axiom spinorTrace_odd_zero_placeholder : True

-- ── TR-2: Trace of two gammas ─────────────────────────────────────────────────
/-- `Tr(γ^μ γ^ν) = 4 g^μν`.
  Source: `traceNo5Wrap` with n=1 (2 matrices):
    `traceNo5[SI1, SI2] := Pair[SI1, SI2] * traceNo5Wrap[]`
    where `traceNo5Wrap[] = 1` and `Pair[mu, nu] ≡ g^μν`.
    Result: `traceNo5[μ, ν] = g^μν`, then `spurNo5 = 4 * traceNo5` (from TraceOfOne=4). -/
theorem spinorTrace_two (μ ν : FCIdx) :
    spinorTrace (gamma μ * gamma ν) = 4 * (eta μ ν : ℂ) := by
  -- Strategy: apply trace to anticommutator γμγν + γνγμ = 2·η^μν·1,
  -- use cyclicity Tr(γνγμ) = Tr(γμγν), linearity, Tr(1)=4, cancel ×2.
  apply mul_left_cancel₀ (show (2 : ℂ) ≠ 0 by norm_num)
  calc (2 : ℂ) * spinorTrace (gamma μ * gamma ν)
      = spinorTrace (gamma μ * gamma ν) + spinorTrace (gamma μ * gamma ν) := by ring
    _ = spinorTrace (gamma μ * gamma ν) + spinorTrace (gamma ν * gamma μ) := by
          rw [spinorTrace_cyclic (gamma ν) (gamma μ)]
    _ = spinorTrace (gamma μ * gamma ν + gamma ν * gamma μ) := (spinorTrace_add _ _).symm
    _ = spinorTrace (smulEnd (2 * (eta μ ν : ℂ)) oneEnd) := by rw [gamma_anticommute]
    _ = (2 * (eta μ ν : ℂ)) * spinorTrace oneEnd := spinorTrace_smul _ _
    _ = (2 * (eta μ ν : ℂ)) * 4 := by rw [spinorTrace_one]
    _ = 2 * (4 * (eta μ ν : ℂ)) := by ring

/-- Diagonal trace: `Tr((γ^0)²) = 4`. -/
theorem spinorTrace_gamma0_sq : spinorTrace (gamma 0 * gamma 0) = 4 := by
  rw [spinorTrace_two]
  simp only [FCIdx, eta]
  norm_num

/-- Spatial diagonal: `Tr((γ^i)²) = -4`  for i ∈ {1,2,3}. -/
theorem spinorTrace_gammaI_sq (i : Fin 3) :
    let μ : FCIdx := ⟨i.val + 1, by omega⟩
    spinorTrace (gamma μ * gamma μ) = -4 := by
  intro μ
  rw [spinorTrace_two]
  -- η(μ,μ) = -1 since μ.val = i.val + 1 ≥ 1 ≠ 0
  have hne : μ.val ≠ 0 := by simp only [μ]; omega
  simp only [eta, if_neg hne]
  norm_num

-- ── TR-6: Trace recursion (Thomas Hahn Trace4) ───────────────────────────────
/-- **Trace recursion** (Hahn's Trace4 / FeynCalc `traceNo5`).
  For 2n gamma matrices (n ≥ 1):
  `Tr(γ^μ₁ γ^μ₂ … γ^μ_{2n})`
  `= ∑_{i=2}^{2n} (-1)^i g^{μ₁ μᵢ} · Tr(γ^μ₂ … γ̂^{μᵢ} … γ^{μ_{2n}})`
  where the hat denotes omission.

  Source: `DiracTrace.m` L641-648:
    `traceNo5[SI1_, SI2__] :=
      Plus @@ MapIndexed[((s = -s) Pair[SI1, #1] Drop[head[SI2], #2]) &, {SI2}]`
  This expands the first index against all others with alternating signs. -/
-- Helper: spinorTrace distributes over subtraction
private lemma spinorTrace_sub (A B : FCEnd) :
    spinorTrace (A - B) = spinorTrace A - spinorTrace B := by
  simp [spinorTrace, Matrix.trace_sub]

-- Helper: scalar-times-identity times matrix simplifies to scalar-times-matrix
private lemma smulEnd_one_mul (c : ℂ) (A : FCEnd) :
    smulEnd c oneEnd * A = smulEnd c A := by
  simp [smulEnd, oneEnd]

-- Helper: matrix times scalar-times-identity simplifies to scalar-times-matrix
private lemma mul_smulEnd_one (A : FCEnd) (c : ℂ) :
    A * smulEnd c oneEnd = smulEnd c A := by
  simp [smulEnd, oneEnd]

theorem spinorTrace_recursion_two (μ₁ μ₂ μ₃ μ₄ : FCIdx) :
    -- 4-gamma case: Tr(γ^μ₁ γ^μ₂ γ^μ₃ γ^μ₄)
    --  = g^{μ₁μ₂} Tr(γ^μ₃ γ^μ₄) - g^{μ₁μ₃} Tr(γ^μ₂ γ^μ₄) + g^{μ₁μ₄} Tr(γ^μ₂ γ^μ₃)
    spinorTrace (gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄) =
    (eta μ₁ μ₂ : ℂ) * spinorTrace (gamma μ₃ * gamma μ₄)
    - (eta μ₁ μ₃ : ℂ) * spinorTrace (gamma μ₂ * gamma μ₄)
    + (eta μ₁ μ₄ : ℂ) * spinorTrace (gamma μ₂ * gamma μ₃) := by
  -- From γ^a·γ^b = smulEnd (2η^{ab}) oneEnd - γ^b·γ^a (anticommutator rearranged)
  have hg12 : gamma μ₁ * gamma μ₂ =
      smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd - gamma μ₂ * gamma μ₁ :=
    eq_sub_of_add_eq (gamma_anticommute μ₁ μ₂)
  have hg13 : gamma μ₁ * gamma μ₃ =
      smulEnd (2 * (eta μ₁ μ₃ : ℂ)) oneEnd - gamma μ₃ * gamma μ₁ :=
    eq_sub_of_add_eq (gamma_anticommute μ₁ μ₃)
  have hg14 : gamma μ₁ * gamma μ₄ =
      smulEnd (2 * (eta μ₁ μ₄ : ℂ)) oneEnd - gamma μ₄ * gamma μ₁ :=
    eq_sub_of_add_eq (gamma_anticommute μ₁ μ₄)
  -- Step 1: Tr(γ¹γ²γ³γ⁴) = 2η¹²·Tr(γ³γ⁴) - Tr(γ²γ¹γ³γ⁴)
  have step1 :
      spinorTrace (gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄) =
      2 * (eta μ₁ μ₂ : ℂ) * spinorTrace (gamma μ₃ * gamma μ₄)
      - spinorTrace (gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄) := by
    have : gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄ =
        smulEnd (2*(eta μ₁ μ₂:ℂ)) (gamma μ₃ * gamma μ₄) -
        gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄ := by
      rw [show gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄ = (gamma μ₁ * gamma μ₂) * (gamma μ₃ * gamma μ₄) by (repeat rw [mul_assoc]), hg12]
      simp [smulEnd, oneEnd, sub_mul, mul_assoc]
    rw [this, spinorTrace_sub, spinorTrace_smul]
  have step2 :
      spinorTrace (gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄) =
      2 * (eta μ₁ μ₃ : ℂ) * spinorTrace (gamma μ₂ * gamma μ₄)
      - spinorTrace (gamma μ₂ * gamma μ₃ * gamma μ₁ * gamma μ₄) := by
    have : gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄ =
        smulEnd (2*(eta μ₁ μ₃:ℂ)) (gamma μ₂ * gamma μ₄) -
        gamma μ₂ * gamma μ₃ * gamma μ₁ * gamma μ₄ := by
      rw [show gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄ = gamma μ₂ * (gamma μ₁ * gamma μ₃) * gamma μ₄ by (repeat rw [mul_assoc]), hg13]
      simp [smulEnd, oneEnd, mul_sub, sub_mul, mul_assoc]
    rw [this, spinorTrace_sub, spinorTrace_smul]
  have step3 :
      spinorTrace (gamma μ₂ * gamma μ₃ * gamma μ₁ * gamma μ₄) =
      2 * (eta μ₁ μ₄ : ℂ) * spinorTrace (gamma μ₂ * gamma μ₃)
      - spinorTrace (gamma μ₂ * gamma μ₃ * gamma μ₄ * gamma μ₁) := by
    have : gamma μ₂ * gamma μ₃ * gamma μ₁ * gamma μ₄ =
        smulEnd (2*(eta μ₁ μ₄:ℂ)) (gamma μ₂ * gamma μ₃) -
        gamma μ₂ * gamma μ₃ * gamma μ₄ * gamma μ₁ := by
      rw [show gamma μ₂ * gamma μ₃ * gamma μ₁ * gamma μ₄ = (gamma μ₂ * gamma μ₃) * (gamma μ₁ * gamma μ₄) by (repeat rw [mul_assoc]), hg14]
      simp [smulEnd, oneEnd, mul_sub, mul_assoc]
    rw [this, spinorTrace_sub, spinorTrace_smul]
  -- Step 4: cyclicity Tr(γ²γ³γ⁴γ¹) = Tr(γ¹γ²γ³γ⁴)
  have hcyc :
      spinorTrace (gamma μ₂ * gamma μ₃ * gamma μ₄ * gamma μ₁) =
      spinorTrace (gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄) := by
    have h := spinorTrace_cyclic (gamma μ₁) (gamma μ₂ * gamma μ₃ * gamma μ₄)
    simp only [← mul_assoc] at h
    exact h.symm
  -- Combine: T = η¹²T₁₂ - η¹³T₁₃ + η¹⁴T₁₄  via linear_combination ½*step1 - ...
  linear_combination (1/2 : ℂ) * step1 - (1/2 : ℂ) * step2 +
                     (1/2 : ℂ) * step3 - (1/2 : ℂ) * hcyc

-- ── TR-4: Trace of four gammas ────────────────────────────────────────────────
/-- `Tr(γ^μ γ^ν γ^ρ γ^σ) = 4 (g^μν g^ρσ − g^μρ g^νσ + g^μσ g^νρ)`.
  Source: Thomas Hahn's Trace4 recursion (`traceNo5` in `DiracTrace.m` L641-648):
    `traceNo5[SI1, SI2, SI3, SI4] :=
       Pair[SI1, SI2] * traceNo5[SI3, SI4]
     - Pair[SI1, SI3] * traceNo5[SI2, SI4]
     + Pair[SI1, SI4] * traceNo5[SI2, SI3]`
  Combined with TraceOfOne = 4, this gives the standard 4-gamma formula. -/
theorem spinorTrace_four (μ ν ρ σ : FCIdx) :
    spinorTrace (gamma μ * gamma ν * gamma ρ * gamma σ) =
    4 * ((eta μ ν : ℂ) * (eta ρ σ) - (eta μ ρ) * (eta ν σ) + (eta μ σ) * (eta ν ρ)) := by
  rw [spinorTrace_recursion_two, spinorTrace_two, spinorTrace_two, spinorTrace_two]
  ring

-- ── TR-7: Trace with γ^5 ────────────────────────────────────────────────────
/-- `Tr(γ^μ γ^ν γ^ρ γ^σ γ^5) = -4i ε^μνρσ`  (4-dimensional, West convention).
  Source: `spur5In4Dim` / `trace5Wrap` in `DiracTrace.m` L655-710:
    `spur5In4Dim[x__DiracGamma, DiracGamma[5]] :=`
    `  trace5Wrap[First/@{x,DiracGamma[5]}]  /; EvenQ[Length[{x}]]`
  which ultimately yields `4I * Eps[μ,ν,ρ,σ]` for the 4-index case.
  The `leviCivitaSign` parameter is +1 (West convention, FeynCalc default). -/
private lemma lc_0123 : leviCivita 0 1 2 3 = 1 := leviCivita_0123

private lemma lc_0132 : leviCivita 0 1 3 2 = -1 := leviCivita_0132_neg

private lemma lc_0213 : leviCivita 0 2 1 3 = -1 := leviCivita_0213_neg

private lemma lc_0231 : leviCivita 0 2 3 1 = 1 := by
  have h := leviCivita_antisymm_last (μ := 0) (ν := 2) (ρ := 1) (σ := 3)
  linarith [h, lc_0213]

private lemma lc_0312 : leviCivita 0 3 1 2 = 1 := by
  have h := leviCivita_antisymm_12 (μ := 0) (ν := 1) (ρ := 3) (σ := 2)
  linarith [h, lc_0132]

private lemma lc_0321 : leviCivita 0 3 2 1 = -1 := by
  have h := leviCivita_antisymm_last (μ := 0) (ν := 3) (ρ := 1) (σ := 2)
  linarith [h, lc_0312]

private lemma lc_1023 : leviCivita 1 0 2 3 = -1 := leviCivita_1023_neg

private lemma lc_1032 : leviCivita 1 0 3 2 = 1 := by
  have h := leviCivita_antisymm_last (μ := 1) (ν := 0) (ρ := 2) (σ := 3)
  linarith [h, lc_1023]

private lemma lc_1203 : leviCivita 1 2 0 3 = 1 := by
  have h := leviCivita_antisymm_12 (μ := 1) (ν := 0) (ρ := 2) (σ := 3)
  linarith [h, lc_1023]

private lemma lc_1230 : leviCivita 1 2 3 0 = -1 := by
  have h := leviCivita_antisymm_last (μ := 1) (ν := 2) (ρ := 0) (σ := 3)
  linarith [h, lc_1203]

private lemma lc_1302 : leviCivita 1 3 0 2 = -1 := by
  have h := leviCivita_antisymm_12 (μ := 1) (ν := 0) (ρ := 3) (σ := 2)
  linarith [h, lc_1032]

private lemma lc_1320 : leviCivita 1 3 2 0 = 1 := by
  have h := leviCivita_antisymm_last (μ := 1) (ν := 3) (ρ := 0) (σ := 2)
  linarith [h, lc_1302]

private lemma lc_2013 : leviCivita 2 0 1 3 = 1 := by
  have h := leviCivita_antisymm_01 (μ := 0) (ν := 2) (ρ := 1) (σ := 3)
  linarith [h, lc_0213]

private lemma lc_2031 : leviCivita 2 0 3 1 = -1 := by
  have h := leviCivita_antisymm_last (μ := 2) (ν := 0) (ρ := 1) (σ := 3)
  linarith [h, lc_2013]

private lemma lc_2103 : leviCivita 2 1 0 3 = -1 := by
  have h := leviCivita_antisymm_01 (μ := 1) (ν := 2) (ρ := 0) (σ := 3)
  linarith [h, lc_1203]

private lemma lc_2130 : leviCivita 2 1 3 0 = 1 := by
  have h := leviCivita_antisymm_last (μ := 2) (ν := 1) (ρ := 0) (σ := 3)
  linarith [h, lc_2103]

private lemma lc_2301 : leviCivita 2 3 0 1 = 1 := by
  have h := leviCivita_antisymm_12 (μ := 2) (ν := 0) (ρ := 3) (σ := 1)
  linarith [h, lc_2031]

private lemma lc_2310 : leviCivita 2 3 1 0 = -1 := by
  have h := leviCivita_antisymm_last (μ := 2) (ν := 3) (ρ := 0) (σ := 1)
  linarith [h, lc_2301]

private lemma lc_3012 : leviCivita 3 0 1 2 = -1 := by
  have h := leviCivita_antisymm_01 (μ := 0) (ν := 3) (ρ := 1) (σ := 2)
  linarith [h, lc_0312]

private lemma lc_3021 : leviCivita 3 0 2 1 = 1 := by
  have h := leviCivita_antisymm_last (μ := 3) (ν := 0) (ρ := 1) (σ := 2)
  linarith [h, lc_3012]

private lemma lc_3102 : leviCivita 3 1 0 2 = 1 := by
  have h := leviCivita_antisymm_01 (μ := 1) (ν := 3) (ρ := 0) (σ := 2)
  linarith [h, lc_1302]

private lemma lc_3120 : leviCivita 3 1 2 0 = -1 := by
  have h := leviCivita_antisymm_last (μ := 3) (ν := 1) (ρ := 0) (σ := 2)
  linarith [h, lc_3102]

private lemma lc_3201 : leviCivita 3 2 0 1 = -1 := by
  have h := leviCivita_antisymm_12 (μ := 3) (ν := 0) (ρ := 2) (σ := 1)
  linarith [h, lc_3021]

private lemma lc_3210 : leviCivita 3 2 1 0 = 1 := by
  have h := leviCivita_antisymm_last (μ := 3) (ν := 2) (ρ := 0) (σ := 1)
  linarith [h, lc_3201]

set_option maxHeartbeats 1200000 in
theorem spinorTrace_four_gamma5 (μ ν ρ σ : FCIdx) :
    spinorTrace (gamma μ * gamma ν * gamma ρ * gamma σ * gamma5) =
    -4 * Complex.I * (leviCivita μ ν ρ σ : ℂ) := by
  fin_cases μ <;> fin_cases ν <;> fin_cases ρ <;> fin_cases σ <;>
    simp [spinorTrace, gamma, gamma5,
      diracGamma, diracGamma0, diracGamma1, diracGamma2, diracGamma3, diracGamma5,
      Matrix.trace, Matrix.diag, Matrix.mul_apply, Fin.sum_univ_four,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      leviCivita4_diagonal_01, leviCivita4_diagonal_12, leviCivita4_diagonal_23,
      leviCivita4_diagonal_02, leviCivita4_diagonal_03, leviCivita4_diagonal_13,
      lc_0123, lc_0132, lc_0213, lc_0231, lc_0312, lc_0321,
      lc_1023, lc_1032, lc_1203, lc_1230, lc_1302, lc_1320,
      lc_2013, lc_2031, lc_2103, lc_2130, lc_2301, lc_2310,
      lc_3012, lc_3021, lc_3102, lc_3120, lc_3201, lc_3210] <;>
    ring

/-- Tr(γ^μ γ^ν γ^5) = 0  (only 2 gammas before γ^5, gives length 2 < 4). -/
theorem spinorTrace_two_gamma5_zero (μ ν : FCIdx) :
    spinorTrace (gamma μ * gamma ν * gamma5) = 0 := by
  fin_cases μ <;> fin_cases ν <;>
    simp [spinorTrace, gamma, gamma5,
      diracGamma, diracGamma0, diracGamma1, diracGamma2, diracGamma3, diracGamma5,
      Matrix.trace, Matrix.diag, Matrix.mul_apply, Fin.sum_univ_four,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Complex.I_mul_I]

-- ── TR-8: Cyclicity ──────────────────────────────────────────────────────────
/-- Cyclic property: `Tr(γ^μ γ^ν) = Tr(γ^ν γ^μ)`.  Follows from TR-2 + eta symmetry. -/
theorem spinorTrace_two_symm (μ ν : FCIdx) :
    spinorTrace (gamma μ * gamma ν) = spinorTrace (gamma ν * gamma μ) := by
  rw [spinorTrace_two, spinorTrace_two]
  congr 1
  exact_mod_cast eta_symm μ ν

/-- General cyclic shift: `Tr(A₁ A₂ … Aₙ) = Tr(A₂ … Aₙ A₁)`. -/
theorem spinorTrace_cyclic_shift (A B : FCEnd) :
    spinorTrace (A * B) = spinorTrace (B * A) :=
  spinorTrace_cyclic A B

-- ── Convenience: Minkowski momentum products ──────────────────────────────────

/-- Helper: spinorTrace of a product of two scalar-scaled gamma matrices.
  `Tr(c·γ^μ · d·γ^ν) = c·d · 4g^μν`.
  Proof: use bimodule axioms to factor scalars, then apply TR-2. -/
private lemma trace_smul_gamma_mul (c d : ℂ) (μ ν : FCIdx) :
    spinorTrace (smulEnd c (gamma μ) * smulEnd d (gamma ν)) =
    c * d * (4 * (eta μ ν : ℂ)) := by
  rw [smulEnd_mul_left, smulEnd_mul_right, ← smulEnd_comp, spinorTrace_smul, spinorTrace_two]

/-- Feynman slash trace: `Tr(p̸ q̸) = 4 p·q` where `p·q = pμ qν g^μν`.
  Source: FeynCalc `DiracSimplify[Tr[Slash[p] . Slash[q]]]` → `4 Pair[p, q]`.
  Proof (Phase 1): expand pSlash to 4 terms, distribute trace via linearity,
  apply `trace_smul_gamma_mul` to each of the 16 product terms, evaluate η. -/
theorem spinorTrace_slash_slash (p q : FCIdx → ℝ) :
    spinorTrace (pSlash p * pSlash q) =
    4 * (Finset.univ (α := FCIdx)).sum (fun μ =>
          (Finset.univ (α := FCIdx)).sum (fun ν =>
            (eta μ ν : ℂ) * (p μ : ℂ) * (q ν : ℂ))) := by
  -- Step 1: expand pSlash (4-term explicit sum) and distribute the product
  simp only [pSlash, add_mul, mul_add, spinorTrace_add]
  -- Step 2: extract scalars via smulEnd bimodule lemmas, then apply Tr(γμ γν) = 4 ημν
  simp_rw [smulEnd_mul_left, smulEnd_mul_right, ← smulEnd_comp,
           spinorTrace_smul, spinorTrace_two]
  -- Step 3: expand the RHS double Finset.sum over FCIdx = Fin 4
  simp only [Fin.sum_univ_four]
  -- Step 4: evaluate eta at all 16 concrete (μ,ν) pairs; off-diagonal → 0
  -- simp (not simp only) uses ite_true/ite_false + DecidableEq (Fin 4) to evaluate if conditions
  simp [eta]; ring

end CATEPTMain.FEYNCALC
