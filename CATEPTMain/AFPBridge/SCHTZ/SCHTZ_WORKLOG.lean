/-!
# SCHTZ Translation Worklog — Schutz_Spacetime → Lean 4
Source: AFP `Schutz_Spacetime`
  (Richard Schmoetten, Jake Palmer, Jacques Fleuriot — July 27, 2021)
  https://www.isa-afp.org/entries/Schutz_Spacetime.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.SCHTZ)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: Schutz axiomatics is pure order theory — no analysis imports
  needed for phase 1.  The only Mathlib dependency for the prelude is `Order.Defs`.

AFP entry abstract:
  A formalization of Schutz's "Independent Axioms for Minkowski Spacetime" (1997).
  Covers: betweenness on paths, ordering axioms O1–O6, signal axioms S1–S5,
  three further axiom groups (Continuity, Density, Completeness), kinematic
  time coordinates, kinematic equivalence, and the derivation of the Minkowski
  metric from purely axiomatic order-theoretic data.

AFP session file order (for TH record numbering):
  1.  Util
  2.  TernaryOrdering
  3.  Minkowski
  4.  TemporalOrderOnPath

AFP direct dependencies:
  - HOL-Library (standard)

Used by (downstream AFP): none directly; conceptually foundational for relativity chain.

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.Order.Defs.PartialOrder
  - Mathlib.Topology.MetricSpace.Basic
  - Mathlib.LinearAlgebra.Matrix.BilinearForm (Minkowski metric)
  - Mathlib.Analysis.InnerProductSpace.Basic

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

--------------------------------------------------------------------------------
-- RECORD KEY
-- SCHTZ-PRE-* = pre-generation gate items
-- SCHTZ-TH-*  = per-theory translation plans (AFP session order)
-- SCHTZ-INT-* = integration bridge targets
-- SCHTZ-QA-*  = validation / quality gate targets
--------------------------------------------------------------------------------

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-PRE-001  Type alignment: `event` and `path` (P1)
Severity: P1 — blocker
Context:
  AFP defines `event` as an uninterpreted type (locale parameter).
  AFP defines `path` as an order on events with betweenness.
  Lean 4 risk: translator may collapse `event` to `ℝ⁴` or `EuclideanSpace ℝ (Fin 4)`.
  This collapses the axiomatic abstraction — betweenness and signal axioms become
  tautologies rather than theorems.
Strategy:
  Phase-1: `opaque SchutzEvent : Type` + `opaque SchutzPath : Type`.
  Phase-2: `SchutzEvent := EuclideanSpace ℝ (Fin 4)` + prove the axioms rigorously.
Fix status: RESOLVED in SCHTZPrelude.lean (opaque types chosen; B40/B41 binder rules).
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-PRE-002  Betweenness ≠ Lean `Between` (P1)
Severity: P1 — collision risk
Context:
  Mathlib has `Mathlib.Order.Betweenness` defining `Btw α` typeclass with
  `btw a b c` meaning "b is between a and c" in a linear order.
  Schutz's betweenness is PATH-INDEXED: `between P a b c` where P is the path.
  If the translator resolves to `Btw` typeclass methods, the path parameter is
  lost, making O1–O6 ill-typed.
Strategy:
  Emit `schutzBetween : SchutzPath → SchutzEvent → SchutzEvent → SchutzEvent → Prop`
  as an axiom. Do NOT use `Btw` typeclass or `between` from Mathlib.Order.Betweenness.
  Do NOT open `Mathlib.Order.Betweenness` in the prelude.
Fix status: RESOLVED — `schutzBetween` emitted as standalone axiom (not Btw instance).
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-PRE-003  Signal ≠ null geodesic in phase 1 (P2)
Severity: P2 — semantic risk
Context:
  AFP `signal a b` is purely axiomatic (S1–S5 axioms).
  Phase-2 wants to connect it to `schutzMetric a b = 0` (null interval).
  Phase-1 risk: translator may prematurely bind signal to metric == 0,
  making S4 (transitivity) non-trivial to prove.
Strategy:
  Phase-1: `axiom schutzSignal : SchutzEvent → SchutzEvent → Prop` (no metric binding).
  Phase-2 note in `schutzMetric_minkowski`: add explicit bridge lemma
    `theorem signal_iff_null : schutzSignal a b ↔ schutzMetric a b = 0`.
Fix status: RESOLVED in SCHTZPrelude.lean — signal is axiom; metric kept separate.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-TH-001  TernaryOrdering.thy → Lean 4 (P1)
Theory: O1–O6 ordering axioms on paths
AFP signatures:

  `between :: 'a path ⇒ 'a ⇒ 'a ⇒ 'a ⇒ bool`
  `AXIOM_O1`, ..., `AXIOM_O6`
  `strict_betweenness` (derived predicate)

Translation plan:
  - Emit O1–O6 as Lean 4 axioms in namespace `SCHTZ` (done in prelude).
  - `strict_betweenness` → `schutzLt P a b` (derived `def`, not axiom).
  - All path-indexed.
Known issues:
  - O5 (total order axiom) is the hardest to use in downstream proofs:
    emitter must not split it into three separate axioms (would lose the ∨ structure).
Fix status: RESOLVED — O5 emitted as single ∨-conclusion axiom.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-TH-002  Signal.thy → Lean 4 (P1)
Theory: S1–S5 signal axioms + path through two events
Translation plan:
  - S1 (irreflexive), S4 (transitive) → straightforward axioms.
  - S2 (∃ path through two events) → `schutz_S2` axiom.
  - S5 (uniqueness of signal intersection) → `∃!` Lean 4 axiom.
Known issues:
  - S5 `∃!` requires Lean 4 `ExistsUnique` unfolding in downstream proofs;
    use `obtain ⟨f, hf, huniq⟩ := schutz_S5 ...` in phase-2 proofs.
Fix status: S5 uses `∃!` as required — no issues.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-TH-003  MinkowskiSpacetime.thy → Lean 4 (P2)
Theory: Main result — kinematic equivalence → Minkowski metric
Translation plan:
  - `schutzKinTime`: phase-1 axiom (non-constructive).
  - `schutzMetric`: phase-1 axiom for the output metric.
  - `schutzMetric_minkowski`: states the (−,+,+,+) decomposition as existential.
  - Phase-2: connect via Cauchy sequence from signal intersections.
Known issues:
  - Kinematic time is ℚ-valued in Schutz (rational, not real) — do NOT
    promote to ℝ in phase 1. Phase-2 upgrade: ℚ → ℝ via completion.
  - The main AFP theorem requires 14+ lemma steps; phase-2 sorry chain needed.
Fix status: Phase-1 stubs in place; ℚ-type preserved.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-INT-001  CATEPT integration: SchutzEvent → CATEPTSpacetimeModel.SpaceTime (P2)
Target: show that `minkowskiCATEPT.SpaceTime = Fin 4 → ℝ` satisfies SCHTZ axioms
Strategy:
  Phase-2 theorem:
    `theorem minkowski_satisfies_schutz_O1_O6 : ∀ P : SchutzPath, <O1..O6>`
  Requires: embedding `Fin 4 → ℝ` as `SchutzEvent` and standard line through two
  Minkowski points as `SchutzPath`.
  Bridge: `instSchutzOnMinkowski : onPath e (minkowskiLine a b) ↔ ∃ t : ℝ, e = a + t • (b - a)`
Fix status: Phase-2 open item — not implemented in this prelude.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## SCHTZ-QA-001  Build validation (P1)
Required checks:
  1. `lake build CATEPTMain.AFPBridge.SCHTZ.SCHTZPrelude` → EXIT:0
  2. No `SchutzEvent = ℝ⁴` or `SchutzPath = Set ℝ⁴` in prelude.
  3. `opaque` used for both core types.
  4. All O1–O6, S1–S5 axioms present and type-check.
Fix status: See build output for current run.
-/
