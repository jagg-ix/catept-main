#!/usr/bin/env python3
import argparse, json, math
from dataclasses import dataclass
from pathlib import Path
import numpy as np
import pandas as pd

def _sf(x):
    try:
        return float(x)
    except Exception:
        return float('nan')

def estimate_vcl(df: pd.DataFrame, vcol: str) -> float:
    d = df.copy()
    d['absS'] = d['slit_separation_fs'].abs()
    d = d[np.isfinite(d[vcol]) & np.isfinite(d["absS"]) & (d["absS"]>0)]
    if len(d)==0:
        return 1.0
    cutoff = np.quantile(d["absS"].values, 0.2)
    small = d[d["absS"] <= cutoff]
    if len(small)==0:
        small = d.nsmallest(max(1, min(10, len(d))), "absS")
    v = np.clip(small[vcol].values.astype(float), 1e-9, 1.0)
    return float(np.quantile(v, 0.95))

@dataclass
class Row:
    S_fs: float
    df_THz: float
    s: float
    V: float
    q: float
    lam: float
    gamma: float
    asym: float
    Delta: float
    J: float
    pt_unbroken: bool
    eta_residual: float
    eta_cond: float
    asym_pred: float

def solve_eta(H: np.ndarray, rcond: float = 1e-12):
    # eta = [[a, c+id],[c-id,b]]
    def eta_from(x):
        a,b,c,d = x
        return np.array([[a, c+1j*d],[c-1j*d,b]], dtype=complex)
    basis = [np.array([1,0,0,0],float), np.array([0,1,0,0],float), np.array([0,0,1,0],float), np.array([0,0,0,1],float)]
    M=[]; y=[]
    for i in range(2):
        for j in range(2):
            coeff=[]
            for e in basis:
                E = eta_from(e)
                Z = H.conj().T@E - E@H
                coeff.append(Z[i,j])
            M.append([float(np.real(c)) for c in coeff]); y.append(0.0)
            M.append([float(np.imag(c)) for c in coeff]); y.append(0.0)
    M=np.array(M,float); y=np.array(y,float)
    # trace constraint a+b=2
    M2 = np.vstack([M, np.array([1,1,0,0],float)])
    y2 = np.concatenate([y, np.array([2.0],float)])
    x, *_ = np.linalg.lstsq(M2, y2, rcond=rcond)
    eta = eta_from(x)
    res = H.conj().T@eta - eta@H
    return eta, float(np.linalg.norm(res))

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--obs_spectral", default="PAPER_TABLES/OBSERVABLES/obs_spectral.csv")
    ap.add_argument("--out", default="PAPER_TABLES")
    ap.add_argument("--figure", default="Fig_2f")
    ap.add_argument("--visibility_col", default="visibility_paper")
    ap.add_argument("--vcl", type=float, default=0.0)
    ap.add_argument("--S_cal_fs", type=float, default=500.0)
    args=ap.parse_args()

    obs = pd.read_csv(args.obs_spectral)
    obs = obs[obs["figure_ref"]==args.figure].copy()
    obs["slit_separation_fs"] = obs["slit_separation_fs"].apply(_sf)
    obs["fringe_spacing_THz"] = obs["fringe_spacing_THz"].apply(_sf)
    obs[args.visibility_col] = obs[args.visibility_col].apply(_sf)
    obs["asymmetry_fraction"] = obs["asymmetry_fraction"].apply(_sf)
    obs = obs[np.isfinite(obs["slit_separation_fs"]) & np.isfinite(obs["fringe_spacing_THz"]) & np.isfinite(obs[args.visibility_col])]
    obs = obs[obs["slit_separation_fs"].abs() > 1e-9]
    if len(obs)==0:
        raise SystemExit("No usable observable rows")

    vcl = args.vcl if args.vcl>0 else estimate_vcl(obs, args.visibility_col)
    vcl = float(np.clip(vcl, 1e-6, 1.0))

    # pick calibration row closest in absS to S_cal_fs
    target = abs(args.S_cal_fs)
    obs["absS"] = obs["slit_separation_fs"].abs()
    cal = obs.iloc[(obs["absS"]-target).abs().argmin()]

    # compute cal s and gamma (from visibility)
    S_cal = float(cal["slit_separation_fs"])
    absS_s = abs(S_cal)*1e-15
    df_THz = float(cal["fringe_spacing_THz"])
    omega = 2*math.pi*df_THz*1e12
    s_cal = 0.5*omega
    V = float(np.clip(float(cal[args.visibility_col]), 1e-9, 1.0))
    q = max(0.0, -math.log(V/vcl))
    lam = q/max(absS_s, 1e-30)
    gamma_cal = 0.5*lam

    # calibrated map: aim for asym_pred ~= asym at calibration using asym_pred = Delta/sqrt(s^2+gamma^2)
    asym_cal = float(cal.get("asymmetry_fraction", 0.0))
    if not np.isfinite(asym_cal):
        asym_cal = 0.0
    aclip = float(np.clip(asym_cal, -0.9, 0.9))
    denom = math.sqrt(s_cal*s_cal + gamma_cal*gamma_cal)
    if abs(aclip) < 1e-9 or denom < 1e-30 or abs(s_cal) < 1e-30:
        k = 1.0
    else:
        # solve a = (k*a*s)/denom -> k = denom/s
        k = denom/max(abs(s_cal), 1e-30)
    k = float(np.clip(k, 0.05, 20.0))

    # now build per-S table with k and with baseline k=1 comparison of asym_pred error
    rows=[]
    eps=1e-24
    for _, r in obs.iterrows():
        S_fs = float(r["slit_separation_fs"])
        absS_s = abs(S_fs)*1e-15
        df_THz = float(r["fringe_spacing_THz"])
        omega = 2*math.pi*df_THz*1e12
        s = 0.5*omega
        V = float(np.clip(float(r[args.visibility_col]), 1e-9, 1.0))
        q = max(0.0, -math.log(V/vcl))
        lam = q/max(absS_s, 1e-30)
        gamma = 0.5*lam
        asym = float(r.get("asymmetry_fraction", 0.0))
        if not np.isfinite(asym):
            asym = 0.0
        aclip = float(np.clip(asym, -0.9, 0.9))
        Delta = k*aclip*s
        J2 = s*s + gamma*gamma - Delta*Delta
        J = math.sqrt(max(J2, eps))
        pt_unbroken = (J2>0.0) and (s*s>0.0)
        H = np.array([[Delta+1j*gamma, J],[J, -Delta-1j*gamma]], dtype=complex)
        eta, res = solve_eta(H)
        try:
            cond = float(np.linalg.cond(eta))
        except Exception:
            cond = float("nan")
        denom = math.sqrt(s*s + gamma*gamma)
        asym_pred = (Delta/denom) if denom>0 else 0.0
        # baseline pred with k=1
        Delta0 = aclip*s
        asym_pred0 = (Delta0/denom) if denom>0 else 0.0
        rows.append({
            "S_fs": S_fs, "absS_fs": abs(S_fs), "fringe_spacing_THz": df_THz,
            "visibility": V, "Vcl_used": vcl, "q": q,
            "lambda_eff_inv_s": lam, "gamma_inv_s": gamma,
            "asym_obs": asym, "aclip": aclip,
            "k_calibrated": k, "Delta": Delta, "J": J, "pt_unbroken": pt_unbroken,
            "eta_residual_norm": res, "eta_condition_number": cond,
            "asym_pred_k": asym_pred, "asym_pred_k1": asym_pred0,
            "abs_err_k": abs(asym_pred-asym), "abs_err_k1": abs(asym_pred0-asym),
        })

    out = pd.DataFrame(rows).sort_values("absS_fs")
    out_dir = Path(args.out)/"PT_HAMILTONIAN_2x2_DATA_CAL"
    out_dir.mkdir(parents=True, exist_ok=True)
    out.to_csv(out_dir/"hamiltonian_2x2_calibrated.csv", index=False)

    # train/test split: train is the chosen closest-to S_cal, test all others
    cal_mask = (out["absS_fs"] - abs(S_cal)).abs() < 1e-6
    test = out[~cal_mask].copy()
    mae_k = float(test["abs_err_k"].mean()) if len(test) else 0.0
    mae_k1 = float(test["abs_err_k1"].mean()) if len(test) else 0.0
    summary = {
        "figure": args.figure, "S_cal_fs": S_cal, "S_cal_target_fs": args.S_cal_fs,
        "k_calibrated": k, "Vcl_used": vcl,
        "n_total": int(len(out)), "n_test": int(len(test)),
        "asym_MAE_test_k": mae_k, "asym_MAE_test_k1": mae_k1,
        "improvement": float(mae_k1-mae_k),
        "pt_unbroken_fraction": float(out["pt_unbroken"].mean()) if len(out) else 0.0,
        "eta_residual_median": float(np.nanmedian(out["eta_residual_norm"].values)),
        "eta_cond_median": float(np.nanmedian(out["eta_condition_number"].values)),
    }
    (out_dir/"summary.json").write_text(json.dumps(summary, indent=2))
    status = "OK" if summary["asym_MAE_test_k"] <= summary["asym_MAE_test_k1"] else "WARN"
    (out_dir/'STATUS.txt').write_text(status + '\n')
    (out_dir/'README.md').write_text(
        '# Phase 4E calibrated PT reduction\n\n'
        'Generated by scripts/phase4e_pt_reduction_calibrated.py.\n'
        'Trains a single coefficient k on S_cal, then predicts all other S.\n'
        'Asymmetry prediction uses asym_pred = Delta/sqrt(s^2+gamma^2).\n'
    )

if __name__ == "__main__":
    main()
