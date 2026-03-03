"""Validate SGI sqlite database completeness against paper-extracted TXT sources."""
from __future__ import annotations
import argparse, json, sqlite3, hashlib, re
from pathlib import Path

EXPECTED_TABLES = [
    "params",
    "fig3_population_vs_T",
    "fig4_momentum_width",
    "fig5_spatial_coherence",
    "fig6a_visibility_vs_dz",
    "fig6b_visibility_vs_dv",
    "fig8_visibility_vs_Td1",
    "meta_source_files",
]

_numline = re.compile(r"^\s*[-+0-9\.eE]+(\s+[-+0-9\.eE]+)*\s*$")

def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024*1024), b""):
            h.update(chunk)
    return h.hexdigest()

def count_numeric_rows(txt: Path) -> int:
    n=0
    for line in txt.read_text(encoding="utf-8", errors="ignore").splitlines():
        s=line.strip()
        if not s or s.startswith("#"):
            continue
        if _numline.match(s):
            n += 1
    return n

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=".")
    ap.add_argument("--expected", default="data/sgi_txt/EXPECTED_SHA256.json")
    ap.add_argument("--txt-dir", default="data/sgi_txt")
    ap.add_argument("--db", default="data/sgi/sgidb.sqlite")
    ap.add_argument("--out", default="PAPER_LOGS/SGI/sgidb_validate.json")
    args = ap.parse_args()

    repo = Path(args.repo)
    expected_path = repo/args.expected
    txt_dir = repo/args.txt_dir
    db_path = repo/args.db
    out_path = repo/args.out
    out_path.parent.mkdir(parents=True, exist_ok=True)

    report = {"status":"FAIL", "checks": {}, "tables": {}, "sources": {}, "row_counts": {}}

    if not expected_path.exists():
        report["checks"]["expected_file"] = f"missing: {expected_path}"
        out_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
        raise SystemExit(1)

    expected = json.loads(expected_path.read_text(encoding="utf-8"))
    hash_ok = True
    for fname, exp in expected.items():
        p = txt_dir/fname
        if not p.exists():
            report["sources"][fname] = {"status":"missing"}
            hash_ok = False
            continue
        got = sha256_file(p)
        ok = (got == exp)
        report["sources"][fname] = {"expected": exp, "got": got, "ok": ok}
        hash_ok = hash_ok and ok
    report["checks"]["txt_hashes_ok"] = bool(hash_ok)

    report["checks"]["db_exists"] = db_path.exists()
    if not db_path.exists():
        out_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
        raise SystemExit(1)

    conn = sqlite3.connect(str(db_path))
    try:
        cur = conn.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = {r[0] for r in cur.fetchall()}

        tbl_ok = True
        for t in EXPECTED_TABLES:
            ok = t in tables
            report["tables"][t] = {"present": ok}
            tbl_ok = tbl_ok and ok
        report["checks"]["tables_present"] = bool(tbl_ok)

        meta_ok = True
        if "meta_source_files" in tables:
            cur.execute("SELECT filename, sha256 FROM meta_source_files")
            meta = {fn:sh for fn,sh in cur.fetchall()}
            for fname, exp in expected.items():
                ok = (fname in meta and meta[fname] == exp)
                report["tables"]["meta_source_files"][fname] = {"present": fname in meta, "sha_ok": (meta.get(fname)==exp)}
                meta_ok = meta_ok and ok
        else:
            meta_ok = False
        report["checks"]["meta_sources_ok"] = bool(meta_ok)

        mapping = {
            "fig3.txt": "fig3_population_vs_T",
            "fig4.txt": "fig4_momentum_width",
            "fig5.txt": "fig5_spatial_coherence",
            "fig6A.txt": "fig6a_visibility_vs_dz",
            "fig6B.txt": "fig6b_visibility_vs_dv",
            "fig8.txt": "fig8_visibility_vs_Td1",
        }
        rc_ok = True
        for fname, table in mapping.items():
            txtp = txt_dir/fname
            if not txtp.exists() or table not in tables:
                continue
            n_txt = count_numeric_rows(txtp)
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            n_db = int(cur.fetchone()[0])
            ok = (n_txt == n_db)
            report["row_counts"][table] = {"txt_file": fname, "txt_numeric_rows": n_txt, "db_rows": n_db, "ok": ok}
            rc_ok = rc_ok and ok
        report["checks"]["row_counts_ok"] = bool(rc_ok)

        ok_all = hash_ok and report["checks"]["db_exists"] and tbl_ok and meta_ok and rc_ok
        report["status"] = "PASS" if ok_all else "FAIL"
    finally:
        conn.close()

    out_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    raise SystemExit(0 if report["status"]=="PASS" else 1)

if __name__ == "__main__":
    main()
