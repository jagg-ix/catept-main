"""Singularity shielding diagnostic (simulation-grade).

This tool does NOT claim a theorem. It produces diagnostics showing whether:
- metric clock rate dtau/dt collapses near a placed BH center
- PI attenuation weight exp(-Gamma) collapses along an approach trajectory
- entropic clock (if provided via gamma field) grows monotonically

Usage:
  python scripts/sgi_shielding_check.py --out OUTDIR --metric-mode kerr --bh-mass-kg ... --bh-placement center
"""

from __future__ import annotations
import argparse, os, json
import numpy as np

from catsim_core.spacetime.scene import RectRegion, BlackHoleSpec, Scene, shift_xyz_by_scene
from catsim_core.clock.clock_models import metric_clock, entropic_clock, check_monotonic
from catsim_core.qg.phase_path_integral import visibility_from_phase_pi
from catsim_core.catept.dissipation_field import constant_gamma, from_scene_context

def build_argparser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--scene-width-m", type=float, default=0.02)
    ap.add_argument("--scene-height-m", type=float, default=0.02)
    ap.add_argument("--bh-mass-kg", type=float, required=True)
    ap.add_argument("--bh-a-star", type=float, default=0.0)
    ap.add_argument("--bh-placement", default="center",
                    choices=["center","top","bottom","left","right","top_left","top_right","bottom_left","bottom_right"])
    ap.add_argument("--metric-mode", default="kerr", choices=["schwarzschild","kerr"])
    ap.add_argument("--metric-theta-deg", type=float, default=90.0)
    ap.add_argument("--observer-mode", default="static", choices=["static","zamo","circular_prograde","circular_retrograde"])
    ap.add_argument("--tmax-s", type=float, default=1.0)
    ap.add_argument("--n", type=int, default=2000)
    ap.add_argument("--r0-m", type=float, default=0.01)
    ap.add_argument("--rmin-m", type=float, default=1e-6)
    ap.add_argument("--gamma-phi", type=float, default=0.0)
    ap.add_argument("--gamma-field", default="constant", choices=["constant","scene_piecewise"])
    ap.add_argument("--gamma-region", type=float, default=None)
    return ap

def dtau_dt_metric(mode: str, observer_mode: str, mass_kg: float, a_star: float, theta_deg: float, x_m: np.ndarray) -> float:
    if mode == "kerr":
        from cat_ept_doubleslit.metrics.kerr_observers import KerrParams, dtau_dt_at_x
        kp = KerrParams.from_si(mass_kg=float(mass_kg), a_star=float(a_star), theta_deg=float(theta_deg))
        return float(dtau_dt_at_x(kp, x_m, observer_mode))
    else:
        from cat_ept_doubleslit.metrics.schwarzschild import SchwarzschildMetric
        m = SchwarzschildMetric.from_mass_kg(float(mass_kg))
        return float(m.redshift_factor(0.0, x_m))

def main() -> int:
    args = build_argparser().parse_args()
    os.makedirs(args.out, exist_ok=True)

    reg = RectRegion(width_m=float(args.scene_width_m), height_m=float(args.scene_height_m))
    bh = BlackHoleSpec(placement=str(args.bh_placement), mass_kg=float(args.bh_mass_kg),
                       a_star=float(args.bh_a_star), radius_m=0.0)
    scene = Scene(region=reg, black_hole=bh)
    ctx = scene.to_context()

    t = np.linspace(0.0, float(args.tmax_s), int(args.n))
    r = np.linspace(float(args.r0_m), float(args.rmin_m), int(args.n))
    x = np.zeros((len(t),3), dtype=float)
    x[:,0] = r

    x_eval = np.array([shift_xyz_by_scene(xi, ctx) for xi in x], dtype=float)
    dtau = np.array([dtau_dt_metric(args.metric_mode, args.observer_mode, args.bh_mass_kg, args.bh_a_star, args.metric_theta_deg, xi) for xi in x_eval], dtype=float)
    mc = metric_clock(t, dtau, meta={"metric_mode": args.metric_mode, "observer_mode": args.observer_mode})

    if args.gamma_field == "scene_piecewise":
        gamma_field = from_scene_context(ctx, gamma_background=float(args.gamma_phi),
                                         gamma_region=(float(args.gamma_region) if args.gamma_region is not None else None))
    else:
        gamma_field = constant_gamma(float(args.gamma_phi))

    gvals = np.array([float(gamma_field(float(ti), xi)) for ti, xi in zip(t, x)], dtype=float)
    ec = entropic_clock(t, gvals, meta={"gamma_field": args.gamma_field})
    entropic_mon = check_monotonic(ec.tau_s)

    out_pi = visibility_from_phase_pi(phi_final_rad=0.0, T_s=float(args.tmax_s),
                                     t_s=t, dphi_dt_rad_s=np.zeros_like(t),
                                     gamma_t_x=gamma_field, x_path_m=x, diagnostics=True)

    csv_path = os.path.join(args.out, "shielding_trace.csv")
    with open(csv_path, "w", encoding="utf-8") as f:
        f.write("t_s,r_m,dtau_dt,tau_metric_s,gamma_s_inv,tau_ent_s\n")
        for i in range(len(t)):
            f.write(f"{t[i]:.9e},{r[i]:.9e},{dtau[i]:.9e},{mc.tau_s[i]:.9e},{gvals[i]:.9e},{ec.tau_s[i]:.9e}\n")

    meta = {
        "scene": ctx,
        "metric_mode": args.metric_mode,
        "observer_mode": args.observer_mode,
        "entropic_monotonic": bool(entropic_mon),
        "pi": out_pi,
    }
    with open(os.path.join(args.out, "shielding_meta.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2)

    print("Wrote:", csv_path)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
