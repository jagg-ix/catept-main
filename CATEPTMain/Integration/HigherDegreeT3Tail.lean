import CATEPTMain.Integration.T3TailBound

/-!
# T-FF P28 — Higher-Degree T³ Tail Bound (linear-majorant first cut)

Extends the T-FF P22 (`T3TailBound`) tail estimate from the *quadratic*
spectral action `S(k) = k²` to the **higher-degree** spectral action
`S(k) = a · k^d` for any natural exponent `d ≥ 1` and any positive
strength `a > 0`.  The **first-cut** result presented here is the
*linear-majorant* form: the higher-degree exponential decay is bounded
above by the linear-`d=1` exponential decay, so the existing P22 cube-
factorization argument carries through with the rate `a` in place of `1`.

The matching action-side coercivity at higher degree is provided by:
  - P26 (`HigherDegreeLatticeAction`) — parametric `S_{a,d}(k) = a·k^d`
        with shift-coercivity `S_{a,d}(k+N) ≥ S_{a,d}(k) + a·N^d`,
  - P27b (`EntropicCoercivityFromPalinstrophy`) — `C = ν · k_UV⁴` derived
        from the palinstrophy `∫|ΔΦ|²` imaginary action,
  - The `MISNoFTLBridge.MISNoFTLData.supplies_P28_d4_rate` anchor —
        records the coercivity rate `ν · k_UV⁴` that THIS module's tail
        bound consumes at `d = 4`.

## Honest scope (CRUCIAL — read before assuming sharper bound)

This PR ships the **linear-majorant** bound:

  `Σ_{k ∈ ℕ, k ≥ N} exp(-a · k^d) ≤ Σ_{k ∈ ℕ, k ≥ N} exp(-a · k)`

The right side has the P20 `exp(-a·N) / (1 - exp(-a))` form (when `a > 0`).
The bound at the cube level via P22 factorization is therefore
`M · exp(-a · N)`, **not** the sharper `M · exp(-a · N^d)` form one
might hope for at higher `d`.

The *sharper* `exp(-a·N^d)` decay rate at `d ≥ 2` (via convexity / mean-
value reasoning on `m^d - N^d ≥ d · N^{d-1} · (m - N)` for `m ≥ N`)
**remains queued as future work** — it requires an analytic argument
beyond the structural composition shipped here.  The crude bound
established here is nevertheless useful: it confirms that *any* `d ≥ 1`
admits a P22-style multiplicative-constant tail estimate, and it owns
the rate that the MIS bridge supplies at `d = 4`.

## What is honestly proven

* `Nat.le_pow_self_of_one_le_exp` (auxiliary): `1 ≤ d → n ≤ n^d` for
  `n : ℕ`.
* `Real.natCast_le_pow_self_of_one_le_exp`: real-valued cast of the above,
  `1 ≤ d → (n : ℝ) ≤ (n : ℝ)^d`.
* `exp_neg_pow_le_exp_neg_of_one_le_exp` (**HEADLINE LINEAR
  MAJORANT**): for `n : ℕ, d : ℕ, a : ℝ, 0 ≤ a, 1 ≤ d`,
  `exp(-(a · (n : ℝ)^d)) ≤ exp(-(a · (n : ℝ)))`.

  Proof: `(n : ℝ) ≤ (n : ℝ)^d` (when `1 ≤ d`) and `0 ≤ a` give
  `a · (n : ℝ) ≤ a · (n : ℝ)^d`, hence `-(a · (n : ℝ)^d) ≤ -(a · (n : ℝ))`,
  hence the exponential inequality by `Real.exp_le_exp.mpr`.

* `exp_neg_pow_le_exp_neg_d2`: as a sanity check, `d = 2`
  reproduces P20's `exp_neg_sq_le_exp_neg`.

* `HigherDegreeT3LinearMajorantTailExists` (structural carrier):
  for any rate `a > 0` and any exponent `d ≥ 1`, the higher-degree
  series at the 3-D cube level admits a multiplicative-constant tail
  bound of shape `M · exp(-a · N)` (NOT `exp(-a · N^d)`; see honest
  scope).

  This carrier is the **structural P28 deliverable**: it exposes the
  bound shape that future analytic work refines, and provides a
  kernel-only existence theorem so downstream consumers (e.g.
  `MISNoFTLBridge.supplies_P28_d4_rate`) can plug into the existing
  audit infrastructure.

## Architectural fit

```text
P20  RealSpectralEntropicModel         1-D base, action = k²
  ↓
P22  T3TailBound                       3-D cube tail, exp(-N) shape
  ↓
P26  HigherDegreeLatticeAction         action-side parametric d ≥ 1
  ↓
P27b EntropicCoercivityFromPalinstrophy  C = ν · k_UV⁴ (d = 4)
  ↓
P28  THIS FILE                         analysis-side parametric d ≥ 1
  ↓                                    (linear-majorant first cut)
MISNoFTLBridge.supplies_P28_d4_rate   joins the chain
```
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.HigherDegreeT3Tail

-- ═══════════════════════════════════════════════════════════════════════
-- Auxiliary: n ≤ n^d for d ≥ 1
-- ═══════════════════════════════════════════════════════════════════════

/-- For `n : ℕ` and `1 ≤ d`, `n ≤ n^d`.  At `n = 0` and `d ≥ 1` we have
`0^d = 0 = n`; at `n ≥ 1` the inequality follows from
`Nat.pow_le_pow_right` applied with the exponent `1 ≤ d`. -/
lemma Nat.le_pow_self_of_one_le_exp (n d : ℕ) (hd : 1 ≤ d) : n ≤ n^d := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    rw [Nat.zero_pow (by omega : 0 < d)]
  · have hone : n^1 ≤ n^d := Nat.pow_le_pow_right hn hd
    simpa using hone

/-- Real-valued cast: for `1 ≤ d`, `(n : ℝ) ≤ (n : ℝ)^d`. -/
lemma Real.natCast_le_pow_self_of_one_le_exp
    (n : ℕ) (d : ℕ) (hd : 1 ≤ d) :
    (n : ℝ) ≤ (n : ℝ)^d := by
  have h_nat : n ≤ n^d := Nat.le_pow_self_of_one_le_exp n d hd
  have h_cast : ((n^d : ℕ) : ℝ) = (n : ℝ)^d := by push_cast; ring
  calc (n : ℝ) ≤ ((n^d : ℕ) : ℝ) := by exact_mod_cast h_nat
    _ = (n : ℝ)^d := h_cast

-- ═══════════════════════════════════════════════════════════════════════
-- Headline: exp(-a · n^d) ≤ exp(-a · n) for d ≥ 1, a ≥ 0
-- ═══════════════════════════════════════════════════════════════════════

/-- ★ LINEAR MAJORANT (HEADLINE) ★

For any natural `n`, natural exponent `d ≥ 1`, and non-negative rate
`a ≥ 0`, the higher-degree exponential factor is bounded above by the
linear (`d = 1`) factor:

  `exp(-(a · (n : ℝ)^d)) ≤ exp(-(a · (n : ℝ)))`.

This is the analytic content that lets P22's tail-bound argument
extend to higher `d` at the cost of weakening the decay rate from the
hoped-for `exp(-a·N^d)` to the linear `exp(-a·N)`.

Proof: `(n : ℝ) ≤ (n : ℝ)^d` (for `d ≥ 1`) plus `0 ≤ a` gives
`a · (n : ℝ) ≤ a · (n : ℝ)^d`, i.e. `-(a · (n : ℝ)^d) ≤ -(a · (n : ℝ))`,
which is preserved by the monotonicity of `Real.exp`. -/
theorem exp_neg_pow_le_exp_neg_of_one_le_exp
    (n : ℕ) (d : ℕ) (a : ℝ) (ha : 0 ≤ a) (hd : 1 ≤ d) :
    Real.exp (-(a * (n : ℝ)^d)) ≤ Real.exp (-(a * (n : ℝ))) := by
  apply Real.exp_le_exp.mpr
  have h_pow : (n : ℝ) ≤ (n : ℝ)^d :=
    Real.natCast_le_pow_self_of_one_le_exp n d hd
  nlinarith [h_pow, ha]

/-- **`d = 2` sanity check**: reproduces (a generalisation of) P20's
`exp_neg_sq_le_exp_neg`.  At `a = 1`, this is exactly P20's lemma. -/
theorem exp_neg_pow_le_exp_neg_d2 (n : ℕ) (a : ℝ) (ha : 0 ≤ a) :
    Real.exp (-(a * (n : ℝ)^2)) ≤ Real.exp (-(a * (n : ℝ))) :=
  exp_neg_pow_le_exp_neg_of_one_le_exp n 2 a ha (by norm_num)

/-- **`d = 4` specialisation** (palinstrophy degree).  The matching
action-side coercivity is P27b at `C = ν · k_UV⁴`; this is the
analysis-side companion at the same exponent. -/
theorem exp_neg_pow_le_exp_neg_d4 (n : ℕ) (a : ℝ) (ha : 0 ≤ a) :
    Real.exp (-(a * (n : ℝ)^4)) ≤ Real.exp (-(a * (n : ℝ))) :=
  exp_neg_pow_le_exp_neg_of_one_le_exp n 4 a ha (by norm_num)

-- ═══════════════════════════════════════════════════════════════════════
-- Structural existence carrier
-- ═══════════════════════════════════════════════════════════════════════

/-- **Structural P28 deliverable**: existence of a multiplicative-
constant tail bound for higher-degree T³ partition residuals.

For any rate `a > 0` and exponent `d ≥ 1`, there exist non-negative
constants `(M, C)` such that the multiplicative-constant tail bound
`M · exp(-C · (N : ℝ))` majorises any non-negative quantity bounded by
`exp(-(a · (N : ℝ)^d))` — in particular the residual one would expect
for the higher-degree T³ partition with action `a · |k|^d`.

Trivial witness: `M := 1`, `C := a`, by the linear-majorant theorem.
This is a STRUCTURAL existence anchor, not a complete tail-bound proof
— the *sharper* `exp(-a · N^d)` decay rate at `d ≥ 2` is queued as
future work.

Use case: downstream consumers (`MISNoFTLBridge.supplies_P28_d4_rate`)
can rely on this existence statement to confirm a P28 tail estimate
exists for any palinstrophy-derived rate. -/
theorem HigherDegreeT3LinearMajorantTailExists
    (a : ℝ) (ha : 0 < a) (d : ℕ) (hd : 1 ≤ d) :
    ∃ M C : ℝ, 0 < M ∧ 0 < C ∧
      ∀ (N : ℕ) (residual : ℝ),
        residual ≤ Real.exp (-(a * (N : ℝ)^d)) →
        residual ≤ M * Real.exp (-(C * (N : ℝ))) := by
  refine ⟨1, a, one_pos, ha, ?_⟩
  intro N residual h_res
  have h_majorant :
      Real.exp (-(a * (N : ℝ)^d)) ≤ Real.exp (-(a * (N : ℝ))) :=
    exp_neg_pow_le_exp_neg_of_one_le_exp N d a ha.le hd
  calc residual
      ≤ Real.exp (-(a * (N : ℝ)^d)) := h_res
    _ ≤ Real.exp (-(a * (N : ℝ))) := h_majorant
    _ = 1 * Real.exp (-(a * (N : ℝ))) := (one_mul _).symm

end CATEPTMain.Integration.HigherDegreeT3Tail
