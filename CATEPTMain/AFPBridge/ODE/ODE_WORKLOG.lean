/-!
# ODE Translation Worklog — Ordinary_Differential_Equations → Lean 4
Source: AFP `Ordinary_Differential_Equations`
  (Fabian Immler, Johannes Hölzl — 2012, last updated 2022)
  https://www.isa-afp.org/entries/Ordinary_Differential_Equations.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.ODE)
License: BSD/LGPL

Prior version: none — first translation.
Methodology note: This is a large AFP entry covering: Picard-Lindelöf theorem,
  flows, Euler method, Poincaré-Bendixson theorem, and Lorenz system analysis.
  Phase-1 bridge preserves all core types as opaque carriers; phase-2 connects
  to Mathlib.Analysis.ODE.

AFP entry abstract:
  A formal verification of: (1) existence and uniqueness of solutions to initial
  value problems when the right-hand side satisfies Lipschitz conditions
  (Picard-Lindelöf); (2) flows of autonomous systems; (3) the Euler method as
  an approximation scheme; (4) Poincaré-Bendixson theorem for 2D flows;
  (5) enclosure arithmetic for rigorous numerical verification.

AFP session file order:
  1.  ODE_Auxiliaries      (helper lemmas)
  2.  Picard_Lindelof       (existence & uniqueness)
  3.  Flow                  (system flow, semigroup)
  4.  Euler_Affine          (Euler method for affine systems)
  5.  Euler_Gene            (general Euler method)
  6.  Poincare_Bendixson    (2D limit cycle theorem)
  7.  Concrete_Reachability (Lorenz system)
  8.  Bounded_Continuous_Function (auxiliary)

AFP direct dependencies:
  - HOL-Analysis
  - HOL-Library
  - Matrices_for_ODEs (AFP) — see MODE bridge

Used by (downstream AFP):
  - Hilbert_Space_Tensor_Product (via generator/Duhamel)
  - Any AFP entry requiring flow/evolution analysis

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.Analysis.ODE.PicardLindelof
  - Mathlib.Analysis.ODE.Solution
  - Mathlib.Topology.MetricSpace.Contracting

BINDER RULES (ODE-specific):
  B64: `ode_rhs f` → `(f : ℝ → EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin n))`
  B65: `ode_sol f t₀ x₀` → `ODESolution` (opaque phase-1; concrete in phase-2)
  B66: `flow f t` → `ODEFlow f t` (opaque phase-1)
  B67: Lipschitz constant `L` → `(hL : LipschitzWith L (f t))` type annotation

Phase record (cumulative):
  TH001–TH032: ODE theorems translated
-/
