"""Export SGI sqlite tables to CSV for quick inspection.

Usage:
  python -m scripts.sgi_export --db data/sgi/sgidb.sqlite --out PAPER_TABLES/SGI_DB_EXPORT
"""
from __future__ import annotations
import argparse, sqlite3, csv
from pathlib import Path

TABLES = [
  "params",
  "fig3_population_vs_T",
  "fig4_momentum_width",
  "fig5_spatial_coherence",
  "fig6a_visibility_vs_dz",
  "fig6b_visibility_vs_dv",
  "fig8_visibility_vs_Td1",
  "meta_source_files",
]

def export_table(conn, table: str, out_dir: Path):
    cur = conn.cursor()
    cur.execute(f"SELECT * FROM {table}")
    rows = cur.fetchall()
    cols = [d[0] for d in cur.description]
    out_path = out_dir / f"{table}.csv"
    out_dir.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(cols)
        w.writerows(rows)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    conn = sqlite3.connect(args.db)
    try:
        out_dir = Path(args.out)
        for t in TABLES:
            export_table(conn, t, out_dir)
    finally:
        conn.close()

if __name__ == "__main__":
    main()
