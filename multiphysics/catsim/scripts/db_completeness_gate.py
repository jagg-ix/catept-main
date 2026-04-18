#!/usr/bin/env python3
"""DB completeness gate for the Tirole temporal-double-slit pipeline.

This is *Phase 1* plumbing: ensure the SQLite DB produced by the XLSX->CSV->SQLite
pipeline is complete enough to support paper-faithful sweeps.

What it checks (hard fail by default):
  - Fig_2f provides spectra with slit_separation_fs populated per-row.
  - Fig_2g provides time_domain traces with slit_separation_fs populated per-row.
  - The Fig_2f sweep contains at least N distinct slit separations (default 17).

Outputs:
  PAPER_TABLES/DB_SUMMARY/db_summary.csv
  PAPER_TABLES/DB_SUMMARY/gate.json
  PAPER_TABLES/DB_SUMMARY/STATUS.txt  (PASS/FAIL)
"""

from __future__ import annotations

import argparse
import json
import sqlite3
from pathlib import Path

import pandas as pd


def _q1(cur, sql: str, params=()):
    cur.execute(sql, params)
    r = cur.fetchone()
    return r[0] if r else None


def summarize(db_path: Path) -> pd.DataFrame:
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    cur.execute("SELECT DISTINCT figure_ref FROM experiments ORDER BY figure_ref")
    figs = [r[0] for r in cur.fetchall()]

    rows = []
    for fig in figs:
        n_exp = _q1(cur, "SELECT COUNT(*) FROM experiments WHERE figure_ref=?", (fig,))
        n_exp_s = _q1(cur, "SELECT COUNT(*) FROM experiments WHERE figure_ref=? AND slit_separation_fs IS NOT NULL", (fig,))

        n_spec = _q1(cur, "SELECT COUNT(*) FROM spectra s JOIN experiments e ON e.id=s.experiment_id WHERE e.figure_ref=?", (fig,))
        n_spec_s = _q1(cur, "SELECT COUNT(DISTINCT s.slit_separation_fs) FROM spectra s JOIN experiments e ON e.id=s.experiment_id WHERE e.figure_ref=? AND s.slit_separation_fs IS NOT NULL", (fig,))

        n_td = _q1(cur, "SELECT COUNT(*) FROM time_domain t JOIN experiments e ON e.id=t.experiment_id WHERE e.figure_ref=?", (fig,))
        n_td_s = _q1(cur, "SELECT COUNT(DISTINCT t.slit_separation_fs) FROM time_domain t JOIN experiments e ON e.id=t.experiment_id WHERE e.figure_ref=? AND t.slit_separation_fs IS NOT NULL", (fig,))

        rows.append({
            "figure_ref": fig,
            "experiments": int(n_exp or 0),
            "experiments_with_slit_sep": int(n_exp_s or 0),
            "spectra_rows": int(n_spec or 0),
            "spectra_distinct_S": int(n_spec_s or 0),
            "time_domain_rows": int(n_td or 0),
            "time_domain_distinct_S": int(n_td_s or 0),
        })

    conn.close()
    return pd.DataFrame(rows)


def gate(db_path: Path, min_distinct_s: int, strict: bool) -> dict:
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    # Fig_2f (spectra sweep)
    fig2f_spec_rows = _q1(cur, """
        SELECT COUNT(*) FROM spectra s
        JOIN experiments e ON e.id=s.experiment_id
        WHERE e.figure_ref='Fig_2f'
    """)
    fig2f_s_nonnull = _q1(cur, """
        SELECT COUNT(*) FROM spectra s
        JOIN experiments e ON e.id=s.experiment_id
        WHERE e.figure_ref='Fig_2f' AND s.slit_separation_fs IS NOT NULL
    """)
    fig2f_distinct_s = _q1(cur, """
        SELECT COUNT(DISTINCT s.slit_separation_fs) FROM spectra s
        JOIN experiments e ON e.id=s.experiment_id
        WHERE e.figure_ref='Fig_2f' AND s.slit_separation_fs IS NOT NULL
    """)

    # Fig_2g (time-domain heatmap)
    fig2g_td_rows = _q1(cur, """
        SELECT COUNT(*) FROM time_domain t
        JOIN experiments e ON e.id=t.experiment_id
        WHERE e.figure_ref='Fig_2g'
    """)
    fig2g_s_nonnull = _q1(cur, """
        SELECT COUNT(*) FROM time_domain t
        JOIN experiments e ON e.id=t.experiment_id
        WHERE e.figure_ref='Fig_2g' AND t.slit_separation_fs IS NOT NULL
    """)
    fig2g_distinct_s = _q1(cur, """
        SELECT COUNT(DISTINCT t.slit_separation_fs) FROM time_domain t
        JOIN experiments e ON e.id=t.experiment_id
        WHERE e.figure_ref='Fig_2g' AND t.slit_separation_fs IS NOT NULL
    """)

    conn.close()

    def pct(n, d):
        if not d:
            return 0.0
        return float(n or 0) / float(d) * 100.0

    checks = {
        "fig2f": {
            "spectra_rows": int(fig2f_spec_rows or 0),
            "rows_with_S": int(fig2f_s_nonnull or 0),
            "pct_rows_with_S": pct(fig2f_s_nonnull, fig2f_spec_rows),
            "distinct_S": int(fig2f_distinct_s or 0),
        },
        "fig2g": {
            "time_domain_rows": int(fig2g_td_rows or 0),
            "rows_with_S": int(fig2g_s_nonnull or 0),
            "pct_rows_with_S": pct(fig2g_s_nonnull, fig2g_td_rows),
            "distinct_S": int(fig2g_distinct_s or 0),
        },
    }

    # Hard requirements
    reqs = []
    reqs.append((checks["fig2f"]["spectra_rows"] > 0, "Fig_2f must have spectra rows"))
    reqs.append((checks["fig2f"]["pct_rows_with_S"] >= 99.9, "Fig_2f spectra rows must have slit_separation_fs populated"))
    reqs.append((checks["fig2f"]["distinct_S"] >= min_distinct_s, f"Fig_2f must have >= {min_distinct_s} distinct S"))

    # Fig_2g is optional for the spectral sweep, but required for later phases.
    reqs.append((checks["fig2g"]["time_domain_rows"] > 0, "Fig_2g must have time_domain rows"))
    reqs.append((checks["fig2g"]["pct_rows_with_S"] >= 99.9, "Fig_2g time_domain rows must have slit_separation_fs populated"))

    passed = all(ok for ok, _ in reqs)
    failures = [msg for ok, msg in reqs if not ok]

    result = {
        "passed": bool(passed),
        "min_distinct_S": int(min_distinct_s),
        "checks": checks,
        "failures": failures,
        "strict": bool(strict),
    }
    if strict and not passed:
        raise SystemExit("DB completeness gate FAILED: " + "; ".join(failures))
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default="data_pipeline/user_scripts/double_slit.sqlite3")
    ap.add_argument("--out", default="PAPER_TABLES/DB_SUMMARY")
    ap.add_argument("--min_distinct_S", type=int, default=17)
    ap.add_argument("--non_strict", action="store_true", help="Do not exit non-zero on failure")
    args = ap.parse_args()

    db_path = Path(args.db)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    df = summarize(db_path)
    df.to_csv(out_dir / "db_summary.csv", index=False)

    strict = not args.non_strict
    res = gate(db_path, min_distinct_s=args.min_distinct_S, strict=strict)
    (out_dir / "gate.json").write_text(json.dumps(res, indent=2))
    (out_dir / "STATUS.txt").write_text("PASS\n" if res["passed"] else "FAIL\n")
    print((out_dir / "STATUS.txt").read_text().strip())


if __name__ == "__main__":
    main()
