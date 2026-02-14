"""
Complete EPT Stress-Energy Tensor and Conservation Equations

Implements the full 4D stress-energy tensor T^μν and related quantities:
- T^00: Energy density ρ
- T^0i: Momentum density J^i
- T^ij: Spatial stress (from Equations 36 & 37)
- Energy-momentum conservation: ∇_μ T^μν = 0

These are essential for:
1. BSSN constraint equations
2. Energy conservation checks
3. Gravitational wave analysis
4. Physical diagnostics
"""

import numpy as np
from typing import Dict, Tuple
from dataclasses import dataclass

@dataclass
class StressEnergyComponents:
    """Complete stress-energy tensor components"""
    # Energy density
    rho: np.ndarray  # T^00
    
    # Momentum density
    J_x: np.ndarray  # T^0x
    J_y: np.ndarray  # T^0y
    J_z: np.ndarray  # T^0z
    
    # Spatial stress (already computed)
    S_xx: np.ndarray  # T^xx
    S_xy: np.ndarray  # T^xy
    S_xz: np.ndarray  # T^xz
    S_yy: np.ndarray  # T^yy
    S_yz: np.ndarray  # T^yz
    S_zz: np.ndarray  # T^zz


class EPTStressEnergyComputer:
    """
    Compute complete stress-energy tensor for EPT
    
    The full stress-energy tensor is:
    
    T^μν = T^μν_φ + T^μν_τ
    
    where T^μν_φ comes from Equation 36 and T^μν_τ from Equation 37.
    """
    
    def __init__(self, grid, lambda_0: float = 1.0):
        self.grid = grid
        self.lambda_0 = lambda_0
        self.nx = grid.nx
        self.ny = grid.ny
        self.nz = grid.nz
        self.dx = grid.dx
        self.dy = grid.dy
        self.dz = grid.dz
    
    def compute_energy_density_phi(self, 
                                   phi: np.ndarray,
                                   Pi: np.ndarray,
                                   dphi_dt: np.ndarray = None) -> np.ndarray:
        """
        Compute energy density from φ field
        
        ρ_φ = (1/2) Π² + (1/2) (∇φ)² + V(φ)
        
        where:
        - Π = ∂_t φ (conjugate momentum)
        - V(φ) is potential (if any)
        
        For wave equation: □φ = 0, we have
        ρ_φ = (1/2) Π² + (1/2) (∇φ)²
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Compute gradient
        dphi_dx, dphi_dy, dphi_dz = fd_op.gradient(phi)
        
        # Kinetic energy: (1/2) Π²
        rho_kinetic = 0.5 * Pi**2
        
        # Gradient energy: (1/2) (∇φ)²
        grad_phi_squared = dphi_dx**2 + dphi_dy**2 + dphi_dz**2
        rho_gradient = 0.5 * grad_phi_squared
        
        # Total energy density
        rho_phi = rho_kinetic + rho_gradient
        
        return rho_phi
    
    def compute_momentum_density_phi(self,
                                    phi: np.ndarray,
                                    Pi: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Compute momentum density from φ field
        
        J^i_φ = -Π ∂^i φ
        
        This is the energy flux in direction i.
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Compute gradient of φ
        dphi_dx, dphi_dy, dphi_dz = fd_op.gradient(phi)
        
        # Momentum density
        J_x = -Pi * dphi_dx
        J_y = -Pi * dphi_dy
        J_z = -Pi * dphi_dz
        
        return J_x, J_y, J_z
    
    def compute_energy_density_tau(self,
                                   tau: np.ndarray,
                                   dtau_dt: np.ndarray) -> np.ndarray:
        """
        Compute energy density from τ field
        
        ρ_τ = (λ₀/2) (∂_t τ)²
        
        Since ∂_t τ = λ₀ α (from evolution equation),
        where α is the lapse function:
        
        ρ_τ = (λ₀³/2) α²
        """
        # For simplicity, assume α = 1 (will be generalized)
        alpha = 1.0
        
        rho_tau = 0.5 * self.lambda_0**3 * alpha**2 * np.ones_like(tau)
        
        return rho_tau
    
    def compute_momentum_density_tau(self,
                                    tau: np.ndarray,
                                    dtau_dt: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Compute momentum density from τ field
        
        J^i_τ = -λ₀ (∂_t τ) ∂^i τ
        
        Since ∂_t τ = λ₀ α:
        
        J^i_τ = -λ₀² α ∂^i τ
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Compute gradient of τ
        dtau_dx, dtau_dy, dtau_dz = fd_op.gradient(tau)
        
        # Assume α = 1
        alpha = 1.0
        
        # Momentum density
        J_x = -self.lambda_0**2 * alpha * dtau_dx
        J_y = -self.lambda_0**2 * alpha * dtau_dy
        J_z = -self.lambda_0**2 * alpha * dtau_dz
        
        return J_x, J_y, J_z
    
    def compute_complete_stress_energy(self,
                                      phi: np.ndarray,
                                      Pi: np.ndarray,
                                      tau: np.ndarray,
                                      S_ij: Dict[str, np.ndarray],
                                      Lambda_ij: Dict[str, np.ndarray]) -> StressEnergyComponents:
        """
        Compute complete stress-energy tensor
        
        Returns T^μν with all components:
        - T^00 = ρ (energy density)
        - T^0i = J^i (momentum density)
        - T^ij = S_ij (spatial stress)
        """
        # Energy density
        rho_phi = self.compute_energy_density_phi(phi, Pi)
        rho_tau = self.compute_energy_density_tau(tau, None)
        rho = rho_phi + rho_tau
        
        # Momentum density
        J_x_phi, J_y_phi, J_z_phi = self.compute_momentum_density_phi(phi, Pi)
        J_x_tau, J_y_tau, J_z_tau = self.compute_momentum_density_tau(tau, None)
        
        J_x = J_x_phi + J_x_tau
        J_y = J_y_phi + J_y_tau
        J_z = J_z_phi + J_z_tau
        
        # Spatial stress (from Equations 36 & 37)
        # T_ij = S_ij + Λ_ij
        T_xx = S_ij['xx'] + Lambda_ij['xx']
        T_xy = S_ij['xy'] + Lambda_ij['xy']
        T_xz = S_ij['xz'] + Lambda_ij['xz']
        T_yy = S_ij['yy'] + Lambda_ij['yy']
        T_yz = S_ij['yz'] + Lambda_ij['yz']
        T_zz = S_ij['zz'] + Lambda_ij['zz']
        
        return StressEnergyComponents(
            rho=rho,
            J_x=J_x, J_y=J_y, J_z=J_z,
            S_xx=T_xx, S_xy=T_xy, S_xz=T_xz,
            S_yy=T_yy, S_yz=T_yz, S_zz=T_zz
        )
    
    def compute_trace(self, T: StressEnergyComponents, 
                     gamma_inv: Dict[str, np.ndarray] = None) -> np.ndarray:
        """
        Compute trace of stress tensor
        
        Tr(T) = γ^ij T_ij
        
        In flat space: Tr(T) = T_xx + T_yy + T_zz
        """
        if gamma_inv is None:
            # Flat space
            trace = T.S_xx + T.S_yy + T.S_zz
        else:
            # Curved space
            trace = (gamma_inv['xx'] * T.S_xx + 
                    gamma_inv['yy'] * T.S_yy + 
                    gamma_inv['zz'] * T.S_zz +
                    2 * gamma_inv['xy'] * T.S_xy +
                    2 * gamma_inv['xz'] * T.S_xz +
                    2 * gamma_inv['yz'] * T.S_yz)
        
        return trace


class EnergyConservationChecker:
    """
    Check energy-momentum conservation
    
    ∇_μ T^μν = 0
    
    In components:
    - ν=0: ∂_t ρ + ∂_i J^i = 0 (energy conservation)
    - ν=i: ∂_t J^i + ∂_j T^ij = 0 (momentum conservation)
    """
    
    def __init__(self, grid):
        self.grid = grid
    
    def compute_energy_conservation_violation(self,
                                             T_curr: StressEnergyComponents,
                                             T_prev: StressEnergyComponents,
                                             dt: float) -> np.ndarray:
        """
        Compute violation of energy conservation
        
        ∂_t ρ + ∂_i J^i ≈ 0
        
        Returns:
        --------
        violation: array
            Should be ≈ 0 if energy conserved
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Time derivative of ρ
        drho_dt = (T_curr.rho - T_prev.rho) / dt
        
        # Divergence of J
        dJ_x_dx = fd_op.derivative_x(T_curr.J_x)
        dJ_y_dy = fd_op.derivative_y(T_curr.J_y)
        dJ_z_dz = fd_op.derivative_z(T_curr.J_z)
        
        div_J = dJ_x_dx + dJ_y_dy + dJ_z_dz
        
        # Violation
        violation = drho_dt + div_J
        
        return violation
    
    def compute_momentum_conservation_violation(self,
                                               T_curr: StressEnergyComponents,
                                               T_prev: StressEnergyComponents,
                                               dt: float) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Compute violation of momentum conservation
        
        ∂_t J^i + ∂_j T^ij ≈ 0
        
        Returns:
        --------
        violation_x, violation_y, violation_z: arrays
            Should be ≈ 0 if momentum conserved
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Time derivatives of J
        dJ_x_dt = (T_curr.J_x - T_prev.J_x) / dt
        dJ_y_dt = (T_curr.J_y - T_prev.J_y) / dt
        dJ_z_dt = (T_curr.J_z - T_prev.J_z) / dt
        
        # Divergence of stress tensor
        # ∂_j T^xj = ∂_x T^xx + ∂_y T^xy + ∂_z T^xz
        div_Tx = (fd_op.derivative_x(T_curr.S_xx) +
                 fd_op.derivative_y(T_curr.S_xy) +
                 fd_op.derivative_z(T_curr.S_xz))
        
        div_Ty = (fd_op.derivative_x(T_curr.S_xy) +
                 fd_op.derivative_y(T_curr.S_yy) +
                 fd_op.derivative_z(T_curr.S_yz))
        
        div_Tz = (fd_op.derivative_x(T_curr.S_xz) +
                 fd_op.derivative_y(T_curr.S_yz) +
                 fd_op.derivative_z(T_curr.S_zz))
        
        # Violations
        violation_x = dJ_x_dt + div_Tx
        violation_y = dJ_y_dt + div_Ty
        violation_z = dJ_z_dt + div_Tz
        
        return violation_x, violation_y, violation_z


if __name__ == '__main__':
    print("="*70)
    print("Complete EPT Stress-Energy Tensor Test")
    print("="*70)
    
    from equation36_reference import Grid3D
    from ept_evolution import EPTFields
    
    # Create grid
    grid = Grid3D(nx=32, ny=32, nz=32, dx=0.1, dy=0.1, dz=0.1)
    
    # Create test fields
    x = np.arange(32) * 0.1 - 1.6
    X, Y, Z = np.meshgrid(x, x, x, indexing='ij')
    r = np.sqrt(X**2 + Y**2 + Z**2)
    
    phi = 0.1 * np.exp(-r**2)
    Pi = -0.2 * r * np.exp(-r**2)  # Some momentum
    tau = np.ones_like(phi)
    
    # Create dummy S_ij and Lambda_ij
    S_ij = {
        'xx': 0.01 * np.random.randn(32, 32, 32),
        'xy': 0.005 * np.random.randn(32, 32, 32),
        'xz': 0.005 * np.random.randn(32, 32, 32),
        'yy': 0.01 * np.random.randn(32, 32, 32),
        'yz': 0.005 * np.random.randn(32, 32, 32),
        'zz': 0.01 * np.random.randn(32, 32, 32)
    }
    
    Lambda_ij = {k: np.zeros_like(v) for k, v in S_ij.items()}
    
    # Compute stress-energy
    computer = EPTStressEnergyComputer(grid, lambda_0=1.0)
    T = computer.compute_complete_stress_energy(phi, Pi, tau, S_ij, Lambda_ij)
    
    print("\nStress-Energy Components:")
    print(f"  Energy density ρ:   {np.min(T.rho):.6e} to {np.max(T.rho):.6e}")
    print(f"  Momentum J_x:       {np.min(T.J_x):.6e} to {np.max(T.J_x):.6e}")
    print(f"  Momentum J_y:       {np.min(T.J_y):.6e} to {np.max(T.J_y):.6e}")
    print(f"  Momentum J_z:       {np.min(T.J_z):.6e} to {np.max(T.J_z):.6e}")
    print(f"  Stress S_xx:        {np.min(T.S_xx):.6e} to {np.max(T.S_xx):.6e}")
    
    # Compute trace
    trace = computer.compute_trace(T)
    print(f"\n  Trace Tr(T):        {np.min(trace):.6e} to {np.max(trace):.6e}")
    
    # Check energy density positive
    if np.all(T.rho >= 0):
        print("\n✅ Energy density non-negative (WEC satisfied)")
    else:
        print("\n⚠️  Energy density has negative values")
    
    print("\n" + "="*70)
    print("✅ Complete stress-energy tensor computed!")
    print("="*70)
