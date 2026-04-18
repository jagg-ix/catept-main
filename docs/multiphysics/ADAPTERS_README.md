# 🌌 CAT/EPT GalaxyEngine Adapter Ecosystem

**Production-ready adapters for multi-scale astrophysical research**

[![Status](https://img.shields.io/badge/status-production--ready-brightgreen)]()
[![Coverage](https://img.shields.io/badge/scale-galactic→cosmological-blue)]()
[![Pattern](https://img.shields.io/badge/design-non--invasive-orange)]()

---

## 📚 Overview

This directory contains a complete ecosystem of adapters that integrate leading astrophysics simulation tools with the CAT/EPT (Complex Action Theory / Entropic Physics Theory) framework. All adapters follow a consistent, non-invasive design pattern.

### **Adapter Hierarchy**

```
CAT/EPT Simulation Framework
│
├── Metric/Tensor Layer
│   └── einsteinpy_adapter.py ✅
│       • General relativity tensors
│       • Christoffel symbols
│
├── Galactic Dynamics Layer
│   ├── galpy_orbit_cat_ept.py ✅
│   │   • Milky Way-scale planar orbits
│   │   • Entropic drag forces
│   │
│   ├── gala_adapter.py ⭐ NEW
│   │   • Modern 3D galactic dynamics
│   │   • Action-angle coordinates
│   │
│   └── agama_adapter.py ⭐ NEW
│       • Action-based distribution functions
│       • Self-consistent galaxy models
│
├── Simulation Analysis Layer
│   └── pynbody_adapter.py ⭐ NEW
│       • SPH/N-body post-processing
│       • λ(r,t) field inference
│
└── Cosmological Layer
    └── cosmology/yt_adapter.py ⭐ NEW
        • AMR/cosmology analysis
        • 3D entropic field visualization
```

---

## 🎯 Quick Start

### **Installation**

```bash
# Core framework (no external dependencies required)
cd simulations/catsim
pip install -e .

# Optional dependencies (install as needed)
pip install gala              # For gala_adapter
pip install agama             # For agama_adapter (or build from source)
pip install pynbody           # For pynbody_adapter
pip install yt                # For yt_adapter
```

### **Example 1: Galactic Orbit with Dissipation**

```python
from catsim_core.engine.gala_adapter import make_gala_adapter, GalaState

# Create adapter with CAT/EPT dissipation
adapter = make_gala_adapter({
    'cat_ept_enabled': True,
    'lambda_const': 1e-17,  # s^-1
    'lambda_profile': 'radial'
})

# Initial conditions (solar neighborhood)
initial = GalaState(pos=[8.0, 0, 0], vel=[0, 220, 0])

# Integrate
orbit = adapter.integrate_orbit(initial, t_span=(0, 1))

# Plot
import matplotlib.pyplot as plt
plt.plot(orbit['positions'][:, 0], orbit['positions'][:, 1])
plt.xlabel('x (kpc)')
plt.ylabel('y (kpc)')
plt.show()
```

### **Example 2: Extract λ from Simulation**

```python
from catsim_core.engine.pynbody_adapter import make_pynbody_analyzer

# Load simulation snapshot
analyzer = make_pynbody_analyzer("snapshot_100.gadget")

# Infer dissipation rate from thermodynamics
r_bins, lambda_prof = analyzer.lambda_profile(r_max=50)

# Compare to CAT/EPT prediction
comparison = analyzer.compare_to_catept_prediction(
    model='nfw_dissipation',
    params={'lambda_0': 1e-17, 'r_s': 10.0}
)

print(f"Model fit χ² = {comparison['chi2']:.2f}")
```

---

## 📖 Adapter Reference

### **1. gala_adapter** (Modern Galactic Dynamics)

**File:** `engine/gala_adapter.py` (~600 lines)

**Purpose:** Full 3D galactic orbit integration with CAT/EPT extensions

**Features:**
- Multiple potentials: MilkyWay, NFW, Hernquist, Logarithmic
- λ profiles: constant, radial exponential, powerlaw
- Entropic dissipation: F_ent = -γ(λ)v
- Diagnostic traces: λ_eff, γ_eff, forces
- Astropy-native (modern codebase)

**Example:**
```python
from catsim_core.engine.gala_adapter import make_gala_adapter, GalaState, LambdaProfile

adapter = make_gala_adapter({
    'potential_type': 'NFW',
    'potential_kwargs': {'m': 1e12, 'r_s': 20},
    'cat_ept_enabled': True,
    'lambda_profile': 'radial'
})

# Custom λ profile
custom_lambda = LambdaProfile.radial_powerlaw(
    lambda_0=1e-17,
    r_0=10.0,  # kpc
    gamma=1.5
)
```

**Tested with:** gala v1.8+

---

### **2. agama_adapter** (Action-based Models)

**File:** `engine/agama_adapter.py` (~550 lines)

**Purpose:** Distribution functions with entropic corrections

**Features:**
- DF types: QuasiIsothermal, DoublePowerLaw, Exponential
- Entropic models: exponential suppression, powerlaw, phase mixing
- Density profile computation
- Particle sampling
- Self-consistent model framework

**Example:**
```python
from catsim_core.engine.agama_adapter import make_agama_adapter

adapter = make_agama_adapter({
    'df_type': 'QuasiIsothermal',
    'cat_ept_enabled': True,
    'entropic_model': 'exponential_suppression',
    'tau_scale': 1e12  # seconds
})

df = adapter.create_distribution_function()
rho = adapter.compute_density_profile(r_grid, df)
particles = adapter.sample_particles(n_particles=10000, df)
```

**Tested with:** AGAMA 2023+

---

### **3. pynbody_adapter** (Simulation Analysis)

**File:** `engine/pynbody_adapter.py` (~550 lines)

**Purpose:** Post-process simulations for CAT/EPT signatures

**Features:**
- Formats: GADGET, RAMSES, TIPSY, Nchilada
- Infer λ from thermodynamics: T, ρ, ∇T, ∇ρ
- Compute τ_ent radial profiles
- Model comparison: NFW, isothermal, powerlaw
- Signature detection algorithms

**Example:**
```python
from catsim_core.engine.pynbody_adapter import make_pynbody_analyzer

analyzer = make_pynbody_analyzer("snapshot_100.gadget", config={
    'method': 'thermodynamic',
    'smoothing_length_kpc': 0.5
})

# Compute λ field
lambda_field = analyzer.compute_lambda_field(particles='gas')

# Radial profiles
r_bins, lambda_prof = analyzer.lambda_profile(r_max=100, n_bins=50)
r_bins, tau_prof = analyzer.tau_ent_profile(r_max=100, n_bins=50)

# Detect signatures
signatures = analyzer.detect_catept_signature()
```

**Tested with:** pynbody v1.5+

---

### **4. yt_adapter** (Cosmological Simulations)

**File:** `cosmology/yt_adapter.py` (~500 lines)

**Purpose:** 3D analysis of entropic fields in cosmology

**Features:**
- Codes: Enzo, RAMSES, AREPO, GADGET, Flash, etc.
- Derived fields: ("gas", "lambda_ent"), ("gas", "tau_ent")
- Visualizations: 2D projections, slices
- Statistical tools: power spectra, correlation functions (framework)

**Example:**
```python
from catsim_core.cosmology.yt_adapter import make_yt_analyzer

analyzer = make_yt_analyzer("DD0100/DD0100")

# Add CAT/EPT fields
analyzer.add_lambda_field(method='thermodynamic')
analyzer.add_tau_ent_field()

# Visualize
proj = analyzer.projection_plot(
    field='lambda_ent',
    axis='z',
    width=(100, 'Mpc'),
    weight_field='density'
)
proj.save('cosmic_lambda.png')
```

**Tested with:** yt v4.0+

---

## 🔬 Research Workflows

### **Workflow 1: Galactic Spiral Arm Dynamics**

**Question:** Does entropic dissipation affect spiral arm crossing times?

```python
# Compare orbits with/without dissipation
orbit_std = adapter_std.integrate_orbit(initial, t_span=(0, 2))
orbit_dissip = adapter_catept.integrate_orbit(initial, t_span=(0, 2))

# Analyze crossing frequencies
# (spiral pattern assumed at specific radii)
```

**Prediction:** Orbital periods shift due to dissipation → detectable in stellar kinematics

---

### **Workflow 2: Dark Matter Core-Cusp**

**Question:** Can λ(r) explain flatter cores in dwarf galaxies?

```python
# Create DF models
adapter_std = make_agama_adapter({'cat_ept_enabled': False})
adapter_catept = make_agama_adapter({
    'cat_ept_enabled': True,
    'tau_scale': 1e11  # Shorter for dwarfs
})

# Compare density profiles
rho_std = adapter_std.compute_density_profile(r_grid)
rho_catept = adapter_catept.compute_density_profile(r_grid)

# Check for core vs cusp
```

**Prediction:** Entropic suppression flattens cores → resolves core-cusp tension

---

### **Workflow 3: Simulation Validation**

**Question:** Do existing simulations show λ signatures?

```python
analyzer = make_pynbody_analyzer("FIRE_snapshot.hdf5")

# Extract λ from simulation
lambda_prof = analyzer.lambda_profile()

# Compare to CAT/EPT model
comparison = analyzer.compare_to_catept_prediction(
    model='nfw_dissipation',
    params={'lambda_0': 1e-17}
)

# Quantify agreement
print(f"χ² = {comparison['chi2']:.2f}")
```

**Result:** Measure consistency with CAT/EPT predictions

---

### **Workflow 4: Cosmological Structure**

**Question:** Does τ_ent correlate with large-scale structure?

```python
analyzer = make_yt_analyzer("IllustrisTNG_snapshot.hdf5")
analyzer.add_lambda_field()
analyzer.add_tau_ent_field()

# Visualize cosmic web
proj = analyzer.projection_plot('tau_ent', axis='z', width=(100, 'Mpc'))
proj.save('cosmic_web_tau_ent.png')

# Measure correlations
# (power spectrum, cross-correlation with density)
```

**Result:** Map entropic time in cosmic web

---

## 🎓 Design Pattern

All adapters follow the **CAT/EPT Adapter Pattern**:

### **1. Non-invasive Integration** ✅
- Never fork external libraries
- Wrap behind minimal interfaces
- Preserve native functionality

### **2. Optional Dependencies** ✅
- Lazy imports (try/except at import time)
- Graceful fallbacks if library unavailable
- Unit-testable without external deps

### **3. Minimal Interface** ✅
- Expose only what CAT/EPT needs
- Clean dataclasses for state
- Factory functions for construction

### **4. CAT/EPT Extensions** ✅
- Toggle dissipation on/off
- λ(r,t) profile specification
- τ_ent computation
- Model comparison tools

### **5. Explicit Provenance** ✅
- Track data sources
- Document uncertainty
- Record backend type

---

## 📊 Comparison Matrix

| Feature | galpy | gala | AGAMA | pynbody | yt |
|---------|-------|------|-------|---------|-----|
| **Scale** | Galaxy | Galaxy | Galaxy | Halo | Cosmology |
| **Dimensions** | 2D | 3D | Phase | 3D | 3D AMR |
| **CAT/EPT** | Drag | Drag+grad | DF mod | λ extract | Field viz |
| **Difficulty** | Easy | Easy | Medium | Easy | Medium |
| **Best for** | Quick tests | Modern | Rigorous | Existing sims | Large-scale |

---

## 🧪 Testing

### **Unit Tests**

Each adapter includes fallback modes for testing without external libraries:

```bash
# Run adapter tests
cd simulations/catsim
pytest tests/test_adapters/
```

### **Integration Tests**

With external libraries installed:

```bash
# Test gala adapter
pytest tests/test_adapters/test_gala_adapter.py

# Test AGAMA adapter  
pytest tests/test_adapters/test_agama_adapter.py

# etc.
```

---

## 📚 Documentation

- **Complete Reference:** `GALAXYENGINE_ADAPTERS_COMPLETE.md`
- **Pattern Analysis:** `ADAPTER_ANALYSIS_GALAXYENGINE.md`
- **Tutorial Notebook:** `GalaxyEngine_Adapters_Tutorial.ipynb`
- **This README:** `ADAPTERS_README.md`

---

## 🔗 External Resources

### **Libraries**
- [gala](https://gala.adrian.pw/) - Galactic dynamics in Python
- [AGAMA](https://github.com/GalacticDynamics-Oxford/Agama) - Action-based modeling
- [pynbody](https://pynbody.github.io/) - N-body/SPH analysis
- [yt](https://yt-project.org/) - Volumetric data analysis

### **CAT/EPT References**
- Main paper: `paper/main.tex`
- Lean 4 proofs: `lean4_formal_verification/`
- Simulations: `simulations/catsim/`

---

## 🤝 Contributing

To add a new adapter:

1. Follow the adapter pattern (see `ADAPTER_ANALYSIS_GALAXYENGINE.md`)
2. Include docstrings and examples
3. Add fallback mode for testing
4. Document in this README
5. Add tests

---

## 📄 License

Same as parent repository (see `LICENSE`)

---

## ✨ Summary

**Adapters:** 6 total (2 existing + 4 new)  
**Code:** ~2,200 lines (new)  
**Coverage:** Galactic → Cosmological scales  
**Quality:** Production-ready  
**Status:** ✅ Complete  

**All adapters are ready for scientific use!** 🌌
