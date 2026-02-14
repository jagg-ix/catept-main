"""
MEEP adapter for CAT/EPT framework.

MEEP (MIT Electromagnetic Equation Propagation) is a finite-difference time-domain (FDTD)
simulation software for electromagnetic systems.

Design principles:
- Never fork or modify MEEP
- Lazy import (optional dependency)
- Add entropic absorption/dispersion to materials
- Simulate ENZ (epsilon-near-zero) experiments
- Interface with QuTiP for quantum-EM coupling

CAT/EPT Extensions:
1. Complex permittivity: ε_eff = ε_R + iε_I(λ, τ_ent)
2. Entropic absorption: α(ω) includes dissipation
3. Modified Drude model: ε(ω) with λ-dependent damping
4. ENZ visibility decay: V(S) = V_cl·exp(-λS)
5. Two-photon entanglement with entropic decoherence
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Optional, Tuple
import numpy as np


@dataclass
class MEEPMaterial:
    """Material definition with CAT/EPT properties"""
    
    name: str
    epsilon: complex  # Relative permittivity (ε_r)
    mu: complex = 1.0  # Relative permeability (μ_r)
    
    # CAT/EPT parameters
    lambda_ent: float = 0.0  # Entropic dissipation rate (s^-1)
    tau_ent: float = 0.0  # Accumulated entropic time (s)
    
    # For Drude materials (metals, ENZ)
    is_drude: bool = False
    omega_p: float = 0.0  # Plasma frequency (rad/s)
    gamma_drude: float = 0.0  # Drude damping (rad/s)
    epsilon_inf: float = 1.0  # High-frequency permittivity
    
    def epsilon_at_frequency(self, omega: float, include_catept: bool = True) -> complex:
        """Compute ε(ω) including CAT/EPT corrections
        
        Standard Drude model:
        ε(ω) = ε_∞ - ω_p² / (ω² + iγω)
        
        CAT/EPT modification:
        ε(ω) = ε_∞ - ω_p² / (ω² + i(γ + κλ)ω)
        
        where κ converts λ to frequency units
        """
        if not self.is_drude:
            return self.epsilon
        
        # Effective damping includes entropic contribution
        if include_catept and self.lambda_ent > 0:
            # Convert λ (s^-1) to rad/s and add to Drude damping
            gamma_eff = self.gamma_drude + self.lambda_ent
        else:
            gamma_eff = self.gamma_drude
        
        # Drude model
        eps = self.epsilon_inf - self.omega_p**2 / (omega**2 + 1j * gamma_eff * omega)
        
        return eps


@dataclass
class MEEPSimulationConfig:
    """Configuration for MEEP simulation with CAT/EPT"""
    
    # Geometry
    cell_size: Tuple[float, float, float] = (10, 10, 10)  # μm
    resolution: int = 20  # pixels/μm
    pml_thickness: float = 1.0  # μm (perfectly matched layer)
    
    # Sources
    source_wavelength: float = 1.55  # μm (telecom wavelength)
    source_width: float = 0.5  # μm (Gaussian width)
    
    # Time evolution
    run_time: float = 100  # MEEP time units
    
    # CAT/EPT
    cat_ept_enabled: bool = False
    global_lambda: float = 0.0  # s^-1 (if uniform)
    track_tau_ent: bool = True


class MEEPCATPTAdapter:
    """Adapter wrapping MEEP with CAT/EPT extensions
    
    This adapter enables:
    1. Standard MEEP electromagnetic simulations
    2. CAT/EPT modifications to material properties
    3. ENZ (epsilon-near-zero) experiment simulations
    4. Two-photon entanglement with entropic decoherence
    5. Interface to QuTiP for quantum-classical coupling
    
    Examples
    --------
    >>> # Standard simulation (no CAT/EPT)
    >>> config = MEEPSimulationConfig(cat_ept_enabled=False)
    >>> adapter = MEEPCATPTAdapter(config)
    >>> adapter.add_material('silicon', epsilon=11.7)
    >>> results = adapter.run_simulation()
    
    >>> # ENZ experiment with CAT/EPT
    >>> config = MEEPSimulationConfig(
    ...     cat_ept_enabled=True,
    ...     global_lambda=1e-14  # ENZ regime
    ... )
    >>> adapter = MEEPCATPTAdapter(config)
    >>> adapter.setup_enz_experiment()
    >>> results = adapter.run_enz_visibility_test()
    """
    
    def __init__(self, config: MEEPSimulationConfig):
        """Initialize MEEP adapter with lazy import"""
        
        self.config = config
        self.materials: Dict[str, MEEPMaterial] = {}
        
        # Lazy import
        try:
            import meep as mp
            self.meep = mp
            self._meep_available = True
            print("✓ MEEP available")
        except ImportError:
            self._meep_available = False
            self.meep = None
            print("⚠ MEEP not installed. Using fallback mode.")
            print("Install: pip install meep")
        
        # Initialize simulation
        if self._meep_available:
            self._initialize_simulation()
    
    def _initialize_simulation(self):
        """Initialize MEEP simulation geometry"""
        if not self._meep_available:
            return
        
        # Create computational cell
        self.cell = self.meep.Vector3(*self.config.cell_size)
        
        # Geometry list (filled by user)
        self.geometry = []
        
        # Source list
        self.sources = []
        
        # PML boundary layers
        self.pml_layers = [self.meep.PML(self.config.pml_thickness)]
        
        print(f"✓ Initialized MEEP cell: {self.config.cell_size} μm")
    
    def add_material(
        self, 
        name: str, 
        epsilon: Optional[complex] = None,
        drude_params: Optional[Dict[str, float]] = None,
        lambda_ent: float = 0.0
    ):
        """Add material to simulation
        
        Parameters
        ----------
        name : str
            Material identifier
        epsilon : complex, optional
            Simple permittivity (if not Drude)
        drude_params : dict, optional
            {'omega_p': ..., 'gamma': ..., 'epsilon_inf': ...}
        lambda_ent : float
            Entropic dissipation rate (s^-1)
        """
        
        if drude_params is not None:
            # Drude material
            mat = MEEPMaterial(
                name=name,
                epsilon=drude_params.get('epsilon_inf', 1.0),
                is_drude=True,
                omega_p=drude_params['omega_p'],
                gamma_drude=drude_params['gamma'],
                epsilon_inf=drude_params.get('epsilon_inf', 1.0),
                lambda_ent=lambda_ent
            )
        else:
            # Simple dielectric
            mat = MEEPMaterial(
                name=name,
                epsilon=epsilon or 1.0,
                lambda_ent=lambda_ent
            )
        
        self.materials[name] = mat
        print(f"✓ Added material: {name} (λ={lambda_ent:.2e} s⁻¹)")
    
    def setup_enz_experiment(
        self,
        film_thickness: float = 0.1,  # μm
        substrate_thickness: float = 1.0,  # μm
        lambda_enz: float = 1e-14  # s^-1 (ENZ regime)
    ):
        """Setup ENZ (Epsilon-Near-Zero) visibility experiment
        
        This is the **TESTABLE PREDICTION** from CAT/EPT!
        
        Prediction: V(S) = V_cl · exp(-λS)
        where S is photon path length through ENZ medium
        
        Parameters
        ----------
        film_thickness : float
            ENZ film thickness (μm)
        substrate_thickness : float
            Substrate thickness (μm)
        lambda_enz : float
            Entropic dissipation in ENZ (s^-1)
            Predicted: λ_ent = λ_thermal · n_g ≈ 10^-14 s^-1
        """
        
        if not self._meep_available:
            print("⚠ MEEP not available - skipping setup")
            return
        
        # Add ITO-like ENZ material
        # At λ ≈ 1.2 μm, ITO has ε ≈ 0 (ENZ condition)
        self.add_material(
            'enz_film',
            drude_params={
                'omega_p': 2.2e15,  # rad/s (from paper)
                'gamma': 1e14,  # rad/s (standard ITO)
                'epsilon_inf': 3.9
            },
            lambda_ent=lambda_enz if self.config.cat_ept_enabled else 0.0
        )
        
        # Add substrate (SiO2)
        self.add_material('substrate', epsilon=2.1)
        
        # Create geometry
        # Substrate
        substrate = self.meep.Block(
            size=self.meep.Vector3(self.meep.inf, self.meep.inf, substrate_thickness),
            center=self.meep.Vector3(0, 0, -substrate_thickness/2),
            material=self.meep.Medium(epsilon=2.1)
        )
        
        # ENZ film (this is where CAT/EPT happens!)
        enz_mat = self.materials['enz_film']
        
        # Convert to MEEP material
        # In MEEP, Drude model: ε(ω) = ε_∞ - f/(ω² + iγω)
        # where f = ω_p²
        if self.config.cat_ept_enabled:
            gamma_eff = enz_mat.gamma_drude + enz_mat.lambda_ent
        else:
            gamma_eff = enz_mat.gamma_drude
        
        meep_drude = self.meep.DrudeSusceptibility(
            frequency=enz_mat.omega_p / (2 * np.pi),  # Convert to freq
            gamma=gamma_eff / (2 * np.pi),
            sigma=1.0
        )
        
        enz_medium = self.meep.Medium(
            epsilon=enz_mat.epsilon_inf,
            E_susceptibilities=[meep_drude]
        )
        
        enz_film = self.meep.Block(
            size=self.meep.Vector3(self.meep.inf, self.meep.inf, film_thickness),
            center=self.meep.Vector3(0, 0, film_thickness/2),
            material=enz_medium
        )
        
        self.geometry = [substrate, enz_film]
        
        # Add source (plane wave from below)
        self.sources = [
            self.meep.Source(
                self.meep.ContinuousSource(
                    frequency=1.0 / self.config.source_wavelength,
                    width=self.config.source_width
                ),
                component=self.meep.Ex,
                center=self.meep.Vector3(0, 0, -substrate_thickness - 1.0),
                size=self.meep.Vector3(self.meep.inf, self.meep.inf, 0)
            )
        ]
        
        print(f"✓ ENZ experiment setup complete")
        print(f"  Film thickness: {film_thickness} μm")
        print(f"  λ_ENZ: {lambda_enz:.2e} s⁻¹")
        print(f"  CAT/EPT: {'ENABLED' if self.config.cat_ept_enabled else 'DISABLED'}")
    
    def run_simulation(self) -> Dict[str, Any]:
        """Run MEEP simulation
        
        Returns
        -------
        results : dict
            'fields': Field arrays
            'transmission': Transmission spectrum
            'tau_ent': Entropic time evolution
        """
        
        if not self._meep_available:
            return self._run_fallback()
        
        # Create simulation
        sim = self.meep.Simulation(
            cell_size=self.cell,
            geometry=self.geometry,
            sources=self.sources,
            boundary_layers=self.pml_layers,
            resolution=self.config.resolution
        )
        
        # Field monitors
        transmission_monitor = []
        
        def get_transmission(sim_obj):
            """Monitor transmission"""
            # Get flux through plane above ENZ film
            flux = sim_obj.get_fluxes(transmission_monitor)[0]
            transmission_monitor.append(flux)
        
        # Run simulation
        sim.run(
            self.meep.at_every(1.0, get_transmission),
            until=self.config.run_time
        )
        
        # Extract results
        results = {
            'transmission': np.array(transmission_monitor),
            'times': np.arange(len(transmission_monitor)),
            'tau_ent': self._compute_tau_ent(len(transmission_monitor)) if self.config.track_tau_ent else None
        }
        
        return results
    
    def run_enz_visibility_test(self) -> Dict[str, Any]:
        """Run ENZ visibility decay experiment
        
        Tests CAT/EPT prediction: V(S) = V_cl · exp(-λS)
        
        Returns
        -------
        comparison : dict
            'S_values': Path lengths (μm)
            'V_measured': Measured visibility
            'V_predicted': CAT/EPT prediction
            'chi2': Goodness of fit
        """
        
        print("Running ENZ visibility test...")
        
        # Vary path length S (film thickness)
        S_values = np.linspace(0.05, 0.5, 10)  # μm
        V_measured = []
        
        for S in S_values:
            # Setup with this thickness
            self.setup_enz_experiment(film_thickness=S)
            
            # Run simulation
            results = self.run_simulation()
            
            # Compute visibility from transmission
            T = results['transmission']
            V = self._compute_visibility(T)
            V_measured.append(V)
        
        V_measured = np.array(V_measured)
        
        # CAT/EPT prediction: V(S) = V_cl · exp(-λS)
        lambda_enz = self.materials['enz_film'].lambda_ent if 'enz_film' in self.materials else 0.0
        V_cl = V_measured[0]  # Classical visibility (S → 0)
        
        V_predicted = V_cl * np.exp(-lambda_enz * S_values * 1e-6)  # Convert μm to m
        
        # Goodness of fit
        chi2 = np.sum((V_measured - V_predicted)**2 / V_predicted)
        
        print(f"✓ ENZ test complete")
        print(f"  χ² = {chi2:.2f}")
        
        return {
            'S_values': S_values,
            'V_measured': V_measured,
            'V_predicted': V_predicted,
            'chi2': chi2,
            'lambda_enz': lambda_enz
        }
    
    def _compute_visibility(self, transmission: np.ndarray) -> float:
        """Compute fringe visibility from transmission data"""
        # V = (T_max - T_min) / (T_max + T_min)
        T_max = np.max(transmission)
        T_min = np.min(transmission)
        return (T_max - T_min) / (T_max + T_min + 1e-10)
    
    def _compute_tau_ent(self, n_steps: int) -> np.ndarray:
        """Compute entropic time evolution"""
        if not self.config.cat_ept_enabled:
            return np.zeros(n_steps)
        
        # τ_ent accumulates from global λ
        dt = self.config.run_time / n_steps  # MEEP time units
        # Convert to seconds (rough estimate)
        dt_seconds = dt * 1e-15  # femtosecond scale
        
        lambda_global = self.config.global_lambda
        tau_ent = np.arange(n_steps) * lambda_global * dt_seconds
        
        return tau_ent
    
    def _run_fallback(self) -> Dict[str, Any]:
        """Fallback simulation when MEEP unavailable"""
        print("⚠ Running fallback mode (no MEEP)")
        
        # Simple analytical model
        n_steps = 100
        times = np.linspace(0, self.config.run_time, n_steps)
        
        # Mock transmission (exponential decay with CAT/EPT)
        if self.config.cat_ept_enabled:
            transmission = np.exp(-self.config.global_lambda * times * 1e-15)
        else:
            transmission = np.ones(n_steps)
        
        return {
            'transmission': transmission,
            'times': times,
            'tau_ent': self._compute_tau_ent(n_steps)
        }


def make_meep_adapter(config: Optional[Dict[str, Any]] = None) -> MEEPCATPTAdapter:
    """Factory function for MEEP adapter
    
    Parameters
    ----------
    config : dict, optional
        Simulation configuration
    
    Returns
    -------
    adapter : MEEPCATPTAdapter
    
    Examples
    --------
    >>> # Standard EM simulation
    >>> adapter = make_meep_adapter({'cat_ept_enabled': False})
    >>> adapter.add_material('gold', drude_params={...})
    >>> results = adapter.run_simulation()
    
    >>> # ENZ experiment with CAT/EPT
    >>> adapter = make_meep_adapter({
    ...     'cat_ept_enabled': True,
    ...     'global_lambda': 1e-14
    ... })
    >>> adapter.setup_enz_experiment()
    >>> test_results = adapter.run_enz_visibility_test()
    """
    
    if config is None:
        config = {}
    
    meep_config = MEEPSimulationConfig(**config)
    return MEEPCATPTAdapter(meep_config)
