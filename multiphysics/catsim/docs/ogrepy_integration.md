# OGRePy integration (no-notebook + entropic time)

This repository uses OGRePy for **symbolic GR** where appropriate (exact metric, connection, curvature, geodesics), and then bridges those expressions to:

- the **simulator** (NumPy evaluation / finite-difference modules)
- **i-PI** drivers (forces / constraints / thermostats)
- **EinsteinPy** trajectories (validation + cross-checks)

## 1) Remove the Jupyter/IPython hard dependency

OGRePy upstream is designed to render rich Markdown/TeX in notebooks.
In a CLI/i-PI workflow, this can create an unwanted hard dependency on IPython.

This repo includes:

- your original diff: `third_party/patches/OGRePy.patch`
- a robust patcher script: `tools/patch_ogrepy_no_ipython.py`

Patch **an installed** OGRePy (site-packages):

```bash
python tools/patch_ogrepy_no_ipython.py --installed
```

Patch **a git checkout** of OGRePy:

```bash
python tools/patch_ogrepy_no_ipython.py /path/to/OGRePy
```

The script makes only three changes in `OGRePy/_core.py`:

1. remove `from IPython...` imports
2. force `_in_notebook = False`
3. make `_display_markdown` / `_display_tex` call `print()`

## 2) Entropic proper time reparameterization

CAT/EPT introduces a monotone clock:

\[
\tau_{\mathrm{ent}}(t) = \int_0^t \lambda(t',x,\dots)\,dt',\qquad \lambda\ge 0.
\]

Software migration rule:

- if your solver evolves in coordinate time `t`, replace the time step by
  \( d\tau = \lambda\,dt \)
- derivatives transform as \(\frac{d}{d\tau} = \frac{1}{\lambda}\frac{d}{dt}\)

This repo provides symbolic helpers in:

- `cat_ept_doubleslit.integration.ogrepy_entropic_bridge`

## 3) Wiring OGRePy into the bridges

### OGRePy -> i-PI

Use `cat_ept_doubleslit.integration.ogrepy_ipi_bridge.EntropicMetricIPIBridge`.
It expects an OGRePy-defined metric-like object and produces numerical callbacks
(i.e. lambdified expressions) that a driver can evaluate.

### OGRePy -> EinsteinPy

EinsteinPy is primarily numerical. The practical workflow is:

- derive symbolic expressions in OGRePy (e.g. effective potential, d\tau/dt)
- validate trajectories against EinsteinPy integrators

## 4) Recommended validation checks

- coordinate-time limit: set \(\lambda \to 1\) and compare against baseline solver
- unitary limit: set dissipation terms to zero (if present) and confirm norm conservation
- CFL sanity: if you use explicit time stepping, enforce \(\Delta t\) via \(\Delta \tau = \lambda\Delta t\)

