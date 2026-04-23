/-!
# PDC Translation Worklog — Poincare_Disc → Lean 4
Source: AFP `Poincare_Disc`
  (Danijela Simić, Filip Marić, Pierre Boutry — December 16, 2019)
  https://www.isa-afp.org/entries/Poincare_Disc.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.Core.PDC)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: The Poincaré disc uses complex analysis heavily.
  Main risk: well-typedness of the disc subtype through Möbius maps.
  Phase-1 approach: PDCPoint as Subtype is already semi-concrete (not fully opaque),
  which is appropriate since the Möbius formula and distance formula are explicit.

AFP entry abstract:
  Formalizes the Poincaré disc model of hyperbolic plane geometry.
  Proves Euclid's first four postulates hold but the parallel postulate fails.
  Uses complex arithmetic, Möbius transformations, and cross-ratio.

AFP session file order (for TH record numbering):
  1.  Hyperbolic_Functions
  2.  Tarski
  3.  Poincare_Lines
  4.  Poincare_Lines_Ideal_Points
  5.  Poincare_Distance
  6.  Poincare_Circles
  7.  Poincare_Between
  8.  Poincare_Lines_Axis_Intersections
  9.  Poincare_Perpendicular
  10. Poincare
  11. Poincare_Tarski

AFP direct dependencies:
  - HOL-Complex-Analysis (complex analysis standard library)
  - HOL-Analysis

Used by (downstream AFP):
  - GyrovectorSpaces (Möbius gyrovector model overlap)

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.Analysis.Complex.Isometry           (Möbius maps)
  - Mathlib.Analysis.SpecialFunctions.Complex.Circle
  - Mathlib.Topology.MetricSpace.Basic          (metric space structure)
  - Mathlib.Geometry.Hyperbolic.PoincareDisk    (if available in Mathlib 4.29)

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-PRE-001  PDCPoint as Subtype (not opaque) (P1)
Severity: P1
Context:
  AFP `p_disc` is defined as `typedef p_disc = {z :: complex | cmod z < 1}`.
  In Lean 4, the natural encoding is `{z : ℂ // ‖z‖ < 1}` (a Subtype).
  Unlike other preludes, PDCPoint should NOT be `opaque` because:
    (1) The Möbius formula `pdcMobiusVal` is explicit and depends on ℂ arithmetic.
    (2) `pdcDist` has an explicit formula via `Real.atanh`.
    (3) Making it opaque forces all membership proofs to be axioms (too many).
  Risk: if PDCPoint = ℂ (without constraint), the disc property is lost.
Strategy:
  `def PDCPoint : Type := {z : ℂ // ‖z‖ < 1}` — Subtype approach.
  All well-typedness lemmas (Möbius preserves disc, distance OK) are axioms in phase-1
  and proved in phase-2 via complex analysis.
Fix status: RESOLVED — PDCPoint is `def` Subtype; closure lemmas are axioms.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-PRE-002  Complex conjugate: use starRingEnd ℂ (P1)
Severity: P1
Context:
  AFP `cnj z` = `Isabelle/HOL Complex.cnj z`.
  Lean 4 options:
    (a) `Complex.conj z` — deprecated / no longer preferred
    (b) `starRingEnd ℂ z` — the ring-involution from `Star` typeclass (recommended)
    (c) `conj z` — from `StarRing` open (requires specific import)
  The Möbius formula denominator is `1 - cnj(a) * z`.
  If the translator emits `Complex.re - Complex.im * I` expansion, the formula
  becomes unreadable and hard to use in phase-2 proofs.
Strategy:
  Always use `starRingEnd ℂ a` for conjugate.
  Import `Mathlib.Analysis.SpecialFunctions.Complex.Circle` which pulls `Star ℂ`.
Fix status: RESOLVED — `starRingEnd ℂ` used throughout.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-PRE-003  pdcDist formula: Real.atanh range (P2)
Severity: P2
Context:
  `pdcDist a b = 2 * Real.atanh ‖pdcMobiusVal a.1 b.1‖`.
  `Real.atanh` is defined for all `x : ℝ` in Mathlib (returning 0 for |x| ≥ 1).
  The issue: `pdcMobiusVal a.1 b.1` has norm < 1 (by `pdcMobiusVal_lt_one`), so
  `Real.atanh` is properly in (0, ∞).
  BUT: Lean's `Real.atanh x = 0` for `x ≥ 1` by convention; proofs about
  the metric that use `pdcDist_zero_iff` must verify the constraint is in force.
Strategy:
  Phase-1: axiom `pdcDist_zero_iff` covers the non-degenerate case.
  Phase-2: prove by combining `pdcMobiusVal_lt_one` with `Real.atanh_pos`.
Fix status: phase-1 axiom adequate; phase-2 proof path identified.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-PRE-004  Mathlib.Geometry.Hyperbolic.PoincareDisk availability (P2)
Severity: P2
Context:
  Mathlib 4.29 may contain a partial `PoincareDisk` development.
  If so, some axioms in PDCPrelude.lean can be replaced by `theorem` + `exact`.
  Risk: using Mathlib's version may conflict with the AFP formulation
  (different conventions for the metric formula).
Strategy:
  Phase-1: all results are axioms (safe regardless of Mathlib content).
  Phase-2: run `#check Mathlib.Geometry.Hyperbolic.PoincareDisk` to check availability;
  if present, replace axioms with instances/theorems.
Fix status: Phase-2 open item.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-TH-001  PoincareDisk_Lines.thy → Lean 4 (P2)
Theory: hyperbolic lines (arcs + diameters)
AFP definition:
  A p_disc line is EITHER:
    (1) A diameter: `{z | Im(e^(iθ) * z) = 0}` for some angle θ
    (2) A circular arc: `{z | ‖z - c‖ = r}` where the circle meets ∂D orthogonally
  Key property: `h_move a` maps any line to another line.
Translation plan:
  Phase-1: `opaque PDCLine` + `axiom onLine + axiom pdcLine_unique`.
  Phase-2: characterize PDCLine as `{∃ a b : PDCPoint, a ≠ b, · = geodesicArc a b}`.
Known issues:
  - The distinction between "diameter" and "arc" cases must NOT be collapsed.
    In phase-1, `PDCLine` hides this.
Fix status: PDCLine is opaque; `pdcLine_unique` captures the existence+uniqueness.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-INT-001  CATEPT bridge: PDC → SCHTZ via hyperbolic geometry (P3)
Severity: P3
Context:
  The Schutz_Spacetime (SCHTZ) betweenness axioms, when restricted to a 1+1D
  Minkowski slice, define a unique class of hyperbolic (Poincaré disc) geometry
  for velocity space.  This is the "rapidity = hyperbolic angle" connection.
  The PDC prelude provides the geometric infrastructure for this bridge.
Plan: Phase-3 connection theorem:
  `theorem rapidityHyperbolicBridge :
      ∀ u v : PDCPoint, pdcDist pdcOrigin (pdcMobius u v) = Real.acosh (1 + pdcDist pdcOrigin u ^ 2 / 2)`
  (relates PDC distance to Minkowski rapidity).
Fix status: Phase-3 bridge item.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PDC-QA-001  Build validation (P1)
Required checks:
  1. `lake build CATEPTMain.Core.PDC.PDCPrelude` → EXIT:0
  2. `pdcMobius_involution` well-typed (needs `pdcMobiusVal_lt_one`).
  3. `pdcHyperbolicParallel` well-typed.
  4. `Real.atanh` in scope.
Fix status: See build output.
-/

────────────────────────────────────────────────────────────────────────────────
## PDC-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.Core.PDC.PDCPrelude added to CATEPTSelfConsistency.lean
  - pdc_hyperbolic_consistent field added to CATEPTAFPConsistencyWitness
  - PDCConsistency section + catept_pdc_dist_nonneg_consistent (non-sorry: pdcDist_nonneg a b) added
  - CATEPTSelfConsistencyContract extended with w.pdc_hyperbolic_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: poincare-disc-afp (afp_transpile_lean4)
  Phase-2: PDC-INT-001: pdcDist_triangle + pdcMobius_isometry → EPT hyperboloid slice

────────────────────────────────────────────────────────────────────────────────
## PDC-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.Core.PDC.PDCPrelude added to CATEPTSelfConsistency.lean
  - pdc_hyperbolic_consistent field added to CATEPTAFPConsistencyWitness
  - PDCConsistency section + catept_pdc_dist_nonneg_consistent (non-sorry: pdcDist_nonneg a b) added
  - CATEPTSelfConsistencyContract extended with w.pdc_hyperbolic_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: poincare-disc-afp (afp_transpile_lean4)
  Phase-2: PDC-INT-001: pdcDist_triangle + pdcMobius_isometry → EPT hyperboloid slice

/-!
## RS-P2-PDC-BACKREF  Restructuring Phase 2 back-reference

This module is a stub-only module (Prelude + WORKLOG, no Theories/).
It is a candidate for consolidation in AFPBridge Phase 2.

Phase 2 decision and procedure:
  → CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean  (RS-P2-ASSESS, RS-P2-MERGE)

Action required here: none until RS-P2-ASSESS decides MERGE.
If MERGE is decided, this directory will be removed and its namespace
content folded into CATEPTMain/AFPBridge/Stubs.lean.
-/
