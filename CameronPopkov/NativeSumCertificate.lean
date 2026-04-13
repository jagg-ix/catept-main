import Mathlib.Analysis.Complex.Exponential
import Mathlib.Analysis.SpecialFunctions.Exp
import NavierStokesClean.CameronPopkov.DomainParameters

/-!
# Native Sum Certificate — Phase 10

Lean-native proof that `exp(−1519/200) ≤ 51/100000`,
discharging the Cameron sum upper bound without Wolfram computation.

## Proof sketch

The partial sum `Σ_{i=0}^{14} (1519/200)^i / i! ≥ 100000/51 ≈ 1961`
is verified by `norm_num` (rational arithmetic, 15 terms).

By `Real.sum_le_exp_of_nonneg`, this partial sum `≤ exp(1519/200)`.
Hence `exp(1519/200) ≥ 100000/51`, giving `exp(−1519/200) ≤ 51/100000`.

## Why 1519/200?

From `unit_torus_weyl_lb`: the Weyl constant satisfies `C_W > 1519/100`.
Under the Constantin-Iyer identification `ħ = 2ν`, the suppression rate is
`c' = C_W/2 > 1519/200 = 7.595`. The bound `exp(−c') ≤ exp(−1519/200)` is
thus a conservative upper bound on the dominant (k=1) term of the Cameron sum.

## Epistemic status

`.verified` — pure Lean/Mathlib computation (Taylor partial sum + norm_num).
Zero new axioms. Zero sorry. Replaces the `.openBridge` axiom from Phase 6.
-/

set_option autoImplicit false

open Real Finset Nat

namespace NavierStokesClean.CameronPopkov

/-! ## §1. Taylor partial sum lower bound (norm_num) -/

/-- The 15-term Taylor partial sum of exp(1519/200) exceeds 100000/51 ≈ 1960.78.

    Verified by norm_num: pure rational arithmetic over 15 terms. -/
theorem taylor_partial_sum_lb :
    (100000 / 51 : ℝ) ≤
    ∑ i ∈ range 15, (1519 / 200 : ℝ) ^ i / (factorial i : ℝ) := by
  norm_num [sum_range_succ, factorial]

/-! ## §2. Main exp bound — zero axioms -/

/-- **exp(−1519/200) ≤ 51/100000** (Lean-native, 0 new axioms, 0 sorry).

    This is the Lean-verifiable counterpart to the Wolfram `eq_238` bound:
    the dominant k=1 term of the Cameron trace sum satisfies
    `k^{1/3} · exp(−c' · k^{2/3})|_{k=1} = exp(−c') ≤ exp(−1519/200) ≤ 51/100000`.

    **Proof**: By `Real.sum_le_exp_of_nonneg`, the 15-term Taylor partial sum
    `Σ_{i=0}^{14} (1519/200)^i/i!` is ≤ exp(1519/200). That partial sum
    exceeds 100000/51 (by `norm_num`). Thus exp(1519/200) ≥ 100000/51,
    and exp(−1519/200) · exp(1519/200) = 1 (exp addition), so
    exp(−1519/200) ≤ 51/100000. -/
theorem cameron_exp_bound :
    Real.exp (-(1519 / 200 : ℝ)) ≤ 51 / 100000 := by
  have hpartial := taylor_partial_sum_lb
  have hTaylor := Real.sum_le_exp_of_nonneg (by norm_num : (0 : ℝ) ≤ 1519 / 200) 15
  have hge : (100000 / 51 : ℝ) ≤ Real.exp (1519 / 200) := le_trans hpartial hTaylor
  have hpos : (0 : ℝ) < Real.exp (-(1519 / 200 : ℝ)) := Real.exp_pos _
  have key : Real.exp (-(1519 / 200 : ℝ)) * Real.exp (1519 / 200) = 1 := by
    rw [← Real.exp_add]; norm_num
  nlinarith

end NavierStokesClean.CameronPopkov
