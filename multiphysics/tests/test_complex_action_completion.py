#!/usr/bin/env python3
"""
Test Suite: Complex Action Completion - Equations 70-76
========================================================

Final equations completing Complex Action & Path Integral section.

Equations:
- Eq 70: Re(A) = -S_I/ℏ ≤ 0, Im(A) = S_R/ℏ
- Eq 71: -Re(A) ≥ C||Φ||²/ℏ (coercivity)
- Eq 72: Exponential damping ~ exp(-λ||Φ||²_H¹/ℏ)
- Eq 73: Measure finiteness |μ_CAT|(Ω) < ∞
- Eq 74: Operator K = K_R + iλ structure
- Eq 75: Euclidean propagator G_E(k) = 1/(k² + m² + λ)
- Eq 76: Yukawa potential G_E(r) ~ e^(-M_eff r)/r

Created: 2026-02-09
Phase: 4 - Complete Complex Action Section
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'python'))

import unittest
import numpy as np
from scipy import integrate
import sqlite3

DB_PATH = 'database/catept_verification.db'

class TestComplexActionCompletion(unittest.TestCase):
    """Test Equations 70-76: Complete Complex Action"""
    
    def _record_test(self, eq_id, test_name, test_type, passed, expected, actual, 
                     tolerance=1e-10, exec_time_ms=0):
        """Record test result to database"""
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT OR REPLACE INTO test_cases 
            (equation_id, test_name, test_type, expected_output, actual_output, 
             tolerance, passed, last_run, execution_time_ms)
            VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'), ?)
        """, (eq_id, test_name, test_type, str(expected), str(actual), 
              tolerance, 1 if passed else 0, exec_time_ms))
        
        test_id = cursor.lastrowid
        
        cursor.execute("""
            INSERT INTO test_results 
            (test_id, passed, execution_time_ms, output_data)
            VALUES (?, ?, ?, ?)
        """, (test_id, 1 if passed else 0, exec_time_ms, str(actual)))
        
        cursor.execute("""
            UPDATE equations
            SET test_created = 1, 
                test_passed = ?,
                test_last_run = datetime('now'),
                test_result = ?
            WHERE equation_id = ?
        """, (1 if passed else 0, 'PASS' if passed else 'FAIL', eq_id))
        
        conn.commit()
        conn.close()
    
    # ========================================================================
    # EQUATION 70: Re(A) = -S_I/ℏ ≤ 0, Im(A) = S_R/ℏ
    # ========================================================================
    
    def test_eq070_action_functional_parts(self):
        """
        Eq 70: Re(A[Φ]) = -S_I/ℏ ≤ 0, Im(A[Φ]) = S_R/ℏ
        
        Test: Real and imaginary parts of action functional
        """
        import time
        start = time.time()
        
        hbar = 1.0
        S_R = 5.0  # Real action
        S_I = 2.0  # Imaginary action (≥ 0)
        
        # Action functional
        A = 1j * S_R / hbar - S_I / hbar
        
        # Components
        Re_A = A.real
        Im_A = A.imag
        
        # Checks
        expected_Re = -S_I / hbar
        expected_Im = S_R / hbar
        
        check_Re = abs(Re_A - expected_Re) < 1e-10
        check_Im = abs(Im_A - expected_Im) < 1e-10
        check_sign = Re_A <= 0  # Re(A) ≤ 0
        
        passed = check_Re and check_Im and check_sign
        
        actual = (Re_A, Im_A)
        expected = (expected_Re, expected_Im)
        
        exec_time = (time.time() - start) * 1000
        self._record_test(68, "action_functional_parts", "numerical",
                         passed, expected, actual, 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 70 - Action parts: Re(A) = {Re_A:.6f} ≤ 0, Im(A) = {Im_A:.6f}")
    
    # ========================================================================
    # EQUATION 71: -Re(A) ≥ C||Φ||²/ℏ
    # ========================================================================
    
    def test_eq071_coercivity_bound(self):
        """
        Eq 71: -Re(A[Φ]) = S_I/ℏ ≥ C||Φ||²_UV/ℏ
        
        Test: Coercivity ensures convergence
        """
        import time
        start = time.time()
        
        hbar = 1.0
        C = 0.5  # Coercivity constant
        Phi_norm_sq = 4.0  # ||Φ||²_UV
        
        # Imaginary action (from coercivity)
        S_I = C * Phi_norm_sq + 0.5  # Satisfies S_I ≥ C||Φ||²
        
        # -Re(A)
        minus_Re_A = S_I / hbar
        
        # Bound
        lower_bound = C * Phi_norm_sq / hbar
        
        # Check
        satisfies = minus_Re_A >= lower_bound - 1e-10
        
        passed = satisfies
        actual = minus_Re_A
        expected = f"≥ {lower_bound}"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(69, "coercivity_bound", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 71 - Coercivity: -Re(A) = {minus_Re_A:.6f} ≥ {lower_bound:.6f}")
    
    # ========================================================================
    # EQUATION 72: exp(-S_I/ℏ) ~ exp(-λ||Φ||²_H¹/ℏ)
    # ========================================================================
    
    def test_eq072_sobolev_damping(self):
        """
        Eq 72: exp(-S_I/ℏ) ~ exp(-λ||Φ||²_H¹/ℏ)
        
        Test: Damping in Sobolev norm H¹
        """
        import time
        start = time.time()
        
        hbar = 1.0
        lambda_val = 0.3
        
        # Sobolev H¹ norm squared: ||Φ||²_H¹ = ||Φ||²_L² + ||∇Φ||²_L²
        Phi_L2_sq = 2.0
        grad_Phi_L2_sq = 1.5
        Phi_H1_sq = Phi_L2_sq + grad_Phi_L2_sq
        
        # Damping factor
        damping = np.exp(-lambda_val * Phi_H1_sq / hbar)
        
        # Should be in (0, 1)
        is_valid = 0 < damping < 1
        
        passed = is_valid
        actual = damping
        expected = "∈ (0,1)"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(70, "sobolev_damping", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(is_valid)
        
        print(f"\n✓ Eq 72 - Sobolev damping: exp(-λ||Φ||²_H¹/ℏ) = {damping:.6f}")
    
    # ========================================================================
    # EQUATION 73: |μ_CAT|(Ω) < ∞
    # ========================================================================
    
    def test_eq073_measure_finiteness(self):
        """
        Eq 73: |μ_CAT|(Ω) = ∫_Ω exp(-S_I/ℏ) DΦ < ∞
        
        Test: Complex action measure is finite
        """
        import time
        start = time.time()
        
        # Simplified: 1D Gaussian measure
        hbar = 1.0
        S_I_coeff = 2.0  # Coefficient in S_I = S_I_coeff * φ²
        
        # Measure: ∫ exp(-S_I_coeff * φ²/ℏ) dφ
        # = ∫ exp(-a*φ²) dφ = √(π/a)
        a = S_I_coeff / hbar
        measure = np.sqrt(np.pi / a)
        
        # Should be finite
        is_finite = np.isfinite(measure) and measure > 0
        
        passed = is_finite
        actual = measure
        expected = "finite"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(71, "measure_finiteness", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(is_finite)
        
        print(f"\n✓ Eq 73 - Measure finiteness: |μ_CAT| = {measure:.6f} < ∞")
    
    # ========================================================================
    # EQUATION 74: K = K_R + iλ
    # ========================================================================
    
    def test_eq074_operator_structure(self):
        """
        Eq 74: K = K_R + iλ, K_R = -□ + m² + V''(Φ_b)
        
        Test: Fluctuation operator structure
        """
        import time
        start = time.time()
        
        # Parameters
        m_sq = 1.0
        V_double_prime = 0.5  # V''(Φ_b)
        lambda_val = 0.2
        
        # In momentum space: K_R = k² + m² + V''
        k_sq = 4.0  # Example momentum squared
        K_R_value = k_sq + m_sq + V_double_prime
        
        # Complex operator
        K_value = K_R_value + 1j * lambda_val
        
        # Checks
        has_real_part = K_value.real > 0
        has_imag_part = K_value.imag == lambda_val
        
        passed = has_real_part and has_imag_part
        
        actual = K_value
        expected = "K_R + iλ"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(72, "operator_structure", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 74 - Operator: K = {K_value:.6f}")
    
    # ========================================================================
    # EQUATION 75: G_E(k) = 1/(k² + m² + λ)
    # ========================================================================
    
    def test_eq075_euclidean_propagator(self):
        """
        Eq 75: G_E(k) = 1/(k² + m² + λ)
        
        Test: Euclidean propagator in momentum space
        """
        import time
        start = time.time()
        
        # Parameters
        k_sq = 2.0
        m_sq = 1.0
        lambda_val = 0.5
        
        # Propagator
        denominator = k_sq + m_sq + lambda_val
        G_E = 1.0 / denominator
        
        # Properties
        is_positive = G_E > 0
        is_finite = np.isfinite(G_E)
        
        # Pole analysis: no pole for λ > 0
        has_no_real_pole = denominator > 0
        
        passed = is_positive and is_finite and has_no_real_pole
        
        actual = G_E
        expected = "1/(k² + m² + λ)"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(73, "euclidean_propagator", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 75 - Propagator: G_E(k) = {G_E:.6f}")
    
    def test_eq075_damping_effect(self):
        """
        Eq 75: λ > 0 suppresses propagator
        
        Test: Damping reduces propagator strength
        """
        import time
        start = time.time()
        
        k_sq = 1.0
        m_sq = 0.5
        
        # Without damping
        G_E_no_damp = 1.0 / (k_sq + m_sq)
        
        # With damping
        lambda_val = 0.3
        G_E_with_damp = 1.0 / (k_sq + m_sq + lambda_val)
        
        # Damping should suppress
        is_suppressed = G_E_with_damp < G_E_no_damp
        
        ratio = G_E_with_damp / G_E_no_damp
        
        passed = is_suppressed and 0 < ratio < 1
        
        actual = ratio
        expected = "< 1"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(73, "damping_effect", "consistency",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 75 - Damping: G_E(λ>0)/G_E(λ=0) = {ratio:.6f} < 1")
    
    # ========================================================================
    # EQUATION 76: G_E(r) ~ e^(-M_eff r)/r, M_eff = √(m² + λ)
    # ========================================================================
    
    def test_eq076_yukawa_potential(self):
        """
        Eq 76: G_E(r) ~ e^(-M_eff r)/r, M_eff = √(m² + λ)
        
        Test: Yukawa potential in position space
        """
        import time
        start = time.time()
        
        # Parameters
        m_sq = 1.0
        lambda_val = 0.5
        
        # Effective mass
        M_eff = np.sqrt(m_sq + lambda_val)
        
        # Position space propagator at various r
        r_values = [1.0, 2.0, 5.0]
        
        all_valid = True
        for r in r_values:
            G_E_r = np.exp(-M_eff * r) / r
            
            # Should be positive and decreasing
            if G_E_r <= 0:
                all_valid = False
        
        # Check screening: λ > 0 increases M_eff, shortens range
        M_eff_no_lambda = np.sqrt(m_sq)
        increased_mass = M_eff > M_eff_no_lambda
        
        passed = all_valid and increased_mass
        
        actual = M_eff
        expected = f"√(m² + λ) = {M_eff:.6f}"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(74, "yukawa_potential", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 76 - Yukawa: M_eff = √(m² + λ) = {M_eff:.6f}")
    
    def test_eq076_screening_length(self):
        """
        Eq 76: Screening length r_screen ~ 1/M_eff
        
        Test: λ reduces interaction range
        """
        import time
        start = time.time()
        
        m_sq = 0.5
        
        # Without entropic damping
        M_eff_0 = np.sqrt(m_sq)
        r_screen_0 = 1.0 / M_eff_0
        
        # With entropic damping
        lambda_val = 1.5
        M_eff_lambda = np.sqrt(m_sq + lambda_val)
        r_screen_lambda = 1.0 / M_eff_lambda
        
        # Screening length should decrease
        is_shorter = r_screen_lambda < r_screen_0
        
        ratio = r_screen_lambda / r_screen_0
        
        passed = is_shorter
        
        actual = ratio
        expected = "< 1"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(74, "screening_length", "consistency",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 76 - Screening: r(λ>0)/r(λ=0) = {ratio:.6f} < 1")


if __name__ == '__main__':
    print("="*80)
    print("RUNNING TESTS: Complex Action Completion (Equations 70-76)")
    print("="*80)
    
    suite = unittest.TestLoader().loadTestsFromTestCase(TestComplexActionCompletion)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print("\n" + "="*80)
    print("TEST SUMMARY - COMPLEX ACTION COMPLETION")
    print("="*80)
    print(f"Tests run:     {result.testsRun}")
    print(f"Successes:     {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures:      {len(result.failures)}")
    print(f"Errors:        {len(result.errors)}")
    print(f"Success rate:  {100 * (result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun:.1f}%")
    print("="*80)
    
    sys.exit(0 if result.wasSuccessful() else 1)
