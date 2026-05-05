# `scripts/verify/` — runnable verification scripts

This directory contains a small test suite that runs every Lean
verification recipe shown in the project [`README.md`](../../README.md)
and checks that each one produces the expected output.

Each script:
1. Builds (or asks Lean to elaborate) the relevant module.
2. Captures the raw command output to `logs/<script-name>.out`.
3. Greps the output for the lines the project README claims should
   appear, and prints `PASS` / `SKIP` / `FAIL`.
4. Exits 0 on success, 77 on skip (when the prerequisite isn't on
   the current branch), or 1 on failure.

Logs persist after the run so they can be inspected later, attached
to bug reports, or diffed across branches.

---

## How to run

From the repository root, with the Mathlib olean cache already warm
(`lake exe cache get`):

```bash
bash scripts/verify/run_all.sh
```

This runs all six scripts in order and prints a summary table.
Individual scripts can also be run on their own:

```bash
bash scripts/verify/05_axiom_free_all_10.sh
```

The summary at the end of `run_all.sh` looks like:

```
==============================================================
 Summary
==============================================================
  SKIP  01_kernel_axiom_audit.sh   (no showcase on this branch)
  SKIP  02_gr_minkowski.sh   (no showcase on this branch)
  SKIP  03_gr_electrovacuum.sh   (no showcase on this branch)
  SKIP  04_all_spine.sh   (no showcase on this branch)
  PASS  05_axiom_free_all_10.sh
  PASS  06_axiom_free_individual.sh
--------------------------------------------------------------
  total: 6   pass: 2   skip: 4   fail: 0
  logs : /…/catept-main/scripts/verify/logs/
```

Exit codes: `run_all.sh` exits **0** if no script failed (skips are
fine), or **1** if any script returned a non-zero non-77 status.

---

## What each script verifies

| # | Script | Mirrors README § | What it asserts |
|--:|---|---|---|
| 1 | `01_kernel_axiom_audit.sh` | §4 | `qm_satisfies_catept_spine` and `gr_minkowski_satisfies_catept_spine` depend only on `propext`, `Classical.choice`, `Quot.sound`. |
| 2 | `02_gr_minkowski.sh` | §3.3.1 | The GR Minkowski instance has the correct *statement type* (`cateptConsistencyConstraint gravitasMinkowskiSlot`) and depends only on the kernel axiom triple. |
| 3 | `03_gr_electrovacuum.sh` | §3.3.2 | The GR full-electrovacuum (Einstein–Maxwell) instance has the correct *statement type* (`cateptSpineConstraint gravitasElectrovacuumPlugin`) and depends only on the kernel axiom triple. |
| 4 | `04_all_spine.sh` | §3.3.3 | All four spine theorems (QM, GR Minkowski, GR full-electrovacuum, bundled headline) clear the kernel-axiom-only bar simultaneously. |
| 5 | `05_axiom_free_all_10.sh` | §6.1 | All ten compatibility theorems print `does not depend on any axioms` in a single combined grep. |
| 6 | `06_axiom_free_individual.sh` | §6.2 | Each of the ten compatibility theorems independently prints `does not depend on any axioms`. |

---

## When a script SKIPs

Scripts 1–4 require the file
`CATEPT/Showcase/QMGRUnification.lean`, which lives on the
[`feat/publication`](https://github.com/jagg-ix/catept-main/tree/feat/publication)
branch of this repository. On any other branch (e.g. development
branches) Lean reports

```
error: object file '…/CATEPT/Showcase/QMGRUnification.olean'
       of module CATEPT.Showcase.QMGRUnification does not exist
```

The driver detects that error and marks scripts 1–4 as `SKIP` rather
than `FAIL`. To run them as `PASS`, switch to `feat/publication`:

```bash
git checkout feat/publication
lake exe cache get
bash scripts/verify/run_all.sh
```

Scripts 5 and 6 only require `CATEPTMain/Domains/CoherenceShowcase.lean`,
which is present on every branch where the repo builds.

---

## Where the logs live

* `logs/01_kernel_axiom_audit.out`   — `lake env lean` output for §4
* `logs/02_gr_minkowski.out`         — `lake env lean` output for §3.3.1
* `logs/03_gr_electrovacuum.out`     — `lake env lean` output for §3.3.2
* `logs/04_all_spine.out`            — `lake env lean` output for §3.3.3
* `logs/05_axiom_free_all_10.out`    — `lake build … | grep` output for §6.1
* `logs/06_axiom_free_individual.out`     — per-theorem matches for §6.2
* `logs/06_axiom_free_individual.build.out` — full `lake build` output (kept
  separately so the per-theorem grep doesn't suppress unrelated build noise)

The logs directory is regenerated on every run.

---

## Adding a new check

1. Add a numbered script `NN_<name>.sh` next to the existing ones.
2. `source` the helpers from `lib.sh` and call `verify_repo_root`,
   `verify_banner`, `verify_run`, `verify_match` / `verify_no_match`,
   then `verify_pass` or `verify_fail` (or `exit 77` to skip).
3. Append the script name to the `scripts=(…)` array in
   `run_all.sh`.

The helper library (`lib.sh`) is intentionally minimal — `bash` only,
no `jq` or other dependencies — so the suite runs anywhere Lake
itself runs.
