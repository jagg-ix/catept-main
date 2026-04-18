import json
from pathlib import Path

import pandas as pd
import plotly.express as px
import streamlit as st
import subprocess

st.title("Stern–Gerlach Interferometer (Harness)")

repo_root = Path(__file__).resolve().parents[1].parents[0]  # ui/pages -> ui -> repo

st.markdown("""This page is an **experiment harness** for a full-loop SGI.
It generates GR/SR baseline trajectories and invokes any **extended backend**
already present in the repository via adapters.

**Important:** This UI does not re-implement CAT/EPT equations. Extended behavior
must come from existing repo modules (through the backend bridge).
""")

st.markdown("## Controls")
out_dir = st.text_input("Output directory", value=str(repo_root/"PAPER_TABLES/ADVANCED/UI/SGI/run_001"))
dt = st.number_input("dt (s)", min_value=1e-9, value=1e-6, format="%.6g")
mass_kg = st.number_input("mass (kg)", min_value=1e-30, value=1.0e-26, format="%.6g")
mu_eff = st.number_input("mu_eff (J/T)", min_value=0.0, value=9.2740100783e-24, format="%.6g")
gravity = st.number_input("gravity (m/s^2)", value=9.80665, format="%.6g")
init_z = st.number_input("z0 (m)", value=0.0, format="%.6g")
init_v = st.number_input("v0 (m/s)", value=0.0, format="%.6g")
template = st.selectbox("Pulse template", ["custom","split_mirror_recombine","four_pulse_close"], index=0)
grad = st.number_input("Template base gradient (T/m)", value=200.0, format="%.6g")
t1 = st.number_input("t1 (s)", value=0.002, format="%.6g")
t2 = st.number_input("t2 (s)", value=0.002, format="%.6g")
t3 = st.number_input("t3 (s)", value=0.002, format="%.6g")
t4 = st.number_input("t4 (s)", value=0.002, format="%.6g")
pulses = st.text_input("Custom pulses grad_T/m:duration_s (comma-separated)",
                       value="+200:0.002,-200:0.002,+200:0.002")
auto_close = st.checkbox("Auto-tune pulse durations for closure (GR baseline)", value=False)
auto_close_mode = st.selectbox("Auto-close mode", ["scale_last","two_pulse"], index=0)
close_grid = st.slider("Closure solver grid", min_value=21, max_value=151, value=81, step=10)
shape = st.selectbox("Pulse edge shape", ["none","tanh"], index=0)
ramp_frac = st.slider("Ramp fraction (tanh)", min_value=0.05, max_value=0.45, value=0.15, step=0.05)

run_extended = st.checkbox("Run extended backend (via adapters)", value=False)
context_json = st.text_area("Extended backend context (JSON string or file path)", value="{}")

st.markdown("## Run")
if st.button("Run SGI harness"):
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    cmd = [
        "python", "-m", "scripts.ui_modules.sgi_run",
        "--out", out_dir,
        "--dt", str(dt),
        "--mass-kg", str(mass_kg),
        "--mu-eff", str(mu_eff),
        "--gravity", str(gravity),
        "--init-z", str(init_z),
        "--init-v", str(init_v),
        "--template", template,
        "--grad", str(grad),
        "--t1", str(t1),
        "--t2", str(t2),
        "--t3", str(t3),
        "--t4", str(t4),
        "--pulses", pulses,
        "--shape", str(shape),
        "--ramp-frac", str(ramp_frac),
    ]
    if auto_close:
        cmd += ["--auto-close", "--auto-close-mode", auto_close_mode, "--close-grid", str(close_grid)]
    if run_extended:
        cmd += ["--run-extended", "--context-json", context_json]
    p = subprocess.run(cmd, cwd=str(repo_root), capture_output=True, text=True)
    if p.returncode != 0:
        st.error("Run failed")
        st.code(p.stderr)
    else:
        st.success("Run complete")
        if p.stdout.strip():
            st.code(p.stdout)

st.markdown("## Load run")
manifest_path = Path(out_dir)/"run_manifest.json"
if not manifest_path.exists():
    st.info("Run first to generate artifacts.")
    st.stop()

man = json.loads(manifest_path.read_text())
st.json(man)

arm_plus = Path(man["artifacts"]["arm_plus_csv"])
arm_minus = Path(man["artifacts"]["arm_minus_csv"])
summary = json.loads(Path(man["artifacts"]["summary_json"]).read_text())

st.markdown("## Trajectories")
if arm_plus.exists() and arm_minus.exists():
    a = pd.read_csv(arm_plus); b = pd.read_csv(arm_minus)
    a["arm"] = "plus"; b["arm"] = "minus"
    df = pd.concat([a,b], ignore_index=True)

    fig = px.line(df, x="t_s", y="z_m", color="arm", title="z(t) arms")
    st.plotly_chart(fig, use_container_width=True)
    fig = px.line(df, x="t_s", y="v_m_per_s", color="arm", title="v(t) arms")
    st.plotly_chart(fig, use_container_width=True)

st.markdown("## Closure metrics")
st.json(summary.get("closure", {}))
if summary.get("closure_tuning"):
    st.markdown("### Closure tuning")
    st.json(summary.get("closure_tuning"))

st.markdown("### Closure solver plots")

st.markdown("### Paper-extracted curves (from sgidb)")

st.markdown("### Measured vs predicted overlays (scan harness)")
overlay_files = sorted(run_dir.glob("overlay_*.csv"))
if overlay_files:
    names = [p.name for p in overlay_files]
    sel_overlay = st.selectbox("Select overlay file", names, index=0, key="sgi_overlay_select")
    dfo = pd.read_csv(run_dir/sel_overlay)
    st.dataframe(dfo, use_container_width=True)

    def _pred_cols(dfo: pd.DataFrame):
        cols = ["visibility_pred"]
        if "visibility_pred_classical" in dfo.columns:
            cols = ["visibility_pred_classical"]
            if "visibility_pred_qutip" in dfo.columns and dfo["visibility_pred_qutip"].notna().any():
                cols = cols + ["visibility_pred_qutip"]
        return cols

    if sel_overlay.startswith("overlay_fig6a") and {"delta_z_um","visibility_meas","visibility_pred"}.issubset(dfo.columns):
        fig = px.line(dfo, x="delta_z_um", y=["visibility_meas"] + _pred_cols(dfo), title="Fig 6A overlay: measured vs predicted")
        st.plotly_chart(fig, use_container_width=True)
    elif sel_overlay.startswith("overlay_fig6b") and {"delta_v_mm_s","visibility_meas","visibility_pred"}.issubset(dfo.columns):
        fig = px.line(dfo, x="delta_v_mm_s", y=["visibility_meas"] + _pred_cols(dfo), title="Fig 6B overlay: measured vs predicted")
        st.plotly_chart(fig, use_container_width=True)
    elif sel_overlay.endswith("_compare.csv") and {"residual_baseline","residual_extended"}.issubset(dfo.columns):
        xcol = [c for c in dfo.columns if c not in ("residual_baseline","residual_extended")][0]
        fig = px.line(dfo, x=xcol, y=["residual_baseline","residual_extended"], title=f"Residual comparison (baseline vs extended): {sel_overlay}")
        st.plotly_chart(fig, use_container_width=True)
    elif sel_overlay.startswith("overlay_fig8") and {"Td1_us","visibility_meas","visibility_pred"}.issubset(dfo.columns):
        fig = px.line(dfo, x="Td1_us", y=["visibility_meas"] + _pred_cols(dfo), title=f"Fig 8 overlay: {sel_overlay}")
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("No specialized overlay plot for this file; showing table only.")
else:
    st.info("No overlay CSVs found in this run folder. Generate with make sgi_scan_fig6a / sgi_scan_fig6b / sgi_scan_fig8.")
meas_dir = Path(man["artifacts"].get("meas_sgi_db_dir",""))
if meas_dir.exists():
    csvs = sorted(meas_dir.glob("*.csv"))
    if csvs:
        names = [c.stem for c in csvs]
        default_idx = names.index("fig8_visibility_vs_Td1") if "fig8_visibility_vs_Td1" in names else 0
        sel = st.selectbox("Select measured table", names, index=default_idx)
        dfm = pd.read_csv(meas_dir/f"{sel}.csv")
        st.dataframe(dfm, use_container_width=True)
        if sel == "fig6a_visibility_vs_dz" and {"delta_z_um","visibility"}.issubset(dfm.columns):
            st.plotly_chart(px.scatter(dfm, x="delta_z_um", y="visibility", error_y="err" if "err" in dfm.columns else None,
                                       title="Fig 6A: visibility vs Δz (paper-extracted)"),
                            use_container_width=True)
        elif sel == "fig6b_visibility_vs_dv" and {"delta_v_mm_s","visibility"}.issubset(dfm.columns):
            st.plotly_chart(px.scatter(dfm, x="delta_v_mm_s", y="visibility", error_y="err" if "err" in dfm.columns else None,
                                       title="Fig 6B: visibility vs Δv (paper-extracted)"),
                            use_container_width=True)
        elif sel == "fig8_visibility_vs_Td1" and {"Td1_us","vis_splitstop","vis_fullloop"}.issubset(dfm.columns):
            fig = px.line(dfm, x="Td1_us", y=["vis_splitstop","vis_fullloop"], title="Fig 8: visibility vs Td1 (paper-extracted)")
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No specialized plot for this table (showing data only).")
    else:
        st.info("No measured CSVs found in meas_sgi_db/.")
else:
    st.info("No sgidb export present for this run. Run with --sgidb data/sgi/sgidb.sqlite (or make sgi_repro).")

hist_path = Path(man["artifacts"].get("closure_solver_history_csv",""))
if hist_path.exists():
    h = pd.read_csv(hist_path)
    # Prefer plot vs scale when present
    if "scale" in h.columns:
        fig = px.line(h, x="scale", y=["obj","dz_final_m","dv_final_m_per_s"] if "obj" in h.columns else h.columns, title="Closure scan (scale_last)")
        st.plotly_chart(fig, use_container_width=True)
    elif "scale_a" in h.columns and "scale_b" in h.columns and "obj" in h.columns:
        fig = px.density_heatmap(h, x="scale_a", y="scale_b", z="obj", histfunc="avg", title="Closure scan objective (two_pulse)")
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.dataframe(h.head(50))
else:
    st.info("No solver history CSV found (enable auto-close).")

st.markdown("## GR baseline")
gr = summary.get("gr_baseline", {})
if "tau_plus_s" in gr and "tau_minus_s" in gr:
    t = pd.read_csv(arm_plus)["t_s"]
    df_tau = pd.DataFrame({"t_s": t, "tau_plus_s": gr["tau_plus_s"], "tau_minus_s": gr["tau_minus_s"]})
    fig = px.line(df_tau, x="t_s", y=["tau_plus_s","tau_minus_s"], title="Proper time accumulation (baseline)")
    st.plotly_chart(fig, use_container_width=True)
st.json({k:v for k,v in gr.items() if k not in ("tau_plus_s","tau_minus_s")})

st.markdown("## Extended backend output")
st.json(summary.get("extended", {}))
