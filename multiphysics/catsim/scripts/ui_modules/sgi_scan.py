"""SGI scan harness: measured-vs-predicted overlays from sgidb.

This harness compares paper-extracted measured curves (from sgidb.sqlite) against:
- baseline: SR proper-time proxy (run_gr_baseline)
- extended: CAT/EPT adapter via run_extended_backend (no equations re-derived here)

Outputs:
- overlay_*_baseline.csv
- overlay_*_extended.csv
- overlay_*_compare.csv (baseline vs extended residuals when backend=both)

Run via Makefile:
  make sgi_scan_fig6a
  make sgi_scan_fig6b
  make sgi_scan_fig8
"""

from __future__ import annotations

import argparse
from catsim_core.readout.registry import ReadoutContext, predict as predict_readout
import json
from pathlib import Path
import numpy as np
import pandas as pd

from .sgi_experiment_spec import SGIConfig, InitialState, template_split_mirror_recombine, template_four_pulse_close
from .sgi_worldlines_gr import simulate_1d_shaped, closure_metrics
from .sgi_closure_solver import solve_by_scaling_last_pulse, solve_by_two_pulse_durations
from .sgi_backend_bridge import run_gr_baseline, run_extended_backend

def _write_csv(path: Path, header, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    import csv
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(list(header))
        for r in rows:
            w.writerow(list(r))

def vis_from_phase(phi_rad: float) -> float:
    return float(0.5 * (1.0 + np.cos(phi_rad)))

def predict(cfg: SGIConfig, init: InitialState, *, dt_s: float, shape: str, ramp_frac: float, backend: str, ctx: dict) -> dict:
    world = simulate_1d_shaped(cfg, init, dt_s=float(dt_s), shape=shape, ramp_frac=float(ramp_frac))
    cm = closure_metrics(world)
    if backend == "extended":
        out = run_extended_backend(world, ctx)
        phi = float(out.get("d_phi_final_rad", 0.0))
        vis_classical = vis_from_phase(phi)
        vis = vis_classical
        vis_qutip = None
        vis_pi = None

        qbackend = ctx.get("quantum_backend")
        if qbackend in ("qutip", "path_integral"):
            # Time-grid support: prefer backend-provided d_phi_t_rad, else synthesize linear ramp
            t_s = np.asarray(world["arm_plus"].t_s, dtype=float)
            if isinstance(out.get("t_s"), (list, tuple, np.ndarray)) and isinstance(out.get("d_phi_t_rad"), (list, tuple, np.ndarray)):
                try:
                    t_s = np.asarray(out["t_s"], dtype=float)
                    phi_t = np.asarray(out["d_phi_t_rad"], dtype=float)
                except Exception:
                    phi_t = None
            else:
                phi_t = None
            if phi_t is None or phi_t.shape != t_s.shape:
                phi_t = np.linspace(0.0, float(phi), t_s.size)
            # dOmega ≈ d(phi)/dt on the time grid
            dOmega = np.gradient(phi_t, t_s, edge_order=1)

            T_s = float(t_s[-1])
            if qbackend == "qutip":
                from catsim_quantum.sgi_qutip_readout import predict_visibility_from_phase
                z = np.asarray(world["arm_plus"].z_m, dtype=float)
                x_path_m = np.stack([np.zeros_like(z), z, np.zeros_like(z)], axis=1)
                q = predict_visibility_from_phase(phi_final_rad=float(phi), T_s=T_s, context=ctx, t_s=t_s, dOmega=dOmega, x_path_m=x_path_m)
                vis_qutip = float(q["visibility_pred"])
                vis = vis_qutip
                out["qutip"] = q
            elif qbackend == "path_integral":
                from catsim_quantum.sgi_path_integral_readout import predict_visibility_from_phase
                z = np.asarray(world["arm_plus"].z_m, dtype=float)
                x_path_m = np.stack([np.zeros_like(z), z, np.zeros_like(z)], axis=1)
                q = predict_visibility_from_phase(phi_final_rad=float(phi), T_s=T_s, context=ctx, t_s=t_s, dOmega=dOmega, x_path_m=x_path_m)
                vis_pi = float(q["visibility_pred"])
                vis = vis_pi
                out["path_integral"] = q

        return {"backend":"extended","status":out.get("status","ok"),"closure": cm, "d_phi_final_rad": phi,
                "visibility_pred": vis,
                "visibility_pred_classical": vis_classical,
                "visibility_pred_qutip": vis_qutip,
                "visibility_pred_pi": vis_pi,
                "visibility_pred_classical": vis_classical,
                "visibility_pred_qutip": vis_qutip,
                "visibility_pred_path_integral": vis_pi,
                "raw": out}
    else:
        out = run_gr_baseline(world, mass_kg=cfg.mass_kg)
        phi = float(out.get("d_phi_final_rad", 0.0))
        return {"backend":"baseline","closure": cm, "d_phi_final_rad": phi, "visibility_pred": vis_from_phase(phi), "raw": out}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--sgidb", required=True)
    ap.add_argument("--scan", required=True, choices=["fig6a_dz","fig6b_dv","fig8_Td1"])
    ap.add_argument("--backend", default="both", choices=["baseline","extended","both"])
    ap.add_argument("--dt", type=float, default=1e-6)
    ap.add_argument("--mass-kg", type=float, default=1.0e-26)
    ap.add_argument("--mu-eff", type=float, default=9.2740100783e-24)
    ap.add_argument("--gravity", type=float, default=9.80665)
    ap.add_argument("--template", default="split_mirror_recombine", choices=["split_mirror_recombine","four_pulse_close"])
    ap.add_argument("--grad", type=float, default=200.0)
    ap.add_argument("--t1", type=float, default=0.002)
    ap.add_argument("--t2", type=float, default=0.002)
    ap.add_argument("--t3", type=float, default=0.002)
    ap.add_argument("--t4", type=float, default=0.002)
    ap.add_argument("--auto-close", action="store_true")
    ap.add_argument("--auto-close-mode", default="scale_last", choices=["scale_last","two_pulse"])
    ap.add_argument("--close-grid", type=int, default=81)
    ap.add_argument("--shape", default="none", choices=["none","tanh"])
    ap.add_argument("--ramp-frac", type=float, default=0.15)

    # Scene knobs (for spatial fields: bath density, gamma fields, BH placement)
    ap.add_argument("--scene-width-m", type=float, default=0.0)
    ap.add_argument("--scene-height-m", type=float, default=0.0)
    ap.add_argument("--scene-use-density-as-bath", action="store_true", help="If set, copy scene mass density into bath density if bath not explicitly set.")
    ap.add_argument("--matter-energy-density", type=float, default=0.0, help="Mean energy-density knob for matter region (J/m^3).")
    ap.add_argument("--matter-radius-m", type=float, default=0.0)
    ap.add_argument("--matter-placement", default="center", choices=["center","top","bottom","left","right","top_left","top_right","bottom_left","bottom_right"])
    ap.add_argument("--bh-mass-kg", type=float, default=0.0)
    ap.add_argument("--bh-radius-m", type=float, default=0.0)
    ap.add_argument("--bh-a-star", type=float, default=0.0)
    ap.add_argument("--bh-placement", default="center", choices=["center","top","bottom","left","right","top_left","top_right","bottom_left","bottom_right"])


    # extended backend context knobs (do not hardcode equations)
    ap.add_argument("--lambda0", type=float, default=None, help="Extended backend: lambda0 (s^-1) passed to adapter (overrides preset if set)")
    ap.add_argument("--lambda-preset", default="off", help="Extended backend: named lambda preset (see catsim_core.clock.lambda_presets)")
    ap.add_argument("--metric-mode", default="minkowski", choices=["minkowski","schwarzschild","kerr"], help="Extended backend: metric mode for redshift factor")
    ap.add_argument("--metric-a-star", type=float, default=0.0, help="Extended backend: Kerr spin parameter a* in [0,1).")
    ap.add_argument("--metric-theta-deg", type=float, default=90.0, help="Extended backend: polar angle theta (deg) for observers/fields.")
    ap.add_argument("--observer-mode", default="static", choices=["static","zamo"], help="Observer model for metric clock when supported.")
    ap.add_argument("--metric-mass-kg", type=float, default=5.972e24, help="Extended backend: mass for schwarzschild metric (kg)")

    # Quantum readout backend (optional QuTiP)
    ap.add_argument("--quantum-backend", default="none", choices=["none","qutip"], help="If qutip: compute visibility using path-qubit dephasing model (falls back if qutip missing).")
    ap.add_argument("--channel-preset", default="off", help="Quantum channel preset for dephasing (see catsim_quantum.channel_presets).")
    ap.add_argument("--gamma-phi", type=float, default=None, help="Override dephasing rate gamma_phi (1/s).")
    ap.add_argument("--quantum-mode", default="constant", choices=["constant","timegrid"], help="QuTiP readout mode. constant=use final phase+T; timegrid=construct a time grid (currently uniform rate) and call timegrid solver when available.")
    ap.add_argument("--bath-preset", default=None, help="Bath density preset for scaling dephasing (catsim_quantum.bath_models).")
    ap.add_argument("--bath-density", type=float, default=None, help="Override bath density (kg/m^3).")
    ap.add_argument("--bath-alpha", type=float, default=1.0, help="Bath scaling exponent alpha in gamma_eff = gamma_base*(rho/rho_ref)**alpha.")
    ap.add_argument("--bath-rho-ref", type=float, default=1.225, help="Reference density rho_ref (kg/m^3) for bath scaling.")

    # Multi-bath controls (optional; used by qutip timegrid backend when available)
    ap.add_argument("--bath-model", default="dephasing_only", choices=["dephasing_only","dephasing_relax_excite"])
    ap.add_argument("--bath-density-scale", type=float, default=1.0)
    ap.add_argument("--bath-dephasing-frac", type=float, default=1.0)
    ap.add_argument("--bath-relax-frac", type=float, default=0.0)
    ap.add_argument("--bath-excite-frac", type=float, default=0.0)
    ap.add_argument("--bath-density-field", default="constant", choices=["scene","constant"])
    ap.add_argument("--bath-density-background", type=float, default=1.0)


    args = ap.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    from scripts.sgi_db import export_all
    meas_dir = out_dir / "meas_sgi_db"
    mapping = export_all(Path(args.sgidb), meas_dir)

    def make_cfg(pulses):
        return SGIConfig(gravity_m_per_s2=float(args.gravity),
                         mu_eff_J_per_T=float(args.mu_eff),
                         mass_kg=float(args.mass_kg),
                         pulses=pulses)

    def tune(cfg: SGIConfig):
        if not args.auto_close or not cfg.pulses:
            return cfg, None
        init0 = InitialState(z0_m=0.0, v0_m_per_s=0.0)
        if args.auto_close_mode == "two_pulse" and len(cfg.pulses) >= 2:
            res = solve_by_two_pulse_durations(cfg, init0, dt_s=float(args.dt), n_grid=int(args.close_grid))
        else:
            res = solve_by_scaling_last_pulse(cfg, init0, dt_s=float(args.dt), n_grid=int(args.close_grid))
        cfg2 = SGIConfig(axis=cfg.axis, gravity_m_per_s2=cfg.gravity_m_per_s2, mu_eff_J_per_T=cfg.mu_eff_J_per_T, mass_kg=cfg.mass_kg, pulses=res.pulses)
        info = {"mode": args.auto_close_mode, "best_metrics": res.metrics}
        return cfg2, info

    from catsim_core.clock.lambda_presets import resolve_lambda0
    lam0 = resolve_lambda0(lambda0=args.lambda0, lambda_preset=args.lambda_preset)
    ctx = {"mass_kg": float(args.mass_kg), "lambda0": float(lam0), "lambda_preset": str(args.lambda_preset), "metric_mode": str(args.metric_mode), "metric_mass_kg": float(args.metric_mass_kg), "metric_a_star": float(getattr(args,"metric_a_star",0.0)), "metric_theta_rad": (None if getattr(args,"metric_theta_deg",None) is None else float(getattr(args,"metric_theta_deg"))*3.141592653589793/180.0), "observer_mode": getattr(args,"observer_mode",None), "quantum_backend": str(args.quantum_backend), "channel_preset": str(args.channel_preset), "gamma_phi": args.gamma_phi, "quantum_mode": str(args.quantum_mode), "bath_preset": args.bath_preset, "bath_density": args.bath_density, "bath_alpha": float(args.bath_alpha), "bath_rho_ref": float(args.bath_rho_ref)}

    meta = {"scan": args.scan, "measured_tables": mapping, "backend": args.backend, "context": ctx}

    # Build scene context (optional)
    if args.scene_width_m > 0.0 and args.scene_height_m > 0.0:
        from catsim_core.spacetime.scene import RectRegion, MatterRegion, BlackHoleSpec, Scene
        reg = RectRegion(width_m=float(args.scene_width_m), height_m=float(args.scene_height_m))
        matter = None
        if args.matter_energy_density > 0.0:
            matter = MatterRegion(placement=str(args.matter_placement), radius_m=float(args.matter_radius_m), mean_energy_density_J_m3=float(args.matter_energy_density))
        bh = None
        if args.bh_mass_kg > 0.0:
            bh = BlackHoleSpec(placement=str(args.bh_placement), mass_kg=float(args.bh_mass_kg), a_star=float(args.bh_a_star), radius_m=float(args.bh_radius_m))
        scene = Scene(region=reg, matter=matter, black_hole=bh)
        ctx.update(scene.to_context())
        if args.scene_use_density_as_bath and ("bath_density_kg_m3" not in ctx or ctx.get("bath_density_kg_m3") is None):
            if "scene_mass_density_kg_m3" in ctx:
                ctx["bath_density_kg_m3"] = float(ctx["scene_mass_density_kg_m3"])


        (out_dir/"run_manifest.json").write_text(json.dumps(meta, indent=2, sort_keys=True), encoding="utf-8")

    def do_backends(cfg, init, meas_tuple):
        # returns dict backend->(vis_pred, phi, status)
        out={}
        if args.backend in ("baseline","both"):
            pb = predict(cfg, init, dt_s=args.dt, shape=args.shape, ramp_frac=args.ramp_frac, backend="baseline", ctx=ctx)
            out["baseline"]=pb
        if args.backend in ("extended","both"):
            pe = predict(cfg, init, dt_s=args.dt, shape=args.shape, ramp_frac=args.ramp_frac, backend="extended", ctx=ctx)
            out["extended"]=pe
        return out

    if args.scan == "fig6a_dz":
        df = pd.read_csv(meas_dir/"fig6a_visibility_vs_dz.csv")
        pulses = template_split_mirror_recombine(args.grad, args.t1, args.t2, args.t3) if args.template=="split_mirror_recombine" else template_four_pulse_close(args.grad, args.t1, args.t2, args.t3, args.t4)
        cfg, close_info = tune(make_cfg(pulses))
        meta["closure_tuning"] = close_info

        rows_b=[]; rows_e=[]; rows_c=[]
        for _,r in df.iterrows():
            dz_um=float(r["delta_z_um"]); vis=float(r["visibility"]); err=float(r["err"]) if "err" in df.columns else float("nan")
            init = InitialState(z0_m=dz_um*1e-6, v0_m_per_s=0.0)
            outs = do_backends(cfg, init, (dz_um,vis,err))
            if "baseline" in outs:
                ob=outs["baseline"]; vb=ob["visibility_pred"]; phib=ob["d_phi_final_rad"]
                rows_b.append((dz_um, vis, err, vb, vb, float("nan"), phib, vis - vb))
            if "extended" in outs:
                oe=outs["extended"]; ve=oe["visibility_pred"]; phie=oe["d_phi_final_rad"]
                rows_e.append((dz_um, vis, err, ve, float(oe.get("visibility_pred_classical", float("nan"))), float(oe.get("visibility_pred_qutip", float("nan"))), phie, vis - ve, oe.get("status","ok")))
            if "baseline" in outs and "extended" in outs:
                rows_c.append((dz_um, (vis - outs["baseline"]["visibility_pred"]), (vis - outs["extended"]["visibility_pred"])))

        if rows_b: _write_csv(out_dir/"overlay_fig6a_dz_baseline.csv", ["delta_z_um","visibility_meas","err","visibility_pred","visibility_pred_classical","visibility_pred_qutip","d_phi_final_rad","residual_meas_minus_pred"], rows_b)
        if rows_e: _write_csv(out_dir/"overlay_fig6a_dz_extended.csv", ["delta_z_um","visibility_meas","err","visibility_pred","visibility_pred_classical","visibility_pred_qutip","d_phi_final_rad","residual_meas_minus_pred","status"], rows_e)
        if rows_c: _write_csv(out_dir/"overlay_fig6a_dz_compare.csv", ["delta_z_um","residual_baseline","residual_extended"], rows_c)

    elif args.scan == "fig6b_dv":
        df = pd.read_csv(meas_dir/"fig6b_visibility_vs_dv.csv")
        pulses = template_split_mirror_recombine(args.grad, args.t1, args.t2, args.t3) if args.template=="split_mirror_recombine" else template_four_pulse_close(args.grad, args.t1, args.t2, args.t3, args.t4)
        cfg, close_info = tune(make_cfg(pulses))
        meta["closure_tuning"] = close_info

        rows_b=[]; rows_e=[]; rows_c=[]
        for _,r in df.iterrows():
            dv=float(r["delta_v_mm_s"]); vis=float(r["visibility"]); err=float(r["err"]) if "err" in df.columns else float("nan")
            init = InitialState(z0_m=0.0, v0_m_per_s=dv*1e-3)
            outs = do_backends(cfg, init, (dv,vis,err))
            if "baseline" in outs:
                ob=outs["baseline"]; vb=ob["visibility_pred"]; phib=ob["d_phi_final_rad"]
                rows_b.append((dv, vis, err, vb, vb, float("nan"), phib, vis - vb))
            if "extended" in outs:
                oe=outs["extended"]; ve=oe["visibility_pred"]; phie=oe["d_phi_final_rad"]
                rows_e.append((dv, vis, err, ve, float(oe.get("visibility_pred_classical", float("nan"))), float(oe.get("visibility_pred_qutip", float("nan"))), phie, vis - ve, oe.get("status","ok")))
            if "baseline" in outs and "extended" in outs:
                rows_c.append((dv, (vis - outs["baseline"]["visibility_pred"]), (vis - outs["extended"]["visibility_pred"])))

        if rows_b: _write_csv(out_dir/"overlay_fig6b_dv_baseline.csv", ["delta_v_mm_s","visibility_meas","err","visibility_pred","visibility_pred_classical","visibility_pred_qutip","d_phi_final_rad","residual_meas_minus_pred"], rows_b)
        if rows_e: _write_csv(out_dir/"overlay_fig6b_dv_extended.csv", ["delta_v_mm_s","visibility_meas","err","visibility_pred","visibility_pred_classical","visibility_pred_qutip","d_phi_final_rad","residual_meas_minus_pred","status"], rows_e)
        if rows_c: _write_csv(out_dir/"overlay_fig6b_dv_compare.csv", ["delta_v_mm_s","residual_baseline","residual_extended"], rows_c)

    else:
        df = pd.read_csv(meas_dir/"fig8_visibility_vs_Td1.csv")
        rows_sb=[]; rows_se=[]; rows_sc=[]
        rows_fb=[]; rows_fe=[]; rows_fc=[]
        for _,r in df.iterrows():
            Td1=float(r["Td1_us"]); t1 = Td1*1e-6
            vis_s=float(r["vis_splitstop"]); err_s=float(r["err_splitstop"])
            vis_f=float(r["vis_fullloop"]); err_f=float(r["err_fullloop"])

            cfg_s, _ = tune(make_cfg(template_split_mirror_recombine(args.grad, t1, args.t2, args.t3)))
            outs_s = do_backends(cfg_s, InitialState(0.0,0.0), None)
            if "baseline" in outs_s:
                vb=outs_s["baseline"]["visibility_pred"]; phib=outs_s["baseline"]["d_phi_final_rad"]
                rows_sb.append((Td1, vis_s, err_s, vb, phib, vis_s - vb))
            if "extended" in outs_s:
                ve=outs_s["extended"]["visibility_pred"]; phie=outs_s["extended"]["d_phi_final_rad"]; st=outs_s["extended"].get("status","ok")
                rows_se.append((Td1, vis_s, err_s, ve, phie, vis_s - ve, st))
            if "baseline" in outs_s and "extended" in outs_s:
                rows_sc.append((Td1, (vis_s - outs_s["baseline"]["visibility_pred"]), (vis_s - outs_s["extended"]["visibility_pred"])))

            cfg_f, _ = tune(make_cfg(template_four_pulse_close(args.grad, t1, args.t2, args.t3, args.t4)))
            outs_f = do_backends(cfg_f, InitialState(0.0,0.0), None)
            if "baseline" in outs_f:
                vb=outs_f["baseline"]["visibility_pred"]; phib=outs_f["baseline"]["d_phi_final_rad"]
                rows_fb.append((Td1, vis_f, err_f, vb, phib, vis_f - vb))
            if "extended" in outs_f:
                ve=outs_f["extended"]["visibility_pred"]; phie=outs_f["extended"]["d_phi_final_rad"]; st=outs_f["extended"].get("status","ok")
                rows_fe.append((Td1, vis_f, err_f, ve, phie, vis_f - ve, st))
            if "baseline" in outs_f and "extended" in outs_f:
                rows_fc.append((Td1, (vis_f - outs_f["baseline"]["visibility_pred"]), (vis_f - outs_f["extended"]["visibility_pred"])))

        if rows_sb: _write_csv(out_dir/"overlay_fig8_splitstop_baseline.csv", ["Td1_us","visibility_meas","err","visibility_pred","d_phi_final_rad","residual_meas_minus_pred"], rows_sb)
        if rows_se: _write_csv(out_dir/"overlay_fig8_splitstop_extended.csv", ["Td1_us","visibility_meas","err","visibility_pred","d_phi_final_rad","residual_meas_minus_pred","status"], rows_se)
        if rows_sc: _write_csv(out_dir/"overlay_fig8_splitstop_compare.csv", ["Td1_us","residual_baseline","residual_extended"], rows_sc)

        if rows_fb: _write_csv(out_dir/"overlay_fig8_fullloop_baseline.csv", ["Td1_us","visibility_meas","err","visibility_pred","d_phi_final_rad","residual_meas_minus_pred"], rows_fb)
        if rows_fe: _write_csv(out_dir/"overlay_fig8_fullloop_extended.csv", ["Td1_us","visibility_meas","err","visibility_pred","d_phi_final_rad","residual_meas_minus_pred","status"], rows_fe)
        if rows_fc: _write_csv(out_dir/"overlay_fig8_fullloop_compare.csv", ["Td1_us","residual_baseline","residual_extended"], rows_fc)

    (out_dir/"scan_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")

if __name__ == "__main__":
    main()
