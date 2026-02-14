#!/usr/bin/env python3
"""
QuTiP + CAT/EPT Integration Setup
Generates adapters for quantum-GR coupling via entropic proper time

This script creates adapter modules that bridge:
- QuTiP (quantum dynamics)
- einsteinpy (general relativity)
- CAT/EPT framework (entropic time, complex action)

Author: Jorge A. Garcia-Gonzalez
Date: 2026-02-09
"""

import os
import sys
from pathlib import Path

# Color codes
class Colors:
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BOLD = '\033[1m'
    NC = '\033[0m'

def print_header(msg):
    print(f"{Colors.BLUE}{Colors.BOLD}")
    print("═" * 60)
    print(f"  {msg}")
    print("═" * 60)
    print(f"{Colors.NC}")

def print_success(msg):
    print(f"{Colors.GREEN}✓ {msg}{Colors.NC}")

def print_info(msg):
    print(f"{Colors.BLUE}→ {msg}{Colors.NC}")

# Base directory
BASE_DIR = Path("integrations")
ADAPTERS_DIR = BASE_DIR / "adapters"
EXAMPLES_DIR = BASE_DIR / "examples"
TESTS_DIR = BASE_DIR / "tests"

###############################################################################
# ADAPTER 1: ENTROPIC TIME ADAPTER
###############################################################################

ENTROPIC_TIME_ADAPTER = '''"""
Entropic Time Adapter for QuTiP Integration

Provides entropic proper time τ_ent for quantum evolution,
bridging QuTiP dynamics with CAT/EPT framework.
"""

import numpy as np
from typing import Callable, Optional, Tuple
import qutip as qt

class EntropicTimeAdapter:
    """
    Adapter for incorporating entropic time into QuTiP simulations.
    
    Core Concept:
        - Coordinate time t (standard)
        - Entropic time τ_ent = ∫λ(t)dt (irreversibility measure)
        - dτ_ent/dt = λ(t) (dissipation rate)
    
    Usage:
        adapter = EntropicTimeAdapter(lambda_func)
        t_array, tau_array = adapter.compute_dual_time(t_max, dt)
        result = adapter.evolve_with_entropic_time(H, psi0, times)
    """
    
    def __init__(self, 
                 lambda_func: Optional[Callable[[float], float]] = None,
                 lambda_const: float = 0.0):
        """
        Initialize entropic time adapter.
        
        Parameters:
        -----------
        lambda_func : callable, optional
            Time-dependent dissipation rate λ(t)
            If None, uses constant lambda_const
        lambda_const : float
            Constant dissipation rate (default: 0.0 = closed system)
        """
        if lambda_func is not None:
            self.lambda_func = lambda_func
        else:
            self.lambda_func = lambda t: lambda_const
            
        self.lambda_const = lambda_const
        
    def compute_entropic_time(self, 
                             t: np.ndarray) -> np.ndarray:
        """
        Compute entropic time τ_ent from coordinate time.
        
        τ_ent = ∫₀ᵗ λ(t') dt'
        
        Parameters:
        -----------
        t : array_like
            Coordinate time points
            
        Returns:
        --------
        tau_ent : ndarray
            Entropic time corresponding to each t
        """
        tau_ent = np.zeros_like(t)
        
        for i in range(1, len(t)):
            dt = t[i] - t[i-1]
            lambda_avg = 0.5 * (self.lambda_func(t[i-1]) + 
                               self.lambda_func(t[i]))
            tau_ent[i] = tau_ent[i-1] + lambda_avg * dt
            
        return tau_ent
    
    def compute_dual_time(self, 
                         t_max: float, 
                         dt: float = 0.01) -> Tuple[np.ndarray, np.ndarray]:
        """
        Generate dual time arrays (t, τ_ent).
        
        Returns both coordinate and entropic time for simulation.
        """
        t = np.arange(0, t_max, dt)
        tau_ent = self.compute_entropic_time(t)
        return t, tau_ent
    
    def damping_factor(self, tau_ent: float) -> float:
        """
        Compute damping factor exp(-τ_ent).
        
        This multiplies the wave function amplitude:
        |ψ(t)⟩ → exp(-τ_ent(t)/2)|ψ(t)⟩
        """
        return np.exp(-tau_ent)
    
    def evolve_with_entropic_time(self,
                                  H: qt.Qobj,
                                  psi0: qt.Qobj,
                                  times: np.ndarray,
                                  c_ops: Optional[list] = None,
                                  e_ops: Optional[list] = None) -> qt.Result:
        """
        Evolve quantum state with entropic damping.
        
        Solves modified Schrödinger equation:
        iℏ dψ/dt = (H - iH_I)ψ
        
        where H_I incorporates entropic damping.
        
        Parameters:
        -----------
        H : Qobj
            Hamiltonian (can be time-dependent)
        psi0 : Qobj
            Initial state
        times : array_like
            Time points for evolution
        c_ops : list, optional
            Collapse operators (for master equation)
        e_ops : list, optional
            Expectation value operators
            
        Returns:
        --------
        result : Result
            QuTiP result object with entropic damping applied
        """
        # Compute entropic time
        tau_ent = self.compute_entropic_time(times)
        
        # Standard evolution
        if c_ops is not None:
            # Master equation (already has dissipation)
            result = qt.mesolve(H, psi0, times, c_ops, e_ops)
        else:
            # Schrödinger equation
            result = qt.sesolve(H, psi0, times, e_ops)
        
        # Apply entropic damping to states
        if hasattr(result, 'states'):
            damped_states = []
            for i, state in enumerate(result.states):
                damping = np.sqrt(self.damping_factor(tau_ent[i]))
                damped_state = damping * state
                # Renormalize
                damped_state = damped_state.unit()
                damped_states.append(damped_state)
            result.states = damped_states
            
        # Apply damping to expectation values
        if hasattr(result, 'expect'):
            result.expect_original = result.expect.copy()
            for i in range(len(result.expect)):
                damping = self.damping_factor(tau_ent)
                result.expect[i] = result.expect[i] * damping
                
        # Store dual time
        result.tau_ent = tau_ent
        result.coordinate_time = times
        
        return result
    
    def lambda_from_temperature(self, T: float, 
                               omega: float, 
                               hbar: float = 1.0,
                               k_B: float = 1.0) -> float:
        """
        Compute entropic rate from thermal environment.
        
        λ ∝ ω·coth(ℏω/2k_BT)
        
        This gives correct high-T and low-T limits.
        """
        beta = 1.0 / (k_B * T)
        x = hbar * omega * beta / 2.0
        
        if x < 1e-10:
            # High temperature limit
            lambda_thermal = 2 * k_B * T / hbar
        else:
            lambda_thermal = omega / np.tanh(x)
            
        return lambda_thermal
'''

###############################################################################
# ADAPTER 2: EINSTEINPY ADAPTER
###############################################################################

EINSTEINPY_ADAPTER = '''"""
Einsteinpy Adapter for Quantum-GR Coupling

Provides spacetime geometry for quantum systems,
integrating einsteinpy metrics with QuTiP dynamics.
"""

import numpy as np
from typing import Tuple, Optional
try:
    from einsteinpy.metric import Schwarzschild, Kerr
    from einsteinpy.coordinates import CartesianDifferential
    EINSTEINPY_AVAILABLE = True
except ImportError:
    EINSTEINPY_AVAILABLE = False
    print("Warning: einsteinpy not installed")

class SpacetimeAdapter:
    """
    Adapter for coupling quantum dynamics to curved spacetime.
    
    Provides:
    - Proper time dτ from spacetime metric
    - Gravitational redshift
    - Time dilation effects
    - Schwarzschild geometry for black holes
    """
    
    def __init__(self, metric_type: str = "schwarzschild", **params):
        """
        Initialize spacetime adapter.
        
        Parameters:
        -----------
        metric_type : str
            Type of metric: "schwarzschild", "kerr", "flat"
        params : dict
            Metric-specific parameters (e.g., M for mass)
        """
        self.metric_type = metric_type
        self.params = params
        
        if not EINSTEINPY_AVAILABLE and metric_type != "flat":
            raise ImportError("einsteinpy required for curved metrics")
            
        if metric_type == "schwarzschild":
            self.M = params.get('M', 1.0)  # Mass
            self.G = params.get('G', 1.0)  # Newton's constant
            self.c = params.get('c', 1.0)  # Speed of light
            self.r_s = 2 * self.G * self.M / self.c**2
            
    def proper_time_factor(self, r: float) -> float:
        """
        Compute proper time factor dτ/dt at radius r.
        
        For Schwarzschild:
        dτ/dt = √(1 - r_s/r)
        
        Parameters:
        -----------
        r : float
            Radial coordinate (must be > r_s)
            
        Returns:
        --------
        factor : float
            Proper time dilation factor
        """
        if self.metric_type == "flat":
            return 1.0
            
        elif self.metric_type == "schwarzschild":
            if r <= self.r_s:
                raise ValueError(f"r={r} inside horizon r_s={self.r_s}")
            return np.sqrt(1.0 - self.r_s / r)
            
        else:
            raise NotImplementedError(f"Metric {self.metric_type}")
    
    def gravitational_redshift(self, r: float, 
                              omega_infinity: float) -> float:
        """
        Compute gravitationally redshifted frequency.
        
        ω(r) = ω_∞ · √(1 - r_s/r)
        
        Parameters:
        -----------
        r : float
            Radial coordinate
        omega_infinity : float
            Frequency at infinity
            
        Returns:
        --------
        omega_local : float
            Local frequency at radius r
        """
        return omega_infinity * self.proper_time_factor(r)
    
    def schwarzschild_redshift_operator(self, 
                                       r: float,
                                       H_infinity: "qt.Qobj") -> "qt.Qobj":
        """
        Apply gravitational redshift to Hamiltonian.
        
        H(r) = √(1 - r_s/r) · H_∞
        
        Energy is redshifted by proper time factor.
        """
        import qutip as qt
        factor = self.proper_time_factor(r)
        return factor * H_infinity
    
    def horizon_temperature(self) -> float:
        """
        Compute Hawking temperature for Schwarzschild black hole.
        
        T_H = ℏc³/(8πGMk_B)
        """
        if self.metric_type != "schwarzschild":
            raise ValueError("Hawking temp only for black holes")
            
        hbar = self.params.get('hbar', 1.0)
        k_B = self.params.get('k_B', 1.0)
        
        T_H = (hbar * self.c**3) / (8 * np.pi * self.G * self.M * k_B)
        return T_H
'''

###############################################################################
# ADAPTER 3: COMPLEX ACTION ADAPTER
###############################################################################

COMPLEX_ACTION_ADAPTER = '''"""
Complex Action Adapter for CAT/EPT Integration

Implements complex action formalism:
χ = S_R + iℏτ_ent

Provides quantum path integrals with entropic damping.
"""

import numpy as np
import qutip as qt
from typing import Callable, Optional

class ComplexActionAdapter:
    """
    Complex action formalism for quantum systems.
    
    χ = S_R + iS_I = S_R + iℏτ_ent
    
    Provides:
    - Complex action path weight
    - Non-Hermitian effective Hamiltonian
    - Entropy production tracking
    """
    
    def __init__(self, 
                 H_real: qt.Qobj,
                 H_imag: Optional[qt.Qobj] = None,
                 lambda_rate: float = 0.0):
        """
        Initialize complex action adapter.
        
        Parameters:
        -----------
        H_real : Qobj
            Real (reversible) part of Hamiltonian
        H_imag : Qobj, optional
            Imaginary (dissipative) part
            If None, computed from lambda_rate
        lambda_rate : float
            Entropic dissipation rate
        """
        self.H_R = H_real
        
        if H_imag is not None:
            self.H_I = H_imag
        else:
            # Simple proportional model
            self.H_I = lambda_rate * H_real
            
        self.lambda_rate = lambda_rate
        
    def effective_hamiltonian(self) -> qt.Qobj:
        """
        Compute effective non-Hermitian Hamiltonian.
        
        H_eff = H_R - iH_I
        
        This is the generator of complex time evolution.
        """
        return self.H_R - 1j * self.H_I
    
    def complex_evolution(self,
                         psi0: qt.Qobj,
                         times: np.ndarray) -> tuple:
        """
        Evolve under complex Hamiltonian.
        
        iℏ dψ/dt = (H_R - iH_I)ψ
        
        Returns:
        --------
        states : list
            Evolved states (non-normalized)
        norms : array
            Norm evolution (probability leakage)
        entropy_production : array
            Cumulative entropy production
        """
        H_eff = self.effective_hamiltonian()
        
        # Evolve under non-Hermitian H
        result = qt.sesolve(H_eff, psi0, times)
        
        # Track normalization
        norms = np.array([state.norm() for state in result.states])
        
        # Entropy production from norm decrease
        entropy_production = -np.log(norms**2)
        
        return result.states, norms, entropy_production
    
    def path_weight(self, action_real: float, 
                   tau_ent: float,
                   hbar: float = 1.0) -> complex:
        """
        Compute complex path integral weight.
        
        w = exp(iχ/ℏ) = exp(iS_R/ℏ) · exp(-τ_ent)
        
        Parameters:
        -----------
        action_real : float
            Real part of action S_R
        tau_ent : float
            Entropic time τ_ent
        hbar : float
            Planck's constant
            
        Returns:
        --------
        weight : complex
            Complex path weight
        """
        phase = np.exp(1j * action_real / hbar)
        damping = np.exp(-tau_ent)
        return phase * damping
    
    def lindblad_to_complex_h(self, c_ops: list) -> qt.Qobj:
        """
        Convert Lindblad operators to imaginary Hamiltonian.
        
        H_I = (1/2) Σ_k L_k† L_k
        
        This connects to standard open quantum systems.
        """
        H_I = 0
        for L in c_ops:
            H_I = H_I + 0.5 * L.dag() * L
        return H_I
'''

###############################################################################
# EXAMPLE 1: ENTROPIC SCHRÖDINGER EQUATION
###############################################################################

EXAMPLE_ENTROPIC_SCHRODINGER = '''"""
Example: Entropic Schrödinger Equation

Demonstrates quantum evolution with entropic damping.
Shows how CAT/EPT modifies standard quantum dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt
import qutip as qt
from adapters.entropic_time_adapter import EntropicTimeAdapter

def main():
    print("=" * 60)
    print("  Entropic Schrödinger Equation Example")
    print("  Comparing standard vs entropic evolution")
    print("=" * 60)
    print()
    
    # System: Two-level atom
    omega = 1.0  # Transition frequency
    H = 0.5 * omega * qt.sigmaz()  # Hamiltonian
    
    # Initial state: superposition
    psi0 = (qt.basis(2, 0) + qt.basis(2, 1)).unit()
    
    # Time array
    t_max = 10.0
    times = np.linspace(0, t_max, 200)
    
    # === Standard Evolution ===
    print("Running standard Schrödinger evolution...")
    result_standard = qt.sesolve(H, psi0, times, [qt.sigmaz()])
    
    # === Entropic Evolution (λ = constant) ===
    lambda_const = 0.1
    print(f"Running entropic evolution (λ = {lambda_const})...")
    
    adapter = EntropicTimeAdapter(lambda_const=lambda_const)
    result_entropic = adapter.evolve_with_entropic_time(
        H, psi0, times, e_ops=[qt.sigmaz()]
    )
    
    # === Plotting ===
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Panel 1: Expectation value comparison
    ax = axes[0, 0]
    ax.plot(times, result_standard.expect[0], 'b-', label='Standard', lw=2)
    ax.plot(times, result_entropic.expect[0], 'r--', label='Entropic', lw=2)
    ax.set_xlabel('Time t')
    ax.set_ylabel('⟨σ_z⟩')
    ax.set_title('Expectation Value Evolution')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Entropic time
    ax = axes[0, 1]
    ax.plot(times, result_entropic.tau_ent, 'g-', lw=2)
    ax.set_xlabel('Coordinate time t')
    ax.set_ylabel('Entropic time τ_ent')
    ax.set_title(f'Dual Time (λ = {lambda_const})')
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Damping factor
    ax = axes[1, 0]
    damping = adapter.damping_factor(result_entropic.tau_ent)
    ax.plot(times, damping, 'orange', lw=2)
    ax.set_xlabel('Time t')
    ax.set_ylabel('exp(-τ_ent)')
    ax.set_title('Entropic Damping Factor')
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Purity
    ax = axes[1, 1]
    purity_std = [state.purity() for state in result_standard.states]
    purity_ent = [state.purity() for state in result_entropic.states]
    ax.plot(times, purity_std, 'b-', label='Standard', lw=2)
    ax.plot(times, purity_ent, 'r--', label='Entropic', lw=2)
    ax.set_xlabel('Time t')
    ax.set_ylabel('Purity')
    ax.set_title('State Purity Evolution')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('entropic_schrodinger.png', dpi=150, bbox_inches='tight')
    print()
    print("✓ Plot saved: entropic_schrodinger.png")
    print()
    
    # === Analysis ===
    print("Analysis:")
    print(f"  Initial purity:     {purity_std[0]:.4f}")
    print(f"  Final purity (std): {purity_std[-1]:.4f}")
    print(f"  Final purity (ent): {purity_ent[-1]:.4f}")
    print()
    print(f"  Entropic time accumulated: {result_entropic.tau_ent[-1]:.4f}")
    print(f"  Final damping factor:      {damping[-1]:.4f}")
    print()
    
    print("=" * 60)
    print("  Entropic damping suppresses oscillations")
    print("  while preserving quantum coherence")
    print("=" * 60)

if __name__ == "__main__":
    main()
'''

###############################################################################
# CREATE FILES
###############################################################################

def create_files():
    """Create all adapter and example files."""
    
    print_header("Creating Integration Files")
    
    # Create adapters
    print_info("Creating adapter modules...")
    
    adapters = [
        ("entropic_time_adapter.py", ENTROPIC_TIME_ADAPTER),
        ("einsteinpy_adapter.py", EINSTEINPY_ADAPTER),
        ("complex_action_adapter.py", COMPLEX_ACTION_ADAPTER),
    ]
    
    for filename, content in adapters:
        filepath = ADAPTERS_DIR / filename
        with open(filepath, 'w') as f:
            f.write(content)
        print_success(f"Created: {filepath}")
    
    # Create __init__.py
    init_content = '''"""
CAT/EPT Integration Adapters

Quantum-GR coupling via entropic proper time.
"""

from .entropic_time_adapter import EntropicTimeAdapter
from .einsteinpy_adapter import SpacetimeAdapter
from .complex_action_adapter import ComplexActionAdapter

__all__ = [
    'EntropicTimeAdapter',
    'SpacetimeAdapter',
    'ComplexActionAdapter',
]
'''
    
    with open(ADAPTERS_DIR / "__init__.py", 'w') as f:
        f.write(init_content)
    print_success(f"Created: {ADAPTERS_DIR / '__init__.py'}")
    
    # Create examples
    print()
    print_info("Creating example scripts...")
    
    examples = [
        ("entropic_schrodinger.py", EXAMPLE_ENTROPIC_SCHRODINGER),
    ]
    
    for filename, content in examples:
        filepath = EXAMPLES_DIR / filename
        with open(filepath, 'w') as f:
            f.write(content)
        os.chmod(filepath, 0o755)
        print_success(f"Created: {filepath}")
    
    # Create README
    print()
    print_info("Creating documentation...")
    
    readme = '''# QuTiP + CAT/EPT Integration

Integration adapters for quantum-gravity coupling via entropic proper time.

## Components

### Adapters (`adapters/`)

1. **EntropicTimeAdapter** - Entropic time integration
   - Dual time evolution (t, τ_ent)
   - Entropic damping
   - Thermal dissipation rates

2. **SpacetimeAdapter** - General relativity coupling
   - Schwarzschild geometry
   - Gravitational redshift
   - Proper time factors

3. **ComplexActionAdapter** - Complex action formalism
   - χ = S_R + iℏτ_ent
   - Non-Hermitian evolution
   - Entropy production tracking

### Examples (`examples/`)

- `entropic_schrodinger.py` - Basic entropic evolution
- (More to come)

## Usage

```python
from adapters import EntropicTimeAdapter
import qutip as qt

# Define system
H = qt.sigmaz()
psi0 = qt.basis(2, 0)

# Create adapter
adapter = EntropicTimeAdapter(lambda_const=0.1)

# Evolve with entropic damping
result = adapter.evolve_with_entropic_time(H, psi0, times)

# Access dual time
t = result.coordinate_time
tau = result.tau_ent
```

## Installation

```bash
pip install qutip einsteinpy numpy scipy matplotlib
```

## Running Examples

```bash
cd integrations/examples
python3 entropic_schrodinger.py
```
'''
    
    with open(BASE_DIR / "README.md", 'w') as f:
        f.write(readme)
    print_success(f"Created: {BASE_DIR / 'README.md'}")
    
    print()
    print_header("Setup Complete!")
    print()
    print("Created integration structure:")
    print(f"  {BASE_DIR}/")
    print(f"    ├── adapters/")
    print(f"    │   ├── __init__.py")
    print(f"    │   ├── entropic_time_adapter.py")
    print(f"    │   ├── einsteinpy_adapter.py")
    print(f"    │   └── complex_action_adapter.py")
    print(f"    ├── examples/")
    print(f"    │   └── entropic_schrodinger.py")
    print(f"    └── README.md")
    print()
    print("Next steps:")
    print("  1. Install dependencies: pip install qutip einsteinpy")
    print("  2. Run example: python3 integrations/examples/entropic_schrodinger.py")
    print()

if __name__ == "__main__":
    create_files()
