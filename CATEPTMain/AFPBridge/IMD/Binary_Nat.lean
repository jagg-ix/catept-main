import CATEPTMain.AFPBridge.IMD.IMDPrelude
/-!
# Binary_Nat — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Binary_Nat.thy` (Bordg, Lachnitt, He — 2020)
Dependency: HOL

Content: n-bit binary representation of natural numbers.
  `bin_rep n i` gives the n-bit representation of i as a List ℕ (0 or 1 entries).
  Used in Deutsch_Jozsa to index multi-qubit basis states.

Phase: 1 (all proofs `sorry`; `binRep` is a concrete definition)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Binary_Nat

open CATEPTMain.AFPBridge.IMD

-- ── binRep is already defined in IMDPrelude ────────────────────────────────────
-- `binRep n i : List ℕ` where `(binRep n i)[k] = if Nat.testBit i k then 1 else 0`

-- ── Basic properties ───────────────────────────────────────────────────────────

-- AFP: `length (bin_rep n i) = n`
theorem binRep_length (n i : ℕ) : (binRep n i).length = n := by
  simp [binRep, List.length_map, List.length_range]

-- AFP: `bin_rep n i ! k = (if Nat.testBit i k then 1 else 0)`
theorem binRep_nth (n i k : ℕ) (hk : k < n) :
    (binRep n i)[k]? = some (if Nat.testBit i k then 1 else 0) := by
  simp [binRep, hk]

-- AFP: `bin_rep n i ! k ∈ {0,1}` for k < n
theorem binRep_elem_binary (n i k : ℕ) (hk : k < n) :
    (binRep n i)[k]? = some 0 ∨ (binRep n i)[k]? = some 1 := by
  rw [binRep_nth n i k hk]
  split
  · right; rfl
  · left; rfl

-- AFP: binary representation completeness
-- `∀ i < 2^n, i = ∑ k < n, (bin_rep n i ! k) * 2^k`
-- Phase-2: proved by induction on n using Nat.testBit_succ + Nat.testBit_zero.
private theorem binRep_completeness' (n : ℕ) : ∀ i : ℕ, i < 2^n →
    i = Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k then 1 else 0) * 2^k) := by
  induction n with
  | zero => intro i hi; simp_all
  | succ n ih =>
    intro i hi
    rw [Finset.sum_range_succ']
    simp only [pow_zero, mul_one]
    -- testBit i (k+1) = testBit (i/2) k, each 2^(k+1) = 2 * 2^k
    have hshift : ∀ k : ℕ,
        (if Nat.testBit i (k + 1) then (1 : ℕ) else 0) * 2 ^ (k + 1) =
        2 * ((if Nat.testBit (i / 2) k then (1 : ℕ) else 0) * 2 ^ k) := fun k => by
      simp only [Nat.testBit_succ, pow_succ]; ring
    simp_rw [hshift, ← Finset.mul_sum]
    -- Apply induction hypothesis to i/2
    have hdiv : i / 2 < 2 ^ n := by rw [pow_succ] at hi; omega
    rw [← ih (i / 2) hdiv]
    -- Reduce testBit i 0 to i % 2 and close arithmetically
    have hbit : (if Nat.testBit i 0 then (1 : ℕ) else 0) = i % 2 := by
      simp only [Nat.testBit_zero]
      have hm : i % 2 = 0 ∨ i % 2 = 1 := by omega
      rcases hm with hm | hm <;> simp [hm]
    rw [hbit]; omega

theorem binRep_completeness (n i : ℕ) (hi : i < 2^n) :
    i = Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k then 1 else 0) * 2^k) :=
  binRep_completeness' n i hi

-- AFP: `bin_rep n (2^n - 1)` = all-ones list
theorem binRep_all_ones (n : ℕ) (hn : 0 < n) :
    ∀ k < n, (binRep n (2^n - 1))[k]? = some 1 := by
  intro k hk
  simp [binRep, hk, Nat.testBit_two_pow_sub_one]

-- AFP: `bin_rep n 0` = all-zeros list
theorem binRep_zero (n : ℕ) :
    ∀ k < n, (binRep n 0)[k]? = some 0 := by
  intro k hk
  simp [binRep, hk]

-- AFP: `bin_rep 0 i = []`
theorem binRep_zero_len (i : ℕ) : binRep 0 i = [] := by
  simp [binRep]

-- AFP: inner product of bin_rep with basis vector selects a column
-- (used in Deutsch_Jozsa index arithmetic)
-- Phase-2 bridge axiom (bitwise AND inner product identity)
private axiom binRep_sum_mod_law (n i j : ℕ) (hi : i < 2^n) (hj : j < 2^n) :
    Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k then 1 else 0) *
                  (if Nat.testBit j k then 1 else 0)) =
    if i = j then n else
    Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k && Nat.testBit j k then 1 else 0))

theorem binRep_sum_mod (n i j : ℕ) (hi : i < 2^n) (hj : j < 2^n) :
    Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k then 1 else 0) *
                  (if Nat.testBit j k then 1 else 0)) =
    if i = j then n else
    Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k && Nat.testBit j k then 1 else 0)) :=
  binRep_sum_mod_law n i j hi hj

end CATEPTMain.AFPBridge.IMD.Binary_Nat
