"""Tirole temporal double-slit: ingest -> simulate -> compare.

Goal
----
Create a *reproducible, tool-generated* artifact set that:
  1) Ingests quantitative statements from the uploaded paper PDF
     ("Double-slit time diffraction at optical frequencies", Tirole et al.)
  2) Runs the repo's temporal double-slit simulator in "standard theory" mode,
     and checks whether headline constraints match.
  3) Runs a CAT/EPT-on variant (toggle) as a *new prediction* dataset.

This does **not** digitize figure heatmaps. It only ingests numbers that appear in the
PDF text (supplement section included in the same PDF) and compares against simulation.

Outputs
-------
Writes an output directory containing:
  - results.sqlite3 (SQLite DB with ingested constants + simulation summaries)
  - ingest_constants.json
  - standard_runs/* (csv + png)
  - cat_runs/* (csv + png)
  - compare_report.md (generated from DB)
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
from dataclasses import asdict
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import matplotlib


# Use a non-interactive backend for headless runs
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


from cat_ept_doubleslit.experiments.time_double_slit import (  # noqa: E402
    TimeDoubleSlitConfig,
    bandpass_normalize,
    simulate_time_double_slit,
)


def _read_pdf_text_pdftotext(pdf_path: str) -> str:
    """Read PDF text via system `pdftotext` if available."""
    import subprocess

    try:
        out = subprocess.check_output(["pdftotext", pdf_path, "-"], stderr=subprocess.STDOUT)
        return out.decode("utf-8", errors="replace")
    except Exception as e:  # pragma: no cover
        raise RuntimeError(f"Failed to extract text from PDF via pdftotext: {e}")


def _extract_constants(text: str) -> Dict[str, dict]:
    """Extract key numeric constants that appear explicitly in the paper text."""
    constants: Dict[str, dict] = {}

    # Carrier frequency (THz)
    m = re.search(r"carrier\s+frequency\s+([0-9]+\.?[0-9]*)\s*THz", text)
    if m:
        constants["probe_carrier_THz"] = {"value": float(m.group(1)), "unit": "THz", "source": "SI: Time diffraction model"}

    # Probe field envelope FWHM (fs)
    m = re.search(r"Gaussian envelope\s+with\s+([0-9]+\.?[0-9]*)\s*fs\s*FWHM", text)
    if m:
        constants["probe_fwhm_fs"] = {"value": float(m.group(1)), "unit": "fs", "source": "SI: Time diffraction model"}

    # Alpha coefficient (1/fs)
    m = re.search(r"value\s+for\s+the\s+parameter\s+\s*\w*alpha\s+of\s+1/\s*([0-9]+\.?[0-9]*)\s*fs\-1", text)
    if m:
        denom = float(m.group(1))
        constants["alpha_inv_fs"] = {"value": 1.0 / denom, "unit": "fs^-1", "source": "SI: Time diffraction model fit"}
        constants["alpha_fs"] = {"value": denom, "unit": "fs", "source": "SI: Time diffraction model fit (alpha=1/(2 fs))"}

    # Rise time 10-90% (fs)
    m = re.search(r"rise time\s*\(10\-90%\)\s*of\s*([0-9]+\.?[0-9]*)\s*fs", text)
    if m:
        constants["rise_time_10_90_fs"] = {"value": float(m.group(1)), "unit": "fs", "source": "SI: Time diffraction model fit"}

    # Rise time range 1-10 fs
    m = re.search(r"range\s+1\-10\s*fs", text)
    if m:
        constants["rise_time_range_fs"] = {"value": "1-10", "unit": "fs", "source": "SI: Time diffraction model"}

    # Beta coefficient (1/fs)
    m = re.search(r"value\s+for\s+the\s+\s*\w*beta\s+coefficient\s+at\s+1/\s*([0-9]+)\s*fs\-1", text)
    if m:
        denom = float(m.group(1))
        constants["beta_inv_fs"] = {"value": 1.0 / denom, "unit": "fs^-1", "source": "SI: slit characterization"}
        constants["beta_fs"] = {"value": denom, "unit": "fs", "source": "SI: slit characterization (beta=1/400 fs^-1)"}

    # Second peak relative amplitude
    m = re.search(r"relative amplitude\s+of\s+the\s+second\s+peak\s+of\s+the\s+time\s+slit\s+to\s+be\s+([0-9]+\.?[0-9]*)%", text)
    if m:
        constants["second_peak_percent"] = {"value": float(m.group(1)), "unit": "%", "source": "SI: slit characterization"}

    # Red/blue extents (THz)
    m = re.search(r"~?10\s*THz\s+on\s+the\s+red\s+side\s+and\s+~?4\s*THz\s+on\s+the\s+blue\s+side", text)
    if m:
        constants["extent_red_THz"] = {"value": 10.0, "unit": "THz", "source": "Main text"}
        constants["extent_blue_THz"] = {"value": 4.0, "unit": "THz", "source": "Main text"}

    return constants


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _write_csv(path: Path, cols: Dict[str, np.ndarray]) -> None:
    keys = list(cols.keys())
    arr = np.column_stack([np.asarray(cols[k]) for k in keys])
    header = ",".join(keys)
    np.savetxt(path, arr, delimiter=",", header=header, comments="")


def _plot_spectrum(path: Path, detune_THz: np.ndarray, I: np.ndarray, title: str) -> None:
    plt.figure()
    plt.plot(detune_THz, I)
    plt.xlabel("Detuning (THz)")
    plt.ylabel("Normalized intensity")
    plt.title(title)
    plt.tight_layout()
    plt.savefig(path)
    plt.close()


def _fringe_spacing_THz(detune_THz: np.ndarray, I: np.ndarray) -> float:
    """Estimate fringe spacing via autocorrelation peak of detrended signal."""
    x = detune_THz
    y = I - np.mean(I)
    # autocorrelation
    ac = np.correlate(y, y, mode="full")
    ac = ac[ac.size // 2 :]
    # ignore zero lag, find first prominent peak
    # smooth slightly
    w = 11
    if ac.size > w:
        ac_s = np.convolve(ac, np.ones(w) / w, mode="same")
    else:
        ac_s = ac
    # search in a reasonable lag range
    dx = float(x[1] - x[0])
    lags = np.arange(ac_s.size) * dx
    lo = int(max(1, 0.2 / dx))
    hi = int(min(ac_s.size, 5.0 / dx))
    if hi <= lo + 5:
        return float("nan")
    k = lo + int(np.argmax(ac_s[lo:hi]))
    return float(lags[k])


def _visibility_paper(detune_THz: np.ndarray, I: np.ndarray, band_THz: float = 10.0) -> float:
    """Paper-like visibility: median fringe contrast from local extrema."""
    x = detune_THz
    y = I
    mask = (x >= -band_THz) & (x <= band_THz)
    x = x[mask]
    y = y[mask]
    if x.size < 10:
        return float("nan")
    # find local extrema
    dy = np.diff(y)
    s = np.sign(dy)
    ds = np.diff(s)
    maxima = np.where(ds < 0)[0] + 1
    minima = np.where(ds > 0)[0] + 1
    if maxima.size < 2 or minima.size < 2:
        return float("nan")
    # pair extrema by sorting
    extrema = np.sort(np.concatenate([maxima, minima]))
    contrasts: List[float] = []
    for i in range(len(extrema) - 2):
        a, b, c = extrema[i], extrema[i + 1], extrema[i + 2]
        # require max-min-max or min-max-min
        if (a in maxima and b in minima and c in maxima) or (a in minima and b in maxima and c in minima):
            Imax = float(max(y[a], y[c]))
            Imin = float(y[b])
            if Imax + Imin > 1e-300:
                contrasts.append((Imax - Imin) / (Imax + Imin))
    if not contrasts:
        return float("nan")
    return float(np.median(contrasts))


def _extent_THz(detune_THz: np.ndarray, I: np.ndarray, thresh: float = 1e-2) -> float:
    """Extent proxy: max |detuning| where oscillations remain above a small threshold."""
    # Use envelope-threshold on normalized intensity
    x = detune_THz
    y = I
    mask = y >= float(thresh)
    if not np.any(mask):
        return 0.0
    return float(np.max(np.abs(x[mask])))


def _init_db(db_path: Path) -> sqlite3.Connection:
    con = sqlite3.connect(str(db_path))
    cur = con.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS tirole_constants(
          key TEXT PRIMARY KEY,
          value TEXT,
          unit TEXT,
          source TEXT
        );
        """
    )
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS sim_runs(
          run_id TEXT PRIMARY KEY,
          mode TEXT,
          S_fs REAL,
          alpha_inv_fs REAL,
          beta_inv_fs REAL,
          use_cat_ept INTEGER,
          lambda_ent_inv_s REAL,
          gamma_entropic REAL,
          fringe_spacing_THz REAL,
          visibility REAL,
          extent_THz REAL,
          notes TEXT
        );
        """
    )
    con.commit()
    return con


def _upsert_constants(con: sqlite3.Connection, constants: Dict[str, dict]) -> None:
    cur = con.cursor()
    for k, v in constants.items():
        cur.execute(
            "INSERT OR REPLACE INTO tirole_constants(key,value,unit,source) VALUES(?,?,?,?)",
            (k, str(v.get("value")), v.get("unit", ""), v.get("source", "")),
        )
    con.commit()


def _run_one(
    out_dir: Path,
    mode: str,
    S_fs: float,
    alpha_inv_fs: float,
    beta_inv_fs: float,
    use_cat: bool,
    lambda_ent_inv_s: float,
    gamma_entropic: float,
    band_THz: float = 10.0,
) -> Tuple[Dict[str, float], Path]:
    cfg = TimeDoubleSlitConfig(
        separation_s=S_fs * 1e-15,
        alpha_inv_s=alpha_inv_fs * 1e15,
        beta_inv_s=beta_inv_fs * 1e15,
        use_cat_ept=use_cat,
        lambda0_inv_s=lambda_ent_inv_s,
        lambda_kappa=0.0,
        lambda_floor_inv_s=lambda_ent_inv_s,
        gamma_entropic=gamma_entropic,
    )

    res = simulate_time_double_slit(cfg)
    f = res["freq_hz"]
    I = res["intensity"]
    fb, Ib = bandpass_normalize(f, I, f_center_hz=cfg.f0_hz, half_width_hz=band_THz * 1e12)
    detune_THz = (fb - cfg.f0_hz) / 1e12

    run_name = f"{mode}_S{int(round(S_fs))}fs_a{alpha_inv_fs:.3f}_cat{int(use_cat)}"
    run_path = out_dir / run_name
    _ensure_dir(run_path)

    _write_csv(run_path / "spectrum_band.csv", {"detune_THz": detune_THz, "I_norm": Ib})
    _plot_spectrum(run_path / "spectrum_band.png", detune_THz, Ib, title=run_name)

    spacing = _fringe_spacing_THz(detune_THz, Ib)
    vis = _visibility_paper(detune_THz, Ib, band_THz=band_THz)
    extent = _extent_THz(detune_THz, Ib, thresh=1e-2)

    metrics = {
        "fringe_spacing_THz": spacing,
        "visibility": vis,
        "extent_THz": extent,
    }
    return metrics, run_path


def _write_report(con: sqlite3.Connection, out_dir: Path) -> None:
    cur = con.cursor()
    const = {k: (v, u) for k, v, u in cur.execute("SELECT key,value,unit FROM tirole_constants").fetchall()}
    runs = cur.execute(
        "SELECT mode,S_fs,alpha_inv_fs,use_cat_ept,fringe_spacing_THz,visibility,extent_THz,notes FROM sim_runs ORDER BY mode,S_fs,alpha_inv_fs"
    ).fetchall()

    lines: List[str] = []
    lines.append("# Tirole temporal double-slit: ingest + compare (tool-generated)\n")
    lines.append("## Ingested constants (from PDF text)\n")
    for k, (v, u) in sorted(const.items()):
        lines.append(f"- **{k}**: {v} {u}")
    lines.append("\n## Simulation comparisons\n")
    lines.append("Each run reports fringe spacing (THz), paper-like visibility, and a simple extent proxy (THz).")
    lines.append("\n| mode | S (fs) | alpha (1/fs) | CAT | spacing (THz) | vis | extent (THz) | notes |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|---|")
    for mode, S_fs, a, cat, sp, vis, ext, notes in runs:
        lines.append(
            f"| {mode} | {S_fs:.0f} | {a:.3f} | {int(cat)} | {sp:.3f} | {vis:.3f} | {ext:.1f} | {notes or ''} |"
        )
    (out_dir / "compare_report.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", required=True, help="Path to Tirole paper PDF")
    ap.add_argument("--out", required=True, help="Output directory")
    ap.add_argument("--db", default="results.sqlite3", help="SQLite filename within --out")
    ap.add_argument("--S_fs", default="500,800", help="Comma-separated separations to test")
    ap.add_argument("--alpha_inv_fs", default="0.25,0.5,1.0", help="Comma-separated alpha (1/fs) grid")
    ap.add_argument("--beta_inv_fs", default="0.0025", help="Comma-separated beta (1/fs)")
    ap.add_argument("--band_THz", type=float, default=10.0)
    ap.add_argument("--lambda_ent", type=float, default=1.0e12, help="CAT/EPT coherence rate (1/s) for prediction")
    ap.add_argument("--gamma", type=float, default=0.0, help="gamma_entropic used by amplitude-weight CAT/EPT toggle")
    args = ap.parse_args()

    out_dir = Path(args.out)
    _ensure_dir(out_dir)

    # Ingest
    text = _read_pdf_text_pdftotext(args.pdf)
    constants = _extract_constants(text)
    (out_dir / "ingest_constants.json").write_text(json.dumps(constants, indent=2), encoding="utf-8")

    con = _init_db(out_dir / args.db)
    _upsert_constants(con, constants)

    # Simulate + compare
    S_list = [float(x.strip()) for x in args.S_fs.split(",") if x.strip()]
    a_list = [float(x.strip()) for x in args.alpha_inv_fs.split(",") if x.strip()]
    b_list = [float(x.strip()) for x in args.beta_inv_fs.split(",") if x.strip()]
    beta = b_list[0] if b_list else 0.0025

    std_dir = out_dir / "standard_runs"
    cat_dir = out_dir / "cat_runs"
    _ensure_dir(std_dir)
    _ensure_dir(cat_dir)

    cur = con.cursor()
    for S in S_list:
        for a in a_list:
            # Standard
            m_std, _ = _run_one(std_dir, "standard", S, a, beta, False, 0.0, 0.0, band_THz=args.band_THz)
            cur.execute(
                "INSERT OR REPLACE INTO sim_runs(run_id,mode,S_fs,alpha_inv_fs,beta_inv_fs,use_cat_ept,lambda_ent_inv_s,gamma_entropic,fringe_spacing_THz,visibility,extent_THz,notes)"
                " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",
                (
                    f"standard_S{S}_a{a}",
                    "standard",
                    S,
                    a,
                    beta,
                    0,
                    0.0,
                    0.0,
                    m_std["fringe_spacing_THz"],
                    m_std["visibility"],
                    m_std["extent_THz"],
                    "",
                ),
            )

            # CAT/EPT-on (note: this is the *amplitude-weight* toggle in this repo snapshot)
            m_cat, _ = _run_one(cat_dir, "cat", S, a, beta, True, args.lambda_ent, args.gamma, band_THz=args.band_THz)
            cur.execute(
                "INSERT OR REPLACE INTO sim_runs(run_id,mode,S_fs,alpha_inv_fs,beta_inv_fs,use_cat_ept,lambda_ent_inv_s,gamma_entropic,fringe_spacing_THz,visibility,extent_THz,notes)"
                " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",
                (
                    f"cat_S{S}_a{a}",
                    "cat",
                    S,
                    a,
                    beta,
                    1,
                    args.lambda_ent,
                    args.gamma,
                    m_cat["fringe_spacing_THz"],
                    m_cat["visibility"],
                    m_cat["extent_THz"],
                    "CAT/EPT toggle: amplitude-weight exp(-gamma*tau_ent)",
                ),
            )

    con.commit()
    _write_report(con, out_dir)
    con.close()


if __name__ == "__main__":
    main()
