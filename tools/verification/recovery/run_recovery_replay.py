#!/usr/bin/env python3
import argparse
import json
import os
import re
import subprocess
from collections import Counter
from datetime import datetime
from pathlib import Path

EMPTY_MARKERS = (
    "nothing to commit",
    "previous cherry-pick is now empty",
    "the previous cherry-pick is now empty",
)

THEIRS_PREFIXES = (
    "NavierStokes/",
    "lean4_formal_verification/NavierStokes/",
    "tools/verification/",
    ".github/",
)


def run(cmd: list[str], *, check: bool = False, env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, env=env)


def shell(cmd: str) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, shell=True, capture_output=True, text=True)


def git(*args: str, check: bool = True) -> str:
    res = run(["git", *args], check=False)
    if check and res.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {res.stderr.strip()}")
    return res.stdout.strip()


def is_clean_worktree() -> bool:
    # Allow untracked artifacts (queue/log files) but block tracked changes.
    return git("status", "--porcelain", "--untracked-files=no", check=True) == ""


def conflict_files() -> list[str]:
    out = git("diff", "--name-only", "--diff-filter=U", check=False)
    return [line.strip() for line in out.splitlines() if line.strip()]


def is_empty_pick(text: str) -> bool:
    t = (text or "").lower()
    return any(marker in t for marker in EMPTY_MARKERS)


def safe_path_rule(path: str) -> str | None:
    if any(path.startswith(p) for p in THEIRS_PREFIXES):
        return "theirs"
    if path.startswith("docs/") and not path.startswith("docs/workstation/"):
        return "theirs"
    if path.startswith("database/workstation") or path.startswith("docs/workstation/"):
        return "remove"
    return None


def resolve_conflicts() -> tuple[bool, list[dict], list[str]]:
    files = conflict_files()
    if not files:
        return True, [], []

    actions: list[dict] = []
    unsafe: list[str] = []

    for f in files:
        rule = safe_path_rule(f)
        if rule == "theirs":
            run(["git", "checkout", "--theirs", "--", f])
            run(["git", "add", "--", f])
            actions.append({"path": f, "action": "theirs+add"})
        elif rule == "remove":
            run(["git", "rm", "--", f])
            actions.append({"path": f, "action": "rm"})
        else:
            unsafe.append(f)

    if unsafe:
        return False, actions, unsafe

    env = dict(os.environ)
    env["GIT_EDITOR"] = "true"
    cont = run(["git", "cherry-pick", "--continue"], env=env)
    if cont.returncode == 0:
        actions.append({"action": "continue_ok"})
        return True, actions, []

    text = (cont.stdout or "") + "\n" + (cont.stderr or "")
    if is_empty_pick(text):
        skip = run(["git", "cherry-pick", "--skip"])
        if skip.returncode == 0:
            actions.append({"action": "skip_empty_after_continue"})
            return True, actions, []

    actions.append({
        "action": "continue_failed",
        "returncode": cont.returncode,
        "stdout_tail": (cont.stdout or "")[-500:],
        "stderr_tail": (cont.stderr or "")[-500:],
    })
    run(["git", "cherry-pick", "--abort"])
    return False, actions, []


def main() -> None:
    ap = argparse.ArgumentParser(description="Run deterministic cherry-pick replay from recovery queue.")
    ap.add_argument("--queue", default=".recovery/recovery_queue_priority.json")
    ap.add_argument("--base", default="main")
    ap.add_argument("--branch", default="")
    ap.add_argument("--log-dir", default=".recovery/logs")
    ap.add_argument("--max", type=int, default=0, help="optional max picks (0 = all)")
    args = ap.parse_args()

    if not is_clean_worktree():
        raise SystemExit("worktree is dirty; aborting replay")

    queue = json.loads(Path(args.queue).read_text())
    if args.max and args.max > 0:
        queue = queue[: args.max]

    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    branch = args.branch or f"recovery/cherry-pick-nsi-dedup-{ts}"

    git("switch", "-c", branch, args.base)

    log_root = Path(args.log_dir)
    log_root.mkdir(parents=True, exist_ok=True)
    run_dir = log_root / f"{ts}_{branch.replace('/', '_')}"
    run_dir.mkdir(parents=True, exist_ok=True)
    jsonl_path = run_dir / "replay_results.jsonl"
    summary_path = run_dir / "replay_summary.json"

    status_counter = Counter()

    for i, entry in enumerate(queue, start=1):
        ref = entry["replay_ref"]
        pick = run(["git", "cherry-pick", "-x", ref])

        result = {
            "index": i,
            "replay_ref": ref,
            "source_sha": entry.get("source_sha"),
            "source_subject": entry.get("source_subject"),
            "priority_group": entry.get("priority_group"),
            "priority_order": entry.get("priority_order"),
            "natural_order": entry.get("natural_order"),
            "origin_type": entry.get("origin_type"),
            "injected_missing": entry.get("injected_missing", False),
            "status": None,
        }

        if pick.returncode == 0:
            new_head = git("rev-parse", "--short", "HEAD")
            new_subject = git("show", "-s", "--format=%s", "HEAD")
            result.update({
                "status": "applied",
                "new_head": new_head,
                "new_subject": new_subject,
            })
            status_counter["applied"] += 1
        else:
            text = (pick.stdout or "") + "\n" + (pick.stderr or "")
            conflicts = conflict_files()

            if not conflicts:
                if is_empty_pick(text):
                    skip = run(["git", "cherry-pick", "--skip"])
                    if skip.returncode == 0:
                        result["status"] = "skipped_empty"
                        status_counter["skipped_empty"] += 1
                    else:
                        run(["git", "cherry-pick", "--abort"])
                        result["status"] = "failed_skip_empty"
                        status_counter["failed_skip_empty"] += 1
                else:
                    run(["git", "cherry-pick", "--abort"])
                    result["status"] = "failed_no_conflicts"
                    status_counter["failed_no_conflicts"] += 1
                result.update({
                    "pick_returncode": pick.returncode,
                    "stdout_tail": (pick.stdout or "")[-500:],
                    "stderr_tail": (pick.stderr or "")[-500:],
                })
            else:
                ok, actions, unsafe = resolve_conflicts()
                if ok:
                    new_head = git("rev-parse", "--short", "HEAD")
                    new_subject = git("show", "-s", "--format=%s", "HEAD")
                    result.update({
                        "status": "applied_after_conflict_resolution",
                        "new_head": new_head,
                        "new_subject": new_subject,
                        "conflict_actions": actions,
                    })
                    status_counter["applied_after_conflict_resolution"] += 1
                else:
                    # Always clear cherry-pick state after a failed conflict path.
                    run(["git", "cherry-pick", "--abort"])
                    result.update({
                        "status": "failed_unsafe_conflict" if unsafe else "failed_conflict_continue",
                        "conflict_actions": actions,
                        "unsafe_paths": unsafe,
                        "pick_returncode": pick.returncode,
                        "stdout_tail": (pick.stdout or "")[-500:],
                        "stderr_tail": (pick.stderr or "")[-500:],
                    })
                    if unsafe:
                        status_counter["failed_unsafe_conflict"] += 1
                    else:
                        status_counter["failed_conflict_continue"] += 1

        with jsonl_path.open("a") as f:
            f.write(json.dumps(result) + "\n")

    summary = {
        "timestamp": ts,
        "queue_file": str(Path(args.queue).resolve()),
        "base": args.base,
        "branch": branch,
        "total_attempted": len(queue),
        "status_counts": dict(status_counter),
        "results_jsonl": str(jsonl_path.resolve()),
    }
    summary_path.write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
