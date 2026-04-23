/-!
# PHQ Translation Worklog — Physical_Quantities → Lean 4
Source: AFP `Physical_Quantities`
  (Simon Foster, Burkhart Wolff — October 20, 2020)
  https://www.isa-afp.org/entries/Physical_Quantities.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.Core.PHQ)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: Physical_Quantities uses Isabelle's type system deeply —
  `Dimension` is encoded as a type-level tuple, not a term-level structure.
  In Lean 4, we use a term-level `Fin 7 → ℤ` encoding (NOT phantom types at
  the universe level).  This is a deliberate simplification for phase-1;
  phase-2 may explore dependent-type approaches.

AFP entry abstract:
  A formalization of the International System of Quantities (ISQ) and SI units.
  Dimensions are represented as 7-tuples of integer exponents at the type level.
  Quantities are real (or complex) values paired with their dimension.
  The Isabelle formalization uses type classes and type-level arithmetic.

AFP session file order (for TH record numbering):
  1.  Power_int
  2.  Enum_extra
  3.  Groups_mult
  4.  ISQ_Dimensions
  5.  ISQ_Quantities
  6.  ISQ_Proof
  7.  ISQ_Algebra
  8.  ISQ_Units
  9.  ISQ_Conversion
  10. ISQ
  11. SI_Units
  12. CGS
  13. SI_Constants
  14. SI_Prefix
  15. SI_Derived
  16. SI_Accepted
  17. SI_Imperial
  18. SI
  19. SI_Astronomical
  20. SI_Pretty
  21. BIS

AFP direct dependencies:
  - HOL-Library (Groups, Number_Theory)
  - (no AFP dependencies — self-contained)

Used by (downstream AFP):
  - (potential: electrodynamics, thermodynamics formalizations)

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.Data.Real.Basic
  - Mathlib.Algebra.Group.Basic
  - (no direct Mathlib.Physics module in 4.29)
  - Physlib (repo dependency — if physlib has unit types, check compatibility)

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-PRE-001  Dimension as term, not type (P1)
Severity: P1 — fundamental design choice
Context:
  AFP `Dimension` uses Isabelle's type-level arithmetic: the dimension of a
  quantity is embedded in its TYPE, e.g., `Length Quantity` is a specific type.
  In Lean 4, this would require a dependent type parameter `PhysQuantity (d : PhysDim)`.
  However, type-level arithmetic creates universe issues when dimension operations
  (e.g., d₁ * d₂ = d₁ + d₂) need to be reflected at the type level.
  Phase-1 design choice: use `PhysDim = Fin 7 → ℤ` as a plain term.
  This means `PhysQuantity d` is an opaque type indexed by a term, which is
  perfectly well-typed in Lean 4 (types may depend on terms).
Strategy:
  - `def PhysDim : Type := Fin 7 → ℤ` (concrete structure, not opaque)
  - `opaque PhysQuantity : PhysDim → Type` (opaque indexed family)
  - All dimension operations are `def`s on `PhysDim`
  - `physMul`, `physDiv`, `physAdd` are typed with dimension arithmetic
Fix status: RESOLVED — implemented as above in PHQPrelude.lean.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-PRE-002  physMk / physVal round-trip axioms (P1)
Severity: P1
Context:
  `physMk d : ℝ → PhysQuantity d` and `physVal : PhysQuantity d → ℝ` must satisfy
  the round-trip: `physVal (physMk d r) = r` and `physMk d (physVal q) = q`.
  Without these, `physMul_val` (which is a concrete theorem) cannot be proved.
  These are the only "implementation detail" axioms that would be auto-proved
  in phase-2 once `PhysQuantity d := ℝ` (a `def` rather than `opaque`).
Strategy:
  Phase-1: axioms `physMk_val` and `physVal_mk`.
  Phase-2: `def PhysQuantity (d : PhysDim) := ℝ`; these become `rfl`.
Fix status: RESOLVED — both round-trip axioms present.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-PRE-003  Dimension algebra theorems are provable (not axioms) (P2)
Severity: P2
Context:
  `dimAdd_comm`, `dimAdd_assoc`, `dimAdd_zero` are purely algebraic on `Fin 7 → ℤ`.
  They follow from `add_comm`, `add_assoc`, `add_zero` in ℤ combined with `funext`.
  Unlike other preludes where theorems need `sorry`, these can be proved by
  `funext i; simp [...]` using standard ℤ algebra.
Strategy:
  Emit as `theorem` with Lean 4 `funext` + `simp` proofs (NOT as axioms).
  This is appropriate because PhysDim is fully concrete.
Fix status: RESOLVED — `dimAdd_comm`, `dimAdd_assoc`, `dimAdd_zero` provable.
NOTE FOR TRANSLATOR: The `simp [dimAdd, add_comm]` proof works because
  `dimAdd : (Fin 7 → ℤ) → (Fin 7 → ℤ) → (Fin 7 → ℤ)` reduces to pointwise ℤ addition.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-PRE-004  Physlib compatibility check (P2)
Severity: P2
Context:
  The `catept-main` repo depends on `Physlib` (leanprover-community/physlib).
  Physlib may define overlapping types: `PhysUnit`, `Dimension`, `SIUnit`.
  Risk: if both PHQPrelude.lean and Physlib define `PhysDim`, there will be a
  conflict when CATEPTSelfConsistency.lean imports both.
Strategy:
  Phase-1: use prefix `PHQ.PhysDim`, `PHQ.PhysQuantity` to avoid namespace collision.
  The namespace `CATEPTMain.Core.PHQ` isolates all names.
  When importing, always open with the full qualified path.
Fix status: RESOLVED by namespacing — PHQ types have no unqualified names.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-TH-001  ISQ_Derived → Lean 4 derived dimensions (P2)
AFP derived SI units and their dimensions:
  force     (Newton)   = M·L·T⁻²
  energy    (Joule)    = M·L²·T⁻²
  pressure  (Pascal)   = M·L⁻¹·T⁻²
  power     (Watt)     = M·L²·T⁻³
  frequency (Hertz)    = T⁻¹
  voltage   (Volt)     = M·L²·T⁻³·I⁻¹
  charge    (Coulomb)  = T·I
Translation plan:
  All emitted as `def dimXxx : PhysDim := ...` using dimAdd/dimSub.
  Done for Force, Energy, Pressure, Power, Velocity, Acceleration, Frequency.
  Phase-2 TODO: add Voltage, Charge, Resistance, Capacitance.
Fix status: Core derived dimensions implemented; electrical dimensions deferred.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-INT-001  CATEPT integration: constSpeedOfLight → CATEPTSpacetimeModel.noFTL (P2)
Target: `constSpeedOfLight` provides the numeric value c = 299792458 m/s.
  In `CATEPTSpacetimeModel.noFTL`, the speed limit is c = 1 (natural units).
  The bridge lemma: `physVal constSpeedOfLight = 299792458` and
  "velocity in natural units" = `physVal v_phys / physVal constSpeedOfLight < 1`.
Plan:
  `def naturalUnitVelocity (v : PhysQuantity dimVelocity) : ℝ :=
      physVal v / physVal constSpeedOfLight`
  Bridge theorem: `naturalUnitVelocity u < 1 ↔ physVal u < 299792458`
Fix status: Phase-2 open item.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## PHQ-QA-001  Build validation (P1)
Required checks:
  1. `lake build CATEPTMain.Core.PHQ.PHQPrelude` → EXIT:0
  2. `dimAdd_comm`, `dimAdd_assoc`, `dimAdd_zero` proved (not sorry).
  3. `physMul_val` proved (not sorry).
  4. All SI constants defined and type-check.
Fix status: See current build.
-/

────────────────────────────────────────────────────────────────────────────────
## PHQ-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.Core.PHQ.PHQPrelude added to CATEPTSelfConsistency.lean
  - phq_dimension_consistent field added to CATEPTAFPConsistencyWitness
  - PHQConsistency section + catept_phq_dimless_consistent (trivial stub) added
  - CATEPTSelfConsistencyContract extended with w.phq_dimension_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: physical-quantities-afp (afp_transpile_lean4)
  Phase-2: PHQ-INT-001: constSpeedOfLight → CATEPTSpacetimeModel.noFTL

────────────────────────────────────────────────────────────────────────────────
## PHQ-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.Core.PHQ.PHQPrelude added to CATEPTSelfConsistency.lean
  - phq_dimension_consistent field added to CATEPTAFPConsistencyWitness
  - PHQConsistency section + catept_phq_dimless_consistent (trivial stub) added
  - CATEPTSelfConsistencyContract extended with w.phq_dimension_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: physical-quantities-afp (afp_transpile_lean4)
  Phase-2: PHQ-INT-001: constSpeedOfLight → CATEPTSpacetimeModel.noFTL

────────────────────────────────────────────────────────────────────────────────
## PHQ-P2-001  Speed-of-light positivity in CATEPTSelfConsistency (P2)
Severity: P2 — PHQ-INT-001 dimensional certificate partial closure
Status: DONE — 2026-04-13
Record:
  - catept_phq_speed_positive_consistent added to PHQConsistency section
  - Proves: physVal constSpeedOfLight > 0 (i.e., c = 299792458 > 0)
  - Proof: unfold constSpeedOfLight; rw [physMk_val]; norm_num (no sorry)
  - PHQ-INT-001 partial: positivity certificate done; noFTL binding remains
  - Next: relate constSpeedOfLight to CATEPTSpacetimeModel.noFTL

/-!
## RS-P2-PHQ-BACKREF  Restructuring Phase 2 back-reference

This module is a stub-only module (Prelude + WORKLOG, no Theories/).
It is a candidate for consolidation in AFPBridge Phase 2.

Phase 2 decision and procedure:
  → CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean  (RS-P2-ASSESS, RS-P2-MERGE)

Action required here: none until RS-P2-ASSESS decides MERGE.
If MERGE is decided, this directory will be removed and its namespace
content folded into CATEPTMain/AFPBridge/Stubs.lean.
-/
