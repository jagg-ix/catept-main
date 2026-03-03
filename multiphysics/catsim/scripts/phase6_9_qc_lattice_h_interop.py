#!/usr/bin/env python3
"""Phase 6.9: QC_lattice_H interoperability (optional)."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from catsim_core.gates.status import write_status
from catsim_core.qc_lattice_h.adapter import qc_lattice_h_available


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    if not qc_lattice_h_available():
        write_status(outdir, ok=False, status="SKIP", details="QC_lattice_H not available")
        (outdir / "summary.json").write_text(json.dumps({"status": "SKIP"}, indent=2))
        return 0

    # Delegate to the demo script to keep logic single-sourced.
    from qc_lattice_h_interop_demo import main as demo_main  # type: ignore

    return int(demo_main())


if __name__ == "__main__":
    raise SystemExit(main())
