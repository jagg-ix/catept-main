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

namespace CATEPTMain.AFPBridge.IMD.Theories.Binary_Nat

open CATEPTMain.AFPBridge.IMD

-- ── binRep is already defined in IMDPrelude ────────────────────────────────────
-- `binRep n i : List ℕ` where `(binRep n i)[k] = if Nat.testBit i k then 1 else 0`

-- ── Basic properties ───────────────────────────────────────────────────────────

-- AFP: `length (bin_rep n i) = n`
theorem binRep_length (n i : ℕ) : (binRep n i).length = n := by
  simp [binRep, List.length_map, List.length_range]

-- AFP: `bin_rep n i ! k ∈ {0,1}` for k < n
theorem binRep_elem_binary (n i k : ℕ) (hk : k < n) :
    (binRep n i)[k]? = some 0 ∨ (binRep n i)[k]? = some 1 := by
  sorry -- phase2_simp [binRep, List.getElem?_map, List.getElem?_range]

-- AFP: `bin_rep n i ! k = (if Nat.testBit i k then 1 else 0)`
theorem binRep_nth (n i k : ℕ) (hk : k < n) :
    (binRep n i)[k]? = some (if Nat.testBit i k then 1 else 0) := by
  sorry -- phase2_simp [binRep, List.getElem?_map, List.getElem?_range_eq]

-- AFP: binary representation completeness
-- `∀ i < 2^n, i = ∑ k < n, (bin_rep n i ! k) * 2^k`
theorem binRep_completeness (n i : ℕ) (hi : i < 2^n) :
    i = Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k then 1 else 0) * 2^k) := by
  sorry -- phase2_high: Nat.testBit sum decomposition, requires Nat.sum_testBit or induction

-- AFP: `bin_rep n (2^n - 1)` = all-ones list
theorem binRep_all_ones (n : ℕ) (hn : 0 < n) :
    ∀ k < n, (binRep n (2^n - 1))[k]? = some 1 := by
  sorry -- phase2_simp [binRep, Nat.testBit_two_pow_sub_one]

-- AFP: `bin_rep n 0` = all-zeros list
theorem binRep_zero (n : ℕ) :
    ∀ k < n, (binRep n 0)[k]? = some 0 := by
  sorry -- phase2_simp [binRep, Nat.testBit_zero]

-- AFP: `bin_rep 0 i = []`
theorem binRep_zero_len (i : ℕ) : binRep 0 i = [] := by
  simp [binRep]

-- AFP: inner product of bin_rep with basis vector selects a column
-- (used in Deutsch_Jozsa index arithmetic)
theorem binRep_sum_mod (n i j : ℕ) (hi : i < 2^n) (hj : j < 2^n) :
    Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k then 1 else 0) *
                  (if Nat.testBit j k then 1 else 0)) =
    if i = j then n else
    Finset.sum (Finset.range n)
        (fun k => (if Nat.testBit i k && Nat.testBit j k then 1 else 0)) := by
  sorry -- phase2_high

end CATEPTMain.AFPBridge.IMD.Theories.Binary_Nat
