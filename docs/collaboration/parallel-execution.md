# Parallel Execution on a Shared Workstation

**Audience**: AI agents and humans working on catept-main (or any sibling
repo) from the same macOS workstation at `~/lab/tau/tau-information-dynamics/`.

**Goal**: avoid collisions, duplicated work, and corrupted build state
when more than one helper is active.

---

## TL;DR — the five rules

1. **Register yourself** in the worklog (`register-agent`) and always
   attribute your notes with `--agent <your-handle>`.
2. **Claim tasks** by setting them `in_progress` *and* logging a
   `coordination` note before starting work.
3. **One branch per helper per task**: `feat/<handle>/<slug>`. No direct
   pushes to `main` or `feat/publication`.
4. **Don't share a `.lake/` directory for concurrent `lake build`** —
   use your own clone or serialise builds.
5. **Hand off cleanly** at end-of-shift: `log-note --kind handoff` with
   state, branch, blockers, and next step.

Read the rest if you're new to the workstation or the worklog tool.

---

## The coordination hub — the worklog DB

A single SQLite database at

```
/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
```

is shared across all sibling projects. Every helper reads from and
writes to it. This is how we know what everyone else is doing.

Managed via the `ept_worklog` CLI
(see `~/lab/tau/tau-information-dynamics/entropic-worklog-tool/`).

Full reference: [`.claude/skills/worklog/SKILL.md`](../../.claude/skills/worklog/SKILL.md)
(in this repo) and the identical one in
`navier-stokes-project-clean/.claude/skills/worklog/SKILL.md`.

### Quick commands

```bash
DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PYTHONPATH=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool

# What's everyone doing right now?
python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','list-tasks','--status','in_progress']; main()"

# Who's registered?
python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','list-agents']; main()"
```

---

## Agent registration

Before your first action, make sure your handle is in the DB:

```bash
python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','register-agent',
  '--handle','claude-opus-4-7',          # or 'jorge', 'claude-sonnet-4-6', …
  '--display-name','Claude Opus 4.7',
  '--kind','ai',                         # or 'human'
]; main()"
```

Use the same handle in every `log-note --agent <handle>` and
`log-run --agent <handle>` call. Notes without attribution produce a
warning and pollute the audit trail.

---

## Task-claim protocol

Tasks in the worklog have four states: `todo`, `in_progress`, `done`,
`blocked`. The workflow:

```
┌───────┐ claim  ┌──────────────┐ complete ┌──────┐
│ todo  │──────→ │ in_progress  │────────→ │ done │
└───────┘        └──────────────┘          └──────┘
                       │
                       │ stuck
                       ▼
                  ┌─────────┐
                  │ blocked │
                  └─────────┘
```

### Before starting — is it free?

```bash
python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','list-tasks','--status','in_progress']; main()"
```

If the task you want is already `in_progress` by someone else, either:
- Pick a different task, or
- Post a `coordination` note asking to collaborate / take over:
  ```bash
  sys.argv=['wl','--db','$DB','log-note',
    '--title','Requesting handoff',
    '--body','Noticed you\\'re on <task>. I\\'d like to pick it up / pair on it. OK?',
    '--agent',YOUR_HANDLE,
    '--kind','coordination',
    '--task-code',CODE]
  ```
- Wait for an acknowledgement before starting.

### Claiming

Two CLI calls:

```bash
sys.argv=['wl','--db','$DB','set-task-status','--code',CODE,'--status','in_progress']
sys.argv=['wl','--db','$DB','log-note',
  '--title','Claiming task',
  '--body','Starting. Branch: feat/<handle>/<slug>. ETA ~Xh.',
  '--agent',YOUR_HANDLE,
  '--kind','coordination',
  '--task-code',CODE]
```

### Releasing

Mark `done` (with milestone note) or `blocked` (with a note explaining
the blocker). Don't silently leave tasks `in_progress` — if you stop,
see "Handoff" below.

---

## Git branch conventions

| Branch | Who may push | Policy |
|---|---|---|
| `main` | primary maintainer only | requires PR + axiom-gate CI green |
| `feat/publication` | primary maintainer only | requires PR + axiom-gate CI green |
| `feat/<handle>/<slug>` | owning helper only | free-for-all on your own branch |

Examples of correct per-helper branch names:

- `feat/jorge/lake-lockfile-hygiene`
- `feat/claude-opus-4-7/assumption-registry`
- `feat/claude-sonnet-4-6/bkm-proof-retirement`

### Pre-push checklist

```bash
git fetch origin
git rebase origin/main            # or origin/<base-branch>
lake build <target>               # verify
git push origin feat/<handle>/<slug>
```

Never `git push --force` a branch another helper may be sharing.
Use `--force-with-lease` for your own branches if a rebase is needed.

---

## Lake build isolation

`.lake/packages/` caches Mathlib oleans and dep sources. Two concurrent
`lake build` invocations on the **same clone** will write to the same
olean files and produce undefined behaviour.

### Preferred: one clone per helper

Each helper maintains their own clone under a handle-specific subdir:

```
~/lab/tau/tau-information-dynamics/catept-main/           # primary
~/lab/tau/tau-information-dynamics/catept-main-opus/      # Claude Opus helper
~/lab/tau/tau-information-dynamics/catept-main-sonnet/    # Claude Sonnet helper
~/lab/tau/tau-information-dynamics/catept-main-jorge-dev/ # Jorge scratch
```

Independent `.lake/` per clone; no contention.

### If you must share a clone

Before `lake build` / `lake exe cache get`, check:

```bash
pgrep -f "lake build" | xargs -r ps -o pid,command
```

If another build is active, wait. Build times can be 10-30 min cold,
~minutes warm.

### Never edit `.lake/packages/`

Files under `.lake/packages/**` are managed by lake. Lake overwrites
them on `lake update`. If a dep needs fixing: edit its own repo, push,
bump the pin in `lakefile.lean` + `lake-manifest.json`.

---

## `/tmp` hygiene

Scratch clones (for porting forks, running audits, etc.) live under
`/tmp`. Use a per-helper subdir to avoid collisions and to make cleanup
attributable:

```
/tmp/<handle>/<repo-or-task>/
```

Clean up when done — a Mathlib-pinned clone is ~7 GB.

---

## Handoff protocol (end-of-shift)

When you stop mid-task (context window limit, end of human work day,
handing off to another helper):

1. **Commit and push** whatever's working on your branch.
2. **Log a handoff note**:
   ```bash
   sys.argv=['wl','--db','$DB','log-note',
     '--title','Handoff: <short summary>',
     '--body','Branch feat/<handle>/<slug> at <sha>. '
              'State: <what works, what fails>. '
              'Unpushed commits: <none / list>. '
              'Blockers: <…>. '
              'Next step: <…>.',
     '--agent',YOUR_HANDLE,
     '--kind','handoff',
     '--task-code',CODE]
   ```
3. **Leave task `in_progress`** — do NOT revert to `todo`. The next
   helper will see the handoff note before resuming.

### Incoming helper

1. `list-notes --task-code CODE` → read the latest handoff note
2. Log a `coordination` note: "Resuming after <prev-handle>'s handoff."
3. Claim (it's already `in_progress`; just take it over) and continue.

---

## Conflict resolution

If two helpers accidentally worked on the same task in parallel:

- First-to-merge-to-target-branch wins the task.
- The other logs a `coordination` note summarising their attempt and
  noting whether any of it is salvageable as a follow-up task.
- Don't hide duplicate work — surfacing it helps future audits and
  identifies where the claim protocol broke down.

---

## Worklog DB safety

SQLite handles concurrent readers + short serialised writes. You may
see `database is locked` occasionally — retry after a few seconds.

Don't leave long-running interactive Python sessions holding write
transactions open.

---

## Summary poster (for the wall)

> 1. Register → `register-agent --handle <you>`
> 2. Before work → `list-tasks --status in_progress`
> 3. Claim → `set-task-status in_progress` + `log-note coordination`
> 4. Work → on `feat/<handle>/<slug>`
> 5. Build → your own clone, or wait for the shared one
> 6. Handoff/End → `log-note handoff` with branch + sha + next step
> 7. Done → `set-task-status done` + `log-note milestone`
