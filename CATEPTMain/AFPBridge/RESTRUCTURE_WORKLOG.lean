/-!
# AFPBridge Restructuring Worklog — Master Orchestration

Scope:
  Flatten and simplify the `CATEPTMain/AFPBridge/` directory tree from
  a 3-level layout (`AFPBridge/MODULE/Theories/File.lean`) to a 2-level
  layout (`AFPBridge/MODULE/File.lean`), consolidate stub-only modules,
  and optionally regroup modules by domain.

  No Lean source *content* changes — only file moves and import-path updates.

Phase documents (see linked worklogs for per-module records):
  → Phase 1 (flatten Theories/ layer):
      CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean
  → Phase 2 (consolidate stub-only modules):
      CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean
  → Phase 3 (thematic regrouping, optional):
      CATEPTMain/AFPBridge/PHASE3_THEMATIC_WORKLOG.lean

Source plan (markdown):
  catept-main/AFPBRIDGE_RESTRUCTURE_PLAN.md

Conventions:
  - RS-P1-*: Phase 1 flatten records
  - RS-P2-*: Phase 2 stub-consolidation records
  - RS-P3-*: Phase 3 thematic-regroup records
  - Status: TODO | IN-PROGRESS | DONE | BLOCKED
  - Priority: P0 (blocker), P1 (required for milestone), P2 (nice-to-have)
-/

/-!
## RS-MASTER-001  Pre-flight baseline (P0 — do first)

Before any file moves, establish a clean baseline so every later step
can be verified against it.

### Steps

1. Confirm current build is clean:
   ```
   cd catept-main
   lake exe cache get
   lake build
   ```
   Expected: EXIT 0, no errors.

2. Tag the baseline commit:
   ```
   git add -A && git commit -m "chore: pre-restructure baseline"
   git tag pre-flatten
   ```

3. Record the current sorry/axiom counts for regression detection:
   ```
   grep -r "sorry" CATEPTMain/AFPBridge --include="*.lean" | grep -v WORKLOG | wc -l
   grep -r "^axiom" CATEPTMain/AFPBridge --include="*.lean" | wc -l
   ```

### Validation
  `lake build` → EXIT 0.
  `git tag pre-flatten` exists.
  Sorry count recorded (reference for RS-P1-VALIDATE).

### Status: TODO
-/

/-!
## RS-MASTER-002  Phase 1 — flatten Theories/ layer

Scope:   17 AFP-ISA bridge modules, ~120 theory files.
Detail:  → CATEPTMain/AFPBridge/PHASE1_FLATTEN_WORKLOG.lean
Records: RS-P1-QFT … RS-P1-NOFTL (17 per-module records)
         RS-P1-BARREL (AFPBridge.lean barrel update)
         RS-P1-VALIDATE (final build + regression check)

Summary of action per module:
  1. `mv AFPBridge/MOD/Theories/*.lean AFPBridge/MOD/`
  2. `rmdir AFPBridge/MOD/Theories/`
  3. In `CATEPTMain/AFPBridge.lean`:
       sed replace `AFPBridge.MOD.Theories.X` → `AFPBridge.MOD.X`
  4. Optionally: check internal cross-imports within the moved files.
  5. `lake build CATEPTMain.AFPBridge.MOD` → EXIT 0 before moving to next module.

Prerequisite: RS-MASTER-001 DONE.
Next phase:   RS-MASTER-003 (after RS-P1-VALIDATE DONE).

### Status: TODO
-/

/-!
## RS-MASTER-003  Phase 2 — consolidate stub-only modules

Scope:   4 prelude-only modules: GYR, PDC, PHQ, SCHTZ.
Detail:  → CATEPTMain/AFPBridge/PHASE2_STUBS_WORKLOG.lean
Records: RS-P2-ASSESS, RS-P2-MERGE, RS-P2-VALIDATE

Default recommendation: defer until at least one stub graduates to Phase 2
content (to avoid moving twice). See RS-P2-ASSESS for decision criteria.

Prerequisite: RS-MASTER-002 (RS-P1-VALIDATE DONE).
Next phase:   RS-MASTER-004.

### Status: TODO
-/

/-!
## RS-MASTER-004  Phase 3 — thematic regrouping (optional)

Scope:   All 31 modules → 6 thematic subdirs.
Detail:  → CATEPTMain/AFPBridge/PHASE3_THEMATIC_WORKLOG.lean
Records: RS-P3-PLAN … RS-P3-VALIDATE

WARNING: This phase changes Lean namespaces project-wide
(`CATEPTMain.AFPBridge.MOD` → `CATEPTMain.THEME.MOD`).
Requires a migration script and full rebuild. Defer until Phase 1+2 complete
and team alignment is reached on the new namespace map.

Prerequisite: RS-MASTER-003 (or explicit decision to skip Phase 2).
Blocking condition: None — this phase is purely optional.

### Status: TODO
-/

/-!
## RS-MASTER-006  CALCULUS bridge — lean4-mlir VJP framework port

Scope:   New `AFPBridge/CALCULUS/` module porting the verified differentiation
         library from the local `lean4-mlir` repo into catept-main.
Detail:  → CATEPTMain/AFPBridge/CALCULUS_PORT_WORKLOG.lean
Records: CALC-001 (pre-flight) … CALC-008 (validate + commit)

Summary:
  Source: `lean4-mlir/LeanMlir/Proofs/Tensor.lean` (8 axioms, 0 sorry)
          + BatchNorm.lean (3 axioms) + Attention.lean (1 axiom; SDPA subset)
  Target: `CATEPTMain/AFPBridge/CALCULUS/`
  Payoff: `vjp_comp`, `biPath_has_vjp`, `elemwiseProduct_has_vjp` —
          proved theorems that retire sorry stubs in CATEPT/EPT.

Prerequisite: None (independent of RS-MASTER-001..005).
Blocking condition: None — additive, no existing file moves.

Progress (2026-04-18):
  - CALC-001 DONE (pre-flight audit)
  - CALC-002 DONE (CALCULUS module skeleton landed)
  - CALC-003 DONE (Differentiation/Tensor port builds)
  - CALC-004 DONE (BatchNorm/Normalization port builds)
  - CALC-005 DONE (Attention softmax + SDPA subset port builds)
  - CALC-006 DONE (AFPBridge barrel import + table row)
  - CALC-007 DONE (`hyers_ulam_weight_stability` sorry retired in CATEPT bridge)
  - CALC-008 DONE (full build/audits + commit/push complete)
  - CALC-009 DONE (documented leverage map from lean4-mlir to CATEPT)

### Status: DONE
-/

/-!
## RS-MASTER-005  Post-restructure documentation update

After Phase 1 (minimum) is complete, update:
  - CATEPTMain/AFPBridge.lean   (barrel — updated incrementally in Phase 1)
  - CATEPTMain/AFPBridge/*/WORKLOG files — add note "Theories/ removed YYYY-MM-DD"
  - catept-main/AFPBRIDGE_RESTRUCTURE_PLAN.md — mark phases complete
  - This file (RESTRUCTURE_WORKLOG.lean) — update record statuses

### Status: TODO
-/
