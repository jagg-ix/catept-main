#!/usr/bin/env python3
"""Paper-faithful CAT/EPT vs standard comparison using the *Excel-derived* dataset.

This script is meant to close the loop the way your paper describes:

  1) Fit the decoherence/entropic rate on ONE separation setting (one S-set).
  2) Predict the other separation setting *without refitting*.
  3) Write all intermediate artifacts into PAPER_TABLES/ for later inspection.

Data source
-----------
Uses the SQLite DB produced by data_pipeline/user_scripts/ (Makefile targets).
We specifically use:
  - Fig_2a_tidy.csv  (S = 800 fs)  -> experiments.figure_ref == "Fig_2a"
  - Fig_2b_tidy.csv  (S = 500 fs)  -> experiments.figure_ref == "Fig_2b"

Model
-----
Uses the repo's minimal temporal double-slit spectrum model:
  - standard mode: exponential decoherence with rate gamma (1/s)
  - entropic mode: entropic proper time / complex-action proxy with rate lambda_ent (1/s)

Important: this tool intentionally stays *tool-driven*: it only uses the extracted
dataset and the simulator in this repo.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict
from pathlib import Path

import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from cat_ept_doubleslit.db import load_spectra
from cat_ept_doubleslit.fit import fit_rate_grid_temporal
from cat_ept_doubleslit.experiments.time_double_slit import bandpass_normalize
from cat_ept_doubleslit.models import temporal_double_slit_spectrum


def _read_pdf_text_pdftotext(pdf_path: Path) -> str:
    import subprocess

    out = subprocess.check_output(["pdftotext", str(pdf_path), "-"], stderr=subprocess.STDOUT)
    return out.decode("utf-8", errors="replace")


def _extract_constants_from_pdf(text: str) -> dict:
    """Reuse the same extraction logic as scripts/tirole_ingest_and_compare.py (lightweight)."""
    import re

    constants: dict = {}

    m = re.search(r"carrier\s+frequency\s+([0-9]+\.?[0-9]*)\s*THz", text)
    if m:
        constants["probe_carrier_THz"] = float(m.group(1))

    m = re.search(r"Gaussian envelope\s+with\s+([0-9]+\.?[0-9]*)\s*fs\s*FWHM", text)
    if m:
        constants["probe_fwhm_fs"] = float(m.group(1))

    m = re.search(r"rise time\s*\(10\-90%\)\s*of\s*([0-9]+\.?[0-9]*)\s*fs", text)
    if m:
        constants["slit_rise_10_90_fs"] = float(m.group(1))

    # The SI mentions alpha=1/(2 fs) in the PDF text we previously parsed.
    m = re.search(r"parameter\s+\s*\w*alpha\s+of\s+1/\s*([0-9]+\.?[0-9]*)\s*fs\-1", text)
    if m:
        denom = float(m.group(1))
        constants["alpha_fs"] = denom
        constants["alpha_inv_fs"] = 1.0 / denom

    # beta=1/400 fs^-1 appears in the SI text.
    m = re.search(r"beta\s+coefficient\s+at\s+1/\s*([0-9]+)\s*fs\-1", text)
    if m:
        denom = float(m.group(1))
        constants["beta_fs"] = denom
        constants["beta_inv_fs"] = 1.0 / denom

    return constants


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _save_overlay(out_png: Path, det_THz: np.ndarray, y: np.ndarray, yhat: np.ndarray, title: str) -> None:
    plt.figure()
    plt.plot(det_THz, y, label="data")
    plt.plot(det_THz, yhat, label="model")
    plt.xlabel("Detuning (THz)")
    plt.ylabel("Normalized intensity")
    plt.title(title)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_png)
    plt.close()


def _write_csv(path: Path, det_THz: np.ndarray, y: np.ndarray, yhat_std: np.ndarray, yhat_cat: np.ndarray) -> None:
    arr = np.column_stack([det_THz, y, yhat_std, yhat_cat])
    path.write_text("detuning_THz,data,std_pred,cat_pred\n")
    with path.open("a", encoding="utf-8") as f:
        for r in arr:
            f.write(f"{r[0]:.9f},{r[1]:.9e},{r[2]:.9e},{r[3]:.9e}\n")


def _rmse(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.sqrt(np.mean((np.asarray(a) - np.asarray(b)) ** 2)))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True, help="SQLite produced by data_pipeline/user_scripts")
    ap.add_argument("--pdf", required=True, help="Tirole paper PDF (for constants)")
    ap.add_argument("--calibrate", choices=["500", "800"], default="500", help="Which S-set to fit")
    ap.add_argument("--out", default="PAPER_TABLES", help="Output folder")
    ap.add_argument("--rate_max", type=float, default=5e14, help="Max rate (1/s) to scan")
    ap.add_argument("--rate_n", type=int, default=600, help="Number of grid points")
    ap.add_argument("--lambda0", type=float, default=1e15, help="Reference rate λ0 (1/s) used by entropic phase reparameterization")
    args = ap.parse_args()

    out = Path(args.out)
    _ensure_dir(out)

    text = _read_pdf_text_pdftotext(Path(args.pdf))
    constants = _extract_constants_from_pdf(text)
    (out / "ingested_constants.json").write_text(json.dumps(constants, indent=2))

    w0_THz = float(constants.get("probe_carrier_THz", 382.0))
    # Convert 10-90 rise time to an effective Gaussian-ish rise parameter for the model.
    # We keep this conservative: use the extracted 10-90% rise directly as the model's
    # characteristic rise time (order-of-magnitude match is what matters for comparisons).
    rise_fs = float(constants.get("slit_rise_10_90_fs", 7.0))
    slit_rise_s = rise_fs * 1e-15

    # Two reference spectra from the extraction pipeline
    fA_THz, yA_raw = load_spectra(args.db, ref="Fig_2a")  # S=800 fs
    fB_THz, yB_raw = load_spectra(args.db, ref="Fig_2b")  # S=500 fs

    # Work in Hz internally
    fA_Hz = fA_THz * 1e12
    fB_Hz = fB_THz * 1e12
    w0_Hz = w0_THz * 1e12

    # Normalize intensities to match the model's unit scale.
    # The paper reports oscillations over roughly ~10 THz red and ~4 THz blue,
    # so we choose a conservative half-width of 15 THz around the carrier.
    half_width_hz = 15.0e12
    fA_Hz, yA = bandpass_normalize(fA_Hz, yA_raw, w0_Hz, half_width_hz)
    fB_Hz, yB = bandpass_normalize(fB_Hz, yB_raw, w0_Hz, half_width_hz)

    # detuning axis in Hz for the fit
    detA_Hz = fA_Hz - w0_Hz
    detB_Hz = fB_Hz - w0_Hz

    # Sort
    oa = np.argsort(detA_Hz)
    ob = np.argsort(detB_Hz)
    detA_Hz, yA = detA_Hz[oa], yA[oa]
    detB_Hz, yB = detB_Hz[ob], yB[ob]

    rate_grid = np.linspace(0.0, float(args.rate_max), int(args.rate_n))

    # Calibration set selection
    if args.calibrate == "500":
        cal_S_fs = 500.0
        cal_det_Hz, cal_y = detB_Hz, yB
        pred_S_fs = 800.0
        pred_det_Hz, pred_y = detA_Hz, yA
        cal_tag, pred_tag = "S500fs", "S800fs"
    else:
        cal_S_fs = 800.0
        cal_det_Hz, cal_y = detA_Hz, yA
        pred_S_fs = 500.0
        pred_det_Hz, pred_y = detB_Hz, yB
        cal_tag, pred_tag = "S800fs", "S500fs"

    # Fit standard and CAT/EPT rates on calibration set
    res_std = fit_rate_grid_temporal(
        cal_det_Hz,
        cal_y,
        separation_s=cal_S_fs * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="standard",
        rate_grid=rate_grid,
        fit_affine=False,
    )
    res_cat = fit_rate_grid_temporal(
        cal_det_Hz,
        cal_y,
        separation_s=cal_S_fs * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="entropic",
        rate_grid=rate_grid,
        fit_affine=False,
        lambda0_s_inv=float(args.lambda0),
    )

    # Predict the other S-set with NO refit
    Ical_std, _ = temporal_double_slit_spectrum(
        f_hz=cal_det_Hz,
        separation_s=cal_S_fs * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="standard",
        gamma_s_inv=res_std.rate_value,
    )
    Ical_cat, _ = temporal_double_slit_spectrum(
        f_hz=cal_det_Hz,
        separation_s=cal_S_fs * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="entropic",
        lambda_ent_s_inv=res_cat.rate_value,
        lambda0_s_inv=float(args.lambda0),
    )

    Ipred_std, _ = temporal_double_slit_spectrum(
        f_hz=pred_det_Hz,
        separation_s=pred_S_fs * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="standard",
        gamma_s_inv=res_std.rate_value,
    )
    Ipred_cat, _ = temporal_double_slit_spectrum(
        f_hz=pred_det_Hz,
        separation_s=pred_S_fs * 1e-15,
        slit_rise_s=slit_rise_s,
        mode="entropic",
        lambda_ent_s_inv=res_cat.rate_value,
        lambda0_s_inv=float(args.lambda0),
    )

    # Save overlays + csv tables
    det_cal_THz = cal_det_Hz / 1e12
    det_pred_THz = pred_det_Hz / 1e12
    _write_csv(out / f"calibration_{cal_tag}.csv", det_cal_THz, cal_y, Ical_std, Ical_cat)
    _write_csv(out / f"prediction_{pred_tag}.csv", det_pred_THz, pred_y, Ipred_std, Ipred_cat)

    _save_overlay(out / f"overlay_calibration_{cal_tag}_standard.png", det_cal_THz, cal_y, Ical_std, f"Calibration {cal_tag} (standard)")
    _save_overlay(out / f"overlay_calibration_{cal_tag}_cat.png", det_cal_THz, cal_y, Ical_cat, f"Calibration {cal_tag} (CAT/EPT)")
    _save_overlay(out / f"overlay_prediction_{pred_tag}_standard.png", det_pred_THz, pred_y, Ipred_std, f"Prediction {pred_tag} (standard rate from {cal_tag})")
    _save_overlay(out / f"overlay_prediction_{pred_tag}_cat.png", det_pred_THz, pred_y, Ipred_cat, f"Prediction {pred_tag} (CAT/EPT rate from {cal_tag})")

    summary = {
        "calibration": {
            "S_fs": cal_S_fs,
            "std_fit": asdict(res_std),
            "cat_fit": asdict(res_cat),
            "rmse_std": _rmse(cal_y, Ical_std),
            "rmse_cat": _rmse(cal_y, Ical_cat),
        },
        "prediction": {
            "S_fs": pred_S_fs,
            "rmse_std": _rmse(pred_y, Ipred_std),
            "rmse_cat": _rmse(pred_y, Ipred_cat),
        },
        "constants": {
            "probe_carrier_THz": w0_THz,
            "slit_rise_fs_used": rise_fs,
            "lambda0_s_inv": float(args.lambda0),
        },
    }
    (out / "PAPER_VISIBILITY_SUMMARY.json").write_text(json.dumps(summary, indent=2))

    # human-readable note
    lines = []
    lines.append(f"Calibration on {cal_tag}: std gamma={res_std.rate_value:.3e}  cat lambda={res_cat.rate_value:.3e} (1/s)")
    lines.append(f"RMSE calibration: std={summary['calibration']['rmse_std']:.4g} cat={summary['calibration']['rmse_cat']:.4g}")
    lines.append(f"Prediction on {pred_tag} using same rates:")
    lines.append(f"RMSE prediction: std={summary['prediction']['rmse_std']:.4g} cat={summary['prediction']['rmse_cat']:.4g}")
    (out / "PAPER_VISIBILITY_SUMMARY.txt").write_text("\n".join(lines) + "\n")

    print((out / "PAPER_VISIBILITY_SUMMARY.txt").read_text())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
