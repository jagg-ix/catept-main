# Multi-Helper Sync Protocol

**Status**: working protocol, 2026-04-27
**Worklog code**: `catept_arch_multihelper_sync_protocol_20260426`
**Codifies**: lessons from the parallel T82-T84 incident (forensic note in worklog 2026-04-27)

This document specifies how multiple AI helpers (Claude Opus, Codex,
GitHub Copilot, claude.ai extension, etc.) cooperate on the
`catept-main` repository without overwriting each other's work,
double-numbering commits, or losing forensic data when something goes
wrong.

The protocol is **descriptive of practice that already works** plus
**prescriptive for the failure modes we have observed**. It is not
exhaustive — when a helper hits a situation the protocol does not
cover, the safety stop in §5 takes precedence.

---

## 1. Worktrees and clones — never share a working tree

Each helper operates in **its own worktree or local clone**.

| Helper | Working location |
|---|---|
| Claude Opus 4.7 (this author) | `/private/tmp/catept-main-t70/` (separate worktree) |
| Codex / OpenAI | local clone at `/Users/macbookpro/lab/tau/tau-information-dynamics/catept-main/` |
| GitHub Copilot / claude.ai extension | local clone (same directory as codex) — note: this caused the 2026-04-27 incident |

**Rule**: helpers that share a local clone must coordinate explicitly.
Two agents `git checkout`-ing on the same clone in parallel will see
each other's HEAD changes mid-task and trip the safety stop.

**Recommendation for the future**: each helper uses
`git worktree add` to spin a private worktree off the shared clone:

```bash
cd /Users/macbookpro/lab/tau/tau-information-dynamics/catept-main
git worktree add /tmp/catept-<your-handle>-<task> -b feat/<your-handle>/<task> origin/main
```

Then helpers never compete for HEAD on the original clone.

## 2. Branch-naming convention

All branches are prefixed with the helper's handle:

```
feat/<handle>/<short-task-slug>
```

Observed handles:

| Prefix | Meaning |
|---|---|
| `feat/claude-opus-4-7/...` | Claude Opus 4.7 (e.g. `feat/claude-opus-4-7/t71-superior-method-bridges`) |
| `feat/codex/...` (and `feat/codex-t69-followup`) | OpenAI Codex |
| `feat/copilot-claude/...` | GitHub Copilot's Claude integration |
| `split/...` | repo-restructure split branches (any agent, no handle prefix because they're shared work) |

**Rule**: never push to `main` from a feature branch without a
fast-forward verification step (see §6).

## 3. Worklog protocol (cooperative locking)

The shared worklog DB at
`/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3`
acts as the **cooperative lock layer**. Every helper using a queued
task should:

### 3.1 Before starting a task

```bash
DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PP=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool

PYTHONPATH=$PP python3 -c "
from ept_worklog.cli import main; import sys
sys.argv = ['wl','--db','$DB','set-task-status',
            '--code','<task-code>','--status','in_progress']
main()
"
```

This visibly claims the task. Other helpers checking the task list see
the lock and pick a different one.

### 3.2 During the task

If a non-trivial decision is made, log a `note` linked to the task with
`--task-code`. This produces a forensic trail.

### 3.3 After completion

```bash
PYTHONPATH=$PP python3 -c "
from ept_worklog.cli import main; import sys
sys.argv = ['wl','--db','$DB','set-task-status',
            '--code','<task-code>','--status','done']
main()
"
```

Plus a milestone note documenting the commits, audit gate impact, and
any follow-up tasks unlocked.

### 3.4 Worklog conflict avoidance

Two helpers grabbing the same task simultaneously is rare but possible.
Mitigation: check `set-task-status` worked by re-querying:

```bash
sqlite3 $DB "SELECT status FROM tasks WHERE code='<task-code>';"
```

If the result isn't `in_progress` or shows your handle's most recent
update was overwritten, fall back to §5 safety stop.

## 4. T-number convention (commit tags)

Commits in the T65-T86 series use sequential `Tnn:` prefixes in commit
messages. **T-numbers are not branch-globally unique** — they may
collide between parallel helpers (we observed T82 and T83 collisions
on 2026-04-27).

### 4.1 When numbering

Pick the **next free T-number** at the moment of commit, based on
`git log origin/main`:

```bash
git log origin/main --oneline | grep -oE "T[0-9]+" | sort -V | tail -3
```

If you're working on a long-running feature branch that lags behind
main, **expect collisions** and reserve a buffer (e.g., if main is at
T86, claim T88 and let T87 be free for whoever else is in flight).

### 4.2 If you collide with another helper's T-number on integration

Don't rebrand the original commit — that loses the parallel-thread
audit trail. Instead:

* Cherry-pick the parallel commit verbatim (preserve original Author).
* In the integration commit's message, document both threads
  ("T82-mine = substrate witnesses; T82-parallel = gauge-geometry
  duality; both land on origin/main with attribution preserved").
* In `CoherenceShowcase.lean` audit-line comments, suffix the handle:
  `T82-claude-opus`, `T82-copilot-claude`, etc.

Pattern observed in `e2c912816` (the parallel T82-T84 cherry-pick).

## 5. The safety stop

If any of the following happen mid-task, **STOP IMMEDIATELY** and run
the forensic protocol (§6) before mutating anything:

* HEAD moved on a clone you didn't switch yourself.
* Tracked modifications you saw 30 seconds ago no longer match.
* `git status` shows files you didn't touch as modified.
* A push you expected to be a fast-forward fails as non-FF.
* A worklog task you set to `in_progress` is now `in_progress` *by
  someone else's most recent update*.
* `lake build` succeeds or fails differently from one minute ago when
  you didn't change anything.

The cost of pausing is low. The cost of compounding the issue with a
checkout / push / reset is potentially severe (lost work, force-
overwrites, history rewrites that can't be cleanly undone).

**Codex's behaviour on 2026-04-27 is the canonical example of this
protocol working**: HEAD moved unexpectedly from
`feat/codex-t69-followup` to `feat/copilot-claude/t82-t84-invariants`
mid-inspection; codex paused and reported the anomaly. This let us
forensically reconstruct the parallel T82-T84 work and integrate it
cleanly without losing anyone's contribution.

## 6. Forensic protocol (read-only investigation)

When the safety stop fires, run **only read-only commands** until you
understand what happened.

### 6.1 Universal first commands

```bash
cd <local-clone>

# 1. Reflog — the canonical "what happened recently"
git reflog --date=iso | head -30

# 2. Where every branch tip currently is
git for-each-ref --format='%(refname:short) %(committerdate:iso) %(authoremail)' refs/heads/

# 3. Untracked + modified state
git status --short --branch

# 4. Stashes (might contain in-progress work)
git stash list

# 5. Origin state
git ls-remote origin
```

### 6.2 If a parallel commit is suspected

```bash
# Compare the suspected parallel SHA against your branch base
git log --oneline origin/main..<suspect-sha>
git log --oneline <suspect-sha>..origin/main

# Diff the parallel SHA against current main HEAD
git diff origin/main <suspect-sha> -- <relevant-paths>

# Author identity
git log --format='%an <%ae>' -1 <suspect-sha>
```

### 6.3 Decide: scenario A, B, or C

* **Scenario A — benign concurrent agent**: another helper created a
  branch from a clean base, did valid work, didn't conflict.
  Resolution: stash any in-progress local edits, proceed.
* **Scenario B — lost work**: HEAD reset or forced checkout removed
  reachable commits. Resolution: recover via `git reflog` →
  `git checkout <SHA>` → cherry-pick onto a recovery branch.
* **Scenario C — parallel work that needs integration**: a competing
  helper landed substantive work in parallel.
  Resolution: cherry-pick into your branch with conflict resolution,
  preserve original Author, push to main with both threads documented.
  Pattern: `e2c912816` on origin/main (the 2026-04-27 T82-T84 cherry-pick).

## 7. Push protocol

Pushing to `origin/main` is the most consequential action a helper
takes. The protocol:

### 7.1 Always fast-forward

```bash
git fetch origin main
git log --oneline <your-commit>..origin/main  # should be empty
git push origin <your-commit>:main             # FF push, never branch-FF
```

If `git log <your-commit>..origin/main` is non-empty, you are **behind**
main — rebase or cherry-pick onto current main first. **Never force-push
to main.**

### 7.2 Verify the push

```bash
git fetch origin main
git log --oneline origin/main -3
```

Confirm your SHA is at the tip.

## 8. Communication norms

* **Quote SHAs explicitly** in worklog notes — `e2c912816 cherry-pick`,
  not "the cherry-pick".
* **Quote dates ISO** — `2026-04-27T07:00:50 -0600`, not "earlier today".
* **Identify your handle** in commit messages and worklog agent fields:
  - Claude Opus 4.7 → `claude-opus-4-7`
  - Codex → `codex`
  - GitHub Copilot Claude → `copilot-claude`
  - claude.ai web → `claude-web` (not yet observed)
* **Co-authored-by lines** in commit messages name the AI model
  explicitly (e.g. `Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>`).

## 9. Recovery hooks (post-incident)

After a sync incident is resolved, log a forensic milestone note
linked to the protocol task:

```bash
PYTHONPATH=$PP python3 -c "
from ept_worklog.cli import main; import sys
sys.argv = ['wl','--db','$DB','log-note',
  '--title','Sync incident <date>: <one-line summary>',
  '--kind','decision',
  '--agent','<your-handle>',
  '--task-code','catept_arch_multihelper_sync_protocol_20260426',
  '--body','''
... reflog snippets ...
... resolution steps ...
... lessons / protocol amendments ...
''']
main()
"
```

The 2026-04-27 forensic note is the canonical exemplar.

## 10. Checklist for any helper before pushing

Before `git push origin <SHA>:main`, confirm:

- [ ] Build is green: `lake build CATEPTMain.Domains.CoherenceShowcase` (or relevant target).
- [ ] Audit grep is green: only `propext`, `Classical.choice`, `Quot.sound` in any `depends on axioms` line.
- [ ] You're fast-forwarding (`git log <SHA>..origin/main` is empty).
- [ ] Worklog task is `in_progress` under your handle.
- [ ] Commit message includes a `Co-Authored-By:` line naming your AI model.
- [ ] If your work cherry-picks or integrates a parallel thread, the original Author is preserved on the cherry-pick commit (use `GIT_AUTHOR_NAME=... GIT_AUTHOR_EMAIL=... git cherry-pick --continue --no-edit`).

After `git push`, confirm:

- [ ] `git fetch origin main` and verify your SHA is at the tip.
- [ ] Set the worklog task to `done`.
- [ ] Log a milestone note with the SHA, audit gate count, and follow-up tasks unlocked.

---

## Appendix A — handles observed on `catept-main` 2026-04 to 2026-04-27

| Handle | Branch prefixes | Notes |
|---|---|---|
| `claude-opus-4-7` | `feat/claude-opus-4-7/...` | T70-T86 sequential, separate worktree |
| `codex` (OpenAI) | `feat/codex-t69-followup` | T69 follow-up; ran reconcile inspection 2026-04-27, hit safety stop |
| `copilot-claude` | `feat/copilot-claude/...` | T82-T84 parallel-numbered work; multiple branches observed (`foundations-to-catept-core`, `t82-t84-invariants`, `target6-orphan-tree-removal`) |

## Appendix B — rules of thumb

* If something looks weird, **stop and read git reflog before changing anything**.
* If a branch you didn't touch has new commits, **don't delete it** until you understand what's on it.
* If you cherry-pick someone else's commit, **preserve their Author**. Their identity in git history is part of the audit trail.
* **The cost of pausing to confirm is low. The cost of an unwanted action can be very high.**
