"""Deterministic run identifier for regression tracking.

We intentionally avoid timestamps so runs are diffable.

run_id = sha256( bundle_version + script_id + sha256(db_bytes) + sha256(concatenated_config_bytes) )

Only include inputs that materially affect numerical results.
"""

from __future__ import annotations

import hashlib
from pathlib import Path
from typing import Iterable


def _sha256_bytes(data: bytes) -> str:
    h = hashlib.sha256()
    h.update(data)
    return h.hexdigest()


def sha256_file(path: str | Path) -> str:
    p = Path(path)
    h = hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def compute_run_id(
    *,
    bundle_version: str,
    script_id: str,
    db_path: str | Path,
    config_paths: Iterable[str | Path] = (),
) -> str:
    db_hash = sha256_file(db_path)

    cfg_hasher = hashlib.sha256()
    for cp in [Path(x) for x in config_paths]:
        if not cp.exists():
            continue
        cfg_hasher.update(cp.name.encode('utf-8'))
        with cp.open('rb') as f:
            for chunk in iter(lambda: f.read(1024 * 1024), b''):
                cfg_hasher.update(chunk)
    cfg_hash = cfg_hasher.hexdigest()

    payload = f"{bundle_version}|{script_id}|{db_hash}|{cfg_hash}".encode('utf-8')
    full = _sha256_bytes(payload)
    # short, still collision-resistant for our use:
    return full[:12]
