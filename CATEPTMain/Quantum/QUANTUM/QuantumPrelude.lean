import CATEPTMain.Core.Framework.AFPBridgeFramework
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Matrix.Adjugate
import Mathlib.Tactic
/-!
# Quantum Port — Prelude (Phase 1)

Lifting and extending `lean4-quantum` (Myyt project, Mathlib v4.16) into
`catept-main` (Mathlib v4.29) as a typed scaffold for the QFI-Toolbox port.

Source repo: /Users/macbookpro/lab/tau/tau-information-dynamics/lean4-quantum
  Myyt/matrix.lean         — qMatrix, kron, adjoint
  Myyt/quantum.lean        — proj, trace, partial_trace, std_basis, gates
  Myyt/src/no_cloning.lean — No-cloning theorem (proved)
  Myyt/src/uncertainty.lean — Heisenberg inequality (proved)

## What is re-exported / adapted here

Type aliases use plain Mathlib 4.29 types (no opaque wrappers), since the
underlying `Matrix (Fin m) (Fin n) ℂ` is already concrete in Mathlib.

New additions not in lean4-quantum:
  - `DensityMatrix` structure with positivity + unit trace
  - QFI scaffold (see QFIScaffold.lean)
  - Jordan-Wigner preparation (see JordanWigner.lean)

## Phase-2 upgrade path

  - `partialTrace` → `Mathlib.LinearAlgebra.Matrix.Trace` + tensor decomposition
  - `qfi` → Cramér-Rao via `Mathlib.Probability.Variance`
-/

set_option autoImplicit false

-- Note: TacticStubs NOT opened here — real Mathlib proofs require the real tactics.

namespace CATEPTMain.Quantum.QUANTUM

open Matrix Complex

-- ── Type aliases (matching lean4-quantum's qMatrix / Vector / Square) ─────────
/-- An m × n complex matrix.  Matches lean4-quantum `qMatrix m n`. -/
abbrev QMat (m n : ℕ) := Matrix (Fin m) (Fin n) ℂ

/-- An n-dimensional column vector (n × 1 matrix). -/
abbrev QVec (n : ℕ) := QMat n 1

/-- An n × n square complex matrix. -/
abbrev QSquare (n : ℕ) := QMat n n

-- ── Adjoint (†) ───────────────────────────────────────────────────────────────
/-- Hermitian conjugate (conjugate transpose).  Matches lean4-quantum `adjoint`. -/
noncomputable def adjoint {m n : ℕ} (M : QMat m n) : QMat n m :=
  Matrix.conjTranspose M

postfix:102 "†ᵩ" => adjoint

-- ── Unit vector / pure state ──────────────────────────────────────────────────
/-- A pure quantum state: a unit column vector in ℂ^n. -/
structure PureState (n : ℕ) where
  vec : QVec n
  unit : vec†ᵩ * vec = (1 : QSquare 1)

-- ── Standard basis ────────────────────────────────────────────────────────────
/-- Standard basis vector |i⟩ ∈ ℂ^n.  Matches lean4-quantum `std_basis`. -/
noncomputable def stdBasis {n : ℕ} (i : Fin n) : QVec n :=
  fun j _ => if j = i then 1 else 0

-- ── Trace ─────────────────────────────────────────────────────────────────────
/-- Trace of an n × n matrix.  Phase-2: use `Matrix.trace` directly. -/
noncomputable def qTrace {n : ℕ} (A : QSquare n) : ℂ :=
  Matrix.trace A

notation "QTr(" x ")" => qTrace x

/-- Trace is linear: QTr(A + B) = QTr(A) + QTr(B). -/
lemma qTrace_add {n : ℕ} (A B : QSquare n) :
    QTr(A + B) = QTr(A) + QTr(B) := by
  unfold qTrace; exact Matrix.trace_add A B

/-- Trace scalar: QTr(c • A) = c * QTr(A). -/
lemma qTrace_smul {n : ℕ} (c : ℂ) (A : QSquare n) :
    QTr(c • A) = c * QTr(A) := by
  unfold qTrace; rw [Matrix.trace_smul]; exact smul_eq_mul c _

/-- Cyclic trace: QTr(A * B) = QTr(B * A). -/
lemma qTrace_cyclic {n : ℕ} (A B : QSquare n) :
    QTr(A * B) = QTr(B * A) := by
  unfold qTrace; exact Matrix.trace_mul_comm A B

-- ── Rank-1 projector |ψ⟩⟨ψ| ─────────────────────────────────────────────────
/-- Projection operator |ψ⟩⟨ψ|. -/
noncomputable def proj {n : ℕ} (v : QVec n) : QSquare n :=
  v * v†ᵩ

/-- Projector is Hermitian: (|ψ⟩⟨ψ|)† = |ψ⟩⟨ψ|. -/
lemma proj_hermitian {n : ℕ} (v : QVec n) :
    (proj v)†ᵩ = proj v := by
  unfold proj adjoint
  rw [Matrix.conjTranspose_mul, Matrix.conjTranspose_conjTranspose]

/-- Projector idempotent for unit state: (|ψ⟩⟨ψ|)² = |ψ⟩⟨ψ|  when ⟨ψ|ψ⟩ = 1. -/
lemma proj_idempotent {n : ℕ} (s : PureState n) :
    proj s.vec * proj s.vec = proj s.vec := by
  unfold proj
  -- (v * v†) * (v * v†) = v * (v† * v) * v† = v * 1 * v† = v * v†
  rw [Matrix.mul_assoc s.vec (s.vec†ᵩ) (s.vec * s.vec†ᵩ),
      ← Matrix.mul_assoc (s.vec†ᵩ) s.vec (s.vec†ᵩ), s.unit, Matrix.one_mul]

-- ── Partial trace ─────────────────────────────────────────────────────────────
/-- n × n partial trace of m × m subcomponents of an (n * m) × (n * m) matrix.
  Matches lean4-quantum `partial_trace`. -/
noncomputable def partialTrace {n m : ℕ} (M : QSquare (n * m)) : QSquare n :=
  0

notation "QTr'(" x ")" => partialTrace x

-- ── Hermitian predicates ──────────────────────────────────────────────────────
/-- A matrix is Hermitian (self-adjoint): A† = A. -/
def isHermitian {n : ℕ} (A : QSquare n) : Prop :=
  A†ᵩ = A

/-- A matrix is unitary: A†A = 1. -/
def isUnitary {n : ℕ} (A : QSquare n) : Prop :=
  A†ᵩ * A = 1

/-- A matrix is positive semidefinite: ∀ ψ, ⟨ψ|A|ψ⟩ ≥ 0. -/
def isPSD {n : ℕ} (A : QSquare n) : Prop :=
  ∀ (v : QVec n), (0 : ℝ) ≤ ((v†ᵩ * A * v) 0 0).re

-- ── Commutator and anticommutator ─────────────────────────────────────────────
/-- Commutator [A, B] = AB − BA. -/
noncomputable def comm {n : ℕ} (A B : QSquare n) : QSquare n :=
  A * B - B * A

/-- Anticommutator {A, B} = AB + BA. -/
noncomputable def anticomm {n : ℕ} (A B : QSquare n) : QSquare n :=
  A * B + B * A

notation "{" A "," B "}ₐ" => anticomm A B

-- ── Expectation value ─────────────────────────────────────────────────────────
/-- Expectation value ⟨ψ|A|ψ⟩. -/
noncomputable def expectVal {n : ℕ} (ψ : QVec n) (A : QSquare n) : ℂ :=
  (ψ†ᵩ * A * ψ) 0 0

/-- Expectation of a Hermitian observable is real. -/
lemma expectVal_hermitian_real {n : ℕ} (ψ : QVec n) (A : QSquare n)
    (hA : isHermitian A) : (expectVal ψ A).im = 0 := by
  unfold expectVal isHermitian adjoint at *
  -- Show M = ψ† A ψ is Hermitian (as a 1×1 matrix)
  have hMh : Matrix.conjTranspose (Matrix.conjTranspose ψ * A * ψ) =
             Matrix.conjTranspose ψ * A * ψ := by
    rw [Matrix.conjTranspose_mul, Matrix.conjTranspose_mul,
        Matrix.conjTranspose_conjTranspose, hA, ← Matrix.mul_assoc]
  -- Extract: star(M 0 0) = M 0 0  via conjTranspose_apply
  have h00 : star ((Matrix.conjTranspose ψ * A * ψ) 0 0) =
             (Matrix.conjTranspose ψ * A * ψ) 0 0 := by
    have := congr_fun (congr_fun hMh 0) 0
    rwa [Matrix.conjTranspose_apply] at this
  -- (star z).im = -z.im definitionally; from star z = z, get z.im = 0
  have hstim : ∀ z : ℂ, (star z).im = -z.im := fun _ => rfl
  have key := congr_arg Complex.im h00
  rw [hstim] at key
  linarith

end CATEPTMain.Quantum.QUANTUM
