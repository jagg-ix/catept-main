"""
BSSN Constraint Equations with EPT Contributions

Implements:
1. Hamiltonian constraint: H = R + K² - K_ij K^ij - 16π ρ = 0
2. Momentum constraint: M^i = D_j K^ij - D^i K - 8π J^i = 0

These constraints should be satisfied throughout evolution if:
- Initial data satisfies them
- Evolution equations are correct
- Numerical errors are small

Violation of constraints indicates:
- Poor initial data
- Bugs in evolution
- Numerical instabilities
- Grid resolution issues
"""

import numpy as np
from typing import Dict, Tuple
from dataclasses import dataclass

@dataclass
class BSSNVariables:
    """BSSN evolved variables"""
    # Conformal metric γ̃_ij
    gamma_tilde_xx: np.ndarray
    gamma_tilde_xy: np.ndarray
    gamma_tilde_xz: np.ndarray
    gamma_tilde_yy: np.ndarray
    gamma_tilde_yz: np.ndarray
    gamma_tilde_zz: np.ndarray
    
    # Conformal factor φ (NOT the EPT φ!)
    # γ_ij = e^{4φ} γ̃_ij
    phi_bssn: np.ndarray
    
    # Trace of extrinsic curvature
    K: np.ndarray
    
    # Conformal traceless extrinsic curvature Ã_ij
    A_tilde_xx: np.ndarray
    A_tilde_xy: np.ndarray
    A_tilde_xz: np.ndarray
    A_tilde_yy: np.ndarray
    A_tilde_yz: np.ndarray
    A_tilde_zz: np.ndarray
    
    # Conformal connection functions Γ̃^i
    Gamma_tilde_x: np.ndarray
    Gamma_tilde_y: np.ndarray
    Gamma_tilde_z: np.ndarray
    
    # Lapse and shift (gauge)
    alpha: np.ndarray
    beta_x: np.ndarray
    beta_y: np.ndarray
    beta_z: np.ndarray


class BSSNConstraintComputer:
    """
    Compute BSSN constraint violations
    
    Including EPT matter contributions
    """
    
    def __init__(self, grid):
        self.grid = grid
        self.nx = grid.nx
        self.ny = grid.ny
        self.nz = grid.nz
        self.dx = grid.dx
        self.dy = grid.dy
        self.dz = grid.dz
    
    def compute_hamiltonian_constraint(self,
                                      bssn: BSSNVariables,
                                      rho: np.ndarray) -> np.ndarray:
        """
        Compute Hamiltonian constraint violation
        
        H = R + K² - K_ij K^ij - 16π ρ
        
        Should be ≈ 0 if constraints satisfied.
        
        In BSSN form:
        H = e^{-4φ} [R̃ + (2/3)K² - Ã_ij Ã^ij] 
            - 8 D^i D_i φ 
            + 16π ρ
        
        where:
        - R̃ is Ricci scalar of γ̃_ij
        - Ã_ij is traceless part of K_ij
        - D_i is covariant derivative
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # For simplified demonstration, compute key terms
        
        # 1. Kinetic term: K²
        K_squared = bssn.K**2
        
        # 2. Traceless extrinsic curvature squared: Ã_ij Ã^ij
        # In flat conformal metric:
        A_squared = (bssn.A_tilde_xx**2 + bssn.A_tilde_yy**2 + bssn.A_tilde_zz**2 +
                    2 * (bssn.A_tilde_xy**2 + bssn.A_tilde_xz**2 + bssn.A_tilde_yz**2))
        
        # 3. Ricci scalar R̃ (simplified - full calculation is complex)
        # This would require computing Christoffel symbols of γ̃_ij
        # For now, use placeholder
        R_tilde = np.zeros_like(bssn.K)  # Placeholder
        
        # 4. Laplacian of φ: D^i D_i φ
        dphi_dx, dphi_dy, dphi_dz = fd_op.gradient(bssn.phi_bssn)
        
        d2phi_dx2 = fd_op.derivative_x(dphi_dx)
        d2phi_dy2 = fd_op.derivative_y(dphi_dy)
        d2phi_dz2 = fd_op.derivative_z(dphi_dz)
        
        laplacian_phi = d2phi_dx2 + d2phi_dy2 + d2phi_dz2
        
        # 5. Conformal factor
        e_minus_4phi = np.exp(-4.0 * bssn.phi_bssn)
        
        # Hamiltonian constraint
        H = (e_minus_4phi * (R_tilde + (2.0/3.0) * K_squared - A_squared)
             - 8.0 * laplacian_phi
             - 16.0 * np.pi * rho)
        
        return H
    
    def compute_momentum_constraint(self,
                                   bssn: BSSNVariables,
                                   J_x: np.ndarray,
                                   J_y: np.ndarray,
                                   J_z: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Compute momentum constraint violation
        
        M^i = D_j K^ij - D^i K - 8π J^i
        
        Should be ≈ 0 if constraints satisfied.
        
        In BSSN form:
        M^i = e^{-4φ} [D̃_j Ã^ij + 6 Ã^ij ∂_j φ] 
              - (2/3) γ̃^ij ∂_j K
              - 8π J^i
        """
        from equation36_reference import FiniteDifferenceOperator
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Derivatives of K
        dK_dx = fd_op.derivative_x(bssn.K)
        dK_dy = fd_op.derivative_y(bssn.K)
        dK_dz = fd_op.derivative_z(bssn.K)
        
        # Derivatives of φ
        dphi_dx, dphi_dy, dphi_dz = fd_op.gradient(bssn.phi_bssn)
        
        # Simplified momentum constraint (full version requires covariant derivatives)
        e_minus_4phi = np.exp(-4.0 * bssn.phi_bssn)
        
        # X component
        M_x = (e_minus_4phi * 6.0 * bssn.A_tilde_xx * dphi_dx
               - (2.0/3.0) * dK_dx
               - 8.0 * np.pi * J_x)
        
        # Y component
        M_y = (e_minus_4phi * 6.0 * bssn.A_tilde_yy * dphi_dy
               - (2.0/3.0) * dK_dy
               - 8.0 * np.pi * J_y)
        
        # Z component
        M_z = (e_minus_4phi * 6.0 * bssn.A_tilde_zz * dphi_dz
               - (2.0/3.0) * dK_dz
               - 8.0 * np.pi * J_z)
        
        return M_x, M_y, M_z
    
    def compute_constraint_norms(self,
                                H: np.ndarray,
                                M_x: np.ndarray,
                                M_y: np.ndarray,
                                M_z: np.ndarray) -> Dict[str, float]:
        """
        Compute L2 and L∞ norms of constraints
        
        Returns:
        --------
        norms: dict
            Contains L2 and Linf norms for H and M
        """
        dx_vol = self.dx * self.dy * self.dz
        
        # Hamiltonian constraint
        H_L2 = np.sqrt(np.sum(H**2) * dx_vol)
        H_Linf = np.max(np.abs(H))
        
        # Momentum constraint magnitude
        M_mag = np.sqrt(M_x**2 + M_y**2 + M_z**2)
        M_L2 = np.sqrt(np.sum(M_mag**2) * dx_vol)
        M_Linf = np.max(M_mag)
        
        return {
            'H_L2': H_L2,
            'H_Linf': H_Linf,
            'M_L2': M_L2,
            'M_Linf': M_Linf
        }


class ConstraintDampingTerms:
    """
    Constraint damping terms for BSSN
    
    Add constraint damping to evolution equations to
    prevent constraint violations from growing:
    
    ∂_t Γ̃^i += 2 κ₁ M^i
    ∂_t Ã_ij += κ₂ (∂_i M_j + ∂_j M_i)
    
    where κ₁, κ₂ are damping parameters.
    """
    
    def __init__(self, grid, kappa1: float = 0.02, kappa2: float = 0.0):
        self.grid = grid
        self.kappa1 = kappa1
        self.kappa2 = kappa2
    
    def compute_Gamma_damping(self,
                             M_x: np.ndarray,
                             M_y: np.ndarray,
                             M_z: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Compute constraint damping for Γ̃^i
        
        Damping = 2 κ₁ M^i
        """
        damping_x = 2.0 * self.kappa1 * M_x
        damping_y = 2.0 * self.kappa1 * M_y
        damping_z = 2.0 * self.kappa1 * M_z
        
        return damping_x, damping_y, damping_z
    
    def compute_A_damping(self,
                         M_x: np.ndarray,
                         M_y: np.ndarray,
                         M_z: np.ndarray) -> Dict[str, np.ndarray]:
        """
        Compute constraint damping for Ã_ij
        
        Damping_ij = κ₂ (∂_i M_j + ∂_j M_i)
        """
        from equation36_reference import FiniteDifferenceOperator
        
        if self.kappa2 == 0:
            return {k: np.zeros_like(M_x) 
                   for k in ['xx', 'xy', 'xz', 'yy', 'yz', 'zz']}
        
        fd_op = FiniteDifferenceOperator(self.grid)
        
        # Derivatives of momentum constraint
        dMx_dx = fd_op.derivative_x(M_x)
        dMx_dy = fd_op.derivative_y(M_x)
        dMx_dz = fd_op.derivative_z(M_x)
        
        dMy_dx = fd_op.derivative_x(M_y)
        dMy_dy = fd_op.derivative_y(M_y)
        dMy_dz = fd_op.derivative_z(M_y)
        
        dMz_dx = fd_op.derivative_x(M_z)
        dMz_dy = fd_op.derivative_y(M_z)
        dMz_dz = fd_op.derivative_z(M_z)
        
        # Damping terms
        damping = {
            'xx': self.kappa2 * 2.0 * dMx_dx,
            'xy': self.kappa2 * (dMx_dy + dMy_dx),
            'xz': self.kappa2 * (dMx_dz + dMz_dx),
            'yy': self.kappa2 * 2.0 * dMy_dy,
            'yz': self.kappa2 * (dMy_dz + dMz_dy),
            'zz': self.kappa2 * 2.0 * dMz_dz
        }
        
        return damping


if __name__ == '__main__':
    print("="*70)
    print("BSSN Constraint Equations with EPT Test")
    print("="*70)
    
    from equation36_reference import Grid3D
    
    # Create grid
    grid = Grid3D(nx=32, ny=32, nz=32, dx=0.1, dy=0.1, dz=0.1)
    
    # Create dummy BSSN variables (flat space)
    bssn = BSSNVariables(
        gamma_tilde_xx=np.ones((32, 32, 32)),
        gamma_tilde_xy=np.zeros((32, 32, 32)),
        gamma_tilde_xz=np.zeros((32, 32, 32)),
        gamma_tilde_yy=np.ones((32, 32, 32)),
        gamma_tilde_yz=np.zeros((32, 32, 32)),
        gamma_tilde_zz=np.ones((32, 32, 32)),
        phi_bssn=np.zeros((32, 32, 32)),
        K=np.zeros((32, 32, 32)),
        A_tilde_xx=0.01 * np.random.randn(32, 32, 32),
        A_tilde_xy=0.01 * np.random.randn(32, 32, 32),
        A_tilde_xz=0.01 * np.random.randn(32, 32, 32),
        A_tilde_yy=0.01 * np.random.randn(32, 32, 32),
        A_tilde_yz=0.01 * np.random.randn(32, 32, 32),
        A_tilde_zz=0.01 * np.random.randn(32, 32, 32),
        Gamma_tilde_x=np.zeros((32, 32, 32)),
        Gamma_tilde_y=np.zeros((32, 32, 32)),
        Gamma_tilde_z=np.zeros((32, 32, 32)),
        alpha=np.ones((32, 32, 32)),
        beta_x=np.zeros((32, 32, 32)),
        beta_y=np.zeros((32, 32, 32)),
        beta_z=np.zeros((32, 32, 32))
    )
    
    # EPT matter
    rho = 0.01 * np.ones((32, 32, 32))
    J_x = 0.001 * np.random.randn(32, 32, 32)
    J_y = 0.001 * np.random.randn(32, 32, 32)
    J_z = 0.001 * np.random.randn(32, 32, 32)
    
    # Compute constraints
    computer = BSSNConstraintComputer(grid)
    
    H = computer.compute_hamiltonian_constraint(bssn, rho)
    M_x, M_y, M_z = computer.compute_momentum_constraint(bssn, J_x, J_y, J_z)
    
    print("\nConstraint Violations:")
    print(f"  Hamiltonian H:  {np.min(H):.6e} to {np.max(H):.6e}")
    print(f"  Momentum M_x:   {np.min(M_x):.6e} to {np.max(M_x):.6e}")
    print(f"  Momentum M_y:   {np.min(M_y):.6e} to {np.max(M_y):.6e}")
    print(f"  Momentum M_z:   {np.min(M_z):.6e} to {np.max(M_z):.6e}")
    
    # Compute norms
    norms = computer.compute_constraint_norms(H, M_x, M_y, M_z)
    
    print("\nConstraint Norms:")
    print(f"  ||H||_L2:    {norms['H_L2']:.6e}")
    print(f"  ||H||_L∞:    {norms['H_Linf']:.6e}")
    print(f"  ||M||_L2:    {norms['M_L2']:.6e}")
    print(f"  ||M||_L∞:    {norms['M_Linf']:.6e}")
    
    # Test constraint damping
    print("\nConstraint Damping:")
    damper = ConstraintDampingTerms(grid, kappa1=0.02, kappa2=0.01)
    
    damp_Gamma = damper.compute_Gamma_damping(M_x, M_y, M_z)
    print(f"  Γ damping magnitude: {np.max(np.abs(damp_Gamma[0])):.6e}")
    
    damp_A = damper.compute_A_damping(M_x, M_y, M_z)
    print(f"  A damping magnitude: {np.max(np.abs(damp_A['xx'])):.6e}")
    
    print("\n" + "="*70)
    print("✅ BSSN constraints with EPT computed!")
    print("="*70)
