#!/usr/bin/env python3
"""Export spectra traces from the included SQLite DB to a CSV usable by the fitter.

Example:
  python scripts/export_sqlite_spectra_to_csv.py \
    --db data/tirole_double_slit.sqlite3 \
    --experiment 1 \
    --out data/tirole_spectrum_ex1.csv

The output CSV has columns: wavelength_m,intensity
"""

from __future__ import annotations

import argparse
from pathlib import Path

from cat_ept_doubleslit.db import export_spectra_to_csv


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True, help="Path to SQLite DB")
    ap.add_argument(
        "--experiment",
        required=True,
        help="Experiment identifier: integer id OR a figure_ref string if present.",
    )
    ap.add_argument("--out", required=True, help="Output CSV path")
    args = ap.parse_args()

    exp = args.experiment
    if exp.isdigit():
        export_spectra_to_csv(Path(args.db), Path(args.out), experiment_id=int(exp))
    else:
        export_spectra_to_csv(Path(args.db), Path(args.out), ref=exp)
    print(f"Wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
