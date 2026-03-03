"""Verify SGI TXT checksums against data/sgi_txt/EXPECTED_SHA256.json."""

from __future__ import annotations
import argparse, json, hashlib
from pathlib import Path

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1<<20), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default="data/sgi_txt", help="Directory containing SGI txt sources and EXPECTED_SHA256.json")
    args = ap.parse_args()
    d = Path(args.dir)
    exp_path = d/"EXPECTED_SHA256.json"
    if not exp_path.exists():
        raise SystemExit(f"Missing {exp_path}")
    exp = json.loads(exp_path.read_text(encoding="utf-8"))
    files = exp.get("files", {})
    bad = 0
    for fname, sha in files.items():
        p = d/fname
        if not p.exists():
            print(f"MISSING {fname}")
            bad += 1
            continue
        got = sha256_file(p)
        if got != sha:
            print(f"BAD {fname} expected={sha} got={got}")
            bad += 1
        else:
            print(f"OK  {fname} {sha}")
    if bad:
        raise SystemExit(f"{bad} checksum failures")
    print("All SGI checksums OK.")

if __name__ == "__main__":
    main()
