"""
Bridge between i-PI and EinsteinPy/OGRePy framework.

Converts EinsteinPy geodesics → i-PI trajectories
Injects OGRePy-computed α(x), λ(x) → i-PI driver

Workflow:
1. OGRePy: Define metric symbolically, compute α_sym, λ_sym
2. Lambdify: Convert to NumPy functions
3. EinsteinPy: Propagate geodesic, get positions(t)
4. Evaluate: α_vals = α_func(positions)
5. i-PI: Use α_vals, λ_vals in entropic_langevin motion
"""

import numpy as np
from typing import Callable, Dict, Tuple, Optional

try:
    import OGRePy as og
    OGREPY_AVAILABLE = True
except ImportError:
    OGREPY_AVAILABLE = False
    print("Warning: OGRePy not available. Symbolic features disabled.")

try:
    from einsteinpy.geodesic import Geodesic
    EINSTEINPY_AVAILABLE = True
except ImportError:
    EINSTEINPY_AVAILABLE = False
    print("Warning: EinsteinPy not available. Geodesic features disabled.")


class GeodesicToIPIBridge:
    """
    Convert EinsteinPy geodesic trajectories to i-PI format.
    
    Extracts:
    - Positions q(t) for i-PI beads
    - Velocities v(t) for initialization
    - Proper time τ(t) for validation
    """
    
    def __init__(self, geodesic):
        """
        Args:
            geodesic: EinsteinPy Geodesic object
        """
        if not EINSTEINPY_AVAILABLE:
            raise ImportError("EinsteinPy required for geodesic bridge")
        
        self.geodesic = geodesic
        self.trajectory = geodesic.trajectory
    
    def get_positions(self, units="meter"):
        """
        Extract spatial positions from geodesic.
        
        Returns:
            positions: Array [n_steps, 3] in specified units
        """
        # EinsteinPy trajectory format: [proper_time, t, r, theta, phi]
        # or [proper_time, t, x, y, z] depending on coordinates
        
        coords = self.trajectory[1][:, 1:4]  # Skip time coordinate
        
        # Convert to Cartesian if needed
        if getattr(getattr(self.geodesic, "metric", None), "coords_type", "cartesian") == "spherical":
            r = coords[:, 0]
            theta = coords[:, 1]
            phi = coords[:, 2]
            
            x = r * np.sin(theta) * np.cos(phi)
            y = r * np.sin(theta) * np.sin(phi)
            z = r * np.cos(theta)
            
            positions = np.column_stack([x, y, z])
        else:
            positions = coords
        
        return positions
    
    def get_velocities(self):
        """
        Compute velocities from geodesic.
        
        Returns:
            velocities: Array [n_steps, 3] in m/s
        """
        positions = self.get_positions()
        time = self.trajectory[1][:, 0]
        
        # Numerical derivative
        velocities = np.gradient(positions, time, axis=0)
        
        return velocities
    
    def get_proper_time(self):
        """
        Get proper time τ from geodesic.
        
        Returns:
            tau: Array [n_steps] in seconds
        """
        return self.trajectory[0]
    
    def write_ipi_xyz(self, filename, atom_type="H"):
        """
        Write trajectory in i-PI XYZ format.
        
        Args:
            filename: Output file path
            atom_type: Atom symbol (default: H for test particle)
        """
        positions = self.get_positions()
        n_steps = positions.shape[0]
        
        with open(filename, 'w') as f:
            for i in range(n_steps):
                f.write("1\n")
                f.write(f"# Step {i}\n")
                f.write(f"{atom_type}  {positions[i,0]:.6e}  "
                       f"{positions[i,1]:.6e}  {positions[i,2]:.6e}\n")


class SymbolicToDriverBridge:
    """
    Convert OGRePy symbolic expressions to i-PI driver functions.
    
    Workflow:
    1. Create EntropicMetric in OGRePy
    2. Compute α(x), λ(x) symbolically
    3. Lambdify to NumPy functions
    4. Inject into custom i-PI driver
    """
    
    def __init__(self, metric_symbolic):
        """
        Args:
            metric_symbolic: OGRePy EntropicMetric object
        """
        if not OGREPY_AVAILABLE:
            raise ImportError("OGRePy required for symbolic bridge")
        
        self.metric = metric_symbolic
        self.coords = metric_symbolic.coords
        
        # Store lambdified functions
        self._alpha_func = None
        self._lambda_func = None
        self._Pi_func = None
    
    def lambdify_lapse(self, params: Dict) -> Callable:
        """
        Convert α(x) to NumPy function.
        
        Args:
            params: Dictionary of parameter values (e.g., {'r_s': 3000, ...})
            
        Returns:
            alpha_func: Callable(positions) → alpha_values
        """
        alpha_sym = self.metric.gravitational_lapse()
        
        # Get coordinate symbols
        coord_syms = [self.coords.t, self.coords.x, self.coords.y, self.coords.z]
        
        # Get parameter symbols
        param_syms = list(params.keys())
        
        # Lambdify
        import sympy as sp
        alpha_lamb = sp.lambdify(coord_syms + param_syms, alpha_sym, "numpy")
        
        # Wrapper for i-PI format
        def alpha_func(positions):
            """
            Args:
                positions: Array [n_atoms, 3] in meters
            Returns:
                alpha_vals: Array [n_atoms]
            """
            n_atoms = positions.shape[0]
            t = np.zeros(n_atoms)  # Assume time coordinate = 0
            x = positions[:, 0]
            y = positions[:, 1]
            z = positions[:, 2]
            
            # Evaluate
            param_vals = [params[p] for p in param_syms]
            alpha_vals = alpha_lamb(t, x, y, z, *param_vals)
            
            return alpha_vals
        
        self._alpha_func = alpha_func
        return alpha_func
    
    def lambdify_dissipation(self, params: Dict) -> Callable:
        """
        Convert λ(x) to NumPy function.
        
        Args:
            params: Parameter values
            
        Returns:
            lambda_func: Callable(positions, time) → lambda_values
        """
        lambda_sym = self.metric.lambda_sym
        
        coord_syms = [self.coords.t, self.coords.x, self.coords.y, self.coords.z]
        param_syms = list(params.keys())
        
        import sympy as sp
        lambda_lamb = sp.lambdify(coord_syms + param_syms, lambda_sym, "numpy")
        
        def lambda_func(positions, time):
            n_atoms = positions.shape[0]
            t = np.full(n_atoms, time)
            x = positions[:, 0]
            y = positions[:, 1]
            z = positions[:, 2]
            
            param_vals = [params[p] for p in param_syms]
            lambda_vals = lambda_lamb(t, x, y, z, *param_vals)
            
            return lambda_vals
        
        self._lambda_func = lambda_func
        return lambda_func
    
    def create_driver_class(self, base_potential: str = "harmonic") -> type:
        """
        Generate custom driver class with OGRePy-computed functions.
        
        Args:
            base_potential: "harmonic", "gravitational", etc.
            
        Returns:
            DriverClass: Subclass of EntropicDriver with injected functions
        """
        try:
            # Prefer local optional driver base if user does not have i-PI's python driver tree
            from cat_ept_doubleslit.integration.driver_base import EntropicDriver
        except Exception:
            # Fallback to legacy path expected in older dev layouts
            from drivers.py.entropic_drivers import EntropicDriver

        
        alpha_func = self._alpha_func
        lambda_func = self._lambda_func
        
        class OGRePyDriver(EntropicDriver):
            """Auto-generated driver from OGRePy symbolic metric."""
            
            def __init__(self, **kwargs):
                super().__init__(**kwargs)
                self.alpha_func = alpha_func
                self.lambda_func = lambda_func
            
            def compute_potential(self, positions):
                # Base potential (simplified)
                if base_potential == "harmonic":
                    k = 1.0
                    energy = 0.5 * k * np.sum(positions**2)
                    forces = -k * positions
                elif base_potential == "gravitational":
                    M = 1.0 * 1.98892e30
                    G = 6.67430e-11
                    r = np.linalg.norm(positions, axis=1, keepdims=True)
                    energy = -G * M / r
                    forces = G * M * positions / r**3
                else:
                    energy = 0.0
                    forces = np.zeros_like(positions)
                
                # Compute OGRePy quantities
                lambda_vals = self.lambda_func(positions, 0.0)
                alpha_vals = self.alpha_func(positions)
                
                virial = np.zeros((3, 3))
                extras = {
                    'lambda': lambda_vals.tolist(),
                    'alpha': alpha_vals.tolist(),
                }
                
                return energy, forces, virial, extras
        
        return OGRePyDriver


def demo_full_pipeline():
    """
    Demonstrate complete OGRePy → EinsteinPy → i-PI pipeline.
    """
    if not (OGREPY_AVAILABLE and EINSTEINPY_AVAILABLE):
        print("Demo requires both OGRePy and EinsteinPy")
        return
    
    print("=== Full Pipeline Demo ===\n")
    
    # Step 1: Define metric in OGRePy
    print("Step 1: Creating Schwarzschild metric in OGRePy...")
    coords = og.Coordinates("t r theta phi")
    M = og.syms("M")
    G = og.syms("G")
    c = og.syms("c")
    
    r_s = 2 * G * M / c**2
    
    g = og.diag(
        -(1 - r_s/coords.r),
        1/(1 - r_s/coords.r),
        coords.r**2,
        coords.r**2 * og.s.sin(coords.theta)**2
    )
    
    from ogrepy_entropic_extensions import EntropicMetric
    lambda_0 = og.syms("lambda_0")
    metric = EntropicMetric(coords, g, dissipation_func=lambda_0)
    
    print("✓ Metric created\n")
    
    # Step 2: Compute symbolic quantities
    print("Step 2: Computing symbolic lapse and dissipation...")
    alpha_sym = metric.gravitational_lapse()
    Pi_sym = metric.planckian_ratio()
    
    print(f"  α(r) = {alpha_sym}")
    print(f"  Π = {Pi_sym}")
    print("✓ Symbolic computation complete\n")
    
    # Step 3: Lambdify
    print("Step 3: Converting to NumPy functions...")
    bridge = SymbolicToDriverBridge(metric)
    
    params = {
        'M': 1.98892e30,
        'G': 6.67430e-11,
        'c': 299792458.0,
        'lambda_0': 1e3,
    }
    
    alpha_func = bridge.lambdify_lapse(params)
    lambda_func = bridge.lambdify_dissipation(params)
    
    print("✓ Lambdification complete\n")
    
    # Step 4: Test evaluation
    print("Step 4: Evaluating at test positions...")
    test_pos = np.array([[1e7, 0, 0], [5e7, 0, 0]])
    
    alpha_vals = alpha_func(test_pos)
    lambda_vals = lambda_func(test_pos, 0.0)
    
    print(f"  At r = 10 Mm: α = {alpha_vals[0]:.4f}, λ = {lambda_vals[0]:.3e} s⁻¹")
    print(f"  At r = 50 Mm: α = {alpha_vals[1]:.4f}, λ = {lambda_vals[1]:.3e} s⁻¹")
    print("✓ Evaluation successful\n")
    
    print("=== Pipeline Complete ===")
    print("Next: Use these functions in i-PI driver")


if __name__ == "__main__":
    demo_full_pipeline()
