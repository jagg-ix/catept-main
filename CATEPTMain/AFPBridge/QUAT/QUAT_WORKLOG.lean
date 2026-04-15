/-!
# QUAT Translation Worklog — Quaternions → Lean 4
Source: AFP `Quaternions`
  (Lawrence C. Paulson — 2018)
  https://www.isa-afp.org/entries/Quaternions.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.QUAT)
License: BSD

Prior version: none — first translation.
Methodology note: Lean 4 Mathlib has `Quaternion ℝ` as a concrete type in
  `Mathlib.Algebra.Quaternion`. Phase-1 connects AFP definitions directly to
  Mathlib types — this bridge is unique in that most content is provable
  concretely using Mathlib instances.

AFP entry abstract:
  Formalizes quaternion algebra ℍ = {a + bi + cj + dk | a,b,c,d ∈ ℝ}:
  the skew field (division ring) structure, norm, conjugation, and the
  application to 3D rotation. Unit quaternions U(ℍ) ≅ SU(2) double-cover SO(3).

AFP session file order:
  1.  Quaternions          (ring/field structure, conjugation, norm)
  2.  Quaternion_Rotation  (3D rotation formula v ↦ q v q⁻¹, double cover of SO(3))

AFP direct dependencies:
  - HOL-Analysis
  - HOL-Library

Used by (downstream AFP):
  - Octonions (extends quaternion structure — see OCT bridge)
  - Various geometric / physics formalization projects

Mathlib modules used as semantic targets (all in scope):
  - Mathlib.Algebra.Quaternion             (Quaternion α type, all basic instances)
  - Mathlib.Analysis.Quaternion            (norm, inner product)
  - Mathlib.LinearAlgebra.Quaternion       (matrix representation, 3D rotation)

CRITICAL TYPE NOTE:
  AFP `quat` → Lean 4: `Quaternion ℝ` (direct Mathlib type)
  AFP `norm q` → `‖q‖` via `NormedAlgebra ℝ (Quaternion ℝ)`
  AFP `quat_inv q` → `q⁻¹` (division ring instance)
  In phase-1, proofs use Mathlib's proved instances wherever possible.

BINDER RULES:
  B80: AFP `(q : quat)` → `(q : Quaternion ℝ)`
  B81: conjugate `q*ᵥ` → `star q : Quaternion ℝ` (Star instance)
  B82: unit quaternion → `(h : ‖q‖ = 1)`
  B83: 3D vector embedding → `(0 : ℝ).mk_quaternion` hack → see quatVec below

Phase record (cumulative):
  TH001–TH022: QUAT theorems translated
-/

────────────────────────────────────────────────────────────────────────────────
## QUAT-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.AFPBridge.QUAT.QUATPrelude added to CATEPTSelfConsistency.lean
  - quat_rotation_consistent field added to CATEPTAFPConsistencyWitness
  - QUATConsistency section + catept_quat_unit_consistent theorem added
    (non-sorry: directly proves unitQuat_inv_eq_conj q h : q⁻¹ = star q)
  - CATEPTSelfConsistencyContract extended with w.quat_rotation_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: quaternions-afp (afp_transpile_lean4)
