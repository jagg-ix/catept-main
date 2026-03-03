import streamlit as st
from pathlib import Path
import json
import subprocess
import time
import pandas as pd
import plotly.express as px

from ui.common.run_pipeline import run_make

st.set_page_config(page_title="Double slit", layout="wide")
st.title("Double-slit module (temporal dataset)")

repo_root = Path(__file__).resolve().parents[2]
runs_root = repo_root / "PAPER_TABLES" / "ADVANCED" / "UI" / "DOUBLE_SLIT"

st.markdown("## Data source (SQLite)")
default_db = str(repo_root / "data_pipeline" / "user_scripts" / "double_slit.sqlite3")
db_path = st.text_input("DB path", value=default_db)

st.markdown("### Experiment selection")
# Try to list experiments via existing helper (if db exists)
exp_options = ["1"]
try:
    from cat_ept_doubleslit.db import list_experiments
    exps = list_experiments(db_path)
    # show "id: figure_ref" labels if available
    exp_options = []
    for e in exps:
        # Experiment dataclass typically has id and figure_ref/ref
        label = f"{getattr(e,'id', '??')}"
        ref = getattr(e,'figure_ref', None) or getattr(e,'ref', None)
        if ref:
            label += f" ({ref})"
        exp_options.append(label)
except Exception:
    pass

exp_choice = st.selectbox("Experiment (id or ref)", exp_options, index=0)
# parse id from "id (...)" label
exp_arg = exp_choice.split(" ",1)[0].strip()
if "(" in exp_arg:
    exp_arg = exp_arg.split("(")[0].strip()


st.markdown("## Physics predictor (multilayer)")
physics_enabled = st.checkbox("Enable physics predictor for this run", value=True)
eps_table = st.text_input("ε-table CSV path", value=str(repo_root / "data" / "materials" / "ITO_eps_table_proxy.csv"))
film_thickness_m = st.number_input("Film thickness (m)", min_value=1e-9, value=300e-9, format="%.6g")
substrate_n = st.number_input("Substrate refractive index n_sub", min_value=1.0, value=1.5, format="%.6g")
substrate_eps_table = st.text_input("Optional substrate ε-table CSV path (leave blank for constant n)", value="")
stack_json = st.text_input("Optional stack JSON spec (leave blank to use air|film|substrate)", value="")
preset = st.selectbox("Time-trace preset", ["tirole_default","custom"], index=0)
time_trace_mode = st.selectbox("Compare measured time trace against", ["auto","mag","field"], index=0)
nfft = st.selectbox("NFFT (time-trace)", [2048,4096,8192,16384], index=1)
window = st.selectbox("Window", ["hann","none"], index=0)
auto_time_shift = st.checkbox("Auto time-shift alignment (cross-correlation)", value=True)

st.markdown("## Run")
c1, c2, c3 = st.columns(3)

st.markdown("### Physics predictor (eps-table slab optics)")
physics_enabled = st.checkbox("Enable physics predictor", value=False)
eps_table = st.text_input("eps-table CSV", value=str(repo_root / "data" / "materials" / "ITO_eps_table_proxy.csv"))
slab_thickness_m = st.number_input("Slab thickness (m)", min_value=1e-12, value=200e-9, format="%.6g")
physics_nfft = st.number_input("Physics NFFT", min_value=256, value=4096, step=256)

def run_double_slit_cli():
    ts = time.strftime("run_%Y%m%d_%H%M%S")
    out_dir = runs_root / ts
    out_dir.mkdir(parents=True, exist_ok=True)
    cmd = [
        "python", "-m", "scripts.ui_modules.double_slit_run",
        "--db", db_path,
        "--experiment", exp_arg,
        "--out", str(out_dir),
    ]
    if physics_enabled:
        cmd += ["--physics-enabled", "--eps-table-csv", eps_table, "--slab-thickness-m", str(slab_thickness_m), "--physics-nfft", str(int(physics_nfft))]

    p = subprocess.run(cmd, cwd=str(repo_root), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return out_dir, p.returncode, p.stdout, p.stderr

if c1.button("New run (extract measured + baseline pred)"):
    out_dir, rc, so, se = run_double_slit_cli()
    st.code(so or "", language="text")
    if rc != 0:
        st.error(f"Failed (rc={rc}).")
        st.code(se or "", language="text")
    else:
        st.success(f"Done: {out_dir}")

if c2.button("Run paper reproduction (make repro_from_xlsx)"):
    res = run_make("repro_from_xlsx", repo_root=repo_root)
    st.code(res.stdout or "", language="text")
    if res.returncode != 0:
        st.error("Failed.")
        st.code(res.stderr or "", language="text")
    else:
        st.success("Done.")

if c3.button("Baseline (fixed run_001 via Make)"):
    res = run_make("run_double_slit", repo_root=repo_root)
    st.code(res.stdout or "", language="text")
    if res.returncode != 0:
        st.error("Failed.")
        st.code(res.stderr or "", language="text")
    else:
        st.success("Done.")

st.markdown("## Select a run (manifest-driven)")
manifests = sorted(runs_root.glob("**/run_manifest.json"), key=lambda p: p.stat().st_mtime, reverse=True) if runs_root.exists() else []
if not manifests:
    st.info("No runs found yet. Click 'New run'.")
    st.stop()

labels = [str(p.parent.relative_to(runs_root)) for p in manifests]
choice = st.selectbox("Run directory", labels, index=0)
man_path = manifests[labels.index(choice)]
man = json.loads(man_path.read_text())
st.caption(str(man_path))
st.json(man)


# Show physics metrics summary if available
try:
    summary_path = Path(man["artifacts"].get("summary_json",""))
    if summary_path.exists():
        summ = json.loads(summary_path.read_text())
        pm = summ.get("physics_metrics", {})
        if pm:
            st.markdown("### Physics metrics")
            if "time_trace_mode_auto_best" in pm:
                st.success(f"Auto-selected time-trace mode: **{pm['time_trace_mode_auto_best']}**")
            st.json(pm)
except Exception:
    pass



st.markdown("## Plots")

# measured spectra
spec_path = Path(man["artifacts"].get("meas_spectra_csv",""))
if spec_path.exists():
    df = pd.read_csv(spec_path)
    if "frequency_thz" in df.columns:
        fig = px.line(df, x="frequency_thz", y="intensity", title="Measured spectra (from SQLite)")
        st.plotly_chart(fig, use_container_width=True)
else:
    st.info("Measured spectra not present for this run (or extraction failed).")

# measured time domain
td_path = Path(man["artifacts"].get("meas_time_domain_csv",""))
if td_path.exists():
    df = pd.read_csv(td_path)
    if "delay_fs" in df.columns:
        fig = px.line(df, x="delay_fs", y="reflectivity", title="Measured time-domain trace (from SQLite)")
        st.plotly_chart(fig, use_container_width=True)
else:
    st.info("Measured time-domain trace not present for this run (or extraction failed).")



st.markdown("## Measured vs Predicted overlays (physics predictor)")
pred_spec_p = Path(man["artifacts"].get("pred_spectra_physics_csv",""))
if spec_path.exists() and pred_spec_p.exists():
    ms = pd.read_csv(spec_path).rename(columns={"intensity":"measured"})
    ps = pd.read_csv(pred_spec_p).rename(columns={"intensity_pred":"predicted"})
    if "frequency_thz" in ms.columns and "frequency_thz" in ps.columns:
        dfj = ms.merge(ps, on="frequency_thz", how="inner")
        fig = px.line(dfj, x="frequency_thz", y=["measured","predicted"], title="Spectra: measured vs predicted (physics slab model)")
        st.plotly_chart(fig, use_container_width=True)

res_spec_p = Path(man["artifacts"].get("residuals_spectra_physics_csv",""))
if res_spec_p.exists():
    dr = pd.read_csv(res_spec_p)
    if "frequency_thz" in dr.columns:
        fig = px.line(dr, x="frequency_thz", y=dr.columns[-1], title="Spectra residuals (physics, meas - affine(pred))")
        st.plotly_chart(fig, use_container_width=True)

pred_td_p = Path(man["artifacts"].get("pred_time_domain_physics_csv",""))
if td_path.exists() and pred_td_p.exists():
    mt = pd.read_csv(td_path).rename(columns={"reflectivity":"measured"})
    pt = pd.read_csv(pred_td_p).rename(columns={"reflectivity_pred":"predicted"})
    if "delay_fs" in mt.columns and "delay_fs" in pt.columns:
        dfj = mt.merge(pt, on="delay_fs", how="inner")
        fig = px.line(dfj, x="delay_fs", y=["measured","predicted"], title="Time-domain: measured vs predicted (physics, IFFT of r(ω))")
        st.plotly_chart(fig, use_container_width=True)

res_td_p = Path(man["artifacts"].get("residuals_time_domain_physics_csv",""))
if res_td_p.exists():
    dr = pd.read_csv(res_td_p)
    if "delay_fs" in dr.columns:
        fig = px.line(dr, x="delay_fs", y=dr.columns[-1], title="Time-domain residuals (physics, meas - affine(pred))")
        st.plotly_chart(fig, use_container_width=True)


st.markdown("## Measured vs Predicted overlays (baseline smoothing)")
# spectra overlay
pred_spec = Path(man["artifacts"].get("pred_spectra_csv",""))
if spec_path.exists() and pred_spec.exists():
    ms = pd.read_csv(spec_path)
    ps = pd.read_csv(pred_spec)
    if "frequency_thz" in ms.columns and "frequency_thz" in ps.columns:
        dfm = ms.rename(columns={"intensity":"measured"})
        dfp = ps.rename(columns={"intensity_pred":"predicted"})
        dfj = dfm.merge(dfp, on="frequency_thz", how="inner")
        fig = px.line(dfj, x="frequency_thz", y=["measured","predicted"], title="Spectra: measured vs predicted (polyfit baseline)")
        st.plotly_chart(fig, use_container_width=True)
# spectra residuals
res_spec = Path(man["artifacts"].get("residuals_spectra_csv",""))
if res_spec.exists():
    dr = pd.read_csv(res_spec)
    if "frequency_thz" in dr.columns:
        fig = px.line(dr, x="frequency_thz", y="residual_meas_minus_pred", title="Spectra residuals (meas - pred)")
        st.plotly_chart(fig, use_container_width=True)

# time-domain overlay
pred_td = Path(man["artifacts"].get("pred_time_domain_csv",""))
if td_path.exists() and pred_td.exists():
    mt = pd.read_csv(td_path).rename(columns={"reflectivity":"measured"})
    pt = pd.read_csv(pred_td).rename(columns={"reflectivity_pred":"predicted"})
    if "delay_fs" in mt.columns and "delay_fs" in pt.columns:
        dfj = mt.merge(pt, on="delay_fs", how="inner")
        fig = px.line(dfj, x="delay_fs", y=["measured","predicted"], title="Time-domain: measured vs predicted (polyfit baseline)")
        st.plotly_chart(fig, use_container_width=True)

res_td = Path(man["artifacts"].get("residuals_time_domain_csv",""))
if res_td.exists():
    dr = pd.read_csv(res_td)
    if "delay_fs" in dr.columns:
        fig = px.line(dr, x="delay_fs", y="residual_meas_minus_pred", title="Time-domain residuals (meas - pred)")
        st.plotly_chart(fig, use_container_width=True)

# baseline pred intensity (placeholder)
pred_path = Path(man["artifacts"].get("pred_intensity_csv",""))
if pred_path.exists():
    df = pd.read_csv(pred_path)
    if "x_m" in df.columns:
        fig = px.line(df, x="x_m", y="I_pred", title="Baseline spatial prediction I(x) [placeholder]")
        st.plotly_chart(fig, use_container_width=True)
else:
    st.info("Baseline prediction not present.")


st.markdown("## Physics overlays (multilayer)")
psp = Path(man["artifacts"].get("pred_spectra_physics_csv",""))
rsp = Path(man["artifacts"].get("residuals_spectra_physics_csv",""))
ptp_field = Path(man["artifacts"].get("pred_time_domain_physics_field_csv",""))
ptp_mag = Path(man["artifacts"].get("pred_time_domain_physics_mag_csv",""))
rtp = Path(man["artifacts"].get("residuals_time_domain_physics_csv",""))

if spec_path.exists() and psp.exists():
    ms = pd.read_csv(spec_path).rename(columns={"intensity":"measured"})
    ps = pd.read_csv(psp).rename(columns={"intensity_pred":"predicted"})
    if "frequency_thz" in ms.columns and "frequency_thz" in ps.columns:
        dfj = ms.merge(ps, on="frequency_thz", how="inner")
        fig = px.line(dfj, x="frequency_thz", y=["measured","predicted"], title="Spectra: measured vs physics (multilayer)")
        st.plotly_chart(fig, use_container_width=True)
if rsp.exists():
    dr = pd.read_csv(rsp)
    if "frequency_thz" in dr.columns:
        fig = px.line(dr, x="frequency_thz", y=dr.columns[-1], title="Spectra residuals (meas - affine(pred)) [physics]")
        st.plotly_chart(fig, use_container_width=True)

if td_path.exists():
    mt = pd.read_csv(td_path).rename(columns={"reflectivity":"measured"})
    if "delay_fs" in mt.columns:
        if ptp_field.exists():
            pf = pd.read_csv(ptp_field).rename(columns={"reflectivity_pred_field":"pred_field"})
            dfj = mt.merge(pf, on="delay_fs", how="inner")
            fig = px.line(dfj, x="delay_fs", y=["measured","pred_field"], title="Time-domain: measured vs physics (field Re[r(t)])")
            st.plotly_chart(fig, use_container_width=True)
        if ptp_mag.exists():
            pm = pd.read_csv(ptp_mag).rename(columns={"reflectivity_pred_mag":"pred_mag"})
            dfj = mt.merge(pm, on="delay_fs", how="inner")
            fig = px.line(dfj, x="delay_fs", y=["measured","pred_mag"], title="Time-domain: measured vs physics (magnitude |r(t)|)")
            st.plotly_chart(fig, use_container_width=True)
if rtp.exists():
    dr = pd.read_csv(rtp)
    if "delay_fs" in dr.columns:
        fig = px.line(dr, x="delay_fs", y=dr.columns[-1], title="Time-domain residuals (meas - affine(pred)) [physics]")
        st.plotly_chart(fig, use_container_width=True)
