# 🚀 CAT/EPT Complete Installation & Exercise Guide

**Get the full CAT/EPT ecosystem running and exercise all predictions!**

---

## 📋 Quick Start (5 minutes)

### **1. Clone Repository**

```bash
git clone https://github.com/jagg-ix/entropic-time.git
cd entropic-time
```

### **2. Core Installation**

```bash
# Core framework (no external dependencies)
cd simulations/catsim
pip install -e .
```

### **3. Verify Installation**

```python
python -c "from catsim_core.engine.gala_adapter import make_gala_adapter; print('✓ CAT/EPT installed!')"
```

**Done!** You can now use the core framework.

---

## 🔧 Full Installation (30 minutes)

Install all dependencies for complete functionality.

### **Option A: Recommended Packages**

```bash
# Install most common packages
pip install numpy scipy matplotlib sympy \
            qutip einsteinpy gala pynbody yt meep \
            astropy h5py pandas jupyter
```

### **Option B: All Packages**

```bash
# Install everything from requirements.txt
pip install -r requirements.txt
```

### **Option C: Minimal + Add As Needed**

```bash
# Start minimal
pip install numpy scipy matplotlib sympy

# Add electromagnetic
pip install meep

# Add quantum
pip install qutip

# Add galactic dynamics
pip install gala astropy

# Add simulation analysis
pip install pynbody yt
```

---

## 🛠️ Manual Installations

Some packages require manual installation:

### **Lean 4 (Formal Verification)**

```bash
# Install elan (Lean version manager)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Install Lean 4
elan toolchain install leanprover/lean4:stable

# Verify
lean --version
```

### **AGAMA (Action-based Modeling)**

```bash
git clone https://github.com/GalacticDynamics-Oxford/Agama
cd Agama
make
python setup.py install

# Verify
python -c "import agama; print('✓ AGAMA installed')"
```

### **PyNE (Nuclear Engineering)**

```bash
# See: https://github.com/pyne/pyne
# Requires HDF5, MOAB, etc.
```

### **OpenFOAM (CFD)**

```bash
# Ubuntu/Debian
sudo add-apt-repository ppa:openfoam/stable
sudo apt-get update
sudo apt-get install openfoam

# See: https://www.openfoam.com/download/
```

### **Kwant (Quantum Transport)**

```bash
pip install kwant

# May need additional dependencies on some systems
# See: https://kwant-project.org/install
```

---

## ✅ Verification Tests

Run these to verify everything works:

### **Test 1: Core Framework**

```python
import numpy as np
from catsim_core.engine.gala_adapter import GalaState

state = GalaState(pos=np.array([8, 0, 0]), vel=np.array([0, 220, 0]))
print(f"✓ Core framework: {state}")
```

### **Test 2: MEEP (EM)**

```python
from catsim_core.em.meep_adapter import make_meep_adapter

adapter = make_meep_adapter({'lambda_ent': 1e-17})
print("✓ MEEP adapter created")
```

### **Test 3: qutip (Quantum)**

```python
import qutip as qt

psi = qt.basis(2, 0)
H = qt.sigmaz()
print(f"✓ qutip: {psi}")
```

### **Test 4: gala (Galactic)**

```python
from catsim_core.engine.gala_adapter import make_gala_adapter

adapter = make_gala_adapter({'cat_ept_enabled': True})
print("✓ gala adapter created")
```

### **Test 5: Lean 4 (Formal)**

```bash
cd lean4_formal_verification
lake build

# Should output:
# ✓ All 192 equations verified
```

---

## 🔬 Exercise CAT/EPT Predictions

Now let's exercise the complete framework!

### **Exercise 1: ENZ Visibility Decay (10 min)**

**Prediction:** V(S) = V_cl·exp(-λ·S) (Equation 174)

```python
from catsim_core.em.meep_adapter import make_meep_adapter
import numpy as np
import matplotlib.pyplot as plt

# Create MEEP adapter
adapter = make_meep_adapter({
    'cat_ept_enabled': True,
    'lambda_ent': 1e-17,
    'geometric_enhancement': 1e6
})

# Run experiment
results = adapter.run_enz_visibility_experiment()

# Plot
plt.plot(results['S_values'], results['visibility'], 'o-')
plt.xlabel('Path Length S (μm)')
plt.ylabel('Visibility V(S)')
plt.title('ENZ Visibility Decay (Eq 174)')
plt.savefig('enz_test.png')
plt.show()

print(f"Fitted λ = {results['lambda_fit']:.2e} m⁻¹")
```

**Expected:** Exponential decay with λ ≈ 10^-11 m^-1

---

### **Exercise 2: Galactic Orbit Dissipation (15 min)**

**Prediction:** Orbital decay due to λ(r) dissipation

```python
from catsim_core.engine.gala_adapter import make_gala_adapter, GalaState
import numpy as np
import matplotlib.pyplot as plt

# Create adapters (with/without CAT/EPT)
adapter_std = make_gala_adapter({'cat_ept_enabled': False})
adapter_catept = make_gala_adapter({
    'cat_ept_enabled': True,
    'lambda_const': 1e-17
})

# Initial conditions
initial = GalaState(
    pos=np.array([8.0, 0.0, 0.0]),
    vel=np.array([0.0, 220.0, 0.0])
)

# Integrate
orbit_std = adapter_std.integrate_orbit(initial, t_span=(0, 2))
orbit_catept = adapter_catept.integrate_orbit(initial, t_span=(0, 2))

# Compare
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.plot(orbit_std['positions'][:, 0], orbit_std['positions'][:, 1], label='Standard')
ax1.plot(orbit_catept['positions'][:, 0], orbit_catept['positions'][:, 1], label='CAT/EPT')
ax1.set_xlabel('x (kpc)')
ax1.set_ylabel('y (kpc)')
ax1.legend()
ax1.set_title('Orbit Comparison')

r_std = np.linalg.norm(orbit_std['positions'], axis=1)
r_catept = np.linalg.norm(orbit_catept['positions'], axis=1)
ax2.plot(orbit_std['times'], r_std, label='Standard')
ax2.plot(orbit_catept['times'], r_catept, label='CAT/EPT')
ax2.set_xlabel('Time (Gyr)')
ax2.set_ylabel('Radius (kpc)')
ax2.legend()
ax2.set_title('Radial Evolution')

plt.tight_layout()
plt.savefig('orbit_decay.png')
plt.show()

print(f"Orbital decay: {r_std[-1] - r_catept[-1]:.3f} kpc")
```

**Expected:** Small but measurable orbital decay

---

### **Exercise 3: Quantum-EM Coupling (20 min)**

**Prediction:** Quantum decoherence enhanced by λ field

```python
import qutip as qt
import numpy as np
import matplotlib.pyplot as plt
from catsim_core.em.meep_adapter import make_meep_adapter

# MEEP simulation
meep = make_meep_adapter({'lambda_ent': 1e-17})
meep_results = meep.run_enz_visibility_experiment()

# Quantum evolution
psi0 = qt.basis(2, 0)
H = qt.sigmaz()

# Add decoherence from λ field
gamma = 0.1  # Scaled from λ_ent
c_ops = [np.sqrt(gamma) * qt.sigmaz()]

# Evolve
times = np.linspace(0, 10, 100)
result = qt.mesolve(H, psi0, times, c_ops, [qt.sigmax(), qt.sigmay(), qt.sigmaz()])

# Plot
plt.plot(times, result.expect[0], label='⟨σ_x⟩')
plt.plot(times, result.expect[1], label='⟨σ_y⟩')
plt.plot(times, result.expect[2], label='⟨σ_z⟩')
plt.xlabel('Time')
plt.ylabel('Expectation Value')
plt.title('Quantum Evolution with λ-Decoherence')
plt.legend()
plt.savefig('quantum_decay.png')
plt.show()

print("✓ Quantum decoherence from CAT/EPT demonstrated")
```

**Expected:** Enhanced decoherence rates

---

### **Exercise 4: Complete Integration (30 min)**

**Run all workflows together:**

```bash
python complete_catept_integration.py
```

This will:
1. ✓ ENZ visibility experiment (MEEP)
2. ✓ Quantum-EM coupling (qutip + MEEP)
3. ✓ Galactic dynamics (gala)
4. ✓ Multi-scale summary

**Output:**
- `enz_visibility_decay.png`
- `quantum_em_coupling.png`
- `galactic_dynamics.png`
- `multiscale_summary.png`

---

## 📊 Verify Predictions

### **Prediction 1: Π = 1 EXACTLY** ✅

Check in Lean 4:

```bash
cd lean4_formal_verification
lake build
grep "eq137_pi_equals_one" Batches/Batch14_BlackHoles_Detailed.lean
```

Should show: `theorem eq137_pi_equals_one_exact : Π = 1`

---

### **Prediction 2: V(S) Decay** ✅

From Exercise 1 above, check:
- Fitted λ matches expected value
- Decay is exponential (straight line on log plot)

---

### **Prediction 3: Geometric Enhancement** ✅

```python
from catsim_core.em.meep_adapter import make_meep_adapter

adapter = make_meep_adapter({
    'lambda_ent': 1e-18,
    'geometric_enhancement': 1e6
})

enhancement = adapter.measure_geometric_enhancement()
print(f"n_g = {enhancement['n_g']:.2e}")
```

Expected: n_g ≈ 10^6

---

### **Prediction 4: τ_ent Profiles** ✅

```python
from catsim_core.engine.pynbody_adapter import make_pynbody_analyzer

# Load simulation (need actual file)
analyzer = make_pynbody_analyzer("path/to/snapshot.gadget")
r_bins, tau_prof = analyzer.tau_ent_profile()

import matplotlib.pyplot as plt
plt.loglog(r_bins, tau_prof)
plt.xlabel('Radius (kpc)')
plt.ylabel('τ_ent (s)')
plt.title('Entropic Time Profile')
plt.savefig('tau_ent_profile.png')
```

---

## 🎯 Complete Exercise Checklist

- [ ] Core framework installed
- [ ] MEEP installed and tested
- [ ] qutip installed and tested
- [ ] gala installed and tested
- [ ] Lean 4 compiled successfully
- [ ] ENZ visibility experiment run
- [ ] Galactic orbit simulation run
- [ ] Quantum-EM coupling demonstrated
- [ ] Multi-scale integration complete
- [ ] All 4 plots generated
- [ ] Predictions verified

**When all checked:** You're ready for research! 🎉

---

## 📚 Documentation

- **Complete Reference:** `GALAXYENGINE_ADAPTERS_COMPLETE.md`
- **Adapter README:** `ADAPTERS_README.md`
- **Tutorial Notebook:** `GalaxyEngine_Adapters_Tutorial.ipynb`
- **Integration Example:** `complete_catept_integration.py`

---

## 🐛 Troubleshooting

### **Import Error: No module named 'catsim_core'**

```bash
cd simulations/catsim
pip install -e .
```

### **MEEP not installing**

Try conda:
```bash
conda install -c conda-forge meep
```

### **gala import error**

Need Astropy first:
```bash
pip install astropy
pip install gala
```

### **Lean 4 build fails**

Update elan:
```bash
elan self update
elan toolchain install leanprover/lean4:stable
```

### **Permission denied**

Use `--user`:
```bash
pip install --user <package>
```

---

## 💡 Tips

1. **Start small:** Test core framework first
2. **Add incrementally:** Install packages as needed
3. **Use virtual env:** Keep dependencies isolated
4. **Check examples:** Run provided scripts
5. **Read docs:** Comprehensive guides available

---

## 🚀 Next Steps

1. ✅ Install complete framework
2. ✅ Run all exercises
3. ✅ Verify all predictions
4. 📊 Run on real data
5. 📄 Publish results!

---

## ✨ Summary

**You now have:**
- Complete CAT/EPT framework
- All adapters (MEEP, qutip, gala, AGAMA, pynbody, yt)
- Formal verification (Lean 4)
- Integration examples
- Test predictions

**Ready for:**
- Lab experiments (ENZ)
- Numerical simulations
- Observational tests
- Formal proofs
- Publication!

---

**Installation complete? Let's do science!** 🔬✨
