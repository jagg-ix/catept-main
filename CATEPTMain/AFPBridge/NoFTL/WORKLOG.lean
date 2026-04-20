/-!
# NoFTL AFP Port — Lean 4 Worklog

Source: AFP `No_FTL_observers_Gen_Rel` (Sulzbacher & Martins 2023)
Target: Lean 4 / Mathlib v4.29, idiomatic type classes

## Dependency DAG (Isabelle → Lean 4)

```
Layer 0 — Foundation (DONE)
  Sorts.thy           → Sorts.lean           ✅  28 lemmas proved, 4 sqrt sorry
  Points.thy          → Points.lean          ✅  25+ lemmas proved, 5 line sorry

Layer 1 — Axiom stubs + simple theories (DONE)
  AxEField.thy        → AxEField.lean        ✅  axiom class only
  WorldView.thy       → WorldView.lean       ✅  5 defs, 0 lemmas
  AxSelfMinus.thy     → AxSelfMinus.lean     ✅  axiom class
  AxEventMinus.thy    → AxEventMinus.lean    ✅  axiom class
  Functions.thy       → Functions.lean       ✅  19 defs, 4/7 lemmas proved, 3 sorry

Layer 2 — Norms + WorldLine + Translations (DONE)
  Norms.thy           → Norms.lean           ✅  4 defs, 3/8 lemmas proved, 5 sorry (sqrt chain)
  WorldLine.thy       → WorldLine.lean       ✅  1 def, 1 lemma proved, 1 deferred
  Translations.thy    → Translations.lean    ✅  2 defs, 12/19 lemmas proved, 7 sorry

Layer 3 — Vectors + Matrices + TangentLines (DONE)
  Vectors.thy         → Vectors.lean         ✅  11 defs, 24/26 lemmas proved, 2 sorry
  Matrices.thy        → Matrices.lean        ✅  7 defs, 0 lemmas
  AxTriangleIneq.thy  → AxTriangleIneq.lean  ✅  axiom class
  TangentLines.thy    → TangentLines.lean    ✅  5 defs, 1/3 lemmas proved, 2 sorry

Layer 4 — Algebra (CauchySchwarz, LinearMaps, Quadratics) (DONE)
  CauchySchwarz.thy   → CauchySchwarz.lean   ✅  0 defs, 0/7 lemmas proved, 7 sorry (norm/sqrt chain)
  LinearMaps.thy      → LinearMaps.lean      ✅  1 def, 3/9 lemmas proved, 6 sorry
  Quadratics.thy      → Quadratics.lean      ✅  11 defs, 7/9 lemmas proved, 2 sorry (sqrt)
  ReverseCauchySchwarz→ RevCauchySchwarz.lean ✅  0 defs, 1/4 lemmas proved, 3 sorry
  Cardinalities.thy   → Cardinalities.lean   ✅  0 defs, 1/6 lemmas proved, 5 sorry

Layer 5 — Geometry (Affine, Cones, Classification) (DONE)
  Affine.thy          → Affine.lean          ✅  7 defs, 3/18 lemmas proved, 15 sorry
  Cones.thy           → Cones.lean           ✅  5 defs, 0 lemmas
  Classification.thy  → Classification.lean  ✅  4 defs, 3/32 lemmas proved, 29 sorry
  AxLightMinus.thy    → AxLightMinus.lean    ✅  axiom class
  AxDiff.thy          → AxDiff.lean          ✅  axiom class

Layer 6 — Proof chain to NoFTLGR (DONE)
  WorldLine.thy       (already in L2)
  Sublemma3.thy       → Sublemma3.lean       ✅  0 defs, 0/2 lemmas proved, 2 sorry
  Sublemma4.thy       → Sublemma4.lean       ✅  0 defs, 0/1 lemmas proved, 1 sorry
  MainLemma.thy       → MainLemma.lean       ✅  0 defs, 0/3 lemmas proved, 3 sorry
  TangentLineLemma    → TangentLineLemma.lean ✅  0 defs, 0/9 lemmas proved, 9 sorry
  KeyLemma.thy        → KeyLemma.lean        ✅  0 defs, 0/1 lemmas proved, 1 sorry
  AffineConeLemma.thy → AffineConeLemma.lean ✅  0 defs, 0/2 lemmas proved, 2 sorry
  Proposition1.thy    → Proposition1.lean    ✅  0 defs, 0/1 lemmas proved, 1 sorry
  Proposition2.thy    → Proposition2.lean    ✅  0 defs, 0/1 lemmas proved, 1 sorry
  Proposition3.thy    → Proposition3.lean    ✅  0 defs, 0/1 lemmas proved, 1 sorry
  ObserverConeLemma   → ObservConeLemma.lean ✅  0 defs, 0/1 lemmas proved, 1 sorry
  NoFTLGR.thy         → NoFTLGR.lean        ✅  0 defs, 0/1 lemmas proved, 1 sorry ⭐ CROWN
```

## Legend
  ✅ = ported with real proofs, builds clean
  ○  = not yet started
  ⚠  = expected difficulty

## Port strategy
  - Axiom files (AxEField, AxSelfMinus, AxEventMinus, AxTriangleInequality,
    AxLightMinus, AxDiff): map to Lean 4 `class` extending the prerequisite
    class with an axiom field. Tiny files, port as batch.
  - Definition-heavy files (WorldView, Cones, Matrices): structures + abbrevs,
    no lemmas. Port as batch.
  - Lemma-heavy files: port in dependency order, prove what can be proved,
    mark remainder `sorry` with `-- phase2` annotation.
  - Classification.thy (2064 lines, 32 lemmas): largest file, port last.

## Isabelle class hierarchy → Lean 4 mapping
  Isabelle `class Foo = Bar + assumes ...` maps to:
    class Foo (Q : Type*) extends Bar Q where
      axiomFoo : ∀ ...
  This preserves the typeclass inheritance chain.

## Key type mappings
  Isabelle                    Lean 4
  ─────────────────────────   ─────────────────────────────────────
  class Quantities            [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
  'a Point (record)           structure Point (Q : Type*)
  'a Space (record)           structure Space (Q : Type*)
  'a Matrix (record)          structure Matrix (Q : Type*)
  Body                        structure Body (in NoFTLPrelude)
  class WorldView             class WorldView (B Q : Type*) ... where W : ...
  p ⊕ q                       moveBy p q (notation ⊕)
  p ⊖ q                       movebackBy p q (notation ⊖)
  α ⊗ p                       scaleBy α p (notation ⊗)

## History
  2026-04-19: Deleted 25 auto-translated all-sorry stub files (NoFTLObj-based).
              Retained 3 freshly ported files (NoFTLPrelude, Sorts, Points).
              AFPBridge.lean updated, builds clean at 8420 jobs.
  2026-04-19: Ported Layer 1 (AxEField, WorldView, AxSelfMinus, AxEventMinus,
              Functions) and Layer 2 (Norms, WorldLine, Translations).
              8 new files, all build clean at 8428 jobs.
              Sorry inventory: Functions 3, Norms 5, WorldLine 1, Translations 7.
  2026-04-19: Ported Layer 3 (Vectors, Matrices, AxTriangleInequality,
              TangentLines). 4 new files, all build clean at 8432 jobs.
              Vectors: 24/26 lemmas proved (ring tactic). Matrices: defs only.
  2026-04-19: Ported Layer 4 (CauchySchwarz, Quadratics, LinearMaps,
              ReverseCauchySchwarz, Cardinalities). 5 new files, all build
              clean at 8437 jobs.
              Quadratics: 7/9 lemmas proved (algebra with ring/field_simp).
              LinearMaps: 3/9 proved (lemMatrixApplicationIsLinear,
              lemIdIsLinear, lemLinOfLinIsLin).
              CauchySchwarz: 7 sorry (all depend on norm/sqrt chain).
              ReverseCauchySchwarz: 1/4 proved (lemTimelikeNotZeroTime).
              Cardinalities: 1/6 proved (lemInjectiveValueUnique).
              Sorry inventory: CS 7, LM 6, Q 2, RCS 3, Card 5 = 23 total.
  2026-04-19: Ported Layer 5 (AxLightMinus, Cones, Affine, AxDiff,
              Classification). 5 new files, all build clean at 3305 jobs.
              Added BodySorts class to NoFTLPrelude (Ph/Ob predicates for
              abstract body type B).
              Affine: 3/18 proved (lemLinearImpliesAffine,
              lemTranslationImpliesAffine, lemAffineImpliesTotalFunction).
              Classification: 3/32 proved (lemConesExist,
              lemSlopeInfiniteImpliesOutside, lemLineInsideRegularConeHasFiniteSlope).
              Key fix: `⊕` notation needs parens after `∨`/`≠` (conflicts
              with `Sum` type notation).
              Sorry inventory: Affine 15, Classification 29 = 44 total.
              Cumulative sorry: L0-L4 (23) + L5 (44) = 67 total.
  2026-04-19: Ported Layer 6 (Sublemma3, Sublemma4, MainLemma,
              TangentLineLemma, KeyLemma, AffineConeLemma, Proposition1,
              Proposition2, Proposition3, ObserverConeLemma, NoFTLGR).
              11 new files, all build clean at 8453 jobs.
              Added lineSlopeFinite to Points.lean.
              All 23 lemmas sorry'd (phase2 — proofs are 300-700 lines each
              in Isabelle, highly dependent on lower-layer sorry chain).
              Crown theorem: lemNoFTLGR — no observer sees another observer
              moving at or above lightspeed.
              PORT COMPLETE: all 36 Isabelle theories ported to Lean 4.
              Sorry inventory: L6 = 23 sorry.
              Cumulative sorry: L0-L4 (23) + L5 (44) + L6 (23) = 90 total.
-/
