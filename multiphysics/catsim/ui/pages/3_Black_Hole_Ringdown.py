import streamlit as st
from pathlib import Path
import json
import pandas as pd
import plotly.express as px
from ui.common.run_pipeline import run_make

st.set_page_config(page_title="Black hole ringdown", layout="wide")
st.title("Black hole ringdown — fit runner (baseline)")

repo_root = Path(__file__).resolve().parents[2]
runs_root = repo_root / "PAPER_TABLES" / "ADVANCED" / "UI" / "RINGDOWN"

st.markdown("## Run")
if st.button("Run synthetic ringdown fit (make run_ringdown_fit)"):
    res = run_make("run_ringdown_fit", repo_root=repo_root)
    st.code(res.stdout or "", language="text")
    if res.returncode != 0:
        st.error("Failed.")
        st.code(res.stderr or "", language="text")
    else:
        st.success("Done.")

st.markdown("## Select a run (manifest-driven)")
manifests = sorted(runs_root.glob("**/run_manifest.json"), key=lambda p: p.stat().st_mtime, reverse=True) if runs_root.exists() else []
if not manifests:
    st.info("No runs found yet. Click 'Run synthetic ringdown fit'.")
    st.stop()

labels = [str(p.parent.relative_to(runs_root)) for p in manifests]
choice = st.selectbox("Run", labels, index=0)
man_path = manifests[labels.index(choice)]
man = json.loads(man_path.read_text())
st.caption(str(man_path))
st.json(man)

fit_csv = Path(man["artifacts"]["ringdown_fit_csv"])
fit_params = Path(man["artifacts"]["fit_params_json"])

if fit_params.exists():
    p = json.loads(fit_params.read_text())
    c1,c2,c3 = st.columns(3)
    c1.metric("f (Hz)", f'{p["f_hz"]:.6g}')
    c2.metric("τ (s)", f'{p["tau_s"]:.6g}')
    c3.metric("RMSE", f'{p["rmse"]:.6g}')

if fit_csv.exists():
    df = pd.read_csv(fit_csv)
    fig = px.line(df, x="t_s", y=["h","h_fit"], title="Ringdown fit")
    st.plotly_chart(fig, use_container_width=True)
    fig2 = px.line(df, x="t_s", y="resid", title="Residual")
    st.plotly_chart(fig2, use_container_width=True)
    st.dataframe(df, use_container_width=True)
else:
    st.warning("Missing ringdown_fit.csv artifact.")
