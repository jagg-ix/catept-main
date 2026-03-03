"""SGI TXT -> SQLite ingestion pipeline.

This mirrors the double-slit pipeline: keep paper-extracted source data in a canonical SQLite DB
with provenance and checksums.

Run:
    python -m scripts.sgi_ingest --in data/sgi_txt --out data/sgi/sgidb.sqlite
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Iterable

NUM_RE = re.compile(r"^[+-]?(?:\d+\.?\d*|\d*\.?\d+)(?:[eE][+-]?\d+)?$")

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1<<20), b""):
            h.update(chunk)
    return h.hexdigest()

def parse_numeric_table(path: Path, expect_cols: Optional[int] = None) -> List[List[float]]:
    """Parse whitespace-separated numeric tables.

    Accepts optional header lines; ignores lines that don't look like numeric rows.
    """
    rows: List[List[float]] = []
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = re.split(r"[\s,]+", line)
        if any(not NUM_RE.match(p) for p in parts):
            continue
        vals = [float(p) for p in parts]
        if expect_cols is not None and len(vals) != expect_cols:
            # keep but ignore mismatched numeric lines
            continue
        rows.append(vals)
    return rows

def parse_master_params(path: Path) -> List[Dict[str, str]]:
    """Parse master-params.txt into structured rows.

    Flexible: captures the raw line and tries to split into (name, value, unit, note).
    """
    out=[]
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        raw=line.strip()
        if not raw or raw.startswith("#"):
            continue
        # heuristic: name: value unit (optional)
        # e.g. "B0 = 0.001 T" or "mu_B 9.274e-24 J/T"
        name=None; value=None; unit=None
        m = re.match(r"^([A-Za-z0-9_\-\(\)\[\]/]+)\s*(?:=|:)\s*([+-]?[0-9\.eE]+)\s*(.*)$", raw)
        if m:
            name=m.group(1); value=m.group(2); rest=m.group(3).strip()
            unit=rest if rest else None
        else:
            # fallback: first token name, second token numeric
            parts=re.split(r"\s+", raw)
            if len(parts)>=2 and NUM_RE.match(parts[1]):
                name=parts[0]; value=parts[1]; unit=" ".join(parts[2:]) if len(parts)>2 else None
        out.append({
            "raw": raw,
            "name": name or "",
            "value": value or "",
            "unit": unit or "",
        })
    return out

def create_schema(conn: sqlite3.Connection) -> None:
    cur = conn.cursor()
    cur.executescript(
        """
        PRAGMA journal_mode=WAL;
        PRAGMA foreign_keys=ON;

        CREATE TABLE IF NOT EXISTS meta_source_files(
            path TEXT PRIMARY KEY,
            sha256 TEXT NOT NULL,
            ingested_at TEXT NOT NULL,
            note TEXT
        );

        CREATE TABLE IF NOT EXISTS params(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            value TEXT,
            unit TEXT,
            raw TEXT
        );

        CREATE TABLE IF NOT EXISTS fig3_population_vs_T(
            T2_plus_T3_us REAL,
            population_percent REAL,
            err REAL
        );

        CREATE TABLE IF NOT EXISTS fig4_momentum_width(
            delta_v_mm_s REAL,
            population_percent REAL,
            err REAL
        );

        CREATE TABLE IF NOT EXISTS fig5_spatial_coherence(
            Td_us REAL,
            pop_blue REAL,
            err_blue REAL,
            pop_red REAL,
            err_red REAL
        );

        CREATE TABLE IF NOT EXISTS fig6a_visibility_vs_dz(
            delta_z_um REAL,
            visibility REAL,
            err REAL
        );

        CREATE TABLE IF NOT EXISTS fig6b_visibility_vs_dv(
            delta_v_mm_s REAL,
            visibility REAL,
            err REAL
        );

        CREATE TABLE IF NOT EXISTS fig8_visibility_vs_Td1(
            Td1_us REAL,
            vis_splitstop REAL,
            err_splitstop REAL,
            vis_fullloop REAL,
            err_fullloop REAL,
            ramsey_ref REAL
        );
        """
    )
    conn.commit()

def clear_tables(conn: sqlite3.Connection) -> None:
    cur=conn.cursor()
    for t in ["params","fig3_population_vs_T","fig4_momentum_width","fig5_spatial_coherence","fig6a_visibility_vs_dz","fig6b_visibility_vs_dv","fig8_visibility_vs_Td1"]:
        cur.execute(f"DELETE FROM {t};")
    conn.commit()

def ingest(in_dir: Path, out_db: Path, *, verify_expected: bool = True) -> None:
    in_dir = in_dir.resolve()
    out_db.parent.mkdir(parents=True, exist_ok=True)

    expected_path = in_dir/"EXPECTED_SHA256.json"
    expected = None
    if expected_path.exists():
        expected = json.loads(expected_path.read_text(encoding="utf-8"))
    elif verify_expected:
        raise SystemExit(f"Expected hash file missing: {expected_path}")

    conn = sqlite3.connect(str(out_db))
    try:
        create_schema(conn)
        clear_tables(conn)
        cur = conn.cursor()

        # verify + record provenance
        for fname in ["page1.txt","master-params.txt","fig3.txt","fig4.txt","fig5.txt","fig6A.txt","fig6B.txt","fig8.txt"]:
            p = in_dir/fname
            if not p.exists():
                raise SystemExit(f"Missing input: {p}")
            h = sha256_file(p)
            if verify_expected and expected is not None:
                exp = expected.get("files", {}).get(fname)
                if exp and exp != h:
                    raise SystemExit(f"Checksum mismatch for {fname}: expected {exp} got {h}")
            cur.execute(
                "INSERT OR REPLACE INTO meta_source_files(path, sha256, ingested_at, note) VALUES(?,?,datetime('now'),?)",
                (str(p.relative_to(in_dir)), h, "paper-extracted txt")
            )

        # params
        params = parse_master_params(in_dir/"master-params.txt")
        cur.executemany(
            "INSERT INTO params(name,value,unit,raw) VALUES(?,?,?,?)",
            [(r["name"], r["value"], r["unit"], r["raw"]) for r in params]
        )

        # fig3: 3 cols
        fig3 = parse_numeric_table(in_dir/"fig3.txt", expect_cols=3)
        cur.executemany("INSERT INTO fig3_population_vs_T(T2_plus_T3_us,population_percent,err) VALUES(?,?,?)", fig3)

        # fig4: 3 cols
        fig4 = parse_numeric_table(in_dir/"fig4.txt", expect_cols=3)
        cur.executemany("INSERT INTO fig4_momentum_width(delta_v_mm_s,population_percent,err) VALUES(?,?,?)", fig4)

        # fig5: 5 cols
        fig5 = parse_numeric_table(in_dir/"fig5.txt", expect_cols=5)
        cur.executemany("INSERT INTO fig5_spatial_coherence(Td_us,pop_blue,err_blue,pop_red,err_red) VALUES(?,?,?,?,?)", fig5)

        # fig6A: 3 cols
        fig6a = parse_numeric_table(in_dir/"fig6A.txt", expect_cols=3)
        cur.executemany("INSERT INTO fig6a_visibility_vs_dz(delta_z_um,visibility,err) VALUES(?,?,?)", fig6a)

        # fig6B: 3 cols
        fig6b = parse_numeric_table(in_dir/"fig6B.txt", expect_cols=3)
        cur.executemany("INSERT INTO fig6b_visibility_vs_dv(delta_v_mm_s,visibility,err) VALUES(?,?,?)", fig6b)

        # fig8: 6 cols
        fig8 = parse_numeric_table(in_dir/"fig8.txt", expect_cols=6)
        cur.executemany("INSERT INTO fig8_visibility_vs_Td1(Td1_us,vis_splitstop,err_splitstop,vis_fullloop,err_fullloop,ramsey_ref) VALUES(?,?,?,?,?,?)", fig8)

        conn.commit()
    finally:
        conn.close()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="in_dir", required=True, help="Input directory containing SGI txt sources")
    ap.add_argument("--out", dest="out_db", required=True, help="Output sqlite path")
    ap.add_argument("--no-verify", action="store_true", help="Skip checksum verification against EXPECTED_SHA256.json")
    args = ap.parse_args()

    ingest(Path(args.in_dir), Path(args.out_db), verify_expected=(not args.no_verify))

if __name__ == "__main__":
    main()
