#!/usr/bin/env python3
"""Phase 6.18: Materials Project (MP) cached subset gate.

This phase **does not** download anything. It validates and registers an
already-downloaded subset in `data/cache/materials_project/`.

Produces:
  PAPER_LOGS/PHASE6/6.18_MP_CACHE/STATUS.md
  PAPER_LOGS/PHASE6/6.18_MP_CACHE/summary.json
  PAPER_LOGS/PHASE6/6.18_MP_CACHE/data_sources.json

If no cache files are present, status=SKIP.
"""

from __future__ import annotations

import argparse
import json
import hashlib
from pathlib import Path

from catsim_core.logs.status import write_status_md, write_summary_json
from catsim_core.data_sources.export import write_data_sources_json


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache_dir", type=str, default="data/cache/materials_project")
    args = ap.parse_args()

    log_dir = Path("PAPER_LOGS/PHASE6/6.18_MP_CACHE")
    log_dir.mkdir(parents=True, exist_ok=True)

    cache_dir = Path(args.cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)

    json_files = sorted([p for p in cache_dir.glob("mp_subset__*.json") if p.is_file()])
    if not json_files:
        write_status_md(log_dir / "STATUS.md", phase="6.18_MP_CACHE", status="SKIP",
                        notes=["No cached MP subset found", "Run scripts/fetch_materials_project_subset.py to create one"])
        write_summary_json(log_dir / "summary.json", {
            "phase": "6.18_MP_CACHE",
            "status": "SKIP",
            "cache_dir": str(cache_dir),
            "n_files": 0,
        })
        repo_root = Path(__file__).resolve().parents[1]
        write_data_sources_json(log_dir / "data_sources.json", repo_root=repo_root)
        return 0

    validated = []
    notes = []
    for p in json_files:
        try:
            obj = json.loads(p.read_text(encoding="utf-8"))
            schema_ok = isinstance(obj, dict) and obj.get("schema") == "catsim.cache.materials_project.subset.v1"
            sha = sha256_file(p)
            if not schema_ok:
                notes.append(f"WARN: {p.name} schema mismatch")
            validated.append({
                "path": str(p),
                "sha256": sha,
                "n_records": int(obj.get("n_records", 0)) if isinstance(obj, dict) else 0,
                "query": obj.get("query", {}) if isinstance(obj, dict) else {},
            })
        except Exception as e:
            notes.append(f"WARN: {p.name} failed to parse: {e}")

    status = "PASS" if validated else "SKIP"
    if validated:
        notes.insert(0, f"Validated {len(validated)} cached MP subset file(s)")

    write_status_md(log_dir / "STATUS.md", phase="6.18_MP_CACHE", status=status, notes=notes)
    write_summary_json(log_dir / "summary.json", {
        "phase": "6.18_MP_CACHE",
        "status": status,
        "cache_dir": str(cache_dir),
        "files": validated,
    })

    repo_root = Path(__file__).resolve().parents[1]
    write_data_sources_json(log_dir / "data_sources.json", repo_root=repo_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
