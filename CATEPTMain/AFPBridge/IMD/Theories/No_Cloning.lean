import CATEPTMain.AFPBridge.IMD.Theories.Measurement
/-!
# No_Cloning — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/No_Cloning.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Tensor, Measurement

Content: No-cloning theorem — there is no unitary that can copy an arbitrary
  unknown quantum state. Proof by linearity argument.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.No_Cloning

open CATEPTMain.AFPBridge.IMD
open CATEPTMain.AFPBridge.IMD.Theories.Quantum
open CATEPTMain.AFPBridge.IMD.Theories.Quantum

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

theorem no_cloning : ¬ ∃ (U : QMat), isCloner U := by
  sorry -- phase2_high: assume isCloner U; pick psi ≠ phi with ⟨ψ,φ⟩ ≠ 0;
        -- cloning + unitarity gives ⟨ψ,φ⟩² = ⟨ψ,φ⟩; forces ⟨ψ,φ⟩ ∈ {0,1}, contradiction

-- Corollary: no cloner for non-orthogonal states
theorem no_cloning_nonorthogonal (psi phi : QVec)
    (hPsi : psi ∈ stateQbit 1) (hPhi : phi ∈ stateQbit 1)
    (hNeq : psi ≠ phi)
    (hInner : innerProd psi phi ≠ 0) :
    ¬ ∃ (U : QMat), isCloner U := by
  sorry -- phase2_medium

-- ── Proof by contradiction via inner product ──────────────────────────────────
-- AFP: key lemma — if U(ψ⊗s) = ψ⊗ψ and U(φ⊗s) = φ⊗φ then ⟨ψ,φ⟩² = ⟨ψ,φ⟩
-- Derivation: ⟨ψ⊗ψ, φ⊗φ⟩ = ⟨ψ,φ⟩²; U unitary ⟹ ⟨U(ψ⊗s), U(φ⊗s)⟩ = ⟨ψ⊗s,φ⊗s⟩
-- = ⟨ψ,φ⟩⟨s,s⟩ = ⟨ψ,φ⟩; so ⟨ψ,φ⟩² = ⟨ψ,φ⟩.

theorem cloning_inner_product_eq (psi phi : QVec) (U : QMat)
    (hU : unitaryMat U)
    (hClone_psi : matMulVec U (tensorVec psi ancilla_state) = tensorVec psi psi)
    (hClone_phi : matMulVec U (tensorVec phi ancilla_state) = tensorVec phi phi) :
    innerProd psi phi ^ 2 = innerProd psi phi := by
  sorry -- phase2_high: ⟨U(ψ⊗s), U(φ⊗s)⟩ = ⟨ψ⊗s,φ⊗s⟩ by hU;
        -- = ⟨ψ,φ⟩·⟨s,s⟩ = ⟨ψ,φ⟩; LHS = ⟨ψ⊗ψ,φ⊗φ⟩ = ⟨ψ,φ⟩²

end CATEPTMain.AFPBridge.IMD.Theories.No_Cloning
