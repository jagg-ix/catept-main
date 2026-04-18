#!/usr/bin/env python3
"""End-to-end fit: SQLite spectra -> CSV -> fit (standard vs entropic).

This is a convenience wrapper so you can run:

  python scripts/fit_from_sqlite_spectra.py \
    --db data/tirole_double_slit.sqlite3 --experiment 1 \
    --out out_fit --mode both \
    --separation_s 40e-15 --slit_rise_s 7e-15 --w0_Hz 3.75e14 \
    --rate-grid 0,1e15,400

Notes:
- The temporal model uses a frequency axis. We convert DB spectra to wavelength,
  then internally convert to frequency around w0_Hz.
- This keeps the dependency footprint minimal (numpy only).
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np

from cat_ept_doubleslit.db import load_spectra
from cat_ept_doubleslit.fit import fit_temporal_spectrum_rate_grid

C = 299_792_458.0


def wavelength_to_freq_Hz(lam_m: np.ndarray) -> np.ndarray:
    return C / lam_m


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--experiment", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--mode", choices=["standard", "entropic", "both"], default="both")
    ap.add_argument("--separation_s", type=float, required=True)
    ap.add_argument("--slit_rise_s", type=float, required=True)
    ap.add_argument("--w0_Hz", type=float, required=True, help="Carrier (center) frequency")
    ap.add_argument("--rate-grid", required=True, help="min,max,n e.g. 0,1e15,400")
    args = ap.parse_args()

    exp = int(args.experiment) if args.experiment.isdigit() else args.experiment
    lam_m, inten = load_spectra(Path(args.db), exp)

    f_Hz = wavelength_to_freq_Hz(lam_m)
    # detuning relative to carrier (keep sign)
    det_Hz = f_Hz - args.w0_Hz

    # Sort by detuning ascending (fit expects monotonic x)
    order = np.argsort(det_Hz)
    det_Hz = det_Hz[order]
    y = inten[order]

    gmin, gmax, gn = args.rate_grid.split(",")
    rate_grid = np.linspace(float(gmin), float(gmax), int(gn))

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    results = {}

    if args.mode in ("standard", "both"):
        res = fit_temporal_spectrum_rate_grid(
            det_Hz,
            y,
            separation_s=args.separation_s,
            slit_rise_s=args.slit_rise_s,
            rate_grid=rate_grid,
            mode="standard",
        )
        results["standard"] = res

    if args.mode in ("entropic", "both"):
        res = fit_temporal_spectrum_rate_grid(
            det_Hz,
            y,
            separation_s=args.separation_s,
            slit_rise_s=args.slit_rise_s,
            rate_grid=rate_grid,
            mode="entropic",
        )
        results["entropic"] = res

    # Save
    import json

    with open(outdir / "fit_results.json", "w") as f:
        json.dump(results, f, indent=2)

    print(f"Wrote {outdir / 'fit_results.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
