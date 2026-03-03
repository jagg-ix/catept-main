#!/usr/bin/env python3
"""Phase 7: Create a single reproducibility bundle zip.

The bundle is designed to be self-contained for rerunning the full pipeline:

  - source code (src/, scripts/, tools/)
  - pipeline inputs (data_pipeline/source_data/ ...)
  - generated artifacts: PAPER_TABLES/, PAPER_FIGS/, PAPER_LOGS/ and
    verification_report.csv if present

We avoid bundling large caches; this is meant to be portable.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import zipfile


INCLUDE_DIRS = [
    "src",
    "scripts",
    "tools",
    "configs",
    "examples",
    "docs",
    "data_pipeline",
    "third_party",
    "TIROLE_DB",
    "PAPER_TABLES",
    "PAPER_FIGS",
    "PAPER_LOGS",
]

INCLUDE_FILES = [
    "README.md",
    "REPRO_DOUBLE_SLIT.md",
    "verification_report.csv",
    "collect.txt",
    "collect2.txt",
    "Makefile",
]


def _add_path(zf: zipfile.ZipFile, root: Path, path: Path) -> None:
    if path.is_dir():
        for p in path.rglob("*"):
            if p.is_file():
                rel = p.relative_to(root)
                zf.write(p, rel.as_posix())
    elif path.is_file():
        rel = path.relative_to(root)
        zf.write(path, rel.as_posix())


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=".")
    ap.add_argument("--out", default="catsim_tirole_paper_bundle.zip")
    args = ap.parse_args()

    root = Path(args.repo).resolve()
    out = (root / args.out).resolve()
    if out.exists():
        out.unlink()

    with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for d in INCLUDE_DIRS:
            p = root / d
            if p.exists():
                _add_path(zf, root, p)
        for f in INCLUDE_FILES:
            p = root / f
            if p.exists():
                _add_path(zf, root, p)

    print(f"Wrote: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
