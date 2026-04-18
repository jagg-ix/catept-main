#!/usr/bin/env python3
import argparse
import csv
import json
import re
import subprocess
from collections import Counter
from pathlib import Path

STAGE_RE = re.compile(r"\bStage(?:s)?\s+([0-9]{1,4})\b", re.IGNORECASE)
TRAILER_RE = re.compile(r"cherry picked from commit\s+([0-9a-f]{7,40})", re.IGNORECASE)

# User-confirmed missing SHAs from prior manual-batch audit.
MISSING_SOURCE_REFS = [
    "8eb9c4f0a",
    "ca879b308",
]

PRIORITY_RANK = {
    "G1_core_spectral_geometry": 1,
    "G2_functional_energy": 2,
    "G3_solver_stability": 3,
    "G4_other": 9,
}

G1_KEYWORDS = (
    "fourier",
    "parseval",
    "spectral",
    "triad",
    "triadic",
    "torus",
    "lattice",
    "fft",
    "shell",
    "mode",
    "harmonic",
)

G2_KEYWORDS = (
    "energy",
    "enstrophy",
    "entropy",
    "palinstrophy",
    "positiv",
    "monot",
    "functional",
    "dissipation",
    "lyapunov",
    "bound",
)

G3_KEYWORDS = (
    "solver",
    "stability",
    "convergence",
    "compactness",
    "splitting",
    "cayley",
    "iteration",
    "recurrence",
    "ode",
    "weaklimit",
    "weak limit",
)


def git(*args: str, check: bool = True) -> str:
    res = subprocess.run(["git", *args], capture_output=True, text=True)
    if check and res.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {res.stderr.strip()}")
    return res.stdout.strip()


def resolve_commit(ref: str) -> str | None:
    out = git("rev-parse", "--verify", "--quiet", f"{ref}^{{commit}}", check=False)
    return out if out else None


def get_subject(ref: str) -> str:
    return git("show", "-s", "--format=%s", ref)


def get_body(ref: str) -> str:
    return git("show", "-s", "--format=%B", ref)


def get_files(ref: str) -> list[str]:
    out = git("show", "--name-only", "--pretty=format:", ref)
    return [line.strip() for line in out.splitlines() if line.strip()]


def extract_stage(subject: str) -> int | None:
    m = STAGE_RE.search(subject or "")
    if not m:
        return None
    try:
        return int(m.group(1))
    except ValueError:
        return None


def classify_priority(subject: str, files: list[str]) -> str:
    text = (subject + " " + " ".join(files)).lower()
    if any(k in text for k in G1_KEYWORDS):
        return "G1_core_spectral_geometry"
    if any(k in text for k in G2_KEYWORDS):
        return "G2_functional_energy"
    if any(k in text for k in G3_KEYWORDS):
        return "G3_solver_stability"
    return "G4_other"


def make_entry(*, replay_ref: str, source_sha: str | None, source_commit: str, source_subject: str,
               origin_branch_commit: str, origin_branch_subject: str, origin_type: str,
               injected_missing: bool) -> dict:
    files = get_files(source_commit)
    priority_group = classify_priority(source_subject, files)
    return {
        "replay_ref": replay_ref,
        "source_sha": source_sha,
        "source_commit": source_commit,
        "source_subject": source_subject,
        "stage": extract_stage(source_subject),
        "priority_group": priority_group,
        "priority_rank": PRIORITY_RANK[priority_group],
        "origin_branch_commit": origin_branch_commit,
        "origin_branch_subject": origin_branch_subject,
        "origin_type": origin_type,
        "injected_missing": injected_missing,
        "files_changed_count": len(files),
        "files_changed_sample": files[:10],
    }


def main() -> None:
    ap = argparse.ArgumentParser(description="Build deduped recovery replay queues from a branch.")
    ap.add_argument("--base", default="main")
    ap.add_argument("--source-branch", default="cherry-pick-nsi-related-20260417")
    ap.add_argument("--out-dir", default=".recovery")
    args = ap.parse_args()

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    branch_commits = git("rev-list", "--reverse", f"{args.base}..{args.source_branch}").splitlines()

    seen: set[str] = set()
    duplicates: list[dict] = []
    entries: list[dict] = []

    for commit in branch_commits:
        branch_subject = get_subject(commit)
        body = get_body(commit)
        trailer = TRAILER_RE.search(body)

        if trailer:
            src_ref = trailer.group(1)
            src_full = resolve_commit(src_ref) or src_ref
            dedupe_key = f"src:{src_full}"
            if dedupe_key in seen:
                duplicates.append({
                    "duplicate_branch_commit": commit,
                    "duplicate_branch_subject": branch_subject,
                    "source_ref": src_ref,
                    "source_resolved": src_full,
                })
                continue
            seen.add(dedupe_key)
            source_subject = get_subject(src_full) if resolve_commit(src_full) else branch_subject
            entries.append(
                make_entry(
                    replay_ref=src_full,
                    source_sha=src_full,
                    source_commit=src_full,
                    source_subject=source_subject,
                    origin_branch_commit=commit,
                    origin_branch_subject=branch_subject,
                    origin_type="source_trailer",
                    injected_missing=False,
                )
            )
        else:
            dedupe_key = f"direct:{commit}"
            if dedupe_key in seen:
                duplicates.append({
                    "duplicate_branch_commit": commit,
                    "duplicate_branch_subject": branch_subject,
                    "source_ref": None,
                    "source_resolved": commit,
                })
                continue
            seen.add(dedupe_key)
            entries.append(
                make_entry(
                    replay_ref=commit,
                    source_sha=None,
                    source_commit=commit,
                    source_subject=branch_subject,
                    origin_branch_commit=commit,
                    origin_branch_subject=branch_subject,
                    origin_type="direct_branch_commit",
                    injected_missing=False,
                )
            )

    # Ensure previously-audited missing SHAs are explicitly present.
    for missing_ref in MISSING_SOURCE_REFS:
        missing_full = resolve_commit(missing_ref)
        if not missing_full:
            continue
        key = f"src:{missing_full}"
        if key in seen:
            continue

        subject = get_subject(missing_full)
        stage = extract_stage(subject)
        missing_entry = make_entry(
            replay_ref=missing_full,
            source_sha=missing_full,
            source_commit=missing_full,
            source_subject=subject,
            origin_branch_commit="(injected)",
            origin_branch_subject=f"(injected missing source) {subject}",
            origin_type="injected_missing_source",
            injected_missing=True,
        )

        # Deterministic insertion by stage (if available), else append.
        inserted = False
        if stage is not None:
            for idx, existing in enumerate(entries):
                estage = existing.get("stage")
                if estage is not None and estage > stage:
                    entries.insert(idx, missing_entry)
                    inserted = True
                    break
        if not inserted:
            entries.append(missing_entry)
        seen.add(key)

    # Annotate natural order after all insertions.
    for i, entry in enumerate(entries, start=1):
        entry["natural_order"] = i

    priority_entries = sorted(
        entries,
        key=lambda e: (
            e["priority_rank"],
            e["natural_order"],
        ),
    )
    for i, entry in enumerate(priority_entries, start=1):
        entry["priority_order"] = i

    natural_path = out_dir / "recovery_queue_natural.json"
    priority_path = out_dir / "recovery_queue_priority.json"
    duplicates_path = out_dir / "recovery_queue_duplicates.json"
    csv_path = out_dir / "recovery_queue_priority.csv"
    summary_path = out_dir / "recovery_queue_summary.txt"

    natural_path.write_text(json.dumps(entries, indent=2) + "\n")
    priority_path.write_text(json.dumps(priority_entries, indent=2) + "\n")
    duplicates_path.write_text(json.dumps(duplicates, indent=2) + "\n")

    with csv_path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "priority_order",
            "natural_order",
            "priority_group",
            "stage",
            "replay_ref",
            "source_subject",
            "origin_type",
            "injected_missing",
            "files_changed_count",
        ])
        for e in priority_entries:
            writer.writerow([
                e.get("priority_order"),
                e.get("natural_order"),
                e.get("priority_group"),
                e.get("stage"),
                e.get("replay_ref"),
                e.get("source_subject"),
                e.get("origin_type"),
                e.get("injected_missing"),
                e.get("files_changed_count"),
            ])

    by_group = Counter(e["priority_group"] for e in priority_entries)
    by_origin = Counter(e["origin_type"] for e in priority_entries)

    summary_lines = [
        f"base={args.base}",
        f"source_branch={args.source_branch}",
        f"branch_commit_count={len(branch_commits)}",
        f"deduped_queue_count={len(entries)}",
        f"duplicates_skipped={len(duplicates)}",
        "priority_counts=" + json.dumps(dict(by_group), sort_keys=True),
        "origin_counts=" + json.dumps(dict(by_origin), sort_keys=True),
        f"injected_missing_count={sum(1 for e in entries if e['injected_missing'])}",
        f"natural_queue={natural_path}",
        f"priority_queue={priority_path}",
        f"priority_csv={csv_path}",
        f"duplicates_file={duplicates_path}",
    ]
    summary_path.write_text("\n".join(summary_lines) + "\n")

    print("\n".join(summary_lines))


if __name__ == "__main__":
    main()
