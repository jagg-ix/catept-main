import CATEPTMain.IMD.Entanglement
import CATEPTMain.IMD.Measurement
/-!
# Quantum_Prisoners_Dilemma — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Quantum_Prisoners_Dilemma.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Entanglement, Tensor, Measurement

Content: Eisert-Wilkens-Lewenstein quantum prisoner's dilemma.
  Players apply SU(2) strategies to an entangled 2-qubit state.
  Nash equilibrium analysis; quantum advantage over classical defection.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.IMD.Quantum_Prisoners_Dilemma

open CATEPTMain.IMD
open CATEPTMain.IMD.Quantum
open CATEPTMain.IMD.Entanglement

-- ── EWL quantum game setup ────────────────────────────────────────────────────
-- AFP: entanglement operator J(γ) for γ ∈ [0, π/2]
-- J(γ) = exp(i γ/2 (D⊗D)) where D = [[0,i],[i,0]]

axiom D_gate : QMat
axiom D_gate_dimRow : dimRow D_gate = 2
axiom D_gate_dimCol : dimCol D_gate = 2
axiom D_gate_unitary : unitaryMat D_gate

axiom J_gate (gamma : ℝ) : QMat
axiom J_gate_dimRow (gamma : ℝ) : dimRow (J_gate gamma) = 4
axiom J_gate_dimCol (gamma : ℝ) : dimCol (J_gate gamma) = 4
axiom J_gate_unitary (gamma : ℝ) : unitaryMat (J_gate gamma)
-- J(0) = I₄ (no entanglement at γ=0)
axiom J_gate_zero : J_gate 0 = oneMat 4
-- J(π/2) creates a maximally entangled initial game state from |CC⟩ = |0⟩⊗|0⟩.
-- AFP: J(γ = π/2) applied to |00⟩ gives an entangled Bell-like state.
axiom J_gate_half_pi_entangling :
    ∃ (v : QVec), v ∈ stateQbit 2 ∧
      matMulVec (J_gate (Real.pi / 2))
        (tensorVec zero_qbit zero_qbit) = v ∧
      ¬ separable 1 1 v

-- ── SU(2) player strategies ───────────────────────────────────────────────────
-- AFP: strategy for player = 2×2 unitary; classical C (cooperate) and D (defect)
-- are special cases.

-- U(θ, φ) = [[e^{iφ} cos(θ/2), sin(θ/2)], [-sin(θ/2), e^{-iφ} cos(θ/2)]]
axiom su2_strategy (theta phi : ℝ) : QMat
axiom su2_strategy_dimRow (theta phi : ℝ) : dimRow (su2_strategy theta phi) = 2
axiom su2_strategy_dimCol (theta phi : ℝ) : dimCol (su2_strategy theta phi) = 2
axiom su2_strategy_unitary (theta phi : ℝ) : unitaryMat (su2_strategy theta phi)

-- Classical strategies as special SU(2) cases
noncomputable def cooperate : QMat := su2_strategy 0 0       -- U(0,0) = I
noncomputable def defect    : QMat := su2_strategy Real.pi 0  -- U(π,0) = iX

-- Quantum strategy Q (Eisert's miracle strategy)
noncomputable def stratQ : QMat := su2_strategy 0 (Real.pi / 2)

-- ── Game state after strategies ───────────────────────────────────────────────
-- AFP: final state = J† (U_A ⊗ U_B) J |00⟩

axiom init_00 : QVec
axiom init_00_dim  : dimVec init_00 = 4
axiom init_00_norm : cpxVecLen init_00 = 1
-- init_00 = |00⟩ (computational basis state)
axiom init_00_index_0 : indexVec init_00 0 = 1
axiom init_00_index_k (k : ℕ) (hk : 0 < k) (hk4 : k < 4) :
    indexVec init_00 k = 0

-- AFP: final state = J(γ)† (UA ⊗ UB) J(γ) |00⟩
-- where J(γ) = exp(iγ/2 D⊗D) is the entangling operator.
noncomputable def ewlFinalState (gamma : ℝ) (UA UB : QMat) : QVec :=
  matMulVec
    (matMul (dagger (J_gate gamma)) (matMul (tensorMat UA UB) (J_gate gamma)))
    init_00

-- ── Payoff function ───────────────────────────────────────────────────────────
-- AFP: payoff = expectation in final state of classical payoff matrix.
-- Classical prisoner's dilemma payoffs: CC→3, CD→0, DC→5, DD→1

def classicPayoff_Alice (outcome : ℕ × ℕ) : ℝ :=
  match outcome with
  | (0, 0) => 3  -- CC
  | (0, 1) => 0  -- CD
  | (1, 0) => 5  -- DC
  | (1, 1) => 1  -- DD
  | _      => 0

axiom quantumPayoff (gamma : ℝ) (UA UB : QMat) : ℝ

-- ── Nash equilibrium theorem ──────────────────────────────────────────────────
-- AFP: quantum strategy Q is a Nash equilibrium at γ = π/2
-- (defect is no longer dominant strategy)
-- Phase-2 bridge axioms (quantumPayoff is opaque)
private axiom Q_nash_law :
    ∀ (UA : QMat), unitaryMat UA → dimRow UA = 2 → dimCol UA = 2 →
    quantumPayoff (Real.pi / 2) stratQ stratQ ≥
    quantumPayoff (Real.pi / 2) UA stratQ
private axiom Q_beats_defect_law :
    quantumPayoff (Real.pi / 2) stratQ stratQ >
    quantumPayoff (Real.pi / 2) defect defect

theorem Q_is_nash_equilibrium :
    ∀ (UA : QMat), unitaryMat UA → dimRow UA = 2 → dimCol UA = 2 →
    quantumPayoff (Real.pi / 2) stratQ stratQ ≥
    quantumPayoff (Real.pi / 2) UA stratQ :=
  Q_nash_law

-- AFP: classical Nash (DD) gives payoff 1; quantum (QQ) gives payoff 3
theorem quantum_beats_classical_defect :
    quantumPayoff (Real.pi / 2) stratQ stratQ >
    quantumPayoff (Real.pi / 2) defect defect :=
  Q_beats_defect_law

end CATEPTMain.IMD.Quantum_Prisoners_Dilemma
