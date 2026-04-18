#!/usr/bin/env python3
"""Paper-faithful sweep over slit separations using Fig_2f (spectral matrix).

Goal
----
Mimic the *protocol* described in your CAT/EPT paper:
  1) Fit one separation S_cal to determine a single (gamma, lambda_ent).
  2) Predict all other separations without refitting.
  3) Write tool-generated tables/overlays into PAPER_TABLES/FIG2F_SWEEP/.

This script is fully tool-driven: it only uses
  - the SQLite DB from data_pipeline/user_scripts
  - the repo's temporal spectrum model

It produces BOTH "standard" and "CAT/EPT" predictions.

Notes
-----
- Fig_2f contains both positive and negative slit separations in fs.
  For the baseline visibility sweep we group by |S| (physics is symmetric).
- lambda0 is inferred from a CFL/Nyquist-style dt bound unless explicitly set.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from cat_ept_doubleslit.db import load_spectra_by_slit_separation
from cat_ept_doubleslit.entropic_time import lambda0_from_cfl_time_step
from cat_ept_doubleslit.experiments.time_double_slit import bandpass_normalize
from cat_ept_doubleslit.fit import fit_rate_grid_temporal
from cat_ept_doubleslit.models import temporal_double_slit_spectrum


def _ensure(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _rmse(a: np.ndarray, b: np.ndarray) -> float:
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    return float(np.sqrt(np.mean((a - b) ** 2)))


def _read_pdf_text_pdftotext(pdf_path: Path) -> str:
    import subprocess

    out = subprocess.check_output(["pdftotext", str(pdf_path), "-"], stderr=subprocess.STDOUT)
    return out.decode("utf-8", errors="replace")


def _extract_constants_from_pdf(text: str) -> dict:
    import re

    c: dict = {}

    m = re.search(r"carrier\s+frequency\s+([0-9]+\.?[0-9]*)\s*THz", text)
    if m:
        c["probe_carrier_THz"] = float(m.group(1))

    m = re.search(r"rise time\s*\(10\-90%\)\s*of\s*([0-9]+\.?[0-9]*)\s*fs", text)
    if m:
        c["slit_rise_10_90_fs"] = float(m.group(1))

    return c


def _save_overlay(path: Path, det_THz: np.ndarray, y: np.ndarray, y_std: np.ndarray, y_cat: np.ndarray, title: str) -> None:
    plt.figure()
    plt.plot(det_THz, y, label="data")
    plt.plot(det_THz, y_std, label="std")
    plt.plot(det_THz, y_cat, label="CAT/EPT")
    plt.xlabel("Detuning (THz)")
    plt.ylabel("Normalized intensity")
    plt.title(title)
    plt.legend()
    plt.tight_layout()
    plt.savefig(path)
    plt.close()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--pdf", required=True)
    ap.add_argument("--out", default="PAPER_TABLES")
    ap.add_argument("--cal_S_fs", type=float, default=500.0, help="Calibration |S| in fs")
    ap.add_argument("--rate_max", type=float, default=5e14)
    ap.add_argument("--rate_n", type=int, default=800)
    ap.add_argument("--half_width_THz", type=float, default=15.0)
    ap.add_argument("--lambda0", type=float, default=0.0, help="Override lambda0 (1/s). If 0, infer from dt.")
    ap.add_argument("--dt_fs", type=float, default=0.2, help="If inferring lambda0, use dt (fs).")
    args = ap.parse_args()

    out_root = Path(args.out)
    out = out_root / "FIG2F_SWEEP"
    _ensure(out)

    text = _read_pdf_text_pdftotext(Path(args.pdf))
    constants = _extract_constants_from_pdf(text)
    (out / "ingested_constants.json").write_text(json.dumps(constants, indent=2))

    w0_THz = float(constants.get("probe_carrier_THz", 230.2))
    rise_fs = float(constants.get("slit_rise_10_90_fs", 7.0))
    slit_rise_s = rise_fs * 1e-15

    # lambda0 from CFL/Nyquist-ish dt constraint
    if args.lambda0 > 0:
        lambda0 = float(args.lambda0)
    else:
        lambda0 = lambda0_from_cfl_time_step(args.dt_fs * 1e-15)

    # Load Fig2f grouped spectra
    grouped = load_spectra_by_slit_separation(args.db, ref="Fig_2f")

    # Build |S| groups by merging +S and -S (average intensities)
    abs_groups: dict[float, list[tuple[np.ndarray, np.ndarray]]] = {}
    for s_fs, (f_thz, inten) in grouped.items():
        abs_groups.setdefault(abs(float(s_fs)), []).append((f_thz, inten))

    # Choose calibration |S|
    S_cal = float(args.cal_S_fs)
    if S_cal not in abs_groups:
        # pick closest
        keys = np.array(sorted(abs_groups.keys()))
        S_cal = float(keys[np.argmin(np.abs(keys - S_cal))])

    def prep_one(f_thz: np.ndarray, inten: np.ndarray):
        f_hz = f_thz * 1e12
        w0_hz = w0_THz * 1e12
        half_width_hz = float(args.half_width_THz) * 1e12
        f_band, y = bandpass_normalize(f_hz, inten, w0_hz, half_width_hz)
        det_hz = f_band - w0_hz
        o = np.argsort(det_hz)
        return det_hz[o], y[o]

    # Calibration data (average across +/- if both exist)
    cal_sets = abs_groups[S_cal]
    dets, ys = [], []
    for f_thz, inten in cal_sets:
        d, y = prep_one(f_thz, inten)
        dets.append(d)
        ys.append(y)
    # Interpolate onto a common axis (use first as reference)
    det_cal = dets[0]
    y_cal = np.zeros_like(det_cal)
    for d, y in zip(dets, ys):
        y_cal += np.interp(det_cal, d, y)
    y_cal /= max(len(ys), 1)

    rate_grid = np.linspace(0.0, float(args.rate_max), int(args.rate_n))

    res_std = fit_rate_grid_temporal(
        det_cal,
        y_cal,
        separation_s=S_cal * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="standard",
        rate_grid=rate_grid,
        fit_affine=False,
    )
    res_cat = fit_rate_grid_temporal(
        det_cal,
        y_cal,
        separation_s=S_cal * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="entropic",
        rate_grid=rate_grid,
        fit_affine=False,
        lambda0_s_inv=lambda0,
    )

    (out / "fit_summary.json").write_text(
        json.dumps(
            {
                "S_cal_fs": S_cal,
                "gamma_fit_s_inv": res_std.rate_value,
                "lambda_ent_fit_s_inv": res_cat.rate_value,
                "lambda0_s_inv": lambda0,
                "rmse_cal_std": float(np.sqrt(res_std.sse / max(1, len(y_cal)))),
                "rmse_cal_cat": float(np.sqrt(res_cat.sse / max(1, len(y_cal)))),
            },
            indent=2,
        )
    )

    # Sweep predictions
    rows = []
    perS_dir = out / "per_S"
    _ensure(perS_dir)

    for S_fs in [s for s in sorted(abs_groups.keys()) if float(s) > 0.0]:
        sets = abs_groups[S_fs]
        dets, ys = [], []
        for f_thz, inten in sets:
            d, y = prep_one(f_thz, inten)
            dets.append(d)
            ys.append(y)
        det = dets[0]
        y = np.zeros_like(det)
        for d, yy in zip(dets, ys):
            y += np.interp(det, d, yy)
        y /= max(len(ys), 1)

        y_std, V_std = temporal_double_slit_spectrum(
            f_hz=det,
            separation_s=float(S_fs) * 1e-15,
            slit_rise_s=slit_rise_s,
            mode="standard",
            gamma_s_inv=float(res_std.rate_value),
        )
        y_cat, V_cat = temporal_double_slit_spectrum(
            f_hz=det,
            separation_s=float(S_fs) * 1e-15,
            slit_rise_s=slit_rise_s,
            mode="entropic",
            lambda_ent_s_inv=float(res_cat.rate_value),
            lambda0_s_inv=float(lambda0),
        )

        rmse_std = _rmse(y, y_std)
        rmse_cat = _rmse(y, y_cat)

        det_THz = det / 1e12
        # Save CSV and overlay
        csvp = perS_dir / f"Fig2f_absS_{S_fs:.0f}fs.csv"
        with csvp.open("w", encoding="utf-8") as f:
            f.write("detuning_THz,data,std_pred,cat_pred\n")
            for a, b, c, d in zip(det_THz, y, y_std, y_cat):
                f.write(f"{a:.9f},{b:.9e},{c:.9e},{d:.9e}\n")
        _save_overlay(
            perS_dir / f"Fig2f_absS_{S_fs:.0f}fs.png",
            det_THz,
            y,
            y_std,
            y_cat,
            title=f"Fig2f |S|={S_fs:.0f} fs (fit on {S_cal:.0f} fs)",
        )

        rows.append(
            {
                "absS_fs": float(S_fs),
                "n_traces": int(len(sets)),
                "rmse_std": rmse_std,
                "rmse_cat": rmse_cat,
                "V_eff_std": float(V_std),
                "V_eff_cat": float(V_cat),
            }
        )

    # Write sweep table
    import csv

    table_csv = out / "sweep_summary.csv"
    with table_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)

    # Quick plot: RMSE vs S
    plt.figure()
    Ss = [r["absS_fs"] for r in rows]
    plt.plot(Ss, [r["rmse_std"] for r in rows], label="std")
    plt.plot(Ss, [r["rmse_cat"] for r in rows], label="CAT/EPT")
    plt.xlabel("|S| (fs)")
    plt.ylabel("RMSE")
    plt.title("Fig2f sweep: prediction error vs separation")
    plt.legend()
    plt.tight_layout()
    plt.savefig(out / "rmse_vs_S.png")
    plt.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
