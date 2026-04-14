import CATEPTMain.AFPBridge.IMD.Theories.Quantum
/-!
# Measurement — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Measurement.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Quantum, Complex_Vectors

Content: Quantum measurement formalism — projective measurement, Born rule,
  post-measurement state, orthonormal bases, completeness, probability
  interpretation.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.Measurement

open CATEPTMain.AFPBridge.IMD

-- ── Born rule / measurement probability ───────────────────────────────────────
-- AFP: `prob v P` = ⟨v|P|v⟩ = scalar_prod (P *ᵥ v, v) where P is a projector.
-- Phase-1: Born rule as re⟨v, Pv⟩; phase-2: Matrix.mulVec makes this computable.

noncomputable def measProb (v : QVec) (P : QMat) : ℝ :=
  (innerProd v (matMulVec P v)).re

-- True Born rule (phase-1 axiom):
axiom bornRule (v : QVec) (P : QMat) : ℝ
axiom bornRule_nonneg (v : QVec) (P : QMat)
    (hP : unitaryMat P) (hNorm : cpxVecLen v = 1) :
    0 ≤ bornRule v P

axiom bornRule_le_one (v : QVec) (P : QMat)
    (hP : unitaryMat P) (hNorm : cpxVecLen v = 1) :
    bornRule v P ≤ 1

-- ── Orthonormal basis ─────────────────────────────────────────────────────────
-- AFP: `onb n B` — B is an orthonormal basis of the n-qubit Hilbert space.
-- dim = 2^n, B has 2^n orthonormal vectors.

def isONBasis (n : ℕ) (B : Fin (2^n) → QVec) : Prop :=
  (∀ i, dimVec (B i) = 2^n) ∧
  (∀ i, cpxVecLen (B i) = 1) ∧
  (∀ i j, i ≠ j → innerProd (B i) (B j) = 0)

-- AFP: standard computational basis is ONB
axiom compBasis (n : ℕ) : Fin (2^n) → QVec
axiom compBasis_isONB (n : ℕ) : isONBasis n (compBasis n)

-- AFP: Parseval identity for ONBs
theorem parseval (n : ℕ) (B : Fin (2^n) → QVec) (hB : isONBasis n B)
    (v : QVec) (hv : v ∈ stateQbit n) :
    cpxVecLen v ^ 2 =
    Finset.sum Finset.univ (fun i => Complex.normSq (innerProd (B i) v)) := by
  sorry -- phase2_high: Parseval via ONB

-- AFP: completeness — sum of |b⟩⟨b| = I
-- Phase-1: stated as "expansion coefficients determine the vector" (avoids QMat summation).
-- Equivalent to: if ⟨b_i, v⟩ = ⟨b_i, w⟩ for all i, then v = w.
axiom onb_completeness (n : ℕ) (B : Fin (2^n) → QVec) (hB : isONBasis n B) :
    ∀ (v w : QVec), v ∈ stateQbit n → w ∈ stateQbit n →
    (∀ i : Fin (2^n), innerProd (B i) v = innerProd (B i) w) → v = w

-- ── Post-measurement state ────────────────────────────────────────────────────
-- AFP: after measuring and obtaining outcome i, post-measurement state ∝ P_i|v⟩
-- Phase-1: axiom for renormalization.

axiom postMeasState (v : QVec) (P : QMat)
    (hv : v ∈ stateQbit 1) (hProb : 0 < bornRule v P) : QVec
axiom postMeasState_norm (v : QVec) (P : QMat)
    (hv : v ∈ stateQbit 1) (hProb : 0 < bornRule v P) :
    cpxVecLen (postMeasState v P hv hProb) = 1

end CATEPTMain.AFPBridge.IMD.Theories.Measurement
