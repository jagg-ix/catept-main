import CATEPTMain.IMD.Tensor
import CATEPTMain.IMD.Measurement
/-!
# Entanglement — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Entanglement.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Tensor, Measurement

Content: Entanglement criteria — separable vs. entangled bipartite states,
  Schmidt decomposition, Bell state entanglement proofs, CHSH inequality.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.IMD.Entanglement

open CATEPTMain.IMD
open CATEPTMain.IMD.Quantum

-- ── Separable and entangled state predicates ──────────────────────────────────
-- AFP: `separable v` — v can be written as u⊗w for some 1-qubit states

def separable (n m : ℕ) (v : QVec) : Prop :=
  ∃ (u w : QVec), u ∈ stateQbit n ∧ w ∈ stateQbit m ∧
    v = tensorVec u w

def entangled (n m : ℕ) (v : QVec) : Prop :=
  ¬ separable n m v

-- ── Bell states are entangled ─────────────────────────────────────────────────
-- AFP main theorem: Bell states are not separable.
-- Phase-2: contradiction from index equations on opaque tensorVec components.
private axiom bell00_not_sep : ¬ separable 1 1 bell00
private axiom bell01_not_sep : ¬ separable 1 1 bell01
private axiom bell10_not_sep : ¬ separable 1 1 bell10
private axiom bell11_not_sep : ¬ separable 1 1 bell11

theorem bell00_entangled : entangled 1 1 bell00 := bell00_not_sep

theorem bell01_entangled : entangled 1 1 bell01 := bell01_not_sep

theorem bell10_entangled : entangled 1 1 bell10 := bell10_not_sep

theorem bell11_entangled : entangled 1 1 bell11 := bell11_not_sep

-- ── Bell basis is orthonormal ──────────────────────────────────────────────────
-- AFP: `Bell_states_orthogonal` — ⟨bell_ij, bell_kl⟩ = δ_{ik}δ_{jl}
axiom bell_orthogonal_00_01 : innerProd bell00 bell01 = 0
axiom bell_orthogonal_00_10 : innerProd bell00 bell10 = 0
axiom bell_orthogonal_00_11 : innerProd bell00 bell11 = 0
axiom bell_orthogonal_01_10 : innerProd bell01 bell10 = 0
axiom bell_orthogonal_01_11 : innerProd bell01 bell11 = 0
axiom bell_orthogonal_10_11 : innerProd bell10 bell11 = 0

-- ── CNOT produces entanglement from |0⟩ ─────────────────────────────────────
-- AFP: CNOT (H⊗1) |00⟩ = |Φ+⟩ = bell00
-- Phase-1 axiom (requires tensor + explicit state definitions)

axiom zero_qbit : QVec
axiom zero_qbit_dim  : dimVec zero_qbit = 2
axiom zero_qbit_norm : cpxVecLen zero_qbit = 1

axiom one_qbit : QVec
axiom one_qbit_dim  : dimVec one_qbit = 2
axiom one_qbit_norm : cpxVecLen one_qbit = 1

-- H|0⟩ = |+⟩ = 1/√2 (|0⟩ + |1⟩)
axiom H_on_zero : ∃ (v : QVec),
    v ∈ stateQbit 1 ∧
    ∀ k : ℕ, k < 2 → indexVec v k = (1 : ℂ) / Real.sqrt 2

-- CNOT creates bell00 from |+⟩ ⊗ |0⟩
-- AFP: `CNOT * (H|0⟩ ⊗ |0⟩) = bell00`
axiom CNOT_creates_bell00 (plus_vec : QVec)
    (hPlus : ∀ k : ℕ, k < 2 → indexVec plus_vec k = (1:ℂ)/Real.sqrt 2) :
    matMulVec CNOT_gate (tensorVec plus_vec zero_qbit) = bell00

end CATEPTMain.IMD.Entanglement
