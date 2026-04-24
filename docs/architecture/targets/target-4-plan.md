# Target 4 — plugin sibling-repo split: decomposition plan

**Parent worklog task:** `catept_arch_plugin_siblings_split_20260424` (p3, multi-week)
**Proposal origin:** [`docs/architecture/plugin-rework-proposal.md`](../plugin-rework-proposal.md) — ModularPhysics coordination-hub pattern
**De-facto exemplar:** `xiyin137/OSreconstruction` (already pinned via `lakefile.lean` and consumed by `CATEPT/Bridges/OSReconstruction.lean`).

---

## Why split at all

Today `CATEPTMain/` is a monorepo: `Integration/`, `CATEPT/`, `Quantum/`,
`Gravitas/`, `Domains/`, `Bridges/` all ship together. The cost:

- A single failing plugin breaks the whole CI matrix.
- Pin bumps on Mathlib cascade through every plugin at once.
- The "core + Bridges" publication surface (5 files) is indistinguishable
  in the dep graph from 20+ Integration plugins.
- Plugin authors cannot version independently.

The sibling-repo pattern (ModularPhysics / OSreconstruction) solves this
by giving each plugin its own repo, CI, and version pin. `catept-main`
becomes a coordination hub that consumes pinned versions.

---

## Parent recognition criterion (from the worklog task)

> ≥ 2 plugins live in sibling repos with their own CI, pinned into
> catept-main; axiom gate still green; documentation in
> `docs/architecture/plugin-split.md` describes rollout plan.

This document decomposes that criterion into **six** measurable
middle-targets. Each has a single "done" condition that is objectively
checkable by anyone picking up the work.

---

## The six middle-targets

```
T4.1 Selection + playbook draft ──┐
                                  ▼
T4.2 Pilot extraction ────── T4.3 Pilot re-integration ──┐
                                                         ▼
T4.4 Pilot sibling CI ────────────────────────────────── T4.5 Second-plugin extraction ──┐
                                                                                         ▼
                                                                         T4.6 Playbook finalisation
```

Dependencies are strict: each target blocks the next. T4.2 and T4.3 run
against the same pilot and should land in the same session. T4.4 can
run in parallel with T4.3 once the sibling repo exists.

---

### T4.1 — Selection + playbook draft

**Worklog task:** `catept_arch_t41_pilot_selection_20260424` (p2)

**Goal:** Pick the pilot plugin; draft the extraction playbook so
T4.2-T4.6 are mechanical.

**Recognition criterion — DONE when:**
1. `docs/architecture/plugin-split-playbook.md` exists with (at
   minimum) sections: **Selection criteria**, **Extraction steps
   (numbered)**, **Re-integration steps (numbered)**, **Rollback
   procedure**, **Per-plugin checklist template**.
2. The pilot plugin is named explicitly in a `## Pilot: <name>`
   section, with rationale (size, dependency profile, test coverage).
3. Selection criteria include: (a) ≤ 3 `CATEPTMain.*` imports,
   (b) no outgoing dependencies from other `CATEPTMain.Integration/*`
   plugins, (c) ≥ 1 theorem with a verifiable axiom signature via
   `#print axioms`, (d) author willing to maintain sibling repo.
4. Rollback procedure explains how to revert an extraction via
   `lake update` + a single revert commit on `catept-main`.

**Deliverables:** 1 markdown file; no code changes.

**Blockers:** None. This unblocks all downstream Target-4 work.

---

### T4.2 — Pilot extraction to sibling repo

**Worklog task:** `catept_arch_t42_pilot_extraction_20260424` (p3)

**Goal:** Pilot plugin lives in a new GitHub repo and builds standalone.

**Recognition criterion — DONE when:**
1. New public GitHub repo `jagg-ix/catept-plugin-<name>` exists.
2. The repo contains only the pilot's `.lean` sources (no
   `CATEPTMain/` wrapper directory) under its own top-level module
   namespace, e.g. `CATEPTPlugin<Name>/`.
3. `lakefile.lean` in the new repo pins Lean toolchain, Mathlib, and
   any CATEPT core deps (e.g. `CATEPT` via the existing pinning
   conventions).
4. `lake build` in a fresh clone of the new repo succeeds with zero
   errors, zero new `sorry`, and zero new non-kernel axioms (verified
   via `#print axioms <main-theorem>`).
5. `README.md` states (a) what the plugin provides, (b) what it
   depends on, (c) the re-import contract — i.e. the `import` line a
   consumer writes and the theorem names exposed.

**Deliverables:** A new GitHub repo; not a PR on `catept-main`.

**Blockers:** T4.1.

---

### T4.3 — Pilot re-integration via lake pin

**Worklog task:** `catept_arch_t43_pilot_reintegration_20260424` (p3)

**Goal:** `catept-main` consumes the pilot via a pin; the in-tree copy
is removed; no theorem is lost.

**Recognition criterion — DONE when:**
1. `catept-main/lakefile.lean` has a `require` entry for the new
   package, pinned to a specific commit SHA (not a branch).
2. `catept-main/lake-manifest.json` records the pin.
3. The old in-tree copy of the pilot plugin is **deleted** from
   `catept-main` (no duplication). Publication bridge (if any) now
   imports from the sibling namespace.
4. `lake build` on `catept-main` succeeds after the pin change.
5. `.github/workflows/axiom-gate.yml` still passes — i.e. every
   publication-bridge theorem listed in the workflow still depends
   on `[propext, Classical.choice, Quot.sound]` only.
6. A commit on `catept-main` lands with the deletion + pin change in
   the same changeset.

**Deliverables:** 1 PR or direct merge on `catept-main`.

**Blockers:** T4.2 (needs the sibling repo at a known commit).

---

### T4.4 — Pilot sibling CI

**Worklog task:** `catept_arch_t44_pilot_sibling_ci_20260424` (p3)

**Goal:** The sibling repo has its own axiom gate that prevents
regressions without waiting for `catept-main` CI.

**Recognition criterion — DONE when:**
1. `.github/workflows/axiom-gate.yml` exists in the sibling repo.
2. The workflow builds the sibling package and runs
   `#print axioms <main-theorem>` on ≥ 1 sentinel theorem, failing on
   any axiom outside `{propext, Classical.choice, Quot.sound}` and on
   any `sorryAx`.
3. Workflow runs on `push` to `main` and on `pull_request`; green on
   `main` at least once.
4. `catept-main`'s pin for the sibling is updated to a commit whose
   CI has passed (verified via commit status badge).

**Deliverables:** 1 workflow file in the sibling repo; green run.

**Blockers:** T4.2 (needs the repo to exist).

**Can run in parallel with:** T4.3.

---

### T4.5 — Second-plugin extraction (pattern validation)

**Worklog task:** `catept_arch_t45_second_plugin_extraction_20260424` (p3)

**Goal:** Apply T4.1's playbook to a second plugin without adding new
playbook steps (i.e., the playbook was complete enough).

**Recognition criterion — DONE when:**
1. A second sibling repo `jagg-ix/catept-plugin-<name2>` exists and
   builds standalone (same criteria as T4.2.1-T4.2.5 applied to it).
2. `catept-main` consumes it via pin + lake-manifest (same criteria
   as T4.3.1-T4.3.6).
3. Sibling CI exists and is green (same criteria as T4.4).
4. The T4.1 playbook has been updated with **at most** 2 corrections
   learned from the second extraction. If more than 2 corrections are
   needed, T4.5 is blocked and T4.1 must be re-opened.
5. The parent recognition criterion "≥ 2 plugins in sibling repos" is
   now met. Parent task can be flipped to `done` after T4.6.

**Deliverables:** Second sibling repo + pin bump + playbook diff.

**Blockers:** T4.3 + T4.4.

---

### T4.6 — Playbook finalisation + hub documentation

**Worklog task:** `catept_arch_t46_playbook_finalisation_20260424` (p3)

**Goal:** The pattern is documented well enough that future splits
don't need any designer input; a maintenance contract exists.

**Recognition criterion — DONE when:**
1. `docs/architecture/plugin-split-playbook.md` is finalised: no
   `TODO` or `TBD` markers; every step has an owner or a script;
   checklist template is canonical.
2. `docs/architecture/plugin-split.md` exists (the document named in
   Target 4's parent recognition criterion) with sections:
   **Why splits**, **Current sibling inventory** (table), **Pin-bump
   workflow**, **Adding a new sibling** (links to the playbook).
3. `README.md` on `catept-main` has a "Coordination hub" section
   listing the sibling repos with their pinned commits and links.
4. A prioritised list of **next** plugins to split exists in the
   playbook, each annotated with size, dependency profile, and
   expected effort (S / M / L).

**Deliverables:** 2 markdown files finalised; README update.

**Blockers:** T4.5.

---

## What "done" means for the parent Target 4

Parent task `catept_arch_plugin_siblings_split_20260424` flips to
`done` when **all six** middle-targets are done AND all of these hold
simultaneously:

| Invariant | Verifier |
|---|---|
| `lake build` on `catept-main` succeeds | `lake build` |
| Axiom gate on `catept-main` green | `.github/workflows/axiom-gate.yml` |
| Every sibling repo's CI green on its `main` | GitHub status badges |
| `lake-manifest.json` pins match published commit SHAs | `lake update --check` or manual diff |
| Playbook has zero open TODO markers | `grep -n TODO docs/architecture/plugin-split-playbook.md` returns empty |
| Coordination-hub section exists in `README.md` | `grep -n "Coordination hub" README.md` hits |

**No subjective criterion appears in the recognition list.** Every
item is a script-checkable or URL-visible state.

---

## Non-scope

These are **not** part of Target 4 and should not block it:

- Migrating every plugin (only 2+ are required; more is gravy).
- Changing the `CATEPTPluginSlot` interface (Target 3 covers that).
- Publication-bridge refactors (Target 2 covered the map).
- Axiom discharge for open `sorry`s in plugins (separate workstreams).

If a plugin has an open critical `sorry`, it is **not** a good pilot
candidate — pick another (T4.1 covers selection criteria).

---

## Rollback

Any middle-target can be rolled back with these three commands on
`catept-main`:

```bash
# Revert the pin to the in-tree copy
git revert <pin-commit-sha>
# If the in-tree copy was deleted, restore it:
git checkout <pin-commit-sha>~1 -- CATEPTMain/<PluginPath>
lake update
lake build
```

The sibling repo stays in place (no cost to leave dormant). Playbook
T4.1 section **Rollback** codifies this.

---

## Worklog tasks created

| Code | Priority | Title |
|---|---|---|
| `catept_arch_t41_pilot_selection_20260424` | p2 | T4.1 — Selection + playbook draft |
| `catept_arch_t42_pilot_extraction_20260424` | p3 | T4.2 — Pilot extraction to sibling repo |
| `catept_arch_t43_pilot_reintegration_20260424` | p3 | T4.3 — Pilot re-integration via lake pin |
| `catept_arch_t44_pilot_sibling_ci_20260424` | p3 | T4.4 — Pilot sibling CI |
| `catept_arch_t45_second_plugin_extraction_20260424` | p3 | T4.5 — Second-plugin extraction |
| `catept_arch_t46_playbook_finalisation_20260424` | p3 | T4.6 — Playbook finalisation + hub docs |

The parent `catept_arch_plugin_siblings_split_20260424` stays in
`todo`; it flips to `done` only when the six middle-targets are done
**and** the invariants above all hold.
