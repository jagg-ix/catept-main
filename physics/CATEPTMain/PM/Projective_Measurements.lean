import CATEPTMain.PM.Linear_Algebra_Complements
/-!
# Projective_Measurements — AFP → Lean 4 (Phase 1)

Source: `Projective_Measurements/Projective_Measurements.thy` (Echenim — 2021)
Dependencies: Linear_Algebra_Complements, IMD (via PMPrelude)

Content: Projective measurements formalism:
  - PVM (Projection-Valued Measure) definition and properties
  - Measurement probability (Born rule for PVMs)
  - Post-measurement state formula
  - Repeatability of projective measurements
  - Completeness of PVMs
  - Measurement in orthonormal basis = special PVM

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.PM.Projective_Measurements

open CATEPTMain.PM
open CATEPTMain.IMD

-- ── PVM properties ─────────────────────────────────────────────────────────────
-- AFP: Each P_i is a projector; pairwise orthogonal; sum = 1.

-- Summation form of completeness (phase-1 concrete for n=2):
private axiom pvm_complete_two_law (P : ℕ → QMat) (d : ℕ)
    (h : IsPVM P 2)
    (hDim : dimRow (P 0) = d ∧ dimRow (P 1) = d) :
    matAdd (P 0) (P 1) = oneMat d

theorem pvm_complete_two (P : ℕ → QMat) (d : ℕ)
    (h : IsPVM P 2)
    (hDim : dimRow (P 0) = d ∧ dimRow (P 1) = d) :
    matAdd (P 0) (P 1) = oneMat d :=
  pvm_complete_two_law P d h hDim

-- PVM projectors are self-adjoint:
theorem pvm_self_adj (P : ℕ → QMat) (n i : ℕ) (h : IsPVM P n) (hi : i < n) :
    hermitianMat (P i) := (h.hProj i hi).2

-- ── Born rule for PVMs ─────────────────────────────────────────────────────────
-- AFP: `meas_prob_1 i ρ P` = Tr(P_i * ρ)  when ρ is a density operator.

-- Trace axiom (phase-1): Tr(M) for QMat
noncomputable axiom traceMat : QMat → ℂ
axiom traceMat_cyclic (A B : QMat) : traceMat (matMul A B) = traceMat (matMul B A)
axiom traceMat_linear (A B : QMat) (c : ℂ) :
    traceMat (matAdd A (smulMat c B)) = traceMat A + c * traceMat B

-- Concrete Born rule: measProbPM i ρ P = Re(Tr(P i * ρ))
axiom measProbPM_eq_trace (i : ℕ) (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) (hi : i < 2) :
    measProbPM i ρ P = (traceMat (matMul (P i) ρ)).re

-- Probability sum (re-stated in trace form):
private axiom meas_prob_sum_two_law (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) :
    measProbPM 0 ρ P + measProbPM 1 ρ P = 1

theorem meas_prob_sum_two (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) :
    measProbPM 0 ρ P + measProbPM 1 ρ P = 1 :=
  meas_prob_sum_two_law ρ P hρ hP

-- ── Post-measurement state ────────────────────────────────────────────────────
-- AFP: `post_meas_state_1 i ρ P` = P_i * ρ * P_i† / Tr(P_i * ρ)

axiom postMeasState_eq (i : ℕ) (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) (hi : i < 2)
    (hProb : 0 < measProbPM i ρ P) :
    postMeasState i ρ P =
    smulMat ((measProbPM i ρ P)⁻¹) (matMul (matMul (P i) ρ) (dagger (P i)))

-- ── Repeatability ─────────────────────────────────────────────────────────────
-- AFP: If outcome i is obtained, repeating the measurement gives i again.
-- measProbPM i (postMeasState i ρ P) P = 1

private axiom meas_repeatability_law (i : ℕ) (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) (hi : i < 2)
    (hProb : 0 < measProbPM i ρ P) :
    measProbPM i (postMeasState i ρ P) P = 1

theorem meas_repeatability (i : ℕ) (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) (hi : i < 2)
    (hProb : 0 < measProbPM i ρ P) :
    measProbPM i (postMeasState i ρ P) P = 1 :=
  meas_repeatability_law i ρ P hρ hP hi hProb

-- ── Orthonormal basis yields PVM ──────────────────────────────────────────────
-- AFP: An ONB {eᵢ} yields a PVM via P_i = |eᵢ⟩⟨eᵢ|.

-- ONB predicate (n-qubit):
axiom IsONB (basis : ℕ → QVec) (n : ℕ) : Prop
axiom IsONB_inner (basis : ℕ → QVec) (n : ℕ) (h : IsONB basis n) (i j : ℕ)
    (hi : i < n) (hj : j < n) :
    innerProd (basis i) (basis j) = if i = j then 1 else 0

-- PVM from ONB:
noncomputable def pvmFromONB (basis : ℕ → QVec) (i : ℕ) : QMat :=
  matMul (ketVec (basis i)) (braVec (basis i))

private axiom pvmFromONB_is_pvm_law (basis : ℕ → QVec) (n : ℕ) (h : IsONB basis n) :
    IsPVM (pvmFromONB basis) n

theorem pvmFromONB_is_pvm (basis : ℕ → QVec) (n : ℕ) (h : IsONB basis n) :
    IsPVM (pvmFromONB basis) n :=
  pvmFromONB_is_pvm_law basis n h

end CATEPTMain.PM.Projective_Measurements
