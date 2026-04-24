# Plugin sibling-repo split playbook

**Owner of this document:** maintainer of `jagg-ix/catept-main`.
**Last updated:** 2026-04-24 (T4.1 deliverable).
**Linked plan:** [`targets/target-4-plan.md`](targets/target-4-plan.md).

This is the operational manual for extracting a `CATEPTMain/Integration/`
plugin into its own GitHub repo and re-integrating it via `lake` pin.
Every step is numbered and either script-runnable or visually checkable.
No subjective sign-off appears.

The pattern is the one already used by `xiyin137/OSreconstruction` (pin
in `lakefile.lean`, consumed by `CATEPT/Bridges/OSReconstruction.lean`).

---

## Pilot: `HilleYosidaBridge`

`CATEPTMain/Integration/HilleYosidaBridge.lean` — 195 lines, 5 theorems
(`hilleYosida_integration_contract`, `proved_semigroup_growth_bound`,
`proved_resolvent_bound`, `contracting_has_optimal_growth_bound`,
`ns_heat_semigroup_abstract_theory_proved`).

**Why it is the pilot:**

| Criterion | Status |
|---|---|
| ≤ 3 `CATEPTMain.*` imports | **Yes** — zero `CATEPTMain.*` imports |
| No outgoing deps from other `Integration/*` plugins | **Yes** — only depends on the external `HilleYosida` pin |
| ≥ 1 theorem with a verifiable axiom signature | **Yes** — 5 theorems, all kernel-only |
| Author willing to maintain sibling | **Yes** — already wraps an external sibling pin (`HilleYosida` itself) |
| Incoming references from other plugins | **Zero** — no `Integration/*` file imports it |

**Bonus:** the pattern of wrapping an external pin is already proven
here (`HilleYosida` is itself a sibling repo).  The extraction is
essentially "promote the wrapper to its own repo so it can version
independently of `catept-main`."

**Target sibling repo:** `jagg-ix/catept-plugin-hille-yosida`.
**Target sibling namespace:** `CATEPTPluginHilleYosida.*`.
**Target re-import line in `catept-main`:**

```lean
import CATEPTPluginHilleYosida.IntegrationBridge
```

---

## Selection criteria — when picking a future pilot or batch

A plugin is a viable extraction target when **all four** hold:

1. **Few internal imports.** `grep -c "^import CATEPTMain\." <file>` returns
   ≤ 3.  More than 3 means the plugin is internally coupled and the
   extraction will leak transitive deps; pick a leaf instead.
2. **No outgoing `Integration/*` deps.**
   `grep -c "^import CATEPTMain\.Integration\." <file>` returns 0.
   Otherwise the extraction will pull a chain of plugins with it.
3. **Has at least one theorem with a verifiable axiom signature.**
   `grep -c "^theorem\|^lemma" <file>` returns ≥ 1, and at least one
   theorem can be checked with `#print axioms` for the axiom-gate
   regression test.  Plugins that only define structures with no
   theorems give nothing to the sibling CI to check.
4. **Author can take maintenance.**  The split changes the pin-bump
   cadence; without a maintainer the sibling will rot.

**Anti-pattern: don't pilot a plugin that is heavily imported.**  Run
`grep -l "import CATEPTMain.Integration.<Name>\b" CATEPTMain/Integration/*.lean | wc -l`.
A pilot should have **0 or 1** incoming references.  Migrating a
heavily-consumed plugin causes a cascade.

---

## Extraction steps (T4.2)

Run from a clean clone of `catept-main` on `main`.

1. **Fork the namespace.** Decide the sibling repo name and top-level
   module name.  Convention: `catept-plugin-<kebab-case>` for the repo;
   `CATEPTPlugin<UpperCamel>` for the module namespace.
2. **Create the new repo.** Initialise an empty public GitHub repo
   `jagg-ix/catept-plugin-<kebab>`.  Add `README.md` (initial
   placeholder) and `LICENSE` matching `catept-main`'s.
3. **Author `lakefile.lean`.** Use this template (filled in for the
   pilot — adapt the namespace and external requires):

   ```lean
   import Lake
   open Lake DSL

   package «catept-plugin-hille-yosida» where
     leanOptions := #[]

   require mathlib from git
     "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"

   require HilleYosida from git
     "https://github.com/jagg-ix/HilleYosida.git" @ "<sha>"

   @[default_target]
   lean_lib «CATEPTPluginHilleYosida» where
     roots := #[`CATEPTPluginHilleYosida]
   ```

   Pin Mathlib and any other deps to specific SHAs to match
   `catept-main/lake-manifest.json` at the moment of extraction.

4. **Author `lean-toolchain`.** Copy the file from `catept-main` so the
   toolchain matches.
5. **Move the source.** Create `CATEPTPluginHilleYosida/IntegrationBridge.lean`
   in the new repo with the contents of
   `CATEPTMain/Integration/HilleYosidaBridge.lean`, but:
   - Replace `namespace CATEPTMain.Integration.HilleYosidaBridge` (if
     present) with `namespace CATEPTPluginHilleYosida`.
   - Drop any `import CATEPTMain.*` lines (none expected for the pilot
     since it has zero such imports).
   - Re-prefix any internal references that used the old namespace.
6. **Run `lake exe cache get && lake build`.** Must succeed with zero
   errors and zero new `sorry`.  Fix any namespace fallout from step 5.
7. **Verify axiom signatures.**  Pick the load-bearing theorem and run

   ```bash
   echo 'import CATEPTPluginHilleYosida.IntegrationBridge
   #print axioms CATEPTPluginHilleYosida.hilleYosida_integration_contract
   ' | lake env lean /dev/stdin
   ```

   The output must be `[propext, Classical.choice, Quot.sound]` — no
   other axiom and no `sorryAx`.
8. **Write the README contract.**  In the new repo, replace the
   placeholder `README.md` with sections:
   - **What this provides** (one-paragraph statement of the pinned theorems).
   - **Dependencies** (Mathlib, Lean toolchain, any external pins).
   - **Re-import contract** (the exact `import` line a consumer writes,
     and the list of theorems exposed).
9. **Tag and push.**  Push `main` and tag a commit (e.g. `v0.1.0`)
   that the pin in `catept-main` will reference.  Record the SHA.

**Recognition (T4.2 done):** the new repo is public; `lake build` on
a fresh clone is green; axiom signatures are kernel-only;
`README.md` has the three sections; you have the SHA to pin.

---

## Re-integration steps (T4.3)

Run on `catept-main` after T4.2 is done.

1. **Add the require to `lakefile.lean`.**  Add a `require` block
   pinned to the SHA from T4.2 step 9:

   ```lean
   require «catept-plugin-hille-yosida» from git
     "https://github.com/jagg-ix/catept-plugin-hille-yosida.git" @ "<sha>"
   ```

2. **Run `lake update <package>`.**  Updates `lake-manifest.json` with
   the new pin.  Verify the recorded SHA matches T4.2 step 9.
3. **Add the bridging shim (if needed).**  If any `catept-main` file
   imported the old `CATEPTMain.Integration.HilleYosidaBridge`
   namespace, either (a) update those imports to the new namespace, or
   (b) add a thin re-export module:

   ```lean
   -- CATEPTMain/Integration/HilleYosidaBridge.lean (new content)
   import CATEPTPluginHilleYosida.IntegrationBridge
   namespace CATEPTMain.Integration.HilleYosidaBridge
   export CATEPTPluginHilleYosida (
     hilleYosida_integration_contract proved_semigroup_growth_bound
     proved_resolvent_bound contracting_has_optimal_growth_bound
     ns_heat_semigroup_abstract_theory_proved)
   end CATEPTMain.Integration.HilleYosidaBridge
   ```

   Prefer (a) if the import surface is small.  Prefer (b) if there are
   many consumers and the rename is invasive.
4. **Delete the in-tree copy** of the moved sources (after step 3
   confirms no consumer is left using the old path).  No file in
   `catept-main/CATEPTMain/Integration/` should duplicate sibling code.
5. **Run `lake build` on `catept-main`.**  Must be green with zero
   new errors, zero new `sorry`, zero new non-kernel axioms.
6. **Verify axiom gate.**  Run the same `#print axioms` checks as
   `.github/workflows/axiom-gate.yml` does on the publication
   bridges.  Output must remain `[propext, Classical.choice, Quot.sound]`.
7. **Single commit.**  The deletion + pin change + any shim must land
   in **one** commit so revert is atomic.  Suggested message:

   ```
   T4.3: extract HilleYosidaBridge to jagg-ix/catept-plugin-hille-yosida@<short-sha>

   Pin: https://github.com/jagg-ix/catept-plugin-hille-yosida @ <sha>
   In-tree copy removed; consumers re-targeted to CATEPTPluginHilleYosida.
   axiom-gate.yml: green; #print axioms unchanged.
   ```

**Recognition (T4.3 done):** the pin is in `lakefile.lean` and
`lake-manifest.json`; the in-tree file is deleted; `lake build` green;
axiom gate green; one atomic commit on `catept-main`.

---

## Sibling CI (T4.4)

In the sibling repo, add `.github/workflows/axiom-gate.yml`:

```yaml
name: Axiom Gate

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  axiom-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Install Lean 4 toolchain
      uses: leanprover/lean4-action@v1
      with:
        use-mathlib-cache: true
    - name: Warm Mathlib olean cache
      run: lake exe cache get || true
    - name: Build sibling package
      run: lake build
    - name: Check axiom surface — sentinel theorem
      run: |
        cat > /tmp/check.lean << 'EOF'
        import CATEPTPluginHilleYosida.IntegrationBridge
        #print axioms CATEPTPluginHilleYosida.hilleYosida_integration_contract
        EOF
        lake env lean /tmp/check.lean 2>&1 | tee /tmp/out.txt
        if grep -v -E "propext|Classical\.choice|Quot\.sound|^#print|depends on axioms:|^$" /tmp/out.txt | grep -qE "axiom|sorryAx"; then
          echo "REGRESSION: non-kernel axiom or sorry"
          cat /tmp/out.txt
          exit 1
        fi
        echo "Axiom surface OK"
```

**Recognition (T4.4 done):** workflow file committed; green run on
`main` (badge visible); pin in `catept-main` updated to a SHA whose
sibling CI has passed.

---

## Rollback procedure

If anything goes wrong at T4.3 or later, three commands restore the
pre-extraction state on `catept-main`:

```bash
# 1. Revert the extraction commit (pin add + deletion)
git revert <T4.3 commit sha>

# 2. If the file was deleted, restore it from one commit prior:
git checkout <T4.3 commit sha>~1 -- CATEPTMain/Integration/HilleYosidaBridge.lean

# 3. Re-resolve lake state and rebuild
lake update
lake exe cache get
lake build
```

The sibling repo stays in place — there is no cost to leaving it
dormant; it can be restarted at a future pin.  Do **not** delete the
sibling repo as part of rollback; the SHA-pinning history may still be
referenced from a release branch.

If the sibling itself is broken (build failure on its own CI), the
rollback for `catept-main` alone is sufficient to unblock further work
while the sibling is fixed.

---

## Per-plugin checklist template

Copy this into the worklog task `details` field for each future split.

```
Plugin: <Name>
Sibling repo: jagg-ix/catept-plugin-<kebab>
Sibling namespace: CATEPTPlugin<UpperCamel>

T4.2 — Extraction
  [ ] New repo created (public, MIT/Apache)
  [ ] lakefile.lean pinned to Lean toolchain + Mathlib + external deps
  [ ] lean-toolchain matches catept-main
  [ ] Sources moved with namespace renamed
  [ ] lake build green on fresh clone
  [ ] #print axioms <sentinel> -> [propext, Classical.choice, Quot.sound]
  [ ] README.md has {what, deps, re-import contract}
  [ ] Tag/SHA recorded for pin: ____________________

T4.3 — Re-integration
  [ ] catept-main lakefile.lean: require added with SHA
  [ ] lake update -> lake-manifest.json reflects pin
  [ ] In-tree copy deleted from CATEPTMain/Integration/
  [ ] Consumers re-targeted (or shim re-export added)
  [ ] lake build green on catept-main
  [ ] axiom-gate.yml: #print axioms still kernel-only
  [ ] Single atomic commit on catept-main

T4.4 — Sibling CI
  [ ] .github/workflows/axiom-gate.yml present in sibling
  [ ] Workflow runs on push and PR to main
  [ ] Green on main: ____________________ (URL)
  [ ] catept-main pin SHA's CI is green
```

---

## Future plugins — split priority hint list

Selection ranking from the survey at extraction time
(`grep` over `CATEPTMain/Integration/*.lean`).  Effort: S (≤200 LoC),
M (≤500 LoC), L (>500 LoC).  This list is informational — the
selection criteria above are authoritative.

| Effort | Plugin | LoC | `CATEPTMain.*` imports | Incoming refs |
|---|---|---|---|---|
| **S** | `HilleYosidaBridge` (PILOT) | 195 | 0 | 0 |
| S | `BrownianMotionBridge` | 74 | 0 | 0 |
| S | `QuantumInfoBridge` | 73 | 0 | 0 |
| S | `LeanInfBridge` | 46 | 0 | 0 |
| S | `LeanDimensionalAnalysisBridge` | 58 | 0 | 0 |
| S | `CslibBridge` | 69 | 0 | 0 |
| M | `GaussianFieldLogSobolevBridge` | 179 | 0 | 0 |
| M | `SpectralPhysicsBridge` | 229 | 0 | 0 |
| M | `DeGiorgiBridge` | 277 | 0 | 0 |

After T4.5 lands, refresh this table by re-running the survey command
in [`targets/target-4-plan.md`](targets/target-4-plan.md).

**Suggested T4.5 second pilot:** `BrownianMotionBridge` (smallest,
zero everything — quickest second-pass validation that the playbook
is complete).
