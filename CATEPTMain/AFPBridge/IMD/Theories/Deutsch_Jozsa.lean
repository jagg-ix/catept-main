import CATEPTMain.AFPBridge.IMD.Theories.Deutsch
import CATEPTMain.AFPBridge.IMD.Theories.Binary_Nat
/-!
# Deutsch_Jozsa — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Deutsch_Jozsa.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Deutsch, Binary_Nat, More_Tensor

Content: Deutsch-Jozsa algorithm — n-qubit generalization of Deutsch.
  Determines with one query whether f : {0,1}^n → {0,1} is constant or
  balanced. Key theorem: measuring the n input qubits yields all-zeros iff
  f is constant, and at least one non-zero iff f is balanced.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.Deutsch_Jozsa

open CATEPTMain.AFPBridge.IMD

-- ── n-bit Boolean function predicates ────────────────────────────────────────
def isConstantN (n : ℕ) (f : ℕ → ℕ) : Prop :=
  (∀ x, x < 2^n → f x < 2) ∧
  (∀ x y, x < 2^n → y < 2^n → f x = f y)

def isBalancedN (n : ℕ) (f : ℕ → ℕ) : Prop :=
  (∀ x, x < 2^n → f x < 2) ∧
  (Finset.card (Finset.filter (fun x => f x = 1) (Finset.range (2^n))) = 2^(n-1)) ∧
  (Finset.card (Finset.filter (fun x => f x = 0) (Finset.range (2^n))) = 2^(n-1))

-- ── n-qubit Deutsch-Jozsa oracle ──────────────────────────────────────────────
-- AFP: U_f : (n+1)-qubit unitary oracle matrix

axiom dj_oracle (n : ℕ) (f : ℕ → ℕ) (hf : ∀ x, x < 2^n → f x < 2) : QMat
axiom dj_oracle_dimRow (n : ℕ) (f : ℕ → ℕ) (hf : ∀ x, x < 2^n → f x < 2) :
    dimRow (dj_oracle n f hf) = 2^(n+1)
axiom dj_oracle_dimCol (n : ℕ) (f : ℕ → ℕ) (hf : ∀ x, x < 2^n → f x < 2) :
    dimCol (dj_oracle n f hf) = 2^(n+1)
axiom dj_oracle_unitary (n : ℕ) (f : ℕ → ℕ) (hf : ∀ x, x < 2^n → f x < 2) :
    unitaryMat (dj_oracle n f hf)

-- ── Hadamard on n qubits ──────────────────────────────────────────────────────
-- AFP: H^⊗n := H ⊗ H ⊗ ... ⊗ H (n times)

noncomputable def H_n (n : ℕ) : QMat :=
  CATEPTMain.AFPBridge.IMD.Theories.More_Tensor.tensorPow H_gate n

theorem H_n_dimRow (n : ℕ) : dimRow (H_n n) = 2^n :=
  CATEPTMain.AFPBridge.IMD.Theories.More_Tensor.tensorPow_dimRow H_gate n H_gate_dimRow

theorem H_n_dimCol (n : ℕ) : dimCol (H_n n) = 2^n :=
  CATEPTMain.AFPBridge.IMD.Theories.More_Tensor.tensorPow_dimCol H_gate n H_gate_dimCol

-- ── Deutsch-Jozsa input state |0...0,1⟩ ─────────────────────────────────────
-- AFP: start in (n+1)-qubit |0...01⟩

axiom dj_input (n : ℕ) : QVec
axiom dj_input_dim  (n : ℕ) : dimVec (dj_input n) = 2^(n+1)
axiom dj_input_norm (n : ℕ) : cpxVecLen (dj_input n) = 1

-- ── Index formula for H^⊗n|0...0⟩ ───────────────────────────────────────────
-- AFP: H^⊗n |0...0⟩ = uniform superposition; each amplitude = 1/√(2^n)
-- zero_n_state is the n-qubit all-zero state vector |0...0⟩
axiom zero_n_state (n : ℕ) : QVec
axiom zero_n_state_dim  (n : ℕ) : dimVec (zero_n_state n) = 2^n
axiom zero_n_state_norm (n : ℕ) : cpxVecLen (zero_n_state n) = 1
axiom H_n_uniform (n : ℕ) (i : ℕ) (hi : i < 2^n) :
    indexVec (matMulVec (H_n n) (zero_n_state n)) i =
    (1 : ℂ) / Real.sqrt (2^n : ℝ)

-- ── Main Deutsch-Jozsa circuit output ─────────────────────────────────────────
-- AFP: output state after H^⊗n ; U_f ; H^⊗n (ignoring ancilla)

axiom dj_output (n : ℕ) (f : ℕ → ℕ) (hf : ∀ x, x < 2^n → f x < 2) : QVec
axiom dj_output_dim (n : ℕ) (f : ℕ → ℕ) (hf : ∀ x, x < 2^n → f x < 2) :
    dimVec (dj_output n f hf) = 2^n

-- ── Main theorem ───────────────────────────────────────────────────────────────
-- AFP: `deutsch_jozsa` — measure all zeros iff f is constant

theorem dj_constant_output_all_zeros (n : ℕ) (f : ℕ → ℕ) (hf : isConstantN n f) :
    ∀ i : ℕ, i < 2^n →
      indexVec (dj_output n f hf.1) i =
      if i = 0 then (1 : ℂ) else 0 := by
  sorry -- phase2_high: circuit simulation, binRep arithmetic

theorem dj_balanced_output_not_all_zeros (n : ℕ) (f : ℕ → ℕ)
    (hn : 0 < n) (hf : isBalancedN n f) :
    indexVec (dj_output n f hf.1) 0 = 0 := by
  sorry -- phase2_high: cancellation from balanced XOR

end CATEPTMain.AFPBridge.IMD.Theories.Deutsch_Jozsa
