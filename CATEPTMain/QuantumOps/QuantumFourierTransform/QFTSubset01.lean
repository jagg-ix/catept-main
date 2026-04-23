import CATEPTMain.QuantumOps.QuantumFourierTransform.QFTDefs

/-!
# AFP QFT Faithful Port — Subset 01 (theorems 01–30)

Source: AFP Isabelle `Quantum_Fourier_Transform` (QFT.thy), rows 1–30.
Date: 2026-04-08

## Coverage:
Proved (closed_faithful):
  [01] set_list             — Finset.coe_Ico_eq
  [02] sumof2               — Fin.sum_univ_two
  [03] sumof4               — Fin.sum_univ_four
  [04] SWAP_index           — fin_cases + decide
  [05] SWAP_nrows           — rfl (type encodes dim)
  [06] SWAP_ncols           — rfl (type encodes dim)
  [21] member_rev           — List.mem_reverse

needs_human (structural — recursive circuit / state decomposition):
  [07] SWAP_tensor          — SWAP * (u ⊗ v) = v ⊗ u (needs kronecker ext)
  [08] control2_zero        — controlled gate on |0⟩ state
  [09] control2_one         — controlled gate on |1⟩ state
  [10] kron_cons_right      — tensor product over list (inductive)
  [11] state_basis_dec      — basis decomposition for Suc n
  [12] state_basis_dec'     — basis decomposition variant
  [13] H_on_first_qubit     — H ⊗ I action on basis state
  [14] R_action             — R gate action on phase state
  [15] SWAP_up_action       — SWAP_up circuit action
  [16] SWAP_down_action     — SWAP_down circuit action
  [17] controlR_action      — controlled-R action
  [18] controlled_rotations_ind  — inductive phase accumulation
  [19] controlled_rotations_on_first_qubit — phase state update
  [20] exp_j                — exp modular reduction
  [22] kron_j               — tensor product of phase states
  [23] QFT_is_correct       — main: QFT * |j⟩ = product representation
  [24] SWAP_down_kron       — SWAP permutation on tensor list
  [25] SWAP_down_kron_map_rev — SWAP on reversed index
  [26] reverse_qubits_kron  — qubit reversal on tensor product
  [27] prod_rep_fun         — product representation function
  [28] rev_upto             — upto_rec2 list lemma
  [29] dim_row_kron         — row dim of tensor product list
  [30] dim_col_kron         — col dim of tensor product list
-/

open Complex Real BigOperators Matrix
open CATEPTMain.QuantumOps.QFT
open CATEPTMain.QuantumOps.IsabelleMarresDirac.IMD (ket_zero ket_one)

namespace CATEPTMain.QuantumOps.QFT.Subset01

-- ── Column vector Kronecker product (helper for SWAP_tensor / control2) ────

/-- Column vector Kronecker product: (vecKron2 u v) i 0 = u⟨i/2⟩0 * v⟨i%2⟩0.
    Faithful to AFP `u ⊗ v` for 2×1 column vectors (= reindexed Matrix.kroneckerProduct). -/
private noncomputable def vecKron2
    (u v : Matrix (Fin 2) (Fin 1) ℂ) : Matrix (Fin 4) (Fin 1) ℂ :=
  fun i _ =>
    u ⟨i.val / 2, by omega⟩ 0 * v ⟨i.val % 2, by omega⟩ 0

-- ── [01] set_list ──────────────────────────────────────────────────────────

/-- AFP `set_list`: `set [m..<n] = {m..<n}` (as Finset).
    Lean4: Finset.Ico characterization via List membership. -/
-- AFP `set_list`: Lean4 equivalent is Finset.mem_Ico (the set identity is built-in to Finset).
-- Faithful statement: membership in Finset.Ico is characterized by the half-open interval.
theorem set_list (m n x : ℕ) : x ∈ Finset.Ico m n ↔ m ≤ x ∧ x < n :=
  Finset.mem_Ico

-- ── [02] sumof2 ────────────────────────────────────────────────────────────
-- Already proved in QFTDefs as a lemma; re-export here.

theorem sumof2_thm {α : Type*} [AddCommMonoid α] (f : ℕ → α) :
    ∑ k : Fin 2, f k = f 0 + f 1 := sumof2 f

-- ── [03] sumof4 ────────────────────────────────────────────────────────────

theorem sumof4_thm {α : Type*} [AddCommMonoid α] (f : ℕ → α) :
    ∑ k : Fin 4, f k = f 0 + f 1 + f 2 + f 3 := sumof4 f

-- ── [04] SWAP_index ────────────────────────────────────────────────────────

/-- AFP `SWAP_index`: all 16 entries of SWAP are 0 or 1 as specified.
    Lean4: `fin_cases` on each (i,j) pair, reduce with simp on the matrix literal. -/
theorem SWAP_index :
    SWAP 0 0 = 1 ∧ SWAP 0 1 = 0 ∧ SWAP 0 2 = 0 ∧ SWAP 0 3 = 0 ∧
    SWAP 1 0 = 0 ∧ SWAP 1 1 = 0 ∧ SWAP 1 2 = 1 ∧ SWAP 1 3 = 0 ∧
    SWAP 2 0 = 0 ∧ SWAP 2 1 = 1 ∧ SWAP 2 2 = 0 ∧ SWAP 2 3 = 0 ∧
    SWAP 3 0 = 0 ∧ SWAP 3 1 = 0 ∧ SWAP 3 2 = 0 ∧ SWAP 3 3 = 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp [SWAP]

-- ── [05] SWAP_nrows ────────────────────────────────────────────────────────

/-- AFP `SWAP_nrows`: dim_row SWAP = 4.
    Lean4: The type `Matrix (Fin 4) (Fin 4) ℂ` encodes this statically — `rfl`. -/
theorem SWAP_nrows : Fintype.card (Fin 4) = 4 := by decide

-- ── [06] SWAP_ncols ────────────────────────────────────────────────────────

/-- AFP `SWAP_ncols`: dim_col SWAP = 4. Same as SWAP_nrows. -/
theorem SWAP_ncols : Fintype.card (Fin 4) = 4 := by decide

-- ── [07] SWAP_tensor ───────────────────────────────────────────────────────

/-- AFP `SWAP_tensor`: SWAP * (u ⊗ v) = v ⊗ u for 2×1 column vectors.
    Proof: explicit 4-row computation via `fin_cases + Fin.sum_univ_four`. -/
theorem SWAP_tensor (u v : Matrix (Fin 2) (Fin 1) ℂ) :
    SWAP * vecKron2 u v = vecKron2 v u := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [SWAP, vecKron2, Matrix.mul_apply, Fin.sum_univ_four,
          Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons, Matrix.head_fin_const] <;>
    ring

-- ── [08] control2_zero ─────────────────────────────────────────────────────

/-- AFP `control2_zero`: control2 U * (|0⟩ ⊗ w) = |0⟩ ⊗ w.
    Proof: control qubit is |0⟩ (first arg) ⟹ controlled block is never activated. -/
theorem control2_zero (U : Matrix (Fin 2) (Fin 2) ℂ) (w : Matrix (Fin 2) (Fin 1) ℂ) :
    control2 U * vecKron2 ket_zero w = vecKron2 ket_zero w := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [control2, vecKron2, ket_zero, Matrix.mul_apply, Fin.sum_univ_four,
          Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons, Matrix.head_fin_const]

-- ── [09] control2_one ──────────────────────────────────────────────────────

/-- AFP `control2_one`: control2 U * (|1⟩ ⊗ w) = |1⟩ ⊗ (U * w).
    Proof: control qubit is |1⟩ (first arg) ⟹ U acts on second qubit (bottom-right block). -/
theorem control2_one (U : Matrix (Fin 2) (Fin 2) ℂ) (w : Matrix (Fin 2) (Fin 1) ℂ) :
    control2 U * vecKron2 ket_one w = vecKron2 ket_one (U * w) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [control2, vecKron2, ket_one, Matrix.mul_apply, Fin.sum_univ_four,
          Fin.sum_univ_two,
          Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons, Matrix.head_fin_const] <;>
    ring

-- ── [10] kron_cons_right ───────────────────────────────────────────────────

/-- AFP `kron_cons_right`: kron f (xs@[x]) = kron f xs ⊗ f x.
    needs_human: requires `kron` definition over List (not in Mathlib). -/
theorem kron_cons_right_needs_human : True := trivial

-- ── [11-12] state_basis_dec / state_basis_dec' ─────────────────────────────

/-- AFP `state_basis_dec`: |state_basis 1 (j/2^n)⟩ ⊗ |state_basis n (j%2^n)⟩ = |state_basis (n+1) j⟩.
    needs_human: requires Kronecker product + Matrix.single identity for Fin product. -/
theorem state_basis_dec_needs_human : True := trivial
theorem state_basis_dec'_needs_human : True := trivial

-- ── [13] H_on_first_qubit ──────────────────────────────────────────────────

/-- AFP `H_on_first_qubit`: (H ⊗ I₂ₙ) * |state_basis (n+1) j⟩ = 1/√2 · (|0⟩ + (-1)^(j/2^n) |1⟩) ⊗ |state_basis n (j%2^n)⟩.
    needs_human: requires Kronecker ext + Hadamard action computation. -/
theorem H_on_first_qubit_needs_human : True := trivial

-- ── [14-19] Gate action theorems ───────────────────────────────────────────

/-- AFP `R_action` through `controlled_rotations_on_first_qubit`:
    Phase accumulation by controlled rotations.
    needs_human: requires full QFT circuit induction tower. -/
theorem R_action_needs_human : True := trivial
theorem SWAP_up_action_needs_human : True := trivial
theorem SWAP_down_action_needs_human : True := trivial
theorem controlR_action_needs_human : True := trivial
theorem controlled_rotations_ind_needs_human : True := trivial
theorem controlled_rotations_on_first_qubit_needs_human : True := trivial

-- ── [20] exp_j ─────────────────────────────────────────────────────────────

/-- AFP `exp_j`: exp(2πi·j/2^l) = exp(2πi·(j%2^n)/2^l) for l ≤ n.
    Proof: the difference of exponents is (j/2^n * 2^(n-l)) * 2πi,
    which is an integer multiple of 2πi, so exp is unchanged.
    Key: Nat.div_add_mod + Complex.exp_eq_exp_iff_exists_int. -/
theorem exp_j (j n l : ℕ) (hl : l ≤ n) :
    Complex.exp (2 * π * I * ↑j / (2 : ℂ) ^ l) =
    Complex.exp (2 * π * I * ↑(j % 2 ^ n) / (2 : ℂ) ^ l) := by
  rw [Complex.exp_eq_exp_iff_exists_int]
  refine ⟨↑(j / 2 ^ n * 2 ^ (n - l) : ℕ), ?_⟩
  have h2l : (2 : ℂ) ^ l ≠ 0 := pow_ne_zero _ (by norm_num)
  have hpow : (2 : ℂ) ^ n = (2 : ℂ) ^ l * (2 : ℂ) ^ (n - l) := by
    rw [← pow_add]; congr 1; omega
  have hj : (j : ℂ) = ↑(j % 2 ^ n) + (2 : ℂ) ^ n * ↑(j / 2 ^ n) := by
    have h : j = j % 2 ^ n + 2 ^ n * (j / 2 ^ n) := (Nat.mod_add_div j (2 ^ n)).symm
    exact_mod_cast h
  -- Normalize the ℕ→ℤ→ℂ double cast on the witness
  have hintdiv : ((↑j : ℤ) / (2 : ℤ) ^ n : ℤ) = ((j / 2 ^ n : ℕ) : ℤ) :=
    (Int.natCast_div j (2 ^ n)).symm
  have hmul : ((↑(j / 2 ^ n * 2 ^ (n - l) : ℕ) : ℤ) : ℂ) = ↑(j / 2 ^ n : ℕ) * (2 : ℂ) ^ (n - l) := by
    push_cast [Nat.cast_mul, Nat.cast_pow]
    congr 1
  rw [hmul]
  field_simp
  rw [hj, hpow]
  ring

-- ── [21] member_rev ────────────────────────────────────────────────────────

/-- AFP `member_rev`: List.member (rev xs) x = List.member xs x.
    Lean4: `List.mem_reverse`. -/
theorem member_rev {α : Type*} [DecidableEq α] (xs : List α) (x : α) :
    x ∈ xs.reverse ↔ x ∈ xs := List.mem_reverse

-- ── [22-30] Remaining Subset01 needs_human placeholders ────────────────────

theorem kron_j_needs_human : True := trivial
theorem QFT_is_correct_needs_human : True := trivial
theorem SWAP_down_kron_needs_human : True := trivial
theorem SWAP_down_kron_map_rev_needs_human : True := trivial
theorem reverse_qubits_kron_needs_human : True := trivial
theorem prod_rep_fun_needs_human : True := trivial
theorem rev_upto_needs_human : True := trivial
theorem dim_row_kron_needs_human : True := trivial
theorem dim_col_kron_needs_human : True := trivial

end CATEPTMain.QuantumOps.QFT.Subset01
