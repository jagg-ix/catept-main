#!/usr/bin/env python3
"""Phase 6.10: PySCF interoperability (optional)."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from catsim_core.gates.status import write_status
from catsim_core.pyscf.adapter import pyscf_available


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    if not pyscf_available():
        write_status(outdir, ok=False, status="SKIP", details="PySCF not available")
        (outdir / "summary.json").write_text(json.dumps({"status": "SKIP"}, indent=2))
        return 0

    from pyscf_interop_demo import main as demo_main  # type: ignore

    return int(demo_main())


if __name__ == "__main__":
    raise SystemExit(main())
