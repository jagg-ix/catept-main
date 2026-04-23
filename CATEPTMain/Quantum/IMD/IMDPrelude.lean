import CATEPTMain.Core.Framework.AFPBridgeFramework
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.SpecialFunctions.Sqrt
/-!
# IMD Prelude — Isabelle Marries Dirac (AFP) → Lean 4

Phase-1 opaque scaffold for `Isabelle_Marries_Dirac` (Bordg, Lachnitt, He — 2020).
https://www.isa-afp.org/entries/Isabelle_Marries_Dirac.html

AFP dependencies bridged here:
  Jordan_Normal_Form  → AFPMat / AFPVec (from AFPBridgeFramework)
  Matrix_Tensor       → tensorMat axiom
  VectorSpace         → innerProd / cpxVecLen axioms

Module-specific content: Gate/QuantumState structures, Bell states,
  concrete gate axioms (X, Y, Z, H, CNOT, S, T), binary representation,
  cpx_sqr_mat typedef bridge.

Phase-2 upgrade path:
  Replace `QMat`/`QVec` aliases with `Matrix (Fin n) (Fin m) ℂ`.
  Replace axioms with `Matrix.conjTranspose`, `Matrix.kronecker`, etc.
  All theory files import this prelude unchanged — only the prelude changes.

See: integration/afp_type_map.yaml  (authoritative type correspondence table)
See: CATEPTMain/AFPBridge/IMD/IMD_WORKLOG.lean  (translation plan and records)
-/

set_option autoImplicit false

open CATEPTMain.Core.Framework.TacticStubs  -- phase-1 tactic stubs

namespace CATEPTMain.Quantum.IMD

-- ── Type aliases (IMD-local names over generic framework types) ────────────────
-- Using framework's AFPMat/AFPVec as the phase-1 carrier.
-- Phase-2: replace with Matrix (Fin m) (Fin n) ℂ  and  Matrix (Fin n) (Fin 1) ℂ.
noncomputable abbrev QMat := CATEPTMain.Core.Framework.AFPMat
noncomputable abbrev QVec := CATEPTMain.Core.Framework.AFPVec

-- ── Dimension accessors (from JNF Library / AFPBridgeFramework) ───────────────
noncomputable abbrev dimRow  := CATEPTMain.Core.Framework.afpDimRow
noncomputable abbrev dimCol  := CATEPTMain.Core.Framework.afpDimCol
noncomputable abbrev dimVec  := CATEPTMain.Core.Framework.afpDimVec

-- ── Matrix index operations ────────────────────────────────────────────────────
-- AFP `M $$ (i, j)` → `indexMat M i j`
noncomputable abbrev indexMat := CATEPTMain.Core.Framework.afpIndexMat
-- AFP `v $ i`       → `indexVec v i`
noncomputable abbrev indexVec := CATEPTMain.Core.Framework.afpIndexVec

-- ── Matrix arithmetic ──────────────────────────────────────────────────────────
noncomputable abbrev matMul    := CATEPTMain.Core.Framework.afpMatMul
noncomputable abbrev matAdd    := CATEPTMain.Core.Framework.afpMatAdd
-- Phase-2 matrix multiply index rule (Mathlib: Matrix.mul_apply)
-- indexMat (A * B) i j = ∑ k < dimCol A, A[i,k] * B[k,j]
axiom indexMat_matMul (A B : QMat) (i j : ℕ) :
    indexMat (matMul A B) i j =
    Finset.sum (Finset.range (dimCol A)) (fun k => indexMat A i k * indexMat B k j)
noncomputable abbrev smulMat   := CATEPTMain.Core.Framework.afpSmulMat
noncomputable abbrev oneMat    := CATEPTMain.Core.Framework.afpOneMat
noncomputable abbrev zeroMat   := CATEPTMain.Core.Framework.afpZeroMat
noncomputable abbrev transposeMat := CATEPTMain.Core.Framework.afpTranspose
noncomputable abbrev colVec    := CATEPTMain.Core.Framework.afpColVec
noncomputable abbrev rowMat    := CATEPTMain.Core.Framework.afpRowMat

-- ── Hermitian conjugate (dagger) ──────────────────────────────────────────────
-- AFP `dagger M` = `M†` ≡ conjTranspose M
-- Phase-2: replace with `Matrix.conjTranspose M` (notation Mᴴ in Mathlib)
-- NEVER redefine as opaque if QMat is already opaque — use this explicit alias.
noncomputable abbrev dagger := CATEPTMain.Core.Framework.afpDagger

-- ── Vector arithmetic ──────────────────────────────────────────────────────────
noncomputable abbrev vecAdd    := CATEPTMain.Core.Framework.afpVecAdd
noncomputable abbrev smulVec   := CATEPTMain.Core.Framework.afpSmulVec
noncomputable abbrev scalarProd := CATEPTMain.Core.Framework.afpScalar
noncomputable abbrev innerProd := CATEPTMain.Core.Framework.afpInner      -- sesquilinear ⟨u|v⟩
noncomputable abbrev cpxVecLen := CATEPTMain.Core.Framework.afpVecNorm    -- ‖v‖

-- Phase-2 inner product axioms (Mathlib: InnerProductSpace laws for opaque AFPVec)
axiom innerProd_self_unit (v : QVec) (h : cpxVecLen v = 1) : innerProd v v = 1
-- ‖v‖² = ⟨v,v⟩.re  (Mathlib: inner_self_eq_norm_sq)
axiom innerProd_self_re (v : QVec) : (innerProd v v).re = cpxVecLen v ^ 2
-- ⟨u,v⟩ = conj ⟨v,u⟩  (Mathlib: inner_conj_symm)
axiom innerProd_conj_symm (u v : QVec) : innerProd u v = starRingEnd ℂ (innerProd v u)
-- ⟨u, c·v⟩ = c * ⟨u,v⟩  (Mathlib: inner_smul_right)
axiom innerProd_smul_right (u v : QVec) (c : ℂ) : innerProd u (smulVec c v) = c * innerProd u v
-- ⟨u, v+w⟩ = ⟨u,v⟩ + ⟨u,w⟩  (Mathlib: inner_add_right)
axiom innerProd_add_right (u v w : QVec) : innerProd u (vecAdd v w) = innerProd u v + innerProd u w
-- ⟨c·u, v⟩ = conj(c) * ⟨u,v⟩  (Mathlib: inner_smul_left)
axiom innerProd_smul_left (u v : QVec) (c : ℂ) : innerProd (smulVec c u) v = starRingEnd ℂ c * innerProd u v
-- ‖v‖ ≥ 0  (Mathlib: norm_nonneg)
axiom cpxVecLen_nonneg (v : QVec) : 0 ≤ cpxVecLen v
-- Cauchy-Schwarz: √|⟨u,v⟩|² ≤ ‖u‖ * ‖v‖  (Mathlib: abs_inner_le_norm)
axiom cauchy_schwarz_ineq (u v : QVec) :
    Real.sqrt (Complex.normSq (innerProd u v)) ≤ cpxVecLen u * cpxVecLen v
-- ⟨u,v⟩ = ∑ k < n, conj(u[k]) * v[k]  (Mathlib: inner_apply for pi-type)
axiom innerProd_coord_sum (u v : QVec) :
    innerProd u v =
    Finset.sum (Finset.range (dimVec u)) (fun k => starRingEnd ℂ (indexVec u k) * indexVec v k)
-- ‖c·v‖ = √|c|² * ‖v‖  (Mathlib: norm_smul → Real.sqrt ∘ normSq form)
axiom cpxVecLen_smul_eq (c : ℂ) (v : QVec) :
    cpxVecLen (smulVec c v) = Real.sqrt (Complex.normSq c) * cpxVecLen v

-- ── Ket / bra ─────────────────────────────────────────────────────────────────
-- AFP `ket_vec |v⟩`  = column matrix formed from a vector
-- AFP `bra ⟨v|`      = row matrix = dagger of ket
noncomputable abbrev ketVec := CATEPTMain.Core.Framework.afpKetVec    -- QVec → QMat
noncomputable abbrev braVec := CATEPTMain.Core.Framework.afpBraVec    -- QVec → QMat

-- ── Predicates ────────────────────────────────────────────────────────────────
abbrev unitaryMat   := CATEPTMain.Core.Framework.afpUnitary   -- M† * M = 1 ∧ M * M† = 1
abbrev hermitianMat := CATEPTMain.Core.Framework.afpHermitian -- M = M†
abbrev isSquareMat  := CATEPTMain.Core.Framework.afpIsSquare  -- dimRow = dimCol

-- ── cpx_sqr_mat typedef bridge ────────────────────────────────────────────────
-- AFP: `typedef cpx_sqr_mat = {M. square_mat M}`
--   creates Rep_cpx_sqr_mat / Abs_cpx_sqr_mat + coercion cpx_sqr_mat_to_cpx_mat.
-- Phase-1: opaque wrapper; sqrMatToMat is the explicit projection (not a CoeFun).
-- CRITICAL: do NOT add a Coe instance from CpxSqrMat to QMat —
--   that is the IMD-PRE-004-RULE-B3 CoeFun trap (TRL-002 analog).
-- Phase-2: replace with `{ M : Matrix (Fin n) (Fin n) ℂ // True }`.
opaque CpxSqrMat : Type := Unit
axiom sqrMatToMat  : CpxSqrMat → QMat
axiom sqrMatFromMat : (M : QMat) → isSquareMat M → CpxSqrMat  -- Abs morphism

-- ── Matrix-vector product ─────────────────────────────────────────────────────
-- AFP: `M *\<^sub>v v` (matrix acting on a column vector).
-- Phase-2: Matrix.mulVec
-- BINDER RULE: never replace with function application; M acts on v, not "M v".
axiom matMulVec : QMat → QVec → QVec
axiom matMulVec_dim (M : QMat) (v : QVec) :
    dimVec (matMulVec M v) = dimRow M
-- Linearity axiom (unitary matrix preserves norm):
axiom matMulVec_unitary_norm (M : QMat) (v : QVec)
    (hU : unitaryMat M) (hSq : isSquareMat M)
    (hDim : dimRow M = dimVec v) :
    cpxVecLen (matMulVec M v) = cpxVecLen v
-- Unitary matrices preserve inner products: ⟨Mu, Mv⟩ = ⟨u,v⟩  (Mathlib: LinearIsometry.inner_map_map)
axiom matMulVec_preserves_inner (M : QMat) (u v : QVec)
    (hU : unitaryMat M) :
    innerProd (matMulVec M u) (matMulVec M v) = innerProd u v

-- ── Matrix power ──────────────────────────────────────────────────────────────
-- AFP: `M^n` for repeated matrix multiplication.
-- Phase-2: use Monoid.npow / HSMul instance.
noncomputable axiom matPow : QMat → ℕ → QMat
axiom matPow_zero (M : QMat) : matPow M 0 = oneMat (dimRow M)
axiom matPow_succ (M : QMat) (n : ℕ) :
    matPow M (n + 1) = matMul M (matPow M n)
axiom matPow_dimRow (M : QMat) (n : ℕ) : dimRow (matPow M n) = dimRow M
axiom matPow_unitary (M : QMat) (hU : unitaryMat M) (n : ℕ) :
    unitaryMat (matPow M n)
-- Characterization: U unitary ↔ U†U = I ∧ UU† = I  (Mathlib: Matrix.mem_unitaryGroup_iff)
axiom unitaryMat_iff (M : QMat) :
    unitaryMat M ↔
    matMul (dagger M) M = oneMat (dimRow M) ∧
    matMul M (dagger M) = oneMat (dimRow M)

-- ── Tensor product (Kronecker) ────────────────────────────────────────────────
-- AFP `M ⊗ N` = Kronecker product
-- Phase-2: Matrix.kronecker M N  (with Fin reindexing via finProdFinEquiv)
-- NOTE: ⊗ notation NOT declared here — conflicts with Mathlib TensorProduct.
-- Use tensorMat prefix form throughout all theory files.
axiom tensorMat : QMat → QMat → QMat
-- Key dimension axiom for tensorMat (needed by gate composition theorems):
axiom tensorMat_dimRow (A B : QMat) : dimRow (tensorMat A B) = dimRow A * dimRow B
axiom tensorMat_dimCol (A B : QMat) : dimCol (tensorMat A B) = dimCol A * dimCol B
-- Tensor product algebra laws (phase-2: Matrix.kronecker*)
axiom tensorMat_assoc_law (A B C : QMat) :
    tensorMat (tensorMat A B) C = tensorMat A (tensorMat B C)
axiom tensorMat_distrib_right_law (A B C : QMat) :
    tensorMat A (matAdd B C) = matAdd (tensorMat A B) (tensorMat A C)
axiom tensorMat_distrib_left_law (A B C : QMat) :
    tensorMat (matAdd A B) C = matAdd (tensorMat A C) (tensorMat B C)
axiom tensorMat_smul_left_law (c : ℂ) (A B : QMat) :
    tensorMat (smulMat c A) B = smulMat c (tensorMat A B)
axiom tensorMat_mixed_product_law (A B C D : QMat) :
    matMul (tensorMat A B) (tensorMat C D) = tensorMat (matMul A C) (matMul B D)
axiom tensorMat_dagger_law (A B : QMat) :
    dagger (tensorMat A B) = tensorMat (dagger A) (dagger B)
axiom tensorMat_unitary_law (A B : QMat) (hA : unitaryMat A) (hB : unitaryMat B) :
    unitaryMat (tensorMat A B)
axiom tensorMat_index_law (A B : QMat) (i j : ℕ) :
    indexMat (tensorMat A B) i j =
    indexMat A (i / dimRow B) (j / dimCol B) *
    indexMat B (i % dimRow B) (j % dimCol B)

-- ── Typeclass instances for QMat ──────────────────────────────────────────────
-- Required so that AFP expressions `A * B`, `A + B`, `1`, `0` compile.
axiom instHMulQMat   : HMul QMat QMat QMat
axiom instHAddQMat   : HAdd QMat QMat QMat
axiom instSubQMat    : Sub QMat
axiom instNegQMat    : Neg QMat
axiom instOfNat0QMat : OfNat QMat 0
axiom instOfNat1QMat : OfNat QMat 1
axiom instLEQMat     : LE QMat     -- used in some norm comparisons
attribute [instance]
  instHMulQMat instHAddQMat instSubQMat instNegQMat
  instOfNat0QMat instOfNat1QMat instLEQMat

-- Typeclass instances for QVec
axiom instHAddQVec   : HAdd QVec QVec QVec
axiom instSubQVec    : Sub QVec
axiom instNegQVec    : Neg QVec
axiom instOfNat0QVec : OfNat QVec 0
attribute [instance]
  instHAddQVec instSubQVec instNegQVec instOfNat0QVec
-- ‖v‖ = 0 ↔ v = 0  (Mathlib: norm_eq_zero; uses instOfNat0QVec)
axiom cpxVecLen_eq_zero_iff (v : QVec) : cpxVecLen v = 0 ↔ v = (0 : QVec)

-- Coercion QMat scalar → ℂ (for AFP expressions that use a 1×1 matrix as a scalar)
axiom matToScalar : QMat → ℂ

-- Real-to-complex matrix embedding
-- AFP `real_to_cpx_mat M`
-- Phase-2: Matrix.map M (algebraMap ℝ ℂ)
axiom realToCpxMat : QMat → QMat

-- ── Binary representation (Binary_Nat) ───────────────────────────────────────
-- AFP `bin_rep n i` = n-bit binary representation of natural number i
-- Returns a List ℕ where each element is 0 or 1.
-- Phase-2: List.ofFn (fun k : Fin n => if Nat.testBit i k.val then 1 else 0)
noncomputable def binRep (n i : ℕ) : List ℕ :=
  (List.range n).map (fun k => if Nat.testBit i k then 1 else 0)

-- ── Locale: gate (structure form) ────────────────────────────────────────────
-- AFP `locale gate = fixes n :: nat and A :: complex mat
--        assumes dim_row A = 2^n ∧ square_mat A ∧ unitary A`
-- Lean 4: structure with all locale assumptions as named fields.
-- Locale injection: every `(in gate)` theorem prepends
--   (n : ℕ) (A : QMat) (hRow : dimRow A = 2^n) (hSq : isSquareMat A) (hU : unitaryMat A)
-- LocaleHyps pattern documented in AFPBridgeFramework.lean.
structure Gate (n : ℕ) : Type where
  mat  : QMat
  hRow : dimRow mat = 2^n
  hSq  : isSquareMat mat
  hU   : unitaryMat mat

-- ── Locale: state (structure form) ───────────────────────────────────────────
-- AFP `locale state = fixes n :: nat and v :: complex vec
--        assumes dim_row v = 2^n ∧ dim_col v = 1 ∧ ‖col v 0‖ = 1`
-- Note: AFP uses v as a column matrix (complex mat dim_row 2^n × 1).
-- Here we represent it as QVec for the phase-1 typed-dim-free scaffold.
structure QuantumState (n : ℕ) : Type where
  vec   : QVec
  hDim  : dimVec vec = 2^n
  hNorm : cpxVecLen vec = 1

-- ── state_qbit set (AFP abbreviation) ────────────────────────────────────────
-- AFP `state_qbit n = {v | dim_vec v = 2^n ∧ cpx_vec_length v = 1}`
def stateQbit (n : ℕ) : Set QVec :=
  { v | dimVec v = 2^n ∧ cpxVecLen v = 1 }

-- ── Concrete gate axioms ──────────────────────────────────────────────────────
-- Phase-1: opaque gate matrix values.
-- Phase-2: replace with Matrix literal definitions, e.g.
--   def pauliX : Matrix (Fin 2) (Fin 2) ℂ := ![![0,1],![1,0]]

-- Pauli-X gate (bit flip): [[0,1],[1,0]]
axiom X_gate : QMat
axiom X_gate_dimRow  : dimRow X_gate = 2
axiom X_gate_dimCol  : dimCol X_gate = 2
axiom X_gate_square  : isSquareMat X_gate
axiom X_gate_unitary : unitaryMat X_gate

-- Pauli-Y gate: [[0,-i],[i,0]]
axiom Y_gate : QMat
axiom Y_gate_dimRow  : dimRow Y_gate = 2
axiom Y_gate_dimCol  : dimCol Y_gate = 2
axiom Y_gate_square  : isSquareMat Y_gate
axiom Y_gate_unitary : unitaryMat Y_gate

-- Pauli-Z gate (phase flip): [[1,0],[0,-1]]
axiom Z_gate : QMat
axiom Z_gate_dimRow  : dimRow Z_gate = 2
axiom Z_gate_dimCol  : dimCol Z_gate = 2
axiom Z_gate_square  : isSquareMat Z_gate
axiom Z_gate_unitary : unitaryMat Z_gate

-- Hadamard gate: 1/√2 * [[1,1],[1,-1]]
axiom H_gate : QMat
axiom H_gate_dimRow  : dimRow H_gate = 2
axiom H_gate_dimCol  : dimCol H_gate = 2
axiom H_gate_square  : isSquareMat H_gate
axiom H_gate_unitary : unitaryMat H_gate
-- Key value axiom needed by HValues theorem:
-- indexMat H_gate i j = ±1/√2; stated as a separate Quantum.lean axiom to avoid
-- pulling Real.sqrt into the prelude's minimal import set.

-- Gate involutory laws (phase-2: matrix calculation; X²=Y²=Z²=H²=I₂)
axiom X_gate_involutory_law : matMul X_gate X_gate = oneMat 2
axiom Y_gate_involutory_law : matMul Y_gate Y_gate = oneMat 2
axiom Z_gate_involutory_law : matMul Z_gate Z_gate = oneMat 2
axiom H_gate_involutory_law : matMul H_gate H_gate = oneMat 2

-- CNOT gate (controlled-NOT): 4×4 matrix
axiom CNOT_gate : QMat
axiom CNOT_gate_dimRow  : dimRow CNOT_gate = 4
axiom CNOT_gate_dimCol  : dimCol CNOT_gate = 4
axiom CNOT_gate_square  : isSquareMat CNOT_gate
axiom CNOT_gate_unitary : unitaryMat CNOT_gate

-- S gate (phase gate): [[1,0],[0,i]]  (S² = Z)
axiom S_gate : QMat
axiom S_gate_dimRow  : dimRow S_gate = 2
axiom S_gate_dimCol  : dimCol S_gate = 2
axiom S_gate_square  : isSquareMat S_gate
axiom S_gate_unitary : unitaryMat S_gate

-- T gate (π/8 gate): [[1,0],[0,e^{iπ/4}]]  (T² = S)
axiom T_gate : QMat
axiom T_gate_dimRow  : dimRow T_gate = 2
axiom T_gate_dimCol  : dimCol T_gate = 2
axiom T_gate_square  : isSquareMat T_gate
axiom T_gate_unitary : unitaryMat T_gate

-- Identity gate (id gate: dim_row = 2^n, 1⇩m (2^n))
axiom Id_gate (n : ℕ) : QMat
axiom Id_gate_dimRow  (n : ℕ) : dimRow (Id_gate n) = 2^n
axiom Id_gate_dimCol  (n : ℕ) : dimCol (Id_gate n) = 2^n
axiom Id_gate_square  (n : ℕ) : isSquareMat (Id_gate n)
axiom Id_gate_unitary (n : ℕ) : unitaryMat (Id_gate n)
-- Identity matrix is always unitary (Mathlib: Matrix.one_mem_unitaryGroup)
axiom oneMat_unitary (n : ℕ) : unitaryMat (oneMat n)

-- ── Bell state axioms ─────────────────────────────────────────────────────────
-- AFP named Bell states: bell00, bell01, bell10, bell11
-- These are 4×1 column matrices (or 4-dim QVec in AFP).
-- bell00 = 1/√2 * (|00⟩ + |11⟩) = 1/√2 * [1,0,0,1]ᵀ
-- bell01 = 1/√2 * (|01⟩ + |10⟩) = 1/√2 * [0,1,1,0]ᵀ
-- bell10 = 1/√2 * (|00⟩ - |11⟩) = 1/√2 * [1,0,0,-1]ᵀ
-- bell11 = 1/√2 * (|01⟩ - |10⟩) = 1/√2 * [0,1,-1,0]ᵀ
axiom bell00 : QVec
axiom bell01 : QVec
axiom bell10 : QVec
axiom bell11 : QVec
axiom bell00_dim  : dimVec bell00 = 4
axiom bell01_dim  : dimVec bell01 = 4
axiom bell10_dim  : dimVec bell10 = 4
axiom bell11_dim  : dimVec bell11 = 4
axiom bell00_norm : cpxVecLen bell00 = 1
axiom bell01_norm : cpxVecLen bell01 = 1
axiom bell10_norm : cpxVecLen bell10 = 1
axiom bell11_norm : cpxVecLen bell11 = 1

-- ── Convenience: Gate structure instances for standard gates ──────────────────
-- These let theory files use `X_as_gate.mat` etc. without repeating hypotheses.
noncomputable def X_as_gate    : Gate 1 := ⟨X_gate,    X_gate_dimRow,    X_gate_square,    X_gate_unitary⟩
noncomputable def Y_as_gate    : Gate 1 := ⟨Y_gate,    Y_gate_dimRow,    Y_gate_square,    Y_gate_unitary⟩
noncomputable def Z_as_gate    : Gate 1 := ⟨Z_gate,    Z_gate_dimRow,    Z_gate_square,    Z_gate_unitary⟩
noncomputable def H_as_gate    : Gate 1 := ⟨H_gate,    H_gate_dimRow,    H_gate_square,    H_gate_unitary⟩
noncomputable def CNOT_as_gate : Gate 2 := ⟨CNOT_gate, CNOT_gate_dimRow, CNOT_gate_square, CNOT_gate_unitary⟩

end CATEPTMain.Quantum.IMD
