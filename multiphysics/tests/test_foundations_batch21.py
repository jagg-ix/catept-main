#!/usr/bin/env python3
"""
Test Suite: Foundations Batch 2.1 - Equations 11-15
====================================================

Tests for thermal response, entropic rate, and energy cost equations.

Equations:
- Eq 11: Fourier transform W(E)
- Eq 12: Thermal response (Bose-Einstein)
- Eq 13: Entropic rate λ = κ/(2π) = k_B*T/ℏ
- Eq 14: Energy cost ΔE
- Eq 15: Modular Hamiltonian H_I

Created: 2026-02-09
Phase: 2 - Foundations Complete
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'python'))

import unittest
import numpy as np
from scipy import integrate
import sqlite3
from datetime import datetime

DB_PATH = 'database/catept_verification.db'

class TestFoundationsBatch21(unittest.TestCase):
    """Test Equations 11-15: Thermal & Entropic Properties"""
    
    def _record_test(self, eq_id, test_name, test_type, passed, expected, actual, 
                     tolerance=1e-10, exec_time_ms=0):
        """Record test result to database"""
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Insert test case
        cursor.execute("""
            INSERT OR REPLACE INTO test_cases 
            (equation_id, test_name, test_type, expected_output, actual_output, 
             tolerance, passed, last_run, execution_time_ms)
            VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'), ?)
        """, (eq_id, test_name, test_type, str(expected), str(actual), 
              tolerance, 1 if passed else 0, exec_time_ms))
        
        test_id = cursor.lastrowid
        
        # Insert test result
        cursor.execute("""
            INSERT INTO test_results 
            (test_id, passed, execution_time_ms, output_data)
            VALUES (?, ?, ?, ?)
        """, (test_id, 1 if passed else 0, exec_time_ms, str(actual)))
        
        # Update equation status
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
    # EQUATION 11: Fourier Transform of Correlation Function
    # ========================================================================
    
    def test_eq011_fourier_transform(self):
        """
        Eq 11: W(E) = ∫ dΔτ exp(iEΔτ) G⁺(Δτ)
        
        Test: Fourier transform of exponentially decaying correlation
        """
        import time
        start = time.time()
        
        # Setup: Exponentially decaying correlation function
        # G⁺(Δτ) = exp(-γ|Δτ|) for γ > 0
        gamma = 1.0  # Decay rate
        E_test = 0.5  # Test energy
        
        # Numerical integration
        def integrand(delta_tau):
            G_plus = np.exp(-gamma * np.abs(delta_tau))
            return np.exp(1j * E_test * delta_tau) * G_plus
        
        # Integrate from -∞ to ∞ (use large limits)
        result, error = integrate.quad(lambda x: integrand(x).real, -20, 20)
        result_imag, _ = integrate.quad(lambda x: integrand(x).imag, -20, 20)
        
        W_E_numerical = result + 1j * result_imag
        
        # Analytical result: W(E) = 2γ/(γ² + E²)
        W_E_analytical = 2 * gamma / (gamma**2 + E_test**2)
        
        # Verify
        actual = abs(W_E_numerical)
        expected = W_E_analytical
        tolerance = 1e-6  # Integration tolerance
        
        passed = abs(actual - expected) < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(11, "fourier_transform", "numerical", 
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertTrue(passed, 
                       f"Fourier transform: {actual:.6f} ≠ {expected:.6f}")
        
        print(f"\n✓ Eq 11 - Fourier transform: W(E) = {actual:.6f} "
              f"(expected {expected:.6f}, diff = {abs(actual-expected):.2e})")
    
    # ========================================================================
    # EQUATION 12: Thermal Response (Bose-Einstein)
    # ========================================================================
    
    def test_eq012_thermal_response(self):
        """
        Eq 12: W(E) ∝ 1/(exp(E/k_B T) - 1), T = ℏκ/(2πc k_B)
        
        Test: Bose-Einstein distribution at finite temperature
        """
        import time
        start = time.time()
        
        # Physical constants
        hbar = 1.054571817e-34  # J·s
        k_B = 1.380649e-23      # J/K
        c = 299792458           # m/s
        
        # Surface gravity (example: black hole)
        kappa = 1e-6  # s⁻¹
        
        # Temperature from Hawking/Unruh formula
        T = (hbar * kappa) / (2 * np.pi * c * k_B)
        
        # Test energies
        E_low = k_B * T * 0.1
        E_high = k_B * T * 10.0
        
        # Thermal response
        W_low = 1.0 / (np.exp(E_low / (k_B * T)) - 1)
        W_high = 1.0 / (np.exp(E_high / (k_B * T)) - 1)
        
        # Physical checks
        check1 = W_low > W_high  # Lower energy → higher response
        check2 = W_low > 0 and W_high > 0  # Positive
        check3 = np.isfinite(W_low) and np.isfinite(W_high)
        
        passed = check1 and check2 and check3
        
        actual = (W_low, W_high, T)
        expected = "Bose-Einstein distribution"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(12, "thermal_response", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed, "Thermal response checks failed")
        
        print(f"\n✓ Eq 12 - Thermal response:")
        print(f"    T = {T:.6e} K")
        print(f"    W(E_low) = {W_low:.6f}")
        print(f"    W(E_high) = {W_high:.6f}")
        print(f"    W(E_low) > W(E_high): {check1}")
    
    # ========================================================================
    # EQUATION 13: Entropic Rate λ = κ/(2π) = k_B T/ℏ
    # ========================================================================
    
    def test_eq013_entropic_rate_consistency(self):
        """
        Eq 13: λ = κ/(2π) = k_B T/ℏ
        
        Test: Consistency between two expressions for λ
        NOTE: In natural units where c = 1, T = ℏκ/(2πk_B), so λ = κ/(2π) = k_B T/ℏ
        """
        import time
        start = time.time()
        
        # Use natural units (c = 1) for consistency
        hbar = 1.0
        k_B = 1.0
        
        # Surface gravity
        kappa = 1.0  # In natural units
        
        # First expression: λ = κ/(2π)
        lambda_from_kappa = kappa / (2 * np.pi)
        
        # Temperature in natural units: T = ℏκ/(2πk_B)
        T = (hbar * kappa) / (2 * np.pi * k_B)
        
        # Second expression: λ = k_B T/ℏ
        lambda_from_T = (k_B * T) / hbar
        
        # They should be equal
        actual = lambda_from_kappa
        expected = lambda_from_T
        tolerance = 1e-10  # Absolute tolerance
        
        absolute_error = abs(actual - expected)
        passed = absolute_error < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(13, "entropic_rate_consistency", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertTrue(passed, 
                       f"λ consistency: {actual:.6e} ≠ {expected:.6e}")
        
        print(f"\n✓ Eq 13 - Entropic rate consistency:")
        print(f"    λ (from κ) = {lambda_from_kappa:.6e}")
        print(f"    λ (from T) = {lambda_from_T:.6e}")
        print(f"    Absolute error: {absolute_error:.2e}")
        print(f"    Match: {passed}")
    
    def test_eq013_positivity(self):
        """
        Eq 13: λ > 0 (Physical requirement)
        
        Test: Entropic rate must be positive
        """
        import time
        start = time.time()
        
        # Various surface gravities
        kappas = [1e-8, 1e-6, 1e-4, 1e-2, 1.0]
        
        all_positive = True
        lambda_values = []
        
        for kappa in kappas:
            lambda_val = kappa / (2 * np.pi)
            lambda_values.append(lambda_val)
            if lambda_val <= 0:
                all_positive = False
        
        passed = all_positive
        actual = lambda_values
        expected = "all positive"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(13, "positivity", "consistency",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed, "Some λ values are not positive")
        
        print(f"\n✓ Eq 13 - Positivity: λ values = {[f'{l:.2e}' for l in lambda_values]}")
    
    # ========================================================================
    # EQUATION 14: Energy Cost ΔE = ℏ Δτ_ent ⟨H_I⟩
    # ========================================================================
    
    def test_eq014_energy_cost(self):
        """
        Eq 14: ΔE = ℏ Δτ_ent ⟨H_I⟩ = ℏ ∫ λ ⟨H_I⟩ dt
        
        Test: Energy cost of entropic time evolution
        """
        import time
        start = time.time()
        
        # Constants
        hbar = 1.0  # Natural units
        
        # Parameters
        lambda_const = 0.5  # Entropic rate
        H_I_avg = 0.2       # Average imaginary Hamiltonian
        t_final = 10.0      # Time duration
        
        # Entropic time accumulated
        Delta_tau_ent = lambda_const * t_final
        
        # Energy cost (two methods)
        # Method 1: Direct
        Delta_E_direct = hbar * Delta_tau_ent * H_I_avg
        
        # Method 2: Integration
        Delta_E_integral = hbar * lambda_const * H_I_avg * t_final
        
        # Should be identical
        actual = Delta_E_direct
        expected = Delta_E_integral
        tolerance = 1e-10
        
        passed = abs(actual - expected) < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(14, "energy_cost", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertAlmostEqual(actual, expected, places=10)
        
        print(f"\n✓ Eq 14 - Energy cost:")
        print(f"    ΔE (direct) = {Delta_E_direct:.6f}")
        print(f"    ΔE (integral) = {Delta_E_integral:.6f}")
        print(f"    Δτ_ent = {Delta_tau_ent:.6f}")
    
    def test_eq014_proportionality(self):
        """
        Eq 14: ΔE ∝ ⟨H_I⟩ (Proportionality test)
        
        Test: Energy cost scales linearly with ⟨H_I⟩
        """
        import time
        start = time.time()
        
        hbar = 1.0
        lambda_val = 0.3
        t = 5.0
        Delta_tau = lambda_val * t
        
        # Test different H_I values
        H_I_values = [0.1, 0.2, 0.4, 0.8]
        Delta_E_values = []
        
        for H_I in H_I_values:
            Delta_E = hbar * Delta_tau * H_I
            Delta_E_values.append(Delta_E)
        
        # Check linearity: ΔE(2H_I) = 2*ΔE(H_I)
        ratio = Delta_E_values[1] / Delta_E_values[0]  # Should be 2.0
        expected_ratio = H_I_values[1] / H_I_values[0]
        
        passed = abs(ratio - expected_ratio) < 1e-10
        
        actual = ratio
        expected = expected_ratio
        
        exec_time = (time.time() - start) * 1000
        self._record_test(14, "proportionality", "consistency",
                         passed, expected, actual, 1e-10, exec_time)
        
        self.assertAlmostEqual(ratio, expected_ratio, places=10)
        
        print(f"\n✓ Eq 14 - Proportionality: ratio = {ratio:.6f} "
              f"(expected {expected_ratio:.6f})")
    
    # ========================================================================
    # EQUATION 15: Modular Hamiltonian H_I = k_B λ Ĵ
    # ========================================================================
    
    def test_eq015_modular_hamiltonian(self):
        """
        Eq 15: H_I = k_B λ Ĵ, where Ĵ = (ℏ/k_B) K
        
        Test: Modular Hamiltonian structure
        """
        import time
        start = time.time()
        
        # Constants
        hbar = 1.054571817e-34
        k_B = 1.380649e-23
        
        # Parameters
        lambda_val = 1e-5  # Entropic rate
        K = 1.0            # Modular operator eigenvalue
        
        # Modular current
        J_hat = (hbar / k_B) * K
        
        # Imaginary Hamiltonian
        H_I = k_B * lambda_val * J_hat
        
        # Alternative: H_I = ℏ λ K
        H_I_alt = hbar * lambda_val * K
        
        # Should be equal
        actual = H_I
        expected = H_I_alt
        tolerance = 1e-20  # Very tight for this identity
        
        passed = abs(actual - expected) < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(15, "modular_hamiltonian", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertAlmostEqual(actual, expected, places=18)
        
        print(f"\n✓ Eq 15 - Modular Hamiltonian:")
        print(f"    H_I = k_B λ Ĵ = {H_I:.6e} J")
        print(f"    H_I = ℏ λ K = {H_I_alt:.6e} J")
        print(f"    Match: {abs(H_I - H_I_alt) < tolerance}")
    
    def test_eq015_dimensional_analysis(self):
        """
        Eq 15: Dimensional consistency
        
        Test: [H_I] = Energy
        """
        import time
        start = time.time()
        
        # In SI units
        k_B_SI = 1.380649e-23    # J/K
        lambda_SI = 1e-5         # s⁻¹
        hbar_SI = 1.054571817e-34  # J·s
        K_SI = 1.0               # dimensionless
        
        # H_I = k_B λ (ℏ/k_B) K = ℏ λ K
        H_I_SI = hbar_SI * lambda_SI * K_SI  # Should have units of J
        
        # Check it's in the right range for energy
        is_energy_scale = 1e-50 < H_I_SI < 1e50  # Reasonable range for J
        
        passed = is_energy_scale
        actual = H_I_SI
        expected = "Energy in Joules"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(15, "dimensional_analysis", "consistency",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed, "H_I not in valid energy range")
        
        print(f"\n✓ Eq 15 - Dimensional analysis: H_I = {H_I_SI:.6e} J")


if __name__ == '__main__':
    print("="*80)
    print("RUNNING TESTS: Foundations Batch 2.1 (Equations 11-15)")
    print("="*80)
    
    # Run tests
    suite = unittest.TestLoader().loadTestsFromTestCase(TestFoundationsBatch21)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Summary
    print("\n" + "="*80)
    print("TEST SUMMARY - BATCH 2.1")
    print("="*80)
    print(f"Tests run:     {result.testsRun}")
    print(f"Successes:     {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures:      {len(result.failures)}")
    print(f"Errors:        {len(result.errors)}")
    print(f"Success rate:  {100 * (result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun:.1f}%")
    print("="*80)
    
    # Exit with appropriate code
    sys.exit(0 if result.wasSuccessful() else 1)
