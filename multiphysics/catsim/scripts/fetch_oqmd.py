"""Fetch a small OQMD subset (placeholder).

OQMD provides programmatic access; details depend on the current API.
This repo ships no OQMD bulk data.
"""

from __future__ import annotations

from pathlib import Path


def main() -> int:
    out_dir = Path("data/vendor/oqmd")
    print(
        "OQMD downloader not implemented.\n"
        "Use the OQMD API to fetch the specific subset you need (e.g., In2O3-like entries).\n"
        f"Target directory: {out_dir.resolve()}\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
