---
name: worklog
description: Log notes, add tasks, and update task status in the entropic worklog. Use when the user asks to log work, record a milestone, add a target, mark something done, or check worklog state. Also the coordination point when multiple helpers work in parallel on this workstation.
disable-model-invocation: false
allowed-tools: Bash
---

## Worklog App — Usage Reference (catept-main)

**Package**: `ept_worklog` at `/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool`
**Database**: `/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3`
*(shared across all sibling projects on this workstation — navier-stokes-project-clean, catept-main, etc.)*

### CLI invocation pattern

```bash
DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PYTHONPATH=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool

python3 -c "
from ept_worklog.cli import main; import sys
sys.argv = ['wl', '--db', '$DB', '<subcommand>', <args>]
main()
"
```

### Core subcommands

- `summary` — counts of tasks/notes/runs/agents
- `list-tasks --status <todo|in_progress|done|blocked>`
- `add-task --code <snake_case_id> --title "..." --priority <p0|p1|p2|p3> --status todo --tags "a,b" --details "..."`
- `set-task-status --code <id> --status <...>`
- `log-note --title "..." --body "..." --agent <handle> --kind <strategy|milestone|decision|debug|coordination|handoff> [--task-code <id>]`
- `log-run --command "..." --exit-code 0 --stdout "..." [--task-code <id>]`
- `register-agent --handle <short> --display-name "..." --kind <human|ai>`
- `list-agents`
- `export-md` — regenerates `docs/workstation/WORKLOG.md`

### Priority convention (catept-main)

- `p0` — axiom-gate regression / build-broken / reviewer-blocking publication issue
- `p1` — architecture work / core theorem proofs / important but not blocking
- `p1.5` / `p2` — parallel-track physics domains (QM, GR, QFT, NS)
- `p3` — backlog / nice-to-have / long-term infra

### Code convention

`catept_<area>_<description>_YYYYMMDD`
Examples:
- `catept_arch_assumption_registry_20260424`
- `catept_bridge_os_reconstruction_20260423`
- `catept_dep_aristotle_v429_port_20260423`

---

## Multi-helper coordination (shared workstation)

Multiple AI agents and humans may work on this workstation simultaneously.
The worklog DB is the **single coordination point**. These rules apply to
all repos using the shared DB (catept-main, navier-stokes-project-clean,
Logos_Library, PhysicsLogic, OSreconstruction, ModularPhysics).

### 1. Identify yourself — register an agent handle

```bash
sys.argv = ['wl','--db',DB,'list-agents']
# If missing:
sys.argv = ['wl','--db',DB,'register-agent',
  '--handle','jorge',                           # or 'claude-opus-4-7', 'claude-sonnet-4-6'
  '--display-name','Jorge A. Garcia',
  '--kind','human',                             # or 'ai'
]
```

Always pass `--agent <handle>` on every `log-note` and `log-run`.

### 2. Task-claim protocol — the core rule

**Before starting a task, check it's not already claimed.**

```bash
sys.argv = ['wl','--db',DB,'list-tasks','--status','in_progress']
```

To claim:
1. `set-task-status --code CODE --status in_progress`
2. `log-note --kind coordination --task-code CODE --body "Claiming. Branch: feat/<handle>/<slug>. ETA: ~X h."`

To release: mark `done` or `blocked` with a closing summary note.

If the task is already `in_progress` by another agent, either pick a
different task or post a `coordination` note on that task asking to
collaborate before starting.

### 3. Git branch-per-helper-per-task

Never push directly to `main` or `feat/publication`. Branch name format:

```
feat/<handle>/<short-task-slug>
```

Examples:
- `feat/jorge/os-reconstruction-bridge`
- `feat/claude-opus-4-7/assumption-registry`
- `feat/claude-sonnet-4-6/bkm-retirement`

Before pushing: `git fetch && git rebase origin/main`. Never
`--force-push` a branch another helper may be on.

### 4. Lake build isolation

`.lake/packages/` is shared per-repo-clone. Concurrent `lake build` on the
same clone **will** interleave olean writes. Pick one:

- **Option A (preferred)**: each helper uses their own clone
  (`catept-main-<handle>/`). No contention; independent `.lake/`.
- **Option B**: share the clone, serialise builds. Before `lake build`,
  check for another active build:
  ```bash
  pgrep -f "lake build" | xargs -r ps -o pid,command
  ```
  If active, wait — never run two `lake build` simultaneously on the
  same clone.

**Never edit `.lake/packages/**/*.lean`** as part of routine work — lake
overwrites those. Edit the dep's own repo, push, and bump the pin in
`lakefile.lean` + `lake-manifest.json`.

### 5. `/tmp` hygiene

Use a per-helper subdir:

```
/tmp/<handle>/<repo-or-task>/
```

Examples: `/tmp/claude-opus-4-7/aristotle-port/`, `/tmp/jorge/qft-audit/`.

Clean up after finishing. `/tmp` fills at ~7 GB per Mathlib-pinned clone.

### 6. Worklog DB concurrency

SQLite handles concurrent readers + short serialised writes. If you see
`database is locked`, retry after a few seconds. Avoid long-running
interactive transactions.

### 7. Handoff at end-of-shift

If you stop mid-task (context window limit, end of human work day,
handoff to another agent):

1. `log-note --kind handoff --task-code CODE --body "<state + unpushed commits + blockers + next step>"`
2. Leave task `in_progress` — future helpers see the handoff note.

Incoming helper:
1. `list-notes --task-code CODE` → read the latest handoff
2. `log-note --kind coordination --body "Resuming after <prev-agent>'s handoff."`
3. Continue.

### 8. Conflict resolution

Two helpers accidentally working on the same task: first-to-merge
wins. The other logs a `coordination` note summarising their attempt
(salvageable or not). Don't hide the collision — audit history matters.

---

## Current catept-main active tasks

Check with:
```bash
sys.argv = ['wl','--db',DB,'list-tasks','--status','in_progress']
sys.argv = ['wl','--db',DB,'list-tasks','--status','todo']
```

Filter by prefix `catept_*` to focus on this repo.

---

## Workflow: completing a catept-main milestone

1. Claim task: `set-task-status --status in_progress`; log coordination note
2. Do the Lean4 work on a `feat/<handle>/<slug>` branch
3. Build + axiom-audit: `lake build <target>` + `#print axioms <theorem>`
4. Commit to git; push to your branch
5. `log-note --kind milestone` with: what was proved, files touched,
   axiom-surface delta, next target
6. Mark task `done`
7. Add any new tasks that were unblocked
