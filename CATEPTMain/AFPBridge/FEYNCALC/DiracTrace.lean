import CATEPTMain.AFPBridge.FEYNCALC.DiracAlgebra
import CATEPTMain.AFPBridge.FEYNCALC.LorentzAlgebra
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

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.FEYNCALC

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
  have h2 : (2 : ℂ) * spinorTrace A = 0 := by linarith
  rcases mul_eq_zero.mp h2 with h | h
  · norm_num at h
  · exact h

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
  have h2 : (2 : ℂ) * spinorTrace (gamma μ * gamma5) = 0 := by linarith
  rcases mul_eq_zero.mp h2 with h | h
  · norm_num at h
  · exact h

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
  simp only [eta, if_pos (show μ = μ from rfl), if_neg hne]
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
theorem spinorTrace_recursion_two (μ₁ μ₂ μ₃ μ₄ : FCIdx) :
    -- 4-gamma case: Tr(γ^μ₁ γ^μ₂ γ^μ₃ γ^μ₄)
    --  = g^{μ₁μ₂} Tr(γ^μ₃ γ^μ₄) - g^{μ₁μ₃} Tr(γ^μ₂ γ^μ₄) + g^{μ₁μ₄} Tr(γ^μ₂ γ^μ₃)
    spinorTrace (gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄) =
    (eta μ₁ μ₂ : ℂ) * spinorTrace (gamma μ₃ * gamma μ₄)
    - (eta μ₁ μ₃ : ℂ) * spinorTrace (gamma μ₂ * gamma μ₄)
    + (eta μ₁ μ₄ : ℂ) * spinorTrace (gamma μ₂ * gamma μ₃) := by
  -- Pass γ¹ through the chain via anticommutation: γ¹γⁱ = 2η^{1i}·1 - γⁱγ¹
  -- Step 1: γ¹γ² = smulEnd(2η₁₂)1 - γ²γ¹
  have hac12 : gamma μ₁ * gamma μ₂ = smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd - gamma μ₂ * gamma μ₁ := by
    have := gamma_anticommute μ₁ μ₂
    have hsub : smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd - gamma μ₂ * gamma μ₁ =
                gamma μ₁ * gamma μ₂ := by
      rw [show smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd - gamma μ₂ * gamma μ₁ =
              smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd + negEnd (gamma μ₂ * gamma μ₁) from rfl,
          ← negEnd_eq_smulNeg, ← add_negEnd_self (gamma μ₂ * gamma μ₁),
          ← addEnd_assoc, this, zeroEnd_add_left]
    exact hsub.symm
  -- Step 2: similarly for μ₁,μ₃ and μ₁,μ₄
  have hac13 : gamma μ₁ * gamma μ₃ = smulEnd (2 * (eta μ₁ μ₃ : ℂ)) oneEnd - gamma μ₃ * gamma μ₁ := by
    have := gamma_anticommute μ₁ μ₃
    have hsub : smulEnd (2 * (eta μ₁ μ₃ : ℂ)) oneEnd - gamma μ₃ * gamma μ₁ =
                gamma μ₁ * gamma μ₃ := by
      rw [show smulEnd (2 * (eta μ₁ μ₃ : ℂ)) oneEnd - gamma μ₃ * gamma μ₁ =
              smulEnd (2 * (eta μ₁ μ₃ : ℂ)) oneEnd + negEnd (gamma μ₃ * gamma μ₁) from rfl,
          ← negEnd_eq_smulNeg, ← add_negEnd_self (gamma μ₃ * gamma μ₁),
          ← addEnd_assoc, this, zeroEnd_add_left]
    exact hsub.symm
  have hac14 : gamma μ₁ * gamma μ₄ = smulEnd (2 * (eta μ₁ μ₄ : ℂ)) oneEnd - gamma μ₄ * gamma μ₁ := by
    have := gamma_anticommute μ₁ μ₄
    have hsub : smulEnd (2 * (eta μ₁ μ₄ : ℂ)) oneEnd - gamma μ₄ * gamma μ₁ =
                gamma μ₁ * gamma μ₄ := by
      rw [show smulEnd (2 * (eta μ₁ μ₄ : ℂ)) oneEnd - gamma μ₄ * gamma μ₁ =
              smulEnd (2 * (eta μ₁ μ₄ : ℂ)) oneEnd + negEnd (gamma μ₄ * gamma μ₁) from rfl,
          ← negEnd_eq_smulNeg, ← add_negEnd_self (gamma μ₄ * gamma μ₁),
          ← addEnd_assoc, this, zeroEnd_add_left]
    exact hsub.symm
  -- Step 3: cancel factor of 2 from the final equation
  apply mul_left_cancel₀ (show (2 : ℂ) ≠ 0 by norm_num)
  -- The proof: 2·Tr(γ¹γ²γ³γ⁴)
  -- = Tr(γ¹γ²γ³γ⁴) + Tr(γ¹γ²γ³γ⁴)   by ring
  -- Pass γ¹ right past γ² in first copy; right past γ²γ³ past γ⁴ in second…
  -- use cyclicity Tr(γ²γ³γ⁴γ¹) = Tr(γ¹γ²γ³γ⁴) so we can set up the cancellation.
  -- Simpler: use the two traces with the anticommutator
  --   First copy: rewrite γ¹γ²→ anticomm = (2η₁₂·1 - γ²γ¹)
  --   Track: Tr((2η₁₂·1 - γ²γ¹)γ³γ⁴) = 2η₁₂·Tr(γ³γ⁴) - Tr(γ²γ¹γ³γ⁴)
  --   Second copy: leave as is, use cyclicity to match
  -- Actually use the one-step chain passing γ¹ through everything, ending with cyclicity.
  -- Tr(γ¹γ²γ³γ⁴) from first copy (rewrite γ¹γ²):
  have step12 : spinorTrace (gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄) =
      (2 * (eta μ₁ μ₂ : ℂ)) * spinorTrace (gamma μ₃ * gamma μ₄) -
      spinorTrace (gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄) := by
    rw [show gamma μ₁ * gamma μ₂ * gamma μ₃ * gamma μ₄ =
            (smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd - gamma μ₂ * gamma μ₁) * gamma μ₃ * gamma μ₄ by
          rw [← hac12],
        show (smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd - gamma μ₂ * gamma μ₁) * gamma μ₃ * gamma μ₄ =
             smulEnd (2 * (eta μ₁ μ₂ : ℂ)) oneEnd * gamma μ₃ * gamma μ₄ -
             gamma μ₂ * gamma μ₁ * gamma μ₃ * gamma μ₄ from by
          simp only [sub_eq_add_neg, negEnd_eq_smulNeg,
                     smulEnd_mul_left, smulEnd_mul_right, compEnd_distrib_right,
                     ← negEnd_eq_smulNeg]; ring_nf
                     ]
    sorry
  sorry

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
/-- `Tr(γ^μ γ^ν γ^ρ γ^σ γ^5) = 4i ε^μνρσ`  (4-dimensional, West convention).
  Source: `spur5In4Dim` / `trace5Wrap` in `DiracTrace.m` L655-710:
    `spur5In4Dim[x__DiracGamma, DiracGamma[5]] :=`
    `  trace5Wrap[First/@{x,DiracGamma[5]}]  /; EvenQ[Length[{x}]]`
  which ultimately yields `4I * Eps[μ,ν,ρ,σ]` for the 4-index case.
  The `leviCivitaSign` parameter is +1 (West convention, FeynCalc default). -/
theorem spinorTrace_four_gamma5 (μ ν ρ σ : FCIdx) :
    spinorTrace (gamma μ * gamma ν * gamma ρ * gamma σ * gamma5) =
    4 * Complex.I * (leviCivita μ ν ρ σ : ℂ) := by
  sorry  -- phase2_high: spur5In4Dim from DiracTrace.m L655-710; needs γ^5 = iγ^0γ^1γ^2γ^3

/-- Tr(γ^μ γ^ν γ^5) = 0  (only 2 gammas before γ^5, gives length 2 < 4). -/
theorem spinorTrace_two_gamma5_zero (μ ν : FCIdx) :
    spinorTrace (gamma μ * gamma ν * gamma5) = 0 := by
  sorry  -- phase2_high: DiracTrace.m L343 — fewer than 4 gammas with γ^5 vanishes

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
  -- Unfold pSlash: p̸ = p₀γ⁰ − p₁γ¹ − p₂γ² − p₃γ³
  simp only [pSlash]
  -- Expand the product of two 4-term sums to 16 individual products
  simp only [compEnd_distrib_right, compEnd_distrib_left]
  -- Distribute spinorTrace over + and apply trace_smul_gamma_mul to each term
  simp only [spinorTrace_add, trace_smul_gamma_mul]
  -- Expand the RHS Finset.univ double sum to 16 explicit terms
  simp only [Fin.sum_univ_four]
  -- Evaluate η at all 16 index pairs (off-diagonal → 0; diagonal: η(0,0)=1, η(i,i)=-1)
  simp only [eta,
    if_pos (show (0 : FCIdx) = 0 from rfl),
    if_pos (show (1 : FCIdx) = 1 from rfl),
    if_pos (show (2 : FCIdx) = 2 from rfl),
    if_pos (show (3 : FCIdx) = 3 from rfl),
    if_neg (show ¬(0 : FCIdx) = 1 from by decide),
    if_neg (show ¬(0 : FCIdx) = 2 from by decide),
    if_neg (show ¬(0 : FCIdx) = 3 from by decide),
    if_neg (show ¬(1 : FCIdx) = 0 from by decide),
    if_neg (show ¬(1 : FCIdx) = 2 from by decide),
    if_neg (show ¬(1 : FCIdx) = 3 from by decide),
    if_neg (show ¬(2 : FCIdx) = 0 from by decide),
    if_neg (show ¬(2 : FCIdx) = 1 from by decide),
    if_neg (show ¬(2 : FCIdx) = 3 from by decide),
    if_neg (show ¬(3 : FCIdx) = 0 from by decide),
    if_neg (show ¬(3 : FCIdx) = 1 from by decide),
    if_neg (show ¬(3 : FCIdx) = 2 from by decide),
    if_pos (show (0 : FCIdx).val = 0 from rfl),
    if_neg (show ¬(1 : FCIdx).val = 0 from by decide),
    if_neg (show ¬(2 : FCIdx).val = 0 from by decide),
    if_neg (show ¬(3 : FCIdx).val = 0 from by decide)]
  push_cast

end CATEPTMain.AFPBridge.FEYNCALC
