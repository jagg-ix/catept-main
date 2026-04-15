import CATEPTMain.AFPBridge.IMD.Theories.Tensor
/-!
# More_Tensor — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/More_Tensor.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Tensor

Content: Extended tensor product lemmas — iterated tensor powers,
  interaction with identity matrices, and tensor product of gate sequences.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.More_Tensor

open CATEPTMain.AFPBridge.IMD

-- ── Tensor power of a gate ─────────────────────────────────────────────────────
-- AFP: `id_gate^n ⊗ G ⊗ id_gate^m` — gate applied to qubit k in n+1+m qubit register
-- Phase-1 axioms (phase-2: unfold via tensorMat and Id_gate)

-- Tensor with identity on left: I_n ⊗ G
noncomputable def tensorWithIdLeft (n : ℕ) (G : QMat) : QMat :=
  tensorMat (Id_gate n) G

-- Tensor with identity on right: G ⊗ I_n
noncomputable def tensorWithIdRight (G : QMat) (n : ℕ) : QMat :=
  tensorMat G (Id_gate n)

theorem tensorWithIdLeft_dimRow (n : ℕ) (G : QMat) :
    dimRow (tensorWithIdLeft n G) = 2^n * dimRow G := by
  unfold tensorWithIdLeft
  rw [tensorMat_dimRow, Id_gate_dimRow]

theorem tensorWithIdRight_dimRow (G : QMat) (n : ℕ) :
    dimRow (tensorWithIdRight G n) = dimRow G * 2^n := by
  unfold tensorWithIdRight
  rw [tensorMat_dimRow, Id_gate_dimRow]

-- ── Tensor product of identity and gate action ────────────────────────────────
-- AFP: `(1_n ⊗ U)_is_gate` — applying I_n⊗U to a product state
-- Phase-1: axiom, since it requires careful index computation over tensor spaces.

axiom id_tensor_gate_action (n k : ℕ) (U G : QMat)
    (hU : dimRow U = 2^k) (hUC : dimCol U = 2^k) :
    matMul (tensorMat (Id_gate n) U) (tensorMat (Id_gate n) G) =
    tensorMat (Id_gate n) (matMul U G)

-- ── Iterated tensor dimension ──────────────────────────────────────────────────
-- n-fold tensor power of a 2×2 gate gives a 2^n × 2^n matrix

axiom tensorPow (G : QMat) (n : ℕ) : QMat
axiom tensorPow_dimRow (G : QMat) (n : ℕ) (hR : dimRow G = 2) :
    dimRow (tensorPow G n) = 2^n
axiom tensorPow_dimCol (G : QMat) (n : ℕ) (hC : dimCol G = 2) :
    dimCol (tensorPow G n) = 2^n
-- Computation rules for tensorPow (phase-2: definitional; here as axioms for phase-1)
axiom tensorPow_zero_def (G : QMat) : tensorPow G 0 = oneMat 1
axiom tensorPow_succ_def (G : QMat) (n : ℕ) : tensorPow G (n + 1) = tensorMat (tensorPow G n) G

theorem tensorPow_zero (G : QMat) : tensorPow G 0 = oneMat 1 :=
  tensorPow_zero_def G

theorem tensorPow_succ (G : QMat) (n : ℕ) :
    tensorPow G (n + 1) = tensorMat (tensorPow G n) G :=
  tensorPow_succ_def G n

-- ── Unitarity of tensor power ─────────────────────────────────────────────────
theorem tensorPow_unitary (G : QMat) (n : ℕ)
    (hU : unitaryMat G) (hR : dimRow G = 2) (hC : dimCol G = 2) :
    unitaryMat (tensorPow G n) := by
  induction n with
  | zero => rw [tensorPow_zero_def]; exact oneMat_unitary 1
  | succ n ih => rw [tensorPow_succ_def]; exact tensorMat_unitary_law _ G ih hU

end CATEPTMain.AFPBridge.IMD.Theories.More_Tensor
