"""
CAT/EPT Extension for pynucastro

Adds thermodynamic analysis to nuclear reaction networks:
- Dissipation rates from nuclear burning
- Neutrino entropy losses
- Network timescales
- Multi-scale thermodynamics

This extends pynucastro with unified CAT/EPT framework capabilities.
"""

import numpy as np
from typing import Dict, List, Optional, Tuple

# Physical constants
k_B = 1.381e-23  # J/K (Boltzmann constant)
c = 2.998e8  # m/s (speed of light)
hbar = 1.055e-34  # J·s (reduced Planck constant)
m_p = 1.673e-27  # kg (proton mass)
m_n = 1.675e-27  # kg (neutron mass)
eV_to_J = 1.602e-19  # J/eV
MeV_to_J = 1.602e-13  # J/MeV
erg_to_J = 1e-7  # J/erg
M_sun = 1.989e30  # kg


class NuclearCATEPT:
    """CAT/EPT analysis for nuclear reaction networks
    
    Provides thermodynamic analysis of nuclear burning including:
    - Energy generation rates
    - Entropy production from reactions
    - Neutrino losses
    - Characteristic timescales
    - Multi-scale hierarchies
    
    Examples
    --------
    >>> # pp-chain in Sun
    >>> catept = NuclearCATEPT()
    >>> T = 1.5e7  # K
    >>> rho = 150  # g/cm³
    >>> 
    >>> # Compute dissipation
    >>> lambda_nuc = catept.compute_lambda_nuclear(network, T, rho)
    >>> lambda_nu = catept.compute_lambda_neutrino(network, T, rho)
    >>> lambda_total = lambda_nuc + lambda_nu
    """
    
    def __init__(self):
        """Initialize CAT/EPT calculator"""
        self.k_B = k_B
        self.MeV_to_J = MeV_to_J
        self.erg_to_J = erg_to_J
    
    # =========================================================================
    # DISSIPATION RATES
    # =========================================================================
    
    def compute_lambda_nuclear(self, 
                               epsilon_nuc: float,
                               T: float,
                               rho: float = 1.0,
                               volume: float = 1.0) -> float:
        """Compute nuclear dissipation rate from energy generation
        
        The dissipation rate λ characterizes how fast nuclear binding
        energy is converted to heat and radiation.
        
        λ_nuclear = ε_nuc / (k_B T²)
        
        where ε_nuc is the energy generation rate per unit mass.
        
        Parameters
        ----------
        epsilon_nuc : float
            Energy generation rate (erg/g/s or J/kg/s)
        T : float
            Temperature (K)
        rho : float, optional
            Density (g/cm³), default 1.0
        volume : float, optional
            Volume (cm³), default 1.0
        
        Returns
        -------
        lambda_ent : float
            Nuclear dissipation rate (s⁻¹)
        
        Examples
        --------
        >>> # pp-chain in Sun
        >>> epsilon = 6.0  # erg/g/s
        >>> T = 1.5e7  # K
        >>> lambda_nuc = catept.compute_lambda_nuclear(epsilon, T)
        >>> # lambda_nuc ~ 10^-18 s^-1
        """
        
        # Convert to J/s if needed
        if epsilon_nuc < 1e-3:  # Likely already in J/kg/s
            epsilon_J = epsilon_nuc  # J/kg/s
        else:  # Likely in erg/g/s
            epsilon_J = epsilon_nuc * self.erg_to_J * 1000  # J/kg/s
        
        # Total mass
        mass_kg = rho * volume / 1000  # kg
        
        # Total power
        power = epsilon_J * mass_kg  # W
        
        # Dissipation rate
        # λ = P / (k_B T²)
        lambda_ent = power / (self.k_B * T**2)
        
        return lambda_ent
    
    def compute_lambda_neutrino(self,
                                L_nu: float,
                                T: float,
                                mass: float = 1.0) -> float:
        """Compute neutrino dissipation rate
        
        Neutrinos escape the system, carrying away entropy.
        This represents an entropy loss rather than thermalization.
        
        λ_neutrino = L_ν / (k_B T² M)
        
        Parameters
        ----------
        L_nu : float
            Neutrino luminosity (erg/s or W)
        T : float
            Temperature (K)
        mass : float, optional
            Total mass (g or kg), default 1.0
        
        Returns
        -------
        lambda_nu : float
            Neutrino dissipation rate (s⁻¹)
        
        Examples
        --------
        >>> # Solar neutrino losses
        >>> L_nu = 0.02 * L_sun  # ~2% of total
        >>> T = 1.5e7  # K
        >>> M = M_sun  # kg
        >>> lambda_nu = catept.compute_lambda_neutrino(L_nu, T, M)
        """
        
        # Convert to W if needed
        if L_nu < 1e20:  # Likely in W already
            L_nu_W = L_nu
        else:  # Likely in erg/s
            L_nu_W = L_nu * self.erg_to_J
        
        # Convert mass to kg if needed
        if mass < 1e20:  # Likely in kg
            mass_kg = mass
        else:  # Likely in g
            mass_kg = mass / 1000
        
        # Dissipation rate
        lambda_nu = L_nu_W / (self.k_B * T**2 * mass_kg)
        
        return lambda_nu
    
    def compute_lambda_photon(self,
                             L_gamma: float,
                             T: float,
                             mass: float = 1.0) -> float:
        """Compute photon dissipation rate
        
        Photons thermalize in optically thick regions,
        eventually converting to heat.
        
        Parameters
        ----------
        L_gamma : float
            Photon luminosity (erg/s or W)
        T : float
            Temperature (K)
        mass : float, optional
            Total mass (g or kg)
        
        Returns
        -------
        lambda_gamma : float
            Photon dissipation rate (s⁻¹)
        """
        
        # Same formula as neutrinos
        return self.compute_lambda_neutrino(L_gamma, T, mass)
    
    # =========================================================================
    # TIMESCALES
    # =========================================================================
    
    def compute_nuclear_timescale(self,
                                  rate: float,
                                  density: float = 1.0) -> float:
        """Compute characteristic nuclear reaction timescale
        
        τ_nuclear = 1 / (n × <σv>)
        
        where n is number density and <σv> is reaction rate.
        
        Parameters
        ----------
        rate : float
            Reaction rate (cm³/mol/s or similar)
        density : float, optional
            Number density (cm⁻³)
        
        Returns
        -------
        tau_nuclear : float
            Nuclear timescale (s)
        
        Examples
        --------
        >>> # p-p reaction in Sun
        >>> # τ ~ 10^10 years
        >>> rate = 1e-43  # cm³/mol/s (very slow!)
        >>> n = 6e23  # particles/cm³
        >>> tau = catept.compute_nuclear_timescale(rate, n)
        """
        
        if rate > 0:
            tau_nuclear = 1.0 / (density * rate)
        else:
            tau_nuclear = np.inf
        
        return tau_nuclear
    
    def compute_burning_timescale(self,
                                  X: float,
                                  epsilon_nuc: float) -> float:
        """Compute fuel depletion timescale
        
        τ_burn = X c² / ε_nuc
        
        where X is mass fraction of fuel.
        
        Parameters
        ----------
        X : float
            Mass fraction of fuel (0-1)
        epsilon_nuc : float
            Energy generation rate (erg/g/s or J/kg/s)
        
        Returns
        -------
        tau_burn : float
            Burning timescale (s)
        
        Examples
        --------
        >>> # Hydrogen burning in Sun
        >>> X_H = 0.7  # 70% hydrogen
        >>> epsilon = 6.0  # erg/g/s
        >>> tau = catept.compute_burning_timescale(X_H, epsilon)
        >>> # tau ~ 10^10 years
        """
        
        # Convert epsilon to J/kg/s if needed
        if epsilon_nuc > 1:  # erg/g/s
            eps_J = epsilon_nuc * self.erg_to_J * 1000
        else:
            eps_J = epsilon_nuc
        
        # Available energy
        E_available = X * c**2  # J/kg
        
        # Burning time
        if eps_J > 0:
            tau_burn = E_available / eps_J  # s
        else:
            tau_burn = np.inf
        
        return tau_burn
    
    def get_network_stiffness(self,
                             rates: List[float]) -> Tuple[float, float]:
        """Compute network stiffness ratio
        
        Stiffness = tau_max / tau_min
        
        Large stiffness (>10³) indicates stiff ODE system.
        
        Parameters
        ----------
        rates : list of float
            Reaction rates in network (s⁻¹)
        
        Returns
        -------
        stiffness : float
            Stiffness ratio
        tau_range : tuple
            (tau_min, tau_max) in seconds
        
        Examples
        --------
        >>> # CNO cycle: mix of fast and slow reactions
        >>> rates = [1e-10, 1e-15, 1e-8, 1e-12]  # s^-1
        >>> stiffness, (tau_min, tau_max) = catept.get_network_stiffness(rates)
        >>> # stiffness ~ 10^7 (very stiff!)
        """
        
        rates = np.array(rates)
        rates = rates[rates > 0]  # Remove zero rates
        
        if len(rates) == 0:
            return 1.0, (np.inf, np.inf)
        
        timescales = 1.0 / rates
        tau_min = np.min(timescales)
        tau_max = np.max(timescales)
        
        stiffness = tau_max / tau_min
        
        return stiffness, (tau_min, tau_max)
    
    # =========================================================================
    # ENTROPY PRODUCTION
    # =========================================================================
    
    def compute_entropy_production(self,
                                   Q_reaction: float,
                                   T: float,
                                   reaction_rate: float) -> float:
        """Compute entropy production from nuclear reaction
        
        ΔS = Q / T × (reaction rate)
        
        where Q is the Q-value (energy release).
        
        Parameters
        ----------
        Q_reaction : float
            Q-value (MeV)
        T : float
            Temperature (K)
        reaction_rate : float
            Reaction rate (s⁻¹)
        
        Returns
        -------
        S_dot : float
            Entropy production rate (J/K/s)
        
        Examples
        --------
        >>> # p + p → D + e+ + ν (Q = 1.44 MeV)
        >>> Q = 1.44  # MeV
        >>> T = 1.5e7  # K
        >>> rate = 1e-18  # s^-1
        >>> S_dot = catept.compute_entropy_production(Q, T, rate)
        """
        
        # Q-value in Joules
        Q_J = Q_reaction * self.MeV_to_J
        
        # Entropy production
        S_dot = (Q_J / T) * reaction_rate  # J/K/s
        
        return S_dot
    
    # =========================================================================
    # SPECIAL ANALYSES
    # =========================================================================
    
    def analyze_pp_chain(self,
                        T: float = 1.5e7,
                        rho: float = 150,
                        X_H: float = 0.7) -> Dict:
        """Complete CAT/EPT analysis of pp-chain
        
        Analyzes the proton-proton chain:
        p + p → D + e+ + ν (Q = 1.44 MeV)
        D + p → ³He + γ (Q = 5.49 MeV)
        ³He + ³He → ⁴He + 2p (Q = 12.86 MeV)
        
        Net: 4p → ⁴He + 2e+ + 2ν (Q_total = 26.7 MeV)
        
        Parameters
        ----------
        T : float, optional
            Temperature (K), default 1.5e7 (Sun's core)
        rho : float, optional
            Density (g/cm³), default 150
        X_H : float, optional
            Hydrogen mass fraction, default 0.7
        
        Returns
        -------
        analysis : dict
            Complete CAT/EPT analysis
        
        Examples
        --------
        >>> catept = NuclearCATEPT()
        >>> results = catept.analyze_pp_chain()
        >>> print(f"λ_total = {results['lambda_total']:.2e} s^-1")
        """
        
        # pp-chain energetics
        Q_total = 26.7  # MeV per He-4
        Q_nu = 0.52  # MeV lost to neutrinos (2%)
        Q_gamma = Q_total - Q_nu  # MeV to photons (98%)
        
        # Timescale (simplified)
        # τ_pp ~ 10^10 years
        tau_pp = 1e10 * 365.25 * 24 * 3600  # s
        rate_pp = 1.0 / tau_pp
        
        # Energy generation
        # ε ~ 6 erg/g/s in Sun
        epsilon_nuc = 6.0  # erg/g/s
        
        # Dissipation rates
        lambda_nuclear = self.compute_lambda_nuclear(epsilon_nuc, T, rho, 1.0)
        
        # Neutrino losses
        L_nu_frac = Q_nu / Q_total
        L_nu = epsilon_nuc * L_nu_frac * rho  # erg/s
        lambda_nu = self.compute_lambda_neutrino(L_nu, T, rho)
        
        # Photon component
        L_gamma_frac = Q_gamma / Q_total
        L_gamma = epsilon_nuc * L_gamma_frac * rho
        lambda_gamma = self.compute_lambda_photon(L_gamma, T, rho)
        
        # Total
        lambda_total = lambda_nuclear + lambda_nu + lambda_gamma
        
        # Burning timescale
        tau_burn = self.compute_burning_timescale(X_H, epsilon_nuc)
        
        return {
            'T': T,
            'rho': rho,
            'Q_total': Q_total,
            'Q_neutrino': Q_nu,
            'Q_photon': Q_gamma,
            'epsilon_nuc': epsilon_nuc,
            'tau_pp': tau_pp,
            'tau_burn': tau_burn,
            'lambda_nuclear': lambda_nuclear,
            'lambda_neutrino': lambda_nu,
            'lambda_photon': lambda_gamma,
            'lambda_total': lambda_total,
            'neutrino_fraction': L_nu_frac,
            'photon_fraction': L_gamma_frac
        }
    
    def analyze_CNO_cycle(self,
                         T: float = 2e7,
                         rho: float = 200) -> Dict:
        """Complete CAT/EPT analysis of CNO cycle
        
        The CNO cycle dominates in stars more massive than Sun.
        
        Parameters
        ----------
        T : float, optional
            Temperature (K), default 2e7
        rho : float, optional
            Density (g/cm³), default 200
        
        Returns
        -------
        analysis : dict
            Complete CAT/EPT analysis
        """
        
        # CNO energetics (similar Q-value to pp)
        Q_total = 26.7  # MeV
        Q_nu = 1.7  # MeV (more neutrinos than pp!)
        Q_gamma = Q_total - Q_nu
        
        # Faster than pp at higher T
        # τ_CNO ~ 10^7 years at T=2e7 K
        tau_CNO = 1e7 * 365.25 * 24 * 3600  # s
        
        # Higher energy generation
        epsilon_nuc = 100.0  # erg/g/s (much higher than pp!)
        
        # Compute as before
        lambda_nuclear = self.compute_lambda_nuclear(epsilon_nuc, T, rho, 1.0)
        
        L_nu_frac = Q_nu / Q_total
        L_nu = epsilon_nuc * L_nu_frac * rho
        lambda_nu = self.compute_lambda_neutrino(L_nu, T, rho)
        
        L_gamma_frac = Q_gamma / Q_total
        L_gamma = epsilon_nuc * L_gamma_frac * rho
        lambda_gamma = self.compute_lambda_photon(L_gamma, T, rho)
        
        lambda_total = lambda_nuclear + lambda_nu + lambda_gamma
        
        return {
            'T': T,
            'rho': rho,
            'Q_total': Q_total,
            'Q_neutrino': Q_nu,
            'Q_photon': Q_gamma,
            'epsilon_nuc': epsilon_nuc,
            'tau_CNO': tau_CNO,
            'lambda_nuclear': lambda_nuclear,
            'lambda_neutrino': lambda_nu,
            'lambda_photon': lambda_gamma,
            'lambda_total': lambda_total,
            'neutrino_fraction': L_nu_frac
        }


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def make_nuclear_catept() -> NuclearCATEPT:
    """Factory function for NuclearCATEPT
    
    Returns
    -------
    catept : NuclearCATEPT
        CAT/EPT calculator for nuclear reactions
    
    Examples
    --------
    >>> catept = make_nuclear_catept()
    >>> pp_analysis = catept.analyze_pp_chain()
    """
    return NuclearCATEPT()


def compare_burning_stages(stages: List[Tuple[str, float, float, float]]) -> Dict:
    """Compare CAT/EPT across different burning stages
    
    Parameters
    ----------
    stages : list of tuple
        Each tuple: (name, T, rho, epsilon)
    
    Returns
    -------
    comparison : dict
        Comparative analysis
    
    Examples
    --------
    >>> stages = [
    ...     ('H-burning', 1.5e7, 150, 6),
    ...     ('He-burning', 1e8, 1e4, 1e3),
    ...     ('C-burning', 8e8, 1e6, 1e6)
    ... ]
    >>> comp = compare_burning_stages(stages)
    """
    
    catept = NuclearCATEPT()
    results = {}
    
    for name, T, rho, epsilon in stages:
        lambda_nuc = catept.compute_lambda_nuclear(epsilon, T, rho)
        tau_burn = catept.compute_burning_timescale(0.1, epsilon)  # 10% fuel
        
        results[name] = {
            'T': T,
            'rho': rho,
            'epsilon': epsilon,
            'lambda_ent': lambda_nuc,
            'tau_burn': tau_burn
        }
    
    return results
