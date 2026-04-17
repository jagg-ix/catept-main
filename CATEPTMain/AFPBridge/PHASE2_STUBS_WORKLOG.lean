/-!
# AFPBridge Phase 2 — Consolidate Stub-Only Modules — Worklog

Scope:
  Four modules contain only a `*Prelude.lean` and a `*_WORKLOG.lean`
  with no substantive proven content (all definitions are `sorry` stubs
  or `-- TODO` placeholders). This phase decides whether and how to
  consolidate them.

  Modules in scope: GYR, PDC, PHQ, SCHTZ

Parent orchestration:
  → CATEPTMain/AFPBridge/RESTRUCTURE_WORKLOG.lean  (RS-MASTER-003)

Prerequisite:
  RS-P1-VALIDATE DONE (Phase 1 complete, clean build confirmed).

Next phase:
  → CATEPTMain/AFPBridge/PHASE3_THEMATIC_WORKLOG.lean

Default stance:
  DEFER stub consolidation until at least one stub module has real Phase 2
  content, to avoid moving files twice. RS-P2-ASSESS makes the call.
-/

/-!
## RS-P2-ASSESS  Assess stub module readiness — P1 (decision gate)

Before any consolidation, evaluate each stub module against the
promotion criteria below.

### Stub modules and AFP source mapping

| Module | AFP source (Isabelle)              | Prelude content                            |
|--------|------------------------------------|--------------------------------------------|
| GYR    | Gyrovector_Spaces                  | type stubs for GyroVec, GyroGroup ops      |
| PDC    | Probabilistic_Directed_Acyclic_Graphs | type stubs for DAG, conditional prob    |
| PHQ    | Physical_Quantities                | dimension algebra stubs (SI units)         |
| SCHTZ  | Schroeder_Bernstein_Cantor         | set-theoretic bijection type stubs         |

### Promotion criteria (any one → keep as standalone module)

A stub module should be kept separate (not merged) if:
  1. It has an active Phase 2 proof plan in its WORKLOG
  2. Another module imports its types (check with grep)
  3. Its AFP source has >500 lines (complex enough to warrant standalone)

### Assessment procedure

For each module MOD ∈ {GYR, PDC, PHQ, SCHTZ}:

```bash
# 1. Check if any other file imports this module
grep -r "AFPBridge\.$MOD\." CATEPTMain/ --include="*.lean" \
  | grep -v "$MOD/" | grep -v WORKLOG

# 2. Count lines in the AFP source (approximate)
wc -l CATEPTMain/AFPBridge/$MOD/*Prelude.lean

# 3. Read the WORKLOG for Phase 2 plans
cat CATEPTMain/AFPBridge/$MOD/*WORKLOG.lean
```

### Decision matrix (fill in after running assessment)

| Module | Imported by others? | AFP size | Phase 2 plan? | Decision       |
|--------|---------------------|----------|----------------|----------------|
| GYR    | ?                   | ?        | ?              | DEFER / MERGE  |
| PDC    | ?                   | ?        | ?              | DEFER / MERGE  |
| PHQ    | ?                   | ?        | ?              | DEFER / MERGE  |
| SCHTZ  | ?                   | ?        | ?              | DEFER / MERGE  |

Status: TODO
-/

/-!
## RS-P2-MERGE  Merge stub modules into Stubs.lean — P2 (conditional)

Execute only if RS-P2-ASSESS concludes all four modules should be merged.
If any module has Decision=DEFER, skip that module.

### Procedure for each module MOD being merged

1. Copy namespace content into `AFPBridge/Stubs.lean`:
   ```lean
   -- ── MOD: <AFP source name> (stub) ─────────────────────────────────
   namespace CATEPTMain.AFPBridge.MOD
   -- paste content of MODPrelude.lean here (minus the import header)
   end CATEPTMain.AFPBridge.MOD
   ```

2. Append WORKLOG summary to `AFPBridge/STUBS_WORKLOG.lean`:
   Copy the Phase 2 plans from `MOD/MOD_WORKLOG.lean` into the
   consolidated worklog under a `## MOD` section.

3. Update the barrel `CATEPTMain/AFPBridge.lean`:
   - Remove `import CATEPTMain.AFPBridge.MOD.MODPrelude`
   + Add (once) `import CATEPTMain.AFPBridge.Stubs`

4. Delete the now-empty module directory:
   ```bash
   rm -rf CATEPTMain/AFPBridge/MOD/
   ```

5. Build validation:
   ```bash
   lake build CATEPTMain.AFPBridge
   ```

### Target structure after full merge (all 4 modules)

```
AFPBridge/
├── Stubs.lean          ← GYR + PDC + PHQ + SCHTZ namespaces
├── STUBS_WORKLOG.lean  ← consolidated Phase 2 plans
```

### Notes
  - Keep GYRPrelude's `import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework`
    at the top of Stubs.lean (only once).
  - Namespace aliases (`alias`) are NOT needed — the namespace names stay
    identical (e.g., `CATEPTMain.AFPBridge.GYR` still exists, just in Stubs.lean).

Status: TODO (conditional on RS-P2-ASSESS)
-/

/-!
## RS-P2-VALIDATE  Phase 2 validation — P0

After stub consolidation (or explicit DEFER decision):

1. If merged: full build must pass with zero new errors:
   ```bash
   lake exe cache get
   lake build
   ```

2. If deferred: document the decision in RS-P2-ASSESS status field
   and proceed to Phase 3 without any file moves.

3. Verify stub namespaces still accessible (if merged):
   ```bash
   # Each stub namespace should still be reachable
   grep -r "AFPBridge\.GYR\." CATEPTMain/ --include="*.lean" | head -5
   ```

4. No orphan directories remain:
   ```bash
   find CATEPTMain/AFPBridge -maxdepth 1 -type d | sort
   ```
   Compare to expected list (stub dirs removed if merged, kept if deferred).

5. Commit if changes were made:
   ```bash
   git add -A
   git commit -m "refactor: consolidate AFPBridge stub modules (Phase 2)"
   git tag phase2-stubs-done
   ```

Proceed to Phase 3:
  → CATEPTMain/AFPBridge/PHASE3_THEMATIC_WORKLOG.lean  (RS-P3-PLAN)

Status: TODO
-/
