import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Tactic.Ring

/-!
# Connes–Kreimer Antipode (Ladder Sector, Phase 2)

Phase-2 honest content for the **antipode** of the ladder sub-Hopf-algebra
of `H_FG`, identified with the polynomial Hopf algebra `ℝ[x]` via
  `xⁿ ⟼ Δ(xⁿ) = ∑_{k=0}^n C(n,k) · xᵏ ⊗ x^{n−k}`.

For a connected graded Hopf algebra the antipode `S` is determined by
the antipode equation `m ∘ (S ⊗ id) ∘ Δ = η ∘ ε`.  On the ladder
generator `x` it forces `S(x) = −x`, and on `xⁿ` it forces
`S(xⁿ) = (−1)ⁿ xⁿ`.  Substituting back into the antipode equation,
the coefficient of `xⁿ` collapses to the **Möbius / alternating-sum
identity**
  `∑_{k=0}^n (−1)ᵏ · C(n,k)  =  δ_{n,0}`.

This file ships that identity (lifted from Mathlib's
`Int.alternating_sum_range_choose`) along with the explicit antipode
function `ckLadderAntipodeSign` and its multiplicative property.

## Phase status

Phase-2 — honest algebraic identities for the ladder antipode.  Phase-3
will lift to the full graph-valued `H_FG` antipode and Birkhoff
decomposition for renormalisation characters.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ConnesKreimerAntipode

open Finset

/-- Sign factor in the ladder antipode `S(xⁿ) = (−1)ⁿ · xⁿ`. -/
def ckLadderAntipodeSign (n : ℕ) : ℤ := (-1) ^ n

/-- **Antipode normalisation**: `S(1) = 1` (the antipode preserves the
    unit, equivalently `(-1)⁰ = 1`). -/
theorem ckLadderAntipodeSign_zero :
    ckLadderAntipodeSign 0 = 1 := by
  unfold ckLadderAntipodeSign
  simp

/-- **Antipode is multiplicative on the ladder**: `S(xᵐ⁺ⁿ) = S(xᵐ)·S(xⁿ)`,
    realised on signs as `(-1)^(m+n) = (-1)^m · (-1)^n`. -/
theorem ckLadderAntipodeSign_add (m n : ℕ) :
    ckLadderAntipodeSign (m + n)
      = ckLadderAntipodeSign m * ckLadderAntipodeSign n := by
  unfold ckLadderAntipodeSign
  exact pow_add (-1) m n

/-- **Antipode axiom on the ladder generator** (the Möbius identity):
    the convolution `m ∘ (S ⊗ id) ∘ Δ` evaluated on `xⁿ` produces
    `(∑_{k=0}^n (−1)ᵏ · C(n,k)) · xⁿ`, which equals `δ_{n,0} · 1`.
    This is the antipode axiom `m ∘ (S ⊗ id) ∘ Δ = η ∘ ε`. -/
theorem ckLadder_antipode_axiom (n : ℕ) :
    (∑ k ∈ range (n + 1),
        ckLadderAntipodeSign k * (Nat.choose n k : ℤ))
      = if n = 0 then 1 else 0 := by
  unfold ckLadderAntipodeSign
  exact Int.alternating_sum_range_choose

/-- **Antipode axiom — non-trivial corollary**: for any `n ≠ 0` the
    convolution sum vanishes, witnessing that `(S ∗ id)(xⁿ) = 0`
    (the Hopf algebra obstruction is killed by the antipode in every
    positive degree). -/
theorem ckLadder_antipode_axiom_pos {n : ℕ} (hn : n ≠ 0) :
    (∑ k ∈ range (n + 1),
        ckLadderAntipodeSign k * (Nat.choose n k : ℤ)) = 0 := by
  rw [ckLadder_antipode_axiom, if_neg hn]

end CATEPTMain.Integration.ConnesKreimerAntipode
