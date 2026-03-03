"""Fetch a *deterministic* Materials Project subset into `data/cache/materials_project/`.

This is the recommended MP fetch helper for catsim.

Goals:
- Deterministic outputs (stable field set, stable sorting, stable file names).
- Small footprint (summary fields only).
- Offline-repro friendly (writes a self-contained JSON + sha256).

We do **not** ship Materials Project data in this repository.

Usage
-----
  python scripts/fetch_materials_project_subset.py --api-key "$MP_API_KEY" \
      --chemsys In-Sn-O --limit 50

Outputs
-------
  data/cache/materials_project/mp_subset__In-Sn-O__limit50.json
  data/cache/materials_project/mp_subset__In-Sn-O__limit50.sha256
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any, Dict, List


DEFAULT_FIELDS = [
    "material_id",
    "formula_pretty",
    "composition_reduced",
    "energy_above_hull",
    "band_gap",
    "efermi",
    "density",
    "volume",
    "nsites",
    "symmetry",
]


def _sha256_bytes(b: bytes) -> str:
    h = hashlib.sha256()
    h.update(b)
    return h.hexdigest()


def _canonicalize_doc(d: Any) -> Any:
    """Convert MP docs into JSON-serializable primitives."""
    if hasattr(d, "model_dump"):
        return d.model_dump()
    if hasattr(d, "dict"):
        return d.dict()
    return d


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--api-key", required=True, help="Materials Project API key")
    ap.add_argument(
        "--chemsys",
        default="In-Sn-O",
        help="Chemical system, e.g. In-Sn-O",
    )
    ap.add_argument("--limit", type=int, default=50)
    ap.add_argument(
        "--fields",
        default=",".join(DEFAULT_FIELDS),
        help="Comma-separated MP summary fields to request",
    )
    ap.add_argument(
        "--outdir",
        default="data/cache/materials_project",
        help="Output directory",
    )
    args = ap.parse_args()

    try:
        from mp_api.client import MPRester  # type: ignore
    except Exception as e:
        raise SystemExit(
            "mp_api is not installed. Try: pip install mp-api\n"
            f"Original error: {e}"
        )

    fields = [f.strip() for f in args.fields.split(",") if f.strip()]
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    stem = f"mp_subset__{args.chemsys}__limit{args.limit}"
    out_json = outdir / f"{stem}.json"
    out_sha = outdir / f"{stem}.sha256"

    with MPRester(args.api_key) as mpr:
        docs = mpr.summary.search(
            chemsys=args.chemsys,
            fields=fields,
            # Many MP endpoints accept `num_chunks`/`chunk_size`; `limit` is
            # supported in newer mp-api. If upstream changes, keep this helper
            # minimal and adjust here.
            limit=args.limit,
        )
        rows: List[Dict[str, Any]] = [_canonicalize_doc(d) for d in docs]

    # Deterministic ordering
    rows.sort(key=lambda r: str(r.get("material_id", "")))

    payload = {
        "schema": "catsim.materials_project.subset.v1",
        "query": {"chemsys": args.chemsys, "limit": args.limit, "fields": fields},
        "rows": rows,
    }
    blob = (json.dumps(payload, indent=2, sort_keys=True) + "\n").encode("utf-8")
    out_json.write_bytes(blob)
    out_sha.write_text(_sha256_bytes(blob) + "\n", encoding="utf-8")

    print(f"[materials_project] wrote {out_json}")
    print(f"[materials_project] sha256 {out_sha.read_text().strip()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
