#!/usr/bin/env python3
"""Export time-domain traces (reflectivity vs delay) from SQLite.

Outputs CSV columns: delay_fs,reflectivity

Example:
  python scripts/export_sqlite_time_domain_to_csv.py \
    --db data/tirole_double_slit.sqlite3 \
    --experiment 1 \
    --out data/tirole_time_ex1.csv
"""

from __future__ import annotations

import argparse
from pathlib import Path

from cat_ept_doubleslit.db import export_time_domain_to_csv


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--experiment", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    exp = args.experiment
    if exp.isdigit():
        export_time_domain_to_csv(Path(args.db), Path(args.out), experiment_id=int(exp))
    else:
        export_time_domain_to_csv(Path(args.db), Path(args.out), ref=exp)

    print(f"Wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
