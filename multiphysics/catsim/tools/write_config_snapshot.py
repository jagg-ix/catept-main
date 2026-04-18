#!/usr/bin/env python3
"""Write a minimal, reproducible config snapshot for PAPER_LOGS/.

This is not meant to be a full provenance system; it just captures the
load-bearing knobs used by the paper pipeline so reruns can be compared.
"""

from __future__ import annotations

import argparse
import json
import platform
import sys
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--paper_tables", default="PAPER_TABLES")
    ap.add_argument("--paper_logs", default="PAPER_LOGS")
    ap.add_argument("--db", default="data_pipeline/user_scripts/double_slit.sqlite3")
    args = ap.parse_args()

    paper_tables = Path(args.paper_tables)
    paper_logs = Path(args.paper_logs)
    paper_logs.mkdir(parents=True, exist_ok=True)

    snap = {
        "python": sys.version.split()[0],
        "platform": platform.platform(),
        "db_path": str(Path(args.db)),
        "phase5_status_json": None,
        "enz_config": "configs/enz_model.yaml",
    }

    p5 = paper_tables / "PREDICTIONS" / "status.json"
    if p5.exists():
        snap["phase5_status_json"] = json.loads(p5.read_text())

    (paper_logs / "config_snapshot.json").write_text(json.dumps(snap, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
