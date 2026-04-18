"""CLI for fitting decoherence rate in spatial or temporal double-slit data.

The fitter performs a grid search over the decoherence-rate parameter
(standard: gamma [1/s], entropic: lambda_ent [1/s]) and, for each candidate,
for each candidate, optionally solves linear scale+offset (y ≈ scale*I + offset). For temporal spectra, set --affine only if you have independent calibration; otherwise keep data normalized and let the fitter fix scale=1, offset=0.

It is intentionally dependency-light (NumPy only).
"""

from __future__ import annotations

import argparse
from pathlib import Path
import json

import numpy as np

from cat_ept_doubleslit.io import load_xy_csv
from cat_ept_doubleslit.fit import fit_rate_grid, fit_rate_grid_temporal


def main() -> None:
    ap = argparse.ArgumentParser(description="Fit double-slit model to CSV data (grid search)")
    ap.add_argument("--experiment", choices=["spatial", "temporal"], default="spatial")
    ap.add_argument("--csv", required=True, help="CSV with two columns: axis,intensity (axis = x_m or f_Hz)")
    ap.add_argument("--mode", choices=["standard", "entropic"], required=True)
    ap.add_argument("--out", required=True, help="Output JSON with best-fit parameters")

    # Spatial parameters
    ap.add_argument("--wavelength_m", type=float)
    ap.add_argument("--slit_sep_m", type=float)
    ap.add_argument("--slit_width_m", type=float)
    ap.add_argument("--screen_dist_m", type=float)

    # Temporal parameters
    ap.add_argument("--separation_s", type=float)
    ap.add_argument("--slit_rise_s", type=float)

    ap.add_argument("--visibility0", type=float, default=1.0)
    ap.add_argument("--flight_time_s", type=float, default=None, help="Override flight time (spatial only)")

    ap.add_argument("--rate_min", type=float, default=0.0)
    ap.add_argument("--rate_max", type=float, default=5e6)
    ap.add_argument("--rate_steps", type=int, default=200)
    ap.add_argument("--affine", action="store_true", help="(Temporal) Fit scale+offset too. Warning: scale and visibility are degenerate unless intensity is pre-normalized.")

    args = ap.parse_args()

    axis, y = load_xy_csv(Path(args.csv))

    # Grid of candidate decoherence rates (1/s)
    if args.rate_steps < 2:
        rate_grid = np.array([args.rate_min], dtype=float)
    else:
        rate_grid = np.linspace(args.rate_min, args.rate_max, args.rate_steps)

    if args.experiment == "spatial":
        missing = [k for k in ("wavelength_m", "slit_sep_m", "slit_width_m", "screen_dist_m") if getattr(args, k) is None]
        if missing:
            raise SystemExit(f"Missing spatial parameters: {', '.join(missing)}")

        best = fit_rate_grid(
            x_m=axis,
            y=y,
            mode=args.mode,
            wavelength_m=args.wavelength_m,
            slit_sep_m=args.slit_sep_m,
            slit_width_m=args.slit_width_m,
            screen_dist_m=args.screen_dist_m,
            visibility0=args.visibility0,
            flight_time_s=args.flight_time_s,
            rate_grid=rate_grid,
            fit_affine=args.affine,
        )
    else:
        if args.separation_s is None or args.slit_rise_s is None:
            raise SystemExit("Missing temporal parameters: --separation_s and --slit_rise_s are required")

        best = fit_rate_grid_temporal(
            f_hz=axis,
            y=y,
            mode=args.mode,
            separation_s=args.separation_s,
            slit_rise_s=args.slit_rise_s,
            visibility0=args.visibility0,
            rate_grid=rate_grid,
            fit_affine=args.affine,
        )

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out = {
        "experiment": args.experiment,
        "mode": args.mode,
        "rate_name": best.rate_name,
        "rate_s_inv": float(best.rate_value),
        "visibility0": float(best.visibility0),
        "visibility_pred": (None if best.predicted_visibility is None else float(best.predicted_visibility)),
        "scale": float(best.scale),
        "offset": float(best.offset),
        "sse": float(best.sse),
    }
    out_path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("Best fit written to", out_path)


if __name__ == "__main__":
    main()
