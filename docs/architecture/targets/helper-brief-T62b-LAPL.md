# Helper task brief — T62b: extract Analysis/LAPL as `catept-domain-lapl`

**Assigned to:** copilot-claude (or any helper that's not currently editing the
shared `~/lab/tau/tau-information-dynamics/catept-main` checkout)
**Estimated effort:** 30–45 min on a warm Mathlib cache.
**Prereqs landed on `main`:** T61 (commit `d28155fc6`) — the AFP-framework
sibling and the QUANTUM domain bundle.
**Pattern reference:** T61 (QUANTUM bundle) and T62a (QUAT bundle) — both used
the same playbook; this is the third application of it.

## What to do

Extract `CATEPTMain/Analysis/LAPL/*.lean` (5 files / 378 LoC) into a new
sibling repo `jagg-ix/catept-domain-lapl` under namespace
`CATEPTPluginDomainLapl`. Replace the in-tree files with re-export shims that
preserve the `CATEPTMain.Analysis.LAPL.*` namespace. Pin the sibling in
`catept-main/lakefile.lean` and push the commit directly to `main` (no PR).

## Source structure

```
CATEPTMain/Analysis/LAPL/
  LAPLPrelude.lean        88 LoC  -- prelude (depends on AFPBridgeFramework)
  Laplace_Transform.lean  90 LoC  -- depends on LAPLPrelude
  Convolution_Theorem.lean 68 LoC -- depends on LAPLPrelude
  Inversion.lean          62 LoC  -- depends on Convolution_Theorem + Laplace_Transform
  LAPL_WORKLOG.lean       70 LoC  -- historical log (preserve verbatim)
```

Namespaces in source: `CATEPTMain.Analysis.LAPL` (root) plus three sub-namespaces:
`.Convolution_Theorem`, `.Inversion`, `.Laplace_Transform`.

External imports (the only ones besides `Mathlib.*`):
```
import CATEPTMain.Core.Framework.AFPBridgeFramework
```

External consumers (will keep working through the shims):
- `CATEPTMain/Bridges.lean`
- `CATEPTMain/Integration/CATEPTSelfConsistency.lean`

## Exact recipe (mirror of T61/T62a)

### Step 1 — Create + push the sibling repo

```bash
gh repo create jagg-ix/catept-domain-lapl --public --license MIT \
  --description "LAPL (Laplace transform) domain bundle (5 files, 378 LoC) extracted from catept-main."

cd ~/lab/tau/tau-information-dynamics
git clone https://github.com/jagg-ix/catept-domain-lapl.git
cd catept-domain-lapl

# lean-toolchain
echo 'leanprover/lean4:v4.29.0' > lean-toolchain

# .gitignore
cat > .gitignore <<'EOF'
.lake/
build/
.lean/
*.olean
*.ilean
*.trace
*.hash
.recovery/
lake-manifest.json
.DS_Store
EOF

# lakefile.lean — Mathlib LAST so its pin wins; afp-framework before it
cat > lakefile.lean <<'EOF'
import Lake
open Lake DSL

package «catept-domain-lapl» where
  leanOptions := #[]

require «catept-plugin-afp-framework» from git
  "https://github.com/jagg-ix/catept-plugin-afp-framework.git" @ "27c58a8337eca6cf2ec684602c0cd6cc37d2dc52"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"

@[default_target]
lean_lib «CATEPTPluginDomainLapl» where
  -- Default glob picks up all submodules under CATEPTPluginDomainLapl/.
EOF
```

### Step 2 — Copy + rewrite files into the sibling

Apply three sed substitutions to each source file:

1. `CATEPTMain.Analysis.LAPL` → `CATEPTPluginDomainLapl`  (root namespace)
2. `import CATEPTMain.Core.Framework.AFPBridgeFramework` → `import CATEPTPluginAFPFramework.IntegrationBridge`
3. `open CATEPTMain.Core.Framework.TacticStubs` → `open CATEPTPluginAFPFramework.TacticStubs`
   (and the parent-namespace variant `open CATEPTMain.Core.Framework` → `open CATEPTPluginAFPFramework`)

```bash
SRC=~/lab/tau/tau-information-dynamics/catept-main/CATEPTMain/Analysis/LAPL
DST=CATEPTPluginDomainLapl
mkdir -p "$DST"
for f in "$SRC"/*.lean; do
  sed \
    -e 's|CATEPTMain\.Analysis\.LAPL|CATEPTPluginDomainLapl|g' \
    -e 's|^import CATEPTMain\.Core\.Framework\.AFPBridgeFramework$|import CATEPTPluginAFPFramework.IntegrationBridge|' \
    -e 's|^open CATEPTMain\.Core\.Framework\.TacticStubs$|open CATEPTPluginAFPFramework.TacticStubs|' \
    -e 's|^open CATEPTMain\.Core\.Framework$|open CATEPTPluginAFPFramework|' \
    "$f" > "$DST/$(basename "$f")"
done
```

Sanity-check: `grep -nE "CATEPTMain" CATEPTPluginDomainLapl/*.lean` — only
matches inside docstrings/comments are OK; any `import` or `open` lines mean
a substitution was missed.

### Step 3 — Umbrella file

```lean
-- CATEPTPluginDomainLapl.lean (in the repo root)
import CATEPTPluginDomainLapl.LAPLPrelude
import CATEPTPluginDomainLapl.Laplace_Transform
import CATEPTPluginDomainLapl.Convolution_Theorem
import CATEPTPluginDomainLapl.Inversion

/-!
# catept-domain-lapl — umbrella
-/
```

**Watch out:** Lean 4 requires `import` lines BEFORE any docstring/code. The
docstring goes AFTER the imports.

### Step 4 — Build + push + tag

```bash
lake update            # populates .lake/ + lake-manifest.json
lake exe cache get     # warms Mathlib oleans
lake build             # should hit ~2300 jobs and finish in ~30 s on warm cache

git add -A
git commit -m "T62b: extract LAPL domain bundle from catept-main"
git push
git tag v0.1.0
git push origin v0.1.0
SIBLING_SHA=$(git rev-parse HEAD)
echo "Sibling pin SHA: $SIBLING_SHA"
```

### Step 5 — catept-main side wiring (in a worktree, NOT the shared checkout)

```bash
cd ~/lab/tau/tau-information-dynamics/catept-main
git fetch origin main
git worktree add /private/tmp/catept-main-t62b-lapl -b feat/<your-handle>/t62b-lapl origin/main
cd /private/tmp/catept-main-t62b-lapl
```

#### 5a. Add the sibling pin to `lakefile.lean`

Insert AFTER the existing `require «catept-domain-quat» from git` block (or
after the latest `require «catept-domain-*»` in the file):

```lean
-- catept-domain-lapl: extracted CATEPTMain.Analysis.LAPL.* (5 files / 378 LoC).
-- 21st sibling, T62b — third domain-bundle extraction.
require «catept-domain-lapl» from git
  "https://github.com/jagg-ix/catept-domain-lapl.git" @ "<SIBLING_SHA from step 4>"
```

#### 5b. Replace the 5 in-tree files with shims

For **each** of LAPLPrelude / Laplace_Transform / Convolution_Theorem /
Inversion, write a shim of this shape (note the chained-import rule from the
T61 lessons learned: every shim must `import` the in-tree shims for any
sibling files it transitively depends on, NOT just the sibling):

```lean
-- CATEPTMain/Analysis/LAPL/LAPLPrelude.lean (shim)
import CATEPTPluginDomainLapl.LAPLPrelude

set_option autoImplicit false
namespace CATEPTMain.Analysis.LAPL
export CATEPTPluginDomainLapl (
  -- list every public def/theorem/abbrev/structure/class/inductive
  -- declared in the original LAPLPrelude.lean
)
end CATEPTMain.Analysis.LAPL
```

```lean
-- CATEPTMain/Analysis/LAPL/Laplace_Transform.lean (shim) -- depends on LAPLPrelude
import CATEPTMain.Analysis.LAPL.LAPLPrelude          -- ← chained import
import CATEPTPluginDomainLapl.Laplace_Transform

set_option autoImplicit false
namespace CATEPTMain.Analysis.LAPL.Laplace_Transform
export CATEPTPluginDomainLapl.Laplace_Transform (
  -- list every public symbol in the sub-namespace
)
end CATEPTMain.Analysis.LAPL.Laplace_Transform
```

…and similarly for `Convolution_Theorem.lean` (chains LAPLPrelude),
`Inversion.lean` (chains LAPLPrelude + Convolution_Theorem + Laplace_Transform),
and `LAPL_WORKLOG.lean` (leave unchanged — it's a docs file, not a public surface).

To enumerate the symbols per file:

```bash
SRC=~/lab/tau/tau-information-dynamics/catept-main/CATEPTMain/Analysis/LAPL
for f in LAPLPrelude Laplace_Transform Convolution_Theorem Inversion; do
  echo "--- $f ---"
  grep -hE "^(noncomputable[[:space:]]+)?(def|theorem|abbrev|structure|class|inductive|opaque|axiom|lemma)[[:space:]]" "$SRC/$f.lean" \
    | sed -E 's/^(noncomputable[[:space:]]+)?(def|theorem|abbrev|structure|class|inductive|opaque|axiom|lemma)[[:space:]]+([A-Za-z_][A-Za-z_0-9]*).*/\3/' \
    | sort -u
done
```

**Important:** the regex must match `axiom` and `lemma` too — many AFP-port
files declare AFP carriers as `axiom`s, and shims that miss them will fail
downstream with `Unknown identifier <axiom_name>` (T62a hit this on
`unitQuat_inv_eq_conj`).

#### 5c. Build + verify

```bash
lake update catept-domain-lapl
lake build CATEPTMain.Analysis.LAPL.Inversion        # whole bundle through shims
lake build CATEPTMain.Bridges                        # umbrella consumer
lake build CATEPTMain.Integration.CATEPTSelfConsistency  # other consumer
```

All three should be green.

### Step 6 — Push to main directly

(Per maintainer direction: no PR review for sibling-split work.)

```bash
git add CATEPTMain/Analysis/LAPL/*.lean lakefile.lean lake-manifest.json
git commit -m "T62b: extract LAPL domain bundle as 21st sibling"
git rebase origin/main          # in case main advanced while you were building
git push origin HEAD:main
```

### Step 7 — Worklog + cleanup

```bash
DB=~/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PYTHONPATH=~/lab/tau/tau-information-dynamics/entropic-worklog-tool \
  python3 -c "from ept_worklog.cli import main; import sys; \
    sys.argv=['wl','--db','$DB','add-task',
              '--code','catept_arch_t62b_extract_lapl_20260425',
              '--title','T62b: extract Analysis/LAPL as catept-domain-lapl (21st sibling)',
              '--category','plugin-architecture','--priority','p1','--status','done',
              '--tags','t62b,domain-bundle,sibling-extract',
              '--details','LAPL bundle (5 files / 378 LoC) extracted to jagg-ix/catept-domain-lapl. Pinned in catept-main lakefile. Bridges + CATEPTSelfConsistency green via shims.']; \
    main()"

# Clean up worktree disk usage
cd /private/tmp/catept-main-t62b-lapl && rm -rf .lake
cd ~/lab/tau/tau-information-dynamics/catept-domain-lapl && rm -rf .lake

# Optional: delete the feature branch on remote if it was pushed
cd ~/lab/tau/tau-information-dynamics/catept-main
git push origin --delete feat/<your-handle>/t62b-lapl 2>/dev/null || true
```

## Done criteria

- [ ] `jagg-ix/catept-domain-lapl` v0.1.0 published, `lake build` green standalone.
- [ ] catept-main `lakefile.lean` pins the new sibling.
- [ ] 4 in-tree files (LAPLPrelude, Laplace_Transform, Convolution_Theorem, Inversion) are re-export shims; LAPL_WORKLOG unchanged.
- [ ] `lake build CATEPTMain.Bridges` green in catept-main worktree post-shim.
- [ ] One commit pushed directly to `main`.
- [ ] Worklog task `catept_arch_t62b_extract_lapl_20260425` marked `done`.

## Failure modes to watch for

1. **`Unknown identifier X`** when building a downstream consumer — means the
   shim chain is broken. Re-check that every shim imports the upstream
   in-tree shims (not just the sibling). See T61 lessons-learned in
   `.t61_step0_patches/t61_quantum/README.md` (caveats section).
2. **`invalid 'import' command, it must be used in the beginning of the file`** —
   the umbrella file or a shim has its docstring before its imports. Move
   imports to the top.
3. **Disk pressure** — sibling `.lake/` is ~7 GiB. Clean it after build:
   `rm -rf catept-domain-lapl/.lake`. Build via the catept-main worktree's
   `.lake/` whenever possible (workstation-friendly convention from the
   playbook).
4. **Race with another worker on the shared catept-main checkout** — always
   work in `/private/tmp/catept-main-<handle>-<task>` worktree, never in
   `~/lab/tau/tau-information-dynamics/catept-main` directly.

## Parallel-extractable bundles (after T62b — same playbook applies)

These are clean cuts (no inter-bundle deps, only AFPBridgeFramework + Mathlib):

| Bundle | Files | LoC | Suggested sibling name |
|---|---|---|---|
| `CATEPTMain/Quantum/SCHTZ` | 2 | 385 | `catept-domain-schtz` |
| `CATEPTMain/Core/MTN` | 5 | 383 | `catept-domain-mtn` |
| `CATEPTMain/Core/PDC` | 2 | 358 | `catept-domain-pdc` |
| `CATEPTMain/Geometry/MINK` | 5 | 404 | `catept-domain-mink` |

Each takes ~30–45 min by the same playbook. Three parallel helpers could
land four siblings in one wall-clock half-hour.
