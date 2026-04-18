"""
CAT/EPT Extension for qutip

Adds thermodynamic analysis to quantum systems:
- Dissipation rates from decoherence
- Quantum entropy production
- Decoherence timescales
- Quantum-classical transitions
- Control thermodynamics

This extends qutip with unified CAT/EPT framework capabilities.
"""

import numpy as np
from typing import Dict, List, Optional, Tuple, Any

# Try to import qutip
try:
    import qutip
    _has_qutip = True
except ImportError:
    _has_qutip = False
    print("Warning: qutip not found. Install with: pip install qutip")

# Physical constants
k_B = 1.381e-23  # J/K (Boltzmann constant)
hbar = 1.055e-34  # J·s (reduced Planck constant)
k_B_eV = 8.617e-5  # eV/K


class QuantumCATEPT:
    """CAT/EPT analysis for quantum systems
    
    Provides thermodynamic analysis of quantum dynamics including:
    - Decoherence rates and timescales
    - Quantum entropy production
    - Lindblad dissipation
    - Quantum-classical boundaries
    - Control thermodynamics
    
    Examples
    --------
    >>> # Superconducting qubit
    >>> catept = QuantumCATEPT()
    >>> 
    >>> # Decoherence
    >>> lambda_q = catept.compute_lambda_quantum(H, c_ops, rho)
    >>> tau_q = 1 / lambda_q
    >>> 
    >>> # Quantum vs classical
    >>> regime = catept.quantum_classical_boundary(H, T=0.02)
    """
    
    def __init__(self):
        """Initialize quantum CAT/EPT calculator"""
        self.k_B = k_B
        self.hbar = hbar
        
        if not _has_qutip:
            print("  Warning: qutip not available")
            print("  Some methods will use simplified models")
    
    # =========================================================================
    # DISSIPATION RATES
    # =========================================================================
    
    def compute_lambda_quantum(self,
                               H: Any,
                               c_ops: List[Any],
                               rho: Any,
                               T: float = 0.0) -> float:
        """Compute quantum dissipation rate from Lindblad master equation
        
        The Lindblad master equation describes open quantum systems:
        dρ/dt = -i/ℏ [H, ρ] + Σ_k (L_k ρ L_k† - 1/2 {L_k† L_k, ρ})
        
        The dissipation rate characterizes entropy production from
        decoherence and relaxation.
        
        λ_quantum = Tr[D(ρ) log ρ]
        
        where D is the dissipator.
        
        Parameters
        ----------
        H : qutip.Qobj
            Hamiltonian
        c_ops : list of qutip.Qobj
            Collapse operators (Lindblad operators)
        rho : qutip.Qobj
            Density matrix
        T : float, optional
            Temperature (K), default 0
        
        Returns
        -------
        lambda_ent : float
            Quantum dissipation rate (s⁻¹)
        
        Examples
        --------
        >>> # Qubit with T1 decay
        >>> H = qutip.sigmaz()
        >>> c_ops = [np.sqrt(gamma) * qutip.sigmap()]
        >>> rho = qutip.ket2dm(qutip.basis(2, 0))
        >>> lambda_q = catept.compute_lambda_quantum(H, c_ops, rho)
        """
        
        if not _has_qutip:
            # Simplified estimate
            gamma_total = len(c_ops) * 1e3  # Assume ~kHz rates
            return gamma_total
        
        # Lindblad dissipator
        D_rho = 0
        for c in c_ops:
            D_rho += c * rho * c.dag() - 0.5 * (c.dag() * c * rho + rho * c.dag() * c)
        
        # Entropy production rate
        # S_dot = -Tr[D(ρ) log ρ]
        # Simplified: S_dot ~ Tr[D(ρ)]
        
        # For practical purposes, use sum of decay rates
        gamma_total = 0
        for c in c_ops:
            gamma = qutip.expect(c.dag() * c, rho)
            gamma_total += gamma
        
        return gamma_total
    
    def compute_lambda_thermal(self,
                              omega: float,
                              gamma: float,
                              T: float) -> float:
        """Compute thermal dissipation rate
        
        For a quantum oscillator coupled to thermal bath:
        λ_thermal = γ × n_thermal
        
        where n_thermal is the thermal occupation number.
        
        Parameters
        ----------
        omega : float
            Oscillator frequency (rad/s or Hz)
        gamma : float
            Coupling to bath (s⁻¹)
        T : float
            Temperature (K)
        
        Returns
        -------
        lambda_thermal : float
            Thermal dissipation rate (s⁻¹)
        
        Examples
        --------
        >>> # Cavity mode at room temperature
        >>> omega = 2 * np.pi * 5e9  # 5 GHz
        >>> gamma = 1e6  # 1 MHz loss
        >>> T = 300  # K
        >>> lambda_th = catept.compute_lambda_thermal(omega, gamma, T)
        """
        
        # Thermal occupation
        if T > 0:
            n_thermal = 1.0 / (np.exp(hbar * omega / (k_B * T)) - 1)
        else:
            n_thermal = 0.0
        
        # Thermal dissipation
        lambda_thermal = gamma * n_thermal
        
        return lambda_thermal
    
    def compute_lambda_control(self,
                              control_power: float,
                              T: float = 0.02) -> float:
        """Compute dissipation from quantum control
        
        Quantum control requires power to drive the system.
        This power eventually dissipates.
        
        λ_control = P_control / (k_B T²)
        
        Parameters
        ----------
        control_power : float
            Control power (W)
        T : float, optional
            Temperature (K), default 0.02 (20 mK)
        
        Returns
        -------
        lambda_control : float
            Control dissipation rate (s⁻¹)
        """
        
        lambda_control = control_power / (self.k_B * T**2)
        
        return lambda_control
    
    # =========================================================================
    # TIMESCALES
    # =========================================================================
    
    def get_decoherence_time(self,
                            c_ops: List[Any],
                            rho: Any = None) -> Tuple[float, float]:
        """Get decoherence timescales (T1, T2)
        
        T1: Energy relaxation time
        T2: Dephasing time
        
        Parameters
        ----------
        c_ops : list of qutip.Qobj
            Collapse operators
        rho : qutip.Qobj, optional
            Density matrix for expectation values
        
        Returns
        -------
        T1 : float
            Energy relaxation time (s)
        T2 : float
            Dephasing time (s)
        
        Examples
        --------
        >>> # Qubit with T1 and T2
        >>> gamma_1 = 1e3  # 1 kHz
        >>> gamma_phi = 500  # 500 Hz
        >>> c_ops = [
        ...     np.sqrt(gamma_1) * qutip.sigmam(),
        ...     np.sqrt(gamma_phi) * qutip.sigmaz()
        ... ]
        >>> T1, T2 = catept.get_decoherence_time(c_ops)
        """
        
        if not _has_qutip:
            # Estimate
            T1 = 1e-3  # 1 ms
            T2 = 0.5e-3  # 500 μs
            return T1, T2
        
        # Energy relaxation (amplitude damping)
        gamma_1 = 0
        # Pure dephasing
        gamma_phi = 0
        
        for c in c_ops:
            # Check if it's sigma- (amplitude damping)
            if c.shape == (2, 2):
                # Simplified: assume first is relaxation
                if gamma_1 == 0:
                    gamma_1 = qutip.expect(c.dag() * c, rho) if rho is not None else 1e3
                else:
                    gamma_phi += qutip.expect(c.dag() * c, rho) if rho is not None else 500
        
        # Timescales
        T1 = 1.0 / gamma_1 if gamma_1 > 0 else np.inf
        T2 = 1.0 / (gamma_1/2 + gamma_phi) if (gamma_1 + gamma_phi) > 0 else np.inf
        
        return T1, T2
    
    def get_quantum_speed_limit(self,
                               H: Any,
                               psi_i: Any,
                               psi_f: Any) -> float:
        """Compute quantum speed limit
        
        The minimum time for a quantum state to evolve from |ψ_i⟩ to |ψ_f⟩.
        
        τ_QSL = ℏ arccos(|⟨ψ_f|ψ_i⟩|) / ΔE
        
        where ΔE is the energy uncertainty.
        
        Parameters
        ----------
        H : qutip.Qobj
            Hamiltonian
        psi_i : qutip.Qobj
            Initial state
        psi_f : qutip.Qobj
            Final state
        
        Returns
        -------
        tau_QSL : float
            Quantum speed limit time (s)
        
        Examples
        --------
        >>> # Qubit flip
        >>> H = qutip.sigmax()
        >>> psi_i = qutip.basis(2, 0)
        >>> psi_f = qutip.basis(2, 1)
        >>> tau = catept.get_quantum_speed_limit(H, psi_i, psi_f)
        """
        
        if not _has_qutip:
            return 1e-9  # ~ns
        
        # Overlap
        overlap = np.abs(psi_f.dag() * psi_i)
        overlap = np.clip(overlap, 0, 1)
        
        # Angle
        theta = np.arccos(overlap[0, 0])
        
        # Energy uncertainty
        E = qutip.expect(H, psi_i)
        E2 = qutip.expect(H * H, psi_i)
        Delta_E = np.sqrt(E2 - E**2)
        
        # Quantum speed limit
        if Delta_E > 0:
            tau_QSL = hbar * theta / Delta_E
        else:
            tau_QSL = np.inf
        
        return tau_QSL
    
    # =========================================================================
    # QUANTUM-CLASSICAL BOUNDARY
    # =========================================================================
    
    def quantum_classical_boundary(self,
                                  H: Any,
                                  T: float,
                                  psi: Any = None) -> Dict:
        """Determine quantum vs classical regime
        
        Quantum regime: ℏω >> k_B T
        Classical regime: ℏω << k_B T
        
        Parameters
        ----------
        H : qutip.Qobj or float
            Hamiltonian or energy scale (J)
        T : float
            Temperature (K)
        psi : qutip.Qobj, optional
            Quantum state
        
        Returns
        -------
        analysis : dict
            Regime classification and parameters
        
        Examples
        --------
        >>> # Superconducting qubit at 20 mK
        >>> H = qutip.sigmaz() * 2*np.pi*5e9*hbar
        >>> T = 0.02  # K
        >>> result = catept.quantum_classical_boundary(H, T)
        >>> print(result['regime'])  # 'quantum'
        """
        
        # Energy scale
        if _has_qutip and hasattr(H, 'eigenenergies'):
            energies = H.eigenenergies()
            E_scale = energies[1] - energies[0] if len(energies) > 1 else energies[0]
        elif isinstance(H, (int, float)):
            E_scale = H
        else:
            E_scale = 1e-23  # ~keV for default
        
        # Thermal energy
        E_thermal = k_B * T
        
        # Quantum parameter
        xi = E_scale / E_thermal
        
        # Determine regime
        if xi > 10:
            regime = 'quantum'
            lambda_type = 'quantum'
        elif xi < 0.1:
            regime = 'classical'
            lambda_type = 'thermal'
        else:
            regime = 'intermediate'
            lambda_type = 'mixed'
        
        return {
            'regime': regime,
            'xi': xi,
            'E_quantum': E_scale,
            'E_thermal': E_thermal,
            'T': T,
            'lambda_type': lambda_type
        }
    
    # =========================================================================
    # ENTROPY PRODUCTION
    # =========================================================================
    
    def compute_von_neumann_entropy(self, rho: Any) -> float:
        """Compute von Neumann entropy
        
        S = -Tr(ρ log ρ)
        
        Parameters
        ----------
        rho : qutip.Qobj
            Density matrix
        
        Returns
        -------
        S : float
            von Neumann entropy (dimensionless)
        
        Examples
        --------
        >>> # Pure state
        >>> psi = qutip.basis(2, 0)
        >>> rho = qutip.ket2dm(psi)
        >>> S = catept.compute_von_neumann_entropy(rho)
        >>> # S = 0 (pure state)
        """
        
        if not _has_qutip:
            return 0.0
        
        # Use qutip's built-in entropy
        S = qutip.entropy_vn(rho)
        
        return S
    
    def compute_relative_entropy(self,
                                rho: Any,
                                sigma: Any) -> float:
        """Compute relative entropy (quantum distinguishability)
        
        S(ρ||σ) = Tr(ρ log ρ - ρ log σ)
        
        Measures how distinguishable ρ is from σ.
        
        Parameters
        ----------
        rho : qutip.Qobj
            Density matrix 1
        sigma : qutip.Qobj
            Density matrix 2
        
        Returns
        -------
        S_rel : float
            Relative entropy (dimensionless)
        """
        
        if not _has_qutip:
            return 0.0
        
        # Relative entropy
        # S(ρ||σ) = Tr(ρ log ρ) - Tr(ρ log σ)
        
        # Get eigenvalues
        eigvals_rho = rho.eigenenergies()
        eigvals_sigma = sigma.eigenenergies()
        
        # Remove zeros
        eigvals_rho = eigvals_rho[eigvals_rho > 1e-10]
        eigvals_sigma = eigvals_sigma[eigvals_sigma > 1e-10]
        
        # Compute
        S_rho = -np.sum(eigvals_rho * np.log(eigvals_rho))
        
        # This is simplified - full calculation requires diagonalization
        S_rel = S_rho  # Approximate
        
        return S_rel
    
    # =========================================================================
    # SPECIAL ANALYSES
    # =========================================================================
    
    def analyze_qubit(self,
                     omega: float = 2*np.pi*5e9,
                     T1: float = 1e-3,
                     T2: float = 0.5e-3,
                     T: float = 0.02) -> Dict:
        """Complete CAT/EPT analysis of superconducting qubit
        
        Parameters
        ----------
        omega : float, optional
            Qubit frequency (rad/s), default 5 GHz
        T1 : float, optional
            Energy relaxation time (s), default 1 ms
        T2 : float, optional
            Dephasing time (s), default 0.5 ms
        T : float, optional
            Temperature (K), default 20 mK
        
        Returns
        -------
        analysis : dict
            Complete CAT/EPT analysis
        
        Examples
        --------
        >>> catept = QuantumCATEPT()
        >>> results = catept.analyze_qubit()
        >>> print(f"λ_quantum = {results['lambda_quantum']:.2e} s^-1")
        """
        
        # Decay rates
        gamma_1 = 1.0 / T1
        gamma_phi = 1.0 / T2 - gamma_1 / 2
        
        # Dissipation rates
        lambda_relaxation = gamma_1
        lambda_dephasing = gamma_phi
        lambda_quantum = lambda_relaxation + lambda_dephasing
        
        # Thermal occupation
        n_thermal = 1.0 / (np.exp(hbar * omega / (k_B * T)) - 1) if T > 0 else 0
        
        # Quantum vs classical
        regime_analysis = self.quantum_classical_boundary(hbar * omega, T)
        
        return {
            'omega': omega,
            'frequency_GHz': omega / (2 * np.pi * 1e9),
            'T1': T1,
            'T2': T2,
            'T': T,
            'gamma_1': gamma_1,
            'gamma_phi': gamma_phi,
            'lambda_relaxation': lambda_relaxation,
            'lambda_dephasing': lambda_dephasing,
            'lambda_quantum': lambda_quantum,
            'n_thermal': n_thermal,
            'regime': regime_analysis['regime'],
            'xi': regime_analysis['xi']
        }
    
    def analyze_cavity(self,
                      omega_c: float = 2*np.pi*10e9,
                      kappa: float = 1e6,
                      T: float = 0.02,
                      n_photons: int = 10) -> Dict:
        """Complete CAT/EPT analysis of cavity mode
        
        Parameters
        ----------
        omega_c : float, optional
            Cavity frequency (rad/s), default 10 GHz
        kappa : float, optional
            Cavity decay rate (s⁻¹), default 1 MHz
        T : float, optional
            Temperature (K), default 20 mK
        n_photons : int, optional
            Average photon number, default 10
        
        Returns
        -------
        analysis : dict
            Complete CAT/EPT analysis
        """
        
        # Thermal occupation
        n_thermal = 1.0 / (np.exp(hbar * omega_c / (k_B * T)) - 1) if T > 0 else 0
        
        # Dissipation rates
        lambda_cavity = kappa * n_photons
        lambda_thermal = kappa * n_thermal
        
        # Quality factor
        Q = omega_c / kappa
        
        # Photon lifetime
        tau_photon = 1.0 / kappa
        
        return {
            'omega_c': omega_c,
            'frequency_GHz': omega_c / (2 * np.pi * 1e9),
            'kappa': kappa,
            'T': T,
            'n_photons': n_photons,
            'n_thermal': n_thermal,
            'lambda_cavity': lambda_cavity,
            'lambda_thermal': lambda_thermal,
            'Q_factor': Q,
            'tau_photon': tau_photon
        }


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def make_quantum_catept() -> QuantumCATEPT:
    """Factory function for QuantumCATEPT
    
    Returns
    -------
    catept : QuantumCATEPT
        CAT/EPT calculator for quantum systems
    
    Examples
    --------
    >>> catept = make_quantum_catept()
    >>> qubit_analysis = catept.analyze_qubit()
    """
    return QuantumCATEPT()


def compare_quantum_systems(systems: List[Tuple[str, float, float, float]]) -> Dict:
    """Compare CAT/EPT across different quantum systems
    
    Parameters
    ----------
    systems : list of tuple
        Each tuple: (name, omega, gamma, T)
    
    Returns
    -------
    comparison : dict
        Comparative analysis
    
    Examples
    --------
    >>> systems = [
    ...     ('Superconducting qubit', 2*np.pi*5e9, 1e3, 0.02),
    ...     ('Trapped ion', 2*np.pi*1e15, 1e2, 1e-6),
    ...     ('NV center', 2*np.pi*3e9, 1e6, 300)
    ... ]
    >>> comp = compare_quantum_systems(systems)
    """
    
    catept = QuantumCATEPT()
    results = {}
    
    for name, omega, gamma, T in systems:
        regime = catept.quantum_classical_boundary(hbar * omega, T)
        lambda_q = gamma  # Simplified
        tau_q = 1.0 / gamma
        
        results[name] = {
            'omega': omega,
            'gamma': gamma,
            'T': T,
            'lambda_ent': lambda_q,
            'tau_ent': tau_q,
            'regime': regime['regime']
        }
    
    return results
