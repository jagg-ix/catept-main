/-!
# MODE Translation Worklog — Matrices_for_ODEs → Lean 4
Source: AFP `Matrices_for_ODEs`
  (Jonathan Julian Huerta y Munive, Georg Struth — 2020)
  https://www.isa-afp.org/entries/Matrices_for_ODEs.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.MODE)
License: BSD

Prior version: none — first translation.
Methodology note: Matrix exponential is available directly in Mathlib as
  `Matrix.exp` (from `Mathlib.LinearAlgebra.Matrix.Exp`). Phase-1 bridge focuses on
  the ODE-specific results (affine system solutions, stability criteria).

AFP entry abstract:
  Provides: Euclidean and Chebyshev matrix norms, the matrix exponential and its
  properties, solution of affine ODE systems x' = Ax + b, and differential
  induction (Lyapunov stability) machinery for verified hybrid system analysis.

AFP session file order:
  1.  Matrices              (matrix norms: Euclidean, Frobenius, submultiplicativity)
  2.  Matrix_Exp            (exponential series, convergence, Lie group properties)
  3.  Affine_ODE            (x' = Ax → x(t) = exp(tA) x₀; affine systems)
  4.  Hybridics             (differential invariants for hybrid programs)

AFP direct dependencies:
  - HOL-Analysis
  - Ordinary_Differential_Equations (ODE bridge)

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.LinearAlgebra.Matrix.Exp  (Matrix.exp already exists!)
  - Mathlib.Analysis.NormedSpace.Exponential
  - Mathlib.Analysis.ODE.PicardLindelof

BINDER RULES (MODE-specific):
  B70: `exp_mat A` → `Matrix.exp ℝ A` (Mathlib type available)
  B71: `mat_norm A` → `‖A‖` (operator norm from NormedSpace)
  B72: affine solution `x' = Ax + b` → `modeSolAffine A b t₀ x₀`

Phase record (cumulative):
  TH001–TH024: MODE theorems translated
-/
