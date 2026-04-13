import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Algebra.BigOperators.Finprod
import NavierStokesClean.AFPBridge.QuantumGravity.QPICoreBridge

/-!
# Finite-Dimensional Partial Trace — AFP HST Faithful Bridge

Source: AFP `Hilbert_Space_Tensor_Product / Partial_Trace`
Date: 2026-04-08
Method: finite-dimensional faithful specialisation for 2-qubit (4×4 ℂ) density matrices.

## Context
AFP `Partial_Trace` works in infinite-dimensional Hilbert spaces via trace-class operators
(`sandwich_tc`, `tensor_ell2_right`). For the QPICoreBridge obligations
(`rhoBellPartialTrace`, `gravityMatterEntanglementLayer`), we need a *finite-dimensional*
concrete implementation: density matrices are `Matrix (Fin 4) (Fin 4) ℂ`.

## Basis convention
Two-qubit computational basis: |ij⟩ ↔ Fin 4 index `2·i + j`.
  - |00⟩ = 0, |01⟩ = 1, |10⟩ = 2, |11⟩ = 3.

## Partial trace definitions
- **partialTraceLeft**  (trace out RIGHT qubit, keep LEFT):
    `(ptL ρ) i j = ρ[2i, 2j] + ρ[2i+1, 2j+1]`
- **partialTraceRight** (trace out LEFT qubit, keep RIGHT):
    `(ptR ρ) i j = ρ[i, j] + ρ[i+2, j+2]`

Both preserve `Matrix.trace`: `tr(ptL ρ) = tr(ptR ρ) = tr(ρ)`.

## AFP coverage
- `partial_trace_def'` (§353): specialised to finite-dimensional sum ∑_{k<2}
- `partial_trace_plus` (§356): linearity — proved
- `partial_trace_scaleC` (§357): scalar multiplication — proved
- `partial_trace_tensor` (§358): product-state factorisation — needs_human
  (requires Kronecker product computation)
- trace-preservation: proved directly by `Fin.sum_univ_two + Fin.sum_univ_four`
-/

open Complex Real BigOperators Matrix

open NavierStokesClean.AFPBridge.QuantumGravity.QPICore

namespace NavierStokesClean.AFPBridge.QuantumOps.PartialTrace

-- ── Type aliases (mirrors QPICoreBridge) ──────────────────────────────────────

/-- Two-qubit density matrix space: 4×4 ℂ matrices. -/
abbrev TwoDM : Type := Matrix (Fin 4) (Fin 4) ℂ

/-- One-qubit reduced density matrix: 2×2 ℂ matrices. -/
abbrev OneDM : Type := Matrix (Fin 2) (Fin 2) ℂ

-- ── Helper: Fin 4 index arithmetic ────────────────────────────────────────────

private lemma two_mul_lt_four (i : Fin 2) : 2 * i.val < 4 := by omega
private lemma two_mul_succ_lt_four (i : Fin 2) : 2 * i.val + 1 < 4 := by omega
private lemma val_lt_four_of_lt_two (i : Fin 2) : i.val < 4 := by omega
private lemma val_add_two_lt_four (i : Fin 2) : i.val + 2 < 4 := by omega

-- ── [AFP partial_trace_def' specialised] ──────────────────────────────────────

/-- LEFT partial trace: trace out RIGHT qubit, keep LEFT qubit.
    AFP `Partial_Trace.partial_trace` specialised: ∑_{k<2} ρ[2i+k, 2j+k].
    Faithful: explicit finite sum over k : Fin 2. -/
noncomputable def partialTraceLeft (ρ : TwoDM) : OneDM :=
  fun i j =>
    ρ ⟨2 * i.val,     two_mul_lt_four i⟩     ⟨2 * j.val,     two_mul_lt_four j⟩ +
    ρ ⟨2 * i.val + 1, two_mul_succ_lt_four i⟩ ⟨2 * j.val + 1, two_mul_succ_lt_four j⟩

/-- RIGHT partial trace: trace out LEFT qubit, keep RIGHT qubit.
    AFP `partial_trace` on the tensor-flipped space: ∑_{k<2} ρ[2k+i, 2k+j]. -/
noncomputable def partialTraceRight (ρ : TwoDM) : OneDM :=
  fun i j =>
    ρ ⟨i.val,     val_lt_four_of_lt_two i⟩ ⟨j.val,     val_lt_four_of_lt_two j⟩ +
    ρ ⟨i.val + 2, val_add_two_lt_four i⟩   ⟨j.val + 2, val_add_two_lt_four j⟩

-- ── Entry lemmas (unfold for proof use) ───────────────────────────────────────

@[simp] lemma partialTraceLeft_apply (ρ : TwoDM) (i j : Fin 2) :
    partialTraceLeft ρ i j =
      ρ ⟨2 * i.val, two_mul_lt_four i⟩ ⟨2 * j.val, two_mul_lt_four j⟩ +
      ρ ⟨2 * i.val + 1, two_mul_succ_lt_four i⟩ ⟨2 * j.val + 1, two_mul_succ_lt_four j⟩ := rfl

@[simp] lemma partialTraceRight_apply (ρ : TwoDM) (i j : Fin 2) :
    partialTraceRight ρ i j =
      ρ ⟨i.val, val_lt_four_of_lt_two i⟩ ⟨j.val, val_lt_four_of_lt_two j⟩ +
      ρ ⟨i.val + 2, val_add_two_lt_four i⟩ ⟨j.val + 2, val_add_two_lt_four j⟩ := rfl

-- ── [AFP partial_trace_plus] Linearity ────────────────────────────────────────

/-- AFP `partial_trace_plus`: ptL is additive. -/
theorem partialTraceLeft_add (ρ σ : TwoDM) :
    partialTraceLeft (ρ + σ) = partialTraceLeft ρ + partialTraceLeft σ := by
  ext i j; simp [partialTraceLeft_apply, Matrix.add_apply]; ring

/-- AFP `partial_trace_plus` (right variant): ptR is additive. -/
theorem partialTraceRight_add (ρ σ : TwoDM) :
    partialTraceRight (ρ + σ) = partialTraceRight ρ + partialTraceRight σ := by
  ext i j; simp [partialTraceRight_apply, Matrix.add_apply]; ring

-- ── [AFP partial_trace_scaleC] Scalar multiplication ─────────────────────────

/-- AFP `partial_trace_scaleC`: ptL is ℂ-linear. -/
theorem partialTraceLeft_smul (c : ℂ) (ρ : TwoDM) :
    partialTraceLeft (c • ρ) = c • partialTraceLeft ρ := by
  ext i j; simp [partialTraceLeft_apply, Matrix.smul_apply]; ring

/-- AFP `partial_trace_scaleC` (right variant): ptR is ℂ-linear. -/
theorem partialTraceRight_smul (c : ℂ) (ρ : TwoDM) :
    partialTraceRight (c • ρ) = c • partialTraceRight ρ := by
  ext i j; simp [partialTraceRight_apply, Matrix.smul_apply]; ring

-- ── Trace preservation (key obligation) ───────────────────────────────────────

/-- Core trace identity for ptL: `tr(ptL ρ) = tr(ρ)`.
    Proof: expand both traces via Fin.sum_univ_two and Fin.sum_univ_four,
    match the 4 diagonal entries. -/
theorem partialTraceLeft_trace (ρ : TwoDM) :
    Matrix.trace (partialTraceLeft ρ) = Matrix.trace ρ := by
  simp only [Matrix.trace, Matrix.diag_apply]
  rw [Fin.sum_univ_two]
  simp only [partialTraceLeft_apply]
  -- LHS = (ρ[0,0] + ρ[1,1]) + (ρ[2,2] + ρ[3,3])
  -- RHS = ρ[0,0] + ρ[1,1] + ρ[2,2] + ρ[3,3]   (Fin.sum_univ_four)
  rw [Fin.sum_univ_four]
  simp only [Fin.val_zero, Fin.val_one]
  push_cast
  ring

/-- Core trace identity for ptR: `tr(ptR ρ) = tr(ρ)`. -/
theorem partialTraceRight_trace (ρ : TwoDM) :
    Matrix.trace (partialTraceRight ρ) = Matrix.trace ρ := by
  simp only [Matrix.trace, Matrix.diag_apply]
  rw [Fin.sum_univ_two]
  simp only [partialTraceRight_apply]
  rw [Fin.sum_univ_four]
  simp only [Fin.val_zero, Fin.val_one]
  push_cast
  ring

-- ── Concrete PartialTrace2x2API instance ──────────────────────────────────────

/-- Concrete implementation of QPICoreBridge.PartialTrace2x2API.
    This closes the `rhoBellPartialTrace` and `gravityMatterEntanglementLayer` obligations. -/
noncomputable def finDimPartialTrace2x2API : PartialTrace2x2API where
  partialTraceLeft  := partialTraceLeft
  partialTraceRight := partialTraceRight
  trace_preserving_left  := partialTraceLeft_trace
  trace_preserving_right := partialTraceRight_trace

-- ── Obligation closure theorems ───────────────────────────────────────────────

/-- The `rhoBellPartialTrace` obligation is now satisfiable: a concrete partial-trace
    API exists and preserves unit trace. -/
theorem rhoBellPartialTrace_obligation_satisfied :
    ∃ (pt : PartialTrace2x2API),
      ∀ (ρ : TwoQubitDensity) (_ : Matrix.trace ρ = 1),
        Matrix.trace (pt.partialTraceLeft ρ) = 1 ∧
          Matrix.trace (pt.partialTraceRight ρ) = 1 := by
  exact ⟨finDimPartialTrace2x2API, fun ρ hρ =>
    partialTrace_unitTrace_of_unitTrace finDimPartialTrace2x2API ρ hρ⟩

/-- The `gravityMatterEntanglementLayer` obligation is now satisfiable: a concrete
    GravityMatterEntanglementLayer can be constructed from any 4×4 density matrix
    with unit trace, and the reduced sectors automatically have unit trace. -/
theorem gravityMatterEntanglement_obligation_satisfied
    (ρ : TwoQubitDensity) (hρ : Matrix.trace ρ = 1) :
    ∃ (L : GravityMatterEntanglementLayer),
      Matrix.trace L.reducedGravity = 1 ∧ Matrix.trace L.reducedMatter = 1 := by
  refine ⟨⟨ρ, finDimPartialTrace2x2API,
             finDimPartialTrace2x2API.partialTraceRight ρ,
             finDimPartialTrace2x2API.partialTraceLeft ρ,
             rfl, rfl⟩, ?_⟩
  exact gravityMatterEntanglementLayer_unitTrace _ hρ

-- ── [AFP partial_trace_tensor] Product state factorisation ────────────────────

/-- Explicit Kronecker product on 4×4 / 2×2 Fin-indexed space.
    `kron4 A B i j = A[i/2, j/2] * B[i%2, j%2]` (row-major ordering). -/
noncomputable def kron4 (A B : OneDM) : TwoDM :=
  fun i j =>
    A ⟨i.val / 2, by omega⟩ ⟨j.val / 2, by omega⟩ *
    B ⟨i.val % 2, by omega⟩ ⟨j.val % 2, by omega⟩

/-- AFP `partial_trace_tensor`: ptL (A ⊗ B) = tr(B) · A.
    Proof: entry-wise; for each `i j : Fin 2`,
      ptL(kron4 A B) i j
        = kron4 A B ⟨2i, _⟩ ⟨2j, _⟩ + kron4 A B ⟨2i+1, _⟩ ⟨2j+1, _⟩
        = A[i,j]*B[0,0] + A[i,j]*B[1,1]
        = A[i,j] * tr(B).
    Verified by `fin_cases`. -/
theorem partialTraceLeft_tensor (A B : OneDM) :
    partialTraceLeft (kron4 A B) = Matrix.trace B • A := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [partialTraceLeft_apply, kron4, Matrix.smul_apply,
          Matrix.trace, Matrix.diag_apply, Fin.sum_univ_two] <;>
    ring

/-- AFP `partial_trace_tensor` (right side): ptR (A ⊗ B) = tr(A) · B.
    Proof: for each `i j : Fin 2`,
      ptR(kron4 A B) i j
        = kron4 A B ⟨i, _⟩ ⟨j, _⟩ + kron4 A B ⟨i+2, _⟩ ⟨j+2, _⟩
        = A[0,0]*B[i,j] + A[1,1]*B[i,j]
        = tr(A) * B[i,j].
    Verified by `fin_cases`. -/
theorem partialTraceRight_tensor (A B : OneDM) :
    partialTraceRight (kron4 A B) = Matrix.trace A • B := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [partialTraceRight_apply, kron4, Matrix.smul_apply,
          Matrix.trace, Matrix.diag_apply, Fin.sum_univ_two] <;>
    ring

-- ── Summary ───────────────────────────────────────────────────────────────────

def finDimPartialTraceSummary : String :=
  "FinDimPartialTrace (AFP HST Partial_Trace faithful finite-dim port): " ++
  "partialTraceLeft + partialTraceRight for 4×4 ℂ density matrices. " ++
  "Proved: partial_trace_plus (2), partial_trace_scaleC (2), " ++
  "trace preservation (2), PartialTrace2x2API instance, " ++
  "rhoBellPartialTrace obligation closed, gravityMatterEntanglement obligation closed. " ++
  "All needs_human closed: partial_trace_tensor proved via fin_cases + ring."

end NavierStokesClean.AFPBridge.QuantumOps.PartialTrace
