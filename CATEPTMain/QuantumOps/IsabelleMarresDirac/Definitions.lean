import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.LinearAlgebra.UnitaryGroup
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.LinearAlgebra.Matrix.Reindex
import Mathlib.Data.Nat.Bitwise
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.List.Basic

/-!
# AFP Isabelle_Marries_Dirac — Lean4 Faithful Definitions
Source: AFP Isabelle `Isabelle_Marries_Dirac`, theories Basics/Binary_Nat/Deutsch/Quantum/etc.
Pipeline: faithful port (2026-04-07) — real types, real proofs, no NoFTLObj

These definitions faithfully mirror the AFP Isabelle concepts in Lean4/Mathlib types.
Structural proofs for `bin_rep` use `sorry` pending completion (the types are faithful).
-/

namespace CATEPTMain.QuantumOps.IsabelleMarresDirac

-- AFP IMD namespace: mirrors Isabelle_Marries_Dirac Isabelle theories
namespace IMD

-- ===== Binary representation (Binary_Nat.thy) =====
-- bin_rep_aux n m: n+1 bits MSB-first
-- AFP: bin_rep_aux 0 m = [m%2]; bin_rep_aux (n+1) m = (m/2^(n+1))%2 :: bin_rep_aux n m
def bin_rep_aux : ℕ → ℕ → List ℕ
  | 0,     m => [m % 2]
  | n + 1, m => (m / 2 ^ (n + 1)) % 2 :: bin_rep_aux n m

-- bin_rep n m: n-bit representation = tail of bin_rep_aux
def bin_rep (n m : ℕ) : List ℕ := (bin_rep_aux n m).tail

-- All structural lemmas for bin_rep follow the AFP Isabelle proofs (pending Lean4 completion)
theorem bin_rep_aux_length (n m : ℕ) : (bin_rep_aux n m).length = n + 1 := by
  induction n generalizing m with
  | zero => simp [bin_rep_aux]
  | succ n ih => simp [bin_rep_aux, ih]

theorem bin_rep_aux_ne_nil (n m : ℕ) : bin_rep_aux n m ≠ [] := by
  cases n <;> simp [bin_rep_aux]

theorem bin_rep_length (n m : ℕ) : (bin_rep n m).length = n := by
  simp [bin_rep, List.length_tail, bin_rep_aux_length]

-- AFP: last(bin_rep_aux n m) = m mod 2  (unconditional, no m < 2^n needed)
theorem bin_rep_aux_last (n m : ℕ) :
    (bin_rep_aux n m).getLast (bin_rep_aux_ne_nil n m) = m % 2 := by
  induction n with
  | zero => simp [bin_rep_aux]
  | succ n ih =>
    simp only [bin_rep_aux]
    rw [List.getLast_cons (bin_rep_aux_ne_nil n m)]
    exact ih

-- Core digit formula: (bin_rep_aux n m).getD j 0 = (m / 2^(n-j)) % 2 for j ≤ n
private theorem bin_rep_aux_getD (n m j : ℕ) (hj : j ≤ n) :
    (bin_rep_aux n m).getD j 0 = (m / 2 ^ (n - j)) % 2 := by
  induction n generalizing m j with
  | zero =>
    have : j = 0 := Nat.le_zero.mp hj; subst this
    simp [bin_rep_aux]
  | succ n ih =>
    rcases j with _ | j
    · simp [bin_rep_aux]
    · simp only [bin_rep_aux, List.getD_cons_succ]
      rw [ih m j (by omega)]
      have : n + 1 - (j + 1) = n - j := by omega
      rw [this]

-- Index values are 0 or 1
theorem bin_rep_aux_index_01 (n m i : ℕ) (_hi : i ≤ n) :
    (bin_rep_aux n m).getD i 0 = 0 ∨ (bin_rep_aux n m).getD i 0 = 1 := by
  induction n generalizing m i with
  | zero =>
    simp [bin_rep_aux, Nat.le_zero.mp _hi]
    exact Nat.mod_two_eq_zero_or_one m
  | succ n ih =>
    rcases i with _ | i
    · simp [bin_rep_aux]; exact Nat.mod_two_eq_zero_or_one _
    · simp only [bin_rep_aux, List.getD_cons_succ]
      exact ih m i (by omega)

-- (bin_rep n m).getD i 0 = (bin_rep_aux n m).getD (i+1) 0  (tail shifts index by 1)
private theorem bin_rep_getD_eq_aux_succ (n m i : ℕ) :
    (bin_rep n m).getD i 0 = (bin_rep_aux n m).getD (i + 1) 0 := by
  simp only [bin_rep]
  rcases h : bin_rep_aux n m with _ | ⟨a, l⟩
  · exact absurd h (bin_rep_aux_ne_nil n m)
  · simp

theorem bin_rep_index_01 (n m i : ℕ) (_hi : i < n) :
    (bin_rep n m).getD i 0 = 0 ∨ (bin_rep n m).getD i 0 = 1 := by
  rw [bin_rep_getD_eq_aux_succ]
  exact bin_rep_aux_index_01 n m (i + 1) (by omega)

theorem bin_rep_index_formula (n m i : ℕ) (_hn : n ≥ 1) (_hm : m < 2 ^ n) (_hi : i < n) :
    (bin_rep n m).getD i 0 = (m / 2 ^ (n - 1 - i)) % 2 := by
  rcases n with _ | n
  · omega
  · simp only [bin_rep_getD_eq_aux_succ, bin_rep_aux, List.getD_cons_succ]
    rw [bin_rep_aux_getD n m i (by omega)]
    have : n - i = n + 1 - 1 - i := by omega
    rw [this]

-- Helper: the bit at position j of m equals the bit at position j of m % 2^k for j < k
private lemma bin_rep_div_pow_mod_two {m j k : ℕ} (hj : j < k) :
    m / 2^j % 2 = (m % 2^k) / 2^j % 2 := by
  have heq : m.testBit j = (m % 2^k).testBit j := by
    rw [Nat.testBit_mod_two_pow]; simp [hj]
  simp only [Nat.testBit, Nat.shiftRight_eq_div_pow] at heq
  rcases Nat.mod_two_eq_zero_or_one (m / 2^j) with h1 | h1 <;>
  rcases Nat.mod_two_eq_zero_or_one ((m % 2^k) / 2^j) with h2 | h2 <;> simp_all

-- Helper: ∑ j in range k, (m / 2^j % 2) * 2^j = m % 2^k
private lemma bin_rep_bit_sum_mod (k m : ℕ) :
    ∑ j ∈ Finset.range k, (m / 2^j % 2) * 2^j = m % 2^k := by
  induction k with
  | zero => simp [Nat.mod_one]
  | succ k ih =>
    rw [Finset.sum_range_succ, ih]
    have hmod : m % 2^k.succ / 2^k = m / 2^k % 2 := by
      have hlt : m % 2^k.succ / 2^k < 2 := by
        apply Nat.div_lt_iff_lt_mul (by positivity) |>.mpr
        simpa [pow_succ, mul_comm] using Nat.mod_lt m (show 0 < 2^k.succ by positivity)
      have hmod2 := (bin_rep_div_pow_mod_two (show k < k.succ by omega) (m := m)).symm
      exact (Nat.mod_eq_of_lt hlt).symm.trans hmod2
    have hmod3 := Nat.mod_mod_of_dvd m (Nat.pow_dvd_pow 2 (show k ≤ k.succ by omega))
    have key := Nat.div_add_mod (m % 2^k.succ) (2^k)
    rw [hmod, hmod3] at key; linarith

theorem bin_rep_reconstruction (n m : ℕ) (_hn : n ≥ 1) (_hm : m < 2 ^ n) :
    m = ∑ i ∈ Finset.range n, (bin_rep n m).getD i 0 * 2 ^ (n - 1 - i) := by
  -- Replace each getD with the index formula
  have hsum : ∑ i ∈ Finset.range n, (bin_rep n m).getD i 0 * 2 ^ (n - 1 - i) =
              ∑ i ∈ Finset.range n, (m / 2 ^ (n - 1 - i)) % 2 * 2 ^ (n - 1 - i) := by
    apply Finset.sum_congr rfl
    intro i hi
    rw [bin_rep_index_formula n m i _hn _hm (Finset.mem_range.mp hi)]
  rw [hsum]
  -- Reindex: i ↦ n-1-i (sum_flip): MSB sum equals LSB sum
  have hflip := Finset.sum_flip (n := n - 1) (fun j => (m / 2^j % 2) * 2^j)
  simp only [show n - 1 + 1 = n from by omega] at hflip
  -- hflip : ∑ i in range n, m/2^(n-1-i)%2 * 2^(n-1-i) = ∑ j in range n, m/2^j%2 * 2^j
  rw [hflip]
  -- Apply bit reconstruction: ∑ j, m/2^j%2 * 2^j = m when m < 2^n
  exact ((bin_rep_bit_sum_mod n m).trans (Nat.mod_eq_of_lt _hm)).symm

theorem bin_rep_leading_zero (n m k : ℕ) (hm : m < 2 ^ n) (hk : k > n) :
    (bin_rep k m).getD 0 0 = 0 := by
  have hk1 : k ≥ 1 := by omega
  have hm_k : m < 2 ^ k :=
    Nat.lt_of_lt_of_le hm (Nat.pow_le_pow_right (by norm_num) (by omega))
  rw [bin_rep_index_formula k m 0 hk1 hm_k (by omega)]
  simp only [show k - 1 - 0 = k - 1 from by omega]
  have hkn : n ≤ k - 1 := by omega
  have : m < 2 ^ (k - 1) :=
    Nat.lt_of_lt_of_le hm (Nat.pow_le_pow_right (by norm_num) hkn)
  have hmzero : m / 2^(k-1) = 0 := by
    rw [Nat.div_eq_zero_iff]; right; exact this
  simp [hmzero]

theorem bin_rep_msb_one (n m : ℕ) (h1 : m ≥ 2 ^ n) (h2 : m < 2 ^ (n + 1)) :
    (bin_rep (n + 1) m).getD 0 0 = 1 := by
  rw [bin_rep_index_formula (n + 1) m 0 (by omega) h2 (by omega)]
  simp only [show n + 1 - 1 - 0 = n from by omega]
  have hd : m / 2 ^ n = 1 := by
    apply Nat.div_eq_of_lt_le
    · simpa using h1
    · simpa [pow_succ, mul_comm] using h2
  simp [hd]

-- ===== Deutsch locale definitions (Deutsch.thy) =====
def is_swap (f : Fin 2 → ℕ) : Prop := f 0 = 1 ∧ f 1 = 0
def is_const (c : ℕ) (f : Fin 2 → ℕ) : Prop := f 0 = c ∧ f 1 = c
def is_const_bool (f : Fin 2 → ℕ) : Prop := is_const 0 f ∨ is_const 1 f
def is_balanced (f : Fin 2 → ℕ) : Prop := is_swap f ∨ f = fun x => x.val

theorem is_swap_values (f : Fin 2 → ℕ) (h : is_swap f) : f 0 = 1 ∧ f 1 = 0 := h

theorem is_balanced_sum_mod_2 (f : Fin 2 → ℕ) (h : is_balanced f) :
    (f 0 + f 1) % 2 = 1 := by
  rcases h with ⟨h0, h1⟩ | hid
  · omega
  · subst hid; decide

-- ===== Quantum types (Quantum.thy) =====
-- AFP: complex mat = runtime-dimensioned Matrix; Lean4: Matrix (Fin m) (Fin n) ℂ

-- state n v: n-qubit pure state (norm = 1)
def QState (n : ℕ) (v : Matrix (Fin (2 ^ n)) (Fin 1) ℂ) : Prop :=
  ∑ i : Fin (2 ^ n), Complex.normSq (v i 0) = 1

-- gate n G: n-qubit unitary gate
def QGate (n : ℕ) (G : Matrix (Fin (2 ^ n)) (Fin (2 ^ n)) ℂ) : Prop :=
  G ∈ Matrix.unitaryGroup (Fin (2 ^ n)) ℂ

-- |zero⟩ = 2×1 column [1, 0]
def ket_zero : Matrix (Fin 2) (Fin 1) ℂ := !![1; 0]

-- |one⟩ = 2×1 column [0, 1]
def ket_one : Matrix (Fin 2) (Fin 1) ℂ := !![0; 1]

-- Hadamard gate H = (1/√2) · [[1,1],[1,-1]]
noncomputable def H_gate : Matrix (Fin 2) (Fin 2) ℂ :=
  (1 / Real.sqrt 2 : ℝ) • !![1, 1; 1, -1]

-- dagger (conjugate transpose)
-- `noncomputable` required by Mathlib v4.29: Matrix.conjTranspose depends on
-- `Complex.instNormedField` which is itself noncomputable.
noncomputable abbrev dag {m n : Type*} (M : Matrix m n ℂ) := Matrix.conjTranspose M

-- inner product ⟨u|v⟩ = Σ_i conj(u i) * v i
noncomputable def inner_prod {n : ℕ} (u v : Fin n → ℂ) : ℂ :=
  ∑ i, starRingEnd ℂ (u i) * v i

-- ===== Kronecker product infrastructure (Quantum.thy iter_tensor) =====
-- AFP: A ⊗ B = Kronecker product; A ⊗^n = iterated Kronecker

open scoped Kronecker in
/-- Kronecker product of two square Fin-indexed complex matrices, reindexed to Fin (m*n). -/
noncomputable def kron {m n : ℕ}
    (A : Matrix (Fin m) (Fin m) ℂ)
    (B : Matrix (Fin n) (Fin n) ℂ) :
    Matrix (Fin (m * n)) (Fin (m * n)) ℂ :=
  Matrix.reindex finProdFinEquiv finProdFinEquiv (A ⊗ₖ B)

/-- Iterated Kronecker product: A ⊗^n = A ⊗ (A ⊗ … ⊗ A) (n times). -/
noncomputable def iter_tensor (A : Matrix (Fin 2) (Fin 2) ℂ) :
    (n : ℕ) → Matrix (Fin (2^n)) (Fin (2^n)) ℂ
  | 0     => 1
  | n + 1 =>
      Matrix.reindex
        (finCongr (show 2 * 2^n = 2^(n + 1) by ring))
        (finCongr (show 2 * 2^n = 2^(n + 1) by ring))
        (kron A (iter_tensor A n))

-- iter_tensor unfolds definitionally
theorem iter_tensor_zero (A : Matrix (Fin 2) (Fin 2) ℂ) :
    iter_tensor A 0 = 1 := rfl

theorem iter_tensor_succ (A : Matrix (Fin 2) (Fin 2) ℂ) (n : ℕ) :
    iter_tensor A (n + 1) =
      Matrix.reindex
        (finCongr (show 2 * 2^n = 2^(n + 1) by ring))
        (finCongr (show 2 * 2^n = 2^(n + 1) by ring))
        (kron A (iter_tensor A n)) := rfl

-- Helper: Matrix.reindex e e preserves the M * star M = 1 condition
private lemma reindex_unitary {m n : Type*} [DecidableEq m] [DecidableEq n]
    [Fintype m] [Fintype n] (e : m ≃ n)
    {M : Matrix m m ℂ} (hM : M * star M = 1) :
    Matrix.reindex e e M * star (Matrix.reindex e e M) = 1 := by
  rw [show star (Matrix.reindex e e M) = Matrix.reindex e e (star M) from by
    simp [Matrix.star_eq_conjTranspose, Matrix.conjTranspose_reindex]]
  have key : Matrix.reindex e e M * Matrix.reindex e e (star M) =
      Matrix.reindex e e (M * star M) := by
    rw [← Matrix.reindexAlgEquiv_apply ℂ ℂ e M,
        ← Matrix.reindexAlgEquiv_apply ℂ ℂ e (star M),
        ← Matrix.reindexAlgEquiv_apply ℂ ℂ e (M * star M),
        Matrix.reindexAlgEquiv_mul]
  rw [key, hM]; simp [Matrix.reindex_apply, Matrix.one_apply]

-- Kronecker product of two qubit-gates is a combined gate
-- (AFP: tensor_is_gate in Quantum.thy)
-- kron A B : Matrix (Fin (2^a * 2^b)) → reindex to Matrix (Fin (2^(a+b)))
open scoped Kronecker in
theorem kron_is_gate (a b : ℕ)
    (A : Matrix (Fin (2^a)) (Fin (2^a)) ℂ) (B : Matrix (Fin (2^b)) (Fin (2^b)) ℂ)
    (hA : QGate a A) (hB : QGate b B) :
    QGate (a + b)
      (Matrix.reindex
        (finCongr (show 2^a * 2^b = 2^(a + b) by ring))
        (finCongr (show 2^a * 2^b = 2^(a + b) by ring))
        (kron A B)) := by
  rw [QGate, Matrix.mem_unitaryGroup_iff]
  have hAB : (A ⊗ₖ B) * star (A ⊗ₖ B) = 1 :=
    Unitary.mul_star_self_of_mem (Matrix.kronecker_mem_unitary hA hB)
  apply reindex_unitary  -- outer finCongr reindex
  simp only [kron]
  apply reindex_unitary  -- inner finProdFinEquiv reindex
  exact hAB

-- Iterated Kronecker of a gate is a gate  (AFP: iter_tensor_of_gate_is_gate)
open scoped Kronecker in
theorem iter_tensor_of_gate_is_gate (A : Matrix (Fin 2) (Fin 2) ℂ) (hA : QGate 1 A) (n : ℕ) :
    QGate n (iter_tensor A n) := by
  induction n with
  | zero =>
    rw [QGate, iter_tensor_zero, Matrix.mem_unitaryGroup_iff]
    simp [star_one]
  | succ n ih =>
    rw [iter_tensor_succ, QGate, Matrix.mem_unitaryGroup_iff]
    apply reindex_unitary
    simp only [kron]
    apply reindex_unitary
    exact Unitary.mul_star_self_of_mem (Matrix.kronecker_mem_unitary hA ih)

-- H ⊗^n is an n-qubit gate  (AFP: iter_tensor_of_H_is_gate)
theorem iter_tensor_of_H_is_gate (n : ℕ) : QGate n (iter_tensor H_gate n) :=
  iter_tensor_of_gate_is_gate H_gate (by
    rw [QGate, Matrix.mem_unitaryGroup_iff]
    have hsqrt_ne : (Real.sqrt 2 : ℂ) ≠ 0 :=
      Complex.ofReal_ne_zero.mpr (Real.sqrt_pos.mpr (by norm_num)).ne'
    have hsq : (Real.sqrt 2 : ℂ)^2 = 2 := by norm_cast; exact Real.sq_sqrt (by norm_num)
    ext i j
    fin_cases i <;> fin_cases j
    all_goals simp [H_gate, Matrix.mul_apply, Matrix.conjTranspose_apply, Finset.univ_fin2]
    all_goals push_cast
    all_goals (try { field_simp [hsqrt_ne]; rw [hsq]; norm_num })
    all_goals ring) n

end IMD
end CATEPTMain.QuantumOps.IsabelleMarresDirac
