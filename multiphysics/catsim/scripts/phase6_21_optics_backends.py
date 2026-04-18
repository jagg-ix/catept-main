#!/usr/bin/env python3
"""Phase 6.21 - Optics backends interoperability (Diffractio / LightPipes / POPPY / HCIPy / Legume).

Goal:
- Provide a single entropic-time aware adapter surface that can be used by the rest of the repo.
- Keep all third-party optics libs OPTIONAL (PASS/SKIP discipline).
- Establish a stable reference (NumPy Fraunhofer) and compare other backends against it.

This phase is deliberately conservative: if a backend isn't installed we SKIP it,
and if it is installed we still run the same portable reference computation (until
a later iteration replaces the TODO stubs with native calls).

Outputs:
- PAPER_TABLES/ADVANCED/OPTICS_INTEROP/rect_compare.csv
- STATUS.md + summary.json
"""

from __future__ import annotations

import argparse
import json
import os
from dataclasses import asdict
from typing import Dict, List

import numpy as np

from cat_ept_doubleslit.numerics.cfl_clock import CFLClock
from catsim_core.spacetime.coupler import make_identity_coupler
from cat_ept_doubleslit.optics import create_engine, list_backends


def _ensure_dir(p: str) -> None:
    os.makedirs(p, exist_ok=True)


def _write_status(out_dir: str, status_md: str, summary: Dict) -> None:
    with open(os.path.join(out_dir, "STATUS.md"), "w", encoding="utf-8") as f:
        f.write(status_md)
    with open(os.path.join(out_dir, "summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, sort_keys=True)


def _make_time_grid(
    *,
    t_final_s: float,
    n_hint: int,
    lambda_max_s_inv: float,
    use_cfl_clock: bool,
) -> np.ndarray:
    if not use_cfl_clock:
        return np.linspace(0.0, float(t_final_s), int(n_hint), dtype=float)

    clock = CFLClock(dx=None, a_max_default=None, cfl_max=0.95, alpha_scheme=0.9)
    t = 0.0
    out = [t]
    # ensure at least a few steps even for tiny t_final
    hard_cap = max(10_000, 10 * int(n_hint))
    for _ in range(hard_cap):
        if t >= t_final_s:
            break
        dt = clock.suggest_dt(lambda_max=float(lambda_max_s_inv))
        if dt is None or dt <= 0:
            # fallback: uniform
            return np.linspace(0.0, float(t_final_s), int(n_hint), dtype=float)
        t = min(t + float(dt), float(t_final_s))
        out.append(t)
    return np.asarray(out, dtype=float)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="PAPER_TABLES/ADVANCED/OPTICS_INTEROP")
    ap.add_argument("--wavelength_m", type=float, default=1.55e-6)
    ap.add_argument("--aperture_width_m", type=float, default=50e-6)
    ap.add_argument("--z_m", type=float, default=0.5)
    ap.add_argument("--n_x", type=int, default=2048)
    ap.add_argument("--x_span_m", type=float, default=0.0, help="0 => auto")
    ap.add_argument("--t_final_s", type=float, default=1e-12)
    ap.add_argument("--n_t_hint", type=int, default=512)
    ap.add_argument("--lambda0_s_inv", type=float, default=1e12)
    ap.add_argument("--use_cfl_clock", type=int, default=1)
    args = ap.parse_args()

    out_dir = args.out
    _ensure_dir(out_dir)

    # Minimal entropic-time contract for optics engines: we generate it here so
    # downstream modules can correlate optics outputs with open-system dissipation.
    coupler = make_identity_coupler(lambda_base=lambda t: float(args.lambda0_s_inv))
    t_s = _make_time_grid(
        t_final_s=args.t_final_s,
        n_hint=args.n_t_hint,
        lambda_max_s_inv=float(args.lambda0_s_inv),
        use_cfl_clock=bool(args.use_cfl_clock),
    )
    lam = np.array([coupler.lambda_eff(float(t)) for t in t_s], dtype=float)
    tau = np.cumsum(np.concatenate([[0.0], 0.5 * (lam[1:] + lam[:-1]) * np.diff(t_s)]))

    # Run reference
    engines: List[str] = list_backends(only_available=False)
    x_span = None if args.x_span_m <= 0 else float(args.x_span_m)

    rows = []
    summary = {
        "phase": "6.21",
        "out_dir": out_dir,
        "entropic_time": {
            "t_final_s": float(args.t_final_s),
            "n_t": int(t_s.size),
            "n_t_hint": int(args.n_t_hint),
            "lambda0_s_inv": float(args.lambda0_s_inv),
            "use_cfl_clock": bool(args.use_cfl_clock),
        },
        "backends": {},
    }

    status_lines = ["# Phase 6.21 Optics interop\n"]
    status_lines.append(f"- time grid: n={t_s.size} (hint {args.n_t_hint}), use_cfl_clock={bool(args.use_cfl_clock)}\n")
    status_lines.append(f"- lambda0: {args.lambda0_s_inv:.3e} 1/s\n")

    # reference
    ref = create_engine("numpy")
    ref_out = ref.run_rect_aperture(
        aperture_width_m=args.aperture_width_m,
        wavelength_m=args.wavelength_m,
        z_m=args.z_m,
        n_x=args.n_x,
        x_span_m=x_span,
    )
    I_ref = ref_out.I
    x_ref = ref_out.x_m

    # helper metric
    def mae(a: np.ndarray, b: np.ndarray) -> float:
        a = np.asarray(a, dtype=float)
        b = np.asarray(b, dtype=float)
        denom = np.maximum(1e-30, np.mean(np.abs(b)))
        return float(np.mean(np.abs(a - b)) / denom)

    for name in engines:
        try:
            eng = create_engine(name)
            out = eng.run_rect_aperture(
                aperture_width_m=args.aperture_width_m,
                wavelength_m=args.wavelength_m,
                z_m=args.z_m,
                n_x=args.n_x,
                x_span_m=x_span,
            )
            if out.x_m.shape != x_ref.shape:
                # resample onto reference grid (linear)
                I = np.interp(x_ref, out.x_m, out.I)
            else:
                I = out.I
            m = mae(I, I_ref)
            summary["backends"][name] = {"status": "PASS", "mae_vs_numpy": m, "meta": out.meta}
            status_lines.append(f"- {name}: PASS (MAE={m:.3e})\n")
        except ImportError as e:
            summary["backends"][name] = {"status": "SKIP", "reason": str(e)}
            status_lines.append(f"- {name}: SKIP ({e})\n")
        except Exception as e:
            summary["backends"][name] = {"status": "FAIL", "reason": str(e)}
            status_lines.append(f"- {name}: FAIL ({e})\n")

    # Export compare CSV (reference + one column per backend available)
    # Keep it simple: write x and I_numpy plus any PASS engines.
    pass_engines = [k for k,v in summary["backends"].items() if v.get("status") == "PASS"]
    cols = ["x_m", "I_numpy"]
    data = [x_ref, I_ref]
    for name in pass_engines:
        if name == "numpy":
            continue
        eng = create_engine(name)
        out = eng.run_rect_aperture(
            aperture_width_m=args.aperture_width_m,
            wavelength_m=args.wavelength_m,
            z_m=args.z_m,
            n_x=args.n_x,
            x_span_m=x_span,
        )
        I = np.interp(x_ref, out.x_m, out.I) if out.x_m.shape != x_ref.shape else out.I
        cols.append(f"I_{name}")
        data.append(I)

    arr = np.vstack(data).T
    csv_path = os.path.join(out_dir, "rect_compare.csv")
    with open(csv_path, "w", encoding="utf-8") as f:
        f.write(",".join(cols) + "\n")
        for row in arr:
            f.write(",".join(f"{float(v):.10e}" for v in row) + "\n")

    # also export entropic contract snapshot
    et_path = os.path.join(out_dir, "entropic_time_contract.csv")
    with open(et_path, "w", encoding="utf-8") as f:
        f.write("t_s,tau_ent_s,lambda_eff_s_inv\n")
        for t, ta, la in zip(t_s, tau, lam):
            f.write(f"{t:.10e},{ta:.10e},{la:.10e}\n")

    _write_status(out_dir, "".join(status_lines), summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
