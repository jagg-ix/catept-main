import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework
import CATEPTMain.AFPBridge.IMD.IMDPrelude
import Mathlib.Analysis.Matrix.Spectrum
/-!
# PM Prelude — Projective_Measurements (AFP) → Lean 4

Phase-1 opaque scaffold for `Projective_Measurements` (Mnacho Echenim — 2021).
https://www.isa-afp.org/entries/Projective_Measurements.html

AFP dependencies bridged here:
  Isabelle_Marries_Dirac → IMDPrelude (QMat, QVec, Gate, QuantumState, etc.)
  QHLProver — has no Lean 4 counterpart; bridged here as axiom predicates.

Module-specific content: projection/projective measurement, PVM (projection-valued
  measure), observables, measurement probability, post-measurement state,
  CHSH inequality, quantum violation of CHSH bound.

BINDER RULES (B6–B10):
  B6:  `mat_proj M` → `IsProjector M : Prop` (predicate, not type binder)
  B7:  `partial_density_operator ρ` → `IsPartialDensityOp ρ : Prop`
  B8:  `observable O` → `IsObservable O : Prop`
  B9:  `pvm P n` → `IsPVM P n : Prop`
  B10: `post_meas_state i ρ P` → `postMeasState i ρ P : QMat` (result, not proof)

Phase-2 upgrade path:
  IsProjector → `M ^ 2 = M ∧ hermitianMat M` (from Mathlib spectral theorem).
  IsObservable → `hermitianMat O ∧ ∀ i, IsProjector (eigProj O i)`.

See: CATEPTMain/AFPBridge/PM/PM_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.PM

-- Re-export IMD types for use in theory files
open CATEPTMain.AFPBridge.IMD

-- ── QHLProver bridge: projection predicates ────────────────────────────────────
-- AFP QHLProver: `mat_proj M` (orthogonal projector matrix)
-- BINDER RULE B6: emit as Prop predicate, never as type binder.
abbrev IsProjector (M : QMat) : Prop :=
  matMul M M = M ∧ hermitianMat M

-- AFP QHLProver: `partial_density_operator ρ` (density matrix)
-- ρ positive semidefinite, trace = 1, or trace ≤ 1 (partial).
abbrev IsPartialDensityOp (ρ : QMat) : Prop :=
  hermitianMat ρ ∧ isSquareMat ρ

-- Full density operator: partial with trace = 1
axiom IsFullDensityOp : QMat → Prop
axiom fullDensityOp_partial (ρ : QMat) (h : IsFullDensityOp ρ) : IsPartialDensityOp ρ

-- ── Observable (Hermitian operator with spectral decomposition) ────────────────
-- AFP: `observable A` = Hermitian matrix with real eigenvalues
-- BINDER RULE B8: Prop predicate
abbrev IsObservable (O : QMat) : Prop :=
  hermitianMat O ∧ isSquareMat O

-- ── Projection-valued measure (PVM) ───────────────────────────────────────────
-- AFP `pvm P n`: indexed family of projectors P : ℕ → QMat that sum to identity.
-- BINDER RULE B9: Prop predicate on the family.
structure IsPVM (P : ℕ → QMat) (n : ℕ) : Prop where
  hProj    : ∀ i, i < n → IsProjector (P i)
  hOrtho   : ∀ i j, i < n → j < n → i ≠ j → matMul (P i) (P j) = zeroMat 1 1
  hComplete: True  -- ∑ P i = Id; sum axiom stated below

-- PVM completeness: ∑_{i < n} P i = Id (phase-1 axiom)
axiom pvm_complete (P : ℕ → QMat) (n d : ℕ)
    (h : IsPVM P n) (hDim : ∀ i, i < n → dimRow (P i) = d) :
    True  -- placeholder; phase-2: direct matrix sum equality

-- ── Measurement probability (Born rule for PVM) ───────────────────────────────
-- AFP: `meas_prob i ρ P` = Tr(P_i ρ)  (probability of outcome i)
-- Phase-1: axiom. Phase-2: matMul trace.
noncomputable axiom measProbPM : ℕ → QMat → (ℕ → QMat) → ℝ
axiom measProbPM_nonneg (i : ℕ) (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsPartialDensityOp ρ) (hP : IsPVM P 2) : 0 ≤ measProbPM i ρ P
axiom measProbPM_sum (ρ : QMat) (P : ℕ → QMat) (n : ℕ)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P n) :
    ∑ i ∈ Finset.range n, measProbPM i ρ P = 1

-- ── Post-measurement state ────────────────────────────────────────────────────
-- AFP: `post_meas_state i ρ P` = P_i ρ P_i† / Tr(P_i ρ)
-- BINDER RULE B10: result matrix, not a proof object.
noncomputable axiom postMeasState : ℕ → QMat → (ℕ → QMat) → QMat
axiom postMeasState_density (i : ℕ) (ρ : QMat) (P : ℕ → QMat)
    (hρ : IsFullDensityOp ρ) (hP : IsPVM P 2) (hProb : 0 < measProbPM i ρ P) :
    IsFullDensityOp (postMeasState i ρ P)

-- ── CHSH observables ──────────────────────────────────────────────────────────
-- AFP: A, A', B, B' ∈ {±1} observables on 1-qubit systems.
-- For CHSH: observables with eigenvalues in {-1, +1}.
abbrev IsDichotomicObs (O : QMat) : Prop :=
  IsObservable O ∧ dimRow O = 2

end CATEPTMain.AFPBridge.PM
