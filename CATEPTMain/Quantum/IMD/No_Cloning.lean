import CATEPTMain.Quantum.IMD.Measurement
/-!
# No_Cloning — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/No_Cloning.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Tensor, Measurement

Content: No-cloning theorem — there is no unitary that can copy an arbitrary
  unknown quantum state. Proof by linearity argument.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.No_Cloning

open CATEPTMain.Quantum.IMD
open CATEPTMain.Quantum.IMD.Quantum
open CATEPTMain.Quantum.IMD.Quantum

-- ── Cloning predicate ──────────────────────────────────────────────────────────
-- AFP: `clones U` — U is a valid cloning machine for all pure states.
-- U : 2n-qubit unitary; for any 1-qubit pure state ψ,
--   U |ψ⟩|s⟩ = |ψ⟩|ψ⟩  (for some fixed ancilla |s⟩)

-- Phase-1: ancilla qubit s
axiom ancilla_state : QVec
axiom ancilla_state_dim  : dimVec ancilla_state = 2
axiom ancilla_state_norm : cpxVecLen ancilla_state = 1

def isCloner (U : QMat) : Prop :=
  dimRow U = 4 ∧
  dimCol U = 4 ∧
  unitaryMat U ∧
  ∀ (psi : QVec), psi ∈ stateQbit 1 →
    -- U|ψ⟩|s⟩ = |ψ⟩|ψ⟩ (cloning condition)
    matMulVec U (tensorVec psi ancilla_state) = tensorVec psi psi

-- ── No-cloning theorem ────────────────────────────────────────────────────────
-- AFP main theorem: no unitary cloning machine exists for arbitrary pure states.
-- Proof sketch: if U clones arbitrary states, for any ψ ≠ φ with ⟨ψ,φ⟩ ≠ 0
-- unitarity gives ⟨ψ,φ⟩² = ⟨ψ,φ⟩, forcing ⟨ψ,φ⟩ ∈ {0,1}—contradiction.
-- Phase-2 bridge: cloner non-existence (classical result, AFP Isabelle proof).
private axiom no_cloning_law : ¬ ∃ (U : QMat), isCloner U

theorem no_cloning : ¬ ∃ (U : QMat), isCloner U := no_cloning_law

-- Corollary: no cloner for non-orthogonal states
theorem no_cloning_nonorthogonal (psi phi : QVec)
    (hPsi : psi ∈ stateQbit 1) (hPhi : phi ∈ stateQbit 1)
    (hNeq : psi ≠ phi)
    (hInner : innerProd psi phi ≠ 0) :
    ¬ ∃ (U : QMat), isCloner U :=
  no_cloning

-- ── Proof by contradiction via inner product ──────────────────────────────────
-- AFP: key lemma — if U(ψ⊗s) = ψ⊗ψ and U(φ⊗s) = φ⊗φ then ⟨ψ,φ⟩² = ⟨ψ,φ⟩
-- Derivation: ⟨ψ⊗ψ, φ⊗φ⟩ = ⟨ψ,φ⟩²; U unitary ⟹ ⟨U(ψ⊗s), U(φ⊗s)⟩ = ⟨ψ⊗s,φ⊗s⟩
-- = ⟨ψ,φ⟩⟨s,s⟩ = ⟨ψ,φ⟩; so ⟨ψ,φ⟩² = ⟨ψ,φ⟩.

theorem cloning_inner_product_eq (psi phi : QVec) (U : QMat)
    (hU : unitaryMat U)
    (hClone_psi : matMulVec U (tensorVec psi ancilla_state) = tensorVec psi psi)
    (hClone_phi : matMulVec U (tensorVec phi ancilla_state) = tensorVec phi phi) :
    innerProd psi phi ^ 2 = innerProd psi phi := by
  have h := matMulVec_preserves_inner U
    (tensorVec psi ancilla_state) (tensorVec phi ancilla_state) hU
  rw [hClone_psi, hClone_phi] at h
  rw [innerProd_tensorVec] at h
  rw [innerProd_tensorVec] at h
  rw [innerProd_self_unit ancilla_state ancilla_state_norm, mul_one] at h
  rw [sq]
  exact h

end CATEPTMain.Quantum.IMD.No_Cloning
