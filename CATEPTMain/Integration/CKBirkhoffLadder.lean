import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Ring
import CATEPTMain.Integration.ConnesKreimerLadder
import CATEPTMain.Integration.ConnesKreimerAntipode
import CATEPTMain.Integration.BPHZForestLadder

/-!
# Connes–Kreimer Convolution Algebra & Birkhoff Decomposition (T-DD Phase 4)

Phase-4 honest content for the **Connes–Kreimer Hopf algebra** of
Feynman graphs at the ladder level. Phases 1–3 pinned the coproduct
coefficients `C(n,k)`, the antipode signs `(−1)ⁿ`, and the
forest-formula cancellation `Z_R(xⁿ) = δ_{n,0}` (Möbius identity).

Phase 4 lifts these data into the **convolution-algebra structure**
on characters of the ladder Hopf-algebra. For functions
`φ, ψ : ℕ → ℤ` (interpreted as characters of the ladder
sub-Hopf-algebra), define the convolution

  `(φ ∗ ψ)(n)  =  ∑_{k=0}^{n}  C(n,k) · φ(k) · ψ(n-k)`,

induced by the Pascal coproduct `Δ(xⁿ) = ∑ C(n,k) xᵏ ⊗ xⁿ⁻ᵏ`.
The unit of this convolution is the counit `ε(n) = δ_{n,0}`.
The Hopf-algebra antipode axiom

  `S ∗ id  =  η ∘ ε`

is the Birkhoff-decomposition statement: `S = (id)^{∗ -1}` in the
convolution algebra. On the ladder this reduces to the classical
binomial-sum identity, and we ship it as `ckLadderConv_S_id`.

* `ckLadderConv`                 — convolution product on characters.
* `ckLadderConv_one_left`        — `ε ∗ φ = φ` (left unit).
* `ckLadderConv_S_id`            — `S ∗ id = ε`, the Birkhoff
                                   inversion / antipode axiom in the
                                   convolution algebra.
* `ckLadderConv_id_S_at_zero`    — `(id ∗ S)(0) = 1`, unit-sector
                                   normalisation of the right-side
                                   convolution.

## Phase status

Phase-4 — kernel-only `[propext, Classical.choice, Quot.sound]`.
Genuine graph-valued antipode on the full Hopf algebra `H_FG` of
1PI Feynman graphs and the dim-reg Birkhoff factorisation
`φ = φ_- ∗ φ_+` of regularised characters remain deferred.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CKBirkhoffLadder

open Finset
open CATEPTMain.Integration.ConnesKreimerLadder
open CATEPTMain.Integration.ConnesKreimerAntipode
open CATEPTMain.Integration.BPHZForestLadder

/-- **Counit / convolution unit** of the ladder Hopf-algebra:
    `ε(0) = 1`, `ε(n) = 0` for `n > 0`. -/
def ckLadderCounit (n : ℕ) : ℤ := if n = 0 then 1 else 0

/-- **Convolution product** on characters of the ladder
    sub-Hopf-algebra, induced by the Pascal coproduct
    `Δ(xⁿ) = ∑ C(n,k) xᵏ ⊗ xⁿ⁻ᵏ`:
      `(φ ∗ ψ)(n) = ∑_{k=0}^{n} C(n,k) · φ(k) · ψ(n-k)`. -/
def ckLadderConv (φ ψ : ℕ → ℤ) (n : ℕ) : ℤ :=
  ∑ k ∈ range (n + 1), (Nat.choose n k : ℤ) * φ k * ψ (n - k)

/-- **Left unit** of the convolution algebra: `ε ∗ φ = φ`.
    Only the `k = 0` term survives by `ε(k) = δ_{k,0}`. -/
theorem ckLadderConv_one_left (φ : ℕ → ℤ) (n : ℕ) :
    ckLadderConv ckLadderCounit φ n = φ n := by
  unfold ckLadderConv ckLadderCounit
  rw [Finset.sum_eq_single 0]
  · simp
  · intro k hk hk0
    simp [hk0]
  · intro h
    exact (h (Finset.mem_range.mpr (Nat.succ_pos n))).elim

/-- **Birkhoff antipode axiom** on the ladder convolution algebra:
      `(S ∗ id)(n)  =  ε(n)  =  δ_{n,0}`.
    This is the Hopf-algebra statement `S ∗ id = η ∘ ε` in the
    convolution algebra of characters, expressing that the antipode
    `S(xᵏ) = (−1)ᵏ · xᵏ` is the convolution-inverse of the identity
    character. The proof routes through the Möbius identity
    (`ckLadder_antipode_axiom`) via the BPHZ-forest closed form. -/
theorem ckLadderConv_S_id (n : ℕ) :
    ckLadderConv (fun k => ckLadderAntipodeSign k) (fun _ => 1) n
      = ckLadderCounit n := by
  unfold ckLadderConv ckLadderCounit
  -- Rewrite ∑ C(n,k) · S(k) · 1 as ∑ S(k) · C(n,k)
  have h : (∑ k ∈ range (n + 1),
              (Nat.choose n k : ℤ) * ckLadderAntipodeSign k * 1)
         = ∑ k ∈ range (n + 1),
              ckLadderAntipodeSign k * (Nat.choose n k : ℤ) := by
    apply Finset.sum_congr rfl
    intro k _
    ring
  rw [h]
  exact ckLadder_antipode_axiom n

/-- **Unit-sector normalisation** of the right-side convolution
    `(id ∗ S)(0) = 1`. This is the trivial ladder sector check
    that the antipode is also a *right* convolution-inverse on the
    unit. -/
theorem ckLadderConv_id_S_at_zero :
    ckLadderConv (fun _ => 1) (fun k => ckLadderAntipodeSign k) 0 = 1 := by
  unfold ckLadderConv ckLadderAntipodeSign
  simp

end CATEPTMain.Integration.CKBirkhoffLadder
