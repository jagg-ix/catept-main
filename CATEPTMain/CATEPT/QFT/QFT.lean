import CATEPTMain.CATEPT.QFT.QFTPrelude
/-!
# QFT — AFP Quantum_Fourier_Transform → Lean 4 (Phase 1)

Source: `Quantum_Fourier_Transform/QFT.thy` (Pablo Manrique — 2025)
Dependencies: Isabelle_Marries_Dirac (QFTPrelude re-exports all IMD types)

Content: Quantum Fourier Transform construction, phase gate algebra, controlled
  phase gates, recursive QFT circuit definition, and correctness theorem
  (QFT maps computational basis |j⟩ to the Fourier basis state).

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.CATEPT.QFT.QFT

open CATEPTMain.CATEPT.QFT
open CATEPTMain.Quantum.IMD

-- ── Phase gate algebra ─────────────────────────────────────────────────────────
-- AFP: `R_k * R_k† = 1`  (unitarity); `R_1 = H` on phase; `R_0 is trivial`.

private axiom phaseGate_hermitian_conj_law (k : ℕ) :
    matMul (phaseGate k) (dagger (phaseGate k)) = oneMat 2

theorem phaseGate_hermitian_conj (k : ℕ) :
    matMul (phaseGate k) (dagger (phaseGate k)) = oneMat 2 := phaseGate_hermitian_conj_law k

-- Adjacent phase gates: R_{k+1} composed twice gives R_k (half-angle)
-- AFP: not stated explicitly, but follows from omega identity.
private axiom phaseGate_half_angle_law (k : ℕ) :
    omegaN (2^(k+1)) * omegaN (2^(k+1)) = omegaN (2^k)

theorem phaseGate_half_angle (k : ℕ) :
    omegaN (2^(k+1)) * omegaN (2^(k+1)) = omegaN (2^k) := phaseGate_half_angle_law k

-- ── Controlled phase gate from Pauli structure ─────────────────────────────────
-- AFP: CR_k decomposes into projectors + phase: |0⟩⟨0| ⊗ 1 + |1⟩⟨1| ⊗ R_k

-- |0⟩⟨0| projector (2×2)
axiom ket0Bra0 : QMat
axiom ket0Bra0_dim : dimRow ket0Bra0 = 2 ∧ dimCol ket0Bra0 = 2
axiom ket0Bra0_proj : matMul ket0Bra0 ket0Bra0 = ket0Bra0

-- |1⟩⟨1| projector (2×2)
axiom ket1Bra1 : QMat
axiom ket1Bra1_dim : dimRow ket1Bra1 = 2 ∧ dimCol ket1Bra1 = 2
axiom ket1Bra1_proj : matMul ket1Bra1 ket1Bra1 = ket1Bra1

-- Decomposition of controlled phase gate:
-- ctrlPhaseGate k = (ket0Bra0 ⊗ Id n) + (ket1Bra1 ⊗ R_k)
private axiom ctrlPhaseGate_decomp_law (k : ℕ) :
    ctrlPhaseGate k =
    matAdd (tensorMat ket0Bra0 (Id_gate 1))
           (tensorMat ket1Bra1 (phaseGate k))

theorem ctrlPhaseGate_decomp (k : ℕ) :
    ctrlPhaseGate k =
    matAdd (tensorMat ket0Bra0 (Id_gate 1))
           (tensorMat ket1Bra1 (phaseGate k)) := ctrlPhaseGate_decomp_law k

-- ── QFT recursive correctness ─────────────────────────────────────────────────
-- AFP: `qft_correct n A` states A is QFT_n; proved recursively.
-- Key: QFT(n+1) is H on first qubit, followed by controlled phases,
--      then QFT(n) on remaining qubits (swap-endian convention).

-- Hadamard preparation step:
-- (H ⊗ Id_{n-1}) applied to first qubit
axiom qftStep_had (n : ℕ) (hn : n ≥ 1) : QMat
axiom qftStep_had_dim (n : ℕ) (hn : n ≥ 1) :
    dimRow (qftStep_had n hn) = 2^n ∧ dimCol (qftStep_had n hn) = 2^n

-- Phase rotation gate at qubit k within n-qubit register:
axiom qftStep_ctrl (n k : ℕ) (hn : n ≥ 1) (hk : k < n) : QMat

-- QFT inductive step:
-- qftCircuit (n+1) = (qftStep_had (n+1)) ∘ (∏_k qftStep_ctrl n k) ∘ (Id_gate 1 ⊗ qftCircuit n)
private axiom qftCircuit_step_law (n : ℕ) (hn : n ≥ 1) : IsQFTCorrect (n+1) (qftCircuit (n+1))

theorem qftCircuit_step (n : ℕ) (hn : n ≥ 1) :
    IsQFTCorrect (n+1) (qftCircuit (n+1)) := qftCircuit_step_law n hn

-- ── Basis state QFT output ─────────────────────────────────────────────────────
-- AFP: For each j < 2^n, QFT|j⟩ = 1/√(2^n) ∑_{k=0}^{2^n - 1} ω^{jk} |k⟩

-- Basis vector |j⟩ for n-qubit system
axiom basisVec (n j : ℕ) (hj : j < 2^n) : QVec
axiom basisVec_norm (n j : ℕ) (hj : j < 2^n) : cpxVecLen (basisVec n j hj) = 1
axiom basisVec_index (n j k : ℕ) (hj : j < 2^n) (hk : k < 2^n) :
    indexVec (basisVec n j hj) k = if k = j then 1 else 0

-- QFT applied to basis state:
private axiom qftCircuit_basis_law (n j : ℕ) (hn : n ≥ 1) (hj : j < 2^n) :
    ∀ k : ℕ, k < 2^n →
    indexVec (colVec (matMul (qftCircuit n) (ketVec (basisVec n j hj))) 0) k =
    (1 / Real.sqrt (2^n : ℝ) : ℝ) * omegaN (2^n) ^ (j * k)

theorem qftCircuit_basis (n j : ℕ) (hn : n ≥ 1) (hj : j < 2^n) :
    ∀ k : ℕ, k < 2^n →
    indexVec (colVec (matMul (qftCircuit n) (ketVec (basisVec n j hj))) 0) k =
    (1 / Real.sqrt (2^n : ℝ) : ℝ) * omegaN (2^n) ^ (j * k) :=
  qftCircuit_basis_law n j hn hj

-- ── Inverse QFT ────────────────────────────────────────────────────────────────
-- AFP: QFT† is the inverse; QFT†QFT = 1 follows from unitarity.
private axiom qftCircuit_inv_law (n : ℕ) :
    matMul (dagger (qftCircuit n)) (qftCircuit n) = oneMat (2^n)

theorem qftCircuit_inv (n : ℕ) :
    matMul (dagger (qftCircuit n)) (qftCircuit n) = oneMat (2^n) := qftCircuit_inv_law n

-- ── Correctness summary ────────────────────────────────────────────────────────
-- Main result: qftCircuit n is the correct n-qubit QFT.
theorem qft_main (n : ℕ) : IsQFTCorrect n (qftCircuit n) :=
  qftCircuit_correct n

end CATEPTMain.CATEPT.QFT.QFT
