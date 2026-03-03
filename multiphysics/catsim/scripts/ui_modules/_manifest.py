from __future__ import annotations
import json, hashlib, platform, sys
from pathlib import Path
from datetime import datetime

def sha256_file(path: Path, chunk: int = 1024*1024) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            b = f.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()

def write_manifest(out_dir: Path, payload: dict) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    payload = dict(payload)
    payload.setdefault("timestamp_utc", datetime.utcnow().isoformat()+"Z")
    payload.setdefault("python", sys.version)
    payload.setdefault("platform", platform.platform())
    p = out_dir / "run_manifest.json"
    p.write_text(json.dumps(payload, indent=2, sort_keys=True))
    return p
