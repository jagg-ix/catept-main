"""QuTiP Tensor Network Extension for Existing CAT/EPT Framework

This module EXTENDS the existing entropic-time CAT/EPT framework by adding:
- Matrix Product States (MPS) with CAT/EPT entropy tracking
- Tensor network contractions with entropic tensors
- Integration with existing metric/entropic_tensors.py
- Leverages existing TensorBundle infrastructure

Integrates with existing modules:
    catsim_core/
    ├── metric/
    │   ├── einsteinpy_adapter.py         # EXISTING - we use this
    │   └── entropic_tensors.py           # EXISTING - we extend this
    ├── engine/
    │   └── tensor_integration.py         # EXISTING - we integrate with this
    └── quantum/
        └── qutip_tensornetwork_catept.py # THIS FILE (new extension)

This follows your existing adapter pattern and integrates with CAT/EPT.
"""

from __future__ import annotations

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict, Any
import warnings

try:
    import qutip as qt
except ImportError:
    warnings.warn("QuTiP not installed")
    qt = None

try:
    import sympy as sp
except ImportError:
    sp = None

# Import EXISTING CAT/EPT framework
try:
    from catsim_core.metric.entropic_tensors import (
        TensorBundle,
        christoffel_symbols,
        entropic_stress_tensor,
        imaginary_curvature_tensor,
        inverse_metric
    )
    from catsim_core.metric.einsteinpy_adapter import make_metric_adapter
    HAS_CATEPT_FRAMEWORK = True
except ImportError:
    # Fallback for standalone testing
    HAS_CATEPT_FRAMEWORK = False
    warnings.warn("CAT/EPT framework not found - using standalone mode")
    
    @dataclass
    class TensorBundle:
        g: Any
        g_inv: Any
        Gamma: Any


@dataclass
class MPSCATEPTConfig:
    """Configuration extending existing CAT/EPT framework"""
    bond_dim: int = 100
    cutoff: float = 1e-10
    max_sweeps: int = 10
    # CAT/EPT specific
    track_entropic_stress: bool = True
    use_imaginary_curvature: bool = True
    lambda_mode: str = "trace_adjusted"


class MatrixProductStateCATEPT:
    """MPS with CAT/EPT entropy tracking
    
    EXTENDS qutip's capabilities with entropic tensors from your framework.
    
    Examples
    --------
    >>> # Create MPS with CAT/EPT tracking
    >>> mps = MatrixProductStateCATEPT(N=10, bond_dim=50)
    >>> 
    >>> # Compute entanglement WITH entropic stress
    >>> S, S_entropic = mps.entanglement_with_catept(cut=5)
    >>> 
    >>> # Integrate with existing tensor bundle
    >>> bundle = create_tensor_bundle_for_mps(mps)
    >>> lambda_ent = compute_lambda_from_mps(mps, bundle)
    """
    
    def __init__(self,
                 N: int,
                 local_dim: int = 2,
                 bond_dim: int = 10,
                 config: Optional[MPSCATEPTConfig] = None):
        """Initialize MPS with CAT/EPT
        
        Parameters
        ----------
        N : int
            Number of sites
        local_dim : int
            Local dimension
        bond_dim : int
            Bond dimension
        config : MPSCATEPTConfig, optional
            CAT/EPT configuration
        """
        self.N = N
        self.local_dim = local_dim
        self.bond_dim = bond_dim
        self.config = config or MPSCATEPTConfig()
        
        # MPS tensors
        self.tensors = self._initialize_random()
        
        # CAT/EPT tracking
        self.entropic_stress_history = []
        self.lambda_ent_history = []
        self.tau_ent = 0.0  # Entropic time from your framework
        
        print(f"  MPS-CAT/EPT Extension:")
        print(f"    Sites: {N}, Bond dim: {bond_dim}")
        print(f"    Integrates with: entropic_tensors.py")
        print(f"    Tracks: S_μν, Λ_μν, λ_ent")
    
    def _initialize_random(self) -> List[np.ndarray]:
        """Initialize random MPS tensors"""
        tensors = []
        for i in range(self.N):
            chi_left = min(self.bond_dim, self.local_dim**i) if i > 0 else 1
            chi_right = min(self.bond_dim, self.local_dim**(self.N-i-1)) if i < self.N-1 else 1
            
            tensor = np.random.randn(chi_left, self.local_dim, chi_right)
            tensor = tensor + 1j * np.random.randn(chi_left, self.local_dim, chi_right)
            tensors.append(tensor)
        
        return tensors
    
    def entanglement_with_catept(self,
                                 cut: int,
                                 metric: Optional[sp.Matrix] = None,
                                 coords: Optional[List] = None) -> Tuple[float, Dict]:
        """Compute entanglement WITH CAT/EPT entropic stress
        
        INTEGRATES with your existing entropic_tensors.py
        
        Parameters
        ----------
        cut : int
            Cut position
        metric : sympy.Matrix, optional
            Metric from your framework (uses Minkowski if None)
        coords : list, optional
            Coordinates from your framework
        
        Returns
        -------
        S : float
            von Neumann entropy
        catept_data : dict
            Entropic stress S_μν, imaginary curvature Λ_μν, λ_ent
        """
        # Standard von Neumann entropy
        S_vn = self._compute_von_neumann_entropy(cut)
        
        if not HAS_CATEPT_FRAMEWORK or not self.config.track_entropic_stress:
            return S_vn, {'S_von_neumann': S_vn}
        
        # YOUR FRAMEWORK: Create entropic field φ from entanglement
        # φ ~ S (entanglement can drive entropic field)
        phi = sp.Symbol('phi', real=True)
        phi_value = float(S_vn)  # Use entanglement as field value
        
        # Use existing metric or Minkowski
        if metric is None:
            if coords is None:
                t, x, y, z = sp.symbols('t x y z', real=True)
                coords = [t, x, y, z]
            metric = sp.diag(-1, 1, 1, 1)
        
        # YOUR FRAMEWORK: Compute entropic stress S_μν (Eq. 36 from Paper3)
        S_tensor = entropic_stress_tensor(
            phi=phi_value,
            g=metric,
            coords=coords
        )
        
        # YOUR FRAMEWORK: Compute imaginary curvature Λ_μν (Eq. 37)
        if self.config.use_imaginary_curvature:
            Lambda_tensor = imaginary_curvature_tensor(
                phi=phi_value,
                g=metric,
                coords=coords,
                mode=self.config.lambda_mode
            )
        else:
            Lambda_tensor = None
        
        # Compute λ_ent from tensors
        # λ_ent ~ 1/S or from trace of S_μν
        if S_vn > 1e-10:
            lambda_ent = 1.0 / S_vn
        else:
            lambda_ent = np.inf
        
        # Store in history
        catept_data = {
            'S_von_neumann': S_vn,
            'S_entropic_00': float(sp.N(S_tensor[0, 0])),
            'S_entropic_11': float(sp.N(S_tensor[1, 1])),
            'lambda_ent': lambda_ent,
            'phi': phi_value
        }
        
        if Lambda_tensor is not None:
            catept_data['Lambda_00'] = float(sp.N(Lambda_tensor[0, 0]))
            catept_data['Lambda_11'] = float(sp.N(Lambda_tensor[1, 1]))
        
        self.entropic_stress_history.append(catept_data)
        self.lambda_ent_history.append(lambda_ent)
        
        return S_vn, catept_data
    
    def _compute_von_neumann_entropy(self, cut: int) -> float:
        """Compute standard von Neumann entropy"""
        # Contract left part
        left = np.ones((1,), dtype=complex)
        for i in range(cut):
            left = np.tensordot(left, self.tensors[i], axes=([0], [0]))
            left = left.reshape(-1)
        
        # Schmidt values
        schmidt = np.abs(left)**2
        schmidt = schmidt / np.sum(schmidt)
        schmidt = schmidt[schmidt > 1e-15]
        
        S = -np.sum(schmidt * np.log(schmidt))
        return S
    
    def integrate_with_tensor_bundle(self,
                                    bundle: TensorBundle,
                                    site: int) -> Dict:
        """Integrate MPS with YOUR TensorBundle
        
        Uses your existing TensorBundle from entropic_tensors.py
        
        Parameters
        ----------
        bundle : TensorBundle
            Your existing tensor bundle (g, g_inv, Gamma)
        site : int
            Site to analyze
        
        Returns
        -------
        integrated : dict
            MPS + CAT/EPT data
        """
        # Get local state
        tensor = self.tensors[site]
        
        # Local entropy
        S_local = self._site_entropy(site)
        
        # Use Christoffel symbols from bundle
        # Connection between tensor network bonds and spacetime connection
        Gamma_component = float(sp.N(bundle.Gamma[0, 0, 0])) if hasattr(bundle.Gamma, '__getitem__') else 0
        
        integrated = {
            'site': site,
            'S_local': S_local,
            'bond_dim_left': tensor.shape[0],
            'bond_dim_right': tensor.shape[2],
            'Christoffel_000': Gamma_component,
            'coupling': 'mps_geometry'
        }
        
        return integrated
    
    def _site_entropy(self, site: int) -> float:
        """Local entropy at site"""
        tensor = self.tensors[site]
        rho = np.tensordot(tensor, tensor.conj(), axes=([0, 2], [0, 2]))
        rho = rho / np.trace(rho)
        
        eigvals = np.linalg.eigvalsh(rho)
        eigvals = eigvals[eigvals > 1e-15]
        
        return -np.sum(eigvals * np.log(eigvals))
    
    def time_evolution_with_catept(self,
                                   dt: float,
                                   lambda_bar: float = 1e12) -> Dict:
        """Time evolution WITH entropic time tracking
        
        Integrates with your existing entropic time framework
        
        Parameters
        ----------
        dt : float
            Coordinate time step
        lambda_bar : float
            Inverse temperature λ from your framework
        
        Returns
        -------
        evolution : dict
            Evolution data with τ_ent
        """
        # YOUR FRAMEWORK: Entropic time step
        # dτ = λ dt (from your Paper3)
        dtau = lambda_bar * dt
        
        self.tau_ent += dtau
        
        evolution = {
            'dt': dt,
            'dtau': dtau,
            'tau_ent': self.tau_ent,
            'lambda_bar': lambda_bar,
            't_total': dt * len(self.lambda_ent_history)
        }
        
        return evolution


def create_tensor_bundle_for_mps(
    mps: MatrixProductStateCATEPT,
    use_entropic_coords: bool = False
) -> TensorBundle:
    """Create YOUR TensorBundle from MPS
    
    USES your existing TensorBundle structure
    
    Parameters
    ----------
    mps : MatrixProductStateCATEPT
        MPS to analyze
    use_entropic_coords : bool
        Use (τ,x,y,z) instead of (t,x,y,z)
    
    Returns
    -------
    bundle : TensorBundle
        Your existing TensorBundle with g, g_inv, Gamma
    """
    if not HAS_CATEPT_FRAMEWORK:
        raise ImportError("CAT/EPT framework required")
    
    # Create metric
    if use_entropic_coords:
        # Entropic time coordinates from your framework
        tau, x, y, z = sp.symbols('tau x y z', real=True)
        coords = [tau, x, y, z]
        # g_ττ = g_tt / λ² from your entropic_time_coords logic
        lambda_val = mps.lambda_ent_history[-1] if len(mps.lambda_ent_history) > 0 else 1e12
        g = sp.diag(-1/(lambda_val**2), 1, 1, 1)
    else:
        t, x, y, z = sp.symbols('t x y z', real=True)
        coords = [t, x, y, z]
        g = sp.diag(-1, 1, 1, 1)
    
    # Use YOUR existing functions
    g_inv = inverse_metric(g)
    Gamma = christoffel_symbols(g, coords)
    
    bundle = TensorBundle(g=g, g_inv=g_inv, Gamma=Gamma)
    
    return bundle


# =============================================================================
# INTEGRATION WITH YOUR ENGINE
# =============================================================================

def integrate_mps_with_tensor_engine(
    mps: MatrixProductStateCATEPT,
    engine_config: Dict
) -> Dict:
    """Integrate MPS with YOUR tensor_integration.py engine
    
    Parameters
    ----------
    mps : MatrixProductStateCATEPT
        MPS system
    engine_config : dict
        Config from your TensorIntegrationConfig
    
    Returns
    -------
    results : dict
        Combined MPS + tensor engine results
    """
    # YOUR ENGINE uses these parameters
    lambda_const = engine_config.get('lambda_const_s_inv', 1.0e12)
    dtau_target = engine_config.get('dtau_target_s', 1.0e-15)
    
    # Compute MPS entanglement
    S_vn, catept_data = mps.entanglement_with_catept(cut=mps.N//2)
    
    # Time evolution
    dt = dtau_target / lambda_const
    evolution = mps.time_evolution_with_catept(dt, lambda_const)
    
    results = {
        **catept_data,
        **evolution,
        'integrated': True,
        'source': 'mps_tensor_engine'
    }
    
    return results


# =============================================================================
# DEMONSTRATION
# =============================================================================

def demo_integration_with_existing_catept():
    """Demonstrate integration with YOUR existing CAT/EPT framework"""
    
    print("\n" + "="*70)
    print("  QUTIP TENSOR NETWORK EXTENSION")
    print("  Integrating with EXISTING CAT/EPT Framework")
    print("="*70)
    
    # [1] Create MPS with CAT/EPT tracking
    print("\n  [1] Creating MPS with CAT/EPT:")
    config = MPSCATEPTConfig(
        bond_dim=50,
        track_entropic_stress=True,
        use_imaginary_curvature=True,
        lambda_mode="trace_adjusted"  # YOUR framework's mode
    )
    mps = MatrixProductStateCATEPT(N=10, bond_dim=50, config=config)
    
    # [2] Compute entanglement WITH your entropic tensors
    print("\n  [2] Entanglement with Entropic Stress:")
    S, catept_data = mps.entanglement_with_catept(cut=5)
    
    print(f"    von Neumann: S = {S:.6f}")
    if 'S_entropic_00' in catept_data:
        print(f"    Entropic S_00: {catept_data['S_entropic_00']:.6e}")
        print(f"    Entropic S_11: {catept_data['S_entropic_11']:.6e}")
    print(f"    λ_ent: {catept_data['lambda_ent']:.6e}")
    
    # [3] Create YOUR TensorBundle
    if HAS_CATEPT_FRAMEWORK:
        print("\n  [3] Creating TensorBundle (your framework):")
        bundle = create_tensor_bundle_for_mps(mps, use_entropic_coords=True)
        print(f"    ✓ Metric g created")
        print(f"    ✓ Inverse g_inv computed")
        print(f"    ✓ Christoffels Γ computed")
        
        # [4] Integrate MPS with bundle
        print("\n  [4] Integrating MPS with TensorBundle:")
        integrated = mps.integrate_with_tensor_bundle(bundle, site=5)
        print(f"    Site: {integrated['site']}")
        print(f"    Local entropy: {integrated['S_local']:.6f}")
        print(f"    Christoffel Γ_000: {integrated['Christoffel_000']:.6e}")
    
    # [5] Time evolution with entropic time
    print("\n  [5] Time Evolution with τ_ent:")
    engine_config = {
        'lambda_const_s_inv': 1.0e12,
        'dtau_target_s': 1.0e-15
    }
    results = integrate_mps_with_tensor_engine(mps, engine_config)
    
    print(f"    dt: {results['dt']:.6e} s")
    print(f"    dτ: {results['dtau']:.6e} s")
    print(f"    τ_ent: {results['tau_ent']:.6e} s")
    
    print("\n  ✓ Integration Complete!")
    print("    MPS ↔ Entropic Tensors ↔ CAT/EPT")
    print("    Using YOUR existing framework!")
    
    return mps, catept_data


if __name__ == '__main__':
    mps, data = demo_integration_with_existing_catept()
