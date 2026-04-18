# 📖 OQuPy Open Quantum Systems Adapter - Complete Guide

**Non-Markovian quantum dynamics with CAT/EPT integration**

**Version:** 1.0  
**Date:** February 10, 2026  
**OQuPy:** https://github.com/tempoCollaboration/OQuPy  

---

## 📚 Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Physics Background](#physics-background)
5. [API Reference](#api-reference)
6. [Workflows](#workflows)
7. [Integration Patterns](#integration-patterns)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### **What is OQuPy?**

OQuPy (Open Quantum Systems in Python) is a state-of-the-art library for simulating non-Markovian open quantum systems using the **TEMPO** (Time-Evolving Matrix Product Operator) method.

**Key Features:**
- Non-Markovian dynamics (memory effects)
- Structured spectral densities (ohmic, super-ohmic, sub-ohmic)
- Numerically exact (within controllable error)
- Efficient tensor network representation

**Reference:** Strathearn et al., *Nature Communications* **9**, 3322 (2018)

---

### **CAT/EPT Integration**

This adapter extends OQuPy with CAT/EPT analysis:

1. **Entropy Extraction:** S(t) = -Tr(ρ ln ρ)
2. **Dissipation Rate:** λ(t) = (1/k_B) dS/dt
3. **Entropic Time:** τ_ent(t) = ∫ λ(t) dt
4. **Multi-Scale Integration:** Connect to Kwant, qutip

**Why This Matters:**
- OQuPy provides exact non-Markovian dynamics
- CAT/EPT extracts fundamental dissipation rates
- Combined: Most accurate λ_ent for mesoscopic systems

---

## 🔧 Installation

### **Step 1: Install OQuPy**

```bash
# From PyPI
pip install oqupy

# Or from source (latest)
git clone https://github.com/tempoCollaboration/OQuPy.git
cd OQuPy
pip install -e .
```

### **Step 2: Verify Installation**

```python
import oqupy
print(f"OQuPy version: {oqupy.__version__}")
```

### **Step 3: Install CAT/EPT Adapter**

```bash
cd /path/to/CATEPT-Complete/simulations/catsim
pip install -e .
```

### **Step 4: Test**

```python
from catsim_core.open_quantum import make_oqupy_adapter

adapter = make_oqupy_adapter()
print("✓ OQuPy adapter loaded successfully")
```

---

## 🚀 Quick Start

### **Example 1: Spin-Boson Model (5 minutes)**

```python
import numpy as np
from catsim_core.open_quantum import make_oqupy_adapter

# Configuration
adapter = make_oqupy_adapter({
    'system_dimension': 2,
    't_end': 1e-12,  # 1 picosecond
    'dt': 5e-15,     # 5 femtoseconds
    'bath_type': 'ohmic',
    'temperature': 300,  # Kelvin
    'coupling_strength': 0.1,
    'cat_ept_enabled': True
})

# System Hamiltonian (Pauli-Z)
H_sys = np.array([[1.0, 0.0], [0.0, -1.0]])

# Initial state (equal superposition)
rho0 = np.array([[0.5, 0.5], [0.5, 0.5]], dtype=complex)

# Coupling operator (Pauli-X)
coupling = np.array([[0.0, 1.0], [1.0, 0.0]])

# Run TEMPO dynamics
result = adapter.run_tempo_dynamics(H_sys, rho0, coupling)

# Access CAT/EPT quantities
print(f"Final entropy: S = {result.entropy[-1]:.6f}")
print(f"Peak λ: {np.max(result.lambda_ent):.3e} s⁻¹")
print(f"Final τ_ent: {result.tau_ent[-1]:.3e} s")
print(f"Final purity: {result.purity[-1]:.6f}")
```

**Expected Output:**
```
✓ OQuPy loaded successfully
Running TEMPO dynamics...
  Time range: 0.00e+00 to 1.00e-12 s
  TEMPO dt: 5.00e-15 s
  Memory depth: 100
  ✓ TEMPO dynamics complete
  Final entropy: S = 0.6931
  Peak λ: 3.2e+12 s⁻¹
  Final τ_ent: 1.5e+00 s
✓ CAT/EPT extraction complete
```

---

### **Example 2: Temperature Dependence (15 minutes)**

```python
temperatures = [10, 50, 100, 200, 300, 400]  # K
results = []

for T in temperatures:
    adapter = make_oqupy_adapter({
        'temperature': T,
        't_end': 1e-12,
        'cat_ept_enabled': True
    })
    
    # Same system as Example 1
    result = adapter.run_tempo_dynamics(H_sys, rho0, coupling)
    
    results.append({
        'T': T,
        'lambda_max': np.max(result.lambda_ent),
        'tau_ent_final': result.tau_ent[-1]
    })

# Analyze scaling
import matplotlib.pyplot as plt

temps = [r['T'] for r in results]
lambdas = [r['lambda_max'] for r in results]

plt.plot(temps, lambdas, 'o-', linewidth=2)
plt.xlabel('Temperature (K)')
plt.ylabel('Peak λ (s⁻¹)')
plt.title('Temperature Dependence')
plt.grid(True)
plt.show()
```

---

## 📊 Physics Background

### **Open Quantum Systems**

**Total Hamiltonian:**
```
H_total = H_sys + H_bath + H_int

H_sys: System Hamiltonian
H_bath: Bath Hamiltonian (environment)
H_int: System-bath interaction
```

**Reduced Dynamics:**

After tracing out bath degrees of freedom:
```
ρ_sys(t) = Tr_bath[e^(-iHt/ℏ) ρ_total(0) e^(iHt/ℏ)]
```

**Non-Markovian Effects:**

When bath correlation time τ_c is comparable to system timescale τ_sys:
- Memory effects (backflow of information)
- Non-exponential decay
- Revivals and oscillations

---

### **TEMPO Method**

**Feynman-Vernon Path Integral:**

TEMPO represents influence functional as tensor network:
```
ρ(t) = ∫ Dξ F[ξ] |ψ(t)[ξ]⟩⟨ψ(t)[ξ]|

F[ξ]: Influence functional (captures bath effects)
|ψ(t)[ξ]⟩: System state conditioned on bath history ξ
```

**Advantages:**
- Numerically exact (controlled error)
- Handles structured baths
- Captures non-Markovian effects
- Efficient for moderate times

**Reference:** Strathearn et al., *Nat. Commun.* (2018)

---

### **Spectral Densities**

**Ohmic:**
```
J(ω) = α ω exp(-ω/ω_c)

Examples: Metallic leads, RC circuits
```

**Super-Ohmic:**
```
J(ω) = α ω³ exp(-ω/ω_c)

Examples: Acoustic phonons, 3D vibrations
```

**Sub-Ohmic:**
```
J(ω) = α ω^s exp(-ω/ω_c),  s < 1

Examples: 1/f noise, fractional baths
```

**Parameters:**
- α: Coupling strength (dimensionless)
- ω_c: Cutoff frequency (rad/s)
- s: Power law exponent

---

### **CAT/EPT Quantities**

**1. Von Neumann Entropy:**
```python
S(t) = -Tr[ρ(t) ln ρ(t)]

# From eigenvalues λ_i
S = -Σ λ_i ln(λ_i)
```

**Physical Meaning:**
- S = 0: Pure state (no entanglement with bath)
- S > 0: Mixed state (entangled with bath)
- S_max = ln(d): Maximally mixed

**2. Dissipation Rate:**
```python
λ(t) = (1/k_B) dS/dt

# Units: s^-1
```

**Physical Meaning:**
- Rate of entropy production
- Quantifies irreversibility
- Peaks during decoherence transient

**3. Entropic Time:**
```python
τ_ent(t) = ∫_0^t λ(t') dt'

# Accumulated dissipation
```

**Physical Meaning:**
- Total entropic "cost" of evolution
- Monotonically increasing
- Dimensionless time parameter in CAT/EPT

---

## 📖 API Reference

### **Configuration: OQuPyConfig**

```python
@dataclass
class OQuPyConfig:
    # System
    system_dimension: int = 2
    
    # Time evolution
    t_start: float = 0.0  # s
    t_end: float = 1e-12  # s
    dt: float = 1e-15     # s
    
    # Bath
    bath_type: str = "ohmic"
    temperature: float = 300.0  # K
    cutoff_freq: float = 1e13   # rad/s
    coupling_strength: float = 0.1
    
    # TEMPO
    tempo_dt: float = 1e-15     # s
    tempo_dkmax: int = 100      # Memory depth
    epsrel: float = 1e-6        # Error tolerance
    
    # CAT/EPT
    cat_ept_enabled: bool = True
    extract_lambda: bool = True
    k_B: float = 1.380649e-23   # J/K
```

---

### **Main Methods**

#### **make_oqupy_adapter()**

```python
def make_oqupy_adapter(
    config: Optional[Dict[str, Any]] = None
) -> OQuPyAdapter

"""Factory function for OQuPy adapter"""
```

**Example:**
```python
adapter = make_oqupy_adapter({
    'system_dimension': 2,
    'temperature': 300,
    'bath_type': 'ohmic'
})
```

---

#### **run_tempo_dynamics()**

```python
def run_tempo_dynamics(
    self,
    H_sys: np.ndarray,
    rho0: np.ndarray,
    coupling_op: np.ndarray,
    bath: Any = None,
    observables: Optional[Dict[str, np.ndarray]] = None
) -> OQuPyResult
```

**Parameters:**
- `H_sys`: System Hamiltonian (d×d array)
- `rho0`: Initial density matrix (d×d array)
- `coupling_op`: System-bath coupling (d×d array)
- `bath`: OQuPy bath object (optional, created if None)
- `observables`: Dict of operators to track

**Returns:**
- `OQuPyResult` with fields:
  - `times`: Time array
  - `density_matrices`: ρ(t)
  - `entropy`: S(t)
  - `lambda_ent`: λ(t)
  - `tau_ent`: τ_ent(t)
  - `purity`: Tr(ρ²)
  - `coherence`: Off-diagonal magnitude
  - `observables`: Expectation values

---

#### **extract_entropy_trace()**

```python
def extract_entropy_trace(
    self,
    times: np.ndarray,
    density_matrices: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]
```

**Extract S(t), λ(t), τ_ent(t) from existing ρ(t)**

**Parameters:**
- `times`: Time points
- `density_matrices`: ρ(t) array (T×d×d)

**Returns:**
- `entropy`: S(t)
- `lambda_ent`: λ(t)
- `tau_ent`: τ_ent(t)

**Use Case:** When you already have ρ(t) from another source

---

#### **create_bath()**

```python
def create_bath(
    self,
    bath_type: str = None,
    temperature: float = None,
    cutoff_freq: float = None,
    coupling_strength: float = None
) -> Any
```

**Create OQuPy bath object**

**Bath Types:**
- `'ohmic'`: J(ω) ∝ ω
- `'super_ohmic'`: J(ω) ∝ ω³
- `'sub_ohmic'`: J(ω) ∝ ω^0.5

---

### **Results: OQuPyResult**

```python
@dataclass
class OQuPyResult:
    times: np.ndarray           # Time points (s)
    density_matrices: np.ndarray  # ρ(t), shape (T, d, d)
    
    # CAT/EPT
    entropy: np.ndarray         # S(t)
    lambda_ent: np.ndarray      # λ(t) s^-1
    tau_ent: np.ndarray         # τ_ent(t) s
    
    # Observables
    observables: Dict[str, np.ndarray]
    purity: np.ndarray          # Tr(ρ²)
    coherence: np.ndarray       # Off-diagonals
```

---

## 🔬 Workflows

### **Workflow 1: Basic Spin-Boson**

See `oqupy_workflows_catept.py` - Workflow 1

**Purpose:** Demonstrate basic OQuPy + CAT/EPT usage

**System:** Two-level system + ohmic bath

**Output:** S(t), λ(t), τ_ent(t), purity, coherence

---

### **Workflow 2: Temperature Scan**

See `oqupy_workflows_catept.py` - Workflow 2

**Purpose:** Study T-dependence of CAT/EPT quantities

**Range:** 10 K to 500 K

**Analysis:** λ_max(T), τ_ent(T), scaling exponents

---

### **Workflow 3: Quantum Dot + Kwant**

See `oqupy_workflows_catept.py` - Workflow 3

**Purpose:** Integration with quantum transport

**Components:**
- OQuPy: Phonon bath decoherence
- Kwant: Lead-to-lead transport
- CAT/EPT: Unified λ field

**Output:** Conductance with realistic dissipation

---

### **Workflow 4: Bath Comparison**

See `oqupy_workflows_catept.py` - Workflow 4

**Purpose:** Compare spectral densities

**Baths:** Ohmic, super-ohmic, sub-ohmic

**Analysis:** How bath spectrum affects λ(t)

---

## 🔗 Integration Patterns

### **Pattern 1: OQuPy → Kwant**

```python
# Step 1: OQuPy for open dynamics
oqupy_adapter = make_oqupy_adapter({...})
oqupy_result = oqupy_adapter.run_tempo_dynamics(...)

# Extract λ_ent
lambda_avg = np.mean(oqupy_result.lambda_ent)

# Step 2: Use in Kwant
from catsim_core.transport.kwant_adapter import make_kwant_adapter

kwant_adapter = make_kwant_adapter({
    'lambda_ent': lambda_avg,
    'cat_ept_enabled': True
})

# Transport with OQuPy-derived dissipation
conductance = kwant_adapter.compute_conductance(energies)
```

**Use Case:** Quantum dot with phonon bath connected to leads

---

### **Pattern 2: OQuPy → qutip**

```python
# OQuPy for non-Markovian bath
# Extract Lindblad operators from λ(t)

# Use in qutip master equation
import qutip as qt

# Derive collapse operators from OQuPy result
gamma = np.mean(oqupy_result.lambda_ent)
c_ops = [np.sqrt(gamma) * qt.sigmam()]

# Lindblad equation
result = qt.mesolve(H, psi0, times, c_ops, [...])
```

**Use Case:** Hybrid non-Markovian + Markovian simulation

---

## 💡 Best Practices

### **DO:**

✅ **Start with short times**
- OQuPy memory requirement grows with time
- Test with t_end ~ 1 ps before scaling up

✅ **Converge TEMPO parameters**
- Vary `tempo_dkmax` until results stable
- Check `epsrel` sensitivity

✅ **Use appropriate bath**
- Metallic leads: Ohmic
- Phonons: Super-ohmic
- Charge noise: Sub-ohmic

✅ **Save intermediate results**
- TEMPO calculations can be expensive
- Cache `density_matrices` for reanalysis

✅ **Validate against known limits**
- Weak coupling: Compare to Markovian
- High temperature: Compare to classical

---

### **DON'T:**

❌ **Don't ignore convergence**
- Unconverged TEMPO gives wrong physics
- Always check dkmax, dt, epsrel

❌ **Don't use too-small dt**
- Makes calculation slow
- dt ~ 1 fs is often sufficient

❌ **Don't exceed memory limits**
- TEMPO scales as O(dkmax²)
- For long times, consider splitting

❌ **Don't forget units**
- Energy: eV
- Time: seconds
- Temperature: Kelvin

---

## ⚠️ Troubleshooting

### **Problem: OQuPy not found**

```
ImportError: OQuPy not installed
```

**Solution:**
```bash
pip install oqupy
```

Or from source:
```bash
git clone https://github.com/tempoCollaboration/OQuPy.git
cd OQuPy
pip install -e .
```

---

### **Problem: TEMPO too slow**

**Symptoms:** Calculation takes hours

**Solutions:**
1. Reduce `tempo_dkmax` (memory depth)
2. Increase `tempo_dt` (timestep)
3. Increase `epsrel` (error tolerance)
4. Shorten `t_end` (total time)

**Example:**
```python
# Fast (less accurate)
config = {
    'tempo_dkmax': 50,    # Was 100
    'epsrel': 1e-4,       # Was 1e-6
    't_end': 5e-13        # Was 1e-12
}
```

---

### **Problem: Entropy decreases**

**Symptoms:** S(t) not monotonic

**Causes:**
1. Numerical errors in TEMPO
2. Insufficient convergence
3. Purity artifacts

**Solutions:**
1. Increase `tempo_dkmax`
2. Decrease `epsrel`
3. Use finer `tempo_dt`

---

### **Problem: λ negative**

**Symptoms:** lambda_ent < 0

**Cause:** Numerical noise in dS/dt

**Solution:** We enforce λ ≥ 0 by default

**If persistent:**
1. Smooth S(t) before differentiation
2. Use finer time grid
3. Check TEMPO convergence

---

## 📚 References

### **OQuPy Library**

**Paper:** Strathearn, A., Kirton, P., Kilda, D., Keeling, J. & Lovett, B. W.  
"Efficient non-Markovian quantum dynamics using time-evolving matrix product operators"  
*Nature Communications* **9**, 3322 (2018)  
DOI: [10.1038/s41467-018-05617-3](https://doi.org/10.1038/s41467-018-05617-3)

**GitHub:** https://github.com/tempoCollaboration/OQuPy

**Documentation:** https://oqupy.readthedocs.io/

---

### **TEMPO Method**

**Reviews:**
- Makri, N. & Makarov, D. E. "Tensor propagator for iterative quantum time evolution"  
  *J. Chem. Phys.* **102**, 4600 (1995)

- Prior, J., Chin, A. W., Huelga, S. F. & Plenio, M. B.  
  "Efficient simulation of strong system-environment interactions"  
  *Phys. Rev. Lett.* **105**, 050404 (2010)

---

### **CAT/EPT Integration**

**This Framework:**
- See `PHYSICS_VALIDATION_REPORT.md` for validation
- See `COMPLETE_API_REFERENCE.md` for full API
- See `tutorial_1_getting_started.py` for introduction

---

## 📞 Support

**Issues:** GitHub Issues (CAT/EPT framework)

**OQuPy Issues:** https://github.com/tempoCollaboration/OQuPy/issues

**Community:** Discussions, Slack

**Email:** support@catept-framework.org

---

## ✅ Summary

**OQuPy Adapter Provides:**
- ✅ Non-Markovian open quantum dynamics (TEMPO)
- ✅ Automatic CAT/EPT extraction (S, λ, τ_ent)
- ✅ Multiple bath types (ohmic, super-ohmic, sub-ohmic)
- ✅ Integration with Kwant and qutip
- ✅ Temperature-dependent analysis
- ✅ Fallback mode when OQuPy unavailable

**Use For:**
- Spin-boson models
- Quantum dots with phonons
- Non-Markovian decoherence
- Mesoscopic systems
- Open quantum device simulations

**Start Here:** `oqupy_workflows_catept.py` - Workflow 1

---

**Version:** 1.0  
**Last Updated:** February 10, 2026  
**Status:** ✅ Production Ready
