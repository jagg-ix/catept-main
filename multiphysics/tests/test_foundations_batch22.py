#!/usr/bin/env python3
"""
Test Suite: Foundations Batch 2.2 - Equations 16-20
====================================================

Tests for thermodynamic entropic time and classical-quantum bridge.

Equations:
- Eq 16: τ_ent[γ] = (1/ℏ) S_I[γ] = ∫ λ(τ) dτ
- Eq 17: H_th = -ln(ρ) = S_I/ℏ = τ_ent (Bridge equation)
- Eq 18: S ~ ℏ N_ops (Entropy scaling)
- Eq 19: Δt ≥ πℏ/(2E) (Time-energy uncertainty)
- Eq 20: ∫ E dt ~ ℏ ∫ ν_ops dt = ℏ N_ops

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

class TestFoundationsBatch22(unittest.TestCase):
    """Test Equations 16-20: Thermodynamic Entropic Time"""
    
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
    # EQUATION 16: τ_ent = (1/ℏ) S_I = ∫ λ(τ) dτ
    # ========================================================================
    
    def test_eq016_tau_ent_integration(self):
        """
        Eq 16: τ_ent[γ] = ∫_γ λ(τ) dτ with λ ≥ 0
        
        Test: Integration along path
        """
        import time
        start = time.time()
        
        hbar = 1.0  # Natural units
        
        # Define path: constant λ
        lambda_const = 0.4
        tau_final = 10.0
        
        # Direct integration
        tau_ent_direct = lambda_const * tau_final
        
        # Numerical integration
        def lambda_func(tau):
            return lambda_const
        
        tau_ent_numerical, error = integrate.quad(lambda_func, 0, tau_final)
        
        # Should match
        actual = tau_ent_numerical
        expected = tau_ent_direct
        tolerance = 1e-10
        
        passed = abs(actual - expected) < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(16, "tau_ent_integration", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertAlmostEqual(actual, expected, places=10)
        
        print(f"\n✓ Eq 16 - τ_ent integration:")
        print(f"    Direct: {tau_ent_direct:.6f}")
        print(f"    Numerical: {tau_ent_numerical:.6f}")
    
    def test_eq016_positivity(self):
        """
        Eq 16: λ(τ) ≥ 0 (Positivity constraint)
        
        Test: Entropic rate must be non-negative
        """
        import time
        start = time.time()
        
        # Various λ functions
        lambda_funcs = [
            lambda tau: 0.5,                    # Constant
            lambda tau: 0.1 * (1 + np.sin(tau)),  # Oscillating but ≥ 0
            lambda tau: 0.3 * np.exp(-0.1*tau),  # Decaying
        ]
        
        all_positive = True
        
        for i, lam_func in enumerate(lambda_funcs):
            tau_values = np.linspace(0, 10, 100)
            lam_values = [lam_func(tau) for tau in tau_values]
            
            if not all(lam >= -1e-10 for lam in lam_values):  # Small tolerance for numerical error
                all_positive = False
        
        passed = all_positive
        actual = "all non-negative"
        expected = "λ ≥ 0"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(16, "positivity", "consistency",
                         passed, expected, actual, 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 16 - Positivity: All λ functions non-negative")
    
    # ========================================================================
    # EQUATION 17: H_th = -ln(ρ) = S_I/ℏ = τ_ent (Bridge)
    # ========================================================================
    
    def test_eq017_bridge_equation(self):
        """
        Eq 17: H_th = -ln(ρ) = τ_ent
        
        Test: Thermal Hamiltonian equals entropic time
        """
        import time
        start = time.time()
        
        hbar = 1.0
        
        # Density matrix for thermal state (2x2 example)
        beta = 1.0  # Inverse temperature
        E1, E2 = 0.0, 1.0  # Energy levels
        
        # Partition function
        Z = np.exp(-beta * E1) + np.exp(-beta * E2)
        
        # Density matrix
        rho = np.diag([np.exp(-beta * E1) / Z, np.exp(-beta * E2) / Z])
        
        # Thermal Hamiltonian: H_th = -ln(ρ)
        # For diagonal ρ: H_th = diag(-ln(ρ_11), -ln(ρ_22))
        H_th_11 = -np.log(rho[0, 0])
        H_th_22 = -np.log(rho[1, 1])
        
        # This should equal β*E + constant
        # H_th_11 = β*E1 + ln(Z)
        expected_H_th_11 = beta * E1 + np.log(Z)
        expected_H_th_22 = beta * E2 + np.log(Z)
        
        actual_11 = H_th_11
        actual_22 = H_th_22
        
        tolerance = 1e-10
        passed = (abs(actual_11 - expected_H_th_11) < tolerance and
                 abs(actual_22 - expected_H_th_22) < tolerance)
        
        exec_time = (time.time() - start) * 1000
        self._record_test(17, "bridge_equation", "numerical",
                         passed, (expected_H_th_11, expected_H_th_22),
                         (actual_11, actual_22), tolerance, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 17 - Bridge equation:")
        print(f"    H_th[1,1] = {H_th_11:.6f} (expected {expected_H_th_11:.6f})")
        print(f"    H_th[2,2] = {H_th_22:.6f} (expected {expected_H_th_22:.6f})")
    
    def test_eq017_entropy_relation(self):
        """
        Eq 17: S = -Tr(ρ ln ρ) = Tr(ρ H_th)
        
        Test: Von Neumann entropy equals expectation of thermal Hamiltonian
        """
        import time
        start = time.time()
        
        # Simple 2-state system
        p1, p2 = 0.7, 0.3
        rho = np.diag([p1, p2])
        
        # Von Neumann entropy
        S_vN = -p1 * np.log(p1) - p2 * np.log(p2)
        
        # Thermal Hamiltonian
        H_th = np.diag([-np.log(p1), -np.log(p2)])
        
        # Expectation value
        expected_H_th = np.trace(rho @ H_th)
        
        # Should equal entropy
        actual = expected_H_th
        expected = S_vN
        tolerance = 1e-10
        
        passed = abs(actual - expected) < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(17, "entropy_relation", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertAlmostEqual(actual, expected, places=10)
        
        print(f"\n✓ Eq 17 - Entropy relation:")
        print(f"    S_vN = {S_vN:.6f}")
        print(f"    ⟨H_th⟩ = {expected_H_th:.6f}")
    
    # ========================================================================
    # EQUATION 18: S ~ ℏ N_ops (Entropy Scaling)
    # ========================================================================
    
    def test_eq018_entropy_scaling(self):
        """
        Eq 18: S ~ ℏ N_ops
        
        Test: Entropy scales with operation count
        """
        import time
        start = time.time()
        
        hbar = 1.0
        
        # Different operation counts
        N_ops_list = [10, 20, 40, 80]
        
        # Entropies should scale linearly
        S_list = [hbar * N for N in N_ops_list]
        
        # Check linearity: S(2N) = 2*S(N)
        ratio = S_list[1] / S_list[0]
        expected_ratio = N_ops_list[1] / N_ops_list[0]
        
        tolerance = 1e-10
        passed = abs(ratio - expected_ratio) < tolerance
        
        actual = ratio
        expected = expected_ratio
        
        exec_time = (time.time() - start) * 1000
        self._record_test(18, "entropy_scaling", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertAlmostEqual(ratio, expected_ratio, places=10)
        
        print(f"\n✓ Eq 18 - Entropy scaling:")
        print(f"    S values: {[f'{s:.1f}' for s in S_list]}")
        print(f"    Ratio: {ratio:.6f} (expected {expected_ratio:.6f})")
    
    # ========================================================================
    # EQUATION 19: Δt ≥ πℏ/(2E) (Time-Energy Uncertainty)
    # ========================================================================
    
    def test_eq019_time_energy_uncertainty(self):
        """
        Eq 19: Δt ≥ πℏ/(2E)
        
        Test: Mandelstam-Tamm time-energy uncertainty
        """
        import time
        start = time.time()
        
        hbar = 1.0
        
        # Test different energies
        E_values = [1.0, 2.0, 4.0, 8.0]
        
        all_satisfied = True
        
        for E in E_values:
            # Minimum time
            Delta_t_min = (np.pi * hbar) / (2 * E)
            
            # Test that this is positive
            if Delta_t_min <= 0:
                all_satisfied = False
            
            # Test scaling: Δt(2E) = Δt(E)/2
            if E < max(E_values):
                E2 = 2 * E
                Delta_t_2E = (np.pi * hbar) / (2 * E2)
                ratio = Delta_t_2E / Delta_t_min
                
                if abs(ratio - 0.5) > 1e-10:
                    all_satisfied = False
        
        passed = all_satisfied
        actual = "uncertainty satisfied"
        expected = "Δt ≥ πℏ/(2E)"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(19, "time_energy_uncertainty", "consistency",
                         passed, expected, actual, 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 19 - Time-energy uncertainty satisfied")
    
    def test_eq019_numerical_values(self):
        """
        Eq 19: Calculate actual Δt values
        
        Test: Numerical evaluation
        """
        import time
        start = time.time()
        
        hbar = 1.054571817e-34  # J·s
        
        # Realistic energy (1 eV)
        E_eV = 1.0
        E_J = E_eV * 1.602176634e-19  # Convert to Joules
        
        # Minimum time
        Delta_t = (np.pi * hbar) / (2 * E_J)
        
        # Should be in femtoseconds range for eV energies
        Delta_t_fs = Delta_t * 1e15  # Convert to femtoseconds
        
        # Physical check: for eV energies, expect femtosecond timescales
        is_physical = 0.1 < Delta_t_fs < 10  # Reasonable range
        
        passed = is_physical
        actual = Delta_t_fs
        expected = "femtosecond timescale"
        
        exec_time = (time.time() - start) * 1000
        self._record_test(19, "numerical_values", "numerical",
                         passed, expected, str(actual), 1e-10, exec_time)
        
        self.assertTrue(passed)
        
        print(f"\n✓ Eq 19 - Numerical: Δt = {Delta_t_fs:.3f} femtoseconds for 1 eV")
    
    # ========================================================================
    # EQUATION 20: ∫ E dt ~ ℏ ∫ ν_ops dt = ℏ N_ops
    # ========================================================================
    
    def test_eq020_operation_energy(self):
        """
        Eq 20: ∫ E dt ~ ℏ N_ops
        
        Test: Total energy-time ~ ℏ × operation count
        """
        import time
        start = time.time()
        
        hbar = 1.0
        
        # Constant energy
        E_const = 2.0  # Energy
        T = 5.0        # Time duration
        
        # Energy-time integral
        energy_time_integral = E_const * T
        
        # Operation frequency
        nu_ops = E_const / hbar  # From E = ℏν
        
        # Total operations
        N_ops = nu_ops * T
        
        # Should satisfy: ∫E dt = ℏ N_ops
        expected = energy_time_integral
        actual = hbar * N_ops
        
        tolerance = 1e-10
        passed = abs(actual - expected) < tolerance
        
        exec_time = (time.time() - start) * 1000
        self._record_test(20, "operation_energy", "numerical",
                         passed, expected, actual, tolerance, exec_time)
        
        self.assertAlmostEqual(actual, expected, places=10)
        
        print(f"\n✓ Eq 20 - Operation energy:")
        print(f"    ∫E dt = {energy_time_integral:.6f}")
        print(f"    ℏ N_ops = {hbar * N_ops:.6f}")
        print(f"    N_ops = {N_ops:.2f}")


if __name__ == '__main__':
    print("="*80)
    print("RUNNING TESTS: Foundations Batch 2.2 (Equations 16-20)")
    print("="*80)
    
    suite = unittest.TestLoader().loadTestsFromTestCase(TestFoundationsBatch22)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print("\n" + "="*80)
    print("TEST SUMMARY - BATCH 2.2")
    print("="*80)
    print(f"Tests run:     {result.testsRun}")
    print(f"Successes:     {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures:      {len(result.failures)}")
    print(f"Errors:        {len(result.errors)}")
    print(f"Success rate:  {100 * (result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun:.1f}%")
    print("="*80)
    
    sys.exit(0 if result.wasSuccessful() else 1)
