import streamlit as st

st.set_page_config(page_title="CATSim UI", layout="wide")

st.title("CATSim — Simulator UI")
st.write(
    "This UI is an orchestration + visualization shell. "
    "It runs existing Make targets/scripts and displays generated artifacts."
)

st.markdown("### Modules")
st.page_link("ui/pages/1_Double_Slit.py", label="Double slit", icon="🟦")
st.page_link("ui/pages/2_Twin_Paradox_Electrons.py", label="Twin paradox (electrons)", icon="⏱️")
st.page_link("ui/pages/3_Black_Hole_Ringdown.py", label="Black hole ringdown", icon="🕳️")

st.markdown("---")
st.markdown("### Quick actions")
st.write("Use these if you just want to run the pipelines from the UI.")
col1, col2, col3 = st.columns(3)
from pathlib import Path
from ui.common.run_pipeline import run_make

repo_root = Path(__file__).resolve().parents[1]

def button(target: str, col):
    if col.button(f"make {target}"):
        res = run_make(target, repo_root=repo_root, timeout_s=None)
        st.code(res.stdout or "", language="text")
        if res.returncode != 0:
            st.error(f"Target failed (rc={res.returncode}).")
            st.code(res.stderr or "", language="text")
        else:
            st.success("Done.")

button("verify_source_data", col1)
button("repro_from_xlsx", col2)
button("material_backend_meep_full", col3)
