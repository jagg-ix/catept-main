"""Simulation CLI.

Supports:
- Spatial double slit (screen position x -> intensity)
- Temporal double slit (frequency f -> spectrum intensity), inspired by
  'Double-slit time diffraction at optical frequencies' (Tirole et al.).

Usage:
  python run_simulate.py --config configs/default.json --outdir out --compare
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

from .models import double_slit_intensity, temporal_double_slit_spectrum
from .io import save_csv_xy


def _load_config(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _plot_xy(x: np.ndarray, y: np.ndarray, xlabel: str, ylabel: str, title: str, out_png: Path) -> None:
    plt.figure()
    plt.plot(x, y)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title)
    plt.tight_layout()
    plt.savefig(out_png, dpi=200)
    plt.close()


def _run_spatial(cfg: dict, mode: str) -> tuple[np.ndarray, np.ndarray, float]:
    x = np.linspace(cfg["x_min_m"], cfg["x_max_m"], int(cfg.get("n_points", 4001)))

    # Backward compatibility: older configs used 't_flight_s'; prefer 'flight_time_s'.
    flight_time_s = cfg.get("flight_time_s", cfg.get("t_flight_s"))

    I, V = double_slit_intensity(
        x_m=x,
        wavelength_m=cfg["wavelength_m"],
        slit_sep_m=cfg["slit_sep_m"],
        slit_width_m=cfg["slit_width_m"],
        screen_dist_m=cfg["screen_dist_m"],
        visibility0=cfg.get("visibility0", 1.0),
        mode=mode,
        gamma_s_inv=float(cfg.get("gamma_s_inv", 0.0)),
        lambda_ent_s_inv=float(cfg.get("lambda_ent_s_inv", 0.0)),
        flight_time_s=None if flight_time_s is None else float(flight_time_s),
    )
    return x, I, V


def _run_temporal(cfg: dict, mode: str) -> tuple[np.ndarray, np.ndarray, float]:
    f = np.linspace(cfg["f_min_hz"], cfg["f_max_hz"], int(cfg.get("n_points", 4001)))

    # Backward/forward compatibility:
    # - configs may use either 'separation_s' (canonical) or 'slit_separation_s' (legacy)
    separation_s = cfg.get("separation_s", cfg.get("slit_separation_s"))
    if separation_s is None:
        raise KeyError("Temporal config must include 'separation_s' (or legacy 'slit_separation_s')")

    I, V = temporal_double_slit_spectrum(
        f_hz=f,
        separation_s=float(separation_s),
        slit_rise_s=float(cfg["slit_rise_s"]),
        visibility0=cfg.get("visibility0", 1.0),
        mode=mode,
        gamma_s_inv=float(cfg.get("gamma_s_inv", 0.0)),
        lambda_ent_s_inv=float(cfg.get("lambda_ent_s_inv", 0.0)),
    )
    return f, I, V


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True, help="Path to config JSON")
    ap.add_argument("--outdir", required=True, help="Output directory")
    ap.add_argument("--compare", action="store_true", help="Run both modes and compare")
    args = ap.parse_args()

    cfg = _load_config(Path(args.config))
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    experiment = str(cfg.get("experiment", "spatial")).lower()
    if experiment not in {"spatial", "temporal"}:
        raise SystemExit(f"Unknown experiment type: {experiment!r}. Use 'spatial' or 'temporal'.")

    runner = _run_spatial if experiment == "spatial" else _run_temporal
    x_name, x_label = ("x_m", "Screen position x (m)") if experiment == "spatial" else ("f_Hz", "Frequency f (Hz)")

    if args.compare:
        x_s, I_s, V_s = runner(cfg, "standard")
        x_e, I_e, V_e = runner(cfg, "entropic")

        save_csv_xy(outdir / f"pattern_standard_{experiment}.csv", x_s, I_s, x_name=x_name, y_name="intensity")
        save_csv_xy(outdir / f"pattern_entropic_{experiment}.csv", x_e, I_e, x_name=x_name, y_name="intensity")

        plt.figure()
        plt.plot(x_s, I_s, label=f"standard (V={V_s:.4g})")
        plt.plot(x_e, I_e, label=f"entropic (V={V_e:.4g})")
        plt.xlabel(x_label)
        plt.ylabel("Intensity (a.u.)")
        plt.title(f"Double-slit ({experiment}) comparison")
        plt.legend()
        plt.tight_layout()
        plt.savefig(outdir / f"comparison_{experiment}.png", dpi=200)
        plt.close()
    else:
        mode = str(cfg.get("mode", "standard")).lower()
        x, I, V = runner(cfg, mode)

        save_csv_xy(outdir / f"pattern_{mode}_{experiment}.csv", x, I, x_name=x_name, y_name="intensity")
        _plot_xy(x, I, x_label, "Intensity (a.u.)", f"Double-slit ({experiment}) — {mode} (V={V:.4g})", outdir / f"pattern_{mode}_{experiment}.png")


if __name__ == "__main__":
    main()
