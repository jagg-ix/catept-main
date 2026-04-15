/-!
# MTN Translation Worklog — Matrix_Tensor → Lean 4
Source: AFP `Matrix_Tensor`
  (T.V.H. Prathamesh — 2016)
  https://www.isa-afp.org/entries/Matrix_Tensor.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.MTN)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: Kronecker product of matrices is finite-dimensional and well-supported
  in Mathlib via `Matrix.kronecker`. Phase-1 uses Mathlib types directly where possible.
  Key distinction from HSTP: MTN is purely finite-dimensional matrix algebra.

AFP entry abstract:
  Kronecker tensor product of matrices. Includes: definition of the Kronecker product,
  mixed-product property (A⊗B)(C⊗D) = (AC)⊗(BD), transpose property (A⊗B)ᵀ = Aᵀ⊗Bᵀ,
  Kronecker product and eigenvalues, connection to linear maps on tensor product spaces.

AFP session file order (for TH record numbering):
  1.  Kronecker_Product    (definition and basic properties)
  2.  Mixed_Product        (mixed-product/reversal rule)
  3.  Eigenvalues_Kron     (eigenvalue structure)

AFP direct dependencies:
  - HOL-Analysis (standard Isabelle)
  - Matrix (HOL-Library)

Used by (downstream AFP):
  - Matrices_for_ODEs (via matrix exponential, see MODE bridge)
  - Various quantum computing AFP entries (also used in IMD)

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.LinearAlgebra.Matrix.Kronecker
  - Mathlib.LinearAlgebra.Matrix.Eigenvalues
  - Mathlib.LinearAlgebra.TensorProduct

KEY DISTINCTION from HSTP:
  MTN = finite Kronecker product of matrices (Matrix.kronecker in Mathlib).
  HSTP = infinite-dimensional Hilbert tensor product (operator-algebraic completion).
  IMD  = uses `tensorMat = Matrix.kronecker` concretely in quantum circuits (n-qubit).

BINDER RULES (MTN-specific):
  B60: `kronecker_product A B` → `Matrix.kronecker A B` (use Mathlib directly)
  B61: eigenvalue pair of Kronecker product → `(λ, μ) → λ * μ`
  B62: `vec_tensor` (vectorization) → `Matrix.vec` or `Finsupp.equivFunOnFinite`

Phase-2 upgrade path:
  Phase-1 axioms for mixed-product, transpose, etc. → replace with Mathlib.Matrix proofs.

Phase record (cumulative):
  TH001–TH019: MTN theorems translated
-/

────────────────────────────────────────────────────────────────────────────────
## MTN-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.AFPBridge.MTN.MTNPrelude added to CATEPTSelfConsistency.lean
  - mtn_kronecker_consistent field added to CATEPTAFPConsistencyWitness
  - MTNConsistency section + catept_mtn_kronecker_consistent theorem added (trivial stub)
  - CATEPTSelfConsistencyContract extended with w.mtn_kronecker_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: matrix-tensor-afp (afp_transpile_lean4)
  Phase-2: kronecker_assoc + kronecker_transpose → C*-algebra for multi-qubit gates.
