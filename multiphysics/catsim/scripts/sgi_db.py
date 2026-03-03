"""SGI SQLite access helpers."""

from __future__ import annotations
from pathlib import Path
from typing import Dict, List, Tuple, Any
import sqlite3

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

def connect(db_path: Path) -> sqlite3.Connection:
    return sqlite3.connect(str(db_path))

def fetch_all(conn: sqlite3.Connection, table: str) -> Tuple[List[str], List[Tuple[Any,...]]]:
    cur = conn.cursor()
    cur.execute(f"SELECT * FROM {table}")
    rows = cur.fetchall()
    cols = [d[0] for d in cur.description]
    return cols, rows

def export_table_csv(conn: sqlite3.Connection, table: str, out_csv: Path) -> None:
    cols, rows = fetch_all(conn, table)
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    import csv
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(cols)
        w.writerows(rows)

def export_all(db_path: Path, out_dir: Path) -> Dict[str,str]:
    """Export all known tables to CSV. Returns mapping table->csv path."""
    out_dir.mkdir(parents=True, exist_ok=True)
    conn = connect(db_path)
    try:
        mapping={}
        for t in TABLES:
            out_csv = out_dir / f"{t}.csv"
            export_table_csv(conn, t, out_csv)
            mapping[t]=str(out_csv)
        return mapping
    finally:
        conn.close()
