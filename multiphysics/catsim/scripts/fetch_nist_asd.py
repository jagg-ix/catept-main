"""Fetch NIST Atomic Spectra Database subsets (placeholder).

NIST ASD is public-domain, but programmatic access varies by table.

This repository ships **no ASD bulk data** by default.

Recommended approach:
- Decide a specific ASD export format (CSV/JSON), and the minimal subset needed
  (e.g., only elements relevant to ITO constituents In/Sn/O and nearby lines).
- Implement a deterministic downloader that writes to:
    data/vendor/nist_asd/
  and records a PROVENANCE.yaml update.

For now, this script prints next actions.
"""

from __future__ import annotations

from pathlib import Path


def main() -> int:
    repo = Path(__file__).resolve().parents[1]
    out_dir = repo / "data" / "vendor" / "nist_asd"
    print("NIST ASD fetch not implemented yet.")
    print(f"Target output directory: {out_dir}")
    print("Next: implement a deterministic downloader for a chosen ASD endpoint.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
