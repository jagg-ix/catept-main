import streamlit as st
from pathlib import Path
import json
import pandas as pd
import plotly.express as px
from ui.common.run_pipeline import run_make

st.set_page_config(page_title="Twin paradox (electrons)", layout="wide")
st.title("Twin paradox (electrons) — worldlines + proper time")

repo_root = Path(__file__).resolve().parents[2]
runs_root = repo_root / "PAPER_TABLES" / "ADVANCED" / "UI" / "TWIN_PARADOX"

st.markdown("## Run")
if st.button("Run baseline twin paradox (make run_twin_paradox)"):
    res = run_make("run_twin_paradox", repo_root=repo_root)
    st.code(res.stdout or "", language="text")
    if res.returncode != 0:
        st.error("Failed.")
        st.code(res.stderr or "", language="text")
    else:
        st.success("Done.")

st.markdown("## Select a run (manifest-driven)")
manifests = sorted(runs_root.glob("**/run_manifest.json"), key=lambda p: p.stat().st_mtime, reverse=True) if runs_root.exists() else []
if not manifests:
    st.info("No runs found yet. Click 'Run baseline twin paradox'.")
    st.stop()

labels = [str(p.parent.relative_to(runs_root)) for p in manifests]
choice = st.selectbox("Run", labels, index=0)
man_path = manifests[labels.index(choice)]
man = json.loads(man_path.read_text())
st.caption(str(man_path))
st.json(man)

wlA = Path(man["artifacts"]["worldline_A_csv"])
wlB = Path(man["artifacts"]["worldline_B_csv"])
summ = Path(man["artifacts"]["summary_json"])

if summ.exists():
    s = json.loads(summ.read_text())
    c1, c2, c3 = st.columns(3)
    c1.metric("τA (s)", f'{s["tauA_s"]:.6g}')
    c2.metric("τB (s)", f'{s["tauB_s"]:.6g}')
    c3.metric("Δτ (s)", f'{s["delta_tau_s"]:.6g}')

if wlA.exists() and wlB.exists():
    dfa = pd.read_csv(wlA)
    dfb = pd.read_csv(wlB)
    fig = px.line(dfa, x="t_s", y="x_m", title="Worldlines x(t)")
    fig.add_scatter(x=dfb["t_s"], y=dfb["x_m"], mode="lines", name="B")
    st.plotly_chart(fig, use_container_width=True)

    fig2 = px.line(dfa, x="t_s", y="tau_s", title="Proper time τ(t)")
    fig2.add_scatter(x=dfb["t_s"], y=dfb["tau_s"], mode="lines", name="B")
    st.plotly_chart(fig2, use_container_width=True)
else:
    st.warning("Missing worldline CSV artifacts.")
