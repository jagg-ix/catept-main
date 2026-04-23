/-!
# SM Translation Worklog — Smooth_Manifolds → Lean 4
Source: AFP `Smooth_Manifolds` (Fabian Immler, Bohua Zhan — October 22, 2018)
  https://www.isa-afp.org/entries/Smooth_Manifolds.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.Geometry.SM)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons.
  SM is INDEPENDENT of all other modules in this batch (no shared AFP deps).
  It use HOL-Analysis extensively. The types-to-sets (TTS) mechanism is used
  throughout — key portability risk.

AFP entry abstract:
  Formalization of smooth manifolds in Isabelle/HOL. Concepts: partition of unity,
  tangent and cotangent spaces, fundamental theorem of path integrals. Concrete
  manifolds: spheres and projective spaces. Extensive use of HOL analysis and
  linear algebra; uses "types-to-sets" mechanism.

AFP session file order (for TH record numbering):
  1.  Analysis_More
  2.  Smooth
  3.  Bump_Function
  4.  Chart
  5.  Topological_Manifold
  6.  Differentiable_Manifold
  7.  Partition_Of_Unity
  8.  Tangent_Space
  9.  Cotangent_Space
  10. Product_Manifold
  11. Sphere
  12. Projective_Space

AFP direct dependencies:
  - HOL-Analysis (standard library, analysis + linear algebra)
  - (types-to-sets uses Isabelle's `Types_To_Sets` mechanism internally)

Used by (downstream AFP):
  - Lie_Groups (Lie groups and algebras)

Mathlib modules used as semantic targets:
  - Mathlib.Geometry.Manifold.SmoothManifoldWithCorners
  - Mathlib.Geometry.Manifold.ContMDiff
  - Mathlib.Geometry.Manifold.VectorBundle.Tangent
  - Mathlib.Topology.PartitionOfUnity
  - Mathlib.Geometry.Manifold.Instances.Sphere
  - Mathlib.Geometry.Manifold.Instances.UnitsOfBoundedLinearMaps

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- SM-PRE-* = pre-generation gate items
-- SM-TH-*  = per-theory translation plans (AFP session order)
-- SM-INT-* = integration bridge targets
-- SM-TLA-* = TLA+ model extension targets
-- SM-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-PRE-001  AFP dependency bridge: manifold type alignment (P1)
Severity: P1 — the manifold type hierarchy is fundamentally different between AFP and Lean 4
Context:
  AFP `Smooth_Manifolds` defines smooth manifolds via:
    - `manifold` typeclass (topological space + charts)
    - `c_manifold k` (k-times differentiable manifold structure on type M)
    - Charts: pairs (U : open set, φ : homeomorphism U → ℝⁿ)
    - Smooth functions: `smooth_on M f` / `smooth M f` (∞-differentiable)
  Lean 4 / Mathlib defines manifolds via:
    - `ModelWithCorners 𝕜 E H` (model space structure replacing Isabelle's `manifold`)
    - `SmoothManifoldWithCorners I M` — the typeclass for smooth manifolds
    - Charts from `ChartedSpace H M` (bundled atlas)
    - Smooth maps: `ContMDiff I I' ∞ f` (∞-continuously differentiable)
  Fundamental mismatch: AFP charts are "open set + homeomorphism"; Lean 4 uses
  a `StructureGroupoid` design with `ModelWithCorners`. They represent the same
  math but the types do NOT match directly.
Strategy:
  Phase-1: Use opaque axiom types:
    axiom SmoothMfd : Type → Type  -- smooth manifold marker
    axiom IsChart (M : Type) (U : Set M) (φ : M → (Fin n → ℝ)) : Prop
    axiom IsSmooth (M N : Type) (f : M → N) : Prop
  Phase-2: Establish bridge:
    When M has `ChartedSpace (EuclideanSpace ℝ (Fin n)) M` and
    `SmoothManifoldWithCorners (modelWithCornersSelf ℝ (EuclideanSpace ℝ (Fin n))) M`,
    then `IsSmooth M N f ↔ ContMDiff (...) f`.
Fix target:
  Do NOT emit AFP `manifold M` as `(M : SmoothManifoldWithCorners I M)` — this is
  a typeclass, not a type. Emit as `[SmoothManifoldWithCorners I M]` or axiom.
Validation:
  - `grep "(M : manifold\|(M : Manifold)" SMPrelude.lean Theories/*.lean | wc -l` → 0
  - `lake build CATEPTMain.Geometry.SM.SMPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-PRE-002  Prelude-first strategy: SMPrelude.lean (P1)
Severity: P1
Required prelude content (skeleton):
  import Mathlib.Geometry.Manifold.SmoothManifoldWithCorners
  import Mathlib.Geometry.Manifold.ContMDiff
  import Mathlib.Topology.PartitionOfUnity
  set_option autoImplicit false
  namespace CATEPTMain.Geometry.SM
  -- Phase-1 opaque manifold markers
  axiom SmoothMfd : Type → Type
  -- Chart predicate: (U, φ) is a valid chart on M around point x to Rⁿ
  axiom IsChart (n : ℕ) {M : Type} (U : Set M) (φ : M → (Fin n → ℝ)) : Prop
  -- Smooth map between manifolds
  axiom IsSmooth {M N : Type} (f : M → N) : Prop
  axiom IsSmoothOn {M N : Type} (f : M → N) (U : Set M) : Prop
  -- Tangent vector and tangent bundle
  axiom TangentVec (M : Type) (p : M) : Type
  axiom TangentBundle (M : Type) : Type
  axiom TangentMap {M N : Type} (f : M → N) (p : M) : TangentVec M p → TangentVec N (f p)
  -- Cotangent vector
  axiom CotangentVec (M : Type) (p : M) : Type
  -- Partition of unity
  axiom SmPartUnity (M : Type) (I : Type) (U : I → Set M) : Type
  end CATEPTMain.Geometry.SM
Validation:
  - `lake build CATEPTMain.Geometry.SM.SMPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-PRE-003  Type map: manifold/smoothness types (P1)
Severity: P1
Type map:
  AFP symbol                Lean 4 phase-1               Lean 4 phase-2
  manifold k M              SmoothMfd M (axiom)           [SmoothManifoldWithCorners I M]
  smooth_on M f U           IsSmoothOn f U                ContMDiffOn I I' ∞ f U
  smooth M f                IsSmooth f                    ContMDiff I I' ∞ f
  tangent_space M p         TangentVec M p (axiom)        TangentSpace I p
  cotangent_space M p       CotangentVec M p (axiom)      (TangentSpace I p →L[ℝ] ℝ)
  partition_of_unity M {Uᵢ} SmPartUnity M I U (axiom)     PartitionOfUnity I M U
  differential f p          TangentMap f p                mfderiv I I' f p
  path integral f γ         axiom PathInt f γ             intervalIntegral (f ∘ γ) 0 1
Notations:
  AFP `Dₚ f` (differential at p) → emit as `TangentMap f p`, NOT as infix `D`.
  AFP `𝒞∞` smoothness → emit as `IsSmooth`, NOT as numeric superscript `∞`.
Validation:
  - No `manifold` as type variable: `grep "(M : manifold\|(M : c_manifold" Theories/*.lean` → 0
  - `grep "SmoothMfd\|IsSmooth" SMPrelude.lean` → ≥1
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-PRE-004  Types-to-sets (TTS) strategy (P1)
Severity: P1 — AFP uses Isabelle's Types_To_Sets throughout; Lean 4 has NO analog
Context:
  AFP `Smooth_Manifolds` uses TTS to transfer results from concrete Euclidean space
  types to abstract types satisfying structural axioms. This is a meta-theory tool
  in Isabelle that has no direct Lean 4 counterpart.
Strategy:
  - IGNORE all TTS boilerplate (axioms, `class_intro`, `unoverload_def` calls)
  - Emit the MATHEMATICAL CONCLUSION THEOREMS only (the "transfer" target)
  - If a TTS result is used in a downstream lemma, emit the downstream lemma with
    `sorry` proof (the type of the statement is still faithful)
  - Document any TTS-dependent theorem with comment: `-- Originally proved via TTS;
    phase-2: re-prove via Mathlib typeclass inference`
Rule:
  B25 — Any AFP theorem with `TTS_intro` or `class_intro` in proof uses TTS.
        Emit theorem with same statement + `sorry` proof. Do NOT emit TTS proof steps.
Validation:
  - `grep "class_intro\|TTS_intro\|unoverload_def" Theories/*.lean | wc -l` → 0
    (no TTS proof machinery in output)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-001  Theory: Analysis_More (P3)
AFP file: Smooth_Manifolds/Analysis_More.thy
Dependency: HOL-Analysis
Content summary:
  Auxiliary analysis lemmas (often filling gaps in AFP's version of HOL-Analysis
  that Lean 4 Mathlib already has). Covers: continuity, differentiability, topology
  on ℝⁿ, manifold-relevant analysis facts.
Translation challenge: LOW
  Most lemmas in Analysis_More are either trivially available in Mathlib or are
  obsolete (superseded by existing Mathlib lemmas). Strategy: audit each lemma
  against Mathlib, emit each either as a `theorem ... := by exact` using Mathlib
  name, or as `sorry` stub if no Mathlib analog exists.
Validation: `lake build CATEPTMain.Geometry.SM.Analysis_More` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-002  Theory: Smooth (P2)
AFP file: Smooth_Manifolds/Smooth.thy
Dependency: Analysis_More
Content summary:
  Core smooth-function definitions on open subsets of normed vector spaces:
  `smooth_on s f` (equivalent to `ContDiffOn ℝ ∞ f s` in Mathlib),
  chain rule for smooth maps, composition of smooth maps.
Translation challenge: MEDIUM
  - `smooth_on s f` ↔ `ContDiffOn ℝ ⊤ f s` in Lean 4 Mathlib.
  - Phase-1: `axiom IsSmoothOn {E : Type} (f : E → E) (s : Set E) : Prop`
  - Phase-2: `def IsSmoothOn f s := ContDiffOn ℝ ⊤ f s`
  - Chain rule: `ContDiffOn.comp` in Mathlib
Key theorems: smooth_on_comp, smooth_const, smooth_id
Validation: `lake build CATEPTMain.Geometry.SM.Smooth` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-003  Theory: Bump_Function (P2)
AFP file: Smooth_Manifolds/Bump_Function.thy
Dependency: Smooth
Content summary:
  Smooth bump functions: compactly supported smooth functions that are 1 on a
  neighborhood of a point. Used in partition of unity construction.
Translation challenge: MEDIUM
  - Lean 4 Mathlib: `ContDiff.exists_smooth_support` or `BumpFunction` class.
  - Phase-1: axiom `HasBumpFn (M : Type) (p : M) (U : Set M) : Prop`
    with axiom `exists_bump_fn : IsOpen U → p ∈ U → HasBumpFn M p U`
  - Phase-2: use `Mathlib.Analysis.SpecialFunctions.Bump.basic`
Key theorem: exists_smooth_bump_function (existence result)
Validation: `lake build CATEPTMain.Geometry.SM.Bump_Function` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-004  Theory: Chart (P1 — core chart structure)
AFP file: Smooth_Manifolds/Chart.thy
Dependency: Smooth
Content summary:
  Chart definition for topological/smooth manifolds: homeomorphism from open set
  to open subset of model space. Chart transitions (overlap maps). Atlas.
Translation challenge: HIGH
  REASON 1 — AFP vs Mathlib chart structure:
    AFP: chart = (source : open set) + (φ : homeomorphism source → model_space)
    Lean 4: chart = `LocalHomeomorph M H` (partial homeomorphism); atlas = structure
      groupoid. The AFP "source" is Mathlib's `LocalHomeomorph.source`.
    Phase-1: `axiom Chart (M : Type) (n : ℕ) : Type` with:
      `axiom chartSource : Chart M n → Set M`
      `axiom chartMap : Chart M n → M → (Fin n → ℝ)`
  REASON 2 — Chart compatibility (transition maps):
    AFP: `c_manifold_chart_trans φ₁ φ₂` = smooth transition map.
    Lean 4: encoded in `StructureGroupoid.compatible`.
    Phase-1: axiom `ChartCompatible : Chart M n → Chart M n → Prop`.
Key theorems: chart_cover_is_open, chart_transition_smooth, atlas_closed_under_comp
Validation:
  - `grep "Chart\|chartSource\|chartMap" SMPrelude.lean Theories/Chart.lean` → ≥1 each
  - `lake build CATEPTMain.Geometry.SM.Chart` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-005  Theory: Topological_Manifold (P2)
AFP file: Topological_Manifolds/Topological_Manifold.thy
Dependency: Chart
Content summary:
  Topological manifolds (C⁰ = continuous): locally homeomorphic to ℝⁿ,
  Hausdorff, second countable. Paracompactness.
Translation challenge: MEDIUM
  - Lean 4 Mathlib: `TopologicalManifold H M` or `ChartedSpace H M` + Hausdorff + σ-compact.
  - Phase-1: axiom `IsTopManifold (n : ℕ) (M : Type) : Prop`
Key theorems: top_manifold_is_hausdorff, top_manifold_paracompact
Validation: `lake build CATEPTMain.Geometry.SM.Topological_Manifold` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-006  Theory: Differentiable_Manifold (P1 — central smooth manifold construction)
AFP file: Smooth_Manifolds/Differentiable_Manifold.thy
Dependency: Chart, Topological_Manifold, Smooth
Content summary:
  Smooth (C∞) manifolds: compatible smooth atlas, smooth functions between manifolds,
  smooth maps (C∞(M,N)), diffeomorphisms.
Translation challenge: HIGH
  - Phase-1: `axiom IsSmoothMfd (n : ℕ) (M : Type) : Prop` (Cⁿ manifold predicate)
  - Phase-2: `instance IsSmoothMfd_of_Mathlib [SmoothManifoldWithCorners I M] : IsSmoothMfd n M`
  - Key lemma: `smooth_iff_char_smooth` (global smoothness ↔ smooth in every chart pair)
Key theorems: smooth_mfd_hausdorff, smooth_comp, smooth_iff_locally_smooth,
  smooth_invariant_under_diffeo
Validation:
  - `grep "IsSmoothMfd\|IsSmoothOn\|IsSmooth" Theories/Differentiable_Manifold.lean` → ≥1
  - `lake build CATEPTMain.Geometry.SM.Differentiable_Manifold` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-007  Theory: Partition_Of_Unity (P2)
AFP file: Smooth_Manifolds/Partition_Of_Unity.thy
Dependency: Differentiable_Manifold, Bump_Function
Content summary:
  Existence of smooth partitions of unity on smooth manifolds (using bump functions).
  Key: for any open cover {Uᵢ}, there exists a smooth partition of unity subordinate to it.
  Used in gluing constructions (extend local objects globally).
Translation challenge: MEDIUM
  - Lean 4 Mathlib: `PartitionOfUnity.exists_isSubordinate_of_locallyFinite`
  - Phase-1: axiom `ExistsPartUnity (M : Type) (n : ℕ) (Uα : I → Set M) : Prop`
  - Phase-2: use Mathlib.Topology.PartitionOfUnity
Key theorem: smooth_partition_of_unity_exists
Validation: `lake build CATEPTMain.Geometry.SM.Partition_Of_Unity` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-008  Theories: Tangent_Space + Cotangent_Space (P2)
AFP files: Tangent_Space.thy, Cotangent_Space.thy
Dependency: Differentiable_Manifold
Content summary:
  - Tangent_Space: tangent vectors at p ∈ M as derivations on C∞(M); tangent bundle TM;
    differential df_p : TₚM → T_{f(p)}N; pushforward
  - Cotangent_Space: dual of tangent space; 1-forms on M; pullback; df : cotangent form
Translation challenge: HIGH
  - AFP tangent vectors as derivations: a bespoke algebraic construction.
  - Lean 4 Mathlib: `TangentSpace I p` defined as `(TangentBundle I M).fiberAt p`
    using vector bundle structure.
  - The derivation characterization is NOT directly available in Mathlib's tangent space.
  - Phase-1: emit tangent vectors as axiom types; pullback/pushforward as axioms.
  - Phase-2: connect via `mfderiv I I' f p` (Mathlib's manifold derivative).
Key theorems: tangent_linear_map, tangent_comp_chain_rule, cotangent_duality,
  fundamental_theorem_path_integral
Validation:
  - `grep "TangentVec\|TangentMap\|CotangentVec" Theories/Tangent_Space.lean` → ≥1
  - `lake build CATEPTMain.Geometry.SM.Tangent_Space` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TH-009  Theories: Product_Manifold + Sphere + Projective_Space (P3)
AFP files: Product_Manifold.thy, Sphere.thy, Projective_Space.thy
Dependency: Differentiable_Manifold, Partition_Of_Unity
Content summary:
  Concrete manifold constructions:
  - Product_Manifold: M × N is a smooth manifold; product charts
  - Sphere: Sⁿ ⊆ ℝⁿ⁺¹ is a smooth manifold; stereographic charts
  - Projective_Space: ℝPⁿ = ℝⁿ⁺¹ \ {0} / ℝ* is a smooth manifold
Translation challenge: MEDIUM
  - Lean 4 Mathlib: `Mathlib.Geometry.Manifold.Instances.Sphere` has Sⁿ manifold instance.
  - Product manifold: `Prod.chartedSpace` in Mathlib.
  - Projective space: `Mathlib.Geometry.ProjectiveSpace` (if available).
  Phase-1: sorry-stubs for concrete manifold instances. Phase-2: Mathlib instances.
Batch note: merge three files into Theories/Concrete_Manifolds.lean for efficiency.
Validation: `lake build CATEPTMain.Geometry.SM.Concrete_Manifolds` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-INT-001  Integration bridge: CATEPTMain.Integration.SMBridge (P2)
Severity: P2
Target file: CATEPTMain/Integration/SMBridge.lean
Content plan:
  import CATEPTMain.Geometry.SM.SMPrelude
  import CATEPTMain.Geometry.SM.Differentiable_Manifold
  import CATEPTMain.Geometry.SM.Tangent_Space
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: a smooth manifold has a tangent bundle. -/
  structure SMBridgeContract (n : ℕ) (M : Type) where
    hMfd  : IsSmoothMfd n M
    /-- Tangent map of identity is identity -/
    hId   : ∀ (p : M), TangentMap (@id M) p = @id (TangentVec M p)
  theorem smBridgeExists : ∃ _ : SMBridgeContract 2 (Fin 2 → ℝ), True :=
    ⟨{ hMfd := sorry, hId := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation: `lake build CATEPTMain.Integration.SMBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-TLA-001  TLA+ model for SM translation control loop (P3)
New error classes:
  "E29_manifold_as_type_not_class"
    — manifold M emitted as regular type variable instead of typeclass
    — remediation: "use_SmoothMfd_axiom_pred"
  "E30_tts_boilerplate_in_output"
    — TTS proof machinery (class_intro, unoverload_def) appears in output
    — remediation: "strip_tts_emit_conclusion_only"
  "E31_chart_homeomorphism_type_error"
    — chart emitted as plain function M → Rⁿ, not as LocalHomeomorph
    — remediation: "use_Chart_axiom_type"
New invariant: NoTTSBoilerplate == ∀ thy ∈ THEORIES_SM: built[thy] =>
  "class_intro" ∉ proofTerms[thy] ∧ "unoverload_def" ∉ proofTerms[thy]
Validation: TLC model check: 0 invariant violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-QA-001  Regression checks for SM translator output (P1)
Checks:
  1. No TTS boilerplate: `grep "class_intro\|unoverload_def\|TTS_intro" Theories/*.lean | wc -l` → 0
  2. Manifold predicate present: `grep "IsSmoothMfd\|SmoothMfd" SMPrelude.lean` → ≥1
  3. Chart axiom: `grep "IsChart\|Chart\|chartMap" SMPrelude.lean Theories/Chart.lean` → ≥1
  4. Tangent bundle: `grep "TangentVec\|TangentBundle" SMPrelude.lean` → ≥1
  5. No chart as plain function: `grep "(φ : M → ℝ\|(φ :.*→.*Fin.*→.*ℝ)" Theories/Chart.lean | wc -l` → 0
  6. No autoImplicit: `grep "autoImplicit true" Theories/*.lean SMPrelude.lean | wc -l` → 0
  7. Full build: `lake build CATEPTMain.Geometry.SM` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SM-QA-002  Faithfulness delta metric for SM (P2)
Metrics:
  faithful_mfd_type   = 1.0  (IsSmoothMfd predicate, not function type)
  faithful_charts     = 1.0  (Chart axiom type, not plain function)
  faithful_tts_clean  = 1.0  (no TTS proof boilerplate in output)
  faithful_proof      = 0.0  (all sorry in phase-1)
Phase-2 targets: faithful_proof ≥ 0.3 using Mathlib manifold typeclasses.
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.

/-!
## RS-P1-SM-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-SM)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-SM is DONE, all imports of this module change from
  `CATEPTMain.Geometry.SM.*`  →  `CATEPTMain.Geometry.SM.*`
-/
