"""
Entropic Langevin dynamics with complex action support.

Implements the factorized proper time evolution from:
"Complex Action and Entropic Time in Open Quantum Systems"

Key equations:
- Proper time factorization (Eq. 15): dτ = α(x) dt / [cosh(η) · f(Π)]
- Openness factor: f = 1/(1+Π) where Π = λℏ/(k_B T_eff)
- Imaginary action (Eq. 4): S_I = ℏ ∫ λ dt
- Complex charge (Eq. 5): Q = E - iℏλ
"""

import numpy as np
from ipi.engine.motion import Motion
from ipi.utils.depend import depend_value
from ipi.utils.units import Constants, unit_to_internal, unit_to_user

__DRIVER__ = "entropic_langevin"

# Physical constants (will use i-PI's Constants where possible)
HBAR = Constants.hbar
KB = Constants.kb
C_LIGHT = 299792458.0  # m/s


class EntropicLangevinMotion(Motion):
    """
    Langevin dynamics with entropic time corrections.
    
    Integrates classical equations with:
    - Position-dependent dissipation λ(x)
    - Gravitational lapse α(x) from curved spacetime
    - Openness factor f(Π) from thermodynamic dissipation
    
    Attributes:
        lambda_model: Callable λ(positions, time) → dissipation rate [s^-1]
        T_eff: Effective temperature of dissipative channel [K]
        alpha_model: Callable α(positions) → gravitational lapse factor [dimensionless]
        track_visibility: Whether to compute visibility decay
        track_complex_charge: Whether to track Q = E - iℏλ
    """
    
    def __init__(
        self,
        timestep,
        mode="langevin",
        lambda_model=None,
        T_eff=300.0,
        alpha_model=None,
        eta_model=None,
        track_visibility=True,
        track_complex_charge=False,
        **kwargs
    ):
        """
        Initialize entropic Langevin dynamics.
        
        Args:
            timestep: Integration time step [internal units]
            mode: Base dynamics mode ("langevin" or "nvt")
            lambda_model: Dissipation rate function
            T_eff: Effective temperature [K]
            alpha_model: Gravitational lapse function (default: flat space α=1)
            eta_model: Kinematic rapidity function (default: η=0)
            track_visibility: Compute V(t) = exp(-τ_ent)
            track_complex_charge: Track conserved quantity Q
        """
        super(EntropicLangevinMotion, self).__init__(timestep=timestep, mode=mode, **kwargs)
        
        # Dissipation model (required)
        if lambda_model is None:
            raise ValueError("lambda_model must be provided for entropic dynamics")
        self.lambda_model = lambda_model
        
        # Temperature of dissipative channel (not necessarily bath temperature)
        self.T_eff = T_eff
        
        # Gravitational corrections (optional)
        self.alpha_model = alpha_model or (lambda pos: np.ones(pos.shape[0]))
        self.eta_model = eta_model or (lambda pos, vel: np.zeros(pos.shape[0]))
        
        # Tracking options
        self.track_visibility = track_visibility
        self.track_complex_charge = track_complex_charge
        
        # Accumulated quantities
        self.tau_entropic = 0.0  # Entropic proper time
        self.S_I = 0.0           # Imaginary action
        self.visibility = 1.0    # Visibility V = exp(-τ_ent)
        self.Q_real = None       # Real part of complex charge
        self.Q_imag = None       # Imaginary part
        
        # History for analysis
        self.tau_history = []
        self.lambda_history = []
        self.Pi_history = []
        self.alpha_history = []
    
    def step(self, step=None):
        """
        Perform one integration step with entropic corrections.
        
        Follows the factorized proper time evolution:
            dτ = α(x) dt / [cosh(η) · f(Π)]
        where f = 1/(1+Π) and Π = λℏ/(k_B T_eff).
        """
        # Get current state
        q = self.beads.q  # Positions [natoms, 3]
        p = self.beads.p  # Momenta
        m = self.beads.m  # Masses
        f = self.forces.f # Forces
        
        dt = self.dt
        natoms = q.shape[0]
        
        # Compute velocities
        v = p / m.reshape(-1, 1)  # [natoms, 3]
        
        # ===================================================================
        # Step 1: Evaluate position-dependent quantities
        # ===================================================================
        
        # Dissipation rate λ(x, t) [s^-1]
        # For constant: lambda_val = np.full(natoms, lambda_0)
        # For position-dependent: lambda_val = self.lambda_model(q, self.time)
        lambda_val = self._evaluate_lambda(q)
        
        # Gravitational lapse α(x) [dimensionless]
        # For flat space: alpha_val = np.ones(natoms)
        # For Schwarzschild: alpha_val = sqrt(1 - r_s/r)
        alpha_val = self._evaluate_alpha(q)
        
        # Kinematic rapidity η from velocities
        # For non-relativistic: eta_val ≈ 0
        # For relativistic: eta_val = arctanh(|v|/c)
        eta_val = self._evaluate_eta(q, v)
        
        # ===================================================================
        # Step 2: Compute thermodynamic quantities
        # ===================================================================
        
        # Planckian ratio Π = λℏ/(k_B T_eff) [dimensionless]
        # Table 1 from paper:
        #   - Black hole: Π ≈ 0.43
        #   - SGI: Π ≈ 0.13
        #   - ENZ: Π ≈ 1.1
        Pi_val = (lambda_val * HBAR) / (KB * self.T_eff)
        
        # Openness factor f = 1/(1+Π) [dimensionless]
        # As Π → 0 (closed system): f → 1
        # As Π → ∞ (maximally open): f → 0
        f_val = 1.0 / (1.0 + Pi_val)
        
        # ===================================================================
        # Step 3: Compute proper time increment
        # ===================================================================
        
        # Factorized rate (Eq. 15): dτ/dt = α/(cosh(η)·f)
        dtau_dt = alpha_val / (np.cosh(eta_val) * f_val)
        
        # Average over atoms (or use centroid for ring polymer)
        dtau_dt_mean = np.mean(dtau_dt)
        
        # Entropic time increment
        dtau = dtau_dt_mean * dt
        self.tau_entropic += dtau
        
        # ===================================================================
        # Step 4: Accumulate imaginary action
        # ===================================================================
        
        # S_I = ℏ ∫ λ dt (Eq. 4)
        lambda_mean = np.mean(lambda_val)
        dS_I = HBAR * lambda_mean * dt
        self.S_I += dS_I
        
        # ===================================================================
        # Step 5: Modified Langevin dynamics
        # ===================================================================
        
        # Standard Langevin: dp = F dt - γ p dt + √(2γmkT) dW
        # Modified: γ_eff = γ · f (reduced friction in open system)
        
        # Get friction coefficient from base thermostat
        # For i-PI thermostats, this is stored in the thermostat object
        if hasattr(self, 'thermostat') and self.thermostat is not None:
            gamma_base = self.thermostat.tau  # Damping time
        else:
            gamma_base = 1.0 / (100.0 * dt)  # Default: τ = 100 Δt
        
        # Apply openness correction to friction
        # This implements the "entropic drag" from Sec 3.5
        gamma_eff = gamma_base * np.mean(f_val)
        
        # Drift term: F/m - γ·v
        drift = f / m.reshape(-1, 1) - gamma_eff * v
        
        # Stochastic term: √(2γkT/m) · dW
        # Note: Use T_eff (dissipative channel temp), not bath temp
        noise_amp = np.sqrt(2.0 * gamma_eff * KB * self.T_eff * dt / m.reshape(-1, 1))
        noise = noise_amp * np.random.normal(size=q.shape)
        
        # Update momenta
        p_new = p + (drift * dt + noise) * m.reshape(-1, 1)
        
        # Update positions (velocity Verlet style)
        q_new = q + 0.5 * (v + p_new / m.reshape(-1, 1)) * dt
        
        # Apply to beads
        self.beads.p = p_new
        self.beads.q = q_new
        
        # ===================================================================
        # Step 6: Update tracking quantities
        # ===================================================================
        
        if self.track_visibility:
            # Visibility decay V = exp(-τ_ent) (Eq. 13)
            self.visibility = np.exp(-self.tau_entropic)
        
        if self.track_complex_charge:
            # Complex charge Q = E - iℏλ (Eq. 5)
            E_total = self.nm.kin + self.nm.pot  # Total energy
            self.Q_real = E_total
            self.Q_imag = -HBAR * lambda_mean
        
        # Store history
        self.tau_history.append(self.tau_entropic)
        self.lambda_history.append(lambda_mean)
        self.Pi_history.append(np.mean(Pi_val))
        self.alpha_history.append(np.mean(alpha_val))
        
        # Increment time
        self.time += dt
    
    def _evaluate_lambda(self, positions):
        """
        Evaluate dissipation rate λ(x, t).
        
        Args:
            positions: Atomic positions [natoms, 3]
            
        Returns:
            lambda_val: Dissipation rates [natoms] in s^-1
        """
        if callable(self.lambda_model):
            return self.lambda_model(positions, self.time)
        else:
            # Constant dissipation
            return np.full(positions.shape[0], float(self.lambda_model))
    
    def _evaluate_alpha(self, positions):
        """
        Evaluate gravitational lapse α(x) = √(-g_00).
        
        For Schwarzschild: α = √(1 - r_s/r)
        For flat space: α = 1
        
        Args:
            positions: Atomic positions [natoms, 3]
            
        Returns:
            alpha_val: Lapse factors [natoms]
        """
        return self.alpha_model(positions)
    
    def _evaluate_eta(self, positions, velocities):
        """
        Evaluate kinematic rapidity η = arctanh(|v|/c).
        
        For non-relativistic systems: η ≈ 0
        
        Args:
            positions: Atomic positions [natoms, 3]
            velocities: Atomic velocities [natoms, 3]
            
        Returns:
            eta_val: Rapidities [natoms]
        """
        v_mag = np.linalg.norm(velocities, axis=1)
        
        # Check if relativistic
        if np.any(v_mag > 0.01 * C_LIGHT):
            # Use rapidity formula
            beta = v_mag / C_LIGHT
            beta_safe = np.clip(beta, 0, 0.9999)  # Avoid division by zero
            return np.arctanh(beta_safe)
        else:
            # Non-relativistic: η ≈ 0
            return np.zeros(positions.shape[0])
    
    def get_diagnostics(self):
        """
        Return diagnostic information for output.
        
        Returns:
            Dictionary with entropic quantities
        """
        diagnostics = {
            'tau_entropic': self.tau_entropic,
            'S_I': self.S_I,
            'visibility': self.visibility,
            'lambda_mean': np.mean(self.lambda_history[-100:]) if self.lambda_history else 0,
            'Pi_mean': np.mean(self.Pi_history[-100:]) if self.Pi_history else 0,
            'alpha_mean': np.mean(self.alpha_history[-100:]) if self.alpha_history else 1,
        }
        
        if self.track_complex_charge:
            diagnostics['Q_real'] = self.Q_real
            diagnostics['Q_imag'] = self.Q_imag
        
        return diagnostics


# ===================================================================
# Factory function for i-PI motion registry
# ===================================================================

def create_entropic_langevin(dt, **kwargs):
    """Factory function for i-PI motion class registry."""
    return EntropicLangevinMotion(timestep=dt, **kwargs)
