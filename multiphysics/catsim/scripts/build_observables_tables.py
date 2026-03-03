#!/usr/bin/env python3
"""Phase 2: Build observable tables from the pipeline SQLite.

This script reads the SQLite database produced by the XLSX->tidy->SQLite
pipeline (Phase 1) and extracts paper-relevant observables for:

* Spectral sweeps (Fig_2f plus any other spectra panels present)
* Time-domain sweeps (Fig_2g plus any other time-domain panels present)

Outputs are written (tool-generated) into:

    PAPER_TABLES/OBSERVABLES/
        obs_spectral.csv
        obs_time_domain.csv
        results.sqlite3
        README.md

The extraction routines live in `src/cat_ept_doubleslit/observables.py`.
"""

from __future__ import annotations

import argparse
import os
import sqlite3
from pathlib import Path

import numpy as np
import pandas as pd

from cat_ept_doubleslit.observables import (
    SpectralObservables,
    TimeDomainObservables,
    build_spectral_observables,
    build_time_domain_observables,
)


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _write_sqlite(df: pd.DataFrame, con: sqlite3.Connection, table: str) -> None:
    df.to_sql(table, con, if_exists="replace", index=False)


def build_spectral_table(con: sqlite3.Connection, carrier_THz: float, band_THz: float) -> pd.DataFrame:
    q = """
    SELECT e.figure_ref, s.slit_separation_fs, s.frequency_thz AS frequency_THz,
           s.intensity, s.series
    FROM spectra s
    JOIN experiments e ON e.id = s.experiment_id
    WHERE s.slit_separation_fs IS NOT NULL
    """
    df = pd.read_sql_query(q, con)
    if df.empty:
        return pd.DataFrame()

    rows = []
    for (fig, S, series), g in df.groupby(["figure_ref", "slit_separation_fs", "series"], dropna=True):
        try:
            obs: SpectralObservables = build_spectral_observables(
                slit_separation_fs=float(S),
                frequency_THz=g["frequency_THz"].to_numpy(float),
                intensity=g["intensity"].to_numpy(float),
                carrier_THz=carrier_THz,
                band_THz=band_THz,
            )
            rows.append(
                {
                    "figure_ref": fig,
                    "series": series,
                    **obs.__dict__,
                }
            )
        except Exception as e:
            rows.append(
                {
                    "figure_ref": fig,
                    "series": series,
                    "slit_separation_fs": float(S),
                    "fringe_spacing_THz": np.nan,
                    "visibility_paper": np.nan,
                    "visibility_robust": np.nan,
                    "asymmetry_fraction": np.nan,
                    "high_detuning_power_fraction": np.nan,
                    "band_THz": float(band_THz),
                    "carrier_THz": float(carrier_THz),
                    "error": repr(e),
                }
            )

    if not rows:
        return pd.DataFrame(
            columns=[
                "figure_ref",
                "series",
                "slit_separation_fs",
                "fringe_spacing_THz",
                "visibility_paper",
                "visibility_robust",
                "asymmetry_fraction",
                "high_detuning_power_fraction",
                "band_THz",
                "carrier_THz",
                "error",
            ]
        )

    out = pd.DataFrame(rows)
    if "error" not in out.columns:
        out["error"] = ""
    return out.sort_values(["figure_ref", "series", "slit_separation_fs"]).reset_index(drop=True)


def build_time_domain_table(con: sqlite3.Connection) -> pd.DataFrame:
    q = """
    SELECT e.figure_ref, t.slit_separation_fs, t.delay_fs, t.reflectivity, t.series
    FROM time_domain t
    JOIN experiments e ON e.id = t.experiment_id
    WHERE t.slit_separation_fs IS NOT NULL
    """
    df = pd.read_sql_query(q, con)
    if df.empty:
        return pd.DataFrame()

    # Some tidy sources do not provide a series label; keep them instead of
    # dropping via groupby(dropna=True).
    if "series" in df.columns:
        df["series"] = df["series"].fillna("raw")

    rows = []
    for (fig, S, series), g in df.groupby(["figure_ref", "slit_separation_fs", "series"], dropna=False):
        try:
            obs: TimeDomainObservables = build_time_domain_observables(
                slit_separation_fs=float(S),
                delay_fs=g["delay_fs"].to_numpy(float),
                reflectivity=g["reflectivity"].to_numpy(float),
            )
            rows.append(
                {
                    "figure_ref": fig,
                    "series": series,
                    **obs.__dict__,
                }
            )
        except Exception as e:
            rows.append(
                {
                    "figure_ref": fig,
                    "series": series,
                    "slit_separation_fs": float(S),
                    "rise_10_90_fs": np.nan,
                    "decay_tau_fs": np.nan,
                    "peak_delay_fs": np.nan,
                    "error": repr(e),
                }
            )

    if not rows:
        return pd.DataFrame(
            columns=[
                "figure_ref",
                "series",
                "slit_separation_fs",
                "rise_10_90_fs",
                "decay_tau_fs",
                "peak_delay_fs",
                "error",
            ]
        )

    out = pd.DataFrame(rows)
    if "error" not in out.columns:
        out["error"] = ""
    return out.sort_values(["figure_ref", "series", "slit_separation_fs"]).reset_index(drop=True)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--db",
        default="data_pipeline/user_scripts/double_slit.sqlite3",
        help="Path to the Phase-1 pipeline SQLite.",
    )
    ap.add_argument(
        "--out",
        default="PAPER_TABLES",
        help="Output root folder (default: PAPER_TABLES).",
    )
    ap.add_argument(
        "--carrier_THz",
        type=float,
        default=230.2,
        help="Carrier frequency used to compute detuning.",
    )
    ap.add_argument(
        "--band_THz",
        type=float,
        default=10.0,
        help="Detuning band |Δf|<=band_THz used for observables.",
    )
    args = ap.parse_args()

    db_path = Path(args.db)
    if not db_path.exists():
        raise FileNotFoundError(f"SQLite not found: {db_path}")

    out_root = Path(args.out) / "OBSERVABLES"
    _ensure_dir(out_root)

    con = sqlite3.connect(str(db_path))
    try:
        obs_spec = build_spectral_table(con, carrier_THz=args.carrier_THz, band_THz=args.band_THz)
        obs_td = build_time_domain_table(con)
    finally:
        con.close()

    # Write CSV artifacts.
    spec_csv = out_root / "obs_spectral.csv"
    td_csv = out_root / "obs_time_domain.csv"
    obs_spec.to_csv(spec_csv, index=False)
    obs_td.to_csv(td_csv, index=False)

    # Write SQLite artifacts.
    rdb = sqlite3.connect(str(out_root / "results.sqlite3"))
    try:
        if not obs_spec.empty:
            _write_sqlite(obs_spec, rdb, "obs_spectral")
        if not obs_td.empty:
            _write_sqlite(obs_td, rdb, "obs_time_domain")
    finally:
        rdb.close()

    # Write a short readme with summary counts.
    with open(out_root / "README.md", "w", encoding="utf-8") as f:
        f.write("# Observable tables (Phase 2)\n\n")
        f.write(f"Source DB: `{db_path}`\n\n")
        f.write("## Spectral\n")
        if obs_spec.empty:
            f.write("No spectral rows found.\n")
        else:
            f.write(f"Rows: {len(obs_spec)}\n\n")
            f.write(obs_spec.groupby(["figure_ref", "series"]).size().to_string())
            f.write("\n\n")
        f.write("## Time domain\n")
        if obs_td.empty:
            f.write("No time-domain rows found.\n")
        else:
            f.write(f"Rows: {len(obs_td)}\n\n")
            f.write(obs_td.groupby(["figure_ref", "series"]).size().to_string())
            f.write("\n")

    print(f"Wrote: {spec_csv}")
    print(f"Wrote: {td_csv}")
    print(f"Wrote: {out_root / 'results.sqlite3'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
