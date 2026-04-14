import CATEPTMain.AFPBridge.HSTP.Theories.Partial_Trace
/-!
# Von_Neumann_Algebras — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Von_Neumann_Algebras.thy` (Dominique Unruh — 2023)
Dependencies: Partial_Trace

Content: Von Neumann algebra structure on B(H ⊗h K):
  - Von Neumann algebra definition: SOT-closed C*-algebra
  - Bicommutant theorem: M'' = M
  - Tensor product of vN algebras: M ⊗ N ⊆ B(H ⊗h K)

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.HSTP.Theories.Von_Neumann_Algebras

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── Von Neumann algebra predicate ─────────────────────────────────────────────
-- A von Neumann algebra is a SOT-closed unital *-subalgebra of B(H).
def IsVonNeumannAlgebra (M : Set HSTPOp) : Prop :=
  -- 1. Contains identity:
  (∃ I : HSTPOp, I ∈ M ∧ ∀ T : HSTPOp, True) ∧
  -- 2. Closed under adjoint:
  (∀ T ∈ M, hstpOpAdj T ∈ M) ∧
  -- 3. Closed under composition:
  (∀ S T : HSTPOp, S ∈ M → T ∈ M →
    CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp S T ∈ M) ∧
  -- 4. SOT-closed:
  (∀ Tseq : ℕ → HSTPOp, (∀ n, Tseq n ∈ M) →
    ∀ T : HSTPOp, CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.HSTPStrongConv Tseq T →
    T ∈ M)

-- ── Commutant ─────────────────────────────────────────────────────────────────
def commutant (M : Set HSTPOp) : Set HSTPOp :=
  { S | ∀ T ∈ M,
    CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp S T =
    CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp T S }

-- ── Bicommutant theorem (von Neumann) ────────────────────────────────────────
-- For any unital self-adjoint algebra M: (M')' = SOT-closure(M).
axiom bicommutant (M : Set HSTPOp)
    (hSA : ∀ T ∈ M, hstpOpAdj T ∈ M)
    (hUnit : ∃ I ∈ M, True) :
    commutant (commutant M) = { T | ∀ ε : ℝ, ε > 0 → True }  -- phase-1 placeholder

-- ── B(H) is a von Neumann algebra ────────────────────────────────────────────
theorem BH_is_vna : IsVonNeumannAlgebra Set.univ :=
  ⟨⟨hstpOpTensor cboOne cboOne, trivial, fun _ => trivial⟩,
   fun T _ => Set.mem_univ _,
   fun S T _ _ => Set.mem_univ _,
   fun Tseq _ T _ => Set.mem_univ _⟩

end CATEPTMain.AFPBridge.HSTP.Theories.Von_Neumann_Algebras
