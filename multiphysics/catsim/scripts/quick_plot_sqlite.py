#!/usr/bin/env python3
"""Quick visualization for the SQLite dataset (spectra + time-domain).

Example:
  python scripts/quick_plot_sqlite.py --db data/tirole_double_slit.sqlite3 --experiment 1 --out out_sqlite
"""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt

from cat_ept_doubleslit.db import load_spectra, load_time_domain


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--experiment", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    exp = int(args.experiment) if args.experiment.isdigit() else args.experiment
    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    lam_m, inten = load_spectra(Path(args.db), exp)
    delay_fs, refl = load_time_domain(Path(args.db), exp)

    plt.figure()
    plt.plot(lam_m * 1e9, inten)
    plt.xlabel("Wavelength (nm)")
    plt.ylabel("Intensity (a.u.)")
    plt.title("Spectra")
    plt.tight_layout()
    plt.savefig(outdir / "spectra.png", dpi=200)
    plt.close()

    plt.figure()
    plt.plot(delay_fs, refl)
    plt.xlabel("Delay (fs)")
    plt.ylabel("Reflectivity (a.u.)")
    plt.title("Time-domain")
    plt.tight_layout()
    plt.savefig(outdir / "time_domain.png", dpi=200)
    plt.close()

    print(f"Wrote plots under {outdir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
