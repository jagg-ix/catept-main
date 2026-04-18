#!/usr/bin/env python3
"""Collect STATUS artifacts into PAPER_LOGS/STATUS/.

Each phase writes a STATUS.txt (sometimes STATUS.md) in its output folder.
This tool copies those files into one place for quick inspection.
"""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path


def _copy_if_exists(src: Path, dst: Path) -> None:
    if src.exists() and src.is_file():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--paper_tables", default="PAPER_TABLES")
    ap.add_argument("--paper_logs", default="PAPER_LOGS")
    args = ap.parse_args()

    pt = Path(args.paper_tables)
    pl = Path(args.paper_logs)
    out = pl / "STATUS"
    out.mkdir(parents=True, exist_ok=True)

    # Known locations
    candidates = {
        "phase3_iff": pt / "IFF_GATES" / "STATUS.txt",
        "phase5_predictions": pt / "PREDICTIONS" / "STATUS.txt",
        "phase6_1_geometric": pt / "ADVANCED" / "GEOMETRIC_LAMBDA" / "STATUS.txt",
        "phase6_2_modular": pt / "ADVANCED" / "MODULAR_PROXY" / "STATUS.txt",
        "phase6_3_bounds": pt / "ADVANCED" / "BOUNDS" / "STATUS.txt",
    }

    for name, src in candidates.items():
        _copy_if_exists(src, out / f"{name}.txt")

    # Also grab any nested STATUS files we don't know about
    for src in pt.rglob("STATUS.txt"):
        rel = src.relative_to(pt).as_posix().replace("/", "__")
        _copy_if_exists(src, out / f"extra__{rel}")

    (out / "README.txt").write_text(
        "Collected STATUS files.\n"
        "If a phase changes from PASS->FAIL after a patch, compare the relevant logs in PAPER_LOGS/.\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
