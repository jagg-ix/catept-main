import QuantumAlgebra.Discrete.IsabelleMarresDirac.Definitions
import Mathlib.Data.List.Basic

/-!
# AFP Isabelle_Marries_Dirac → Lean4 Faithful Port — Subset 2
Theories: Deutsch (continued), Deutsch_Jozsa
Theorems: 30 (indices 31–60)
Port date: 2026-04-07
Strategy: faithful types + real proofs (no NoFTLObj, no sorry except needs_human)

Proof status legend:
  ✓ = closed   ✗sorry = pending (see TODO)
-/

open QuantumAlgebra.Discrete.IsabelleMarresDirac
open IMD

namespace QuantumAlgebra.Discrete.IsabelleMarresDirac.Deutsch

-- ===== Deutsch (continued) =====

-- AFP: f_values — f(0) ∈ {0,1} ∧ f(1) ∈ {0,1}  (✓ exact)
-- AFP: Isabelle_Marries_Dirac.Deutsch.f_values#1
theorem f_values (f : Fin 2 → ℕ) (hdom : ∀ x : Fin 2, f x = 0 ∨ f x = 1) :
    (f 0 = 0 ∨ f 0 = 1) ∧ (f 1 = 0 ∨ f 1 = 1) :=
  ⟨hdom 0, hdom 1⟩

-- AFP: f_cases — f is either const or balanced  (✓ case split)
-- AFP: Isabelle_Marries_Dirac.Deutsch.f_cases#1
theorem f_cases (f : Fin 2 → ℕ) (hdom : ∀ x : Fin 2, f x = 0 ∨ f x = 1) :
    IMD.is_const_bool f ∨ IMD.is_balanced f := by
  rcases hdom 0 with h0 | h0 <;> rcases hdom 1 with h1 | h1
  · exact Or.inl (Or.inl ⟨h0, h1⟩)     -- const 0
  · exact Or.inr (Or.inr (by funext x; fin_cases x <;> simp_all))  -- id
  · exact Or.inr (Or.inl ⟨h0, h1⟩)     -- swap
  · exact Or.inl (Or.inr ⟨h0, h1⟩)     -- const 1

-- AFP: const_0_sum_mod_2 — is_const 0 f → (f(0)+f(1)) mod 2 = 0  (✓ omega)
-- AFP: Isabelle_Marries_Dirac.Deutsch.const_0_sum_mod_2#1
theorem const_0_sum_mod_2 (f : Fin 2 → ℕ) (h : IMD.is_const 0 f) :
    (f 0 + f 1) % 2 = 0 := by
  simp [IMD.is_const] at h; omega

-- AFP: const_1_sum_mod_2 — is_const 1 f → (f(0)+f(1)) mod 2 = 0  (✓ omega)
-- AFP: Isabelle_Marries_Dirac.Deutsch.const_1_sum_mod_2#1
theorem const_1_sum_mod_2 (f : Fin 2 → ℕ) (h : IMD.is_const 1 f) :
    (f 0 + f 1) % 2 = 0 := by
  simp [IMD.is_const] at h; omega

-- AFP: is_const_sum_mod_2 — is_const_bool f → (f(0)+f(1)) mod 2 = 0  (✓ cases)
-- AFP: Isabelle_Marries_Dirac.Deutsch.is_const_sum_mod_2#1
theorem is_const_sum_mod_2 (f : Fin 2 → ℕ) (h : IMD.is_const_bool f) :
    (f 0 + f 1) % 2 = 0 := by
  simp [IMD.is_const_bool, IMD.is_const] at h; omega

-- AFP: id_sum_mod_2 — f = id → (f(0)+f(1)) mod 2 = 1  (✓ decide)
-- AFP: Isabelle_Marries_Dirac.Deutsch.id_sum_mod_2#1
theorem id_sum_mod_2 (f : Fin 2 → ℕ) (hf : f = fun x => x.val) :
    (f 0 + f 1) % 2 = 1 := by subst hf; decide

-- AFP: is_balanced_sum_mod_2 — is_balanced f → (f(0)+f(1)) mod 2 = 1  (✓ IMD)
-- AFP: Isabelle_Marries_Dirac.Deutsch.is_balanced_sum_mod_2#1
theorem is_balanced_sum_mod_2 (f : Fin 2 → ℕ) (h : IMD.is_balanced f) :
    (f 0 + f 1) % 2 = 1 :=
  IMD.is_balanced_sum_mod_2 f h

-- AFP: f_ge_0 — ∀ x, f x ≥ 0  (✓ trivial)
-- AFP: Isabelle_Marries_Dirac.Deutsch.f_ge_0#1
theorem f_ge_0 (f : ℕ → ℕ) : ∀ x, f x ≥ 0 := by simp

-- ===== Deutsch: quantum gate theorems (needs_human — AFP matrix types) =====

-- AFP: ket_zero_is_state — |zero⟩ is a valid 1-qubit state  (✓ simp + norm_num)
-- AFP: Isabelle_Marries_Dirac.Deutsch.ket_zero_is_state#1
theorem ket_zero_is_state : IMD.QState 1 IMD.ket_zero := by
  simp [IMD.QState, IMD.ket_zero, Complex.normSq]

-- AFP: ket_one_is_state — |one⟩ is a valid 1-qubit state  (✓ simp + norm_num)
-- AFP: Isabelle_Marries_Dirac.Deutsch.ket_one_is_state#1
theorem ket_one_is_state : IMD.QState 1 IMD.ket_one := by
  simp [IMD.QState, IMD.ket_one, Complex.normSq]

-- AFP: H_on_ket_zero — H * |zero⟩ = (1/√2)(|0⟩ + |1⟩)
-- AFP: Isabelle_Marries_Dirac.Deutsch.H_on_ket_zero#1
-- needs_human: matrix multiplication; H_gate noncomputable
theorem H_on_ket_zero :
    IMD.H_gate * IMD.ket_zero =
    (1 / Real.sqrt 2 : ℂ) • (IMD.ket_zero + IMD.ket_one) := by
  simp [IMD.H_gate, IMD.ket_zero, IMD.ket_one]

-- AFP: H_on_ket_zero_is_state — H * |zero⟩ is a valid state  (✓)
-- AFP: Isabelle_Marries_Dirac.Deutsch.H_on_ket_zero_is_state#1
theorem H_on_ket_zero_is_state : IMD.QState 1 (IMD.H_gate * IMD.ket_zero) := by
  rw [H_on_ket_zero]
  have hsq : (Real.sqrt 2 : ℂ)^2 = 2 := by norm_cast; exact Real.sq_sqrt (by norm_num)
  simp only [IMD.QState]
  conv_lhs =>
    arg 2; ext x
    rw [show ((1 / Real.sqrt 2 : ℂ) • (IMD.ket_zero + IMD.ket_one)) x 0 = 1 / Real.sqrt 2 from by
      fin_cases x <;>
        simp [IMD.ket_zero, IMD.ket_one, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]]
  simp [Complex.normSq_div, Complex.normSq_ofReal, hsq, Finset.univ_fin2]

-- AFP: H_on_ket_one — H * |one⟩ = (1/√2)(|0⟩ - |1⟩)
-- AFP: Isabelle_Marries_Dirac.Deutsch.H_on_ket_one#1
theorem H_on_ket_one :
    IMD.H_gate * IMD.ket_one =
    (1 / Real.sqrt 2 : ℂ) • (IMD.ket_zero - IMD.ket_one) := by
  simp [IMD.H_gate, IMD.ket_zero, IMD.ket_one]

-- AFP: H_on_ket_one_is_state — H * |one⟩ is a valid state  (✓)
-- AFP: Isabelle_Marries_Dirac.Deutsch.H_on_ket_one_is_state#1
theorem H_on_ket_one_is_state : IMD.QState 1 (IMD.H_gate * IMD.ket_one) := by
  rw [H_on_ket_one]
  have hsq : (Real.sqrt 2 : ℂ)^2 = 2 := by norm_cast; exact Real.sq_sqrt (by norm_num)
  simp only [IMD.QState, Finset.univ_fin2, Finset.sum_pair (by decide : (0:Fin 2) ≠ 1),
             Matrix.smul_apply, Matrix.sub_apply, IMD.ket_zero, IMD.ket_one,
             Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  simp [Complex.normSq_mul, Complex.normSq_sub, Complex.normSq_ofReal, hsq]
  ring

-- AFP: H_tensor_Id_1 — H ⊗ Id₂ = specific 4×4 matrix
-- AFP: Isabelle_Marries_Dirac.Deutsch.H_tensor_Id_1#1
-- needs_human: requires Kronecker product definition in Lean4
-- theorem H_tensor_Id_1 : ... := by sorry

-- AFP: H_tensor_Id_1_is_gate — H ⊗ Id₂ is a 2-qubit gate
-- AFP: Isabelle_Marries_Dirac.Deutsch.H_tensor_Id_1_is_gate#1
-- needs_human: requires Kronecker product + unitary proof
-- theorem H_tensor_Id_1_is_gate : ... := by sorry

-- ===== Deutsch_Jozsa =====
-- All Deutsch_Jozsa theorems require iter_tensor (iterated Kronecker product)
-- which depends on the AFP Isabelle runtime-dimensioned matrix library.
-- These are needs_human: deferred pending Lean4 Kronecker product infrastructure.

-- AFP: is_balanced_inter — disjoint preimages for 0 and 1
-- AFP: Isabelle_Marries_Dirac.Deutsch_Jozsa.is_balanced_inter#1
theorem is_balanced_inter (A B : Finset ℕ) (f : ℕ → ℕ)
    (hA : ∀ x ∈ A, f x = 0) (hB : ∀ x ∈ B, f x = 1) :
    A ∩ B = ∅ := by
  ext x; simp; intro hxA hxB; linarith [hA x hxA, hB x hxB]

-- AFP: is_balanced_union — union of equal-card disjoint sets = full domain
-- AFP: Isabelle_Marries_Dirac.Deutsch_Jozsa.is_balanced_union#1
theorem is_balanced_union (n : ℕ) (A B : Finset ℕ)
    (hA : A ⊆ Finset.range (2^n)) (hB : B ⊆ Finset.range (2^n))
    (hcA : A.card = 2^(n-1)) (hcB : B.card = 2^(n-1)) (hdisj : A ∩ B = ∅) :
    A ∪ B = Finset.range (2^n) := by
  have hd : Disjoint A B := Finset.disjoint_iff_inter_eq_empty.mpr hdisj
  apply Finset.eq_of_subset_of_card_le (Finset.union_subset hA hB)
  rw [Finset.card_range, Finset.card_union_of_disjoint hd, hcA, hcB]
  cases n with
  | zero => norm_num
  | succ n =>
    simp only [Nat.succ_sub_one]
    linarith [show 2^n + 2^n = 2^(n + 1) from by ring]

-- AFP: Deutsch_Jozsa.f_ge_0, f_dom_not_zero, f_values, disj_four_cases:
-- needs_human — require Deutsch_Jozsa locale assumptions (dom, n ≥ 1, range constraint)
-- AFP: iter_tensor_* — all need iterated Kronecker product infrastructure
-- Remaining 20 Deutsch_Jozsa theorems: deferred (needs_human)

end QuantumAlgebra.Discrete.IsabelleMarresDirac.Deutsch
