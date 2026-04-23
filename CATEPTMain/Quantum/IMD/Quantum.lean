import CATEPTMain.Quantum.IMD.IMDPrelude
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Complex.Trigonometric
import Mathlib.Analysis.Complex.Norm
/-!
# Quantum — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Quantum.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Basics, Complex_Vectors, Jordan_Normal_Form, Matrix_Tensor

Content: Core quantum computing formalism — n-qubit Hilbert space, quantum
  state normalization, gate unitarity, Hadamard matrix entries, tensor product
  of quantum states, Bell basis, SWAP gate, controlled gates, Grover oracle.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Quantum

open CATEPTMain.Quantum.IMD

-- ── Hilbert space dimension ────────────────────────────────────────────────────
-- AFP: dim of n-qubit space = 2^n

theorem state_qbit_dim (n : ℕ) (v : QVec) (hv : v ∈ stateQbit n) :
    dimVec v = 2^n := by
  simp [stateQbit] at hv
  exact hv.1

-- AFP: every state in stateQbit n is normalized (‖v‖ = 1)
theorem state_qbit_norm (n : ℕ) (v : QVec) (hv : v ∈ stateQbit n) :
    cpxVecLen v = 1 := by
  simp [stateQbit] at hv
  exact hv.2

-- ── Hadamard gate index values ─────────────────────────────────────────────────
-- AFP `HValues` theorem: explicit matrix entries of H gate via 1/sqrt(2)
-- H = (1/√2) * [[1,1],[1,-1]]

axiom H_gate_index_real (i j : ℕ) (hi : i < 2) (hj : j < 2) :
    indexMat H_gate i j =
    if i = 1 ∧ j = 1 then -(1 : ℂ) / Real.sqrt 2
    else (1 : ℂ) / Real.sqrt 2

-- AFP: explicit entries for CNOT gate
-- CNOT = [[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]]
axiom CNOT_gate_00 : indexMat CNOT_gate 0 0 = 1
axiom CNOT_gate_11 : indexMat CNOT_gate 1 1 = 1
axiom CNOT_gate_23 : indexMat CNOT_gate 2 3 = 1
axiom CNOT_gate_32 : indexMat CNOT_gate 3 2 = 1
axiom CNOT_gate_zero (i j : ℕ) (hi : i < 4) (hj : j < 4)
    (hne : (i,j) ∉ ({(0,0),(1,1),(2,3),(3,2)} : Finset (ℕ × ℕ))) :
    indexMat CNOT_gate i j = 0

-- ── Tensor products of quantum states ─────────────────────────────────────────
-- AFP: ket n ⊗ ket m gives ket (n+m)
-- Phase-1: axiomatize the dimension and unitarity

axiom tensorVec (u v : QVec) : QVec
axiom tensorVec_dimVec (u v : QVec) :
    dimVec (tensorVec u v) = dimVec u * dimVec v
-- Tensor product preserves norms: ‖u⋂v‖ = ‖u‖ * ‖v‖  (Mathlib: norm_tensorProduct_le / norm_smul)
axiom tensorVec_norm_mul (u v : QVec) :
    cpxVecLen (tensorVec u v) = cpxVecLen u * cpxVecLen v
-- Tensor product inner product factorizes: ⟨u₁⋂u₂, v₁⋂v₂⟩ = ⟨u₁,v₁⟩ * ⟨u₂,v₂⟩
axiom innerProd_tensorVec (u1 u2 v1 v2 : QVec) :
    innerProd (tensorVec u1 u2) (tensorVec v1 v2) = innerProd u1 v1 * innerProd u2 v2

-- Tensor product of quantum states preserves normalization
theorem tensorVec_state (n m : ℕ) (u v : QVec)
    (hu : u ∈ stateQbit n) (hv : v ∈ stateQbit m) :
    tensorVec u v ∈ stateQbit (n + m) := by
  constructor
  · rw [tensorVec_dimVec, hu.1, hv.1, ← pow_add]
  · rw [tensorVec_norm_mul, hu.2, hv.2, mul_one]

-- ── Gate unitarity theorems ────────────────────────────────────────────────────
-- AFP: `gate_on_state` — applying unitary gate to normalized state preserves norm

theorem gate_preserves_state (n : ℕ) (G : Gate n) (v : QVec) (hv : v ∈ stateQbit n) :
    ∃ w : QVec, w ∈ stateQbit n ∧
      dimVec w = dimVec v ∧
      cpxVecLen w = cpxVecLen v := by
  refine ⟨matMulVec G.mat v, ?_, ?_, ?_⟩
  · have hDim : dimRow G.mat = dimVec v := G.hRow.trans hv.1.symm
    constructor
    · rw [matMulVec_dim, G.hRow]
    · rw [matMulVec_unitary_norm G.mat v G.hU G.hSq hDim]; exact hv.2
  · rw [matMulVec_dim, G.hRow, hv.1]
  · exact matMulVec_unitary_norm G.mat v G.hU G.hSq (G.hRow.trans hv.1.symm)

-- AFP: unitary ↔ dagger-inverse
theorem unitary_iff_dagger_inv (M : QMat) (hSq : isSquareMat M) :
    unitaryMat M ↔
    matMul (dagger M) M = oneMat (dimRow M) ∧
    matMul M (dagger M) = oneMat (dimRow M) :=
  unitaryMat_iff M

-- AFP: `unitary_fpow` — Uⁿ is unitary whenever U is
theorem unitaryMat_pow (M : QMat) (hU : unitaryMat M) (n : ℕ) :
    unitaryMat (matPow M n) :=
  matPow_unitary M hU n

-- ── Pauli gate properties ──────────────────────────────────────────────────────
-- AFP: X² = I, Y² = I, Z² = I, H² = I
theorem X_gate_involutory : matMul X_gate X_gate = oneMat 2 :=
  X_gate_involutory_law

theorem Y_gate_involutory : matMul Y_gate Y_gate = oneMat 2 :=
  Y_gate_involutory_law

theorem Z_gate_involutory : matMul Z_gate Z_gate = oneMat 2 :=
  Z_gate_involutory_law

theorem H_gate_involutory : matMul H_gate H_gate = oneMat 2 :=
  H_gate_involutory_law

-- AFP: X·Z = -iY
axiom X_times_Z : matMul X_gate Z_gate =
    smulMat (0 - Complex.I) Y_gate

-- ── Bell state dimensions and normalization ────────────────────────────────────
-- (Bell state axioms come from IMDPrelude; here we prove membership in stateQbit 2)
-- Bell states live in 4-dim space = 2^2, so they belong to stateQbit 2.

theorem bell00_state : bell00 ∈ stateQbit 2 := by
  refine ⟨?_, bell00_norm⟩
  have h : (2 : ℕ)^2 = 4 := by norm_num
  rw [h]; exact bell00_dim

theorem bell01_state : bell01 ∈ stateQbit 2 := by
  refine ⟨?_, bell01_norm⟩
  have h : (2 : ℕ)^2 = 4 := by norm_num
  rw [h]; exact bell01_dim

theorem bell10_state : bell10 ∈ stateQbit 2 := by
  refine ⟨?_, bell10_norm⟩
  have h : (2 : ℕ)^2 = 4 := by norm_num
  rw [h]; exact bell10_dim

theorem bell11_state : bell11 ∈ stateQbit 2 := by
  refine ⟨?_, bell11_norm⟩
  have h : (2 : ℕ)^2 = 4 := by norm_num
  rw [h]; exact bell11_dim

-- ── SWAP gate (useful for Quantum_Teleportation) ──────────────────────────────
-- AFP: SWAP = [[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]]
axiom SWAP_gate : QMat
axiom SWAP_gate_dimRow : dimRow SWAP_gate = 4
axiom SWAP_gate_dimCol : dimCol SWAP_gate = 4
axiom SWAP_gate_square : isSquareMat SWAP_gate
axiom SWAP_gate_unitary : unitaryMat SWAP_gate
-- SWAP² = I₄  (phase-2: matrix calculation)
axiom SWAP_gate_involutory_law : matMul SWAP_gate SWAP_gate = oneMat 4
-- SWAP² = I₄
theorem SWAP_gate_involutory : matMul SWAP_gate SWAP_gate = oneMat 4 :=
  SWAP_gate_involutory_law

-- ── Phase gate for Deutsch-Jozsa ──────────────────────────────────────────────
-- AFP: phase_factor = complex exponential e^{iθ}
noncomputable def phaseFactor (theta : ℝ) : ℂ :=
  Complex.exp (Complex.I * (theta : ℂ))

theorem phaseFactor_norm (theta : ℝ) :
    Complex.normSq (phaseFactor theta) = 1 := by
  simp [phaseFactor, Complex.normSq_eq_norm_sq, Complex.norm_exp_I_mul_ofReal]

end CATEPTMain.Quantum.IMD.Quantum
