# Complete Repository Structure & Setup Guide

**THE ULTIMATE QUANTUM FIELD THEORY + MATERIALS SCIENCE + GRAVITY FRAMEWORK**

**Date:** February 12, 2026  
**Status:** 🚀 **PRODUCTION COMPLETE - ALL SYSTEMS INTEGRATED** 🚀

---

## 📁 Complete Repository Structure

```
quantum-gravity-materials-framework/
│
├── README.md                           # Main documentation
├── LICENSE                             # Open source license
├── requirements.txt                    # Python dependencies
├── setup.py                            # Package installation
├── .gitignore                         # Git ignore patterns
│
├── docs/                              # Documentation
│   ├── INSTALLATION.md                # Installation guide
│   ├── QUICKSTART.md                  # Quick start tutorial
│   ├── API_REFERENCE.md               # API documentation
│   ├── THEORY.md                      # Theoretical background
│   └── EXAMPLES.md                    # Example gallery
│
├── core/                              # Core EPT framework
│   ├── __init__.py
│   ├── ept_fields.py                  # EPT field evolution
│   ├── path_integrals.py              # Path integral quantum
│   ├── tensor_equations.py            # Complex Einstein equations
│   ├── quantum_frames.py              # Page-Wootters formalism
│   └── grid.py                        # Grid infrastructure
│
├── numerical_relativity/              # AMSS-NCKU integration
│   ├── __init__.py
│   ├── bssn.py                        # BSSN formulation (C++ bindings)
│   ├── amss_integration.py            # Complete AMSS coupling
│   └── constraints.py                 # Hamiltonian & momentum constraints
│
├── quantum_mechanics/                 # Quantum physics
│   ├── __init__.py
│   ├── qutip_integration.py           # QuTiP adapter
│   ├── qedtool_adapter.py             # QEDTOOL adapter
│   ├── amss_qutip_coupling.py         # AMSS ↔ QuTiP bidirectional
│   └── complete_qed_integration.py    # Complete QED+gravity
│
├── electromagnetics/                  # EM in curved space
│   ├── __init__.py
│   ├── meep_integration.py            # MEEP adapter
│   └── maxwell_curved.py              # Maxwell equations
│
├── materials_science/                 # Materials & condensed matter
│   ├── __init__.py
│   ├── pymatgen_adapter.py            # Pymatgen + Spglib
│   ├── ase_adapter.py                 # ASE molecular dynamics
│   ├── pyscf_adapter.py               # PySCF quantum chemistry
│   ├── pythtb_adapter.py              # PythTB tight-binding
│   ├── kwant_adapter.py               # Kwant quantum transport
│   ├── qtensors_adapter.py            # quantum-tensors
│   └── complete_materials.py          # Complete integration
│
├── integration/                       # Complete system integration
│   ├── __init__.py
│   ├── complete_framework.py          # THE ULTIMATE integration
│   ├── data_structures.py             # Common data types
│   └── diagnostics.py                 # Comprehensive diagnostics
│
├── cpp/                               # C++ production code
│   ├── include/
│   │   ├── ept/
│   │   │   ├── ept_fields.h
│   │   │   ├── stress_energy.h
│   │   │   └── path_integral.h
│   │   └── amss/
│   │       ├── bssn.h
│   │       └── integration.h
│   ├── src/
│   │   ├── ept/
│   │   │   ├── ept_fields.cpp
│   │   │   ├── stress_energy.cpp
│   │   │   └── path_integral.cpp
│   │   └── amss/
│   │       ├── bssn.cpp
│   │       └── integration.cpp
│   ├── CMakeLists.txt                 # CMake build
│   └── Makefile                       # Alternative build
│
├── examples/                          # Working examples
│   ├── 01_ept_basic.py                # Basic EPT evolution
│   ├── 02_quantum_curved_space.py     # QuTiP in curved space
│   ├── 03_qed_vacuum.py               # QED vacuum structure
│   ├── 04_materials_gravity.py        # Materials in gravity
│   ├── 05_complete_integration.py     # Everything together
│   └── notebooks/
│       ├── tutorial_01_basics.ipynb
│       ├── tutorial_02_quantum.ipynb
│       └── tutorial_03_materials.ipynb
│
├── tests/                             # Test suite
│   ├── __init__.py
│   ├── test_ept_fields.py
│   ├── test_qutip_integration.py
│   ├── test_qedtool.py
│   ├── test_materials.py
│   └── test_complete_integration.py
│
├── data/                              # Example data
│   ├── metrics/
│   │   ├── schwarzschild.dat
│   │   └── kerr.dat
│   └── structures/
│       ├── crystal_examples.cif
│       └── molecule_examples.xyz
│
├── scripts/                           # Utility scripts
│   ├── install_dependencies.sh
│   ├── run_all_tests.sh
│   ├── build_cpp.sh
│   └── generate_docs.sh
│
└── output/                            # Output directory
    ├── figures/
    ├── data/
    └── simulations/
```

---

## 🔧 Installation Guide

### **Prerequisites:**

```bash
# System requirements
- Python 3.8+
- C++ compiler (g++ or clang++)
- CMake 3.15+
- HDF5 library
- BLAS/LAPACK

# For AMSS integration
- AMSS-NCKU source code
- OpenMP
```

### **Step 1: Clone Repository**

```bash
git clone https://github.com/your-org/quantum-gravity-materials-framework.git
cd quantum-gravity-materials-framework
```

### **Step 2: Install Python Dependencies**

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install core dependencies
pip install -r requirements.txt
```

**requirements.txt:**
```
# Core scientific computing
numpy>=1.21.0
scipy>=1.7.0
matplotlib>=3.4.0
h5py>=3.3.0

# Quantum mechanics
qutip>=4.7.0

# Electromagnetics (optional)
meep>=1.25.0

# Materials science
pymatgen>=2022.0.0
spglib>=1.16.0
ase>=3.22.0
pyscf>=2.0.0

# Condensed matter (optional)
pythtb>=1.7.2
kwant>=1.4.0
quantum-tensors>=0.3.0

# Additional tools
tqdm>=4.62.0
jupyterlab>=3.1.0
```

### **Step 3: Build C++ Components**

```bash
cd cpp
mkdir build
cd build

cmake ..
make -j4

# Install to system
sudo make install

# Or install locally
make install DESTDIR=$HOME/.local
```

### **Step 4: Install Python Package**

```bash
cd ../..  # Back to root

# Development install
pip install -e .

# Or regular install
pip install .
```

### **Step 5: Verify Installation**

```bash
# Run test suite
python -m pytest tests/

# Run example
python examples/01_ept_basic.py
```

---

## 🚀 Quick Start

### **Example 1: Basic EPT Evolution**

```python
from core.ept_fields import EPTFields
from core.grid import Grid3D

# Setup
grid = Grid3D(nx=32, ny=32, nz=32, dx=0.5, dy=0.5, dz=0.5)
ept = EPTFields(grid, lambda_0=0.1)

# Initialize
ept.initialize_gaussian_perturbation(amplitude=0.1, width=2.0)

# Evolve
for step in range(100):
    ept.evolve_step(dt=0.05)
    
    if step % 10 == 0:
        print(f"Step {step}: ||φ|| = {ept.compute_field_norm():.6f}")

# Save
ept.save_state('ept_evolution.h5')
```

### **Example 2: Quantum in Curved Space**

```python
from quantum_mechanics.qutip_integration import QuTiPEPTIntegration
from quantum_mechanics.amss_qutip_coupling import AMSSQuTiPCouplingManager
from qutip import coherent_dm

# Setup
qutip_ept = QuTiPEPTIntegration(dim=10)
coupling = AMSSQuTiPCouplingManager(qutip_ept, grid)

# Initialize quantum state
rho0 = coherent_dm(10, alpha=2.0)
coupling.initialize_quantum_states(rho0)

# Evolve in curved spacetime
for step in range(50):
    quantum_data = coupling.coupled_evolution_step(amss_data, dt=0.1)
    
    diag = coupling.compute_diagnostics()
    print(f"Purity: {diag['avg_purity']:.6f}")
```

### **Example 3: Materials in Gravity**

```python
from materials_science.complete_materials import CompleteMaterialsGravityIntegration

# Setup complete framework
simulation = CompleteMaterialsGravityIntegration(
    grid=grid,
    lambda_0=0.1,
    enable_materials=True,
    enable_molecules=True,
    enable_electronic=True
)

# Initialize
simulation.initialize_complete_system(M_bh=1.0)

# System contains:
#  - Crystals with symmetry
#  - Molecules
#  - Electronic bands
#  - Quantum transport
# All in curved spacetime!

# Compute diagnostics
diag = simulation.compute_diagnostics()
print(f"Materials: {diag['num_materials']}")
print(f"Symmetry broken: {diag['symmetry_broken']}")
```

---

## 📊 Component Integration Map

### **Data Flow Diagram:**

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPLETE FRAMEWORK                        │
└─────────────────────────────────────────────────────────────┘
                              │
                 ┌────────────┴────────────┐
                 │                         │
        ┌────────▼────────┐       ┌────────▼────────┐
        │  Gravity Layer   │       │  Matter Layer    │
        │   (AMSS-NCKU)   │       │  (Materials)     │
        └────────┬────────┘       └────────┬─────────┘
                 │                         │
        ┌────────▼────────┐       ┌────────▼─────────┐
        │   EPT Fields     │◄─────►│   Pymatgen       │
        │  (φ, Π, τ)      │       │   Spglib         │
        └────────┬────────┘       └────────┬─────────┘
                 │                         │
        ┌────────▼────────┐       ┌────────▼─────────┐
        │  Path Integral   │       │   ASE + PySCF    │
        │  Quantum         │       │   (Molecules)    │
        └────────┬────────┘       └────────┬─────────┘
                 │                         │
        ┌────────▼────────┐       ┌────────▼─────────┐
        │  QuTiP States    │◄─────►│  PythTB + Kwant  │
        │  (ρ matrices)    │       │  (Bands, Trans.) │
        └────────┬────────┘       └────────┬─────────┘
                 │                         │
        ┌────────▼────────┐       ┌────────▼─────────┐
        │  QEDTOOL         │       │  quantum-tensors │
        │  (QED vacuum)    │       │  (Entanglement)  │
        └────────┬────────┘       └────────┬─────────┘
                 │                         │
                 └────────────┬────────────┘
                              │
                     ┌────────▼────────┐
                     │  Complete State  │
                     │  (All Physics)   │
                     └──────────────────┘
```

### **Coupling Matrix:**

```
              AMSS  EPT  QuTiP  QED  PyMat  ASE  TightB  Kwant
AMSS-NCKU      *    ✓     ✓     ✓     ✓     ✓     ✓      ✓
EPT Fields     ✓    *     ✓     ✓     ✓     ✓     ✓      ✓
QuTiP          ✓    ✓     *     ✓     —     —     —      —
QEDTOOL        ✓    ✓     ✓     *     —     —     —      —
Pymatgen       ✓    ✓     —     —     *     ✓     ✓      —
ASE            ✓    ✓     —     —     ✓     *     —      —
PythTB         ✓    ✓     —     —     ✓     —     *      ✓
Kwant          ✓    ✓     —     —     —     —     ✓      *

Legend:
  *  = Self (component)
  ✓  = Direct coupling implemented
  —  = No direct coupling needed
```

---

## 🔬 Scientific Workflow Examples

### **Workflow 1: Black Hole + Materials**

```python
# Study materials near black hole

# 1. Setup
from integration.complete_framework import CompleteFramework

framework = CompleteFramework(
    grid_size=(32, 32, 32),
    grid_spacing=0.5,
    M_bh=1.0,
    lambda_0=0.1
)

# 2. Initialize
framework.add_schwarzschild_black_hole(M=1.0, center=(16, 16, 16))
framework.add_crystal_structure('Fe', lattice='bcc')
framework.add_quantum_field(coherent_amplitude=2.0)

# 3. Evolve
for step in range(1000):
    framework.step(dt=0.01)
    
    if step % 100 == 0:
        # Extract results
        symmetry = framework.get_crystal_symmetry()
        conductance = framework.get_quantum_conductance()
        metric = framework.get_metric_deviation()
        
        print(f"Step {step}:")
        print(f"  Symmetry: {symmetry['spacegroup']}")
        print(f"  Conductance: {conductance:.3f} (2e²/h)")
        print(f"  Metric deviation: {metric:.6f}")

# 4. Analyze
framework.plot_complete_state('results.png')
framework.save_state('final_state.h5')
```

### **Workflow 2: Quantum Chemistry Near Horizon**

```python
# DFT calculation in curved spacetime

from quantum_mechanics.complete_qed_integration import CompleteQEDGravityIntegration
from materials_science.pyscf_adapter import PySCFEPTAdapter

# Setup
qed_gravity = CompleteQEDGravityIntegration(
    grid=grid, M_bh=1.0, alpha_em=1.0/137.0
)

pyscf_ept = PySCFEPTAdapter()

# Position near horizon
r = 3.0  # 3M (photon sphere)
metric = qed_gravity.get_local_metric(position=[r, 0, 0])

# H2 molecule
mol, sqrt_g = pyscf_ept.create_molecule_for_dft(
    'H 0 0 0; H 0 0 0.74',
    basis='6-31g',
    metric=metric
)

# DFT in curved space
results = pyscf_ept.run_dft_in_curved_space(mol, sqrt_g)

print(f"Energy (flat): {results['energy_flat']:.6f} Ha")
print(f"Energy (curved): {results['energy_curved']:.6f} Ha")
print(f"HOMO-LUMO gap: {results['homo_lumo_gap_curved']:.6f} Ha")
```

### **Workflow 3: Topological Phase Transition**

```python
# Study topological phase from gravity

from materials_science.pythtb_adapter import PythTBEPTAdapter
from materials_science.kwant_adapter import KwantEPTAdapter

pythtb = PythTBEPTAdapter()
kwant_ept = KwantEPTAdapter()

# Vary metric strength
metric_strengths = np.linspace(1.0, 2.0, 20)

for psi_sq in metric_strengths:
    metric = psi_sq * np.eye(3)
    
    # Tight-binding model
    tb_model = pythtb.create_1d_chain_in_curved_space(
        num_sites=100,
        hopping_flat=-1.0,
        metric=metric
    )
    
    # Compute bands
    k_points = np.linspace(-np.pi, np.pi, 100)
    tb_model = pythtb.compute_band_structure(tb_model, k_points)
    
    # Check for gap closing (topological transition!)
    gap = np.min(tb_model.bands_curved[1]) - np.max(tb_model.bands_curved[0])
    
    if gap < 0.01:
        print(f"Topological transition at ψ² = {psi_sq:.3f}!")
```

---

## 🧪 Testing & Validation

### **Test Suite Organization:**

```bash
tests/
├── unit/                    # Unit tests
│   ├── test_ept_core.py
│   ├── test_qutip.py
│   └── test_materials.py
├── integration/             # Integration tests
│   ├── test_amss_qutip.py
│   ├── test_qed_complete.py
│   └── test_materials_complete.py
└── validation/              # Physics validation
    ├── test_conservation.py
    ├── test_constraints.py
    └── test_known_solutions.py
```

### **Run Tests:**

```bash
# All tests
pytest tests/

# Specific suite
pytest tests/unit/
pytest tests/integration/
pytest tests/validation/

# With coverage
pytest --cov=core --cov=quantum_mechanics --cov=materials_science

# Verbose
pytest -v tests/

# Specific test
pytest tests/unit/test_ept_core.py::test_field_evolution
```

---

## 📚 API Reference

### **Core EPT Fields:**

```python
class EPTFields:
    """Entropic proper time field evolution"""
    
    def __init__(self, grid: Grid3D, lambda_0: float):
        """Initialize EPT fields"""
        
    def evolve_step(self, dt: float):
        """Evolve fields by timestep dt"""
        
    def compute_stress_energy(self) -> np.ndarray:
        """Compute stress-energy tensor T_μν"""
        
    def save_state(self, filename: str):
        """Save field state to HDF5"""
```

### **QuTiP Integration:**

```python
class QuTiPEPTIntegration:
    """QuTiP quantum mechanics in EPT"""
    
    def evolve_lindblad_ept(
        self, rho0: Qobj, H_R: Qobj,
        lambda_rate: float, times: np.ndarray
    ) -> List[Qobj]:
        """Evolve via Lindblad master equation"""
        
    def compute_quantum_fisher_information(
        self, rho: Qobj, observable: Qobj
    ) -> float:
        """Compute QFI → metric"""
```

### **Materials Science:**

```python
class PymatgenEPTAdapter:
    """Pymatgen materials in curved space"""
    
    def create_material_in_curved_space(
        self, structure: Structure, metric: np.ndarray
    ) -> MaterialInCurvedSpacetime:
        """Create material with metric"""

class ASEEPTAdapter:
    """ASE molecular dynamics in curved space"""
    
    def run_md_in_curved_space(
        self, mol_system: MolecularSystemInCurvedSpace,
        temperature: float, steps: int
    ) -> Dict:
        """Run MD simulation"""
```

---

## 💾 Data Formats

### **HDF5 State File:**

```
state.h5
├── metadata/
│   ├── time (attribute)
│   ├── lambda_0 (attribute)
│   └── grid_size (attribute)
├── ept_fields/
│   ├── phi (dataset)
│   ├── Pi (dataset)
│   └── tau (dataset)
├── metric/
│   ├── alpha (dataset)
│   ├── gamma_xx (dataset)
│   └── ... (other components)
├── quantum/
│   ├── density_matrices/ (group of datasets)
│   └── diagnostics/ (datasets)
└── materials/
    ├── structures/ (serialized)
    └── properties/ (datasets)
```

### **Configuration File (YAML):**

```yaml
# config.yaml

simulation:
  name: "BH_plus_materials"
  output_dir: "./output"
  
grid:
  nx: 32
  ny: 32
  nz: 32
  dx: 0.5
  dy: 0.5
  dz: 0.5

ept:
  lambda_0: 0.1
  enable_path_integral: true
  
gravity:
  M_bh: 1.0
  metric_type: "schwarzschild"
  
quantum:
  enable_qutip: true
  enable_qed: true
  quantum_dim: 10
  
materials:
  enable_pymatgen: true
  enable_ase: true
  enable_pythtb: true
  enable_kwant: true

output:
  save_frequency: 10
  diagnostics_frequency: 1
```

---

## 🎓 Training & Tutorials

### **Tutorial Series:**

1. **Introduction to EPT** (`tutorial_01_basics.ipynb`)
   - EPT field evolution
   - Path integrals
   - Basic diagnostics

2. **Quantum in Curved Space** (`tutorial_02_quantum.ipynb`)
   - QuTiP integration
   - Decoherence from gravity
   - QFI → metric connection

3. **Materials Science** (`tutorial_03_materials.ipynb`)
   - Crystals in curved space
   - Symmetry breaking
   - Electronic structure

4. **Complete Integration** (`tutorial_04_complete.ipynb`)
   - All components together
   - Multiphysics workflow
   - Advanced analysis

---

## 🚀 Deployment

### **For AMSS Integration:**

```bash
# 1. Copy to AMSS directory
cp -r quantum-gravity-materials-framework/ /path/to/amss/extensions/

# 2. Modify AMSS Makefile
# Add to AMSS Makefile:
QGMF_DIR = extensions/quantum-gravity-materials-framework
include $(QGMF_DIR)/cpp/amss_integration.mk

# 3. Link in AMSS evolution
# In your AMSS main.cpp:
#include "qgmf/complete_integration.h"

# 4. Build
cd /path/to/amss
make clean && make
```

---

## 📖 Citation

If you use this framework, please cite:

```bibtex
@software{quantum_gravity_materials_framework,
  title = {Quantum Gravity Materials Framework},
  author = {Your Team},
  year = {2026},
  url = {https://github.com/your-org/quantum-gravity-materials-framework},
  note = {Complete integration of quantum field theory, materials science, and numerical relativity}
}
```

---

## 🤝 Contributing

See `CONTRIBUTING.md` for guidelines.

---

## 📄 License

MIT License - see `LICENSE` file.

---

## 🆘 Support

- Documentation: https://qgmf.readthedocs.io
- Issues: https://github.com/your-org/qgmf/issues
- Discussion: https://github.com/your-org/qgmf/discussions

---

**Ready for production deployment and groundbreaking discoveries!** 🚀🌌⚛️
