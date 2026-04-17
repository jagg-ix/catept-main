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

────────────────────────────────────────────────────────────────────────────────
## ODE-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.AFPBridge.ODE.ODEPrelude added to CATEPTSelfConsistency.lean
  - ode_flow_consistent field added to CATEPTAFPConsistencyWitness
  - ODEConsistency section + catept_ode_flow_zero_consistent (non-sorry: odeFlow_zero n f x₀) added
  - CATEPTSelfConsistencyContract extended with w.ode_flow_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: ordinary-differential-equations-afp (afp_transpile_lean4)
  Phase-2: odeFlow_semigroup → Galerkin half-step operator + half_holder_from_l2_deriv_bound

────────────────────────────────────────────────────────────────────────────────
## ODE-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.AFPBridge.ODE.ODEPrelude added to CATEPTSelfConsistency.lean
  - ode_flow_consistent field added to CATEPTAFPConsistencyWitness
  - ODEConsistency section + catept_ode_flow_zero_consistent (non-sorry: odeFlow_zero n f x₀) added
  - CATEPTSelfConsistencyContract extended with w.ode_flow_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: ordinary-differential-equations-afp (afp_transpile_lean4)
  Phase-2: odeFlow_semigroup → Galerkin half-step operator + half_holder_from_l2_deriv_bound

────────────────────────────────────────────────────────────────────────────────
## ODE-P2-001  Semigroup theorem in CATEPTSelfConsistency (P2)
Severity: P2 — NS-P1 Galerkin half-step key
Status: DONE — 2026-04-13
Record:
  - catept_ode_flow_semigroup_consistent added to ODEConsistency section
  - Proves: odeFlow n f (t₁+t₂) x₀ = odeFlow n f t₂ (odeFlow n f t₁ x₀)
  - Directly applied: odeFlow_semigroup n f t₁ t₂ x₀ (no sorry)
  - NS-P1 path: operator splitter uses this as the half-step composition law

/-!
## RS-P1-ODE-BACKREF  Restructuring Phase 1 back-reference

This module has a `Theories/` subdirectory scheduled for removal in Phase 1.

Phase 1 move record:
  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean  (RS-P1-ODE)

Action required here: none — moves are handled by the Phase 1 procedure.
After RS-P1-ODE is DONE, all imports of this module change from
  `CATEPTMain.AFPBridge.ODE.Theories.*`  →  `CATEPTMain.AFPBridge.ODE.*`
-/
