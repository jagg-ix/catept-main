"""
Dissipation models for entropic time evolution.

Implements λ(x, t) for different physical scenarios:
- Constant dissipation (SGI experiments)
- Horizon dissipation (black holes)
- Position-dependent (custom potentials)
- Curvature-dependent (from Ricci scalar)
"""
import numpy as np
from ipi.utils.units import Constants

HBAR = Constants.hbar
KB = Constants.kb
G_NEWTON = 6.67430e-11  # m^3 kg^-1 s^-2
C_LIGHT = 299792458.0   # m/s
M_SOLAR = 1.98892e30    # kg


class DissipationModel:
    """Base class for dissipation rate models."""
    
    def __call__(self, positions, time):
        """
        Compute λ(x, t) at given positions and time.
        
        Args:
            positions: Array of positions [natoms, 3]
            time: Current simulation time
            
        Returns:
            lambda_vals: Dissipation rates [natoms] in s^-1
        """
        raise NotImplementedError


class ConstantDissipation(DissipationModel):
    """
    Constant dissipation rate λ = λ₀.
    
    Used for SGI validation (Table 1, page 8):
        λ_SGI = 5.3 × 10³ s⁻¹
    """
    
    def __init__(self, lambda_0):
        """
        Args:
            lambda_0: Dissipation rate in s^-1
        """
        self.lambda_0 = float(lambda_0)
    
    def __call__(self, positions, time):
        natoms = positions.shape[0]
        return np.full(natoms, self.lambda_0)


class HorizonDissipation(DissipationModel):
    """
    Black hole horizon dissipation λ = κ/c.
    
    Surface gravity: κ = c³/(4GM) for Schwarzschild
    For Kerr: κ = c³/(4GM) · f(χ) where f includes spin corrections
    
    Used for black hole validation (Table 1, page 8):
        λ_BH ~ 10³ s⁻¹ for solar mass
    """
    
    def __init__(self, mass, spin=0.0, origin=None):
        """
        Args:
            mass: Black hole mass in kg
            spin: Dimensionless spin parameter χ ∈ [0, 1]
            origin: Position of BH center [3] (default: [0,0,0])
        """
        self.mass = mass
        self.spin = spin
        self.origin = origin if origin is not None else np.zeros(3)
        
        # Compute surface gravity κ
        if spin == 0:
            # Schwarzschild: κ = c³/(4GM)
            self.kappa = C_LIGHT**3 / (4.0 * G_NEWTON * mass)
        else:
            # Kerr: κ = c³/(4GM) · f(χ)
            f_spin = np.sqrt(1 - spin**2) / (1 + np.sqrt(1 - spin**2))
            self.kappa = (C_LIGHT**3 / (4.0 * G_NEWTON * mass)) * f_spin
        
        # Dissipation rate at horizon
        self.lambda_horizon = self.kappa / C_LIGHT
        
        # Schwarzschild radius
        self.r_s = 2.0 * G_NEWTON * mass / C_LIGHT**2
    
    def __call__(self, positions, time):
        """
        Compute λ(r) with radial falloff.
        
        Near horizon: λ → λ_horizon
        Far from BH: λ → 0
        
        Simple model: λ(r) = λ_horizon · (r_s/r)²
        """
        # Compute distances from BH center
        rel_pos = positions - self.origin
        r = np.linalg.norm(rel_pos, axis=1)
        
        # Avoid singularity at r=0
        r_safe = np.maximum(r, 1.1 * self.r_s)
        
        # Radial falloff
        lambda_vals = self.lambda_horizon * (self.r_s / r_safe)**2
        
        return lambda_vals
    
    def get_hawking_temperature(self):
        """
        Compute Hawking temperature T_H = ℏκ/(2πk_B c).
        
        Returns:
            Temperature in Kelvin
        """
        return (HBAR * self.kappa) / (2.0 * np.pi * KB * C_LIGHT)
    
    def get_planckian_ratio(self):
        """
        Compute theoretical Planckian ratio at horizon.
        
        From Eq. 25: Π_horizon = 2π
        
        Returns:
            Dimensionless ratio
        """
        T_H = self.get_hawking_temperature()
        return (self.lambda_horizon * HBAR) / (KB * T_H)


class GaussianDissipation(DissipationModel):
    """
    Gaussian dissipation profile λ(r) = λ₀ exp(-r²/L²).
    
    Used for spatially localized decoherence sources.
    """
    
    def __init__(self, lambda_0, length_scale, center=None):
        """
        Args:
            lambda_0: Peak dissipation rate in s^-1
            length_scale: Gaussian width L in meters
            center: Center position [3] (default: [0,0,0])
        """
        self.lambda_0 = lambda_0
        self.L = length_scale
        self.center = center if center is not None else np.zeros(3)
    
    def __call__(self, positions, time):
        rel_pos = positions - self.center
        r_sq = np.sum(rel_pos**2, axis=1)
        
        lambda_vals = self.lambda_0 * np.exp(-r_sq / self.L**2)
        return lambda_vals


class AsymmetricDissipation(DissipationModel):
    """
    Position-dependent asymmetric dissipation.
    
    Used for SGI entropic twin paradox (Sec 2.2, page 7):
        λ±(x) = λ₀(1 ± α·x/d)
    
    Creates differential entropic time between interferometer arms.
    """
    
    def __init__(self, lambda_0, asymmetry, separation, axis=0):
        """
        Args:
            lambda_0: Base dissipation rate in s^-1
            asymmetry: Asymmetry parameter α (dimensionless)
            separation: Arm separation d in meters
            axis: Coordinate axis for asymmetry (0=x, 1=y, 2=z)
        """
        self.lambda_0 = lambda_0
        self.alpha = asymmetry
        self.d = separation
        self.axis = axis
    
    def __call__(self, positions, time):
        x_coord = positions[:, self.axis]
        
        lambda_vals = self.lambda_0 * (1.0 + self.alpha * x_coord / self.d)
        
        # Ensure non-negative
        lambda_vals = np.maximum(lambda_vals, 0.0)
        
        return lambda_vals


class ENZDissipation(DissipationModel):
    """
    Epsilon-near-zero material dissipation.
    
    From Table 1 (page 8):
        λ_ENZ = 1.4 × 10¹⁴ s⁻¹ (τ_rise = 7.1 fs)
    
    Plasma oscillation frequency with ultrafast relaxation.
    """
    
    def __init__(self, tau_rise=7.1e-15):
        """
        Args:
            tau_rise: Rise time in seconds (default: 7.1 fs for ITO)
        """
        self.lambda_ENZ = 1.0 / tau_rise
    
    def __call__(self, positions, time):
        natoms = positions.shape[0]
        return np.full(natoms, self.lambda_ENZ)


# ===================================================================
# Gravitational lapse models
# ===================================================================

class LapseModel:
    """Base class for gravitational lapse α(x) = √(-g_00)."""
    
    def __call__(self, positions):
        raise NotImplementedError


class FlatSpaceLapse(LapseModel):
    """Flat spacetime: α = 1 everywhere."""
    
    def __call__(self, positions):
        return np.ones(positions.shape[0])


class SchwarzschildLapse(LapseModel):
    """
    Schwarzschild lapse α = √(1 - r_s/r).
    
    From Eq. 15 factorization.
    """
    
    def __init__(self, mass, origin=None):
        """
        Args:
            mass: Black hole mass in kg
            origin: BH center position [3]
        """
        self.r_s = 2.0 * G_NEWTON * mass / C_LIGHT**2
        self.origin = origin if origin is not None else np.zeros(3)
    
    def __call__(self, positions):
        rel_pos = positions - self.origin
        r = np.linalg.norm(rel_pos, axis=1)
        
        # Avoid singularity
        r_safe = np.maximum(r, 1.1 * self.r_s)
        
        alpha_vals = np.sqrt(1.0 - self.r_s / r_safe)
        return alpha_vals


# ===================================================================
# Helper functions
# ===================================================================

def compute_planckian_ratio(lambda_val, T_eff):
    """
    Compute Π = λℏ/(k_B T_eff).
    
    Args:
        lambda_val: Dissipation rate in s^-1
        T_eff: Effective temperature in K
        
    Returns:
        Dimensionless Planckian ratio
    """
    return (lambda_val * HBAR) / (KB * T_eff)


def compute_openness_factor(Pi):
    """
    Compute f = 1/(1+Π).
    
    Args:
        Pi: Planckian ratio (dimensionless)
        
    Returns:
        Openness factor f ∈ (0, 1]
    """
    return 1.0 / (1.0 + Pi)


def compute_visibility_decay(tau_entropic):
    """
    Compute visibility V = exp(-τ_ent).
    
    From Eq. 13 (page 7).
    
    Args:
        tau_entropic: Accumulated entropic proper time
        
    Returns:
        Visibility ∈ [0, 1]
    """
    return np.exp(-tau_entropic)
