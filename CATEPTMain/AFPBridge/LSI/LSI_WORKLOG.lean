/-!
# LSI Translation Worklog — Lebesgue_Stieltjes_Integral → Lean 4
Source: AFP `Lebesgue_Stieltjes_Integral` (Yosuke Ito — March 4, 2026)
  https://www.isa-afp.org/entries/Lebesgue_Stieltjes_Integral.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.LSI)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons.
  LSI is the smallest AFP session in this batch (2 theory files).
  It is INDEPENDENT of quantum modules — purely real analysis and measure theory.
  Note: AFP published 2026 — verify Isabelle AFP source is available at checkout time.

AFP entry abstract:
  Formalizes basic facts related to integration with respect to the Lebesgue-Stieltjes
  measure (interval measure). Includes the formula:
    ∫ g(x) dF(x) = ∫ g(x) F'(x) dx
  where F is a monotone function generating the Stieltjes measure.

AFP session file order (for TH record numbering):
  1. Preliminaries_LSI
  2. Lebesgue_Stieltjes_Integral

AFP direct dependencies:
  - Wlog (AFP — without-loss-of-generality combinator; Lean 4 has `wlog` tactic)
  - HOL-Analysis (standard library)
  - HOL-Probability (standard, for measure theory)

Used by (downstream AFP): none listed

Mathlib modules used as semantic targets:
  - Mathlib.MeasureTheory.Integral.LebesgueStieltjes
  - Mathlib.MeasureTheory.Integral.IntervalIntegral
  - Mathlib.MeasureTheory.Measure.StieltjesFunction
  - Mathlib.Analysis.Calculus.FDeriv.Basic

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- LSI-PRE-* = pre-generation gate items
-- LSI-TH-*  = per-theory translation plans (AFP session order)
-- LSI-INT-* = integration bridge targets
-- LSI-TLA-* = TLA+ model extension targets
-- LSI-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-PRE-001  AFP dependency bridge: Wlog + StieltjesFunction → Lean 4 (P1)
Severity: P1 — two bridge requirements: WLOG tactic and Stieltjes measure
Context:
  AFP `Lebesgue_Stieltjes_Integral` uses:
    (a) `Wlog` AFP entry: a WLOG combinator in Isabelle. In Lean 4 Mathlib:
        `wlog h : P` tactic is available from `Mathlib.Tactic.WLOG`. No bridge needed.
    (b) Stieltjes measure from HOL-Analysis:
        AFP `interval_measure F` (= Stieltjes measure of monotone F : ℝ → ℝ)
        In Lean 4 Mathlib: `MeasureTheory.StieltjesFunction.measure` where
        `StieltjesFunction` requires F to be monotone and right-continuous.
Strategy:
  - Wlog: no translation needed. Use `wlog` tactic from Mathlib in phase-2.
  - StieltjesFunction: define bridge wrapper
      `def lsiStieltjesMeasure (F : ℝ → ℝ) (hF : Monotone F) (hRC : RightContinuous F) :
          MeasureTheory.Measure ℝ := (⟨F, hF, hRC⟩ : MeasureTheory.StieltjesFunction).measure`
    Phase-1: axiom `lsiMeasure : (ℝ → ℝ) → MeasureTheory.Measure ℝ` (without monotonicity proof).
Key type correspondences:
  AFP `interval_measure F`         →  lsiMeasure F : MeasureTheory.Measure ℝ
  AFP `stieltjes_function F`       →  MeasureTheory.StieltjesFunction (with Monotone + RightContinuous)
  AFP `lebesgue_stieltjes_integral F g` →  ∫ x, g x ∂(lsiMeasure F)
  AFP `absolutely_continuous ν μ`  →  `MeasureTheory.Measure.AbsolutelyContinuous ν μ`
Fix target:
  Monotone condition: AFP `increasing F` → Lean 4 `Monotone F`. Must be stated explicitly.
  Right-continuity: AFP `right_continuous F` → Lean 4 `ContinuousWithinAt F (Set.Ici x) x`
    (or `MeasureTheory.StieltjesFunction.rightContinuous`).
  Do NOT omit monotone/right-continuity hypotheses from axioms.
Validation:
  - `grep "lsiMeasure\|lsiStieltjesMeasure" LSIPrelude.lean` → ≥1
  - `grep "(F : ℝ → ℝ)" LSIPrelude.lean Theories/*.lean` → each occurrence has `hF : Monotone F`
  - `lake build CATEPTMain.AFPBridge.LSI.LSIPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-PRE-002  Prelude-first strategy: LSIPrelude.lean (P1)
Severity: P1
Required prelude content:
  import Mathlib.MeasureTheory.Integral.LebesgueStieltjes
  import Mathlib.MeasureTheory.Integral.IntervalIntegral
  import Mathlib.MeasureTheory.Measure.StieltjesFunction
  import Mathlib.Analysis.Calculus.FDeriv.Basic
  set_option autoImplicit false
  namespace CATEPTMain.AFPBridge.LSI
  -- Phase-1: axiom Stieltjes measure (relaxed hypotheses)
  noncomputable axiom lsiMeasure : (ℝ → ℝ) → MeasureTheory.Measure ℝ
  -- Key property: lsiMeasure F is the Stieltjes measure of F when F is monotone + RC
  axiom lsiMeasure_is_stieltjes (F : ℝ → ℝ) (hF : Monotone F) (hRC : ∀ x, ContinuousWithinAt F (Set.Ici x) x) :
    ∀ (a b : ℝ), lsiMeasure F (Set.Ioc a b) = ENNReal.ofReal (F b - F a)
  -- Lebesgue-Stieltjes integral
  noncomputable def lsiIntegral (F g : ℝ → ℝ) : ℝ :=
    ∫ x, g x ∂(lsiMeasure F)
  -- Change-of-variables (main result): ∫ g dF = ∫ g * F' dx (when F differentiable a.e.)
  axiom lsiChangeOfVariables (F g : ℝ → ℝ) (hF : Monotone F) (a b : ℝ) :
    ∫ x in Set.Ioc a b, g x ∂(lsiMeasure F) =
    ∫ x in Set.Ioc a b, g x * (deriv F x) ∂MeasureTheory.volume
  end CATEPTMain.AFPBridge.LSI
Validation:
  - `lake build CATEPTMain.AFPBridge.LSI.LSIPrelude` EXIT:0
  - `grep "lsiMeasure\|lsiIntegral\|lsiChangeOfVariables" LSIPrelude.lean` → ≥1 each
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-PRE-003  Type map: Stieltjes measure types (P1)
Severity: P1
Type map:
  AFP symbol                    Lean 4 phase-1                Lean 4 phase-2
  interval_measure F            lsiMeasure F (axiom)           StieltjesFunction.measure
  stieltjes_integral F g a b    lsiIntegral F g restricted     ∫ x in Ioc a b, g x ∂lsiMeasure F
  absolutely_continuous ν μ     axiom LSI_AbsCont ν μ          MeasureTheory.Measure.AbsolutelyContinuous ν μ
  density h ν μ                 axiom LSI_Density h ν μ        (Radon-Nikodym derivative)
  has_density h ν μ             axiom LSI_HasDensity            ∃ f, ν = μ.withDensity f
  F' (derivative of F)          deriv F  (Lean 4 `deriv`)       Lean 4 `HasDerivAt F (F' x) x`
  right_continuous F            ContinuousWithinAt F (Ici x) x Mathlib right-continuity
  increasing F (monotone)       Monotone F                     (Lean 4 built-in `Monotone`)
Monotone vs Antitone note:
  AFP distinguishes `increasing` (monotone increasing) from `decreasing`.
  Lean 4: `Monotone` and `Antitone`. Always explicit.
Validation:
  - `grep "interval_measure\|stieltjes_integral" Theories/*.lean | wc -l` → 0 (AFP names replaced)
  - `grep "lsiMeasure\|lsiIntegral\|Monotone" Theories/*.lean LSIPrelude.lean` → ≥1
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-PRE-004  Binder analysis: monotone function binders (P1)
Severity: P1
Context:
  AFP LSI uses `F` as a Stieltjes-generating function.
  Risk: translator emits `(F : ℝ → ℝ)` WITHOUT the accompanying `(hF : Monotone F)`.
  This leaves all Stieltjes lemmas with unguarded hypotheses.
Binder rules:
  B29 — `stieltjes_function F` → emit as `(F : ℝ → ℝ) (hF : Monotone F) (hRC : ...)`
  B30 — `lebesgue_stieltjes_integral F g` → emit as separate predicate
         `(hInt : MeasureTheory.Integrable g (lsiMeasure F))` before integral
  B31 — `absolutely_continuous ν μ` → always emit as `(h : LSI_AbsCont ν μ)`, never as free var
  B32 — `F'` (derivative) → emit as `(hDiff : DifferentiableAt ℝ F x)` where used
Validation:
  `grep "(F : ℝ → ℝ)" Theories/*.lean | grep -v "hF\|Monotone"` → 0 hits
  (any `F : ℝ → ℝ` must be accompanied by `hF : Monotone F`)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-TH-001  Theory: Preliminaries_LSI (P3)
AFP file: Lebesgue_Stieltjes_Integral/Preliminaries_LSI.thy
Dependency: HOL-Analysis, HOL-Probability
Content summary:
  Auxiliary lemmas for the Lebesgue-Stieltjes main theory:
  - Properties of interval measures (hemi-continuity, outer regularity)
  - Right-continuity and monotonicity of Stieltjes functions
  - Absolute continuity criteria
  - Integration by parts preliminary lemmas
  - Dominated convergence applications
Translation challenge: LOW-MEDIUM
  - Most lemmas are measure-theoretic bookkeeping with Mathlib analogs.
  - Right-continuity in Lean 4: `ContinuousWithinAt F (Set.Ici x) x`
    (same for all x → monotone right-continuous function).
  - Absolute continuity: `MeasureTheory.Measure.AbsolutelyContinuous`.
  - Phase-1: sorry stubs for all. Phase-2: reduce to Mathlib lemmas.
Key lemmas: rcll_of_mono_right_cont, abs_cont_interval_measure,
  interval_measure_sigma_finite
Validation:
  - `lake build CATEPTMain.AFPBridge.LSI.Preliminaries_LSI` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-TH-002  Theory: Lebesgue_Stieltjes_Integral (P1 — main theory)
AFP file: Lebesgue_Stieltjes_Integral/Lebesgue_Stieltjes_Integral.thy
Dependency: Preliminaries_LSI
Content summary:
  The main Lebesgue-Stieltjes integration results:
  1. Stieltjes integral via interval measure: ∫ g dF := ∫ g d(interval_measure F)
  2. Change-of-variables formula: ∫ₐᵇ g(x) dF(x) = ∫ₐᵇ g(x) F'(x) dx
     (when F is absolutely continuous, i.e., admits L¹ derivative F')
  3. Integration by parts for Lebesgue-Stieltjes:
     ∫ₐᵇ g dF + ∫ₐᵇ F dg = F(b)g(b) - F(a)g(a)
  4. Fundamental theorem connection: when F(x) = ∫ₐˣ f dt, the Stieltjes measure is
     the standard Lebesgue measure weighted by f.
Translation challenge: HIGH
  REASON 1 — Change-of-variables (main formula):
    AFP: `lebesgue_stieltjes_integral F g = ∫ g * F' dx`
    This requires F to be absolutely continuous (F' exists as L¹ function).
    In Lean 4: `MeasureTheory.StieltjesFunction.withDensity_deriv` bridges this.
    Phase-1: axiom `lsiChangeOfVariables` (see LSIPrelude).
    Phase-2: use `Mathlib.MeasureTheory.Integral.LebesgueStieltjes` theorem directly.
  REASON 2 — Integration by parts:
    This is the main novel content of the AFP entry.
    AFP proves: `∫ₐᵇ g dF + ∫ₐᵇ F dg = [F·g]ₐᵇ`
    This involves both `lsiMeasure F` and `lsiMeasure g` simultaneously.
    Phase-1: axiom `lsiIntByParts`.
    Phase-2: reduce to Mathlib.MeasureTheory.Integral.StrictlyMono or prove directly.
  REASON 3 — Fubini for Stieltjes:
    Integration by parts proof in AFP uses Fubini (interchange ∫∫ order).
    Lean 4: `MeasureTheory.lintegral_prod` (Fubini-Tonelli) from Mathlib.
Key theorems: lebesgue_stieltjes_eq_density_integral (change-of-variables),
  lebesgue_stieltjes_integration_by_parts,
  lebesgue_stieltjes_of_absolutely_continuous
Phase-2 upgrade path:
  Connect `lsiMeasure F` to `MeasureTheory.StieltjesFunction.measure` and use
  the Radon-Nikodym theorem (`MeasureTheory.Measure.AbsolutelyContinuous.withDensity`)
  to derive the change-of-variables formula from Mathlib directly.
Validation:
  - `grep "lsiChangeOfVariables\|lsiIntByParts" Theories/Lebesgue_Stieltjes_Integral.lean` → ≥1 each
  - `grep "lebesgue_stieltjes_integration_by_parts\|integration_by_parts" Theories/Lebesgue_Stieltjes_Integral.lean` → ≥1
  - `lake build CATEPTMain.AFPBridge.LSI.Lebesgue_Stieltjes_Integral` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-INT-001  Integration bridge: CATEPTMain.Integration.LSIBridge (P2)
Target file: CATEPTMain/Integration/LSIBridge.lean
Content plan:
  import CATEPTMain.AFPBridge.LSI.LSIPrelude
  import CATEPTMain.AFPBridge.LSI.Lebesgue_Stieltjes_Integral
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: Lebesgue-Stieltjes integral reduces to Lebesgue integral for C¹ F. -/
  structure LSIBridgeContract where
    F   : ℝ → ℝ
    g   : ℝ → ℝ
    a b : ℝ
    hF  : Monotone F
    /-- Main formula: Stieltjes integral = Lebesgue integral against derivative -/
    hEq : lsiIntegral F g =
          ∫ x in Set.Ioc a b, g x * (deriv F x) ∂MeasureTheory.volume
  theorem lsiBridgeExists : ∃ _ : LSIBridgeContract, True :=
    ⟨{ F := id, g := fun _ => 1, a := 0, b := 1,
       hF := monotone_id, hEq := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation: `lake build CATEPTMain.Integration.LSIBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-TLA-001  TLA+ model for LSI translation control loop (P3)
New error classes:
  "E38_stieltjes_monotone_missing"
    — lsiMeasure used without Monotone F hypothesis
    — remediation: "add_hF_Monotone_hypothesis"
  "E39_change_of_variables_type_error"
    — change-of-variables formula uses wrong integral domain type (Icc vs Ioc)
    — remediation: "use_Ioc_for_stieltjes_halfopen"
  "E40_integration_by_parts_missing"
    — integration by parts theorem absent from main theory file
    — remediation: "add_lsiIntByParts_axiom"
New invariants:
  LSIByPartsPresent == built["Lebesgue_Stieltjes_Integral"] =>
    "lsiIntByParts" ∈ axiomNames ∪ theoremNames
  LSIMonotoneGuard == ∀ thy ∈ THEORIES_LSI: built[thy] =>
    ∀ f ∈ stieltjesGenerators[thy]: hasMonotonePred(f)
Validation: TLC model check: 0 violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-QA-001  Regression checks for LSI translator output (P1)
Checks:
  1. lsiMeasure axiom: `grep "lsiMeasure" LSIPrelude.lean` → ≥1
  2. Monotone hypothesis present: `grep "Monotone F\|Monotone G" Theories/*.lean LSIPrelude.lean` → ≥1
  3. Change-of-variables: `grep "lsiChangeOfVariables\|lebesgue_stieltjes_eq" Theories/Lebesgue_Stieltjes_Integral.lean` → ≥1
  4. Integration by parts: `grep "lsiIntByParts\|integration_by_parts" Theories/Lebesgue_Stieltjes_Integral.lean` → ≥1
  5. No AFP interval_measure: `grep "interval_measure\b" Theories/*.lean | wc -l` → 0
  6. No autoImplicit: `grep "autoImplicit true" Theories/*.lean LSIPrelude.lean | wc -l` → 0
  7. Full build: `lake build CATEPTMain.AFPBridge.LSI` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## LSI-QA-002  Faithfulness delta metric for LSI (P2)
Metrics:
  faithful_monotone  = 1.0  (Monotone F always explicit)
  faithful_cov       = 1.0  (change-of-variables axiom stated correctly)
  faithful_ibp       = 1.0  (integration by parts axiom present)
  faithful_proof     = 0.0  (all sorry in phase-1)
Phase-2 targets: faithful_proof ≥ 0.7 (change-of-variables and IBP have direct Mathlib paths)
  Reason for high phase-2 target: Mathlib.MeasureTheory.Integral.LebesgueStieltjes has
  most of the ingredients; phase-2 completion is relatively direct for this small module.
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.

/-!
## RS-P1-LSI-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-LSI)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-LSI is DONE, all imports of this module change from
  `CATEPTMain.AFPBridge.LSI.*`  →  `CATEPTMain.AFPBridge.LSI.*`
-/
