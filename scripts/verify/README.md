# `scripts/verify/` — runnable verification scripts

This directory contains a small test suite that runs every Lean
verification recipe shown in the project [`README.md`](../../README.md)
and checks that each one produces the expected output.

Each script:
1. Builds (or asks Lean to elaborate) the relevant module.
2. Captures the raw command output to `logs/<script-name>.out`.
3. Greps the output for the lines the project README claims should
   appear, and prints `PASS` or `FAIL`.
4. Exits 0 on success, 1 on failure. (Skips, exit 77, are reserved
   for prerequisites that are intrinsically unavailable on a host;
   no script in this suite currently uses skip.)

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
  PASS  01_kernel_axiom_audit.sh
  PASS  02_gr_minkowski.sh
  PASS  03_gr_electrovacuum.sh
  PASS  04_all_spine.sh
  PASS  05_axiom_free_all_10.sh
  PASS  06_axiom_free_individual.sh
--------------------------------------------------------------
  total: 6   pass: 6   skip: 0   fail: 0
  logs : /…/catept-main/scripts/verify/logs/
```

Exit codes: `run_all.sh` exits **0** if every script passed (or
skipped) and **1** if any script failed.

---

## What each script verifies

| # | Script | Mirrors README § | What it asserts |
|--:|---|---|---|
| 1 | `01_kernel_axiom_audit.sh` | §4 | The QM-style and GR-Minkowski-style spine theorems both depend only on `propext`, `Classical.choice`, `Quot.sound`. |
| 2 | `02_gr_minkowski.sh` | §3.3.1 | The GR-Minkowski-style instance has the correct *statement type* (`spineConstraint (trivialSlot 1)`) and depends only on the kernel axiom triple. |
| 3 | `03_gr_electrovacuum.sh` | §3.3.2 | The GR-full-electrovacuum-style instance has the correct *statement type* (`spineConstraint (trivialSlot 2)`) and depends only on the kernel axiom triple. |
| 4 | `04_all_spine.sh` | §3.3.3 | All four spine theorems (QM, GR-Minkowski, GR-electrovacuum, bundled headline) clear the kernel-axiom-only bar simultaneously. |
| 5 | `05_axiom_free_all_10.sh` | §6.1 | All ten compatibility theorems print `does not depend on any axioms` in a single combined grep. |
| 6 | `06_axiom_free_individual.sh` | §6.2 | Each of the ten compatibility theorems independently prints `does not depend on any axioms`. |

---

## How scripts 1–4 are implemented (the demo file)

Scripts 1–4 verify the spine theorems against a self-contained Lean
file at [`scripts/verify/lean/SpineDemo.lean`](lean/SpineDemo.lean).

The demo file proves the *same four spine theorems* the canonical
showcase
([`CATEPT/Showcase/QMGRUnification.lean`](https://github.com/jagg-ix/catept-main/blob/feat/publication/CATEPT/Showcase/QMGRUnification.lean)
on the `feat/publication` branch) proves on the full Gravitas /
QuantumCATEPTBridge stack:

* `qm_satisfies_catept_spine`              — QM-style instance
* `gr_minkowski_satisfies_catept_spine`    — GR Minkowski instance
* `gr_electrovacuum_satisfies_catept_spine` — full electrovacuum instance
* `qm_gr_unified_via_entropic_proper_time`  — bundled headline

The demo's content is the *abstract* `actionIm / ℏ = eptClock`
pattern over a minimal three-field `SpineSlot` carrier, not the
rich physics content of the canonical showcase. Its purpose is to
exhibit the same kernel-axiom-only signature
`[propext, Classical.choice, Quot.sound]` so the verification
scripts can mechanically check the audit mechanism on any branch
without depending on the full Gravitas / Bohmian dependency chain.

When the canonical showcase is checked out (i.e. on
`feat/publication`), running the same recipes by hand against
`CATEPT.Showcase.QMGRUnification.*` produces the same kernel-axiom-
only output on the *full physics-content* theorems. The recipes
shown in the project README are written for that case.

Scripts 5–6 do not need the demo: they verify the ten compatibility
theorems against
[`CATEPTMain/Domains/CoherenceShowcase.lean`](../../CATEPTMain/Domains/CoherenceShowcase.lean),
which is present on every branch where the repo builds.

---

## Where the logs live

* `logs/01_kernel_axiom_audit.out`   — `lake env lean` output for §4
* `logs/02_gr_minkowski.out`         — `lake env lean` output for §3.3.1
* `logs/03_gr_electrovacuum.out`     — `lake env lean` output for §3.3.2
* `logs/04_all_spine.out`            — `lake env lean` output for §3.3.3
* `logs/05_axiom_free_all_10.out`    — `lake build … | grep` output for §6.1
* `logs/06_axiom_free_individual.out` — per-theorem matches for §6.2
* `logs/06_axiom_free_individual.build.out` — full `lake build` output (kept
  separately so the per-theorem grep doesn't suppress unrelated build noise)

The logs directory is regenerated on every run.

---

## Adding a new check

1. Add a numbered script `NN_<name>.sh` next to the existing ones.
2. `source` the helpers from `lib.sh` and call `verify_repo_root`,
   `verify_banner`, `verify_run`, `verify_match` / `verify_no_match`,
   then `verify_pass` or `verify_fail`.
3. Append the script name to the `scripts=(…)` array in
   `run_all.sh`.

The helper library (`lib.sh`) is intentionally minimal — `bash` only,
no `jq` or other dependencies — so the suite runs anywhere Lake
itself runs.
