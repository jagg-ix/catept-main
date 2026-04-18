# i-PI entropic-time patch (vendored)

This repository includes a **vendored copy** of your `i-pi.patch` and the files it introduces, so we can:

1. Track what changed in i-PI for *Entropic Langevin* motion.
2. Reuse the Python socket driver (`entropic_drivers.py`) and example inputs from *within* this repo.
3. Keep the core simulator independent of a forked i-PI checkout.

## Where it lives in this repo

- Patch + extracted files (reference):
  - `third_party/i-pi_patch/i-pi.patch`
  - `third_party/i-pi_patch/...` (new files) and `_modified_diffs/` (diffs for modified upstream files)

- Usable, importable Python pieces:
  - `src/cat_ept_doubleslit/integration/ipi_patch/entropic_drivers.py`
  - `src/cat_ept_doubleslit/integration/ipi_patch/ipi/...` (the new i-PI modules)

- Runnable examples:
  - `examples/entropic/sgi_validation/`
  - `examples/entropic/black_hole_ringdown/`

## What the patch changes upstream (summary)

### New files added to i-PI

- `drivers/py/entropic_drivers.py`
  - Implements i-PI socket **driver potentials** (SGI, black hole test particle, ENZ-style oscillator)
  - Reports `extras` fields (e.g. `lambda`, `alpha`, `Pi`) for analysis.

- `ipi/engine/motion/entropic_langevin.py`
  - Adds an `EntropicLangevinMotion` integrator / motion class.

- `ipi/inputs/motion/entropic.py`
  - Adds corresponding **input schema** so `<motion mode="entropic">` is understood.

- `ipi/utils/entropic_time.py`
  - Shared utilities to compute entropic proper time / dissipation observables.

- Examples under `examples/entropic/...`
  - `sgi_validation` and `black_hole_ringdown` input XML + scripts.

### Modified files upstream

- `ipi/engine/motion/__init__.py`
  - Adds `from ipi.engine.motion.entropic_langevin import EntropicLangevinMotion`

> Note: your patch had a quoting/newline artifact in the path of `analyze_bh.py`.
> In this repo we normalized it to `examples/entropic/black_hole_ringdown/analyze_bh.py`.

## How to apply to an i-PI checkout

From the root of an i-PI git checkout:

```bash
git apply /path/to/this/repo/third_party/i-pi_patch/i-pi.patch
```

Then verify `EntropicLangevinMotion` is importable and that the entropic examples run.

## How we use it here

This repo doesn’t require a forked i-PI. Instead:

- We keep the patch as provenance.
- We reuse the driver logic + example configs.
- Our `integration/` bridges can call into these components when you run an i-PI-based pipeline.

