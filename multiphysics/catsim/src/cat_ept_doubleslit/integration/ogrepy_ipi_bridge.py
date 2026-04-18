"""
Bridge between OGRePy symbolic entropic extensions and i-PI drivers.

Converts your existing EntropicMetric class methods into i-PI-compatible
driver functions. Maintains consistency with EinsteinPy bridge.

Workflow:
1. Define EntropicMetric in OGRePy (as you already have)
2. Lambdify symbolic expressions
3. Create custom i-PI driver that evaluates these functions
4. Run i-PI simulation
5. Post-process with QuTiP for quantum observables
"""

import numpy as np
from typing import Callable, Dict, Tuple, Optional
import sys

try:
    import OGRePy as og
    OGREPY_AVAILABLE = True
except ImportError:
    OGREPY_AVAILABLE = False
    print("Warning: OGRePy not available")

try:
    from ipi.interfaces.sockets import InterfaceSocket
    IPI_AVAILABLE = True
except ImportError:
    IPI_AVAILABLE = False
    print("Warning: i-PI not available")

try:
    import qutip as qt
    QUTIP_AVAILABLE = True
except ImportError:
    QUTIP_AVAILABLE = False
    print("Warning: QuTiP not available")

# Physical constants
HBAR = 1.054571817e-34
KB = 1.380649e-23
C_LIGHT = 299792458.0
G_NEWTON = 6.67430e-11
M_SOLAR = 1.98892e30


class EntropicMetricIPIBridge:
    """
    Bridge between your OGRePy EntropicMetric and i-PI.
    
    Takes your existing EntropicMetric class and creates i-PI-compatible
    force functions.
    
    Example:
        # Your existing code (OGRePy)
        metric = EntropicMetric(coords, g, dissipation_func=lambda_0)
        
        # Create bridge
        bridge = EntropicMetricIPIBridge(metric, param_values)
        
        # Generate i-PI driver
        driver = bridge.create_ipi_driver(base_potential="schwarzschild")
        driver.run()
    """
    
    def __init__(self, entropic_metric, param_values: Dict):
        """
        Initialize bridge from your EntropicMetric.
        
        Args:
            entropic_metric: Your OGRePy EntropicMetric instance
            param_values: Dictionary of numerical parameter values
                         e.g., {'M': 1.989e30, 'G': 6.67e-11, ...}
        """
        if not OGREPY_AVAILABLE:
            raise ImportError("OGRePy required")
        
        self.metric = entropic_metric
        self.coords = entropic_metric.coords
        self.params = param_values
        
        # Storage for lambdified functions
        self._alpha_func = None
        self._lambda_func = None
        self._Pi_func = None
        self._f_func = None
        self._dtau_dt_func = None
        
        print("EntropicMetric → i-PI Bridge initialized")
        print(f"  Coordinates: {self.coords}")
        print(f"  Parameters: {list(param_values.keys())}")
    
    def lambdify_all(self):
        """
        Convert all symbolic methods to NumPy functions.
        
        Lambdifies:
        - Gravitational lapse α(x)
        - Dissipation rate λ(x)
        - Planckian ratio Π(x)
        - Openness factor f(x)
        - Proper time rate dτ/dt(x, v)
        """
        print("\nLambdifying symbolic expressions...")
        
        import sympy as sp
        
        # Coordinate symbols
        coord_syms = [self.coords.t, self.coords.r, self.coords.theta, self.coords.phi]
        
        # Parameter symbols
        param_syms = [sp.Symbol(k) for k in self.params.keys()]
        
        # 1. Gravitational lapse α = √(-g₀₀)
        alpha_sym = og.s.sqrt(-self.metric(0, 0))
        self._alpha_func = self._lambdify_scalar(
            alpha_sym, coord_syms, param_syms, "alpha"
        )
        
        # 2. Dissipation rate λ (from your metric.dissipation_func)
        lambda_sym = self.metric.dissipation_func
        self._lambda_func = self._lambdify_scalar(
            lambda_sym, coord_syms, param_syms, "lambda"
        )
        
        # 3. Planckian ratio Π = λℏ/(k_B T_eff)
        Pi_sym = self.metric.planckian_ratio()
        self._Pi_func = self._lambdify_scalar(
            Pi_sym, coord_syms, param_syms, "Pi"
        )
        
        # 4. Openness factor f = 1/(1+Π)
        f_sym = self.metric.openness_factor()
        self._f_func = self._lambdify_scalar(
            f_sym, coord_syms, param_syms, "f"
        )
        
        print("✓ All symbolic expressions lambdified")
    
    def _lambdify_scalar(self, expr, coords, params, name):
        """Helper to lambdify a scalar expression."""
        import sympy as sp
        
        # Substitute parameters
        expr_with_params = expr
        for key, val in self.params.items():
            expr_with_params = expr_with_params.subs(sp.Symbol(key), val)
        
        # Lambdify remaining coordinate dependence
        lamb = sp.lambdify(coords, expr_with_params, "numpy")
        
        # Wrapper for position array input
        def wrapped_func(positions):
            """
            Evaluate on position array.
            
            Args:
                positions: [n_atoms, 3] array in Cartesian (x, y, z)
                
            Returns:
                values: [n_atoms] array
            """
            n_atoms = positions.shape[0]
            
            # Convert Cartesian to spherical if needed
            x = positions[:, 0]
            y = positions[:, 1]
            z = positions[:, 2]
            
            r = np.sqrt(x**2 + y**2 + z**2)
            theta = np.arccos(z / np.maximum(r, 1e-10))
            phi = np.arctan2(y, x)
            
            # Evaluate (assume t=0 for static metric)
            t = np.zeros(n_atoms)
            
            try:
                result = lamb(t, r, theta, phi)
                return result if isinstance(result, np.ndarray) else np.full(n_atoms, result)
            except Exception as e:
                print(f"Error evaluating {name}: {e}")
                return np.zeros(n_atoms)
        
        return wrapped_func
    
    def create_ipi_driver(
        self, 
        base_potential: str = "schwarzschild",
        **driver_kwargs
    ):
        """
        Create custom i-PI driver with OGRePy-derived functions.
        
        Args:
            base_potential: "schwarzschild", "harmonic", "custom"
            **driver_kwargs: Additional arguments for driver
            
        Returns:
            driver_class: Subclass of EntropicDriver with injected functions
        """
        if not IPI_AVAILABLE:
            raise ImportError("i-PI (pip package: ipi) is required for socket-driver execution")
        
        # Ensure lambdified
        if self._alpha_func is None:
            self.lambdify_all()
        
        # Import base driver
        from cat_ept_doubleslit.integration.driver_base import EntropicDriver
        
        # Capture lambdified functions in closure
        alpha_func = self._alpha_func
        lambda_func = self._lambda_func
        Pi_func = self._Pi_func
        f_func = self._f_func
        
        # Base potential parameters
        if base_potential == "schwarzschild":
            M = self.params.get('M', 1.0 * M_SOLAR)
            G = self.params.get('G', G_NEWTON)
        
        class OGRePyIPIDriver(EntropicDriver):
            """
            Auto-generated i-PI driver from OGRePy EntropicMetric.
            
            Evaluates your symbolic expressions on particle positions
            at each MD step.
            """
            
            def __init__(self, **kwargs):
                super().__init__(**kwargs)
                
                print("OGRePy-generated driver initialized")
                print(f"  Base potential: {base_potential}")
            
            def compute_potential(self, positions):
                """
                Compute forces with OGRePy-derived corrections.
                
                Args:
                    positions: [n_atoms, 3] in meters
                    
                Returns:
                    energy, forces, virial, extras
                """
                n_atoms = positions.shape[0]
                
                # Base potential (from classical physics)
                if base_potential == "schwarzschild":
                    # Newtonian gravity
                    r = np.linalg.norm(positions, axis=1, keepdims=True)
                    r_safe = np.maximum(r, 3000.0)  # Avoid singularity
                    
                    energy = -G * M * np.sum(1.0 / r_safe)
                    forces = G * M * positions / r_safe**3
                
                elif base_potential == "harmonic":
                    # Harmonic trap
                    k = 1.0
                    energy = 0.5 * k * np.sum(positions**2)
                    forces = -k * positions
                
                else:
                    # No base potential
                    energy = 0.0
                    forces = np.zeros_like(positions)
                
                # Evaluate OGRePy symbolic functions
                alpha_vals = alpha_func(positions)
                lambda_vals = lambda_func(positions)
                Pi_vals = Pi_func(positions)
                f_vals = f_func(positions)
                
                # Apply openness correction to forces
                # This implements entropic drag from paper Sec 3.5
                forces *= f_vals.reshape(-1, 1)
                
                # Virial (mechanical)
                virial = np.zeros((3, 3))
                for i in range(n_atoms):
                    virial += np.outer(positions[i], forces[i])
                
                # Extra data for i-PI motion class
                extras = {
                    'lambda': lambda_vals.tolist(),
                    'alpha': alpha_vals.tolist(),
                    'Pi': Pi_vals.tolist(),
                    'f': f_vals.tolist(),
                }
                
                return energy, forces, virial, extras
        
        return OGRePyIPIDriver


class IPItoQuTiPBridge:
    """
    Convert i-PI trajectory data to QuTiP input format.
    
    Reads i-PI output, processes entropic time, and prepares
    for quantum master equation solver.
    """
    
    def __init__(self, ipi_output_prefix: str):
        """
        Load i-PI simulation results.
        
        Args:
            ipi_output_prefix: Prefix for i-PI output files
                              (e.g., "sgi_validation")
        """
        self.prefix = ipi_output_prefix
        
        # Load trajectories
        self.positions = None
        self.velocities = None
        self.time = None
        self.tau_entropic = None
        self.lambda_vals = None
        self.visibility = None
        
        self._load_data()
    
    def _load_data(self):
        """Load all i-PI output files."""
        print(f"Loading i-PI results: {self.prefix}.*")
        
        try:
            # Thermodynamic properties
            data_thermo = np.loadtxt(f'{self.prefix}.out')
            self.time = data_thermo[:, 1]  # Time column
            
            # Entropic diagnostics
            data_entropic = np.loadtxt(f'{self.prefix}.entropic.out')
            self.tau_entropic = data_entropic[:, 2]
            self.lambda_vals = data_entropic[:, 5]
            self.visibility = data_entropic[:, 4]
            
            print(f"✓ Loaded {len(self.time)} timesteps")
            
        except FileNotFoundError as e:
            print(f"Error loading i-PI output: {e}")
            raise
    
    def get_time_array(self, mode='coordinate'):
        """
        Get time array for QuTiP.
        
        Args:
            mode: 'coordinate' (t) or 'entropic' (τ_ent)
            
        Returns:
            time_array: For QuTiP tlist
        """
        if mode == 'coordinate':
            return self.time
        elif mode == 'entropic':
            return self.tau_entropic
        else:
            raise ValueError(f"Unknown mode: {mode}")
    
    def get_hamiltonian_corrections(self, omega_infinity: float):
        """
        Compute position-dependent Hamiltonian corrections.
        
        For gravitational redshift:
            ω(x) = ω_∞ · α(x)
            
        Args:
            omega_infinity: Frequency far from source
            
        Returns:
            omega_array: Position-dependent frequencies
        """
        # Would need to load position-dependent α values
        # For now, constant
        return np.full(len(self.time), omega_infinity)
    
    def create_lindblad_operators(self):
        """
        Create collapse operators for QuTiP master equation.
        
        Returns:
            c_ops: List of collapse operators
            gamma_t: Time-dependent dissipation rates
        """
        if not QUTIP_AVAILABLE:
            raise ImportError("QuTiP required")
        
        # Simple example: single qubit with time-dependent dissipation
        # c_ops = [sqrt(λ(t)) * σ_-]
        
        a = qt.destroy(2)  # Lowering operator
        
        # Time-dependent coefficient (from i-PI)
        gamma_t = self.lambda_vals
        
        c_ops = [[a, gamma_t]]  # QuTiP time-dependent format
        
        return c_ops
    
    def solve_master_equation(
        self,
        H: qt.Qobj,
        psi0: qt.Qobj,
        time_mode: str = 'coordinate',
        **mesolve_kwargs
    ):
        """
        Solve master equation with i-PI-derived dissipation.
        
        Args:
            H: Hamiltonian (QuTiP Qobj)
            psi0: Initial state
            time_mode: 'coordinate' or 'entropic'
            **mesolve_kwargs: Additional args for mesolve
            
        Returns:
            result: QuTiP Result object
        """
        if not QUTIP_AVAILABLE:
            raise ImportError("QuTiP required")
        
        tlist = self.get_time_array(mode=time_mode)
        c_ops = self.create_lindblad_operators()
        
        # Solve
        result = qt.mesolve(H, psi0, tlist, c_ops, **mesolve_kwargs)
        
        return result


# ===================================================================
# Complete Workflow Example
# ===================================================================

def complete_workflow_example():
    """
    Demonstrate full pipeline: OGRePy → i-PI → QuTiP
    """
    if not (OGREPY_AVAILABLE and IPI_AVAILABLE and QUTIP_AVAILABLE):
        print("Full workflow requires OGRePy, i-PI, and QuTiP")
        return
    
    print("="*70)
    print("COMPLETE WORKFLOW: OGRePy → i-PI → QuTiP")
    print("="*70)
    print()
    
    # ===================================================================
    # Step 1: Define metric in OGRePy (your existing code)
    # ===================================================================
    
    print("Step 1: Creating EntropicMetric in OGRePy...")
    
    coords = og.Coordinates("t r theta phi")
    
    # Schwarzschild metric
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
    
    # Your entropic extension
    from ogrepy_entropic_extensions import EntropicMetric  # Your existing class
    
    lambda_horizon = c**3 / (4 * G * M)  # Horizon dissipation
    T_H = og.syms("hbar") * lambda_horizon / (2 * og.s.pi * og.syms("k_B") * c)
    
    metric = EntropicMetric(
        coords, 
        g, 
        dissipation_func=lambda_horizon
    )
    metric.T_eff = T_H  # Hawking temperature
    
    print("✓ Metric created")
    print()
    
    # ===================================================================
    # Step 2: Create bridge and lambdify
    # ===================================================================
    
    print("Step 2: Lambdifying symbolic expressions...")
    
    params = {
        'M': 1.0 * M_SOLAR,
        'G': G_NEWTON,
        'c': C_LIGHT,
        'hbar': HBAR,
        'k_B': KB,
    }
    
    bridge = EntropicMetricIPIBridge(metric, params)
    bridge.lambdify_all()
    
    print()
    
    # ===================================================================
    # Step 3: Create i-PI driver
    # ===================================================================
    
    print("Step 3: Generating i-PI driver...")
    
    driver_class = bridge.create_ipi_driver(base_potential="schwarzschild")
    
    print("✓ Driver class created")
    print("  Usage: driver = driver_class(unix_socket='bh_driver')")
    print("         driver.run()")
    print()
    
    # ===================================================================
    # Step 4: (User runs i-PI simulation)
    # ===================================================================
    
    print("Step 4: Run i-PI simulation (manual step)")
    print("  $ i-pi input.xml &")
    print("  $ python driver.py")
    print()
    
    # ===================================================================
    # Step 5: Post-process with QuTiP
    # ===================================================================
    
    print("Step 5: Converting i-PI → QuTiP...")
    
    # Assuming simulation has run
    qutip_bridge = IPItoQuTiPBridge("bh_ringdown")
    
    # Define quantum system (2-level atom)
    H = -0.5 * qt.sigmaz()  # Hamiltonian
    psi0 = qt.basis(2, 0)    # Ground state
    
    # Solve with i-PI-derived dissipation
    result = qutip_bridge.solve_master_equation(
        H, psi0, 
        time_mode='entropic',
        e_ops=[qt.sigmaz(), qt.sigmax()]
    )
    
    print("✓ Quantum evolution computed")
    print()
    
    # ===================================================================
    # Step 6: Validate against paper
    # ===================================================================
    
    print("Step 6: Validation")
    print("  Visibility from i-PI:", qutip_bridge.visibility[-1])
    print("  Visibility from QuTiP:", np.abs(result.states[-1][0,1]))
    print()
    
    print("="*70)
    print("WORKFLOW COMPLETE")
    print("="*70)


if __name__ == "__main__":
    complete_workflow_example()
