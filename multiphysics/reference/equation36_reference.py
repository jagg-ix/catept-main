"""
Reference Implementation: Equation 36 (Spatial Components)
S_ij = ∇_i∇_j φ - γ_ij □φ

This implements the CORRECT equations from the CAT/EPT paper.
AMSS C++ code should match THIS implementation.

Author: Claude (AI Assistant)
Date: 2026-02-11
Version: 1.0 - Initial spatial implementation

Note: This focuses on spatial components S_ij for BSSN integration.
Full 4D implementation will be added later.
"""

import numpy as np
from typing import Tuple, Dict, Optional
from dataclasses import dataclass

@dataclass
class Grid3D:
    """3D Cartesian grid specification"""
    nx: int
    ny: int
    nz: int
    dx: float
    dy: float
    dz: float
    
    @property
    def shape(self) -> Tuple[int, int, int]:
        return (self.nx, self.ny, self.nz)
    
    @property
    def volume_element(self) -> float:
        return self.dx * self.dy * self.dz


class MetricInverter:
    """
    Invert 3x3 symmetric metric tensors
    
    Uses analytical cofactor method for stability
    """
    
    @staticmethod
    def invert_3x3_symmetric(gxx: np.ndarray,
                            gxy: np.ndarray,
                            gxz: np.ndarray,
                            gyy: np.ndarray,
                            gyz: np.ndarray,
                            gzz: np.ndarray) -> Tuple[np.ndarray, ...]:
        """
        Invert symmetric 3x3 matrix using cofactors
        
        Returns: (u_xx, u_xy, u_xz, u_yy, u_yz, u_zz, det)
        where u_ij = γ^{ij} (inverse metric)
        """
        # Cofactors
        Cxx = gyy * gzz - gyz * gyz
        Cxy = gxz * gyz - gxy * gzz
        Cxz = gxy * gyz - gxz * gyy
        Cyy = gxx * gzz - gxz * gxz
        Cyz = gxz * gxy - gxx * gyz
        Czz = gxx * gyy - gxy * gxy
        
        # Determinant
        det = gxx * Cxx + gxy * Cxy + gxz * Cxz
        
        # Check for singularity
        singular = np.abs(det) < 1e-30
        if np.any(singular):
            print(f"⚠️  Warning: {np.sum(singular)} points have near-singular metric")
            # Set small values to avoid division by zero
            det[singular] = 1e-30
        
        # Inverse
        invdet = 1.0 / det
        u_xx = Cxx * invdet
        u_xy = Cxy * invdet
        u_xz = Cxz * invdet
        u_yy = Cyy * invdet
        u_yz = Cyz * invdet
        u_zz = Czz * invdet
        
        return u_xx, u_xy, u_xz, u_yy, u_yz, u_zz, det


class FiniteDifferenceOperator:
    """
    Finite difference operators for derivatives
    
    Uses 4th-order centered differences in interior
    2nd-order near boundaries
    """
    
    def __init__(self, grid: Grid3D):
        self.grid = grid
    
    def gradient(self, phi: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Compute gradient ∂_i φ using 4th-order centered differences
        
        Returns: (dphi_dx, dphi_dy, dphi_dz)
        """
        dphi_dx = np.zeros_like(phi)
        dphi_dy = np.zeros_like(phi)
        dphi_dz = np.zeros_like(phi)
        
        # 4th order interior (i=2 to nx-3)
        dphi_dx[2:-2, :, :] = (
            -phi[4:, :, :] + 8*phi[3:-1, :, :] - 
            8*phi[1:-3, :, :] + phi[:-4, :, :]
        ) / (12 * self.grid.dx)
        
        dphi_dy[:, 2:-2, :] = (
            -phi[:, 4:, :] + 8*phi[:, 3:-1, :] - 
            8*phi[:, 1:-3, :] + phi[:, :-4, :]
        ) / (12 * self.grid.dy)
        
        dphi_dz[:, :, 2:-2] = (
            -phi[:, :, 4:] + 8*phi[:, :, 3:-1] - 
            8*phi[:, :, 1:-3] + phi[:, :, :-4]
        ) / (12 * self.grid.dz)
        
        # 2nd order near boundaries
        # Left boundary (i=0,1)
        dphi_dx[1, :, :] = (phi[2, :, :] - phi[0, :, :]) / (2 * self.grid.dx)
        # Right boundary (i=nx-2, nx-1)
        dphi_dx[-2, :, :] = (phi[-1, :, :] - phi[-3, :, :]) / (2 * self.grid.dx)
        
        # Similar for y, z boundaries
        dphi_dy[:, 1, :] = (phi[:, 2, :] - phi[:, 0, :]) / (2 * self.grid.dy)
        dphi_dy[:, -2, :] = (phi[:, -1, :] - phi[:, -3, :]) / (2 * self.grid.dy)
        
        dphi_dz[:, :, 1] = (phi[:, :, 2] - phi[:, :, 0]) / (2 * self.grid.dz)
        dphi_dz[:, :, -2] = (phi[:, :, -1] - phi[:, :, -3]) / (2 * self.grid.dz)
        
        return dphi_dx, dphi_dy, dphi_dz
    
    def laplacian(self, phi: np.ndarray) -> np.ndarray:
        """
        Compute Laplacian ∂_i∂_i φ (flat space)
        
        This is the d'Alembertian for spatial slice
        """
        d2phi = np.zeros_like(phi)
        
        # 4th order interior
        d2phi[2:-2, :, :] += (
            -phi[4:, :, :] + 16*phi[3:-1, :, :] - 30*phi[2:-2, :, :] + 
            16*phi[1:-3, :, :] - phi[:-4, :, :]
        ) / (12 * self.grid.dx**2)
        
        d2phi[:, 2:-2, :] += (
            -phi[:, 4:, :] + 16*phi[:, 3:-1, :] - 30*phi[:, 2:-2, :] + 
            16*phi[:, 1:-3, :] - phi[:, :-4, :]
        ) / (12 * self.grid.dy**2)
        
        d2phi[:, :, 2:-2] += (
            -phi[:, :, 4:] + 16*phi[:, :, 3:-1] - 30*phi[:, :, 2:-2] + 
            16*phi[:, :, 1:-3] - phi[:, :, :-4]
        ) / (12 * self.grid.dz**2)
        
        # 2nd order near boundaries
        d2phi[1, :, :] += (phi[2, :, :] - 2*phi[1, :, :] + phi[0, :, :]) / self.grid.dx**2
        d2phi[-2, :, :] += (phi[-1, :, :] - 2*phi[-2, :, :] + phi[-3, :, :]) / self.grid.dx**2
        
        d2phi[:, 1, :] += (phi[:, 2, :] - 2*phi[:, 1, :] + phi[:, 0, :]) / self.grid.dy**2
        d2phi[:, -2, :] += (phi[:, -1, :] - 2*phi[:, -2, :] + phi[:, -3, :]) / self.grid.dy**2
        
        d2phi[:, :, 1] += (phi[:, :, 2] - 2*phi[:, :, 1] + phi[:, :, 0]) / self.grid.dz**2
        d2phi[:, :, -2] += (phi[:, :, -1] - 2*phi[:, :, -2] - phi[:, :, -3]) / self.grid.dz**2
        
        return d2phi
    
    def second_derivative_xx(self, phi: np.ndarray) -> np.ndarray:
        """Compute ∂_x∂_x φ"""
        d2phi_dxx = np.zeros_like(phi)
        
        d2phi_dxx[2:-2, :, :] = (
            -phi[4:, :, :] + 16*phi[3:-1, :, :] - 30*phi[2:-2, :, :] + 
            16*phi[1:-3, :, :] - phi[:-4, :, :]
        ) / (12 * self.grid.dx**2)
        
        return d2phi_dxx
    
    def second_derivative_xy(self, phi: np.ndarray) -> np.ndarray:
        """Compute ∂_x∂_y φ"""
        d2phi_dxy = np.zeros_like(phi)
        
        # 2nd order (simpler for mixed derivatives)
        d2phi_dxy[1:-1, 1:-1, :] = (
            phi[2:, 2:, :] - phi[2:, :-2, :] -
            phi[:-2, 2:, :] + phi[:-2, :-2, :]
        ) / (4 * self.grid.dx * self.grid.dy)
        
        return d2phi_dxy
    
    # Similar for yy, xz, yz, zz ...


class Equation36Computer:
    """
    Compute S_ij = ∇_i∇_j φ - γ_ij □φ
    
    This is the CORRECT implementation of Equation 36
    for spatial components in 3+1 formalism.
    """
    
    def __init__(self, grid: Grid3D):
        self.grid = grid
        self.fd_op = FiniteDifferenceOperator(grid)
        self.inverter = MetricInverter()
    
    def compute_S_ij_flat_space(self, phi: np.ndarray) -> Dict[str, np.ndarray]:
        """
        Compute S_ij in flat space (Minkowski)
        
        Simplified version where:
        - γ_ij = δ_ij (flat metric)
        - Christoffel symbols vanish
        - ∇_i∇_j φ = ∂_i∂_j φ
        - □φ = ∂_i∂_i φ
        
        Returns:
        --------
        dict with keys: 'xx', 'xy', 'xz', 'yy', 'yz', 'zz'
        """
        print("Computing Equation 36 in flat space...")
        
        # Step 1: Compute second derivatives
        print("  Computing Hessian ∂_i∂_j φ...")
        d2phi_dxx = self.fd_op.second_derivative_xx(phi)
        d2phi_dyy = self._second_derivative_yy(phi)
        d2phi_dzz = self._second_derivative_zz(phi)
        d2phi_dxy = self.fd_op.second_derivative_xy(phi)
        d2phi_dxz = self._second_derivative_xz(phi)
        d2phi_dyz = self._second_derivative_yz(phi)
        
        # Step 2: Compute Laplacian (d'Alembertian for spatial slice)
        print("  Computing □φ = ∂_i∂_i φ...")
        box_phi = d2phi_dxx + d2phi_dyy + d2phi_dzz
        
        # Step 3: Construct S_ij = ∂_i∂_j φ - δ_ij □φ
        print("  Constructing S_ij = Hessian - γ_ij □φ...")
        S_ij = {
            'xx': d2phi_dxx - box_phi,  # - δ_xx □φ
            'xy': d2phi_dxy,             # - δ_xy □φ = 0
            'xz': d2phi_dxz,
            'yy': d2phi_dyy - box_phi,
            'yz': d2phi_dyz,
            'zz': d2phi_dzz - box_phi
        }
        
        print("✅ Equation 36 computed (flat space)")
        return S_ij
    
    def compute_S_ij_curved_space(self,
                                  phi: np.ndarray,
                                  gxx: np.ndarray,
                                  gxy: np.ndarray,
                                  gxz: np.ndarray,
                                  gyy: np.ndarray,
                                  gyz: np.ndarray,
                                  gzz: np.ndarray) -> Dict[str, np.ndarray]:
        """
        Compute S_ij in curved space
        
        Full implementation with:
        - Covariant derivatives ∇_i∇_j φ
        - Christoffel symbol corrections
        - General metric γ_ij
        
        Returns:
        --------
        dict with S_ij components
        """
        print("Computing Equation 36 in curved space...")
        
        # Step 1: Compute Christoffel symbols
        print("  Computing Christoffel symbols Γ^k_{ij}...")
        Gamma = self._compute_christoffel(gxx, gxy, gxz, gyy, gyz, gzz)
        
        # Step 2: Compute gradient
        print("  Computing gradient ∂_i φ...")
        dphi_dx, dphi_dy, dphi_dz = self.fd_op.gradient(phi)
        
        # Step 3: Compute covariant Hessian
        print("  Computing covariant Hessian ∇_i∇_j φ...")
        Hess = self._compute_covariant_hessian(
            phi, dphi_dx, dphi_dy, dphi_dz, Gamma
        )
        
        # Step 4: Invert metric
        print("  Inverting metric γ_ij...")
        u_xx, u_xy, u_xz, u_yy, u_yz, u_zz, det = \
            self.inverter.invert_3x3_symmetric(gxx, gxy, gxz, gyy, gyz, gzz)
        
        # Step 5: Compute d'Alembertian □φ = γ^{ij} ∇_i∇_j φ
        print("  Computing d'Alembertian □φ...")
        box_phi = (
            u_xx * Hess['xx'] + u_yy * Hess['yy'] + u_zz * Hess['zz'] +
            2 * u_xy * Hess['xy'] + 2 * u_xz * Hess['xz'] + 2 * u_yz * Hess['yz']
        )
        
        # Step 6: Construct S_ij = ∇_i∇_j φ - γ_ij □φ
        print("  Constructing S_ij...")
        S_ij = {
            'xx': Hess['xx'] - gxx * box_phi,
            'xy': Hess['xy'] - gxy * box_phi,
            'xz': Hess['xz'] - gxz * box_phi,
            'yy': Hess['yy'] - gyy * box_phi,
            'yz': Hess['yz'] - gyz * box_phi,
            'zz': Hess['zz'] - gzz * box_phi
        }
        
        print("✅ Equation 36 computed (curved space)")
        return S_ij
    
    def _second_derivative_yy(self, phi: np.ndarray) -> np.ndarray:
        """Compute ∂_y∂_y φ"""
        d2phi = np.zeros_like(phi)
        d2phi[:, 2:-2, :] = (
            -phi[:, 4:, :] + 16*phi[:, 3:-1, :] - 30*phi[:, 2:-2, :] + 
            16*phi[:, 1:-3, :] - phi[:, :-4, :]
        ) / (12 * self.grid.dy**2)
        return d2phi
    
    def _second_derivative_zz(self, phi: np.ndarray) -> np.ndarray:
        """Compute ∂_z∂_z φ"""
        d2phi = np.zeros_like(phi)
        d2phi[:, :, 2:-2] = (
            -phi[:, :, 4:] + 16*phi[:, :, 3:-1] - 30*phi[:, :, 2:-2] + 
            16*phi[:, :, 1:-3] - phi[:, :, :-4]
        ) / (12 * self.grid.dz**2)
        return d2phi
    
    def _second_derivative_xz(self, phi: np.ndarray) -> np.ndarray:
        """Compute ∂_x∂_z φ"""
        d2phi = np.zeros_like(phi)
        d2phi[1:-1, :, 1:-1] = (
            phi[2:, :, 2:] - phi[2:, :, :-2] -
            phi[:-2, :, 2:] + phi[:-2, :, :-2]
        ) / (4 * self.grid.dx * self.grid.dz)
        return d2phi
    
    def _second_derivative_yz(self, phi: np.ndarray) -> np.ndarray:
        """Compute ∂_y∂_z φ"""
        d2phi = np.zeros_like(phi)
        d2phi[:, 1:-1, 1:-1] = (
            phi[:, 2:, 2:] - phi[:, 2:, :-2] -
            phi[:, :-2, 2:] + phi[:, :-2, :-2]
        ) / (4 * self.grid.dy * self.grid.dz)
        return d2phi
    
    def _compute_christoffel(self, gxx, gxy, gxz, gyy, gyz, gzz):
        """
        Compute Christoffel symbols Γ^k_{ij}
        
        Γ^k_{ij} = 1/2 γ^{km} (∂_i γ_mj + ∂_j γ_im - ∂_m γ_ij)
        """
        # Compute metric derivatives
        d_gxx_dx, d_gxx_dy, d_gxx_dz = self.fd_op.gradient(gxx)
        d_gxy_dx, d_gxy_dy, d_gxy_dz = self.fd_op.gradient(gxy)
        d_gxz_dx, d_gxz_dy, d_gxz_dz = self.fd_op.gradient(gxz)
        d_gyy_dx, d_gyy_dy, d_gyy_dz = self.fd_op.gradient(gyy)
        d_gyz_dx, d_gyz_dy, d_gyz_dz = self.fd_op.gradient(gyz)
        d_gzz_dx, d_gzz_dy, d_gzz_dz = self.fd_op.gradient(gzz)
        
        # Invert metric
        u_xx, u_xy, u_xz, u_yy, u_yz, u_zz, det = \
            self.inverter.invert_3x3_symmetric(gxx, gxy, gxz, gyy, gyz, gzz)
        
        # Compute all 18 independent components
        # Γ^x_{ij} components
        Gamma_x_xx = 0.5 * (u_xx * (2*d_gxx_dx - d_gxx_dx) + 
                            u_xy * (2*d_gxy_dx - d_gxx_dy) + 
                            u_xz * (2*d_gxz_dx - d_gxx_dz))
        Gamma_x_xy = 0.5 * (u_xx * (d_gxx_dy + d_gxy_dx - d_gxy_dx) + 
                            u_xy * (d_gxy_dy + d_gyy_dx - d_gxy_dy) + 
                            u_xz * (d_gxz_dy + d_gyz_dx - d_gxy_dz))
        Gamma_x_xz = 0.5 * (u_xx * (d_gxx_dz + d_gxz_dx - d_gxz_dx) + 
                            u_xy * (d_gxy_dz + d_gyz_dx - d_gxz_dy) + 
                            u_xz * (d_gxz_dz + d_gzz_dx - d_gxz_dz))
        Gamma_x_yy = 0.5 * (u_xx * (2*d_gxy_dy - d_gyy_dx) + 
                            u_xy * (2*d_gyy_dy - d_gyy_dy) + 
                            u_xz * (2*d_gyz_dy - d_gyy_dz))
        Gamma_x_yz = 0.5 * (u_xx * (d_gxy_dz + d_gxz_dy - d_gyz_dx) + 
                            u_xy * (d_gyy_dz + d_gyz_dy - d_gyz_dy) + 
                            u_xz * (d_gyz_dz + d_gzz_dy - d_gyz_dz))
        Gamma_x_zz = 0.5 * (u_xx * (2*d_gxz_dz - d_gzz_dx) + 
                            u_xy * (2*d_gyz_dz - d_gzz_dy) + 
                            u_xz * (2*d_gzz_dz - d_gzz_dz))
        
        # Γ^y_{ij} components
        Gamma_y_xx = 0.5 * (u_xy * (2*d_gxx_dx - d_gxx_dx) + 
                            u_yy * (2*d_gxy_dx - d_gxx_dy) + 
                            u_yz * (2*d_gxz_dx - d_gxx_dz))
        Gamma_y_xy = 0.5 * (u_xy * (d_gxx_dy + d_gxy_dx - d_gxy_dx) + 
                            u_yy * (d_gxy_dy + d_gyy_dx - d_gxy_dy) + 
                            u_yz * (d_gxz_dy + d_gyz_dx - d_gxy_dz))
        Gamma_y_xz = 0.5 * (u_xy * (d_gxx_dz + d_gxz_dx - d_gxz_dx) + 
                            u_yy * (d_gxy_dz + d_gyz_dx - d_gxz_dy) + 
                            u_yz * (d_gxz_dz + d_gzz_dx - d_gxz_dz))
        Gamma_y_yy = 0.5 * (u_xy * (2*d_gxy_dy - d_gyy_dx) + 
                            u_yy * (2*d_gyy_dy - d_gyy_dy) + 
                            u_yz * (2*d_gyz_dy - d_gyy_dz))
        Gamma_y_yz = 0.5 * (u_xy * (d_gxy_dz + d_gxz_dy - d_gyz_dx) + 
                            u_yy * (d_gyy_dz + d_gyz_dy - d_gyz_dy) + 
                            u_yz * (d_gyz_dz + d_gzz_dy - d_gyz_dz))
        Gamma_y_zz = 0.5 * (u_xy * (2*d_gxz_dz - d_gzz_dx) + 
                            u_yy * (2*d_gyz_dz - d_gzz_dy) + 
                            u_yz * (2*d_gzz_dz - d_gzz_dz))
        
        # Γ^z_{ij} components
        Gamma_z_xx = 0.5 * (u_xz * (2*d_gxx_dx - d_gxx_dx) + 
                            u_yz * (2*d_gxy_dx - d_gxx_dy) + 
                            u_zz * (2*d_gxz_dx - d_gxx_dz))
        Gamma_z_xy = 0.5 * (u_xz * (d_gxx_dy + d_gxy_dx - d_gxy_dx) + 
                            u_yz * (d_gxy_dy + d_gyy_dx - d_gxy_dy) + 
                            u_zz * (d_gxz_dy + d_gyz_dx - d_gxy_dz))
        Gamma_z_xz = 0.5 * (u_xz * (d_gxx_dz + d_gxz_dx - d_gxz_dx) + 
                            u_yz * (d_gxy_dz + d_gyz_dx - d_gxz_dy) + 
                            u_zz * (d_gxz_dz + d_gzz_dx - d_gxz_dz))
        Gamma_z_yy = 0.5 * (u_xz * (2*d_gxy_dy - d_gyy_dx) + 
                            u_yz * (2*d_gyy_dy - d_gyy_dy) + 
                            u_zz * (2*d_gyz_dy - d_gyy_dz))
        Gamma_z_yz = 0.5 * (u_xz * (d_gxy_dz + d_gxz_dy - d_gyz_dx) + 
                            u_yz * (d_gyy_dz + d_gyz_dy - d_gyz_dy) + 
                            u_zz * (d_gyz_dz + d_gzz_dy - d_gyz_dz))
        Gamma_z_zz = 0.5 * (u_xz * (2*d_gxz_dz - d_gzz_dx) + 
                            u_yz * (2*d_gyz_dz - d_gzz_dy) + 
                            u_zz * (2*d_gzz_dz - d_gzz_dz))
        
        return {
            'x_xx': Gamma_x_xx, 'x_xy': Gamma_x_xy, 'x_xz': Gamma_x_xz,
            'x_yy': Gamma_x_yy, 'x_yz': Gamma_x_yz, 'x_zz': Gamma_x_zz,
            'y_xx': Gamma_y_xx, 'y_xy': Gamma_y_xy, 'y_xz': Gamma_y_xz,
            'y_yy': Gamma_y_yy, 'y_yz': Gamma_y_yz, 'y_zz': Gamma_y_zz,
            'z_xx': Gamma_z_xx, 'z_xy': Gamma_z_xy, 'z_xz': Gamma_z_xz,
            'z_yy': Gamma_z_yy, 'z_yz': Gamma_z_yz, 'z_zz': Gamma_z_zz
        }
    
    def _compute_covariant_hessian(self, phi, dphi_dx, dphi_dy, dphi_dz, Gamma):
        """
        Compute covariant Hessian ∇_i∇_j φ = ∂_i∂_j φ - Γ^k_{ij} ∂_k φ
        """
        # Compute second derivatives ∂_i∂_j φ
        d2phi_dxx = self.fd_op.second_derivative_xx(phi)
        d2phi_dyy = self._second_derivative_yy(phi)
        d2phi_dzz = self._second_derivative_zz(phi)
        d2phi_dxy = self.fd_op.second_derivative_xy(phi)
        d2phi_dxz = self._second_derivative_xz(phi)
        d2phi_dyz = self._second_derivative_yz(phi)
        
        # Subtract Christoffel corrections
        Hess_xx = d2phi_dxx - (Gamma['x_xx']*dphi_dx + Gamma['y_xx']*dphi_dy + Gamma['z_xx']*dphi_dz)
        Hess_xy = d2phi_dxy - (Gamma['x_xy']*dphi_dx + Gamma['y_xy']*dphi_dy + Gamma['z_xy']*dphi_dz)
        Hess_xz = d2phi_dxz - (Gamma['x_xz']*dphi_dx + Gamma['y_xz']*dphi_dy + Gamma['z_xz']*dphi_dz)
        Hess_yy = d2phi_dyy - (Gamma['x_yy']*dphi_dx + Gamma['y_yy']*dphi_dy + Gamma['z_yy']*dphi_dz)
        Hess_yz = d2phi_dyz - (Gamma['x_yz']*dphi_dx + Gamma['y_yz']*dphi_dy + Gamma['z_yz']*dphi_dz)
        Hess_zz = d2phi_dzz - (Gamma['x_zz']*dphi_dx + Gamma['y_zz']*dphi_dy + Gamma['z_zz']*dphi_dz)
        
        return {
            'xx': Hess_xx,
            'xy': Hess_xy,
            'xz': Hess_xz,
            'yy': Hess_yy,
            'yz': Hess_yz,
            'zz': Hess_zz
        }


if __name__ == '__main__':
    print("="*70)
    print("Equation 36 Reference Implementation Test")
    print("="*70)
    
    # Create simple test grid
    grid = Grid3D(nx=32, ny=32, nz=32, dx=0.1, dy=0.1, dz=0.1)
    print(f"\nGrid: {grid.nx} x {grid.ny} x {grid.nz}")
    print(f"Spacing: dx={grid.dx}, dy={grid.dy}, dz={grid.dz}")
    
    # Create Gaussian scalar field
    x = np.linspace(-2, 2, grid.nx)
    y = np.linspace(-2, 2, grid.ny)
    z = np.linspace(-2, 2, grid.nz)
    X, Y, Z = np.meshgrid(x, y, z, indexing='ij')
    phi = np.exp(-(X**2 + Y**2 + Z**2))
    
    print(f"\nScalar field φ:")
    print(f"  Shape: {phi.shape}")
    print(f"  Range: [{phi.min():.6f}, {phi.max():.6f}]")
    
    # Compute Equation 36
    computer = Equation36Computer(grid)
    S_ij = computer.compute_S_ij_flat_space(phi)
    
    # Display results
    print(f"\nResults:")
    for key in ['xx', 'yy', 'zz', 'xy', 'xz', 'yz']:
        val = S_ij[key]
        print(f"  S_{key}: range [{val.min():+.6e}, {val.max():+.6e}], " +
              f"max|S| = {np.max(np.abs(val)):.6e}")
    
    # Check trace
    trace = S_ij['xx'] + S_ij['yy'] + S_ij['zz']
    print(f"\n  Trace S^i_i: max = {np.max(np.abs(trace)):.6e}")
    
    print("\n✅ Test complete!")
    print("="*70)
