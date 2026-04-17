/-!
# HSTP Translation Worklog — Hilbert_Space_Tensor_Product → Lean 4
Source: AFP `Hilbert_Space_Tensor_Product` (Dominique Unruh — September 10, 2024)
  https://www.isa-afp.org/entries/Hilbert_Space_Tensor_Product.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.HSTP)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons.
  HSTP is the most advanced functional analysis module in this batch.
  It depends on CBO — the CBO bridge MUST be stable before HSTP is emitted.

AFP entry abstract:
  Formalizes the tensor product of Hilbert spaces and related material:
  product of vectors, operators, subspaces, von Neumann algebras. Defines and
  studies: Hilbert-Schmidt and trace-class operators; compact operators;
  positive operators; weak/strong/weak* topologies; spectral theorem for compact
  operators; double commutant theorem.

AFP session file order (for TH record numbering):
  1.  Misc_Tensor_Product
  2.  Strong_Operator_Topology
  3.  Positive_Operators
  4.  HS2Ell2
  5.  Weak_Operator_Topology
  6.  Misc_Tensor_Product_TTS
  7.  Eigenvalues
  8.  Compact_Operators
  9.  Spectral_Theorem
  10. Trace_Class
  11. Weak_Star_Topology
  12. Hilbert_Space_Tensor_Product
  13. Partial_Trace
  14. Von_Neumann_Algebras
  15. Tensor_Product_Code

AFP direct dependencies (bridge required):
  - Complex_Bounded_Operators (CBO — bridged in CBO_WORKLOG.lean, must be stable)
  - Ordinary_Differential_Equations (AFP — ODE used for Duhamel/generator; bridge axioms)
  - With_Type (AFP — "poor man's dependent types"; bridge as `sorry`-stub module)
  - Wlog (AFP — WLOG tactic combinator; bridge as tactic or sorry)
  - HOL-Analysis (standard)

Used by (downstream AFP):
  - Registers (quantum/classical registers)
  - Kraus_Maps (quantum channels)

Mathlib modules used as semantic targets:
  - Mathlib.Analysis.InnerProductSpace.TensorProduct
  - Mathlib.LinearAlgebra.TensorProduct
  - Mathlib.Topology.Algebra.Module.UniformConvergence
  - Mathlib.Analysis.Compact.Basic
  - Mathlib.Topology.Sequences (for spectral topology)
  - Mathlib.Analysis.Normed.Operator.BoundedLinearMaps

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- HSTP-PRE-* = pre-generation gate items
-- HSTP-TH-*  = per-theory translation plans (AFP session order)
-- HSTP-INT-* = integration bridge targets
-- HSTP-TLA-* = TLA+ model extension targets
-- HSTP-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-PRE-001  AFP dependency bridge: CBO + ODE + With_Type → Lean 4 (P1)
Severity: P1 — blocker; HSTP imports CBO, ODE, and With_Type
Context:
  HSTP.thy directly depends on:
    (a) CBO: `cblinfun`, `adj`, operator norm, `ell2`, Hilbert space structure —
        all bridged in CBO_WORKLOG.lean; HSTP must import CBOPrelude.
    (b) Ordinary_Differential_Equations (AFP): HSTP uses ODE for semigroup theory
        (Stone's theorem: unitary group ↔ self-adjoint generator).
        Bridge: axiom `UnitaryGroup (H : Type) : Type` with axiom `stone_theorem`.
    (c) With_Type (AFP): a macro/tactic tool for "poor man's dependent types".
        Bridge: emit as empty `import` stub + sorry; With_Type HOL macros have
        no runtime content in Lean 4 (typeclass inference handles this).
    (d) Wlog: without-loss-of-generality combinator. Lean 4: `wlog` tactic exists
        in Mathlib (Mathlib.Tactic.WLOG); bridge is a no-op (use Mathlib tactic).
Strategy:
  - `import CATEPTMain.AFPBridge.CBO.CBOPrelude` (must be stable first)
  - ODE bridge: axiom stubs for semigroup generator; skip Stone's theorem in phase-1
  - With_Type: empty stub module `CATEPTMain.AFPBridge.HSTP.WithTypeStub`
  - Wlog: no translation needed, `wlog` tactic available from Mathlib
Key type correspondences:
  Hilbert tensor product H₁ ⊗ₕ H₂  →  axiom HSTPTensorSpace H₁ H₂ : Type (phase-1)
                                     →  Mathlib.Analysis.InnerProductSpace.TensorProduct (phase-2)
  compact operator K               →  axiom IsCompact : CBOSpace H H → Prop (phase-1)
  trace-class operator T           →  axiom IsTraceClass : CBOSpace H H → Prop
  Hilbert-Schmidt operator HS      →  axiom IsHilbertSchmidt : CBOSpace H H → Prop
  von Neumann algebra M            →  axiom IsVonNeumannAlgebra : (CBOSpace H H → Prop) → Prop
Fix target:
  `H₁ ⊗ₕ H₂` tensor product must NOT be emitted as `tensorMat H₁ H₂` (IMD Kronecker).
  The Hilbert tensor product is a COMPLETION, not just Kronecker product.
  Must use: `HSTPTensorSpace H₁ H₂` as a separate opaque type in phase-1.
Validation:
  - `grep "tensorMat" HSTPPrelude.lean Theories/*.lean | wc -l` → 0
    (HSTPTensorSpace must NOT reuse IMD's tensorMat)
  - `lake build CATEPTMain.AFPBridge.HSTP.HSTPPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-PRE-002  Prelude-first strategy: HSTPPrelude.lean (P1)
Severity: P1
Required prelude content (skeleton):
  import CATEPTMain.AFPBridge.CBO.CBOPrelude
  import Mathlib.Analysis.InnerProductSpace.TensorProduct
  set_option autoImplicit false
  namespace CATEPTMain.AFPBridge.HSTP
  -- Hilbert space tensor product (analytic completion)
  axiom HSTPTensorSpace : Type → Type → Type
  axiom HSTPTensorIn {H₁ H₂ : Type} : H₁ → H₂ → HSTPTensorSpace H₁ H₂
  noncomputable axiom HSTPInner {H₁ H₂ : Type} :
    HSTPTensorSpace H₁ H₂ → HSTPTensorSpace H₁ H₂ → ℂ
  -- Operator on HSTP
  noncomputable axiom HSTPOpTensor {H₁ H₂ : Type} :
    CBOSpace H₁ H₁ → CBOSpace H₂ H₂ → CBOSpace (HSTPTensorSpace H₁ H₂) (HSTPTensorSpace H₁ H₂)
  -- Advanced operator predicates
  axiom IsCompact {H : Type} : CBOSpace H H → Prop
  axiom IsHilbertSchmidt {H : Type} : CBOSpace H H → Prop
  axiom IsTraceClass {H : Type} : CBOSpace H H → Prop
  noncomputable axiom TraceOp {H : Type} : CBOSpace H H → ℂ
  -- Von Neumann algebra predicate
  axiom IsVonNeumannAlg {H : Type} : (CBOSpace H H → Prop) → Prop
  end CATEPTMain.AFPBridge.HSTP
Validation:
  - `lake build CATEPTMain.AFPBridge.HSTP.HSTPPrelude` EXIT:0
  - All HSTP theory files begin with `import CATEPTMain.AFPBridge.HSTP.HSTPPrelude`
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-PRE-003  Type map: Hilbert tensor product vs algebraic tensor product (P1)
Severity: P1 — the central conceptual risk of this module
Context:
  IMD uses `tensorMat` (Kronecker product of matrices) = ALGEBRAIC tensor product.
  HSTP formalizes the ANALYTIC tensor product (completed in ℓ²-norm).
  These are DIFFERENT operations; conflating them is a critical translation error.
  AFP distinguishes:
    `A ⊗⇩o B` (operator tensor on Hilbert spaces) = HSTPOpTensor A B
    `v ⊗⇩s w`  (elementary tensor of vectors) = HSTPTensorIn v w
  In Lean 4 Mathlib:
    - `TensorProduct ℂ H₁ H₂` is the ALGEBRAIC tensor product (module)
    - Completion to Hilbert tensor product requires `HilbertTensorProduct` (Mathlib 4.x)
      or must be defined as `HSTPTensorSpace` opaque axiom in phase-1.
Type map:
  AFP symbol      Lean 4 phase-1              Lean 4 phase-2
  H₁ ⊗⇩H H₂      HSTPTensorSpace H₁ H₂       HilbertTensorProduct ℂ H₁ H₂ (Mathlib)
  v ⊗⇩s w         HSTPTensorIn v w             HilbertTensorProduct.tmul v w
  A ⊗⇩o B         HSTPOpTensor A B             ContinuousLinearMap.tensorProduct A B
  Tr A            TraceOp A                   Matrix.trace or NuclearNorm
  ‖A‖_HS          HSNorm A (axiom)             HilbertSchmidtNorm A (Mathlib)
Validation:
  - `grep "tensorMat.*HSTP\|HSTPTensorSpace.*mat" HSTPPrelude.lean Theories/*.lean` → 0 hits
    (no contamination between IMD Kronecker and HSTP Hilbert tensor)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-PRE-004  Binder analysis: operator topology binders (P1)
Severity: P1
New binder rules for HSTP:
  B19 — `strong_operator_convergence f n x` → emit as propositional goal, NOT free term
  B20 — `weak_operator_convergence A_seq A` → emit as `WeakOpConv A_seq A : Prop` (axiom)
  B21 — `compact_op K` → emit as `(K : CBOSpace H H) (hK : IsCompact K)`
  B22 — `trace_class T` → emit as `(T : CBOSpace H H) (hT : IsTraceClass T)`
  B23 — `A ≤⇩L⇩o B` Loewner order → emit as `CBOLoewner A B` (CBO bridge predicate)
  B24 — `von_neumann_algebra M` → emit as `(M : CBOSpace H H → Prop) (hVN : IsVonNeumannAlg M)`
Validation:
  `grep "(: compact_op\|(: trace_class\|(: von_neumann" Theories/*.lean` → 0 hits
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-001  Theories: Misc_Tensor_Product + Misc_Tensor_Product_TTS (P2)
AFP files: Misc_Tensor_Product.thy, Misc_Tensor_Product_TTS.thy
Dependency: CBO (cblinfun, inner product spaces)
Content summary:
  Auxiliary material for tensor products of Hilbert spaces — algebraic prerequisites
  before introducing the completed Hilbert tensor product:
  - Algebraic tensor product: universal property, bilinear maps
  - _TTS suffix: "types-to-sets" version (uses Isabelle's `Types_To_Sets` mechanism)
    to transfer results from concrete types to abstract axiom sets
Translation challenge: MEDIUM-HIGH
  - Types_To_Sets in Isabelle has no direct analog in Lean 4.
  - Strategy: ignore TTS machinery; emit the mathematical RESULT theorems, not the
    transfer proof boilerplate.
  - Phase-1: sorry-stub all TTS-dependent propositions.
Batch note: merge both files into Theories/Misc_Tensor_Product.lean
Validation: `lake build CATEPTMain.AFPBridge.HSTP.Misc_Tensor_Product` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-002  Theories: Strong_Operator_Topology + Weak_Operator_Topology + Weak_Star_Topology (P2)
AFP files: Strong_Operator_Topology.thy, Weak_Operator_Topology.thy, Weak_Star_Topology.thy
Dependency: CBO, Misc_Tensor_Product
Content summary:
  Three topologies on bounded operators:
  - Strong: Aₙ → A strongly iff ∀v, Aₙv → Av in H (pointwise norm convergence)
  - Weak: ⟨Aₙu, v⟩ → ⟨Au, v⟩ for all u, v (pointwise inner product convergence)
  - Weak*: dual/predual topology (for von Neumann algebras)
Translation challenge: MEDIUM
  - Lean 4 Mathlib: `Topology.Algebra.Module.UniformConvergence` covers pointwise
    convergence topologies; `WeakDual` covers weak* topology.
  - Phase-1: axiom `StrongOpCont : (ℕ → CBOSpace H H) → CBOSpace H H → Prop`
  - Phase-2: use Filter/Topology instances from Mathlib.Topology
Batch note: merge three topology files into Theories/Operator_Topologies.lean
Validation:
  - `lake build CATEPTMain.AFPBridge.HSTP.Operator_Topologies` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-003  Theories: Positive_Operators + Eigenvalues (P2)
AFP files: Positive_Operators.thy, Eigenvalues.thy
Dependency: CBO, Misc_Tensor_Product
Content summary:
  - Positive_Operators: A ≥ 0 (Loewner order), square root of positive operators
  - Eigenvalues: eigenvalue/eigenvector theory for bounded operators;
    Rayleigh quotient; spectral radius
Translation challenge: MEDIUM-HIGH
  - Operator square root: `√A` for PSD cblinfun A → Mathlib `CFC.sqrt` (continuous
    functional calculus).
  - Spectral radius: `ρ(A) = sup_n ‖Aⁿ‖^(1/n)` → Mathlib `spectralRadius`.
  - Phase-1: axiom `cblinfunSqrt`, axiom `spectralRadius`.
Key theorems: pos_op_sqrt_exists, spectral_radius_formula, rayleigh_quotient_bound
Validation: `lake build CATEPTMain.AFPBridge.HSTP.Positive_Operators` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-004  Theory: HS2Ell2 (P2)
AFP file: HS2Ell2.thy
Dependency: CBO, Positive_Operators
Content summary:
  Isometric isomorphism between Hilbert-Schmidt operators on H and ℓ²(H⊗H).
  Key result: HS(H) ≅ ℓ²(H ⊗ H) (Hilbert-Schmidt operators form a Hilbert space).
Translation challenge: MEDIUM
  - Phase-1: axiom `HSToEll2 : CBOSpace H H → Ell2 (H × H) → ℂ` (linear functional)
  - Phase-2: Mathlib.Analysis.HilbertSchmidt (if available) or custom construction
Validation: `lake build CATEPTMain.AFPBridge.HSTP.HS2Ell2` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-005  Theories: Compact_Operators + Spectral_Theorem (P1)
AFP files: Compact_Operators.thy, Spectral_Theorem.thy
Dependency: Positive_Operators, Eigenvalues, Operator_Topologies
Content summary:
  - Compact_Operators: characterizations of compact operators (limit of finite-rank;
    maps bounded sets to precompact sets); ideal property of compact operators
  - Spectral_Theorem: for compact self-adjoint operators: countable spectrum,
    eigenvectors form an orthonormal basis, spectral decomposition series
Translation challenge: CRITICAL (most mathematically deep in HSTP)
  REASON 1 — Compact operator characterization:
    AFP: `compact_op A` ↔ `A maps bounded sets to relatively compact sets`.
    Lean 4 Mathlib: `IsCompactOperator` in `Mathlib.Topology.Algebra.Module.FiniteDimension`.
    Bridge: `axiom IsCompact` in HSTPPrelude + phase-2 `IsCompactOperator`.
  REASON 2 — Spectral series:
    Spectral decomposition is an INFINITE series of rank-1 projectors summing to Id
    in the strong operator topology. This requires `tsum` (summable series) in Lean 4.
    Phase-1: axiom `spectralDecomp : CBOSpace H H → (ℕ → CBOSpace H H)` with axiom
    `spectralDecomp_sum_SOT : StrongOpConv (fun n => ∑ k < n, spectralDecomp A k) A`.
    Phase-2: use `Mathlib.Analysis.Spectral.compact` (if exists) or build from scratch.
  REASON 3 — Orthonormal basis from eigenvectors:
    `OrthonormalBasis ℕ ℂ H` in Lean 4; emit as axiom `spectralONB : OrthonormalBasis ℕ ℂ H`.
Key theorems: compact_op_approx_finite_rank, spectral_theorem_compact_selfadj,
  spectral_decomp_sum_converges
Validation:
  - `grep "IsCompact\|spectralDecomp\|spectralONB" Theories/Compact_Operators.lean` → ≥1 each
  - `lake build CATEPTMain.AFPBridge.HSTP.Compact_Operators` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-006  Theory: Trace_Class (P2)
AFP file: Trace_Class.thy
Dependency: Compact_Operators, HS2Ell2
Content summary:
  Trace-class (nuclear) operators: subset of compact operators where `Tr(|A|) < ∞`.
  Trace functional: `Tr(A) = ∑ₙ ⟨Aeₙ, eₙ⟩` (basis-independent for trace-class).
  Duality: trace-class is the predual of bounded operators `B(H)`.
Translation challenge: HIGH
  - Trace series convergence: `∑' n : ℕ, inner (A (e n)) (e n)` must converge.
  - Phase-1: axiom `TraceOp : CBOSpace H H → ℂ` with axiom `TraceOp_converges`.
  - Phase-2: Mathlib nuclear norm (if available) or tsum over ONB.
Key theorems: trace_class_is_compact, trace_well_defined, trace_adjoint, trace_cycle
Validation: `lake build CATEPTMain.AFPBridge.HSTP.Trace_Class` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-007  Theory: Hilbert_Space_Tensor_Product (P1 — central theory)
AFP file: Hilbert_Space_Tensor_Product.thy
Dependency: All previous modules
Content summary:
  The main Hilbert tensor product construction:
  - Universal property: bilinear maps H₁ × H₂ → K extend to continuous linear maps H₁ ⊗ₕ H₂ → K
  - Inner product on tensor product: ⟨v₁⊗w₁, v₂⊗w₂⟩ = ⟨v₁,v₂⟩⟨w₁,w₂⟩ (and linear extension)
  - Operator tensor: (A ⊗ B)(v ⊗ w) = Av ⊗ Bw (and operator norm bound)
  - Flipping isomorphism: H₁ ⊗ₕ H₂ ≅ H₂ ⊗ₕ H₁
  - Associativity: (H₁ ⊗ₕ H₂) ⊗ₕ H₃ ≅ H₁ ⊗ₕ (H₂ ⊗ₕ H₃)
Translation challenge: VERY HIGH
  REASON 1 — Completion construction:
    Algebraic tensor product TensorProduct ℂ H₁ H₂ (Lean 4) must be completed in
    the Hilbert norm. This requires Cauchy completion (`UniformSpace.Completion`).
    Phase-1: HSTPTensorSpace as opaque axiom (see HSTPPrelude).
    Phase-2: `def HSTPTensorSpace H₁ H₂ := completion (TensorProduct ℂ H₁ H₂)`
  REASON 2 — Continuity of extension:
    Universal property requires proving the extension is bounded (continuous), which
    uses that elementary tensors span a dense subset.
    Density argument: phase-1 axiom `elementary_tensors_dense`.
  REASON 3 — Connection to FINITE-dim IMD case:
    For finite n: `HSTPTensorSpace (Fin n → ℂ) (Fin m → ℂ) ≅ Fin (n*m) → ℂ`
    This bridges to IMD's `tensorMat` Kronecker product.
    Phase-1: axiom `HSTPFlat_finite : HSTPTensorSpace (Fin n → ℂ) (Fin m → ℂ) ≃ₗ[ℂ] (Fin (n*m) → ℂ)`
Key theorems: tensor_product_universal, tensor_norm_mul, tensor_flip_isom,
  tensor_associativity, HSTPFlat_finite
Validation:
  - `grep "HSTPTensorIn\|HSTPOpTensor\|HSTPFlat" Theories/Hilbert_Space_Tensor_Product.lean` → each ≥1
  - `lake build CATEPTMain.AFPBridge.HSTP.Hilbert_Space_Tensor_Product` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-008  Theory: Partial_Trace (P2)
AFP file: Partial_Trace.thy
Dependency: Hilbert_Space_Tensor_Product, Trace_Class
Content summary:
  Partial trace: Trₐ : B(H₁ ⊗ₕ H₂) → B(H₂) defined by ∑ₙ ⟨eₙ, ·eₙ⟩ over ONB of H₁.
  Key property: Trₐ(A ⊗ B) = Tr(A) · B.
  Connects to quantum mechanics: reduced density matrix = partial trace over environment.
Translation challenge: HIGH
  - Phase-1: axiom `partialTrace : CBOSpace (HSTPTensorSpace H₁ H₂) (HSTPTensorSpace H₁ H₂) → CBOSpace H₂ H₂`
  - Connects PM (projective measurements on composite systems) to HSTP.
Validation: `lake build CATEPTMain.AFPBridge.HSTP.Partial_Trace` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-009  Theory: Von_Neumann_Algebras (P2)
AFP file: Von_Neumann_Algebras.thy
Dependency: Hilbert_Space_Tensor_Product, Operator_Topologies, Trace_Class
Content summary:
  Von Neumann algebras: *-subalgebras of B(H) closed in weak operator topology.
  Double commutant theorem: M'' = M (where M' = commutant of M).
  Factors: von Neumann algebras with trivial center.
Translation challenge: HIGH
  - Phase-1: all as axioms/predicates (IsVonNeumannAlg, Commutant, DoubleCom, IsFactor)
  - Phase-2: formalize from first principles or use Mathlib if VN algebra library exists
Validation: `lake build CATEPTMain.AFPBridge.HSTP.Von_Neumann_Algebras` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TH-010  Theory: Tensor_Product_Code (P4)
AFP file: Tensor_Product_Code.thy
Dependency: Hilbert_Space_Tensor_Product, Cblinfun_Matrix
Content summary: code generation support for tensor product (same as CBO-TH-008 pattern).
Translation challenge: MINIMAL — same as CBO code modules; emit as stub.
Validation: `lake build CATEPTMain.AFPBridge.HSTP.Tensor_Product_Code` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-INT-001  Integration bridge: CATEPTMain.Integration.HSTPBridge (P2)
Severity: P2
Target file: CATEPTMain/Integration/HSTPBridge.lean
Content plan:
  import CATEPTMain.AFPBridge.HSTP.HSTPPrelude
  import CATEPTMain.AFPBridge.HSTP.Hilbert_Space_Tensor_Product
  import CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Matrix
  import CATEPTMain.AFPBridge.IMD.IMDPrelude
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: finite-dim HSTP tensor product is consistent with IMD Kronecker. -/
  structure HSTPBridgeContract (n m : ℕ) where
    v1    : Fin n → ℂ   -- vector in Fin n Hilbert space
    v2    : Fin m → ℂ   -- vector in Fin m Hilbert space
    /-- HSTP tensor and IMD Kronecker agree on finite-dim vectors -/
    hFlat : HSTPFlat_finite (HSTPTensorIn v1 v2) = finProdVec v1 v2
  theorem hstpBridgeExists (n m : ℕ) : ∃ _ : HSTPBridgeContract n m, True :=
    ⟨{ v1 := sorry, v2 := sorry, hFlat := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation: `lake build CATEPTMain.Integration.HSTPBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-TLA-001  TLA+ model for HSTP translation control loop (P3)
New error classes:
  "E26_hilbert_tensor_vs_kronecker_conflation"
    — HSTPTensorSpace conflated with IMD tensorMat (Kronecker)
    — remediation: "use_separate_HSTPTensorSpace_axiom"
  "E27_completion_missing"
    — Hilbert tensor product emitted without completeness/denseness axioms
    — remediation: "add_elementary_tensors_dense_axiom"
  "E28_partial_trace_type_error"
    — partialTrace emitted with wrong domain type (QMat instead of CBOSpace ⊗ space)
    — remediation: "use_partialTrace_axiom_from_prelude"
New invariants:
  HSTPNoKronecker == ∀ thy ∈ THEORIES_HSTP: built[thy] => "tensorMat" ∉ definedFns[thy]
  HSTPCompletion  == built["Hilbert_Space_Tensor_Product"] =>
    "elementary_tensors_dense" ∈ axiomNames ∪ theoremNames
Validation: TLC model check: 0 invariant violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-QA-001  Regression checks for HSTP translator output (P1)
Checks:
  1. No Kronecker/HSTP conflation: `grep "tensorMat" HSTPPrelude.lean Theories/*.lean | wc -l` → 0
  2. HSTPTensorSpace present: `grep "HSTPTensorSpace" HSTPPrelude.lean` → ≥1
  3. partialTrace axiom: `grep "partialTrace\|partial_trace" HSTPPrelude.lean Theories/Partial_Trace.lean` → ≥1
  4. VN algebra predicate: `grep "IsVonNeumannAlg\|von_neumann_alg" HSTPPrelude.lean` → ≥1
  5. No adjoint notation: `grep "notation.*†" Theories/*.lean HSTPPrelude.lean | wc -l` → 0
  6. No autoImplicit: `grep "autoImplicit true" Theories/*.lean HSTPPrelude.lean | wc -l` → 0
  7. Full build: `lake build CATEPTMain.AFPBridge.HSTP` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## HSTP-QA-002  Faithfulness delta metric for HSTP (P2)
Metrics:
  faithful_hstp_type   = 1.0  (HSTPTensorSpace opaque, not Kronecker alias)
  faithful_completion  = 1.0  (elementary_tensors_dense axiom present)
  faithful_partial_tr  = 1.0  (partialTrace axiom correctly typed)
  faithful_proof       = 0.0  (all sorry in phase-1)
Phase-2 targets: faithful_proof ≥ 0.2 (double commutant + finite-dim flatness provable)
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.

/-!
## RS-P1-HSTP-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-HSTP)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-HSTP is DONE, all imports of this module change from
  `CATEPTMain.AFPBridge.HSTP.*`  →  `CATEPTMain.AFPBridge.HSTP.*`
-/
