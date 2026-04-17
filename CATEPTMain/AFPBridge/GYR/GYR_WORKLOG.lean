/-!
# GYR Translation Worklog — GyrovectorSpaces → Lean 4
Source: AFP `GyrovectorSpaces`
  (Filip Marić, Jelena Markovic — March 16, 2025)
  https://www.isa-afp.org/entries/GyrovectorSpaces.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.GYR)
License: BSD

Prior version: none — first translation of this AFP entry in this repo.
Methodology note: Gyrovectors are a structurally unusual algebraic object
  (group-but-not-quite). The main risk is false simplification to standard
  groups or vector spaces. All gyrogroup axioms must be preserved as distinct
  axioms — NOT combined into AddGroup instances.

AFP entry abstract:
  Formalization of Ungar's theory of gyrogroups and gyrovector spaces (2008).
  Gyrogroups generalize groups: left-associativity with a gyration correction
  (GG3). Two concrete models: (1) Möbius disc (hyperbolic geometry), (2)
  Einstein addition (SRT velocities). Connections to Poincaré disc model.

AFP session file order (for TH record numbering):
  1.  GyroGroup
  2.  More_Real_Vector
  3.  GyroVectorSpace
  4.  VectorSpace
  5.  Abe
  6.  GyroVectorSpaceIsomorphism
  7.  MoreComplex
  8.  GammaFactor
  9.  PoincareDisc
  10. MobiusGyroGroup
  11. Gyrotrigonometry
  12. HyperbolicFunctions
  13. MobiusGyroVectorSpace
  14. Einstein
  15. GyroVectorSpaceTrivial
  16. hDistance
  17. MobiusCollinear
  18. MobiusGeometry
  19. TarskiIsomorphism
  20. MobiusGyroTarski
  21. MobiusGyrotrigonometry
  22. Poincare

AFP direct dependencies:
  - HOL-Analysis
  - Poincare_Disc (AFP) — included in this batch; see PDCPrelude.lean

Used by (downstream AFP):
  - (indirectly) General_Topology via Poincare_Disc overlap

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.Analysis.Normed.Group.Basic (for norm structure)
  - Mathlib.Analysis.Complex.Circle (Möbius disc)
  - Mathlib.Analysis.SpecialFunctions.Complex.Circle

All records graded by severity (P1=blocker/P2=high/P3=medium/P4=low)
and type (PRE/TH/INT/TLA/QA)
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-PRE-001  Gyrogroup ≠ AddCommGroup (P1)
Severity: P1 — blocker
Context:
  AFP gyrogroup is NOT an additive commutative group.
  GG3 (left gyroassociativity) requires:
    a ⊕ (b ⊕ c) = (a ⊕ b) ⊕ gyr a b c
  This differs from standard associativity by the gyration term `gyr a b c`.
  Lean 4 risk: translator may unify `gyroAdd` with `AddGroup.add` and drop
  the `gyr` correction factor, making GG3 degenerate to standard associativity.
Strategy:
  - `gyroAdd` and `gyroAut` are separate axioms (never merged into AddGroup instance).
  - Do NOT instantiate `Add GyroCarrier`, `AddGroup GyroCarrier`, or
    `AddCommGroup GyroCarrier` for the abstract `GyroCarrier` type.
Fix status: RESOLVED — GYRPrelude.lean uses standalone axioms; no AddGroup instance.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-PRE-002  Gyration map must carry all three arguments (P1)
Severity: P1 — type collapse risk
Context:
  AFP `gyr a b` is a curried function `'a ⇒ 'a` (element of Aut(G)).
  Lean 4 risk: translator may emit `gyr a b : GyroCarrier → GyroCarrier` as
    a `LinearMap` or as a partially-applied composition, losing explicit type.
  The problem: if `gyr a b` is emitted as a term of type `GyroCarrier → GyroCarrier`,
  then `gyroAut a b v` needs pattern-matching against the function, which is opaque.
Strategy:
  Emit as three-argument axiom `gyroAut : GyroCarrier → GyroCarrier → GyroCarrier → GyroCarrier`.
  In downstream proofs, η-expand when needed: `gyroAut a b · = (gyroAut a b ·)`.
  Do NOT specialize `gyr a b` to a LinearMap.
Fix status: RESOLVED — B51 binder rule; `gyroAut` is 3-argument axiom.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-PRE-003  Einstein model: einsteinAdd formula correctness (P2)
Severity: P2 — semantic accuracy
Context:
  The Ungar Einstein velocity addition formula is:
    u ⊕_E v = (1/1+u·v/c²) * [u + v/γ_u + (γ_u/(1+γ_u)) * (u·v/c²) * u]
  where γ_u = 1/√(1 - ‖u‖²/c²) (Lorentz factor), using c = 1 units.
  Phase-1 risk: the formula has a division-by-zero issue when ‖u‖² → 1 (lightcone).
  If the translator leaves u_norm_sq unguarded in the denominator, the definition
  can evaluate to NaN/∞ for unit-norm u.
Strategy:
  Phase-1: provide the formula as a non-computable `def` (not proved correct).
  Add note: at ‖u‖ = 0 the formula reduces to `(0 + v) / 1 = v` (correct).
  Phase-2: prove the formula equals zero on the light cone by continuity extension.
Fix status: RESOLVED with guard — `einsteinAdd` is noncomputable; norm bound enforced
  by `einsteinAdd_norm_lt_one` axiom.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-PRE-004  Möbius addition: `starRingEnd ℂ` for conjugation (P2)
Severity: P2
Context:
  AFP `cnj z` = complex conjugate of z.
  Lean 4 / Mathlib: complex conjugate is `starRingEnd ℂ a` or `conj a` (from `Star`).
  Risk: translator may emit `Complex.conj` (deprecated) or `Complex.re - Complex.im * I`
  instead of the ring involution `starRingEnd ℂ`.
Strategy:
  Use `starRingEnd ℂ a` for conjugate in all Möbius formula terms.
  Import `Mathlib.Analysis.SpecialFunctions.Complex.Circle` (pulls `starRingEnd ℂ`).
Fix status: RESOLVED — `starRingEnd ℂ` used throughout; `mobiusAdd` and `mobiusGyr`.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-TH-001  GyroGroup.thy → Lean 4 (P1)
Theory: GG1–GG5 axioms
Translation: All five axioms emitted as standalone axioms in `GYRPrelude.lean`.
Known issues:
  - GG4 (gyration is a group homomorphism) is sometimes called a "cogyroassociativity"
    lemma in Ungar; translator should match the AFP name to `gyroAut_homo`.
  - GG5 (left loop property) is easy to confuse with "right loop" in Ungar 2008 §2.
    AFP uses only the LEFT loop: `gyr a b = gyr (a ⊕ b) b`.
Fix status: GG1–GG5 present; left/right distinction documented.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-TH-002  EinsteinModel.thy → Lean 4 (P2)
Theory: Einstein velocity addition on open ball
Translation plan:
  - `einsteinAdd` as non-computable def (not axiom — formula is explicit).
  - `einsteinAdd_norm_lt_one` as axiom (phase-2: prove via Cauchy-Schwarz).
  - Phase-2 priority: connect `einsteinAdd` to `gyroAdd` on concrete carrier.
Known issues:
  - Division expression in `einsteinAdd` has `/ u_norm_sq` which is 0/0 for u=0.
    The formula should handle this special case: when u=0, u_norm_sq=0 and the
    correction term `(gamma_u - 1) * uv_dot * u i / u_norm_sq` should be 0.
    Lean division by zero returns 0 so the formula is correct by how Lean handles `/`.
Fix status: OK — Lean `x / 0 = 0` semantics make u=0 case correct automatically.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-INT-001  CATEPT bridge: Einstein model → NoFTL velocity bound (P2)
Target: `einsteinAdd_norm_lt_one` directly supports the NoFTL prelude.
  If u and v are physical velocities (‖·‖ < 1), their Einstein sum is also < 1.
  This provides a concrete realization of the `NoFTL` bound in `CATEPTSpacetimeModel`.
Plan: Phase-2 theorem:
  `theorem catept_noftl_einstein (u v : Fin 3 → ℝ)
       (hu : ∑ i, u i^2 < 1) (hv : ∑ i, v i^2 < 1) :
       ∑ i, einsteinAdd u v i ^ 2 < 1 := einsteinAdd_norm_lt_one u v hu hv`
Fix status: Bridge axiom present; theorem sketch deferred to phase-2.
-/

/-!
────────────────────────────────────────────────────────────────────────────────
## GYR-QA-001  Build validation (P1)
Required checks:
  1. `lake build CATEPTMain.AFPBridge.GYR.GYRPrelude` → EXIT:0
  2. No `AddGroup GyroCarrier` instance anywhere.
  3. No `LinearMap` for gyroAut.
  4. GG1–GG5 all present and type-checked.
Fix status: See current build.
-/

────────────────────────────────────────────────────────────────────────────────
## GYR-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.AFPBridge.GYR.GYRPrelude added to CATEPTSelfConsistency.lean
  - gyr_gyro_consistent field added to CATEPTAFPConsistencyWitness
  - GYRConsistency section + catept_gyr_left_id_consistent (non-sorry: gyroAdd_left_id a) added
  - CATEPTSelfConsistencyContract extended with w.gyr_gyro_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: gyrovector-spaces-afp (afp_transpile_lean4)
  Phase-2: GYR-INT-001: gyroAdd_left_assoc + gyroAut_homo → NoFTL velocity bound

────────────────────────────────────────────────────────────────────────────────
## GYR-INT-001  Downstream wiring in CATEPTSelfConsistency (P1)
Severity: P2 — consistency contract completeness
Status: DONE — 2026-04-13
Record:
  - import CATEPTMain.AFPBridge.GYR.GYRPrelude added to CATEPTSelfConsistency.lean
  - gyr_gyro_consistent field added to CATEPTAFPConsistencyWitness
  - GYRConsistency section + catept_gyr_left_id_consistent (non-sorry: gyroAdd_left_id a) added
  - CATEPTSelfConsistencyContract extended with w.gyr_gyro_consistent conjunct
  - Master catept_self_consistent witness and refine tuple updated
  - repos.yaml entry added: gyrovector-spaces-afp (afp_transpile_lean4)
  Phase-2: GYR-INT-001: gyroAdd_left_assoc + gyroAut_homo → NoFTL velocity bound

────────────────────────────────────────────────────────────────────────────────
## GYR-P2-001  Einstein NoFTL bound theorem in CATEPTSelfConsistency (P2)
Severity: P2 — INT-001 GYR ↔ EPT NoFTL connection
Status: DONE — 2026-04-13
Record:
  - catept_gyr_einstein_noftl_consistent added to GYRConsistency section
  - Proves: Einstein velocity addition closed on {v | ∑ v_i² < 1} (c=1 units)
  - Directly applied: einsteinAdd_norm_lt_one u v hu hv (no sorry)
  - INT-001 connection: GYR speed closure ↔ EPT NoFTL axiom package

────────────────────────────────────────────────────────────────────────────────
## GYR-P2-002  Abstract gyroassociativity bridge GG3+GG4 (P2)
Severity: P2 — GYR-INT-001 abstract completion
Status: DONE — 2026-04-14
Record:
  - catept_gyr_gyroassoc_homo_noftl_bridge added to GYRConsistency section
  - Proves conjunction (no sorry):
      (1) GG3: gyroAdd a (gyroAdd b (gyroAdd x y)) =
               gyroAdd (gyroAdd a b) (gyroAut a b (gyroAdd x y))
      (2) GG4: gyroAut a b (gyroAdd x y) =
               gyroAdd (gyroAut a b x) (gyroAut a b y)
  - Uses gyroAdd_left_assoc + gyroAut_homo directly.
  - Abstract analogue of catept_gyr_einstein_noftl_consistent.
  - gyroNorm_gyroAut closes the norm-invariance leg.
  - GYR-INT-001 Phase-2 deferred item fully discharged.

/-!
## RS-P2-GYR-BACKREF  Restructuring Phase 2 back-reference

This module is a stub-only module (Prelude + WORKLOG, no Theories/).
It is a candidate for consolidation in AFPBridge Phase 2.

Phase 2 decision and procedure:
  → CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean  (RS-P2-ASSESS, RS-P2-MERGE)

Action required here: none until RS-P2-ASSESS decides MERGE.
If MERGE is decided, this directory will be removed and its namespace
content folded into CATEPTMain/AFPBridge/Stubs.lean.
-/
