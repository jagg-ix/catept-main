"""SQLite helpers for the Romain Tirole / Imperial College double-slit time diffraction dataset.

The simulator itself is intentionally small and dependency-light (numpy + matplotlib).
This module adds an optional data-loading layer that reads spectra/time-domain traces
from a SQLite database produced by the user's extraction pipeline.

DB conventions
--------------

This repo supports two SQLite layouts seen in the dataset tooling history:

1) **Normalized layout** (older):
   - table `experiments`: id, file_name, figure_ref, slit_separation_fs, pump_condition, created_at
   - table `spectra`: experiment_id, frequency_thz, intensity
   - table `time_domain`: experiment_id, delay_fs, reflectivity

2) **Figure-table layout** (current tidy CSV builder):
   - one table per figure, e.g. `Fig_2f`, with columns like:
     `Slit_separation_fs`, `Frequency_THz`, `Intensity`, `Series`

The helpers below detect which layout is present and load accordingly.
"""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional, Tuple

import numpy as np

C_LIGHT = 299_792_458.0  # m/s


@dataclass(frozen=True)
class Experiment:
    id: int
    file_name: str
    figure_ref: str
    slit_separation_fs: float
    pump_condition: str


def _connect(db_path: str | Path) -> sqlite3.Connection:
    p = Path(db_path)
    if not p.exists():
        raise FileNotFoundError(f"SQLite DB not found: {p}")
    con = sqlite3.connect(str(p))
    con.row_factory = sqlite3.Row
    return con


def _has_table(con: sqlite3.Connection, name: str) -> bool:
    cur = con.cursor()
    cur.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", (name,))
    return cur.fetchone() is not None


def _table_columns(con: sqlite3.Connection, table: str) -> list[str]:
    cur = con.cursor()
    cur.execute(f"PRAGMA table_info('{table}')")
    return [str(r[1]) for r in cur.fetchall()]


def list_experiments(db_path: str | Path) -> list[Experiment]:
    """List experiments in the DB."""
    con = _connect(db_path)
    try:
        cur = con.cursor()
        if not _has_table(con, "experiments"):
            return []

        cur.execute("SELECT id, file_name, figure_ref, slit_separation_fs, pump_condition FROM experiments ORDER BY id")
        out: list[Experiment] = []
        for r in cur.fetchall():
            out.append(
                Experiment(
                    int(r["id"]),
                    str(r["file_name"]),
                    str(r["figure_ref"]),
                    float(r["slit_separation_fs"] or 0.0),
                    str(r["pump_condition"] or ""),
                )
            )
        return out
    finally:
        con.close()


def experiment_id_for_ref(db_path: str | Path, ref: str) -> int:
    """Resolve an experiment id using experiments.figure_ref (primary human label)."""
    con = _connect(db_path)
    try:
        cur = con.cursor()
        if not _has_table(con, "experiments"):
            raise KeyError(
                "DB uses figure-table layout; there is no experiments table. "
                "Use figure-table loaders (e.g., load_spectra_by_slit_separation)."
            )
        cur.execute("SELECT id FROM experiments WHERE figure_ref = ?", (ref,))
        row = cur.fetchone()
        if row is None:
            raise KeyError(f"No experiment with figure_ref={ref!r}")
        return int(row["id"])
    finally:
        con.close()


def load_spectra(db_path: str | Path, *, experiment_id: Optional[int] = None, ref: Optional[str] = None) -> Tuple[np.ndarray, np.ndarray]:
    """Return (frequency_thz, intensity) arrays."""
    if experiment_id is None:
        if ref is None:
            raise ValueError("Provide experiment_id or ref")
        experiment_id = experiment_id_for_ref(db_path, ref)

    con = _connect(db_path)
    try:
        cur = con.cursor()
        cur.execute(
            "SELECT frequency_thz, intensity FROM spectra WHERE experiment_id = ? ORDER BY frequency_thz",
            (int(experiment_id),),
        )
        rows = cur.fetchall()
        if not rows:
            raise ValueError(f"No spectra rows for experiment_id={experiment_id}")
        f_thz = np.array([float(r[0]) for r in rows], dtype=float)
        inten = np.array([float(r[1]) for r in rows], dtype=float)
        return f_thz, inten
    finally:
        con.close()


def load_spectra_by_slit_separation(
    db_path: str | Path,
    *,
    ref: str,
) -> dict[float, tuple[np.ndarray, np.ndarray]]:
    """Load spectra grouped by slit separation for a given figure_ref.

    Useful for Fig_2f which is stored as a single experiment but has many rows
    for different separations.

    Returns
    -------
    mapping: dict
        Keys are slit separations in fs (float); values are (frequency_thz, intensity) arrays.
    """
    con = _connect(db_path)
    try:
        cur = con.cursor()

        # Layout A: normalized tables.
        if _has_table(con, "experiments") and _has_table(con, "spectra"):
            exp_id = experiment_id_for_ref(db_path, ref)
            cur.execute(
                "SELECT slit_separation_fs, frequency_thz, intensity FROM spectra WHERE experiment_id=? ORDER BY slit_separation_fs, frequency_thz",
                (int(exp_id),),
            )
            rows = cur.fetchall()
            if not rows:
                raise ValueError(f"No spectra rows for figure_ref={ref!r}")
            out: dict[float, list[tuple[float, float]]] = {}
            for r in rows:
                s = float(r[0])
                out.setdefault(s, []).append((float(r[1]), float(r[2])))

        # Layout B: per-figure table.
        else:
            if not _has_table(con, ref):
                raise KeyError(f"No table named {ref!r} in DB")

            cols = _table_columns(con, ref)
            # Column name detection (case-sensitive to match PRAGMA output)
            slit_col = "Slit_separation_fs" if "Slit_separation_fs" in cols else (
                "slit_separation_fs" if "slit_separation_fs" in cols else None
            )
            freq_col = "Frequency_THz" if "Frequency_THz" in cols else (
                "frequency_thz" if "frequency_thz" in cols else (
                    "Frequency_thz" if "Frequency_thz" in cols else None
                )
            )
            inten_col = "Intensity" if "Intensity" in cols else (
                "Counts_MHz" if "Counts_MHz" in cols else (
                    "intensity" if "intensity" in cols else None
                )
            )
            if slit_col is None or freq_col is None or inten_col is None:
                raise KeyError(
                    f"Table {ref!r} missing required columns. Found: {sorted(cols)}"
                )

            where = ""
            params: tuple = ()
            if "Series" in cols:
                # Prefer 'model' if present, else 'smooth', else 'raw'.
                cur.execute(f"SELECT DISTINCT Series FROM {ref}")
                series_vals = {str(r[0]) for r in cur.fetchall() if r[0] is not None}
                chosen = None
                for cand in ("model", "smooth", "raw"):
                    if cand in series_vals:
                        chosen = cand
                        break
                if chosen is not None:
                    where = " WHERE Series = ?"
                    params = (chosen,)

            cur.execute(
                f"SELECT {slit_col}, {freq_col}, {inten_col} FROM {ref}{where} ORDER BY {slit_col}, {freq_col}",
                params,
            )
            rows = cur.fetchall()
            if not rows:
                raise ValueError(f"No spectra rows in table {ref!r}")
            out: dict[float, list[tuple[float, float]]] = {}
            for r in rows:
                s = float(r[0])
                out.setdefault(s, []).append((float(r[1]), float(r[2])))

        grouped: dict[float, tuple[np.ndarray, np.ndarray]] = {}
        for s, pts in out.items():
            f = np.array([p[0] for p in pts], dtype=float)
            y = np.array([p[1] for p in pts], dtype=float)
            grouped[float(s)] = (f, y)
        return grouped
    finally:
        con.close()


def load_time_domain(db_path: str | Path, *, experiment_id: Optional[int] = None, ref: Optional[str] = None) -> Tuple[np.ndarray, np.ndarray]:
    """Return (delay_fs, reflectivity) arrays."""
    if experiment_id is None:
        if ref is None:
            raise ValueError("Provide experiment_id or ref")
        experiment_id = experiment_id_for_ref(db_path, ref)

    con = _connect(db_path)
    try:
        cur = con.cursor()
        cur.execute(
            "SELECT delay_fs, reflectivity FROM time_domain WHERE experiment_id = ? ORDER BY delay_fs",
            (int(experiment_id),),
        )
        rows = cur.fetchall()
        if not rows:
            raise ValueError(f"No time_domain rows for experiment_id={experiment_id}")
        delay_fs = np.array([float(r[0]) for r in rows], dtype=float)
        refl = np.array([float(r[1]) for r in rows], dtype=float)
        return delay_fs, refl
    finally:
        con.close()


def spectra_to_wavelength_m(frequency_thz: np.ndarray) -> np.ndarray:
    """Convert frequency (THz) to vacuum wavelength (m)."""
    f_hz = np.asarray(frequency_thz, dtype=float) * 1e12
    # avoid division by zero
    return C_LIGHT / np.maximum(f_hz, 1e-30)


def export_spectra_to_csv(
    db_path: str | Path,
    out_csv: str | Path,
    *,
    experiment_id: Optional[int] = None,
    ref: Optional[str] = None,
) -> None:
    """Export spectra as CSV compatible with scripts/fit_to_csv.py.

    Output columns:
      - x_m: wavelength in meters
      - counts: intensity (arbitrary units)
    """
    f_thz, inten = load_spectra(db_path, experiment_id=experiment_id, ref=ref)
    x_m = spectra_to_wavelength_m(f_thz)

    p = Path(out_csv)
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open("w", encoding="utf-8") as f:
        f.write("x_m,counts\n")
        for x, y in zip(x_m, inten):
            f.write(f"{x:.12e},{y:.12e}\n")


def export_time_domain_to_csv(
    db_path: str | Path,
    out_csv: str | Path,
    *,
    experiment_id: Optional[int] = None,
    ref: Optional[str] = None,
) -> None:
    """Export time-domain trace as CSV.

    Output columns:
      - delay_fs
      - reflectivity
    """
    delay_fs, refl = load_time_domain(db_path, experiment_id=experiment_id, ref=ref)
    p = Path(out_csv)
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open("w", encoding="utf-8") as f:
        f.write("delay_fs,reflectivity\n")
        for x, y in zip(delay_fs, refl):
            f.write(f"{x:.12e},{y:.12e}\n")
