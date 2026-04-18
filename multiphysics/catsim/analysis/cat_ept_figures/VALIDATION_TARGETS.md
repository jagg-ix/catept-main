# CAT/EPT Validation Targets vs Tirole Experimental Data

## Existing Infrastructure Summary

### Data Sources (already in repo)
| Asset | Path | Content |
|-------|------|---------|
| **Main DB** | `data_pipeline/user_scripts/double_slit.sqlite3` | 3.6 MB, 21 tables, 19830 spectral rows |
| **Excel sources** | `data_pipeline/source_data/Fig_*.xlsx` | Raw Nature Physics source data |
| **TIROLE_DB** | `TIROLE_DB/results.sqlite3` | Ingested constants + sim runs |
| **OBSERVABLES** | `PAPER_TABLES/OBSERVABLES/results.sqlite3` | Extracted spectral + time-domain observables |
| **Visibility Summary** | `PAPER_TABLES/PAPER_VISIBILITY_SUMMARY.json` | Calibration/prediction RMSE |
| **Ingested Constants** | `TIROLE_DB/ingest_constants.json` | PDF-extracted physical constants |

### Data Pipeline (already built)
| Script | Purpose |
|--------|---------|
| `data_pipeline/user_scripts/build_and_verify_pipeline.py` | Master XLSX -> tidy CSV -> SQLite |
| `data_pipeline/user_scripts/tidy-2a-2g.py` | Extract Fig 2 panels |
| `data_pipeline/user_scripts/extend-fig*.py` | Extract Extended Data figures |
| `scripts/tirole_ingest_and_compare.py` | PDF text -> constants -> simulate -> compare |
| `scripts/paper_faithful_tables_from_xlsx.py` | Calibrate on one S, predict on other |

### Simulator API
```python
from cat_ept_doubleslit.experiments.time_double_slit import (
    TimeDoubleSlitConfig, simulate_time_double_slit, simulate_time_double_slit_band
)
from cat_ept_doubleslit.observables import (
    build_spectral_observables, build_time_domain_observables
)
from cat_ept_doubleslit.db import load_spectra, load_spectra_by_slit_separation, load_time_domain
from cat_ept_doubleslit.fit import fit_rate_grid_temporal
from cat_ept_doubleslit.models import temporal_double_slit_spectrum
```

---

## Experimental Data Available in DB

### Spectral Data (from `spectra` table)
| Figure | S (fs) | Series | Points | Description |
|--------|--------|--------|--------|-------------|
| Fig_2a | 800 | raw, smooth, model | 255+255+170 | Primary spectrum at S=800 fs |
| Fig_2b | 500 | raw, smooth | 255+255 | Primary spectrum at S=500 fs |
| Fig_2c | (sub) | raw, smooth, model | 680 | Subtracted spectrum |
| Fig_2d | (sub) | raw, smooth, model | 680 | Subtracted spectrum |
| Fig_2f | -1300..+1300 | model | 17280 (27 seps x 640 freq) | Full interferogram |

### Period vs Separation (from `Fig_2e` table)
| Series | Points | S range (fs) | Period range (THz) |
|--------|--------|-------------|-------------------|
| raw | 17 | -1110..+1190 | 0.756..2.580 |
| model | 17 | -1110..+1190 | 0.655..1.400 |
| fit | 17 | -1221..+1190 | 0.824..1.239 |

### Time-Domain (from `time_domain` table)
| Figure | Points | Description |
|--------|--------|-------------|
| Extended_Fig_1a | 1100 | Single slit reflectivity r(t) |
| Extended_Fig_1b | 2376 | 2D: delay x separation reflectivity |
| Fig_1d | 100 | Pump intensity vs reflectivity |

### Extracted Observables (from OBSERVABLES DB)
| Figure | S (fs) | Fringe (THz) | V_paper | V_robust |
|--------|--------|-------------|---------|----------|
| Fig_2a | 800 | 2.823 | 0.4135 | 0.9460 |
| Fig_2b | 500 | 2.119 | 0.1623 | 0.7603 |

---

## Validation Targets

### TARGET 1: Spectral Shape Match (CRITICAL)
**What**: Overlay simulated spectrum on experimental spectrum at S=500 fs and S=800 fs
**Data**: `spectra` table, experiment_id 11 (Fig_2a, S=800) and 12 (Fig_2b, S=500)
**Metric**: RMSE between normalized model and data
**Current status**: RMSE ~ 0.65 (calibration), ~0.93 (prediction)
```python
DB = "data_pipeline/user_scripts/double_slit.sqlite3"
f_THz, I_data = load_spectra(DB, ref="Fig_2a")  # S=800 fs
f_THz, I_data = load_spectra(DB, ref="Fig_2b")  # S=500 fs
```

### TARGET 2: Fringe Spacing vs Separation (CRITICAL)
**What**: Verify 1/S law from simulation matches experimental Fig 2e data
**Data**: `Fig_2e` table with 'raw' series (17 experimental points)
**Metric**: |sim_period - exp_period| / exp_period at each S
**Key test**: Does CAT/EPT preserve the 1/S fringe spacing relationship?
```python
# Experimental data
cur.execute("SELECT Slit_separation_fs, Oscillation_THz FROM Fig_2e WHERE Series='raw'")
```

### TARGET 3: Visibility at S=500 fs and S=800 fs (CRITICAL)
**What**: Compare simulated visibility to experimentally-extracted visibility
**Data**: OBSERVABLES DB `obs_spectral` table
**Experimental values**:
  - S=800 fs: V_paper = 0.4135, V_robust = 0.9460
  - S=500 fs: V_paper = 0.1623, V_robust = 0.7603
**Metric**: |V_sim - V_exp| for both standard and CAT/EPT

### TARGET 4: Calibrate-then-Predict Protocol (CRITICAL)
**What**: Fit rate on S=500 fs, predict S=800 fs spectrum WITHOUT refitting
**Data**: Both Fig_2a and Fig_2b spectral data
**Metric**: RMSE_prediction (should be lower for correct theory)
**Current results**:
  - Standard: gamma = 5.84e12 /s, RMSE_cal=0.645, RMSE_pred=0.936
  - CAT/EPT: lambda_ent = 6.68e12 /s, RMSE_cal=0.646, RMSE_pred=0.934
**Key insight**: Currently near-identical -- need to check if coherence mode (not amplitude) changes this

### TARGET 5: Full Interferogram Match (HIGH)
**What**: Compare simulated 2D interferogram to experimental Fig 2f
**Data**: `Fig_2f` table (27 separations x 640 frequencies) or `spectra` table with experiment 16
**Metric**: 2D correlation coefficient between sim and data heatmaps

### TARGET 6: Spectral Extent and Asymmetry (HIGH)
**What**: Paper reports "~10 THz red side, ~4 THz blue side" asymmetry
**Data**: Fig_2a raw spectrum
**Experimental values**: extent_red ~ 10 THz, extent_blue ~ 4 THz
**Metric**: Does simulation reproduce this red/blue asymmetry?

### TARGET 7: Rise Time Sensitivity (HIGH)
**What**: Extended Fig 3d provides model spectra at 3.6, 7, and 17 fs rise times
**Data**: `Extended_Fig_3d` table (model spectra for 3 rise times at 170 frequency points each)
**Metric**: Match spectral shape across rise time variants

### TARGET 8: Time-Domain Slit Shape (MEDIUM)
**What**: Match |r(t)| trace shape from Extended Fig 1a
**Data**: `Extended_Fig_1a` table (1100 points, 'actual' series)
**Metric**: Shape overlap of simulated vs experimental r(t)

### TARGET 9: Visibility Decay Law (MEDIUM)
**What**: Verify V(S) functional form from multiple separations
**Data**: Extract visibility from Fig_2f interferogram at each of 27 separations
**Metric**: Fit V(S) = exp(-lambda*S) and check residuals
**Key test**: Does exponential decay fit experimental multi-S data?

### TARGET 10: Second Peak Amplitude (MEDIUM)
**What**: Paper reports second slit peak is 0.93% relative to first
**Data**: `ingest_constants.json`: second_peak_percent = 0.93%
**Metric**: Does sim slit model reproduce A/B amplitude ratio?

---

## How to Load and Configure

### Minimal Example: Load Experimental Data and Compare
```python
import sys, numpy as np
sys.path.insert(0, "simulations/catsim/src")
sys.path.insert(0, "webapp/py")

from cat_ept_doubleslit.db import load_spectra
from cat_ept_doubleslit.experiments.time_double_slit import (
    TimeDoubleSlitConfig, simulate_time_double_slit_band
)
from cat_ept_doubleslit.observables import build_spectral_observables

DB = "simulations/catsim/data_pipeline/user_scripts/double_slit.sqlite3"

# Load experimental spectrum (S=800 fs)
f_exp_THz, I_exp = load_spectra(DB, ref="Fig_2a")

# Simulate standard (no CAT/EPT)
cfg_std = TimeDoubleSlitConfig(
    separation_s=800e-15,
    use_cat_ept=False,
)
res_std = simulate_time_double_slit_band(cfg_std, half_width_hz=15e12)

# Simulate CAT/EPT coherence mode
cfg_cat = TimeDoubleSlitConfig(
    separation_s=800e-15,
    use_cat_ept=True,
    cat_mode="coherence",
    lambda_ent_inv_s=1e12,
)
res_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=15e12)

# Extract observables
obs_std = build_spectral_observables(
    slit_separation_fs=800,
    frequency_THz=res_std["freq_hz_band"] / 1e12,
    intensity=res_std["intensity_band"],
    carrier_THz=230.2,
)
obs_cat = build_spectral_observables(
    slit_separation_fs=800,
    frequency_THz=res_cat["freq_hz_band"] / 1e12,
    intensity=res_cat["intensity_band"],
    carrier_THz=230.2,
)

print(f"Standard V={obs_std.visibility_paper:.4f}")
print(f"CAT/EPT  V={obs_cat.visibility_paper:.4f}")
```

### Calibrate-then-Predict with Existing Fitting Infrastructure
```python
sys.path.insert(0, "simulations/catsim/src")
from cat_ept_doubleslit.db import load_spectra
from cat_ept_doubleslit.fit import fit_rate_grid_temporal
from cat_ept_doubleslit.models import temporal_double_slit_spectrum

DB = "simulations/catsim/data_pipeline/user_scripts/double_slit.sqlite3"

# Load calibration data (S=500 fs)
f_cal_THz, I_cal = load_spectra(DB, ref="Fig_2b")
f_cal_Hz = f_cal_THz * 1e12
det_cal_Hz = f_cal_Hz - 230.2e12

# Fit standard rate on calibration set
rate_grid = np.linspace(0, 5e14, 600)
fit_std = fit_rate_grid_temporal(
    det_cal_Hz, I_cal / I_cal.max(),
    separation_s=500e-15, slit_rise_s=7e-15,
    mode="standard", rate_grid=rate_grid
)

# Predict S=800 fs WITHOUT refitting
f_pred_THz, I_pred = load_spectra(DB, ref="Fig_2a")
det_pred_Hz = f_pred_THz * 1e12 - 230.2e12
I_model_std, V = temporal_double_slit_spectrum(
    det_pred_Hz, separation_s=800e-15, slit_rise_s=7e-15,
    mode="standard", gamma_s_inv=fit_std.rate_value
)
rmse = np.sqrt(np.mean((I_pred/I_pred.max() - I_model_std)**2))
```

---

## Physical Constants from Paper (Supplementary Information)

| Parameter | Value | Unit | Source |
|-----------|-------|------|--------|
| Carrier frequency f0 | 230.2 | THz | SI: Time diffraction model |
| Probe FWHM (field) | 794 | fs | SI: Time diffraction model |
| Rise time (10-90%) | 7.0 | fs | SI: Time diffraction model fit |
| Rise time range | 1-10 | fs | SI: Time diffraction model |
| Alpha (rise) | 1/(2 fs) = 5e14 | 1/s | SI: model parameter |
| Beta (decay) | 1/(400 fs) = 2.5e12 | 1/s | SI: slit characterization |
| Second peak amplitude | 0.93 | % | SI: slit characterization |
| Spectral extent red | ~10 | THz | Main text |
| Spectral extent blue | ~4 | THz | Main text |
| Key separations | 500, 800 | fs | Fig 2a (800), Fig 2b (500) |
| Interferogram range | -1300..+1300 | fs | Fig 2f (27 separations) |
