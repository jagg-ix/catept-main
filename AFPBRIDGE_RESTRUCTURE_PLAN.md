# AFPBridge Restructuring Plan

**Goal**: Flatten `CATEPTMain/AFPBridge/` from a 3-level tree
(`AFPBridge/MODULE/Theories/File.lean`) to a 2-level tree
(`AFPBridge/MODULE/File.lean`), consolidate stub-only modules, and
optionally regroup by domain. No Lean source content changes — only file
moves and import-path updates.

---

## Current structure summary

```
AFPBridge/
├── Framework/          (1 file, no Theories/)
├── L2TimeIntegral.lean (top-level singleton)
│
├── ── AFP ISA bridge (Theories/ layer) ─────────────────────────────
├── CBO/    Theories/  18 files
├── CPM/    Theories/   3 files
├── FOU/    Theories/   6 files
├── HSTP/   Theories/  15 files
├── IMD/    Theories/  13 files
├── LAPL/   Theories/   3 files
├── LSI/    Theories/   2 files
├── MINK/   Theories/   3 files
├── MODE/   Theories/   2 files
├── MTN/    Theories/   3 files
├── NoFTL/  Theories/  26 files
├── OCT/    Theories/   2 files
├── ODE/    Theories/   3 files
├── PM/     Theories/   3 files
├── QFT/    Theories/   1 file
├── QUAT/   Theories/   1 file
├── SM/     Theories/  12 files
│
├── ── New bridge modules (flat already) ────────────────────────────
├── CATEPT/             7 files
├── ELECTROWEAK/        3 files
├── EPT/                2 files
├── EQFTRTFT/           7 files
├── FBD/                5 files
├── FEYNCALC/          10 files
├── LDO/                9 files
├── QCD/                5 files
├── QUANTUM/           10 files
│
└── ── Stub-only (Prelude + WORKLOG, no Theories/) ──────────────────
    ├── GYR/            2 files
    ├── PDC/            2 files
    ├── PHQ/            2 files
    └── SCHTZ/          2 files
```

**Total**: 31 subdirectories, ~180 Lean files across 3 depth levels.

---

## Phase 1 — Remove the `Theories/` layer (pure mechanical)

**Action**: For each of the 17 AFP-ISA modules that have a `Theories/`
subdirectory, move all `*.lean` files up one level into the module root,
then delete the empty `Theories/` directory.

**For each module `MOD`**:
1. `mv AFPBridge/MOD/Theories/*.lean AFPBridge/MOD/`
2. `rmdir AFPBridge/MOD/Theories/`
3. In `AFPBridge.lean`: replace `import CATEPTMain.AFPBridge.MOD.Theories.X`
   → `import CATEPTMain.AFPBridge.MOD.X`
4. Search for any cross-module imports within the moved files (unlikely but
   verify with `grep -r "AFPBridge.MOD.Theories"` after each move).

**Modules and file counts**:

| Module  | Files | Notes |
|---------|------:|-------|
| CBO     |  18   | Core operator algebra; many internal cross-imports likely |
| NoFTL   |  26   | Largest single module; internal deps probable |
| HSTP    |  15   | Hilbert space tensor product |
| IMD     |  13   | Quantum information / Markov |
| SM      |  12   | Smooth manifolds |
| FOU     |   6   | Fourier series |
| CPM     |   3   | Coproduct measure |
| LAPL    |   3   | Laplace transform |
| MINK    |   3   | Minkowski theorem |
| MTN     |   3   | Matrix tensor / Kronecker |
| ODE     |   3   | Picard-Lindelöf, Euler, Flow |
| PM      |   3   | Projective measurements |
| LSI     |   2   | Lebesgue–Stieltjes |
| MODE    |   2   | Matrix ODEs |
| OCT     |   2   | Octonions |
| QFT     |   1   | QFT/Ising model |
| QUAT    |   1   | Unit quaternions |

**Risk**: Low. The only change is import path prefix
`AFPBridge.MOD.Theories.` → `AFPBridge.MOD.`. No definitions change.

**Check for internal cross-imports** (run before moving each module):
```bash
grep -r "AFPBridge.MOD.Theories" AFPBridge/MOD/Theories/
```

**Recommended order**: Start with single-file modules (QFT, QUAT, OCT,
LSI, MODE) to validate the workflow, then proceed to larger modules.

---

## Phase 2 — Consolidate stub-only modules

Four modules contain only a `*Prelude.lean` and a `*_WORKLOG.lean` with
no substantive Lean content (all definitions are `sorry` stubs or
`-- TODO`):

| Module | Content |
|--------|---------|
| GYR    | `GYRPrelude.lean` — gyrovector space type stubs |
| PDC    | `PDCPrelude.lean` — DAG/probability stubs |
| PHQ    | `PHQPrelude.lean` — physical quantities stubs |
| SCHTZ  | `SCHTZPrelude.lean` — Schröder–Bernstein stubs |

**Option A (recommended)**: Keep as separate directories but move each
`*Prelude.lean` inline into a single `AFPBridge/Stubs.lean` that re-exports
all four namespaces. Collapse the four WORKLOG files into a single
`AFPBridge/STUBS_WORKLOG.lean`. This removes 4 directories and 8 files,
replacing them with 2.

**Option B**: Leave stub modules as-is until they graduate to Phase 2.
Avoids any churn on non-blocking items.

Recommendation: **Option B** until at least one stub module has real
content, to avoid re-doing the move twice.

---

## Phase 3 — Thematic regrouping (optional, Phase 2+)

Once Phase 1 is done, the 31 modules could be regrouped into 5–6
thematic subdirectories. This changes the Lean namespace
(`CATEPTMain.AFPBridge.MOD` → `CATEPTMain.Physics.MOD` etc.) and requires
updating `lakefile.lean` / `lakefile.toml` if module roots are affected.

**Proposed grouping**:

```
AFPBridge/
├── Core/               Framework, L2TimeIntegral, PHQ, PDC, MTN
├── Analysis/           FOU, LAPL, LSI, CPM, ODE, MODE
├── Geometry/           SM, MINK, NoFTL, OCT, QUAT, GYR
├── Quantum/            QUANTUM, IMD, PM, CBO, HSTP, SCHTZ
├── GaugeTheory/        FEYNCALC, QCD, ELECTROWEAK, FBD, LDO, EQFTRTFT
└── CATEPT/             CATEPT, EPT, QFT
```

**Risk**: High — every module's Lean namespace changes. Defer until Phase 1
is complete and a migration script is available.

---

## Execution checklist (Phase 1)

```
[ ] 0. Commit current clean build as baseline (git tag pre-flatten)
[ ] 1. QFT  — move 1 file, update AFPBridge.lean
[ ] 2. QUAT — move 1 file, update AFPBridge.lean
[ ] 3. OCT  — move 2 files, update AFPBridge.lean
[ ] 4. LSI  — move 2 files, update AFPBridge.lean
[ ] 5. MODE — move 2 files, update AFPBridge.lean
[ ] 6. MTN  — move 3 files, update AFPBridge.lean
[ ] 7. CPM  — move 3 files, update AFPBridge.lean
[ ] 8. LAPL — move 3 files, update AFPBridge.lean
[ ] 9. MINK — move 3 files, update AFPBridge.lean
[10. ODE  — move 3 files, update AFPBridge.lean
[11. PM   — move 3 files, update AFPBridge.lean
[12. FOU  — move 6 files, update AFPBridge.lean
[13. SM   — move 12 files, check internal imports, update AFPBridge.lean
[14. IMD  — move 13 files, check internal imports, update AFPBridge.lean
[15. HSTP — move 15 files, check internal imports, update AFPBridge.lean
[16. CBO  — move 18 files, check internal imports, update AFPBridge.lean
[17. NoFTL — move 26 files, check internal imports, update AFPBridge.lean
[18. lake build -- verify clean
[19. git commit "feat: flatten AFPBridge Theories/ layer"
```

After each step, run `lake build CATEPTMain.AFPBridge.MOD` (just that
module) to confirm before moving to the next.

---

## Impact on `AFPBridge.lean` barrel file

The barrel file currently has ~120 import lines of the form:
```lean
import CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code
```
After Phase 1 these become:
```lean
import CATEPTMain.AFPBridge.CBO.Cblinfun_Code
```

A sed one-liner handles the bulk update per module:
```bash
sed -i '' 's/AFPBridge\.MOD\.Theories\./AFPBridge.MOD./g' CATEPTMain/AFPBridge.lean
```
(Replace `MOD` with the actual module name each time.)

---

## What does NOT change

- The 9 already-flat new bridge modules: CATEPT, ELECTROWEAK, EPT,
  EQFTRTFT, FBD, FEYNCALC, LDO, QCD, QUANTUM — no moves needed.
- `Framework/AFPBridgeFramework.lean` — already flat, 1 file.
- `L2TimeIntegral.lean` — already top-level singleton.
- All sorry budgets and proof content — pure mechanical renames.
