"""Fail-fast validation that vendored data has provenance.

This is *not* a legal tool. It enforces the repo invariant:
  - if we ship any data files, we ship a `PROVENANCE.yaml` next to them.

Run via:
  make data_license_check
"""

from __future__ import annotations

from pathlib import Path


def main() -> int:
    repo = Path(__file__).resolve().parents[1]
    vendor = repo / "data" / "vendor"
    if not vendor.exists():
        print("[data_license_check] OK: no data/vendor directory")
        return 0

    problems = []
    for subdir in sorted([p for p in vendor.iterdir() if p.is_dir()]):
        # README subtree is allowed but should still carry guidance
        prov = subdir / "PROVENANCE.yaml"
        if not prov.exists() and subdir.name != "README":
            problems.append(f"missing PROVENANCE.yaml in {subdir}")
        # If there are data files directly in the subtree, provenance must exist
        if any(p.is_file() and p.suffix.lower() not in {".md", ".txt", ".yaml"} for p in subdir.rglob("*")):
            if not prov.exists():
                problems.append(f"{subdir} contains data files but no PROVENANCE.yaml")

    if problems:
        print("[data_license_check] FAIL")
        for p in problems:
            print(" -", p)
        return 1

    print("[data_license_check] PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
