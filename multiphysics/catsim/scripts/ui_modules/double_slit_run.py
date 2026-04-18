"""Double-slit module runner: extract measured traces from SQLite + generate baseline prediction.

This repo's "double-slit" dataset is the *temporal* double-slit / time-diffraction dataset (Tirole).
Measured observables available from SQLite are:
- spectra: frequency_thz, intensity
- time-domain: delay_fs, reflectivity

This runner creates a UI-friendly run directory with stable artifacts:

Artifacts:
- meas_spectra.csv (frequency_thz, intensity)
- meas_time_domain.csv (delay_fs, reflectivity)
- pred_spectra_catept.csv (x_m, I_pred)  [baseline spatial Fraunhofer predictor placeholder]
- summary.json
- run_manifest.json

Note:
The baseline predictor currently generates a spatial Fraunhofer I(x) curve as a conservative "starter".
Next step is to replace/augment it with a time-diffraction forward model producing predicted spectra/time-domain.
"""

from __future__ import annotations
import argparse, csv, json
from pathlib import Path
from dataclasses import asdict
import numpy as np

from cat_ept_doubleslit.db import list_experiments, load_spectra, load_time_domain
from cat_ept_doubleslit.adapters.double_slit_backend import compute_double_slit_observables
from .double_slit_physics_multilayer import (
    _load_eps_table_csv, TimeTraceParams, build_time_trace_from_r,
    affine_match, best_time_shift,
    r_stack_transfer_matrix, StackSpec, LayerSpec, load_stack_json
)
from ._manifest import write_manifest

import math

def _write_csv(path: Path, header: list[str], rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w=csv.writer(f)
        w.writerow(header)
        for r in rows:
            w.writerow(r)

def polyfit_predict(x, y, deg: int):
    # Fit polynomial in normalized x for numeric stability
    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)
    if len(x) < max(5, deg+2):
        return None, None
    x0 = float(x.mean())
    s = float(x.std()) if float(x.std()) > 0 else 1.0
    xn = (x - x0)/s
    coeff = np.polyfit(xn, y, deg=deg)
    yhat = np.polyval(coeff, xn)
    return yhat, {"deg": int(deg), "x_mean": x0, "x_std": s, "coeff": [float(c) for c in coeff]}

def load_eps_table(csv_path: Path):
    import pandas as pd
    df = pd.read_csv(csv_path)
    cols = {c.lower(): c for c in df.columns}
    # accept f_thz or freq_thz
    fcol = cols.get("frequency_thz") or cols.get("freq_thz") or cols.get("f_thz") or cols.get("f_thz".lower()) or cols.get("f_thz")
    if fcol is None:
        # common variant: f_THz
        fcol = cols.get("f_thz") or cols.get("f_thz".lower())
    if fcol is None and "f_thz" in cols:
        fcol = cols["f_thz"]
    if fcol is None and "f_thz" in df.columns:
        fcol = "f_thz"
    if fcol is None and "f_THz" in df.columns:
        fcol = "f_THz"
    if fcol is None:
        raise ValueError(f"Could not find frequency column in eps table. Columns: {list(df.columns)}")
    # eps columns
    re_col = cols.get("eps_real") or cols.get("epsilon_real") or cols.get("eps_re")
    im_col = cols.get("eps_imag") or cols.get("epsilon_imag") or cols.get("eps_im")
    if re_col is None or im_col is None:
        raise ValueError(f"Missing eps_real/eps_imag in eps table. Columns: {list(df.columns)}")
    f_thz = df[fcol].to_numpy(dtype=float)
    eps = df[re_col].to_numpy(dtype=float) + 1j*df[im_col].to_numpy(dtype=float)
    return f_thz, eps

def slab_reflection_coeff(freq_thz: np.ndarray, eps: np.ndarray, thickness_m: float, n0: complex = 1.0+0j, n2: complex = 1.0+0j):
    # Normal incidence, air|slab|air by default
    c_light = 299792458.0
    f_hz = np.asarray(freq_thz, dtype=float) * 1e12
    omega = 2*np.pi*np.maximum(f_hz, 1e-30)
    k0 = omega / c_light
    n1 = np.sqrt(eps.astype(complex))
    r01 = (n0 - n1) / (n0 + n1)
    r12 = (n1 - n2) / (n1 + n2)
    t01 = 2*n0 / (n0 + n1)
    t10 = 2*n1 / (n0 + n1)
    phase = np.exp(2j * n1 * k0 * thickness_m)
    denom = 1 - r01*r12*phase  # since r10=-r01; using symmetric form
    r = r01 + (t01*t10*r12*phase) / denom
    return r

def uniform_grid_ifft(freq_thz: np.ndarray, r_complex: np.ndarray, nfft: int = 4096):
    # Interpolate onto uniform frequency grid for IFFT.
    f = np.asarray(freq_thz, dtype=float)
    r = np.asarray(r_complex, dtype=complex)
    # sort
    idx = np.argsort(f)
    f = f[idx]; r = r[idx]
    fmin, fmax = float(f[0]), float(f[-1])
    # uniform grid
    f_u = np.linspace(fmin, fmax, nfft)
    # interp real/imag separately
    r_u_re = np.interp(f_u, f, np.real(r))
    r_u_im = np.interp(f_u, f, np.imag(r))
    r_u = r_u_re + 1j*r_u_im
    # IFFT assuming spectrum sampled from DC..fmax; treat as baseband complex
    # Time step: dt = 1/(N*df)
    df_hz = (f_u[1]-f_u[0]) * 1e12
    dt = 1.0/(nfft*df_hz)
    t = np.arange(nfft)*dt
    h = np.fft.ifft(r_u)
    return f_u, r_u, t, h

def affine_fit(y_true: np.ndarray, y_pred: np.ndarray):
    # Fit y_true ≈ a*y_pred + b by least squares
    y_true = np.asarray(y_true, dtype=float)
    y_pred = np.asarray(y_pred, dtype=float)
    X = np.vstack([y_pred, np.ones_like(y_pred)]).T
    coeff, *_ = np.linalg.lstsq(X, y_true, rcond=None)
    a, b = float(coeff[0]), float(coeff[1])
    y_hat = a*y_pred + b
    resid = y_true - y_hat
    rmse = float(np.sqrt(np.mean(resid**2))) if len(resid) else float("nan")
    return y_hat, resid, {"a": a, "b": b, "rmse": rmse}




def resolve_experiment(db: Path, exp: str):
    if exp.isdigit():
        return {"experiment_id": int(exp), "ref": None}
    return {"experiment_id": None, "ref": exp}

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument("--db", default="data_pipeline/user_scripts/double_slit.sqlite3")
    ap.add_argument("--experiment", default="1", help="experiment id or ref string")
    ap.add_argument("--out", required=True)

    # CAT/EPT backend controls
    ap.add_argument("--sep-s", type=float, default=None, help="Override time-slit separation Δt in seconds (else inferred from fringe spacing).")
    ap.add_argument("--sigma-s", type=float, default=None, help="Override Gaussian slit rise σ in seconds (else crude inferred from envelope).")
    ap.add_argument("--visibility0", type=float, default=1.0, help="Base visibility factor V0.")
    ap.add_argument("--lambda0", type=float, default=1.0e15, help="Reference rate λ0 for entropic phase reparam (model parameter).")
    ap.add_argument("--poly-deg-spectra", type=int, default=10, help="polynomial degree for spectra baseline")
    ap.add_argument("--poly-deg-time", type=int, default=10, help="polynomial degree for time-domain baseline")
    ap.add_argument("--eps-table-csv", default="data/materials/ITO_eps_table_proxy.csv", help="eps(ω) table CSV for physics predictor")
    ap.add_argument("--slab-thickness-m", type=float, default=200e-9, help="slab thickness for Fresnel/transfer-matrix predictor")
    ap.add_argument("--physics-nfft", type=int, default=4096, help="NFFT for IFFT time-domain predictor")
    ap.add_argument("--physics-enabled", action="store_true", help="enable physics-based spectra/time prediction using eps table")

    args=ap.parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    db_path = (repo_root / args.db) if not Path(args.db).is_absolute() else Path(args.db)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    exp_sel = resolve_experiment(db_path, args.experiment)

    # Extract measured spectra/time-domain if possible
    meas = {"spectra": None, "time_domain": None}
    errors = []
    try:
        f_thz, inten = load_spectra(db_path, **exp_sel)
        _write_csv(out_dir/"meas_spectra.csv", ["frequency_thz","intensity"],
                   ((f"{float(f0):.12g}", f"{float(i0):.12g}") for f0,i0 in zip(f_thz, inten)))
        meas["spectra"] = "meas_spectra.csv"
    except Exception as e:
        errors.append(f"spectra_extract_error: {e}")

    try:
        delay_fs, refl = load_time_domain(db_path, **exp_sel)
        _write_csv(out_dir/"meas_time_domain.csv", ["delay_fs","reflectivity"],
                   ((f"{float(d0):.12g}", f"{float(r0):.12g}") for d0,r0 in zip(delay_fs, refl)))
        meas["time_domain"] = "meas_time_domain.csv"
    except Exception as e:
        errors.append(f"time_domain_extract_error: {e}")
    # CAT/EPT backend prediction (primary for spectra)
    catept = None
    if meas.get("spectra") is not None:
        try:
            catept = compute_double_slit_observables(
                f_thz=f_thz,
                intensity=inten,
                separation_s=args.sep_s,
                slit_rise_s=args.sigma_s,
                visibility0=float(args.visibility0),
                lambda0_s_inv=float(args.lambda0),
                fit_affine=True,
            )
            pred_csv = out_dir/"pred_spectra_catept.csv"
            pred_intensity = np.asarray(catept["arrays"]["intensity_pred"], dtype=float)
            _write_csv(pred_csv, ["frequency_thz","intensity_pred"],
                       ((f"{float(f0):.12g}", f"{float(y0):.12g}") for f0,y0 in zip(f_thz, pred_intensity)))

            res_csv = out_dir/"residuals_spectra_catept.csv"
            resid = np.asarray(catept["arrays"]["residual"], dtype=float)
            _write_csv(res_csv, ["frequency_thz","residual_meas_minus_pred"],
                       ((f"{float(f0):.12g}", f"{float(r0):.12g}") for f0,r0 in zip(f_thz, resid)))

            metrics["rmse_spectra_catept"] = float(catept["fit"]["rmse"])
            metrics["best_lambda_ent_s_inv"] = float(catept["fit"]["best_rate"])
            metrics["V_effective_fit"] = float(catept["fit"]["V_effective_fit"])
        except Exception as e:
            errors.append(f"catept_backend_error: {e}")
    else:
        pred_csv = out_dir/"pred_spectra_catept.csv"


    
    # Baseline predictions for extracted measured traces (conservative smoothing)
    metrics = {}
    if meas.get("spectra"):
        try:
            f_thz, inten = load_spectra(db_path, **exp_sel)
            yhat, fitinfo = polyfit_predict(f_thz, inten, deg=args.poly_deg_spectra)
            if yhat is not None:
                out_pred = out_dir/"pred_spectra.csv"
                _write_csv(out_pred, ["frequency_thz","intensity_pred"],
                           ((f"{float(f0):.12g}", f"{float(y0):.12g}") for f0,y0 in zip(f_thz, yhat)))
                out_res = out_dir/"residuals_spectra.csv"
                resid = np.asarray(inten, dtype=float) - np.asarray(yhat, dtype=float)
                rmse = float(np.sqrt(np.mean(resid**2)))
                metrics["spectra_rmse"] = rmse
                metrics["spectra_fit"] = fitinfo
                _write_csv(out_res, ["frequency_thz","residual_meas_minus_pred"],
                           ((f"{float(f0):.12g}", f"{float(r0):.12g}") for f0,r0 in zip(f_thz, resid)))
        except Exception as e:
            errors.append(f"spectra_pred_error: {e}")

    if meas.get("time_domain"):
        try:
            delay_fs, refl = load_time_domain(db_path, **exp_sel)
            yhat, fitinfo = polyfit_predict(delay_fs, refl, deg=args.poly_deg_time)
            if yhat is not None:
                out_pred = out_dir/"pred_time_domain.csv"
                _write_csv(out_pred, ["delay_fs","reflectivity_pred"],
                           ((f"{float(d0):.12g}", f"{float(y0):.12g}") for d0,y0 in zip(delay_fs, yhat)))
                out_res = out_dir/"residuals_time_domain.csv"
                resid = np.asarray(refl, dtype=float) - np.asarray(yhat, dtype=float)
                rmse = float(np.sqrt(np.mean(resid**2)))
                metrics["time_domain_rmse"] = rmse
                metrics["time_domain_fit"] = fitinfo
                _write_csv(out_res, ["delay_fs","residual_meas_minus_pred"],
                           ((f"{float(d0):.12g}", f"{float(r0):.12g}") for d0,r0 in zip(delay_fs, resid)))
        except Exception as e:
            errors.append(f"time_domain_pred_error: {e}")

    # Physics-based prediction (eps-table slab optics) for direct overlay
    physics_metrics = {}
    if args.physics_enabled:
        try:
            eps_path = (repo_root / args.eps_table_csv) if not (Path(args.eps_table_csv).is_absolute()) else Path(args.eps_table_csv)
            f_eps, eps = load_eps_table(eps_path)

            # predict on measured frequency grid (spectra) if available
            if meas.get("spectra"):
                f_thz, inten = load_spectra(db_path, **exp_sel)
                eps_re = np.interp(f_thz, f_eps, np.real(eps))
                eps_im = np.interp(f_thz, f_eps, np.imag(eps))
                eps_m = eps_re + 1j*eps_im
                r = slab_reflection_coeff(f_thz, eps_m, thickness_m=args.slab_thickness_m)
                R = np.abs(r)**2
                Rn = (R - np.min(R)) / max((np.max(R) - np.min(R)), 1e-30)
                out_pred = out_dir/"pred_spectra_physics.csv"
                _write_csv(out_pred, ["frequency_thz","intensity_pred"],
                           ((f"{float(f0):.12g}", f"{float(y0):.12g}") for f0,y0 in zip(f_thz, Rn)))
                yhat, resid, fitinfo = affine_fit(inten, Rn)
                out_res = out_dir/"residuals_spectra_physics.csv"
                _write_csv(out_res, ["frequency_thz","residual_meas_minus_pred_affine"],
                           ((f"{float(f0):.12g}", f"{float(r0):.12g}") for f0,r0 in zip(f_thz, resid)))
                physics_metrics["spectra_affine_fit"] = fitinfo

                f_u, r_u, t_s, h = uniform_grid_ifft(f_thz, r, nfft=args.physics_nfft)
                h_re = np.real(h)
                delay_fs_pred = t_s * 1e15
                out_td = out_dir/"pred_time_domain_physics_field.csv"
                _write_csv(out_td, ["delay_fs","field_re_pred"],
                           ((f"{float(d0):.12g}", f"{float(v0):.12g}") for d0,v0 in zip(delay_fs_pred, h_re)))

            if meas.get("time_domain"):
                delay_fs_meas, refl_meas = load_time_domain(db_path, **exp_sel)
                # Map field prediction to reflectivity proxy via affine match + best shift
                if (out_dir/"pred_time_domain_physics_field.csv").exists():
                    import pandas as pd
                    dfp = pd.read_csv(out_dir/"pred_time_domain_physics_field.csv")
                    delay_fs_pred = dfp["delay_fs"].to_numpy(dtype=float)
                    field_re = dfp["field_re_pred"].to_numpy(dtype=float)
                    shift_fs = best_time_shift(delay_fs_pred, field_re, delay_fs_meas, refl_meas)
                    y_pred_shifted = np.interp(delay_fs_meas, delay_fs_pred + shift_fs, field_re, left=np.nan, right=np.nan)
                    yhat2, resid2, fitinfo2 = affine_fit(refl_meas, y_pred_shifted)
                    out_td2 = out_dir/"pred_time_domain_physics_mag.csv"
                    _write_csv(out_td2, ["delay_fs","reflectivity_pred_affine"],
                               ((f"{float(d0):.12g}", f"{float(v0):.12g}") for d0,v0 in zip(delay_fs_meas, yhat2)))
                    out_res2 = out_dir/"residuals_time_domain_physics.csv"
                    _write_csv(out_res2, ["delay_fs","residual_meas_minus_pred_affine"],
                               ((f"{float(d0):.12g}", f"{float(r0):.12g}") for d0,r0 in zip(delay_fs_meas, resid2)))
                    physics_metrics["time_domain_affine_fit"] = fitinfo2

            physics_metrics["eps_table_csv"] = str(eps_path)
            physics_metrics["slab_thickness_m"] = float(args.slab_thickness_m)
            physics_metrics["nfft"] = int(args.physics_nfft)
        except Exception as e:
            errors.append(f"physics_pred_error: {e}")



    summary = {
        "db_path": str(db_path),
        "experiment": args.experiment,
        "measured_artifacts": meas,
        "catept_pred": catept,
        "metrics": metrics,
        "physics_metrics": physics_metrics,
        "notes": [
            "Measured artifacts are temporal dataset (spectra/time-domain) extracted from SQLite.",
            "pred_spectra_catept.csv is generated by the CAT/EPT adapter (entropic mode) fit to the measured spectrum.",
        ],
        "errors": errors,
    }
    (out_dir/"summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))

    write_manifest(out_dir, {
        "module": "double_slit",
        "db": str(db_path),
        "experiment": args.experiment,
        "artifacts": {
            "meas_spectra_csv": str(out_dir/"meas_spectra.csv"),
            "meas_time_domain_csv": str(out_dir/"meas_time_domain.csv"),
            "pred_spectra_catept_csv": str(pred_csv),
            "residuals_spectra_catept_csv": str(out_dir/"residuals_spectra_catept.csv"),
            "pred_spectra_csv": str(out_dir/"pred_spectra.csv"),
            "pred_time_domain_csv": str(out_dir/"pred_time_domain.csv"),
            "residuals_spectra_csv": str(out_dir/"residuals_spectra.csv"),
            "residuals_time_domain_csv": str(out_dir/"residuals_time_domain.csv"),
            "pred_spectra_physics_csv": str(out_dir/"pred_spectra_physics.csv"),
            "pred_time_domain_physics_field_csv": str(out_dir/"pred_time_domain_physics_field.csv"),
            "pred_time_domain_physics_mag_csv": str(out_dir/"pred_time_domain_physics_mag.csv"),
            "residuals_spectra_physics_csv": str(out_dir/"residuals_spectra_physics.csv"),
            "residuals_time_domain_physics_csv": str(out_dir/"residuals_time_domain_physics.csv"),
            "summary_json": str(out_dir/"summary.json"),
        },
        "params": {
            "catept_pred": catept,
        "metrics": metrics,
        "physics_metrics": physics_metrics,
        },
        "warnings": errors,
    })

    print("Wrote double slit run artifacts to", out_dir)
    if errors:
        print("Warnings:")
        for e in errors:
            print(" -", e)
    return 0

if __name__=="__main__":
    raise SystemExit(main())
