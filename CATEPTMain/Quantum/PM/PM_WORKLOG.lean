/-!
# PM Translation Worklog — Projective_Measurements → Lean 4
Source: AFP `Projective_Measurements` (Mnacho Echenim — March 3, 2021)
  https://www.isa-afp.org/entries/Projective_Measurements.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.Quantum.PM)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: this worklog follows the tooling lessons of IMD_WORKLOG.lean.
  PRE records must all pass before any .lean theory file is emitted.
  Phase-1 output uses `sorry` proofs; faithful types required from the start.

AFP entry abstract:
  Formalization of quantum projective measurements (von Neumann measurements)
  based on spectral theory. Also formalizes the CHSH inequality — violated by
  quantum measurements, proving quantum mechanics cannot be modeled with a local
  hidden-variable theory.

AFP session file order (for TH record numbering):
  1. Linear_Algebra_Complements
  2. Projective_Measurements
  3. CHSH_Inequality

AFP direct dependencies (bridge required):
  - Isabelle_Marries_Dirac (already bridged via IMDPrelude.lean)
  - QHLProver (Quantum Hoare Logic — bridge axioms required for QHL concepts)
  - HOL standard library (covered by Mathlib)

Used by (downstream AFP):
  - Commuting_Hermitian (simultaneous diagonalization of Hermitian matrices)

Mathlib modules used as semantic targets:
  - Mathlib.Analysis.InnerProductSpace.Projection
  - Mathlib.LinearAlgebra.Projection
  - Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
  - Mathlib.Probability.ProbabilityMassFunction.Basic

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- PM-PRE-* = pre-generation gate items (must all pass before any .lean is emitted)
-- PM-TH-*  = per-theory translation plans (AFP session order)
-- PM-INT-* = integration bridge targets
-- PM-TLA-* = TLA+ model extension targets
-- PM-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-PRE-001  AFP dependency bridge: IMD + QHLProver → Lean 4 (P1)
Severity: P1 — blocker; Projective_Measurements imports both IMD and QHLProver
Context:
  Projective_Measurements directly uses:
    - `cpx_sqr_mat`, `unitary`, `dagger`, gate locale → from IMD (bridged: IMDPrelude.lean)
    - QHLProver: quantum Hoare logic operators (`qs` / quantum state space) — these
      are an *additional* AFP dependency not covered by existing bridges.
  QHLProver concepts needed by PM:
    - `mat_proj` (matrix projection operator)
    - `partial_density_operator` (density matrix: hermitian PSD trace-1 matrix)
    - `well_com` (well-formed quantum command)
  These are used in PM to state "measurement is a projective decomposition of identity".
Strategy:
  Step 1: identify exactly which QHLProver symbols appear in PM session files.
    Run: `grep -r "QHLProver\|qs\|mat_proj\|partial_density" <afp-pm-src>/` after AFP checkout.
  Step 2: emit QHLProver bridge axioms in PMPrelude.lean:
    axiom MatProj (P : QMat) : Prop   -- P is a projection: P² = P, P† = P
    axiom PartialDensityOp (ρ : QMat) : Prop  -- ρ is PSD and Tr(ρ) = 1
  Step 3: IMD bridge: `import CATEPTMain.Quantum.IMD.IMDPrelude`
Key type correspondences:
  cpx_sqr_mat n  →  Matrix (Fin n) (Fin n) ℂ  (via IMD bridge)
  mat_proj P     →  LinearMap.IsProj P  or  axiom MatProj
  density_matrix →  axiom PartialDensityOp (phase 1); phase-2: Mathlib.Analysis.SpecialFunctions
Fix target (translator):
  Do NOT emit QHLProver types as function-typed binders (e.g., `(P : QMat → QMat)`).
  Must be: `(P : QMat) (hProj : MatProj P)`.
Validation:
  - `grep "QHLProver" PMPrelude.lean` → 0 hits (all axiomatized internally)
  - `grep "(: QMat → QMat)" PMPrelude.lean Theories/*.lean` → 0 hits
  - `lake build CATEPTMain.Quantum.PM.PMPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-PRE-002  Prelude-first strategy: PMPrelude.lean (P1)
Severity: P1 — all PM theory files must import PMPrelude before any other PM import
Context:
  Following IMD-PRE-002's lesson, a dedicated PMPrelude.lean is required to:
  (a) import IMDPrelude (for shared IMD types: QMat, QVec, Gate, etc.)
  (b) bridge QHLProver symbols as axioms
  (c) define PM-specific notations and type aliases
  (d) declare set_option autoImplicit false at file scope
Required prelude content (minimal):
  import CATEPTMain.Quantum.IMD.IMDPrelude
  import Mathlib.Analysis.InnerProductSpace.Projection
  set_option autoImplicit false
  namespace CATEPTMain.Quantum.PM
  -- QHLProver bridge axioms
  axiom MatProj : QMat → Prop
  axiom PartialDensityOp : QMat → Prop
  -- Projective observable: family of projections summing to Id
  axiom IsObservable (n : ℕ) (Ps : Fin n → QMat) : Prop
  -- Measurement probability: Tr(Pᵢ ρ Pᵢ†)
  noncomputable axiom measProbPM : QMat → QMat → ℝ
  -- Post-measurement state: Pᵢ ρ Pᵢ† / Tr(...)
  noncomputable axiom postMeasState : QMat → QMat → QMat
  end CATEPTMain.Quantum.PM
Fix target: translator must emit PMPrelude.lean FIRST, before any Theories/ file.
Validation:
  - `lake build CATEPTMain.Quantum.PM.PMPrelude` EXIT:0
  - All Theories/*.lean begin with `import CATEPTMain.Quantum.PM.PMPrelude`
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-PRE-003  Concrete type map: spectral / projection types (P1)
Severity: P1 — type collapse of projection operators is the primary risk
Context:
  AFP `Projective_Measurements` introduces several structured types:
    `proj_op A` : predicate — A is a projector (A² = A ∧ A† = A)
    `observable n` : type — list/family of n projectors summing to identity
    `pvm n` : projection-valued measure (PVM) — the central object
    `chsh_game` : classical structure for CHSH inequality
  The critical risk: emitting `proj_op` as a function type `QMat → QMat` or
    emitting `pvm n` as `List QMat` without the summation invariant.
Type map (translator must encode):
  AFP symbol          Lean 4 phase-1           Lean 4 phase-2
  proj_op A           MatProj A : Prop          (Matrix.IsHermitian A) ∧ (A * A = A)
  observable n Ps     IsObservable n Ps         ∑ i, Ps i = (1 : QMat)  axiom
  pvm n               axiom PVM (n : ℕ) : Type  structure with hSum, hProj fields
  density_matrix ρ    PartialDensityOp ρ        IsPosSemidef ρ ∧ Tr ρ = 1
  exp_value f A ρ     axiom expValue             ∑ i, f i * measProbPM (Ps i) ρ
Strategy:
  Phase-1: axiom all structured types; no opaque type collapse.
  Phase-2: replace with Mathlib.Analysis.InnerProductSpace.Projection structures.
Validation:
  - No `(Ps : QMat → QMat)` binders in Theories/*.lean (IsObservable must be a Prop)
  - `grep "pvm\|observable\|PVM" PMPrelude.lean` → axiom/structure definitions
  - Type map YAML entry for PM added to integration/afp_type_map.yaml
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-PRE-004  Binder-analysis pre-pass: predicate vs object disambiguation (P1)
Severity: P1 — AFP predicates on QMat must not become function binders
Context:
  AFP `Projective_Measurements` uses predicates like `proj_op A`, `hermitian A`,
  `unitary A` as *propositions*, not as object-types or function types.
  Example AFP pattern:
    lemma meas_outcome_proj:
      assumes "proj_op P" and "well_formed_state ρ"
      shows "proj_op (P * ρ * P / Tr (P * ρ))"
  If the translator infers `P : proj_op → QMat`, this produces invalid Lean 4.
  The fix: ALL AFP predicates (`proj_op`, `hermitian`, `well_formed_state`) must
  be emitted as `(P : QMat) (hP : MatProj P)`, never as `(P : proj_op)`.
Binder analysis rules for PM (extend IMD-PRE-004 rules B1-B5):
  B6 — `proj_op A`        → emit as `(A : QMat) (hA : MatProj A)`
  B7 — `well_formed_state ρ` → emit as `(ρ : QMat) (hρ : PartialDensityOp ρ)`
  B8 — `observable n Ps`  → emit as `(Ps : Fin n → QMat) (hObs : IsObservable n Ps)`
  B9 — `chsh_expr a b`    → emit as `(a b : ℝ) (h2 : |a| ≤ 1)` with explicit bounds
  B10 — `pvm n Ps`        → emit as `(Ps : Fin n → QMat) (hPVM : IsPVM n Ps)`
Validation:
  `grep "(: proj_op\|(: observable\|(: pvm" Theories/*.lean` → 0 hits
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-TH-001  Theory: Linear_Algebra_Complements (P2)
AFP file: Projective_Measurements/Linear_Algebra_Complements.thy
Dependency: Jordan_Normal_Form, IMD/Basics
Content summary:
  Auxiliary linear algebra lemmas supporting spectral theory and projections:
  - Hermitian matrices: conjugate symmetry lemmas
  - Positive semidefinite (PSD) matrices: diagonalizability under Hermitian condition
  - Eigenvalue/eigenvector lemmas for small-dimensional cases
  - `mat_add_eq_zero`, `mat_is_zero` decision lemmas
  - Orthogonality results: if Ps are pairwise orthogonal projectors then ∑ Ps = Id
Translation challenge: MEDIUM
  - Most lemmas are direct Mathlib analogs (Matrix.IsHermitian, IsPosSemidef).
  - The `orthogonal_projectors` aggregate theorem requires `Finset.sum` over matrix types.
  - Lean 4: `Finset.sum (Finset.univ) (fun i => Ps i) = (1 : Matrix (Fin n) (Fin n) ℂ)`
  - Phase-1: sorry stubs. Phase-2: reduce via Mathlib.LinearAlgebra.Matrix.PosDef.
Key theorems: mat_hermitian_iff, pos_semidef_iff_eigenvalues_nonneg,
  orthogonal_proj_sum_eq_id, proj_op_comp
Validation:
  - `lake build CATEPTMain.Quantum.PM.Linear_Algebra_Complements` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-TH-002  Theory: Projective_Measurements (P1 — central AFP theory)
AFP file: Projective_Measurements/Projective_Measurements.thy
Dependency: Linear_Algebra_Complements, IMD/Quantum, IMD/Measurement
Content summary:
  The core formalization of projective (von Neumann) measurements:
  - Definition of projection-valued measure (PVM): family {Pᵢ} with Pᵢ² = Pᵢ,
    Pᵢ† = Pᵢ, and ∑ᵢ Pᵢ = Id
  - Measurement postulates: prob(i | ρ) = Tr(Pᵢ ρ)
  - Post-measurement state: Pᵢ ρ Pᵢ† / Tr(Pᵢ ρ)
  - Observable: A = ∑ᵢ λᵢ Pᵢ (spectral decomposition, discrete version)
  - Expected value: ⟨A⟩_ρ = Tr(Aρ)
  - Born rule: Prob(outcome i) = Tr(Pᵢ ρ)
  - Non-selective measurement: post-meas state ρ' = ∑ᵢ Pᵢ ρ Pᵢ†
Translation challenge: HIGH
  REASON 1 — PVM summation invariant:
    `∑ᵢ Pᵢ = Id` over finite projectors requires `Finset.sum` with matrix equality.
    Phase-1: axiom IsPVM_sum. Phase-2: use Matrix.ofRows and diagonal decomp.
  REASON 2 — Trace operator:
    Trace `Tr : QMat → ℂ` must be axiomatized in phase-1. Lean 4 Mathlib has
    `Matrix.trace : Matrix n n α → α`. Bridge: `noncomputable def matTr := Matrix.trace`.
  REASON 3 — Division for post-meas state:
    `postMeasState P ρ = P * ρ * dagger P / Tr (P * ρ)` — complex division.
    In Lean 4: `(1 / matTr (P * ρ)) • (P * ρ * conjTranspose P)` (scalar mult over ℂ).
    Must not emit as: `postMeasState P ρ = matMul P ρ / measProbPM P ρ` (type error).
  REASON 4 — Born rule for composite systems:
    Measurement on subsystem A of (A⊗B) requires partial trace. This is advanced;
    phase-1 may restrict to single-system case.
Key theorem names to preserve (PM-PRE-005 analog):
  pvm_sum_proj, born_rule, post_meas_state_well_formed,
  non_selective_meas_is_psd, observable_expected_value
Validation:
  - `grep "pvm_sum_proj\|born_rule\|post_meas_state" Theories/Projective_Measurements.lean`
  - `lake build CATEPTMain.Quantum.PM.Projective_Measurements` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-TH-003  Theory: CHSH_Inequality (P2)
AFP file: Projective_Measurements/CHSH_Inequality.thy
Dependency: Projective_Measurements
Content summary:
  Formalization of the CHSH inequality and its quantum violation:
  - Classical CHSH bound: |E(a,b) - E(a,b') + E(a',b) + E(a',b')| ≤ 2
    for any local hidden-variable model (classical correlators in [-1,1])
  - Quantum violation: for specific PVM measurements in Bell state,
    the LHS reaches 2√2 > 2 (Tsirelson bound)
  - Conclusion: quantum mechanics cannot be modeled with LHV theory
Translation challenge: HIGH
  REASON 1 — Real-valued expectation inequalities:
    CHSH proof involves |x| ≤ 1 bounds and triangle inequalities over ℝ.
    Lean 4: `abs_le`, `Real.sqrt_two`, norm_num tactics suffice in phase-2.
  REASON 2 — Bell state specific computation:
    The quantum violation uses explicit computation on 2-qubit Bell states and
    specific projection angles (θ = π/8 rotations). Requires:
      `Complex.exp (Complex.I * Real.pi / 4)` and concrete matrix computations.
    Phase-1: sorry stub for the computation. Phase-2: `norm_num` or `decide` for 2×2.
  REASON 3 — Correlation function definition:
    `E(a,b) = ⟨ψ| (σₐ ⊗ σᵦ) |ψ⟩` where σₐ, σᵦ are 2×2 spin-½ observables.
    Must reference IMD gate definitions (Pauli X/Y/Z) + PM measurement framework.
Key theorem names: chsh_inequality_classical (≤ 2), chsh_quantum_violation (= 2√2),
  chsh_implies_no_lhv
Phase-2 upgrade path: reduce quantum violation to `norm_num` + `native_decide` on
  the explicit 4×4 density matrix computation with Bell00 state.
Validation:
  - `grep "chsh_inequality\|no_lhv\|chsh_quantum" Theories/CHSH_Inequality.lean`
  - `lake build CATEPTMain.Quantum.PM.CHSH_Inequality` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-INT-001  Integration bridge: CATEPTMain.Integration.PMBridge (P2)
Severity: P2 — integration contract required for catept-main governance
Target file: CATEPTMain/Integration/PMBridge.lean
Namespace: CATEPTMain.Integration
Content plan:
  import CATEPTMain.Quantum.PM.PMPrelude
  import CATEPTMain.Quantum.PM.Projective_Measurements
  import CATEPTMain.Quantum.IMD.Theories.Quantum
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: a PVM satisfies the Born rule (probabilities sum to 1). -/
  structure PMBridgeContract (n : ℕ) where
    Ps      : Fin n → QMat
    ρ       : QMat
    hPVM    : IsPVM n Ps
    hDens   : PartialDensityOp ρ
    /-- Born rule: ∑ᵢ Tr(Pᵢ ρ) = 1 -/
    hBorn   : ∑ i, measProbPM (Ps i) ρ = 1
  theorem pmBridgeContractExists : ∃ (_ : PMBridgeContract 2), True :=
    ⟨{ Ps := sorry, ρ := sorry, hPVM := sorry, hDens := sorry, hBorn := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation:
  - `lake build CATEPTMain.Integration.PMBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-TLA-001  TLA+ extension for PM translation control loop (P3)
Severity: P3 — extend imd_lean4_translation_control.tla with PM gate
Target: extend/fork the existing IMD TLA+ model for PM module
New CONSTANTS: THEORIES_PM ← {"Linear_Algebra_Complements", "Projective_Measurements", "CHSH_Inequality"}
New invariants to add:
  PVMSumInvariant ==
    ∀ thy ∈ THEORIES_PM: built[thy] =>
      ∀ pvm ∈ pvmDecls[thy]: ¬ isCollapsedToProp(pvm)
  CHSHConstantInvariant ==
    ∀ thy ∈ THEORIES_PM: built[thy] =>
      "2√2" ∈ constantsUsed[thy] ∨ "Real.sqrt 2" ∈ constantsUsed[thy]
  LHVConclusionPresent ==
    built["CHSH_Inequality"] =>
      "chsh_implies_no_lhv" ∈ theoremNames["CHSH_Inequality"]
Validation:
  TLC model check: 0 invariant violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-QA-001  Regression checks for PM translator output (P1)
Severity: P1 — all checks must pass before any PM theory file is committed
Target: scripts/check_pm_output.sh (new script)
Checks:
  1. No predicate-type binders: `grep "(: MatProj\|(: IsObservable\|(: IsPVM" Theories/*.lean | wc -l` → 0
  2. No function-type proj binders: `grep "(P : QMat → QMat)" Theories/*.lean | wc -l` → 0
  3. Trace operator present: `grep "matTr\|Matrix.trace" Theories/Projective_Measurements.lean` → ≥1
  4. Born rule theorem present: `grep "born_rule" Theories/Projective_Measurements.lean` → ≥1
  5. CHSH inequality present: `grep "chsh_inequality" Theories/CHSH_Inequality.lean` → ≥1
  6. No autoImplicit true: `grep "autoImplicit true" Theories/*.lean PMPrelude.lean | wc -l` → 0
  7. Full build: `lake build CATEPTMain.Quantum.PM` EXIT:0
Validation: `scripts/check_pm_output.sh` exits 0 with all 7 checks green.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PM-QA-002  Faithfulness delta metric for PM (P2)
Severity: P2 — track translation quality across phases
Metrics (same scale as IMD-QA-002):
  faithful_stmt   ≥ 0.8  (projectors typed as QMat+prop, not opaque functors)
  faithful_trace  = 1.0  (matTr defined, not opaque black-box)
  faithful_names  = 1.0  (born_rule, chsh_inequality_classical present verbatim)
  faithful_proof  = 0.0  (all sorry in phase 1)
Phase-2 upgrade targets:
  faithful_proof  ≥ 0.4  (CHSH classical bound provable by norm_num)
  faithful_stmt   = 1.0  (all QMat → Matrix (Fin n) (Fin n) ℂ)
Validation: add PM metrics output to `scripts/check_pm_output.sh` summary section.
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.
-- Records are sorted by phase then severity: PRE (P1) → TH (P1/P2) → INT → TLA → QA.

/-!
## RS-P1-PM-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-PM)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-PM is DONE, all imports of this module change from
  `CATEPTMain.Quantum.PM.*`  →  `CATEPTMain.Quantum.PM.*`
-/
