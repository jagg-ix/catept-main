#!/usr/bin/env python3
# NOTE: You can also install and run the entrypoint `cat-ept-fit` once installed.

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

from cat_ept_doubleslit.io import load_xy_csv
from cat_ept_doubleslit.fit import fit_rate_grid
from cat_ept_doubleslit.models import double_slit_intensity


def main() -> None:
    ap = argparse.ArgumentParser(description="Fit double-slit model to CSV data (grid search over decoherence rate)")
    ap.add_argument("--csv", required=True, help="CSV with columns x_m and counts/intensity")
    ap.add_argument("--mode", choices=["standard", "entropic"], required=True)
    ap.add_argument("--outdir", required=True)

    ap.add_argument("--wavelength_m", type=float, required=True)
    ap.add_argument("--slit_sep_m", type=float, required=True)
    ap.add_argument("--slit_width_m", type=float, required=True)
    ap.add_argument("--screen_dist_m", type=float, required=True)

    ap.add_argument("--visibility0", type=float, default=1.0)
    ap.add_argument("--flight_time_s", type=float, default=None)

    ap.add_argument("--rate_min", type=float, default=0.0)
    ap.add_argument("--rate_max", type=float, default=1e6)
    ap.add_argument("--rate_n", type=int, default=400)

    args = ap.parse_args()

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    x, y = load_xy_csv(Path(args.csv))

    rate_grid = np.linspace(args.rate_min, args.rate_max, args.rate_n)

    best = fit_rate_grid(
        x_m=x,
        y=y,
        wavelength_m=args.wavelength_m,
        slit_sep_m=args.slit_sep_m,
        slit_width_m=args.slit_width_m,
        screen_dist_m=args.screen_dist_m,
        mode=args.mode,
        visibility0=args.visibility0,
        flight_time_s=args.flight_time_s,
        rate_grid=rate_grid,
    )

    if args.mode == "standard":
        I_model, V = double_slit_intensity(
            x_m=x,
            wavelength_m=args.wavelength_m,
            slit_sep_m=args.slit_sep_m,
            slit_width_m=args.slit_width_m,
            screen_dist_m=args.screen_dist_m,
            visibility0=args.visibility0,
            mode=args.mode,
            flight_time_s=args.flight_time_s,
            gamma_s_inv=best.rate_value,
            lambda_ent_s_inv=0.0,
        )
    else:
        I_model, V = double_slit_intensity(
            x_m=x,
            wavelength_m=args.wavelength_m,
            slit_sep_m=args.slit_sep_m,
            slit_width_m=args.slit_width_m,
            screen_dist_m=args.screen_dist_m,
            visibility0=args.visibility0,
            mode=args.mode,
            flight_time_s=args.flight_time_s,
            gamma_s_inv=0.0,
            lambda_ent_s_inv=best.rate_value,
        )

    y_fit = best.scale * I_model + best.offset

    # Save a short report
    report = outdir / f"fit_report_{args.mode}.txt"
    report.write_text(
        "\n".join([
            f"mode: {best.mode}",
            f"{best.rate_name}: {best.rate_value:.6g}",
            f"visibility0: {best.visibility0}",
            f"visibility_used: {V:.6g}",
            f"scale: {best.scale:.6g}",
            f"offset: {best.offset:.6g}",
            f"SSE: {best.sse:.6g}",
        ]) + "\n",
        encoding="utf-8",
    )

    # Plot
    plt.figure()
    plt.plot(x, y, label="data")
    plt.plot(x, y_fit, label="fit")
    plt.xlabel("x (m)")
    plt.ylabel("counts/intensity")
    plt.legend()
    plt.tight_layout()
    plt.savefig(outdir / f"fit_{args.mode}.png", dpi=200)


if __name__ == "__main__":
    main()
