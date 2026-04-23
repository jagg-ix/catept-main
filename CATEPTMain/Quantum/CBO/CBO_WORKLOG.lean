/-!
# CBO Translation Worklog — Complex_Bounded_Operators → Lean 4
Source: AFP `Complex_Bounded_Operators`
  (José Manuel Rodríguez Caballero, Dominique Unruh — September 18, 2021)
  https://www.isa-afp.org/entries/Complex_Bounded_Operators.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.Quantum.CBO)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons. CBO is the largest AFP
  session in this batch (18+ theory files). PRE gates are essential to avoid the
  `cblinfun` type-collapse risk that mirrors the IMD `cpx_sqr_mat` risk.

AFP entry abstract:
  Formalization of bounded operators on complex vector spaces. Covers: complex vector
  spaces (normed, Banach, Hilbert), the `cblinfun` type (bounded complex linear functions),
  unitaries, projectors, BLT theorem, adjoints, Loewner order, closed subspaces, and
  finite-dimensional operator ↔ matrix correspondence (via Jordan_Normal_Form).

AFP session file order (for TH record numbering):
  1.  Extra_Pretty_Code_Examples
  2.  Extra_General
  3.  Extra_Vector_Spaces
  4.  Extra_Ordered_Fields
  5.  Extra_Operator_Norm
  6.  Complex_Vector_Spaces0
  7.  Complex_Vector_Spaces
  8.  Complex_Inner_Product0
  9.  Complex_Inner_Product
  10. One_Dimensional_Spaces
  11. Complex_Euclidean_Space0
  12. Complex_Bounded_Linear_Function0
  13. Complex_Bounded_Linear_Function
  14. Complex_L2
  15. Extra_Jordan_Normal_Form
  16. Cblinfun_Matrix
  17. Cblinfun_Code
  18. Cblinfun_Code_Examples

AFP direct dependencies (bridge required):
  - Banach_Steinhaus (AFP) — Banach-Steinhaus / uniform boundedness theorem
  - Jordan_Normal_Form (AFP) — already bridged via IMDPrelude's dep chain
  - Real_Impl (AFP) — field extensions Q[√b]
  - Wlog (AFP) — without-loss-of-generality tactic combinator
  - HOL-Analysis (standard)

Used by (downstream AFP):
  - Hilbert_Space_Tensor_Product (HSTP — next worklog in this batch)
  - Two_Hermitian_Results

Mathlib modules used as semantic targets:
  - Mathlib.Analysis.InnerProductSpace.Adjoint
  - Mathlib.Analysis.Normed.Operator.BoundedLinearMaps
  - Mathlib.Topology.Algebra.Module.Basic
  - Mathlib.Analysis.InnerProductSpace.Basic
  - Mathlib.MeasureTheory.Function.L2Space

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- CBO-PRE-* = pre-generation gate items (must all pass before any .lean is emitted)
-- CBO-TH-*  = per-theory translation plans (AFP session order)
-- CBO-INT-* = integration bridge targets
-- CBO-TLA-* = TLA+ model extension targets
-- CBO-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-PRE-001  AFP dependency bridge: cblinfun → ContinuousLinearMap ℂ H H (P1)
Severity: P1 — blocker; `cblinfun` is the central type of this entire AFP session
Context:
  AFP `cblinfun` (complex bounded linear function) is a new TYPE in Isabelle/HOL
  defined as: `typedef ('a, 'b) cblinfun = {f :: 'a ⇒ 'b | bounded_clinear f}`
  This is an opaque wrapper around bounded ℂ-linear maps between complex normed spaces.
  In Lean 4 / Mathlib: `ContinuousLinearMap ℂ H₁ H₂` with the bound implicit in
    the type via the ContinuousLinearMapClass instance.
  CRITICAL RISK (analogous to IMD cpx_sqr_mat): if the translator emits `cblinfun` as
    a function type `(f : H → H)` without the boundedness wrapper, all downstream
    operator norm and adjoint lemmas will be un-typeable.
Strategy:
  Phase-1: `axiom CblinfunSpace (H₁ H₂ : Type) : Type` as opaque type alias
    with key structural axioms.
  Phase-2: `def CblinfunSpace (H₁ H₂ : Type) [NormedAddCommGroup H₁] [InnerProductSpace ℂ H₁]
              [NormedAddCommGroup H₂] [InnerProductSpace ℂ H₂] :=
              ContinuousLinearMap ℂ H₁ H₂`
Key type correspondences:
  ('a, 'b) cblinfun   →  ContinuousLinearMap ℂ H₁ H₂  (phase-2) / opaque axiom (phase-1)
  ‖A‖ (op norm)       →  ‖A‖ (Mathlib operator norm via NormedSpace instance)
  A† (adjoint)        →  ContinuousLinearMap.adjoint (Mathlib)
  A ∘ B (composition) →  A.comp B or A ∘L B
  Id (identity op)    →  ContinuousLinearMap.id ℂ H
  0 (zero op)         →  0 : ContinuousLinearMap ℂ H₁ H₂
Fix target:
  - Never emit `(A : H → H)` for cblinfun-typed variables
  - Adjoint notation: Mathlib uses `ContinuousLinearMap.adjoint` or `star A` (star monoid)
    Do NOT emit `†` notation; use `cblinfunAdj` prefix axiom in phase-1
Validation:
  - `grep "(: .* → .*)" CBOPrelude.lean | grep -v "fun\|def\|axiom" | wc -l` → 0
  - `lake build CATEPTMain.Quantum.CBO.CBOPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-PRE-002  Prelude-first strategy: CBOPrelude.lean (P1)
Severity: P1 — all CBO theory files must import CBOPrelude
Required prelude content (skeleton):
  import Mathlib.Analysis.InnerProductSpace.Adjoint
  import Mathlib.Analysis.Normed.Operator.BoundedLinearMaps
  import Mathlib.Topology.Algebra.Module.Basic
  set_option autoImplicit false
  namespace CATEPTMain.Quantum.CBO
  -- Phase-1 opaque type for cblinfun
  variable (H : Type) [NormedAddCommGroup H] [InnerProductSpace ℂ H] [CompleteSpace H]
  -- Core cblinfun axioms (phase-1 opaque; phase-2 replaced by ContinuousLinearMap)
  axiom CBOSpace : Type → Type → Type
  axiom CBOApply {H₁ H₂ : Type} : CBOSpace H₁ H₂ → H₁ → H₂
  noncomputable axiom CBONorm {H₁ H₂ : Type} : CBOSpace H₁ H₂ → ℝ
  noncomputable axiom CBOAdj {H : Type} : CBOSpace H H → CBOSpace H H
  noncomputable axiom CBOComp {H₁ H₂ H₃ : Type} :
    CBOSpace H₂ H₃ → CBOSpace H₁ H₂ → CBOSpace H₁ H₃
  -- Key predicates
  axiom IsUnitary (A : CBOSpace H H) : Prop
  axiom IsProjector (P : CBOSpace H H) : Prop  -- P² = P, P† = P
  axiom IsPositive (A : CBOSpace H H) : Prop   -- ⟨Av, v⟩ ≥ 0 for all v
  end CATEPTMain.Quantum.CBO
Validation:
  - `lake build CATEPTMain.Quantum.CBO.CBOPrelude` EXIT:0
  - No `cblinun` type emitted as `H → H` anywhere in CBOPrelude.lean
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-PRE-003  Concrete type map: cblinfun family (P1)
Severity: P1
Type map (translator must encode in integration/afp_type_map.yaml CBO section):
  AFP symbol            Lean 4 phase-1              Lean 4 phase-2
  ('a,'b) cblinfun      CBOSpace H₁ H₂              ContinuousLinearMap ℂ H₁ H₂
  'a ell2               ℓ² Hilbert space             PiLp 2 (fun _ : α => ℂ) or lp 2
  bounded_sesquilinear  axiom BCombForm               ContinuousLinearMap sesquilinear
  adj A                 CBOAdj A                     ContinuousLinearMap.adjoint A
  ‖A‖ (cblinfun norm)   CBONorm A                    ‖(A : ContinuousLinearMap ℂ H H)‖
  A o⇩C⇩L B             CBOComp A B                  A ∘L B
  id_cblinfun           CBOId                        ContinuousLinearMap.id ℂ H
  scaleC c A            CBOScale c A                 c • A
  Loewner order A ≤ B   axiom CBOLoewner A B : Prop  0 ≤ CBOAdj B ∘L B - CBOAdj A ∘L A
  Hilbert-Schmidt op    axiom IsHS : CBOSpace H H → Prop  (HS norm ≤ ∞)
  trace-class op        axiom IsTraceClass : Prop    (Σ singular values < ∞)
Watchout: `ell2` type (ℓ² Hilbert space) — AFP uses this for infinite-dimensional H.
  Phase-1: axiom Ell2Space : Type → Type; phase-2: Mathlib.Analysis.MeanInequalities.Lp
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-PRE-004  Binder analysis for CBO (P1)
Severity: P1
Binder rules (extending IMD-PRE-004 and PM-PRE-004):
  B14 — `bounded_clinear f`  → emit as `(f : H₁ →L[ℂ] H₂) (hf : IsBoundedLinearMap ℂ f)`
        NEVER as `(f : bounded_clinear)` or `(f : H₁ → H₂)` alone
  B15 — `is_projection P`    → emit as `(P : CBOSpace H H) (hP : IsProjector P)`
  B16 — `A ≤ B` (Loewner)    → emit as `(h : CBOLoewner A B)`, not `(A B : CBOSpace)` alone
  B17 — `Tr A` (trace)       → emit as `CBOTrace A : ℂ` (axiom), never as `(Tr : CBOSpace → ℂ)`
  B18 — `norm A` (op norm)   → emit as `CBONorm A : ℝ`, never free function variable
Validation:
  `grep "(f : .* → .*[Cc]linear\|(P : is_projection" Theories/*.lean` → 0 hits
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-001  Theories: Extra_* auxiliary modules (P3)
AFP files: Extra_Pretty_Code_Examples, Extra_General, Extra_Vector_Spaces,
           Extra_Ordered_Fields, Extra_Operator_Norm
Dependency: HOL standard library
Content summary:
  Five auxiliary "Extra_*" files provide HOL lemmas extending the standard library.
  These are utility modules used internally by the main CBO theories. Content:
  - Extra_General: some basic HOL lemmas (funext, set operations)
  - Extra_Vector_Spaces: linear algebra over ℂ (complex conjugate, norm properties)
  - Extra_Ordered_Fields: order/field lemmas for ℝ/ℂ comparisons
  - Extra_Operator_Norm: basic operator norm inequalities
  - Extra_Pretty_Code_Examples: code export examples (can be stubs in Lean 4)
Translation challenge: LOW-MEDIUM
  Most lemmas have direct Mathlib analogs. These files are not mathematically deep.
  Phase-1: emit as thin modules that re-export relevant Mathlib lemmas + sorry stubs.
  Phase-2: proof obligations fill in using simp/norm_num tactics.
Emit strategy: batch all five into a single Theories/Extra_Aux.lean to reduce file count.
Validation:
  - `lake build CATEPTMain.Quantum.CBO.Extra_Aux` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-002  Theory: Complex_Vector_Spaces0 + Complex_Vector_Spaces (P2)
AFP files: Complex_Vector_Spaces0.thy, Complex_Vector_Spaces.thy
Dependency: Extra_* modules
Content summary:
  Complex vector spaces on top of HOL+Analysis: complex modules, CModule,
  complex_vector_space, complex_inner_product_space (pre-typeclass version in AFP).
  Key definitions: `cinner` (complex inner product), `is_ortho_set`.
Translation challenge: MEDIUM
  - Lean 4 Mathlib already has `InnerProductSpace ℂ H` with `inner : H → H → ℂ`.
  - AFP `cinner` (antilinear in first argument) matches Mathlib convention for ℂ.
  - Phase-1: abstract over `inner` with `axiom cInner : H → H → ℂ` in CBOPrelude.
  - Phase-2: `def cInner := @inner ℂ H _`
Key theorems: cinner_sesquilinear, cinner_nonneg, cinner_pos_iff (for norms).
Batch note: merge 0 and non-0 variants into single Theories/Complex_Vector_Spaces.lean.
Validation:
  - `lake build CATEPTMain.Quantum.CBO.Complex_Vector_Spaces` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-003  Theory: Complex_Inner_Product0 + Complex_Inner_Product (P1)
AFP files: Complex_Inner_Product0.thy, Complex_Inner_Product.thy
Dependency: Complex_Vector_Spaces
Content summary:
  Hilbert space axiomatization in AFP — the core of the CBO type hierarchy.
  Key concepts: `chilbert_space` typeclass (inner product + completeness),
  extended Cauchy-Schwarz, Gram-Schmidt, Riesz representation theorem,
  `ell2_norm`, `ell2` Hilbert space type.
Translation challenge: HIGH
  REASON 1 — `ell2` Hilbert space:
    AFP `'a ell2` is the Hilbert space ℓ²(α) (square-summable sequences indexed by α).
    Mathlib equivalent: `lp 2 (fun _ : α => ℂ)` or for finite: `EuclideanSpace ℂ (Fin n)`.
    Phase-1: axiom `Ell2 : Type → Type`. Phase-2: `def Ell2 α := lp 2 (fun _ : α => ℂ)`.
  REASON 2 — Riesz representation:
    AFP proves: every bounded linear functional φ on H is inner-product-with-some-v.
    Lean 4 Mathlib: `InnerProductSpace.toDual` (Riesz map H ≃ H*).
    Phase-1: axiom `rieszRep : (H →L[ℂ] ℂ) → H`. Phase-2: use Mathlib.
  REASON 3 — Gram-Schmidt:
    AFP formalizes Gram-Schmidt process; Lean 4 Mathlib has `gramSchmidt` in
    `Mathlib.Analysis.InnerProductSpace.GramSchmidt`.
    Phase-1: axiom stubs. Phase-2: bridge via Mathlib.
Key theorems: cauchy_schwarz, riesz_rep_bounded_functional, ell2_norm_sq,
  is_ortho_set_ORTH (orthonormal sets).
Validation:
  - `lake build CATEPTMain.Quantum.CBO.Complex_Inner_Product` EXIT:0
  - `grep "Ell2\|ell2\|rieszRep" CBOPrelude.lean Theories/Complex_Inner_Product.lean` → ≥1 each
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-004  Theory: Complex_Bounded_Linear_Function0 + Complex_Bounded_Linear_Function (P1)
AFP files: Complex_Bounded_Linear_Function0.thy, Complex_Bounded_Linear_Function.thy
Dependency: Complex_Inner_Product
Content summary:
  The central theory — definition and theory of `cblinfun`:
  - `typedef cblinfun = {f | bounded_clinear f}` (opaque bounded linear map type)
  - Operator norm `‖A‖` with submultiplicativity
  - Banach algebra structure on `cblinfun`
  - BLT theorem: bounded linear maps extend from dense subsets
  - Bounded sesquilinear forms and their associated operators
  - Adjoint `A†` (= `cblinfun_adj A`): characterized by `⟨A†v, w⟩ = ⟨v, Aw⟩`
  - Spectrum, resolvent set
Translation challenge: CRITICAL (largest single theory in CBO)
  REASON 1 — `cblinfun` typedef (analogous to IMD cpx_sqr_mat):
    See CBO-PRE-001. The typedef must be bridged as CBOSpace (phase-1) or ContinuousLinearMap.
    THIS IS THE CENTRAL TYPE OF THE ENTIRE CBO SESSION — get this wrong and all downstream
    files (HSTP, etc.) break.
  REASON 2 — Operator norm:
    `‖A‖` for `cblinfun` is the supremum of `‖Av‖/‖v‖`. In Mathlib:
    `ContinuousLinearMap.opNorm` (notation `‖A‖`). Phase-1: axiom CBONorm.
    WARNING: do not conflate matrix norm (Frobenius) with operator norm.
  REASON 3 — Adjoint notation:
    AFP `cblinfun_adj A` uses notation `A†`. Lean 4 must NOT redefine `†` (conflicts
    with Mathlib `star` or IMD dagger). Use: `cblinfunAdj A` as prefix always.
  REASON 4 — BLT theorem:
    Extension of bounded linear maps is a typeclass inference obligation in Lean 4;
    phase-1: axiom `BLTExtend`. Phase-2: use `DenseRange.extend` from Mathlib.
Key theorems: opNorm_submul, adjoint_compose, adjoint_adjoint,
  spectrum_nonempty, BLT_extension, norm_bound_iff.
Validation:
  - `grep "CBOAdj\|cblinfunAdj" Theories/Complex_Bounded_Linear_Function.lean` → ≥1
  - No `†` notation defined: `grep "notation.*†" Theories/*.lean` → 0
  - `lake build CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-005  Theory: One_Dimensional_Spaces (P3)
AFP file: One_Dimensional_Spaces.thy
Dependency: Complex_Inner_Product
Content summary:
  Characterization of 1-dimensional complex Hilbert/Banach spaces.
  Main result: a 1-dimensional complex Hilbert space is isometric to ℂ.
Translation challenge: LOW
  - Lean 4 Mathlib: `ComplexHilbert₁.equiv : H ≃ₗᵢ[ℂ] ℂ` for FiniteDimensional rank 1.
  - Phase-1: axiom `IsOneDim : Type → Prop` with `iso_to_C : IsOneDim H → (H ≃ₗᵢ[ℂ] ℂ)`.
  - Phase-2: use `Module.rank_eq_one_iff` and linear isometry.
Validation: `lake build CATEPTMain.Quantum.CBO.One_Dimensional_Spaces` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-006  Theory: Complex_L2 (P2)
AFP file: Complex_L2.thy
Dependency: Complex_Bounded_Linear_Function
Content summary:
  L² Hilbert space formalization: square-integrable complex-valued functions.
  Key: `L2_complex` type, measurability conditions, inner product on L².
Translation challenge: MEDIUM
  - Lean 4 Mathlib: `MeasureTheory.L2` is `Lp E 2 μ` for normed space E.
  - Phase-1: axiom `L2Space (α : Type) (μ : MeasureTheory.Measure α) : Type`
  - Phase-2: `def L2Space α μ := MeasureTheory.Lp ℂ 2 μ`
Key theorems: L2_inner_correct, L2_norm_sq_integral
Validation: `lake build CATEPTMain.Quantum.CBO.Complex_L2` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-007  Theories: Cblinfun_Matrix + Extra_Jordan_Normal_Form (P2)
AFP files: Cblinfun_Matrix.thy, Extra_Jordan_Normal_Form.thy
Dependency: Complex_Bounded_Linear_Function, Complex_Euclidean_Space0, Jordan_Normal_Form
Content summary:
  Bridge between finite-dimensional cblinfun and Jordan_Normal_Form matrices.
  Key result: cblinfun on ℂⁿ is representable as an n×n complex matrix.
  Extra_Jordan_Normal_Form: additional lemmas on complex normal matrices.
Translation challenge: HIGH
  - This bridge connects CBO's operator world with IMD's matrix world.
  - Lean 4 analog: `LinearMap.toMatrix` (for linear maps ↔ matrix).
  - Phase-1: axiom `cblinfunToMatrix : CBOSpace (Fin n → ℂ) (Fin n → ℂ) → QMat`
    and `matrixToCblinfun : QMat → CBOSpace (Fin n → ℂ) (Fin n → ℂ)`
  - Phase-2: use `ContinuousLinearMap.toMatrix` from Mathlib.
  CRITICAL: this bridge is the entry point for HSTP (next module) — must be stable.
Key theorems: finite_dim_cblinfun_matrix_iso, matrix_of_adj, matrix_of_comp
Validation:
  - `grep "cblinfunToMatrix\|matrixToCblinfun" Theories/Cblinfun_Matrix.lean` → ≥1 each
  - `lake build CATEPTMain.Quantum.CBO.Cblinfun_Matrix` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TH-008  Theories: Cblinfun_Code + Cblinfun_Code_Examples (P4)
AFP files: Cblinfun_Code.thy, Cblinfun_Code_Examples.thy
Dependency: Cblinfun_Matrix
Content summary:
  Code generation support for cblinfun (for Isabelle's code extraction).
  These theory files are largely irrelevant to Lean 4 translation since Lean 4
  evaluates via kernel reduction / native_decide, not Isabelle's code extractor.
Translation challenge: MINIMAL
  Emit as stub modules with a single `-- Code generation not needed in Lean 4` comment
  and a `sorry`-stub for any exported theorem referenced by downstream AFP entries.
Strategy: emit empty modules with `import CBOPrelude` only.
Validation: `lake build CATEPTMain.Quantum.CBO.Cblinfun_Code` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-INT-001  Integration bridge: CATEPTMain.Integration.CBOBridge (P2)
Severity: P2
Target file: CATEPTMain/Integration/CBOBridge.lean
Content plan:
  import CATEPTMain.Quantum.CBO.CBOPrelude
  import CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function
  import CATEPTMain.Quantum.CBO.Cblinfun_Matrix
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: finite-dim cblinfun and QMat are isomorphic in the CBO bridge. -/
  structure CBOBridgeContract (n : ℕ) where
    A     : CBOSpace (Fin n → ℂ) (Fin n → ℂ)
    M     : QMat
    hDim  : dimRow M = n ∧ dimCol M = n
    hIso  : cblinfunToMatrix A = M
  theorem cboBridgeExists (n : ℕ) : ∃ _ : CBOBridgeContract n, True :=
    ⟨{ A := sorry, M := sorry, hDim := sorry, hIso := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation: `lake build CATEPTMain.Integration.CBOBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-TLA-001  TLA+ model for CBO translation control loop (P3)
Severity: P3 — extends AFP translation error model with CBO-specific classes
New error classes for afp_lean4_translation_error_classes.tla:
  "E22_cblinfun_function_collapse"
    — `cblinfun` emitted as function type `H → H`, NOT as opaque/CLM type
    — remediation: "use_CBOSpace_axiom_phase1"
  "E23_adjoint_notation_conflict"
    — `†` notation defined for cblinfun adjoint, conflicts with IMD dagger
    — remediation: "use_cblinfunAdj_prefix"
  "E24_op_norm_vs_matrix_norm_confusion"
    — operator norm conflated with Frobenius/matrix norm
    — remediation: "use_CBONorm_axiom_not_matNorm"
  "E25_ell2_type_missing"
    — `ell2` Hilbert space type not defined or collapsed to bare list/seq
    — remediation: "define_Ell2_axiom_in_prelude"
New invariant: CblinfunSafe == ∀ thy ∈ THEORIES_CBO: built[thy] =>
  ∀ var ∈ vars[thy]: isCblinfunVar(var) => ¬ isFunctionType(var.type)
Validation: TLC model check: 0 invariant violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-QA-001  Regression checks for CBO translator output (P1)
Severity: P1 — must all pass
Checks:
  1. No cblinfun as function: `grep "(A : .* → .*)" Theories/Complex_Bounded_Linear_Function.lean | wc -l` → 0
  2. No adjoint notation: `grep "notation.*†" Theories/*.lean CBOPrelude.lean | wc -l` → 0
  3. cblinfunAdj defined: `grep "cblinfunAdj\|CBOAdj" CBOPrelude.lean` → ≥1
  4. cblinfunToMatrix present: `grep "cblinfunToMatrix" Theories/Cblinfun_Matrix.lean` → ≥1
  5. opNorm axiom present: `grep "CBONorm\|opNorm" CBOPrelude.lean` → ≥1
  6. No autoImplicit: `grep "autoImplicit true" Theories/*.lean CBOPrelude.lean | wc -l` → 0
  7. Full build: `lake build CATEPTMain.Quantum.CBO` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CBO-QA-002  Faithfulness delta metric for CBO (P2)
Metrics:
  faithful_cblinfun   = 1.0  (CBOSpace opaque, not func-type)
  faithful_adjoint    = 1.0  (CBOAdj axiom present)
  faithful_matrix_iso = 1.0  (cblinfunToMatrix axiom present)
  faithful_proof      = 0.0  (all sorry in phase 1)
Phase-2 targets: faithful_proof ≥ 0.3; replace CBOSpace with ContinuousLinearMap.
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.

/-!
## RS-P1-CBO-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-CBO)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-CBO is DONE, all imports of this module change from
  `CATEPTMain.Quantum.CBO.*`  →  `CATEPTMain.Quantum.CBO.*`
-/
