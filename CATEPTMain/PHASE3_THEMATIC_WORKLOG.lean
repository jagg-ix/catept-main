/-!
# AFPBridge Phase 3 — Thematic Regrouping — Worklog

Scope:
  Optionally reorganise all 31 AFPBridge modules from a flat list into
  six thematic subdirectories. This changes Lean namespaces project-wide
  and requires a migration script. It is deliberately deferred until
  Phase 1 and Phase 2 are complete.

Parent orchestration:
  → CATEPTMain/AFPBridge/RESTRUCTURE_WORKLOG.lean  (RS-MASTER-004)

Prerequisite:
  RS-P1-VALIDATE DONE AND RS-P2-VALIDATE DONE (or explicit DEFER on P2).

WARNING:
  This phase changes `CATEPTMain.MOD` → `CATEPTMain.THEME.MOD`
  for every module. Every file across the entire repo that imports
  an AFPBridge module must be updated. Do NOT start without a migration
  script and a clean Phase 1 baseline.

Default stance: OPTIONAL — only proceed if the team agrees the namespace
  clarity benefit outweighs the migration cost.
-/

/-!
## RS-P3-PLAN  Thematic namespace map — P2

### Proposed target structure

```
CATEPTMain/
├── Core/               ← Framework, L2TimeIntegral, PHQ (stub), PDC (stub), MTN
├── Analysis/           ← FOU, LAPL, LSI, CPM, ODE, MODE
├── Geometry/           ← SM, MINK, NoFTL, OCT, QUAT, GYR (stub)
├── Quantum/            ← QUANTUM, IMD, PM, CBO, HSTP, SCHTZ (stub)
├── GaugeTheory/        ← FEYNCALC, QCD, ELECTROWEAK, FBD, LDO, EQFTRTFT
└── CATEPT/             ← CATEPT, EPT, QFT
```

### Old → new namespace mapping

| Old namespace                      | New namespace                       | Theme       |
|------------------------------------|-------------------------------------|-------------|
| CATEPTMain.Framework     | CATEPTMain.Core.Framework           | Core        |
| CATEPTMain.MTN           | CATEPTMain.Core.MTN                 | Core        |
| CATEPTMain.PHQ           | CATEPTMain.Core.PHQ                 | Core        |
| CATEPTMain.PDC           | CATEPTMain.Core.PDC                 | Core        |
| CATEPTMain.FOU           | CATEPTMain.Analysis.FOU             | Analysis    |
| CATEPTMain.LAPL          | CATEPTMain.Analysis.LAPL            | Analysis    |
| CATEPTMain.LSI           | CATEPTMain.Analysis.LSI             | Analysis    |
| CATEPTMain.CPM           | CATEPTMain.Analysis.CPM             | Analysis    |
| CATEPTMain.ODE           | CATEPTMain.Analysis.ODE             | Analysis    |
| CATEPTMain.MODE          | CATEPTMain.Analysis.MODE            | Analysis    |
| CATEPTMain.SM            | CATEPTMain.Geometry.SM              | Geometry    |
| CATEPTMain.MINK          | CATEPTMain.Geometry.MINK            | Geometry    |
| CATEPTMain.NoFTL         | CATEPTMain.Geometry.NoFTL           | Geometry    |
| CATEPTMain.OCT           | CATEPTMain.Geometry.OCT             | Geometry    |
| CATEPTMain.QUAT          | CATEPTMain.Geometry.QUAT            | Geometry    |
| CATEPTMain.GYR           | CATEPTMain.Geometry.GYR             | Geometry    |
| CATEPTMain.QUANTUM       | CATEPTMain.Quantum.QUANTUM          | Quantum     |
| CATEPTMain.IMD           | CATEPTMain.Quantum.IMD              | Quantum     |
| CATEPTMain.PM            | CATEPTMain.Quantum.PM               | Quantum     |
| CATEPTMain.CBO           | CATEPTMain.Quantum.CBO              | Quantum     |
| CATEPTMain.HSTP          | CATEPTMain.Quantum.HSTP             | Quantum     |
| CATEPTMain.SCHTZ         | CATEPTMain.Quantum.SCHTZ            | Quantum     |
| CATEPTMain.FEYNCALC      | CATEPTMain.GaugeTheory.FEYNCALC     | GaugeTheory |
| CATEPTMain.QCD           | CATEPTMain.GaugeTheory.QCD          | GaugeTheory |
| CATEPTMain.ELECTROWEAK   | CATEPTMain.GaugeTheory.ELECTROWEAK  | GaugeTheory |
| CATEPTMain.FBD           | CATEPTMain.GaugeTheory.FBD          | GaugeTheory |
| CATEPTMain.LDO           | CATEPTMain.GaugeTheory.LDO          | GaugeTheory |
| CATEPTMain.EQFTRTFT      | CATEPTMain.GaugeTheory.EQFTRTFT     | GaugeTheory |
| CATEPTMain.CATEPT        | CATEPTMain.CATEPT.CATEPT            | CATEPT      |
| CATEPTMain.EPT           | CATEPTMain.CATEPT.EPT               | CATEPT      |
| CATEPTMain.QFT           | CATEPTMain.CATEPT.QFT               | CATEPT      |

### `lakefile.lean` / `lakefile.toml` changes required

The module root stays `CATEPTMain` but the barrel file
`CATEPTMain/AFPBridge.lean` would be replaced by:
  `CATEPTMain/Core.lean`
  `CATEPTMain/Analysis.lean`
  `CATEPTMain/Geometry.lean`
  `CATEPTMain/Quantum.lean`
  `CATEPTMain/GaugeTheory.lean`
  `CATEPTMain/CATEPT.lean`  (rename: avoid name clash with AFPBridge/CATEPT/)

Or keep a thin `AFPBridge.lean` that imports all six new barrels (backward
compatible, zero consumer changes).

Status: TODO
-/

/-!
## RS-P3-SCRIPT  Migration script design — P1

A `scripts/migrate_phase3.sh` script should handle all renames before
any manual editing. Structure:

```bash
#!/usr/bin/env bash
# migrate_phase3.sh — AFPBridge thematic regrouping
set -euo pipefail
BASE=CATEPTMain

declare -A THEME_MAP=(
  [Framework]=Core  [MTN]=Core  [PHQ]=Core  [PDC]=Core
  [FOU]=Analysis    [LAPL]=Analysis  [LSI]=Analysis
  [CPM]=Analysis    [ODE]=Analysis   [MODE]=Analysis
  [SM]=Geometry     [MINK]=Geometry  [NoFTL]=Geometry
  [OCT]=Geometry    [QUAT]=Geometry  [GYR]=Geometry
  [QUANTUM]=Quantum [IMD]=Quantum    [PM]=Quantum
  [CBO]=Quantum     [HSTP]=Quantum   [SCHTZ]=Quantum
  [FEYNCALC]=GaugeTheory  [QCD]=GaugeTheory  [ELECTROWEAK]=GaugeTheory
  [FBD]=GaugeTheory       [LDO]=GaugeTheory  [EQFTRTFT]=GaugeTheory
  [CATEPT]=CATEPT   [EPT]=CATEPT     [QFT]=CATEPT
)

for MOD in "${!THEME_MAP[@]}"; do
  THEME="${THEME_MAP[$MOD]}"
  mkdir -p "$BASE/$THEME"
  mv "$BASE/AFPBridge/$MOD" "$BASE/$THEME/$MOD"
  # Update namespace declarations inside moved files
  find "$BASE/$THEME/$MOD" -name "*.lean" -exec \
    sed -i '' "s/CATEPTMain\.AFPBridge\.$MOD/CATEPTMain.$THEME.$MOD/g" {} +
done

# Update all import paths across the entire repo
find "$BASE" -name "*.lean" -exec \
  sed -i '' 's/CATEPTMain\.AFPBridge\./CATEPTMain.PLACEHOLDER./g' {} +
# (Replace PLACEHOLDER with actual theme per module — needs per-module passes)
```

NOTE: The bulk `PLACEHOLDER` approach above is pseudo-code. The actual
script must do one sed pass per module (30 passes), not one global pass,
to correctly remap each module to its theme without collisions.

### Script location
  `catept-main/scripts/migrate_phase3.sh`

### After running the script
  1. Fix any namespace declarations `namespace CATEPTMain.*`
     that were not caught by the sed passes.
  2. Update `lakefile.lean` module root and barrel imports.
  3. Run `lake build` and fix residual import errors.

Status: TODO
-/

/-!
## RS-P3-PRELUDE-FILES  Update Prelude namespace declarations — P1

Each module has a `*Prelude.lean` with an explicit `namespace` declaration.
After the file move, the `namespace` line must be updated too. Example:

  Before:
    `namespace CATEPTMain.FEYNCALC`
  After:
    `namespace CATEPTMain.GaugeTheory.FEYNCALC`

The migration script handles this via the `sed` passes above, but verify
each Prelude manually for namespace correctness after the script runs:

```bash
for THEME in Core Analysis Geometry Quantum GaugeTheory CATEPT; do
  grep -r "namespace CATEPTMain" CATEPTMain/$THEME/ 2>/dev/null
done
```
Expected: no matches (all namespace declarations updated).

Status: TODO
-/

/-!
## RS-P3-BARREL  Replace AFPBridge.lean barrel with thematic barrels — P1

### Option A — Thematic barrels (clean break)

Create six new barrel files:
  `CATEPTMain/Core.lean`, `CATEPTMain/Analysis.lean`,
  `CATEPTMain/Geometry.lean`, `CATEPTMain/Quantum.lean`,
  `CATEPTMain/GaugeTheory.lean`, `CATEPTMain/CATEPT.lean`

Each lists `import CATEPTMain.THEME.MOD.*` lines for its modules.
Delete `CATEPTMain/AFPBridge.lean`.

### Option B — Thin compatibility shim (recommended for incremental rollout)

Keep `CATEPTMain/AFPBridge.lean` as a thin shim that only imports
the six thematic barrels:
  ```lean
  import CATEPTMain.Core
  import CATEPTMain.Analysis
  import CATEPTMain.Geometry
  import CATEPTMain.Quantum
  import CATEPTMain.GaugeTheory
  import CATEPTMain.CATEPT
  ```

Any consumer that currently imports `CATEPTMain` continues to
work. The shim can be removed later once all consumers are updated.

Recommendation: Option B. Zero consumer breakage.

Status: TODO
-/

/-!
## RS-P3-VALIDATE  Phase 3 validation — P0

After all file moves, namespace updates, and barrel changes:

1. Full build:
   ```bash
   lake exe cache get
   lake build
   ```
   Expected: EXIT 0.

2. Namespace sanity check — no `AFPBridge.` in moved files:
   ```bash
   for THEME in Core Analysis Geometry Quantum GaugeTheory CATEPT; do
     grep -r "AFPBridge\." CATEPTMain/$THEME/ --include="*.lean" | grep -v WORKLOG
   done
   ```
   Expected: no matches (all internal namespace refs updated).

3. Legacy shim still resolves (if using Option B):
   ```bash
   grep "^import" CATEPTMain/AFPBridge.lean
   # Should list 6 thematic barrels, nothing else
   ```

4. Sorry/axiom regression check:
   ```bash
   grep -r "sorry" CATEPTMain/ --include="*.lean" | grep -v WORKLOG | wc -l
   grep -r "^axiom" CATEPTMain/ --include="*.lean" | wc -l
   ```
   Must equal Phase 1 baseline counts.

5. Integration consistency check:
   ```bash
   lake build CATEPTMain.Integration
   ```
   If the Integration module imports any AFPBridge modules, it must still build.

6. Commit:
   ```bash
   git add -A
   git commit -m "refactor: AFPBridge thematic regrouping (Phase 3)"
   git tag phase3-thematic-done
   ```

7. Update master orchestration record RS-MASTER-004 status → DONE.
   Update RS-MASTER-005 to trigger documentation cleanup.

Status: TODO
-/
