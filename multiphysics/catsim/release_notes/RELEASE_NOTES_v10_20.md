# Release Notes — v10.20-sgi-harness-gr-bridge

Date: 2026-01-21

Adds a Stern–Gerlach Interferometer (SGI) experiment harness with strict layering:

- SGI experiment spec + GR/SR baseline worldline generator (1D) with pulse schedule.
- Backend bridge that invokes extended physics via existing repo adapters only.
  (No CAT/EPT equations are re-implemented in SGI code.)
- Runner CLI `python -m scripts.ui_modules.sgi_run` that exports manifest-driven artifacts.
- Streamlit UI page `ui/pages/3_Stern_Gerlach_Interferometer.py`.

Make target:
- `make run_sgi_harness`
