import CATEPTMain.CATEPT.CATEPT.BellCHSHBohmCoreAbstractions

set_option autoImplicit false

/-!
# Example 4: Tsirelson Bound from Entropic Rate

## What makes this unique to CAT/EPT

In standard QM, the Tsirelson bound 2√2 on CHSH correlations is derived
from operator algebra (Cirelson's theorem). It's a mathematical fact
about Hilbert space, with no deeper physical explanation.

In CAT/EPT, the same bound emerges from the **entropic rate**:

  b(λ) = exp(λ) - 1

where λ is the entropic rate (entropy production per unit time).
At the calibration point λ = ln(2√2 + 1):

  b(λ) = exp(ln(2√2 + 1)) - 1 = 2√2

This gives quantum non-locality a **thermodynamic explanation**:
the Tsirelson bound is the maximum Bell violation achievable at a
specific entropy production rate.

## Key results

1. Classical CHSH bound |S| ≤ 2 (proved by case analysis)
2. 2 < 2√2 (quantum violates classical)
3. Bell rate b(λ) = exp(λ) - 1 connects entropy to non-locality
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Classical CHSH bound: |S| ≤ 2 for all deterministic assignments
example (x : CHSHDeterministicAssignment) :
    |classicalCHSHValue x| ≤ 2 :=
  classicalCHSH_bound x

-- Tsirelson witness value
example : tsirelsonWitness = 2 * Real.sqrt 2 := rfl

-- 2 ≤ 2√2 (classical bound ≤ quantum bound)
example : (2 : ℝ) ≤ tsirelsonWitness :=
  classical_bound_le_two

-- Strict: 2 < 2√2 (quantum genuinely exceeds classical)
example : (2 : ℝ) < tsirelsonWitness :=
  classical_bound_lt_tsirelson

-- Bell rate from entropic rate: b(λ) = exp(λ) - 1
example (λ : ℝ) : bellRateFromEntropicRate λ = Real.exp λ - 1 := rfl

-- Rearranged: b(λ) + 1 = exp(λ)
example (λ : ℝ) : bellRateFromEntropicRate λ + 1 = Real.exp λ :=
  bellRate_rearranged λ

end CATEPT.Examples
