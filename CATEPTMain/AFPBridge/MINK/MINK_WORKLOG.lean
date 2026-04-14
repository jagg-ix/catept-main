/-!
# MINK Translation Worklog — Minkowskis_Theorem → Lean 4
Source: AFP `Minkowskis_Theorem`
  (Manuel Eberl — 2017)
  https://www.isa-afp.org/entries/Minkowskis_Theorem.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.MINK)
License: BSD

Prior version: none — first translation.
Methodology note: Minkowski's theorem lives at the intersection of convex
  analysis and number theory (lattice points). Mathlib has convex sets,
  Lebesgue measure, and integer lattice — all the ingredients.
  The theorem itself (K ∩ ℤⁿ ≠ {0}) is NOT directly stated in Mathlib,
  but all auxiliary definitions are available.

AFP entry abstract:
  Minkowski's Theorem: Let K ⊆ ℝⁿ be a convex, symmetric, bounded set with
  Lebesgue measure vol(K) > 2ⁿ. Then K contains a nonzero integer lattice point.
  Proved via the "period lattice" tiling argument: S = (K/2) ∩ [0,1)ⁿ tiles ℝⁿ
  by integer translates; if vol(K) > 2ⁿ then the images of (K/2) in the unit
  cell must overlap by the pigeonhole principle.

AFP session file order:
  1.  Minkowskis_Theorem  (main theorem — single-file AFP entry)

AFP direct dependencies:
  - HOL-Analysis
  - HOL-Number_Theory

Mathlib modules used as semantic targets:
  - Mathlib.Analysis.Convex.Basic       (Convex, convexHull)
  - Mathlib.MeasureTheory.Measure.Lebesgue.Basic  (volume, measurable sets)
  - Mathlib.Geometry.Euclidean.Basic    (EuclideanSpace ℝ)
  - Mathlib.NumberTheory.LatticePoints  (integer lattice casting)

BINDER RULES:
  B90: `(K : set real^n)` convex symmetric → `(K : Set (EuclideanSpace ℝ (Fin n)))`
       with `(hConvex : Convex ℝ K)` and `(hSym : ∀ x ∈ K, -x ∈ K)`
  B91: volume > 2ⁿ condition → `(hVol : (2 : ℝ)^n < MeasureTheory.volume K)`
       [standard real volume coercion]
  B92: integer lattice point → `(∃ z : Fin n → ℤ, (fun i => (z i : ℝ)) ∈ K ∧ z ≠ 0)`

Phase record (cumulative):
  TH001–TH024: MINK theorems translated
-/
