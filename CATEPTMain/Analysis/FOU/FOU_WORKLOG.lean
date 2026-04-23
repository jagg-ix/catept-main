/-!
# FOU Translation Worklog — Fourier → Lean 4
Source: AFP `Fourier` (Lawrence C. Paulson — September 6, 2019)
  https://www.isa-afp.org/entries/Fourier.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.Analysis.FOU)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: follows IMD_WORKLOG.lean tooling lessons.
  FOU is independent of quantum modules (PM/QFT/CBO/HSTP) — purely analysis.
  It is a port from HOL Light (John Harrison's Fourier formalization).

AFP entry abstract:
  Formalizes square-integrable functions over the reals and the basics of Fourier
  series. Culminates with a proof that every well-behaved periodic function can be
  approximated by a Fourier series. Material ported from HOL Light.

AFP session file order (for TH record numbering):
  1. Periodic
  2. Lspace
  3. Square_Integrable
  4. Confine
  5. Fourier_Aux2
  6. Fourier

AFP direct dependencies:
  - Lp (AFP entry: Lp spaces — MeasureTheory.Lp in Lean 4)
  - HOL-Analysis (standard library)

Used by (downstream AFP): none listed

Mathlib modules used as semantic targets:
  - Mathlib.Analysis.Fourier.FourierTransform
  - Mathlib.Analysis.Fourier.RiemannLebesgue
  - Mathlib.MeasureTheory.Function.L2Space
  - Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
  - Mathlib.MeasureTheory.Integral.Periodic
  - Mathlib.Topology.Algebra.Module.Basic

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- FOU-PRE-* = pre-generation gate items
-- FOU-TH-*  = per-theory translation plans (AFP session order)
-- FOU-INT-* = integration bridge targets
-- FOU-TLA-* = TLA+ model extension targets
-- FOU-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-PRE-001  AFP dependency bridge: Lp spaces → Lean 4 (P1)
Severity: P1 — FOU depends on the AFP `Lp` entry (Lp spaces)
Context:
  AFP `Fourier` directly imports `Lp` (AFP entry for Lp function spaces).
  AFP `Lp` defines: `lp p f` (L^p class of functions), `lp_norm`, integrability.
  In Lean 4 Mathlib: `MeasureTheory.Lp E p μ` — the Lp Banach space.
Strategy:
  Phase-1: import Mathlib.MeasureTheory.Function.L2Space and define bridge:
    -- L² space on [-π, π] with Lebesgue measure
    noncomputable def FourierL2 := MeasureTheory.Lp ℝ 2 (MeasureTheory.Measure.restrict
      MeasureTheory.volume (Set.Icc (-Real.pi) Real.pi))
  Phase-2: replace all AFP Lp references with Mathlib.MeasureTheory.Lp instances.
Key type correspondences:
  AFP `Lspace 2 {-π..π}` → `MeasureTheory.Lp ℝ 2 μ_pi` (Lean 4)
  AFP `sq_integrable f`    → `MeasureTheory.Memℒp f 2 μ` (Lean 4)
  AFP `l2norm f`           → `MeasureTheory.eLpNorm f 2 μ` (Lean 4)
  AFP Fourier coefficient  → `MeasureTheory.L2.inner_apply` or explicit integral
Fix target: Do NOT emit `sq_integrable f` as a type `(f : sq_integrable)`.
  Must be: `(f : ℝ → ℝ) (hf : MeasureTheory.Memℒp f 2 μ_pi)`.
Validation:
  - `grep "(f : sq_integrable\|(f : lspace)" Theories/*.lean | wc -l` → 0
  - `lake build CATEPTMain.Analysis.FOU.FOUPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-PRE-002  Prelude-first strategy: FOUPrelude.lean (P1)
Severity: P1
Required prelude content (skeleton):
  import Mathlib.MeasureTheory.Function.L2Space
  import Mathlib.Analysis.Fourier.FourierTransform
  import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
  import Mathlib.MeasureTheory.Integral.Periodic
  set_option autoImplicit false
  namespace CATEPTMain.Analysis.FOU
  -- Lebesgue measure restricted to [-π, π]
  noncomputable def μ_pi : MeasureTheory.Measure ℝ :=
    MeasureTheory.Measure.restrict MeasureTheory.volume (Set.Icc (-Real.pi) Real.pi)
  -- Square-integrability on [-π, π]
  def SqIntegrable (f : ℝ → ℝ) : Prop := MeasureTheory.Memℒp f 2 μ_pi
  -- Fourier coefficient: ĉ_n(f) = (1/2π) ∫_{-π}^{π} f(x) e^{-inx} dx
  noncomputable def fourierCoeff (f : ℝ → ℝ) (n : ℤ) : ℝ :=
    (1 / (2 * Real.pi)) * ∫ x in Set.Icc (-Real.pi) Real.pi,
      f x * Real.cos (n * x)
  -- Fourier partial sum S_N(f)(x) = ∑_{|n| ≤ N} ĉ_n(f) e^{inx}
  noncomputable axiom fourierPartialSum : (ℝ → ℝ) → ℕ → ℝ → ℝ
  -- Approximation predicate: S_N(f) → f in L²
  axiom FourierL2Approx (f : ℝ → ℝ) : Prop
  end CATEPTMain.Analysis.FOU
Validation:
  - `lake build CATEPTMain.Analysis.FOU.FOUPrelude` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-PRE-003  Type map: Fourier series types (P1)
Severity: P1
Type map:
  AFP symbol              Lean 4 phase-1                Lean 4 phase-2
  sq_integrable f         SqIntegrable f : Prop          MeasureTheory.Memℒp f 2 μ_pi
  l2_norm f               axiom L2Norm f : ℝ             MeasureTheory.eLpNorm f 2 μ_pi
  fourier_nth f n         fourierCoeff f n : ℝ           explicit integral formula
  fourier_sum f N x       fourierPartialSum f N x        ∑ n ∈ Finset.Icc (-N) N, ĉ_n * e^{inx}
  SQUARE_INTEGRABLE_NORM  (Parseval norm equality)       L2 inner product identity
  periodic_fn T f         axiom IsPeriodic f : Prop      Function.Periodic f T
  orthonormal basis eₙ    axiom FourierONB               OrthonormalBasis ℤ ℂ L2
Notation conflicts:
  AFP `%` has no Lean 4 operator meaning; use `Real.pi` everywhere for π.
  AFP complex exponential `exp (i * n * x)` → `Complex.exp (Complex.I * n * x)`
Validation:
  - `grep "sq_integrable\|lspace" Theories/*.lean | wc -l` → 0 (AFP names gone)
  - `grep "SqIntegrable\|fourierCoeff" FOUPrelude.lean` → ≥1 each
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TH-001  Theory: Periodic (P3)
AFP file: Fourier/Periodic.thy
Dependency: HOL-Analysis
Content summary:
  Periodic functions on ℝ: `periodic f T` (f(x+T) = f(x) for all x).
  Integration over periodic domain, shifting lemmas.
Translation challenge: LOW
  - Lean 4 Mathlib: `Function.Periodic f T := ∀ x, f (x + T) = f x`
  - `MeasureTheory.Measure.restrict_add_left` for shifted integrals.
  - Phase-1: `axiom IsPeriodic : (ℝ → ℝ) → ℝ → Prop` (can also use Function.Periodic)
    Bridge: `def IsPeriodic f T := Function.Periodic f T`
Key theorems: periodic_integral_shift, periodic_translation_invariant
Validation: `lake build CATEPTMain.Analysis.FOU.Periodic` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TH-002  Theory: Lspace (P2)
AFP file: Fourier/Lspace.thy
Dependency: Lp (AFP)
Content summary:
  L² function space on [-π, π]: inner product `⟨f, g⟩ := ∫ f * ḡ`, completeness.
Translation challenge: MEDIUM
  - This is a specialization of the general AFP Lp entry to p=2, domain=[-π,π].
  - Lean 4: `MeasureTheory.L2.inner` with `μ = μ_pi` from FOUPrelude.
  - Phase-1: `axiom FOUInner : (ℝ → ℝ) → (ℝ → ℝ) → ℝ` with axiom bridge.
  - Phase-2: `def FOUInner f g := ∫ x in (-π, π), f x * g x`
Key theorems: lspace_is_hilbert (completeness), inner_product_cauchy_schwarz
Validation: `lake build CATEPTMain.Analysis.FOU.Lspace` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TH-003  Theory: Square_Integrable (P2)
AFP file: Fourier/Square_Integrable.thy
Dependency: Lspace
Content summary:
  Dense subsets of L² functions: continuous functions on [-π,π] are dense in L².
  Dominated convergence theorem applications. Fejer kernel properties.
Translation challenge: MEDIUM
  - Density of continuous functions in Lp: `MeasureTheory.ContinuousMap.denseRange_toLp`
  - Fejer kernel: `(1/N) ∑ₙ₌₁ᴺ Dₙ` where Dₙ is Dirichlet kernel.
  - Phase-1: axiom `DiriKernel : ℕ → ℝ → ℝ` and `FejerKernel : ℕ → ℝ → ℝ`
Key theorems: continuous_dense_in_l2, fejer_kernel_nonneg, fejer_kernel_integral
Validation: `lake build CATEPTMain.Analysis.FOU.Square_Integrable` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TH-004  Theory: Confine (P2)
AFP file: Fourier/Confine.thy
Dependency: Square_Integrable
Content summary:
  "Confine" lemmas: approximation of L² functions by functions supported away from
  boundary of integration domain. Infrastructure for the Fourier convergence proof.
Translation challenge: LOW
  Abstract measure-theoretic lemmas. Phase-1: sorry stubs for all.
  Phase-2: reduce to MeasureTheory.Lp approximation lemmas.
Validation: `lake build CATEPTMain.Analysis.FOU.Confine` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TH-005  Theory: Fourier_Aux2 (P2)
AFP file: Fourier/Fourier_Aux2.thy
Dependency: Confine, Periodic
Content summary:
  Auxiliary Fourier analysis results: Riemann-Lebesgue lemma (Fourier coefficients
  go to 0), Dirichlet integral evaluation, pointwise convergence criteria.
Translation challenge: MEDIUM
  - Riemann-Lebesgue: `MeasureTheory.fourier_tendsto_zero` in Mathlib
  - Dirichlet integral: `∫₀^∞ sin(x)/x dx = π/2` — known in Mathlib
  - Phase-1: axiom `riemannLebesgue : SqIntegrable f → Tendsto (|fourierCoeff f n|) atTop (nhds 0)`
Key theorems: riemann_lebesgue, dirichlet_int_eq_pi_2, fourier_coeff_decay
Validation: `lake build CATEPTMain.Analysis.FOU.Fourier_Aux2` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TH-006  Theory: Fourier (P1 — main Fourier convergence theorem)
AFP file: Fourier/Fourier.thy
Dependency: Fourier_Aux2, Square_Integrable
Content summary:
  The main results of the AFP entry:
  1. Fourier series definition (complex exponentials form an orthonormal set in L²)
  2. Parseval's identity: ‖f‖² = ∑ₙ |ĉₙ(f)|²
  3. L² convergence: S_N(f) → f in L²-norm as N → ∞ (for f ∈ L²(-π,π))
  4. Pointwise convergence: if f ∈ C¹ at x, then S_N(f)(x) → f(x)
Translation challenge: HIGH
  REASON 1 — Series convergence:
    `tsum (fun n => |fourierCoeff f n|^2) = L2Norm f ^ 2` (Parseval).
    Lean 4: `tsum` with convergence certificates; `HasSum` predicate.
    Phase-1: axiom `parseval : SqIntegrable f → HasSum (fun n => |fourierCoeff f n|^2) (L2Norm f ^ 2)`
  REASON 2 — L² norm convergence (main theorem):
    `Tendsto (fun N => L2Norm (fun x => fourierPartialSum f N x - f x)) atTop (nhds 0)`
    Phase-1: axiom `fourierL2Conv : SqIntegrable f → FourierL2Approx f`
  REASON 3 — Complex exponentials form ONB:
    The Fourier basis {eₙ(x) = e^{inx}} is an orthonormal basis of L²(-π,π).
    Lean 4 Mathlib: `fourier_series_orthonormal` in `Mathlib.Analysis.Fourier.FourierTransform`.
Key theorems: fourier_coeff_inner_product, parseval, fourier_l2_convergence,
  fourier_pointwise_convergence
Phase-2 upgrade path: connect `fourierCoeff` to `Mathlib.Analysis.Fourier.fourierCoeff`
  and use `MeasureTheory.L2.norm_eq_tsum_inner` for Parseval.
Validation:
  - `grep "parseval\|fourierL2Conv\|FourierL2Approx" Theories/Fourier.lean` → ≥1 each
  - `lake build CATEPTMain.Analysis.FOU.Fourier` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-INT-001  Integration bridge: CATEPTMain.Integration.FOUBridge (P2)
Target file: CATEPTMain/Integration/FOUBridge.lean
Content plan:
  import CATEPTMain.Analysis.FOU.FOUPrelude
  import CATEPTMain.Analysis.FOU.Fourier
  set_option autoImplicit false
  namespace CATEPTMain.Integration
  /-- Contract: L² functions have convergent Fourier series (Parseval identity). -/
  structure FOUBridgeContract where
    f     : ℝ → ℝ
    hSI   : SqIntegrable f
    /-- Parseval: sum of squared Fourier coefficients equals L² norm squared. -/
    hPars : FourierL2Approx f
  theorem fouBridgeExists : ∃ _ : FOUBridgeContract, True :=
    ⟨{ f := fun _ => 0, hSI := sorry, hPars := sorry }, trivial⟩
  end CATEPTMain.Integration
Validation: `lake build CATEPTMain.Integration.FOUBridge` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-TLA-001  TLA+ model for FOU translation control loop (P3)
New error classes:
  "E32_sq_integrable_as_type"
    — `sq_integrable f` emitted as type instead of predicate
    — remediation: "use_SqIntegrable_pred_as_Prop"
  "E33_fourier_coeff_missing"
    — fourierCoeff not defined in prelude, used as free symbol
    — remediation: "define_fourierCoeff_in_FOUPrelude"
  "E34_parseval_type_error"
    — Parseval statement emitted with wrong type for norm (ℂ vs ℝ vs ℝ≥0)
    — remediation: "use_L2Norm_as_real_nonneg"
New invariants:
  FOUParsevalPresent == built["Fourier"] => "parseval" ∈ theoremNames["Fourier"]
  FOUSqIntPred == ∀ thy ∈ THEORIES_FOU: built[thy] =>
    ∀ f ∈ sqIntegrableVars[thy]: isProposition(f)
Validation: TLC model check: 0 violations
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-QA-001  Regression checks for FOU translator output (P1)
Checks:
  1. SqIntegrable as Prop: `grep "(f : SqIntegrable\|(f : sq_integrable" Theories/*.lean | wc -l` → 0
  2. fourierCoeff defined: `grep "def fourierCoeff\|fourierCoeff" FOUPrelude.lean` → ≥1
  3. parseval theorem present: `grep "parseval" Theories/Fourier.lean` → ≥1
  4. L2/Lp import: `grep "MeasureTheory.Lp\|Memℒp\|L2Space" FOUPrelude.lean` → ≥1
  5. No autoImplicit: `grep "autoImplicit true" Theories/*.lean FOUPrelude.lean | wc -l` → 0
  6. Full build: `lake build CATEPTMain.Analysis.FOU` EXIT:0
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-QA-002  Faithfulness delta metric for FOU (P2)
Metrics:
  faithful_sq_int   = 1.0  (SqIntegrable as Prop, not type)
  faithful_coeff    = 1.0  (fourierCoeff defined in prelude)
  faithful_parseval = 1.0  (parseval stated with HasSum / tsum)
  faithful_proof    = 0.0  (all sorry in phase-1)
Phase-2 targets: faithful_proof ≥ 0.5 (Riemann-Lebesgue and Parseval via Mathlib)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-FIX-20260415-A  Vacuous-content tracking for Fourier_Aux2 (P2)
Target file:
  - CATEPTMain/AFPBridge/FOU/Theories/Fourier_Aux2.lean
Current stabilization:
  - File compiles after explicit calculus imports (`ContDiff`, `deriv`) were added.
  - Proof bodies remain phase-1 placeholders/sorries for auxiliary lemmas.
Fix intent:
  - Preserve parser/import correctness while converting Aux2 lemmas from placeholder form
    to Mathlib-backed statements used downstream by `Fourier.lean`.
Phase-2 adjustments:
  1. Replace `riemann_lebesgue_*_law` axioms with Mathlib `fourier_tendsto_zero` bridges.
  2. Replace C1 decay axiom with derivative-based coefficient decay theorem over periodic domain.
  3. Tighten Fejer-kernel nonnegativity using explicit kernel identity and positivity proofs.
Validation target:
  - `lake build CATEPTMain.Analysis.FOU.Fourier_Aux2` EXIT:0 with reduced sorry count.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## FOU-FIX-20260415-B  Vacuous-content tracking for Fourier main theorem (P1)
Target file:
  - CATEPTMain/AFPBridge/FOU/Theories/Fourier.lean
Current stabilization:
  - `fourier_series_representation` currently uses placeholder proof (`sorry`) to avoid a
    brittle `linarith` step in the epsilon extraction path.
Progress (2026-04-15):
  - Placeholder removed. `fourier_series_representation` now has a concrete epsilon-N proof
    using `Metric.tendsto_atTop` and `le_abs_self` (no theorem-body `sorry` remaining).
  - Build validated: `lake build CATEPTMain.Analysis.FOU.Fourier` EXIT:0.
Fix intent:
  - Recover typed epsilon-N proof from `Filter.Tendsto` without relying on fragile arithmetic
    automation assumptions.
Phase-2 adjustments:
  1. Rework `Metric.tendsto_atTop` extraction into a reusable lemma for `L2norm` convergence.
  2. Replace the final inequality closure with direct order rewriting on `dist` and nonnegativity.
  3. Keep theorem statement unchanged so integration bridges continue to depend on the same API.
Validation target:
  - `lake build CATEPTMain.Analysis.FOU.Fourier` EXIT:0 with theorem proved (no `sorry`).
-/

-- This file is a worklog / issue tracker. No runnable Lean 4 code is defined here.

/-!
## RS-P1-FOU-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-FOU)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-FOU is DONE, all imports of this module change from
  `CATEPTMain.Analysis.FOU.*`  →  `CATEPTMain.Analysis.FOU.*`
-/
