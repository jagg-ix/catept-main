# 📖 CAT/EPT Framework - Complete API Reference

**Comprehensive documentation for all adapters and modules**

**Version:** 1.0  
**Date:** February 10, 2026  
**Status:** Production Release  

---

## 📚 Table of Contents

1. [Core Concepts](#core-concepts)
2. [Nuclear Physics (PyNE)](#nuclear-physics-pyne)
3. [Computational Fluid Dynamics (OpenFOAM)](#computational-fluid-dynamics-openfoam)
4. [Quantum Transport (Kwant)](#quantum-transport-kwant)
5. [Electromagnetic (MEEP)](#electromagnetic-meep)
6. [Spacetime Geometry (einsteinpy)](#spacetime-geometry-einsteinpy)
7. [Galactic Dynamics (gala)](#galactic-dynamics-gala)
8. [Cosmology (yt)](#cosmology-yt)
9. [Integration Patterns](#integration-patterns)
10. [Utility Functions](#utility-functions)

---

## 🎯 Core Concepts

### **Universal Parameters**

All adapters share common CAT/EPT parameters:

```python
cat_ept_enabled: bool = True
    # Enable/disable CAT/EPT modifications
    
lambda_ent: float = 1e-17  # s^-1
    # Entropic dissipation rate (fundamental parameter)
    # Typical range: 10^-20 to 10^-12
    
tau_ent: float = 0.0  # s
    # Accumulated entropic time (computed)
```

### **Common Return Types**

```python
Dict[str, Any]
    # Flexible results dictionary
    # Always includes: 'lambda_ent', 'cat_ept_enabled'
    
np.ndarray
    # Numerical results (fields, time series)
    
Tuple[float, float]
    # Paired values (standard, CAT/EPT)
```

---

## ⚛️ Nuclear Physics (PyNE)

**Module:** `catsim_core.nuclear.pyne_adapter`

### **PyNEConfig**

```python
@dataclass
class PyNEConfig:
    cat_ept_enabled: bool = False
    global_lambda: float = 0.0  # s^-1
    kappa_decay: float = 1e-10  # Coupling strength
    data_source: str = "endf"  # Nuclear data
```

### **make_pyne_adapter()**

```python
def make_pyne_adapter(
    config: Optional[Dict[str, Any]] = None
) -> PyNECATEPTAdapter
```

**Factory function** for creating PyNE adapter

**Parameters:**
- `config` (dict, optional): Configuration parameters

**Returns:**
- `PyNECATEPTAdapter`: Configured adapter instance

**Example:**
```python
adapter = make_pyne_adapter({
    'cat_ept_enabled': True,
    'global_lambda': 1e-17
})
```

---

### **PyNEAdapter Methods**

#### `run_bbn()`

```python
def run_bbn(self) -> Dict[str, float]
```

**Big Bang Nucleosynthesis with CAT/EPT**

**Returns:**
```python
{
    'H1': float,      # Hydrogen mass fraction
    'H2': float,      # Deuterium
    'He3': float,     # Helium-3
    'He4': float,     # Helium-4 (Y_p)
    'Li7': float,     # Lithium-7
    'tau_ent': float, # Accumulated τ_ent
    'delta_He4': float # CAT/EPT shift
}
```

**Example:**
```python
bbn = adapter.run_bbn()
print(f"Y_p = {bbn['He4']:.6f}")
```

---

#### `run_stellar_nucleosynthesis()`

```python
def run_stellar_nucleosynthesis(
    star_mass: float,
    metallicity: float = 0.02
) -> Dict[str, Any]
```

**Stellar nucleosynthesis with CAT/EPT**

**Parameters:**
- `star_mass`: Stellar mass (M☉)
- `metallicity`: Initial Z (default: solar)

**Returns:**
```python
{
    'core_composition': Dict[str, float],
    's_process': Dict[str, float],
    'lifetime_standard': float,  # seconds
    'lifetime_catept': float,
    'tau_ent': float
}
```

---

#### `neutron_star_cooling()`

```python
def neutron_star_cooling(
    mass: float = 1.4,
    radius: float = 12.0
) -> Dict[str, Any]
```

**Neutron star cooling with CAT/EPT**

**Parameters:**
- `mass`: NS mass (M☉)
- `radius`: NS radius (km)

**Returns:**
```python
{
    'times': np.ndarray,           # Time array (s)
    'T_surface_standard': np.ndarray,  # K
    'T_surface_catept': np.ndarray,
    'cooling_enhancement': np.ndarray
}
```

**Example:**
```python
cooling = adapter.neutron_star_cooling(mass=1.4)

# Cassiopeia A comparison
t_cas = 330 * 365.25 * 24 * 3600
idx = np.argmin(np.abs(cooling['times'] - t_cas))
T_cas = cooling['T_surface_catept'][idx]
print(f"T(330yr) = {T_cas:.2e} K")
```

---

## 🌊 Computational Fluid Dynamics (OpenFOAM)

**Module:** `catsim_core.cfd.openfoam_adapter`

### **OpenFOAMConfig**

```python
@dataclass
class OpenFOAMConfig:
    # Geometry
    geometry_type: str = "box"
    dimensions: Tuple[float, float, float] = (1.0, 1.0, 1.0)
    
    # Physics
    nu_kinematic: float = 1e-5  # m²/s
    rho: float = 1.0  # kg/m³
    
    # CAT/EPT
    lambda_const: float = 1e-17  # s^-1
    alpha_viscosity: float = 1.0
```

---

### **OpenFOAMAdapter Methods**

#### `compute_entropic_viscosity()`

```python
def compute_entropic_viscosity(
    position: np.ndarray,
    velocity: np.ndarray,
    length_scale: float
) -> float
```

**Compute ν_ent = α·λ·L²/U**

**Parameters:**
- `position`: Position vector (m)
- `velocity`: Velocity vector (m/s)
- `length_scale`: Characteristic length (m)

**Returns:**
- `nu_ent`: Entropic viscosity (m²/s)

---

#### `compute_reynolds_number()`

```python
def compute_reynolds_number(
    U: float,
    L: float,
    time: float = 0.0
) -> Tuple[float, float]
```

**Compute Re_std and Re_eff**

**Parameters:**
- `U`: Velocity scale (m/s)
- `L`: Length scale (m)
- `time`: Current time (s)

**Returns:**
- `(Re_standard, Re_effective)`

**Example:**
```python
Re_std, Re_eff = adapter.compute_reynolds_number(
    U=1.0, L=1.0
)
print(f"Re reduction: {(1 - Re_eff/Re_std)*100:.2f}%")
```

---

#### `setup_case()`

```python
def setup_case(
    case_name: str = "catept_case"
) -> Optional[Path]
```

**Generate OpenFOAM case directory**

**Returns:**
- `Path`: Case directory path (if OpenFOAM available)

---

## ⚛️ Quantum Transport (Kwant)

**Module:** `catsim_core.transport.kwant_adapter`

### **KwantConfig**

```python
@dataclass
class KwantConfig:
    # Lattice
    lattice_type: str = "square"  # "graphene", "triangular"
    width: int = 10
    length: int = 30
    
    # Tight-binding
    t: float = 1.0  # Hopping (eV)
    onsite_energy: float = 0.0  # eV
    
    # CAT/EPT
    lambda_ent: float = 1e-17  # s^-1
    alpha_scattering: float = 1e-10
    beta_decoherence: float = 1e-5
```

---

### **KwantAdapter Methods**

#### `create_system()`

```python
def create_system(self) -> Optional[Any]
```

**Create tight-binding system**

**Returns:**
- `kwant.Builder` or `None`

---

#### `compute_conductance()`

```python
def compute_conductance(
    energies: Optional[np.ndarray] = None
) -> TransportResult
```

**Compute G(E) with CAT/EPT**

**Parameters:**
- `energies`: Energy points (eV)

**Returns:**
```python
TransportResult(
    energies: np.ndarray,
    conductance: np.ndarray,  # e²/h
    transmission: np.ndarray,
    lambda_ent: float
)
```

**Example:**
```python
E = np.linspace(-0.5, 0.5, 100)
result = adapter.compute_conductance(E)

plt.plot(result.energies, result.conductance)
plt.xlabel('Energy (eV)')
plt.ylabel('Conductance (e²/h)')
```

---

#### `quantum_hall_conductance()`

```python
def quantum_hall_conductance(
    filling_factors: np.ndarray
) -> Dict[str, np.ndarray]
```

**QHE with CAT/EPT**

**Returns:**
```python
{
    'nu': np.ndarray,               # Filling factors
    'sigma_xy_std': np.ndarray,     # e²/h
    'sigma_xy_catept': np.ndarray,
    'B_field': float
}
```

---

#### `decoherence_length()`

```python
def decoherence_length(
    energy: float
) -> Tuple[float, float]
```

**Compute L_φ with CAT/EPT**

**Returns:**
- `(L_phi_standard, L_phi_catept)` in nm

---

## 📡 Electromagnetic (MEEP)

**Module:** `catsim_core.em.meep_adapter`

### **Key Methods**

#### `run_enz_visibility_experiment()`

```python
def run_enz_visibility_experiment(
    path_lengths: np.ndarray
) -> Dict[str, np.ndarray]
```

**ENZ visibility decay experiment**

**Returns:**
```python
{
    'S': np.ndarray,           # Path lengths
    'V': np.ndarray,           # Visibility
    'lambda_extracted': float  # Fitted λ
}
```

---

## 🌌 Integration Patterns

### **Pattern 1: Sequential Processing**

```python
# Nuclear → Fluid → Spacetime

# Step 1: Nuclear
nuclear = make_pyne_adapter({'lambda_ent': 1e-17})
stellar = nuclear.run_stellar_nucleosynthesis(M=10)

# Step 2: Fluid (using nuclear results)
cfd = make_openfoam_adapter({'lambda_const': 1e-17})
Re_std, Re_eff = cfd.compute_reynolds_number(
    U=100,  # From stellar convection
    L=1e9   # Convection zone size
)

# Step 3: Spacetime
from catsim_core.metric.einsteinpy_adapter import make_metric_adapter
metric = make_metric_adapter({
    'mass': 10,
    'lambda_ent': 1e-17
})
```

---

### **Pattern 2: Concurrent Coupling**

```python
# EM ↔ Transport ↔ Quantum

# EM fields
meep = make_meep_adapter({'lambda_ent': 1e-17})

# Transport in EM field
kwant = make_kwant_adapter({'lambda_ent': 1e-17})
coupling = kwant.integrate_with_meep()

# Quantum evolution
qutip_result = kwant.integrate_with_qutip()
```

---

### **Pattern 3: Hierarchical**

```python
# Cosmology → Galactic → Stellar

# Load cosmology
from catsim_core.cosmology.yt_adapter import make_yt_analyzer
cosmo = make_yt_analyzer("simulation.hdf5")

# Extract galaxy
from catsim_core.engine.gala_adapter import make_gala_adapter
gala = make_gala_adapter({'lambda_const': 1e-17})

# Stellar population
nuclear = make_pyne_adapter({'global_lambda': 1e-17})
```

---

## 🛠️ Utility Functions

### **Common Utilities**

#### `validate_lambda()`

```python
def validate_lambda(lambda_ent: float) -> bool:
    """Check if λ value is physical"""
    return 1e-25 < lambda_ent < 1e-10
```

#### `compute_tau_ent()`

```python
def compute_tau_ent(
    lambda_ent: float,
    time: float
) -> float:
    """Compute accumulated entropic time"""
    return lambda_ent * time
```

---

## 📊 Data Structures

### **Common Result Types**

```python
# Physics results
PhysicsResult = Dict[str, Union[float, np.ndarray, Dict]]

# Always includes:
result = {
    'lambda_ent': float,
    'tau_ent': float,
    'cat_ept_enabled': bool,
    # ... physics-specific fields
}
```

---

## ⚠️ Error Handling

### **Common Exceptions**

```python
# Missing dependency
if not adapter._library_available:
    # Falls back to theoretical model
    # No exception raised

# Invalid parameter
if lambda_ent < 0 or lambda_ent > 1:
    raise ValueError("λ_ent must be in (0, 1)")

# Computation failure
try:
    result = adapter.compute_something()
except Exception as e:
    logging.error(f"Computation failed: {e}")
    return None
```

---

## 🔍 Quick Reference

### **Most Common Operations**

```python
# Nuclear: BBN
from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
adapter = make_pyne_adapter({'global_lambda': 1e-18})
bbn = adapter.run_bbn()

# Fluid: Reynolds number
from catsim_core.cfd.openfoam_adapter import make_openfoam_adapter
cfd = make_openfoam_adapter({'lambda_const': 1e-17})
Re_std, Re_eff = cfd.compute_reynolds_number(U=1, L=1)

# Quantum: Graphene conductance
from catsim_core.transport.kwant_adapter import make_kwant_adapter
kwant = make_kwant_adapter({'lattice_type': 'graphene'})
kwant.create_system()
kwant.finalize_system()
result = kwant.compute_conductance(np.array([0.0]))

# Multi-physics: Run everything
from multi_physics_integration import workflow_stellar_evolution
stellar = workflow_stellar_evolution()
```

---

## 📚 See Also

- **Tutorials:** Getting started guides
- **Examples:** Complete workflows
- **Validation:** Physics validation report
- **Research Guide:** Application to real problems

---

## 🔄 Version History

**v1.0 (Feb 2026):**
- Initial production release
- 11 functional adapters
- Complete multi-scale integration
- Cassiopeia A validation

---

## 📞 Support

**Documentation:** See guides in `docs/`  
**Issues:** GitHub Issues  
**Community:** Discussions, Slack  
**Email:** support@catept-framework.org  

---

**Last Updated:** February 10, 2026  
**API Version:** 1.0  
**Status:** ✅ Production
