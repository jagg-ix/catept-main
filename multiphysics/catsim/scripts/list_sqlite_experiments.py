#!/usr/bin/env python3
"""Print available experiments from the SQLite DB."""

from __future__ import annotations

import argparse

from cat_ept_doubleslit.db import list_experiments


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    args = ap.parse_args()

    exps = list_experiments(args.db)
    if not exps:
        print("No experiments found.")
        return 0

    print("id\tfigure_ref\tslit_sep_fs\tpump_condition\tfile_name")
    for e in exps:
        print(f"{e.id}\t{e.figure_ref}\t{e.slit_separation_fs}\t{e.pump_condition}\t{e.file_name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
