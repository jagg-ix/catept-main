from __future__ import annotations
from pathlib import Path
import pandas as pd

def find_latest(path: Path, pattern: str):
    items = sorted(path.glob(pattern), key=lambda p: p.stat().st_mtime, reverse=True)
    return items[0] if items else None

def load_csv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path)

def safe_path(p: Path) -> str:
    try:
        return str(p.resolve())
    except Exception:
        return str(p)
