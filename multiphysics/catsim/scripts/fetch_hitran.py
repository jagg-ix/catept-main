"""Fetch HITRAN subsets (placeholder).

HITRAN access typically requires registration and has terms of use.
This repo ships no HITRAN data.

Implementers should:
- choose a band / molecule subset relevant to the optical frequencies of interest
- download via HITRAN API or exported tables
- store into data/vendor/hitran/ with PROVENANCE.yaml updated accordingly
"""

from __future__ import annotations

from pathlib import Path


def main() -> int:
    out_dir = Path("data/vendor/hitran")
    print(
        "HITRAN downloader not implemented.\n"
        f"Place your subset under {out_dir}/ and update {out_dir}/PROVENANCE.yaml."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
