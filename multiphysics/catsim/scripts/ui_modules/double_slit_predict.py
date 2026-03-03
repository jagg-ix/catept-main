"""Double-slit baseline predictor (Fraunhofer approximation).

Outputs a stable artifact contract for the UI:

- pred_intensity.csv: x_m, I_pred
- summary.json: visibility estimate + params
- run_manifest.json: provenance

This is intentionally conservative: it is a baseline model that you can later replace
(or augment) with time-resolved diffraction and experiment-specific camera gating.
"""

from __future__ import annotations
import argparse, json, csv, math
from pathlib import Path
from dataclasses import asdict, dataclass
import numpy as np

from ._manifest import write_manifest

@dataclass
class Params:
    wavelength_m: float
    slit_sep_m: float
    slit_width_m: float
    screen_dist_m: float
    x_min_m: float
    x_max_m: float
    n: int

def sinc(x: np.ndarray) -> np.ndarray:
    # numpy sinc is sin(pi x)/(pi x), so adjust
    return np.sinc(x/np.pi)

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="output dir")
    ap.add_argument("--wavelength-m", type=float, default=632.8e-9)
    ap.add_argument("--slit-sep-m", type=float, default=50e-6)
    ap.add_argument("--slit-width-m", type=float, default=10e-6)
    ap.add_argument("--screen-dist-m", type=float, default=1.0)
    ap.add_argument("--x-min-m", type=float, default=-5e-3)
    ap.add_argument("--x-max-m", type=float, default=5e-3)
    ap.add_argument("--n", type=int, default=2001)
    args = ap.parse_args()

    out_dir = Path(args.out)
    p = Params(
        wavelength_m=args.wavelength_m,
        slit_sep_m=args.slit_sep_m,
        slit_width_m=args.slit_width_m,
        screen_dist_m=args.screen_dist_m,
        x_min_m=args.x_min_m,
        x_max_m=args.x_max_m,
        n=args.n,
    )

    x = np.linspace(p.x_min_m, p.x_max_m, p.n)
    # Fraunhofer: beta = pi a x /(lambda L), delta = pi d x /(lambda L)
    beta = math.pi * p.slit_width_m * x / (p.wavelength_m * p.screen_dist_m)
    delta = math.pi * p.slit_sep_m   * x / (p.wavelength_m * p.screen_dist_m)

    envelope = (np.sinc(beta/np.pi))**2
    interference = (np.cos(delta))**2
    I = envelope * interference
    I = I / max(I.max(), 1e-30)

    # crude visibility estimate on central region
    mid = slice(int(0.45*p.n), int(0.55*p.n))
    I_mid = I[mid]
    Imax = float(I_mid.max())
    Imin = float(I_mid.min())
    V = (Imax - Imin)/(Imax + Imin) if (Imax + Imin) > 0 else float("nan")

    out_dir.mkdir(parents=True, exist_ok=True)
    out_csv = out_dir / "pred_intensity.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["x_m","I_pred"])
        for xi, Ii in zip(x, I):
            w.writerow([f"{float(xi):.12g}", f"{float(Ii):.12g}"])

    summary = {
        "visibility_estimate": V,
        "params": asdict(p),
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))

    write_manifest(out_dir, {
        "module": "double_slit",
        "artifacts": {
            "pred_intensity_csv": str(out_csv),
            "summary_json": str(out_dir/"summary.json"),
        },
        "params": asdict(p),
        "notes": ["Baseline Fraunhofer double-slit model (envelope*squared-cos)."],
    })

    print(f"Wrote: {out_csv}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
