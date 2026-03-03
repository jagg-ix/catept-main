"""I/O helpers (CSV)."""

from __future__ import annotations

from pathlib import Path
from typing import Tuple

import numpy as np


def save_csv(path: Path, x_m: np.ndarray, intensity: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data = np.column_stack([x_m, intensity])
    header = "x_m,intensity"
    np.savetxt(path, data, delimiter=",", header=header, comments="")




def save_csv_xy(path: Path, x: np.ndarray, y: np.ndarray, x_name: str = "x_m", y_name: str = "intensity") -> None:
    """Save two-column CSV with a header.

    Used for both spatial (x_m) and temporal (f_Hz) simulations.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    data = np.column_stack([x, y])
    header = f"{x_name},{y_name}"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
def load_xy_csv(path: Path) -> Tuple[np.ndarray, np.ndarray]:
    """Load CSV with two numeric columns (axis, counts/intensity).

    Accepts either:
      - spatial:  x_m, intensity|counts
      - temporal: f_Hz, intensity|counts
    """
    import csv

    xs = []
    ys = []
    with path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise ValueError("CSV has no header")
        # accept either 'counts' or 'intensity'
        y_key = "counts" if "counts" in reader.fieldnames else ("intensity" if "intensity" in reader.fieldnames else None)
        if y_key is None:
            raise ValueError("CSV must contain 'counts' or 'intensity' column")
        x_key = None
        for cand in ("x_m", "f_Hz", "f_hz"):
            if cand in reader.fieldnames:
                x_key = cand
                break
        if x_key is None:
            raise ValueError("CSV must contain 'x_m' (spatial) or 'f_Hz' (temporal) column")

        for row in reader:
            xs.append(float(row[x_key]))
            ys.append(float(row[y_key]))

    x = np.asarray(xs, dtype=float)
    y = np.asarray(ys, dtype=float)
    return x, y
