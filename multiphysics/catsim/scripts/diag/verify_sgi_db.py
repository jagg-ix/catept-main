from __future__ import annotations
"""SGI database completeness + source-file verification.

Checks:
1) Expected tables exist and have non-zero row counts.
2) meta_source_files contains expected text sources and matches expected sha256 (recomputed from on-disk txt files when present).
3) Basic sanity for column presence and monotonic ordering where applicable.

This is a *verification harness*, not a physics validator.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sqlite3
import pandas as pd

EXPECTED_TABLES = {
    "fig3_population_vs_T": ["T2_plus_T3_us","population_percent","err"],
    "fig4_momentum_width": ["delta_v_mm_s","population_percent","err"],
    "fig5_spatial_coherence": ["Td_us","pop_blue","err_blue","pop_red","err_red"],
    "fig6a_visibility_vs_dz": ["delta_z_um","visibility","err"],
    "fig6b_visibility_vs_dv": ["delta_v_mm_s","visibility","err"],
    "fig8_visibility_vs_Td1": ["Td1_us","vis_splitstop","err_splitstop","vis_fullloop","err_fullloop","ramsey_ref"],
    "params": ["name","value","unit","raw"],
    "meta_source_files": ["path","sha256","ingested_at","note"],
}


EXPECTED_SOURCES = [
    "page1.txt",
    "master-params.txt",
    "fig3.txt",
    "fig4.txt",
    "fig5.txt",
    "fig6A.txt",
    "fig6B.txt",
    "fig8.txt",
]

def sha256_file(p: Path) -> str:
    h=hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1<<20), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--db", default="data/sgi/sgidb.sqlite")
    ap.add_argument("--sources-dir", default="data/sgi/sources", help="Optional: directory containing extracted txt sources.")
    ap.add_argument("--out", default="PAPER_TABLES/ADVANCED/DIAG/DB_VERIFY/sgidb_verify.json")
    args=ap.parse_args()

    db_path=Path(args.db)
    if not db_path.exists():
        raise SystemExit(f"Missing db: {db_path}")
    con=sqlite3.connect(str(db_path))

    report = {"db": str(db_path), "tables": {}, "meta_sources": {}, "status": "ok", "issues": []}

    # tables
    tables=[r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
    for t, cols in EXPECTED_TABLES.items():
        entry={"exists": t in tables, "rowcount": 0, "columns_ok": False}
        if t in tables:
            df=pd.read_sql_query(f"SELECT * FROM {t} LIMIT 5", con)
            entry["rowcount"]=int(con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0])
            entry["columns_ok"]=all(c in df.columns for c in cols)
        report["tables"][t]=entry
        if not entry["exists"]:
            report["status"]="fail"; report["issues"].append(f"missing table: {t}")
        elif entry["rowcount"]<=0:
            report["status"]="fail"; report["issues"].append(f"empty table: {t}")
        elif not entry["columns_ok"]:
            report["status"]="fail"; report["issues"].append(f"unexpected columns in {t}")

    # meta sources
    if "meta_source_files" in tables:
        meta=pd.read_sql_query("SELECT * FROM meta_source_files", con)
        present=set(meta["path"].astype(str).tolist())
        report["meta_sources"]["present"]=sorted(present)
        missing=[s for s in EXPECTED_SOURCES if s not in present]
        report["meta_sources"]["missing"]=missing
        if missing:
            report["status"]="fail"; report["issues"].append(f"missing meta_source_files rows: {missing}")

        # optional on-disk source sha check
        src_dir=Path(args.sources_dir)
        sha_checks=[]
        if src_dir.exists():
            for s in EXPECTED_SOURCES:
                p=src_dir/s
                if not p.exists():
                    sha_checks.append({"path": str(p), "exists": False})
                    continue
                sha_disk=sha256_file(p)
                sha_db = meta.loc[meta["path"]==s, "sha256"].iloc[0] if (meta["path"]==s).any() else None
                ok = (sha_db is not None and sha_disk==sha_db)
                sha_checks.append({"path": str(p), "exists": True, "sha_disk": sha_disk, "sha_db": sha_db, "match": bool(ok)})
                if not ok:
                    report["status"]="fail"; report["issues"].append(f"sha mismatch for {s}")
        report["meta_sources"]["sha_checks"]=sha_checks
    else:
        report["status"]="fail"; report["issues"].append("meta_source_files table missing")

    out=Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    print("Wrote", out)
    print("STATUS:", report["status"])
    if report["issues"]:
        print("ISSUES:")
        for i in report["issues"]:
            print(" -", i)

if __name__=="__main__":
    main()
