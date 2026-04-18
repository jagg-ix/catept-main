"""Phase 6.12: PyNE entropic-time compatibility (optional)."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess


def _auto_find_phi_profile() -> str | None:
    candidates = [
        "PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES/profiles",
        "PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES",
    ]
    for base in candidates:
        p = Path(base)
        if not p.exists() or not p.is_dir():
            continue
        matches = sorted(p.glob("**/tensor_profile_*.csv"))
        if matches:
            return str(matches[0])
    return None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    phi_path = _auto_find_phi_profile()
    cmd = [
        "python",
        "scripts/pyne_entropic_demo.py",
        "--out",
        str(out),
    ]
    if phi_path:
        cmd += ["--phi_profile_csv", phi_path]
    return subprocess.call(cmd)


if __name__ == "__main__":
    raise SystemExit(main())
