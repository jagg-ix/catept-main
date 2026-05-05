# `scripts/verify/` — runnable verification scripts

This directory contains a small test suite that runs every Lean
verification recipe shown in the project [`README.md`](../../README.md)
and checks that each one produces the expected output.

Each script:
1. Builds the relevant Lean module with `lake build`.
2. Captures the raw command output to `logs/<script-name>.out`.
3. Greps the output for the lines the project README claims should
   appear, and prints `PASS` or `FAIL`.
4. Exits 0 on success, 1 on failure.

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
bash scripts/verify/04_all_spine.sh
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

`run_all.sh` exits **0** when every script passes and **1** when
any script fails.

---

## What each script verifies

| # | Script | Mirrors README § | What it asserts |
|--:|---|---|---|
| 1 | `01_kernel_axiom_audit.sh` | §4 | The QM-side and GR-Minkowski-side spine theorems both depend only on `propext`, `Classical.choice`, `Quot.sound`. |
| 2 | `02_gr_minkowski.sh` | §3.3.1 | The GR Minkowski instance (`gr_minkowski_satisfies_catept_spine`) depends only on the kernel-axiom triple. |
| 3 | `03_gr_electrovacuum.sh` | §3.3.2 | The full electrovacuum instance (`gr_electrovacuum_satisfies_catept_spine`) depends only on the kernel-axiom triple. |
| 4 | `04_all_spine.sh` | §3.3.3 | All four spine theorems (QM, GR Minkowski, GR full electrovacuum, bundled headline) clear the kernel-axiom-only bar simultaneously. |
| 5 | `05_axiom_free_all_10.sh` | §6.1 | All ten compatibility theorems print `does not depend on any axioms` in a single combined grep. |
| 6 | `06_axiom_free_individual.sh` | §6.2 | Each of the ten compatibility theorems independently prints `does not depend on any axioms`. |

---

## How scripts 1–4 are implemented

Scripts 1–4 verify the four spine theorems against
[`CATEPTMain/Showcase/QMGRUnification.lean`](../../CATEPTMain/Showcase/QMGRUnification.lean).
That file ports the canonical
[`CATEPT/Showcase/QMGRUnification.lean`](https://github.com/jagg-ix/catept-main/blob/feat/publication/CATEPT/Showcase/QMGRUnification.lean)
on the `feat/publication` branch verbatim — same symbols
(`CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine`,
`...gr_minkowski_satisfies_catept_spine`,
`...gr_electrovacuum_satisfies_catept_spine`,
`...qm_gr_unified_via_entropic_proper_time`), same proofs,
same `#print axioms` directives — but lives under
`CATEPTMain/Showcase/` so Lake's `lean_lib CATEPTMain` owns
the *module path* unambiguously (the `CATEPT/Showcase/` path
is owned by NSC's `lean_lib CATEPT` on this branch and would
route the build there).

The four `#print axioms` directives at the bottom of the
showcase file are emitted as `info:` diagnostics during
`lake build CATEPTMain.Showcase.QMGRUnification`.  Each script
then greps that build output for the line corresponding to its
target theorem, asserting the kernel-axiom triple
`[propext, Classical.choice, Quot.sound]` and nothing else.

Scripts 5 and 6 use the same pattern against
[`CATEPTMain/Domains/CoherenceShowcase.lean`](../../CATEPTMain/Domains/CoherenceShowcase.lean),
which also embeds `#print axioms` directives for the ten
compatibility theorems.

---

## Where the logs live

* `logs/01_kernel_axiom_audit.out`   — `lake build … | grep` output for §4
* `logs/02_gr_minkowski.out`         — `lake build … | grep` output for §3.3.1
* `logs/03_gr_electrovacuum.out`     — `lake build … | grep` output for §3.3.2
* `logs/04_all_spine.out`            — `lake build … | grep` output for §3.3.3
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
   then `verify_pass` or `verify_fail`.
3. Append the script name to the `scripts=(…)` array in
   `run_all.sh`.

The helper library (`lib.sh`) is intentionally minimal — `bash` only,
no `jq` or other dependencies — so the suite runs anywhere Lake
itself runs.
