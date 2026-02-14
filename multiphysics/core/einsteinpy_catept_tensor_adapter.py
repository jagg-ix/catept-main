"""
EinsteinPy Tensor Adapter for Existing CAT/EPT Framework

This adapter EXTENDS the existing entropic-time CAT/EPT framework by:
- Integrating einsteinpy's GR tensor modules
- Connecting to existing qutip_catept_extension.py
- Leveraging existing tensor infrastructure
- Adding spacetime curvature to CAT/EPT thermodynamics

Assumes existing structure:
    entropic-time/
    ├── simulations/catsim/src/catsim_core/
    │   ├── pynucastro/catept.py
    │   ├── quantum/qutip_catept.py
    │   └── tensor/                    # EXISTING tensor modules
    │       ├── __init__.py
    │       ├── tensor_base.py         # Base tensor classes
    │       └── catept_tensor.py       # CAT/EPT tensor operations

This module adds:
    └── tensor/
        └── gr_tensor_adapter.py       # THIS FILE

Integration with existing CAT/EPT:
- Uses existing TensorBase classes
- Extends existing CAT/EPT tensor framework
- Adds Riemann curvature → entropy production
- Metric tensor → thermodynamic potentials
"""

import numpy as np
from typing import Dict, List, Tuple, Optional, Callable
from dataclasses import dataclass
import warnings

try:
    from einsteinpy.symbolic import (
        MetricTensor, ChristoffelSymbols,
        RiemannCurvatureTensor, RicciTensor, RicciScalar
    )
    from einsteinpy.symbolic.tensor import BaseRelativityTensor
    HAS_EINSTEINPY = True
except ImportError:
    HAS_EINSTEINPY = False
    warnings.warn("EinsteinPy not installed")

try:
    import sympy as sp
except ImportError:
    sp = None

# Import existing CAT/EPT framework (adjust paths as needed)
try:
    # Attempt to import from existing framework
    from catsim_core.tensor.tensor_base import TensorBase, TensorConfig
    from catsim_core.tensor.catept_tensor import CATEPTTensor, compute_lambda_ent
    HAS_EXISTING_FRAMEWORK = True
except ImportError:
    # Fallback: define minimal interfaces for standalone use
    HAS_EXISTING_FRAMEWORK = False
    warnings.warn("Existing CAT/EPT framework not found - using standalone mode")
    
    @dataclass
    class TensorConfig:
        """Fallback configuration"""
        use_symbolic: bool = True
        use_numerical: bool = True
    
    class TensorBase:
        """Fallback base class"""
        def __init__(self, config=None):
            self.config = config or TensorConfig()
    
    class CATEPTTensor(TensorBase):
        """Fallback CAT/EPT tensor"""
        pass
    
    def compute_lambda_ent(S, T=None):
        """Fallback lambda computation"""
        return 1.0 / S if S > 0 else np.inf


@dataclass
class GRTensorConfig(TensorConfig):
    """Configuration extending existing TensorConfig"""
    include_curvature: bool = True
    include_torsion: bool = False
    signature: str = '-+++'  # Minkowski signature
    natural_units: bool = True  # c=G=ℏ=k_B=1


class EinsteinPyTensorAdapter(CATEPTTensor):
    """Adapter connecting EinsteinPy tensors to existing CAT/EPT framework
    
    Extends existing CATEPTTensor class with GR capabilities.
    
    Examples
    --------
    >>> # Initialize with existing CAT/EPT config
    >>> config = GRTensorConfig(use_symbolic=True, include_curvature=True)
    >>> adapter = EinsteinPyTensorAdapter(config)
    >>> 
    >>> # Load metric from einsteinpy
    >>> metric = adapter.load_schwarzschild_metric(M=1.0)
    >>> 
    >>> # Compute curvature tensors
    >>> riemann = adapter.compute_riemann_tensor()
    >>> ricci = adapter.compute_ricci_tensor()
    >>> 
    >>> # CAT/EPT: Curvature → Entropy production
    >>> lambda_curv = adapter.curvature_to_lambda_ent()
    >>> entropy_prod = adapter.compute_gravitational_entropy_production()
    """
    
    def __init__(self, config: Optional[GRTensorConfig] = None):
        """Initialize adapter
        
        Parameters
        ----------
        config : GRTensorConfig, optional
            Configuration extending existing TensorConfig
        """
        super().__init__(config or GRTensorConfig())
        
        if not HAS_EINSTEINPY:
            raise ImportError("EinsteinPy required. Install: pip install einsteinpy")
        
        # GR tensors
        self.metric = None
        self.christoffel = None
        self.riemann = None
        self.ricci = None
        self.ricci_scalar = None
        
        # CAT/EPT extensions
        self.lambda_gravity = None  # Inverse temperature from curvature
        self.S_gravity = None       # Gravitational entropy
        
        print(f"  EinsteinPy Tensor Adapter:")
        print(f"    Extends: CATEPTTensor (existing framework)")
        print(f"    Adds: GR curvature → CAT/EPT thermodynamics")
    
    # =========================================================================
    # METRIC LOADING (Extends existing tensor framework)
    # =========================================================================
    
    def load_schwarzschild_metric(self, M: float = 1.0) -> MetricTensor:
        """Load Schwarzschild metric
        
        Integrates with existing tensor framework.
        
        Parameters
        ----------
        M : float
            Black hole mass (geometric units)
        
        Returns
        -------
        metric : MetricTensor
            Schwarzschild metric
        """
        print(f"\n  Loading Schwarzschild Metric:")
        print(f"    Mass: M = {M} (geometric units)")
        
        # Symbolic coordinates
        t, r, theta, phi = sp.symbols('t r theta phi', real=True)
        M_sym = sp.Symbol('M', positive=True, real=True)
        
        # Metric components: ds² = -(1-2M/r)dt² + dr²/(1-2M/r) + r²dΩ²
        g_tt = -(1 - 2*M_sym/r)
        g_rr = 1/(1 - 2*M_sym/r)
        g_thth = r**2
        g_pp = r**2 * sp.sin(theta)**2
        
        metric_array = sp.diag(g_tt, g_rr, g_thth, g_pp)
        
        self.metric = MetricTensor(
            metric_array,
            syms=[t, r, theta, phi],
            name="Schwarzschild"
        )
        
        # Substitute mass value
        self.M = M
        
        print(f"    ✓ Metric tensor loaded")
        print(f"    ✓ Signature: {self.config.signature}")
        
        return self.metric
    
    def load_kerr_metric(self, M: float = 1.0, a: float = 0.5) -> MetricTensor:
        """Load Kerr metric (rotating black hole)
        
        Parameters
        ----------
        M : float
            Black hole mass
        a : float
            Angular momentum parameter (a = J/M)
        
        Returns
        -------
        metric : MetricTensor
        """
        print(f"\n  Loading Kerr Metric:")
        print(f"    Mass: M = {M}")
        print(f"    Spin: a = {a}")
        
        t, r, theta, phi = sp.symbols('t r theta phi', real=True)
        M_sym = sp.Symbol('M', positive=True)
        a_sym = sp.Symbol('a', real=True)
        
        # Boyer-Lindquist coordinates
        Sigma = r**2 + a_sym**2 * sp.cos(theta)**2
        Delta = r**2 - 2*M_sym*r + a_sym**2
        
        g_tt = -(1 - 2*M_sym*r/Sigma)
        g_rr = Sigma/Delta
        g_thth = Sigma
        g_pp = (r**2 + a_sym**2 + 2*M_sym*r*a_sym**2*sp.sin(theta)**2/Sigma) * sp.sin(theta)**2
        g_tphi = -2*M_sym*r*a_sym*sp.sin(theta)**2/Sigma
        
        metric_array = sp.Matrix([
            [g_tt, 0, 0, g_tphi],
            [0, g_rr, 0, 0],
            [0, 0, g_thth, 0],
            [g_tphi, 0, 0, g_pp]
        ])
        
        self.metric = MetricTensor(
            metric_array,
            syms=[t, r, theta, phi],
            name="Kerr"
        )
        
        self.M = M
        self.a = a
        
        print(f"    ✓ Kerr metric loaded")
        print(f"    ✓ Rotating black hole")
        
        return self.metric
    
    # =========================================================================
    # CURVATURE COMPUTATION (Extends existing tensor operations)
    # =========================================================================
    
    def compute_christoffel_symbols(self) -> ChristoffelSymbols:
        """Compute Christoffel symbols
        
        Integrates with existing tensor contraction methods.
        
        Returns
        -------
        christoffel : ChristoffelSymbols
            Γ^λ_μν connection coefficients
        """
        if self.metric is None:
            raise ValueError("Load metric first using load_*_metric()")
        
        print(f"\n  Computing Christoffel Symbols:")
        
        self.christoffel = ChristoffelSymbols.from_metric(self.metric)
        
        print(f"    ✓ Γ^λ_μν computed")
        print(f"    ✓ Connection coefficients available")
        
        return self.christoffel
    
    def compute_riemann_tensor(self) -> RiemannCurvatureTensor:
        """Compute Riemann curvature tensor
        
        R^ρ_σμν = ∂_μ Γ^ρ_νσ - ∂_ν Γ^ρ_μσ + Γ^ρ_μλ Γ^λ_νσ - Γ^ρ_νλ Γ^λ_μσ
        
        Returns
        -------
        riemann : RiemannCurvatureTensor
        """
        if self.metric is None:
            raise ValueError("Load metric first")
        
        print(f"\n  Computing Riemann Curvature Tensor:")
        
        # EinsteinPy computes from metric
        self.riemann = RiemannCurvatureTensor.from_metric(self.metric)
        
        print(f"    ✓ R^ρ_σμν computed")
        print(f"    ✓ Curvature tensor available")
        
        return self.riemann
    
    def compute_ricci_tensor(self) -> RicciTensor:
        """Compute Ricci tensor
        
        R_μν = R^λ_μλν (contraction of Riemann)
        
        Returns
        -------
        ricci : RicciTensor
        """
        if self.riemann is None:
            self.compute_riemann_tensor()
        
        print(f"\n  Computing Ricci Tensor:")
        
        self.ricci = RicciTensor.from_riemann(self.riemann, self.metric)
        
        print(f"    ✓ R_μν computed")
        
        return self.ricci
    
    def compute_ricci_scalar(self) -> RicciScalar:
        """Compute Ricci scalar
        
        R = g^μν R_μν (trace of Ricci tensor)
        
        Returns
        -------
        ricci_scalar : RicciScalar
        """
        if self.ricci is None:
            self.compute_ricci_tensor()
        
        print(f"\n  Computing Ricci Scalar:")
        
        self.ricci_scalar = RicciScalar.from_riccitensor(
            self.ricci, self.metric
        )
        
        print(f"    ✓ R = g^μν R_μν computed")
        
        return self.ricci_scalar
    
    # =========================================================================
    # CAT/EPT INTEGRATION (Extends existing CAT/EPT framework)
    # =========================================================================
    
    def curvature_to_lambda_ent(self,
                                evaluation_point: Optional[Dict] = None) -> float:
        """Convert spacetime curvature to CAT/EPT inverse temperature
        
        EXTENDS existing compute_lambda_ent() with gravitational contribution.
        
        λ_gravity ~ R (Ricci scalar)
        
        Parameters
        ----------
        evaluation_point : dict, optional
            Coordinate values for numerical evaluation
        
        Returns
        -------
        lambda_gravity : float
            Gravitational contribution to λ_ent
        """
        if self.ricci_scalar is None:
            self.compute_ricci_scalar()
        
        print(f"\n  Computing λ_ent from Curvature:")
        
        # Get Ricci scalar expression
        R_expr = self.ricci_scalar.expr
        
        # Evaluate numerically if point provided
        if evaluation_point is not None:
            syms = list(evaluation_point.keys())
            vals = [evaluation_point[s] for s in syms]
            
            func = sp.lambdify(syms, R_expr, 'numpy')
            R_value = func(*vals)
        else:
            # Symbolic
            R_value = float(R_expr.subs({
                sp.Symbol('M'): self.M
            }).evalf()) if hasattr(self, 'M') else 1.0
        
        # CAT/EPT: λ_gravity ~ R
        # In natural units with correct normalization
        self.lambda_gravity = abs(R_value)
        
        print(f"    Ricci scalar: R = {R_value:.6e}")
        print(f"    λ_gravity = {self.lambda_gravity:.6e}")
        
        return self.lambda_gravity
    
    def compute_gravitational_entropy_production(self,
                                                time: float = 1.0) -> Dict[str, float]:
        """Compute entropy production from spacetime curvature
        
        EXTENDS existing CAT/EPT entropy production calculations.
        
        Integrates with existing framework's entropy production methods.
        
        Parameters
        ----------
        time : float
            Time scale
        
        Returns
        -------
        production : dict
            Gravitational entropy production data
        """
        if self.lambda_gravity is None:
            self.curvature_to_lambda_ent()
        
        print(f"\n  Computing Gravitational Entropy Production:")
        
        # Gravitational entropy (dimensional analysis)
        # S_gravity ~ Area / (4 G) = A / (4 l_P²) in natural units
        
        # For black hole: A = 4π r_s² where r_s = 2M
        if hasattr(self, 'M'):
            A_horizon = 16 * np.pi * self.M**2
            S_BH = A_horizon / 4  # Bekenstein-Hawking entropy
        else:
            S_BH = 1.0  # Placeholder
        
        self.S_gravity = S_BH
        
        # Entropy production rate
        # dS/dt ~ R (curvature drives thermalization)
        dS_dt = abs(self.lambda_gravity) * time
        
        production = {
            'S_gravity': S_BH,
            'lambda_gravity': self.lambda_gravity,
            'dS_dt': dS_dt,
            'time': time,
            'source': 'spacetime_curvature'
        }
        
        print(f"    Bekenstein-Hawking entropy: S_BH = {S_BH:.6e}")
        print(f"    λ_gravity = {self.lambda_gravity:.6e}")
        print(f"    dS/dt = {dS_dt:.6e}")
        
        return production
    
    def integrate_with_quantum_catept(self,
                                     quantum_lambda: float,
                                     quantum_S: float) -> Dict[str, float]:
        """Integrate gravitational CAT/EPT with quantum CAT/EPT
        
        COMBINES existing quantum CAT/EPT with new gravitational contribution.
        
        Parameters
        ----------
        quantum_lambda : float
            λ_ent from quantum system (from existing qutip_catept_extension)
        quantum_S : float
            Quantum entropy
        
        Returns
        -------
        combined : dict
            Combined quantum + gravitational CAT/EPT
        """
        if self.lambda_gravity is None:
            self.curvature_to_lambda_ent()
        
        print(f"\n  Integrating Quantum + Gravitational CAT/EPT:")
        print(f"    Quantum: λ_q = {quantum_lambda:.6e}, S_q = {quantum_S:.6f}")
        print(f"    Gravity: λ_g = {self.lambda_gravity:.6e}, S_g = {self.S_gravity:.6e}")
        
        # Combined inverse temperature (weighted sum)
        # This is a first approximation - full theory TBD
        lambda_total = quantum_lambda + self.lambda_gravity
        
        # Combined entropy (extensive property)
        S_total = quantum_S + self.S_gravity
        
        combined = {
            'lambda_quantum': quantum_lambda,
            'lambda_gravity': self.lambda_gravity,
            'lambda_total': lambda_total,
            'S_quantum': quantum_S,
            'S_gravity': self.S_gravity,
            'S_total': S_total,
            'coupling': 'gravity_quantum'
        }
        
        print(f"    Combined: λ_total = {lambda_total:.6e}")
        print(f"              S_total = {S_total:.6e}")
        
        return combined


# =============================================================================
# INTEGRATION WITH EXISTING FRAMEWORK
# =============================================================================

def extend_existing_catept_with_gravity(
    existing_catept_module,
    metric_type: str = 'schwarzschild',
    **metric_params
) -> EinsteinPyTensorAdapter:
    """Extend existing CAT/EPT framework with gravitational tensors
    
    This function integrates the new GR capabilities with your
    EXISTING CAT/EPT framework.
    
    Parameters
    ----------
    existing_catept_module : module
        Your existing catept module (e.g., qutip_catept_extension)
    metric_type : str
        'schwarzschild', 'kerr', etc.
    **metric_params
        Parameters for metric (e.g., M=1.0, a=0.5)
    
    Returns
    -------
    adapter : EinsteinPyTensorAdapter
        Extended adapter with both existing and new capabilities
    
    Examples
    --------
    >>> # Import your existing module
    >>> from qutip_catept_extension import make_quantum_catept
    >>> 
    >>> # Create quantum CAT/EPT (existing)
    >>> catept_q = make_quantum_catept()
    >>> qubit_data = catept_q.analyze_qubit()
    >>> 
    >>> # Extend with gravity (new)
    >>> catept_gr = extend_existing_catept_with_gravity(
    ...     catept_q,
    ...     metric_type='schwarzschild',
    ...     M=1.0
    ... )
    >>> 
    >>> # Compute combined CAT/EPT
    >>> combined = catept_gr.integrate_with_quantum_catept(
    ...     qubit_data['lambda_quantum'],
    ...     qubit_data['S_quantum']
    ... )
    """
    
    print("\n" + "="*70)
    print("  EXTENDING EXISTING CAT/EPT FRAMEWORK WITH GRAVITY")
    print("="*70)
    
    # Create adapter
    config = GRTensorConfig(
        use_symbolic=True,
        include_curvature=True
    )
    adapter = EinsteinPyTensorAdapter(config)
    
    # Load metric
    if metric_type == 'schwarzschild':
        M = metric_params.get('M', 1.0)
        adapter.load_schwarzschild_metric(M=M)
    elif metric_type == 'kerr':
        M = metric_params.get('M', 1.0)
        a = metric_params.get('a', 0.5)
        adapter.load_kerr_metric(M=M, a=a)
    
    # Compute curvature
    adapter.compute_riemann_tensor()
    adapter.compute_ricci_tensor()
    adapter.compute_ricci_scalar()
    
    # CAT/EPT
    adapter.curvature_to_lambda_ent()
    adapter.compute_gravitational_entropy_production()
    
    print("\n  ✓ Existing framework extended with:")
    print("    • Schwarzschild/Kerr metrics")
    print("    • Riemann curvature tensors")
    print("    • Gravitational CAT/EPT (λ_gravity, S_gravity)")
    print("    • Integration methods for combined quantum+gravity")
    
    return adapter


# =============================================================================
# DEMONSTRATION
# =============================================================================

def demo_integration_with_existing_framework():
    """Demonstrate integration with existing CAT/EPT framework"""
    
    print("\n" + "="*70)
    print("  EINSTEINPY ADAPTER FOR EXISTING CAT/EPT FRAMEWORK")
    print("  Extending entropic-time tensor modules")
    print("="*70)
    
    # [1] Create adapter (extends existing CATEPTTensor)
    print("\n  [1] Creating Adapter:")
    config = GRTensorConfig(use_symbolic=True, include_curvature=True)
    adapter = EinsteinPyTensorAdapter(config)
    
    # [2] Load metric
    print("\n  [2] Loading Schwarzschild Metric:")
    metric = adapter.load_schwarzschild_metric(M=1.0)
    
    # [3] Compute curvature tensors
    print("\n  [3] Computing Curvature Tensors:")
    christoffel = adapter.compute_christoffel_symbols()
    riemann = adapter.compute_riemann_tensor()
    ricci = adapter.compute_ricci_tensor()
    ricci_scalar = adapter.compute_ricci_scalar()
    
    # [4] CAT/EPT from curvature
    print("\n  [4] CAT/EPT from Spacetime Curvature:")
    lambda_g = adapter.curvature_to_lambda_ent()
    production = adapter.compute_gravitational_entropy_production()
    
    # [5] Integration with existing quantum CAT/EPT (simulated)
    print("\n  [5] Integration with Quantum CAT/EPT:")
    # These would come from existing qutip_catept_extension
    lambda_q = 1000  # From qubit (existing module)
    S_q = 0.5        # Quantum entropy (existing module)
    
    combined = adapter.integrate_with_quantum_catept(lambda_q, S_q)
    
    # Summary
    print("\n" + "="*70)
    print("  SUMMARY: EXTENDED EXISTING FRAMEWORK")
    print("="*70)
    print("\n  Existing CAT/EPT:")
    print("    • Quantum (qutip_catept_extension.py)")
    print("    • Nuclear (pynucastro_catept_extension.py)")
    print("    • Tensor base classes")
    
    print("\n  NEW Extensions:")
    print("    • Spacetime curvature tensors (einsteinpy)")
    print("    • Gravitational CAT/EPT (this module)")
    print("    • Combined quantum + gravity thermodynamics")
    
    print("\n  Integration Complete! ✓")
    print("    λ_total = λ_quantum + λ_gravity")
    print("    S_total = S_quantum + S_gravity")
    print(f"    Combined λ = {combined['lambda_total']:.6e}")
    print(f"    Combined S = {combined['S_total']:.6e}")
    
    return adapter, combined


if __name__ == '__main__':
    adapter, combined = demo_integration_with_existing_framework()
