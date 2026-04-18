"""
BSSN Conformal Transformation Module

Transforms between ADM (physical) and BSSN (conformal) variables

BSSN uses conformal decomposition:
  γ_ij = e^{4φ} γ̃_ij
  
where γ̃_ij is the conformal metric with det(γ̃) = 1

Author: Claude (AI Assistant)
Date: 2026-02-11
Version: 1.0
"""

import numpy as np
from typing import Tuple, Dict

class BSSNTransformer:
    """
    Transform between ADM and BSSN conformal variables
    
    BSSN Conformal Decomposition:
    ==============================
    Physical metric: γ_ij = e^{4φ} γ̃_ij
    Conformal factor: φ = (1/12) ln(det(γ))
    Conformal metric: det(γ̃) = 1
    
    Extrinsic curvature: K_ij = e^{4φ} Ã_ij + (1/3) γ_ij K
    where K = trace(K_ij), Ã_ij is traceless
    """
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
    
    def ADM_to_BSSN(self, 
                    gxx: np.ndarray, gxy: np.ndarray, gxz: np.ndarray,
                    gyy: np.ndarray, gyz: np.ndarray, gzz: np.ndarray
                    ) -> Dict[str, np.ndarray]:
        """
        Convert ADM metric to BSSN conformal variables
        
        γ_ij → (φ, γ̃_ij)
        
        Parameters:
        -----------
        gxx, gxy, ... : arrays
            Physical metric components γ_ij
        
        Returns:
        --------
        dict with keys:
            'phi' : conformal factor
            'gtxx', 'gtxy', ... : conformal metric γ̃_ij
        """
        if self.verbose:
            print("Converting ADM → BSSN...")
        
        # Compute determinant det(γ)
        det_gamma = self._compute_determinant_3x3(gxx, gxy, gxz, gyy, gyz, gzz)
        
        # Conformal factor: φ = (1/12) ln(det(γ))
        # Add small epsilon to avoid log(0)
        phi = (1.0/12.0) * np.log(np.maximum(det_gamma, 1e-30))
        
        # Conformal transformation factor
        e_minus_4phi = np.exp(-4 * phi)
        
        # Conformal metric: γ̃_ij = e^{-4φ} γ_ij
        gtxx = gxx * e_minus_4phi
        gtxy = gxy * e_minus_4phi
        gtxz = gxz * e_minus_4phi
        gyy_tilde = gyy * e_minus_4phi
        gtyz = gyz * e_minus_4phi
        gtzz = gzz * e_minus_4phi
        
        # Verify det(γ̃) = 1 (should be exact by construction)
        det_tilde = self._compute_determinant_3x3(
            gtxx, gtxy, gtxz, gyy_tilde, gtyz, gtzz
        )
        max_det_error = np.max(np.abs(det_tilde - 1.0))
        
        if self.verbose:
            print(f"  Conformal factor φ: [{phi.min():.6f}, {phi.max():.6f}]")
            print(f"  det(γ̃) - 1: max error = {max_det_error:.6e}")
            if max_det_error > 1e-10:
                print(f"  ⚠️  Warning: det(γ̃) not exactly 1")
        
        return {
            'phi': phi,
            'gtxx': gtxx,
            'gtxy': gtxy,
            'gtxz': gtxz,
            'gtyy': gyy_tilde,
            'gtyz': gtyz,
            'gtzz': gtzz
        }
    
    def BSSN_to_ADM(self,
                    phi: np.ndarray,
                    gtxx: np.ndarray, gtxy: np.ndarray, gtxz: np.ndarray,
                    gtyy: np.ndarray, gtyz: np.ndarray, gtzz: np.ndarray
                    ) -> Dict[str, np.ndarray]:
        """
        Convert BSSN conformal variables to ADM metric
        
        (φ, γ̃_ij) → γ_ij
        
        Returns:
        --------
        dict with keys:
            'gxx', 'gxy', ... : physical metric γ_ij
        """
        if self.verbose:
            print("Converting BSSN → ADM...")
        
        # Conformal transformation factor
        e_4phi = np.exp(4 * phi)
        
        # Physical metric: γ_ij = e^{4φ} γ̃_ij
        gxx = gtxx * e_4phi
        gxy = gtxy * e_4phi
        gxz = gtxz * e_4phi
        gyy = gtyy * e_4phi
        gyz = gtyz * e_4phi
        gzz = gtzz * e_4phi
        
        return {
            'gxx': gxx,
            'gxy': gxy,
            'gxz': gxz,
            'gyy': gyy,
            'gyz': gyz,
            'gzz': gzz
        }
    
    def transform_stress_tensor_to_BSSN(self,
                                        S_ij_physical: Dict[str, np.ndarray],
                                        phi: np.ndarray) -> Dict[str, np.ndarray]:
        """
        Transform physical stress tensor S_ij to conformal S̃_ij
        
        S̃_ij = e^{-4φ} S_ij
        
        Parameters:
        -----------
        S_ij_physical : dict
            Physical stress tensor components
        phi : array
            BSSN conformal factor
        
        Returns:
        --------
        dict with conformal stress tensor S̃_ij
        """
        if self.verbose:
            print("Transforming stress tensor to BSSN...")
        
        e_minus_4phi = np.exp(-4 * phi)
        
        S_tilde = {}
        for key in ['xx', 'xy', 'xz', 'yy', 'yz', 'zz']:
            S_tilde[key] = S_ij_physical[key] * e_minus_4phi
        
        return S_tilde
    
    def transform_stress_tensor_to_ADM(self,
                                       S_ij_conformal: Dict[str, np.ndarray],
                                       phi: np.ndarray) -> Dict[str, np.ndarray]:
        """
        Transform conformal stress tensor S̃_ij to physical S_ij
        
        S_ij = e^{4φ} S̃_ij
        """
        if self.verbose:
            print("Transforming stress tensor to ADM...")
        
        e_4phi = np.exp(4 * phi)
        
        S_physical = {}
        for key in ['xx', 'xy', 'xz', 'yy', 'yz', 'zz']:
            S_physical[key] = S_ij_conformal[key] * e_4phi
        
        return S_physical
    
    def _compute_determinant_3x3(self,
                                 gxx: np.ndarray, gxy: np.ndarray, gxz: np.ndarray,
                                 gyy: np.ndarray, gyz: np.ndarray, gzz: np.ndarray
                                 ) -> np.ndarray:
        """
        Compute determinant of 3x3 symmetric matrix
        
        det(γ) = gxx(gyy*gzz - gyz²) - gxy(gxy*gzz - gxz*gyz) + gxz(gxy*gyz - gyy*gxz)
        """
        det = (
            gxx * (gyy * gzz - gyz * gyz) -
            gxy * (gxy * gzz - gxz * gyz) +
            gxz * (gxy * gyz - gyy * gxz)
        )
        return det


class ChristoffelComputer:
    """
    Compute Christoffel symbols from metric
    
    Γ^k_{ij} = (1/2) γ^{km} (∂_i γ_mj + ∂_j γ_im - ∂_m γ_ij)
    """
    
    def __init__(self, grid_spacing: Tuple[float, float, float], verbose: bool = False):
        self.dx, self.dy, self.dz = grid_spacing
        self.verbose = verbose
    
    def compute_all(self,
                   gxx: np.ndarray, gxy: np.ndarray, gxz: np.ndarray,
                   gyy: np.ndarray, gyz: np.ndarray, gzz: np.ndarray
                   ) -> Dict[str, np.ndarray]:
        """
        Compute all 18 independent Christoffel symbols
        
        Returns:
        --------
        dict with keys like 'Gamma_x_xx', 'Gamma_x_xy', etc.
        where Gamma_k_ij means Γ^k_{ij}
        """
        if self.verbose:
            print("Computing Christoffel symbols...")
        
        # First compute metric derivatives
        d_metric = self._compute_metric_derivatives(gxx, gxy, gxz, gyy, gyz, gzz)
        
        # Invert metric
        from reference.equation36_reference import MetricInverter
        inverter = MetricInverter()
        u_xx, u_xy, u_xz, u_yy, u_yz, u_zz, det = \
            inverter.invert_3x3_symmetric(gxx, gxy, gxz, gyy, gyz, gzz)
        
        # Compute Christoffel symbols
        Gamma = {}
        
        # Γ^x_{ij} components
        for i, di in enumerate(['x', 'y', 'z']):
            for j, dj in enumerate(['x', 'y', 'z']):
                if j < i:
                    # Use symmetry Γ^k_{ij} = Γ^k_{ji}
                    Gamma[f'Gamma_x_{di}{dj}'] = Gamma[f'Gamma_x_{dj}{di}']
                else:
                    # Compute directly
                    Gamma[f'Gamma_x_{di}{dj}'] = self._compute_christoffel_component(
                        'x', i, j, 
                        u_xx, u_xy, u_xz, u_yy, u_yz, u_zz,
                        d_metric
                    )
        
        # Γ^y_{ij} components
        for i, di in enumerate(['x', 'y', 'z']):
            for j, dj in enumerate(['x', 'y', 'z']):
                if j < i:
                    Gamma[f'Gamma_y_{di}{dj}'] = Gamma[f'Gamma_y_{dj}{di}']
                else:
                    Gamma[f'Gamma_y_{di}{dj}'] = self._compute_christoffel_component(
                        'y', i, j,
                        u_xx, u_xy, u_xz, u_yy, u_yz, u_zz,
                        d_metric
                    )
        
        # Γ^z_{ij} components
        for i, di in enumerate(['x', 'y', 'z']):
            for j, dj in enumerate(['x', 'y', 'z']):
                if j < i:
                    Gamma[f'Gamma_z_{di}{dj}'] = Gamma[f'Gamma_z_{dj}{di}']
                else:
                    Gamma[f'Gamma_z_{di}{dj}'] = self._compute_christoffel_component(
                        'z', i, j,
                        u_xx, u_xy, u_xz, u_yy, u_yz, u_zz,
                        d_metric
                    )
        
        if self.verbose:
            max_gamma = max(np.max(np.abs(v)) for v in Gamma.values())
            print(f"  Max |Γ^k_{{ij}}|: {max_gamma:.6e}")
        
        return Gamma
    
    def _compute_metric_derivatives(self, gxx, gxy, gxz, gyy, gyz, gzz):
        """
        Compute ∂_k γ_ij using centered differences
        
        Returns dict with keys like 'd_gxx_dx', 'd_gxy_dy', etc.
        """
        d_metric = {}
        
        # Define helper for centered difference
        def centered_diff_x(field):
            result = np.zeros_like(field)
            result[1:-1, :, :] = (field[2:, :, :] - field[:-2, :, :]) / (2 * self.dx)
            return result
        
        def centered_diff_y(field):
            result = np.zeros_like(field)
            result[:, 1:-1, :] = (field[:, 2:, :] - field[:, :-2, :]) / (2 * self.dy)
            return result
        
        def centered_diff_z(field):
            result = np.zeros_like(field)
            result[:, :, 1:-1] = (field[:, :, 2:] - field[:, :, :-2]) / (2 * self.dz)
            return result
        
        # Compute all derivatives
        for field_name, field in [('gxx', gxx), ('gxy', gxy), ('gxz', gxz),
                                   ('gyy', gyy), ('gyz', gyz), ('gzz', gzz)]:
            d_metric[f'd_{field_name}_dx'] = centered_diff_x(field)
            d_metric[f'd_{field_name}_dy'] = centered_diff_y(field)
            d_metric[f'd_{field_name}_dz'] = centered_diff_z(field)
        
        return d_metric
    
    def _compute_christoffel_component(self, k_dir, i, j, 
                                       u_xx, u_xy, u_xz, u_yy, u_yz, u_zz,
                                       d_metric):
        """
        Compute single Christoffel component Γ^k_{ij}
        
        Γ^k_{ij} = (1/2) γ^{km} (∂_i γ_mj + ∂_j γ_im - ∂_m γ_ij)
        """
        # Map indices to metric components
        metric_names = ['gxx', 'gxy', 'gxz', 'gxy', 'gyy', 'gyz', 'gxz', 'gyz', 'gzz']
        dir_names = ['x', 'y', 'z']
        
        # Inverse metric components
        u_metric = {
            ('x', 'x'): u_xx, ('x', 'y'): u_xy, ('x', 'z'): u_xz,
            ('y', 'x'): u_xy, ('y', 'y'): u_yy, ('y', 'z'): u_yz,
            ('z', 'x'): u_xz, ('z', 'y'): u_yz, ('z', 'z'): u_zz
        }
        
        # Initialize result
        result = np.zeros_like(u_xx)
        
        # Sum over m: Γ^k_{ij} = (1/2) Σ_m γ^{km} (...)
        for m in range(3):
            m_dir = dir_names[m]
            
            # Get γ^{km}
            u_km = u_metric[(k_dir, m_dir)]
            
            # Get metric component names
            def get_metric_name(a, b):
                if a > b:
                    a, b = b, a
                return f'g{dir_names[a]}{dir_names[b]}'
            
            g_mj = get_metric_name(m, j)
            g_im = get_metric_name(i, m)
            g_ij = get_metric_name(i, j)
            
            # Get derivatives
            d_i_g_mj = d_metric[f'd_{g_mj}_d{dir_names[i]}']
            d_j_g_im = d_metric[f'd_{g_im}_d{dir_names[j]}']
            d_m_g_ij = d_metric[f'd_{g_ij}_d{m_dir}']
            
            # Add contribution
            result += 0.5 * u_km * (d_i_g_mj + d_j_g_im - d_m_g_ij)
        
        return result


if __name__ == '__main__':
    print("="*70)
    print("BSSN Transformer Test")
    print("="*70)
    
    # Create test metric (slightly perturbed flat space)
    nx, ny, nz = 32, 32, 32
    x = np.linspace(-2, 2, nx)
    y = np.linspace(-2, 2, ny)
    z = np.linspace(-2, 2, nz)
    X, Y, Z = np.meshgrid(x, y, z, indexing='ij')
    
    # Metric perturbation
    h = 0.1 * np.exp(-(X**2 + Y**2 + Z**2))
    
    gxx = 1.0 + h
    gxy = 0.0 * h
    gxz = 0.0 * h
    gyy = 1.0 + h
    gyz = 0.0 * h
    gzz = 1.0 + h
    
    print(f"\nTest metric (perturbed flat space):")
    print(f"  Grid: {nx} x {ny} x {nz}")
    print(f"  Perturbation: max h = {h.max():.6f}")
    
    # Test ADM → BSSN transformation
    print("\n" + "="*70)
    transformer = BSSNTransformer(verbose=True)
    bssn_vars = transformer.ADM_to_BSSN(gxx, gxy, gxz, gyy, gyz, gzz)
    
    # Test BSSN → ADM transformation (should recover original)
    print("\n" + "="*70)
    adm_vars = transformer.BSSN_to_ADM(
        bssn_vars['phi'],
        bssn_vars['gtxx'], bssn_vars['gtxy'], bssn_vars['gtxz'],
        bssn_vars['gtyy'], bssn_vars['gtyz'], bssn_vars['gtzz']
    )
    
    # Check round-trip accuracy
    print("\n" + "="*70)
    print("Round-trip accuracy (ADM → BSSN → ADM):")
    for key in ['gxx', 'gxy', 'gxz', 'gyy', 'gyz', 'gzz']:
        original = locals()[key]
        recovered = adm_vars[key]
        error = np.max(np.abs(original - recovered))
        print(f"  {key}: max error = {error:.6e}")
    
    # Test stress tensor transformation
    print("\n" + "="*70)
    print("Testing stress tensor transformation...")
    
    # Create dummy stress tensor
    S_physical = {
        'xx': h, 'xy': 0.1*h, 'xz': 0.1*h,
        'yy': h, 'yz': 0.1*h, 'zz': h
    }
    
    S_conformal = transformer.transform_stress_tensor_to_BSSN(
        S_physical, bssn_vars['phi']
    )
    
    S_recovered = transformer.transform_stress_tensor_to_ADM(
        S_conformal, bssn_vars['phi']
    )
    
    print("Stress tensor round-trip:")
    for key in S_physical.keys():
        error = np.max(np.abs(S_physical[key] - S_recovered[key]))
        print(f"  S_{key}: max error = {error:.6e}")
    
    print("\n✅ All transformations successful!")
    print("="*70)
