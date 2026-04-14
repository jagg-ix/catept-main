/-!
# CPM Translation Worklog — Coproduct_Measure → Lean 4
Source: AFP `Coproduct_Measure` (Michikazu Hirata — June 4, 2024)
  https://www.isa-afp.org/entries/Coproduct_Measure.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.CPM)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons.
  CPM is purely measure-theoretic — independent of quantum modules.
  Key novelty: coproduct (disjoint sum) of measures, as opposed to product.

AFP entry abstract:
  Formalizes the coproduct measure. Given index set I and measurable spaces {Mᵢ}ᵢ∈ᵢ,
  defines σ-algebra on ∐ᵢ∈ᵢ Mᵢ = {(i,x) | i ∈ I, x ∈ Mᵢ} as the least σ-algebra
  making all (λx.(i,x)) measurable. Defines coproduct measure ∐ᵢ μᵢ from component
  measures μᵢ. Proves measurability and measure properties.

AFP session file order (for TH record numbering):
  1. Lemmas_Coproduct_Measure
  2. Coproduct_Measure
  3. Coproduct_Measure_Additional

AFP direct dependencies:
  - S_Finite_Measure_Monad (AFP entry — s-finite measures and quasi-Borel spaces)
  - HOL-Probability (standard AFP/Isabelle)

Used by (downstream AFP): none listed (standalone)

Mathlib modules used as semantic targets:
  - Mathlib.MeasureTheory.Measure.MeasureSpace
  - Mathlib.MeasureTheory.Measure.Sum  (MeasureTheory.Measure.sum)
  - Mathlib.MeasureTheory.MeasurableSpace.Basic
  - Mathlib.MeasureTheory.Measure.Disjoint

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- CPM-PRE-* = pre-generation gate items
-- CPM-TH-*  = per-theory translation plans (AFP session order)
-- CPM-INT-* = integration bridge targets
-- CPM-TLA-* = TLA+ model extension targets
-- CPM-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-PRE-001  AFP dependency bridge: S_Finite_Measure_Monad → Lean 4 (P1)
Severity: P1 — CPM depends on S_Finite_Measure_Monad (s-finite measures)
Context:
  AFP Coproduct_Measure imports `S_Finite_Measure_Monad`, which defines:
    - `s_finite_measure S μ`: measure μ is a countable sum of finite measures
    - Quasi-Borel spaces (probability monads)
  The coproduct measure is s-finite when components are s-finite.
  In Lean 4 Mathlib: no direct `s_finite_measure` typeclass exists in Mathlib 4.x.
  Closest: `MeasureTheory.SFinite` typeclass in recent Mathlib (4.7+).
Strategy:
  Step 1: Check if `MeasureTheory.SFinite` exists in pinned Mathlib version.
    Run: `grep -r "SFinite" ~/.elan/toolchains/*/lib/lean/Mathlib/MeasureTheory/` after build.
  Step 2a (SFinite available): use `[MeasureTheory.SFinite μ]` directly.
  Step 2b (not available): axiom `IsSFinite : MeasureTheory.Measure α → Prop`
    with axiom `IsSFinite_sum : (∀ n, IsFiniteMeasure (μ n)) → IsSFinite (∑' n, μ n)`.
  Quasi-Borel spaces: phase-1 axiom stubs only; do NOT attempt full formalization.
Key type correspondences:
  AFP `s_finite_measure S μ`   →  `IsSFinite μ : Prop` (phase-1 axiom)
  AFP `coproduct_sigma_algebra` →  `MeasurableSpace.map (Sum.inr) inferInstance` (phase-2)
  AFP `coproduct_measure`       →  axiom `coprodMeasure : (I → Measure) → Measure`
  AFP disjoint union ∐ᵢ Mᵢ     →  `Σ i : I, αᵢ` (Sigma type in Lean 4)
Fix target:
  AFP `(λx.(i,x))` injection maps → use `Sigma.mk i : α i → (Σ i, α i)` in Lean 4.
  Do NOT emit `(i,x)` as a pair `(Prod.mk i x)` — must be `(Sigma.mk i x)`.
Validation:
  - `grep "Prod.mk.*inject\|Sum.inl\|Sum.inr" CPMPrelude.lean Theories/*.lean | wc -l` →
    0 unless intentional (coproduct uses Sigma type, not Sum type for the domain)
  - `lake build CATEPTMain.AFPBridge.CPM.CPMPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-PRE-002  Prelude-first strategy: CPMPrelude.lean (P1)
Severity: P1
Required prelude content (skeleton):
  import Mathlib.MeasureTheory.Measure.MeasureSpace
  import Mathlib.MeasureTheory.Measure.Sum
  import Mathlib.MeasureTheory.MeasurableSpace.Basic
  set_option autoImplicit false
  namespace CATEPTMain.AFPBridge.CPM
  -- s-finite measure predicate
  axiom IsSFinite {α : Type} (μ : MeasureTheory.Measure α) : Prop
  -- Coproduct σ-algebra: on Σ i : I, α i
  -- (In Lean 4, the sigma type Σ i : I, α i carries a MeasurableSpace instance
  --  from the injection maps; see MeasureTheory.MeasureSpace.sigma)
  axiom CoprodSigmaAlg {I : Type} {α : I → Type}
    (mI : MeasureTheory.MeasurableSpace I)
    (m : ∀ i, MeasureTheory.MeasurableSpace (α i)) :
    MeasureTheory.MeasurableSpace (Σ i : I, α i)
  -- Coproduct measure
  noncomputable axiom coprodMeasure {I : Type} {α : I → Type}
    (μ : ∀ i, MeasureTheory.Measure (α i)) :
    MeasureTheory.Measure (Σ i : I, α i)
  -- Key axiom: injection measurability
  axiom coprodMeasure_injection_measurable {I : Type} {α : I → Type}
    (μ : ∀ i, MeasureTheory.Measure (α i)) (i : I) :
    MeasureTheory.Measurable (Sigma.mk i : α i → Σ j : I, α j)
  end CATEPTMain.AFPBridge.CPM
Validation:
  - `lake build CATEPTMain.AFPBridge.CPM.CPMPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-PRE-003  Type map: coproduct vs product measure disambiguation (P1)
Severity: P1 — coproduct measure must NOT be confused with the product measure
Context:
  This AFP entry defines the COPRODUCT (disjoint sum) measure, which is DIFFERENT
  from the product measure (∫∫ ... dμ₁ dμ₂).
  AFP: `coproduct_measure {μ}` on `∐ᵢ Mᵢ` = sum of component measures after injection.
  Vs:  `product_measure μ₁ μ₂` on `M₁ × M₂` = Fubini/Tonelli product.
  In Lean 4 Mathlib:
    - Coproduct: `MeasureTheory.Measure.sum` — infinite sum of measures on disjoint pieces
    - Product: `MeasureTheory.Measure.prod` — product measure on M₁ × M₂
Type map:
  AFP symbol                      Lean 4 phase-1                Lean 4 phase-2
  coproduct_measure {μᵢ}          coprodMeasure μ (axiom)        MeasureTheory.Measure.sum ...
  coproduct_sigma_algebra         CoprodSigmaAlg mI m (axiom)    MeasurableSpace on Σ type
  ∐ᵢ Mᵢ (domain type)            Σ i : I, αᵢ                    (Lean 4 built-in Sigma type)
  injection (λx.(i,x))           Sigma.mk i                      (no change in phase-2)
  s_finite_measure μ             IsSFinite μ                      MeasureTheory.SFinite μ
  measurable_of_injection         coprodMeasure_injection_measurable  (axiom)
Watchout: do NOT use `Sum.inl` / `Sum.inr` for the injections.
  `Sum` is the binary sum type (like `Either` in Haskell).
  `Sigma` is the dependent sum type (the correct analog of ∐ᵢ Mᵢ for variable types).
Validation:
  - `grep "Sum.inl\|Sum.inr" Theories/*.lean | wc -l` → 0 (unless testing binary sum)
  - `grep "Sigma.mk" CPMPrelude.lean Theories/*.lean` → ≥1
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-TH-001  Theory: Lemmas_Coproduct_Measure (P3)
AFP file: Coproduct_Measure/Lemmas_Coproduct_Measure.thy
Dependency: S_Finite_Measure_Monad, HOL-Probability
Content summary:
  Auxiliary lemmas for the coproduct measure construction:
  - Measurability of sigma-type injections
  - s-finite measure facts
  - Indicator function measurability on disjoint unions
  - Sigma-finite to s-finite relationships
Translation challenge: LOW-MEDIUM
  - Most lemmas are measure-theoretic bookkeeping.
  - Key: `indicator` function measurability → `MeasureTheory.Measurable.indicator`
  - Phase-1: sorry stubs. Phase-2: most reduce to Mathlib sigma-algebra lemmas.
Validation: `lake build CATEPTMain.AFPBridge.CPM.Theories.Lemmas_Coproduct_Measure` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-TH-002  Theory: Coproduct_Measure (P1 — main theory)
AFP file: Coproduct_Measure/Coproduct_Measure.thy
Dependency: Lemmas_Coproduct_Measure
Content summary:
  The main coproduct measure construction:
  1. σ-algebra definition on ∐ᵢ Mᵢ: least making all (λx.(i,x)) measurable
  2. Coproduct measure ∐ᵢ μᵢ: measures A ∩ injection_i as μᵢ(preimage)
  3. Key property: ∐ᵢ μᵢ (injection_i A) = μᵢ(A) for measurable A
  4. Total measure: ∐ᵢ μᵢ (∐ᵢ Mᵢ) = ∑ᵢ μᵢ(Mᵢ)
  5. Coproduct of s-finite measures is s-finite
  6. Measurable functions via coproduct: f : ∐ Mᵢ → N is measurable iff all f ∘ injᵢ are
Translation challenge: HIGH
  REASON 1 — Sigma type vs. union type:
    AFP uses set-theoretic disjoint union `∐ᵢ Mᵢ = {(i,x)}`.
    Lean 4: `Σ i : I, α i` is the dependent sum type; injections are `Sigma.mk i`.
    Property: `∀ x : Σ i, α i, ∃! i, x.1 = i` is automatic by Lean 4 type structure.
  REASON 2 — Defining measure on sigma type:
    `coprodMeasure μ A = ∑ᵢ μᵢ {x | Sigma.mk i x ∈ A}` (Lean 4 formulation).
    Phase-1: axiom with `coprodMeasure_injection` axiom as key property.
    Phase-2: Use `MeasureTheory.Measure.sum` extended to families indexed by I.
  REASON 3 — Universal property (measurability characterization):
    `f : Σ i, α i → N measurable ↔ ∀ i, Measurable (fun x => f ⟨i, x⟩)`
    This is the coproduct's universal property in the measure category.
    Phase-1: axiom `coprodMeasure_universal`.
Key theorems: coprodMeasure_injection_eq, coprodMeasure_total, coprodMeasure_sfin,
  coprodMeasure_measurable_iff
Validation:
  - `grep "coprodMeasure_injection_eq\|coprodMeasure_sfin" Theories/Coproduct_Measure.lean` → ≥1
  - `lake build CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-TH-003  Theory: Coproduct_Measure_Additional (P2)
AFP file: Coproduct_Measure/Coproduct_Measure_Additional.thy
Dependency: Coproduct_Measure
Content summary:
  Extension lemmas for the coproduct measure:
  - Integration formula: ∫ (∐ᵢ μᵢ) f = ∑ᵢ ∫ μᵢ (f ∘ injᵢ)
  - Coproduct measure and Fubini interactions
  - Pullback/pushforward measurability under injections
Translation challenge: MEDIUM
  - Integration formula: `MeasureTheory.lintegral_sum_measure` in Mathlib.
  - Phase-1: axiom `coprodMeasure_integral_eq`.
  - Phase-2: reduce to Mathlib.MeasureTheory.Integral.Lebesgue lintegral_sum.
Key theorems: coprodMeasure_integral, coprodMeasure_pushforward_inj
Validation: `lake build CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure_Additional` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-INT-001  Integration bridge: CATEPTMain.Integration.CPMBridge (P2)
Target file: CATEPTMain/Integration/CPMBridge.lean
Content plan:
  import CATEPTMain.AFPBridge.CPM.CPMPrelude
  import CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: coproduct measure correctly sums component measures. -/
  structure CPMBridgeContract {I : Type} {α : I → Type}
      (μ : ∀ i, MeasureTheory.Measure (α i)) where
    /-- Injection property: coprod measure on injected set equals component measure -/
    hInj : ∀ (i : I) (A : Set (α i)), coprodMeasure μ (Sigma.mk i '' A) = μ i A
  theorem cpmBridgeExists : ∃ (_ : CPMBridgeContract (fun _ : Fin 2 => MeasureTheory.volume)), True :=
    ⟨{ hInj := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation: `lake build CATEPTMain.Integration.CPMBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-TLA-001  TLA+ model for CPM translation control loop (P3)
New error classes:
  "E35_coproduct_vs_product_confusion"
    — coprodMeasure conflated with MeasureTheory.Measure.prod (product measure)
    — remediation: "use_coprodMeasure_axiom_not_prod"
  "E36_sum_vs_sigma_type_confusion"
    — disjoint union ∐ᵢ Mᵢ emitted as Sum type (Sum.inl/Sum.inr) not Sigma type
    — remediation: "use_Sigma_type_Sigma.mk"
  "E37_s_finite_missing"
    — IsSFinite predicate missing, measure axioms reference it as free variable
    — remediation: "add_IsSFinite_axiom_in_CPMPrelude"
New invariants:
  CPMNoProdConfusion == ∀ thy ∈ THEORIES_CPM: built[thy] =>
    "Measure.prod" ∉ coprodRelatedDefs[thy]
  CPMSigmaType == ∀ thy ∈ THEORIES_CPM: built[thy] =>
    ∀ domain ∈ coprodDomains[thy]: isSigmaType(domain)
Validation: TLC model check: 0 violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-QA-001  Regression checks for CPM translator output (P1)
Checks:
  1. No product measure confusion: `grep -w "Measure.prod" Theories/*.lean | wc -l` → 0
  2. Sigma.mk used for injections: `grep "Sigma.mk" CPMPrelude.lean Theories/*.lean` → ≥1
  3. coprodMeasure axiom: `grep "coprodMeasure" CPMPrelude.lean` → ≥1
  4. IsSFinite predicate: `grep "IsSFinite\|SFinite" CPMPrelude.lean` → ≥1
  5. injection axiom: `grep "coprodMeasure_injection" CPMPrelude.lean Theories/Coproduct_Measure.lean` → ≥1
  6. No autoImplicit: `grep "autoImplicit true" Theories/*.lean CPMPrelude.lean | wc -l` → 0
  7. Full build: `lake build CATEPTMain.AFPBridge.CPM` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## CPM-QA-002  Faithfulness delta metric for CPM (P2)
Metrics:
  faithful_sigma    = 1.0  (disjoint union as Σ type, not Sum)
  faithful_sfin     = 1.0  (IsSFinite as Prop predicate)
  faithful_coprod   = 1.0  (coprodMeasure axiom correctly typed)
  faithful_proof    = 0.0  (all sorry in phase-1)
Phase-2 targets: faithful_proof ≥ 0.6 (most reduce directly to MeasureTheory.Measure.sum)
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.
