"""Fetch a small Materials Project subset into `data/vendor/materials_project/`.

We do **not** ship Materials Project data in this repo.

This script is a convenience wrapper around the Materials Project API.
It is intentionally minimal and may need adjustment depending on upstream API versions.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--api-key", required=True, help="Materials Project API key")
    ap.add_argument("--formula", required=True, help="e.g., In2O3")
    ap.add_argument(
        "--out",
        default="data/vendor/materials_project/mp_subset.json",
        help="output path",
    )
    args = ap.parse_args()

    # Deferred import so the repo does not require this dependency.
    try:
        from mp_api.client import MPRester  # type: ignore
    except Exception as e:
        raise SystemExit(
            "mp_api is not installed. Try: pip install mp-api\n"
            f"Original error: {e}"
        )

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)

    with MPRester(args.api_key) as mpr:
        # This is a deliberately small query. Expand as needed.
        docs = mpr.summary.search(formula=args.formula)
        payload = [d.dict() for d in docs]

    out.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"[materials_project] wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
