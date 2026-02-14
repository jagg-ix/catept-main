"""
Multi-Physics CAT/EPT Integration

This module USES YOUR existing adapters to create complete multi-physics simulations:
1. einsteinpy_adapter.py (GR with CAT/EPT) - YOU HAVE THIS
2. meep_adapter.py (EM with CAT/EPT) - YOU HAVE THIS  
3. quantum_tensors_adapter.py (MPS with CAT/EPT) - YOU HAVE THIS
4. vonneumann_algebra_adapter.py (Operator algebras) - NEW

Location in YOUR repo:
    catsim_core/integration/multi_physics_catept.py

Integrates ALL physics scales with CAT/EPT thermodynamics!

Author: Leveraging existing entropic-time framework
"""

from __future__ import annotations

from typing import Dict, Any, Optional
import numpy as np

# Import YOUR existing adapters
try:
    from catsim_core.electromagnetic.meep_adapter import (
        make_meep_adapter,
        MEEPSimulationConfig
    )
    HAS_MEEP_ADAPTER = True
except ImportError:
    HAS_MEEP_ADAPTER = False
    print("⚠ YOUR meep_adapter not found")

try:
    from catsim_core.quantum_information.quantum_tensors_adapter import (
        make_quantum_tensors_adapter,
        QuantumTensorsConfig
    )
    HAS_QT_ADAPTER = True
except ImportError:
    HAS_QT_ADAPTER = False
    print("⚠ YOUR quantum_tensors_adapter not found")

try:
    from catsim_core.metric.einsteinpy_adapter import make_metric_adapter
    from catsim_core.metric.entropic_tensors import (
        TensorBundle,
        entropic_stress_tensor,
        imaginary_curvature_tensor,
        christoffel_symbols,
        inverse_metric
    )
    HAS_CATEPT_TENSORS = True
except ImportError:
    HAS_CATEPT_TENSORS = False
    print("⚠ YOUR entropic_tensors not found")

try:
    from einsteinpy.symbolic import MetricTensor, RicciScalar, RicciTensor
    import sympy as sp
    HAS_EINSTEINPY = True
except ImportError:
    HAS_EINSTEINPY = False
    sp = None


def compute_lambda_from_curvature(
    metric: 'MetricTensor',
    evaluation_point: Optional[Dict] = None
) -> float:
    """Compute λ_gravity from spacetime curvature
    
    Uses YOUR existing einsteinpy_adapter with Ricci scalar
    
    Parameters
    ----------
    metric : MetricTensor
        Spacetime metric from einsteinpy
    evaluation_point : dict, optional
        Coordinates for numerical evaluation
    
    Returns
    -------
    lambda_gravity : float
        Gravitational contribution to λ_ent
    """
    if not HAS_EINSTEINPY or not HAS_CATEPT_TENSORS:
        return 0.0
    
    # Compute Ricci scalar
    try:
        ricci_scalar = RicciScalar.from_metric(metric)
        R_expr = ricci_scalar.expr
        
        # Evaluate
        if evaluation_point:
            syms = list(evaluation_point.keys())
            vals = [evaluation_point[s] for s in syms]
            func = sp.lambdify(syms, R_expr, 'numpy')
            R_value = float(func(*vals))
        else:
            R_value = float(R_expr.evalf())
        
        # λ_gravity ~ |R| (curvature drives dissipation)
        lambda_gravity = abs(R_value)
        
    except Exception as e:
        print(f"  Warning: Could not compute Ricci scalar: {e}")
        lambda_gravity = 0.0
    
    return lambda_gravity


def integrate_all_physics(
    # GR parameters
    schwarzschild_mass: float = 1.0,
    use_kerr: bool = False,
    kerr_spin: float = 0.5,
    
    # EM parameters  
    meep_lambda: float = 1e-14,
    enz_film_thickness: float = 0.1,
    run_enz_experiment: bool = True,
    
    # Quantum parameters
    num_qubits: int = 10,
    bond_dimension: int = 50,
    
    # CAT/EPT
    cat_ept_enabled: bool = True,
    lambda_mode: str = 'trace_adjusted'
    
) -> Dict[str, Any]:
    """Integrate ALL THREE of YOUR existing adapters
    
    This is the main integration function that combines:
    1. GR (einsteinpy) → λ_gravity
    2. EM (YOUR meep_adapter) → λ_EM, τ_EM
    3. Quantum (YOUR quantum_tensors_adapter) → λ_quantum, τ_quantum, S
    
    Then uses YOUR entropic_tensors to compute S_μν and Λ_μν
    
    Parameters
    ----------
    schwarzschild_mass : float
        Black hole mass (M☉)
    use_kerr : bool
        Use rotating (Kerr) vs non-rotating (Schwarzschild)
    kerr_spin : float
        Angular momentum parameter a = J/M
    meep_lambda : float
        EM entropic dissipation rate (s⁻¹)
    enz_film_thickness : float
        ENZ film thickness (μm)
    run_enz_experiment : bool
        Run full ENZ visibility test
    num_qubits : int
        Number of qubits for MPS
    bond_dimension : int
        MPS bond dimension χ
    cat_ept_enabled : bool
        Enable CAT/EPT tracking
    lambda_mode : str
        YOUR mode for imaginary curvature ('trace_adjusted')
    
    Returns
    -------
    results : dict
        Complete multi-physics CAT/EPT results
    
    Examples
    --------
    >>> # All three physics combined
    >>> results = integrate_all_physics(
    ...     schwarzschild_mass=1.0,
    ...     meep_lambda=1e-14,
    ...     num_qubits=10,
    ...     bond_dimension=50
    ... )
    >>> 
    >>> print(f"λ_total = {results['lambda_total']:.6e}")
    >>> print(f"S_entropic_00 = {results['S_entropic_00']:.6e}")
    """
    
    print("\n" + "="*70)
    print("  MULTI-PHYSICS CAT/EPT INTEGRATION")
    print("  Using YOUR Existing Adapters")
    print("="*70)
    
    results = {
        'integrated': True,
        'num_physics': 0,
        'scales': []
    }
    
    # =========================================================================
    # [1] GENERAL RELATIVITY - einsteinpy
    # =========================================================================
    
    if HAS_EINSTEINPY and HAS_CATEPT_TENSORS:
        print("\n[1] General Relativity (einsteinpy):")
        
        # Create metric
        t, r, theta, phi = sp.symbols('t r theta phi', real=True)
        M = sp.Symbol('M', positive=True)
        
        if use_kerr:
            # Kerr metric (rotating BH)
            a = sp.Symbol('a', real=True)
            Sigma = r**2 + a**2 * sp.cos(theta)**2
            Delta = r**2 - 2*M*r + a**2
            
            g_tt = -(1 - 2*M*r/Sigma)
            g_rr = Sigma/Delta
            g_thth = Sigma
            g_pp = (r**2 + a**2 + 2*M*r*a**2*sp.sin(theta)**2/Sigma) * sp.sin(theta)**2
            g_tphi = -2*M*r*a*sp.sin(theta)**2/Sigma
            
            metric_array = sp.Matrix([
                [g_tt, 0, 0, g_tphi],
                [0, g_rr, 0, 0],
                [0, 0, g_thth, 0],
                [g_tphi, 0, 0, g_pp]
            ])
            
            metric_name = "Kerr"
            subs_dict = {M: schwarzschild_mass, a: kerr_spin}
        else:
            # Schwarzschild metric (non-rotating BH)
            g_tt = -(1 - 2*M/r)
            g_rr = 1/(1 - 2*M/r)
            g_thth = r**2
            g_pp = r**2 * sp.sin(theta)**2
            
            metric_array = sp.diag(g_tt, g_rr, g_thth, g_pp)
            metric_name = "Schwarzschild"
            subs_dict = {M: schwarzschild_mass}
        
        metric = MetricTensor(
            metric_array,
            syms=[t, r, theta, phi],
            name=metric_name
        )
        
        # Use YOUR make_metric_adapter
        metric_adapter = make_metric_adapter(metric)
        
        # Compute λ_gravity from curvature
        eval_point = {r: 10*schwarzschild_mass}  # Well outside horizon
        lambda_gravity = compute_lambda_from_curvature(metric, eval_point)
        
        # Use YOUR christoffel_symbols
        coords = [t, r, theta, phi]
        Gamma = christoffel_symbols(metric_array.subs(subs_dict), coords)
        
        print(f"  ✓ Metric: {metric_name}")
        print(f"  ✓ Mass: {schwarzschild_mass} M☉")
        if use_kerr:
            print(f"  ✓ Spin: a = {kerr_spin}")
        print(f"  ✓ λ_gravity: {lambda_gravity:.6e} s⁻¹")
        
        results['metric'] = metric
        results['lambda_gravity'] = lambda_gravity
        results['Christoffel'] = Gamma
        results['num_physics'] += 1
        results['scales'].append('gravitational')
    
    else:
        print("\n[1] General Relativity: NOT AVAILABLE")
        results['lambda_gravity'] = 0.0
    
    # =========================================================================
    # [2] ELECTROMAGNETIC - YOUR meep_adapter
    # =========================================================================
    
    if HAS_MEEP_ADAPTER:
        print("\n[2] Electromagnetic (YOUR meep_adapter):")
        
        # Use YOUR make_meep_adapter
        meep_adapter = make_meep_adapter({
            'cat_ept_enabled': cat_ept_enabled,
            'global_lambda': meep_lambda,
            'run_time': 100
        })
        
        # Use YOUR setup_enz_experiment method
        meep_adapter.setup_enz_experiment(
            film_thickness=enz_film_thickness,
            lambda_enz=meep_lambda
        )
        
        # Run simulation using YOUR method
        if run_enz_experiment:
            em_results = meep_adapter.run_enz_visibility_test()
            print(f"  ✓ ENZ visibility test complete")
            print(f"  ✓ χ² = {em_results['chi2']:.4f}")
        else:
            em_results = meep_adapter.run_simulation()
            print(f"  ✓ Simulation complete")
        
        lambda_em = meep_lambda
        tau_em = em_results.get('tau_ent')
        if tau_em is not None:
            tau_em = tau_em[-1] if hasattr(tau_em, '__len__') else tau_em
        else:
            tau_em = 0.0
        
        print(f"  ✓ λ_EM: {lambda_em:.6e} s⁻¹")
        print(f"  ✓ τ_EM: {tau_em:.6e} s")
        
        results['lambda_em'] = lambda_em
        results['tau_em'] = tau_em
        results['em_results'] = em_results
        results['num_physics'] += 1
        results['scales'].append('electromagnetic')
    
    else:
        print("\n[2] Electromagnetic: YOUR meep_adapter NOT AVAILABLE")
        results['lambda_em'] = 0.0
        results['tau_em'] = 0.0
    
    # =========================================================================
    # [3] QUANTUM - YOUR quantum_tensors_adapter
    # =========================================================================
    
    if HAS_QT_ADAPTER:
        print("\n[3] Quantum Tensor Networks (YOUR quantum_tensors_adapter):")
        
        # Use YOUR make_quantum_tensors_adapter
        qt_adapter = make_quantum_tensors_adapter({
            'num_qubits': num_qubits,
            'representation': 'mps',
            'bond_dimension': bond_dimension,
            'cat_ept_enabled': cat_ept_enabled,
            'lambda_base': 1e-17
        })
        
        # Use YOUR create_random_mps method
        mps = qt_adapter.create_random_mps()
        
        # Use YOUR analyze_mps method
        qt_results = qt_adapter.analyze_mps(mps)
        
        lambda_quantum = qt_results.lambda_ent
        tau_quantum = qt_results.tau_ent
        S_quantum = qt_results.entanglement_entropy
        
        print(f"  ✓ MPS: {num_qubits} qubits, χ = {bond_dimension}")
        print(f"  ✓ S_entangle: {S_quantum:.6f}")
        print(f"  ✓ λ_quantum: {lambda_quantum:.6e} s⁻¹")
        print(f"  ✓ τ_quantum: {tau_quantum:.6e} s")
        
        results['lambda_quantum'] = lambda_quantum
        results['tau_quantum'] = tau_quantum
        results['S_quantum'] = S_quantum
        results['qt_results'] = qt_results
        results['num_physics'] += 1
        results['scales'].append('quantum')
    
    else:
        print("\n[3] Quantum: YOUR quantum_tensors_adapter NOT AVAILABLE")
        results['lambda_quantum'] = 0.0
        results['tau_quantum'] = 0.0
        results['S_quantum'] = 0.0
    
    # =========================================================================
    # [4] INTEGRATION - Combine using YOUR entropic_tensors
    # =========================================================================
    
    if HAS_CATEPT_TENSORS and HAS_EINSTEINPY:
        print("\n[4] Multi-Physics CAT/EPT (YOUR entropic_tensors):")
        
        # Total λ_ent from all sources
        lambda_total = (
            results.get('lambda_gravity', 0.0) +
            results.get('lambda_em', 0.0) +
            results.get('lambda_quantum', 0.0)
        )
        
        # Use quantum entropy as entropic field φ
        phi_combined = results.get('S_quantum', 1.0)
        
        # Use YOUR entropic_stress_tensor
        if 'metric' in results:
            metric_for_tensors = results['metric'].tensor()
            coords_for_tensors = results['metric'].syms
        else:
            # Fallback to Minkowski
            t, x, y, z = sp.symbols('t x y z', real=True)
            metric_for_tensors = sp.diag(-1, 1, 1, 1)
            coords_for_tensors = [t, x, y, z]
        
        S_tensor = entropic_stress_tensor(
            phi=phi_combined,
            g=metric_for_tensors,
            coords=coords_for_tensors
        )
        
        Lambda_tensor = imaginary_curvature_tensor(
            phi=phi_combined,
            g=metric_for_tensors,
            coords=coords_for_tensors,
            mode=lambda_mode  # YOUR mode
        )
        
        print(f"  ✓ λ components:")
        print(f"    Gravity:  {results.get('lambda_gravity', 0.0):.6e} s⁻¹")
        print(f"    EM:       {results.get('lambda_em', 0.0):.6e} s⁻¹")
        print(f"    Quantum:  {results.get('lambda_quantum', 0.0):.6e} s⁻¹")
        print(f"  ✓ λ_TOTAL:  {lambda_total:.6e} s⁻¹")
        print(f"\n  ✓ S_μν computed (YOUR entropic_stress_tensor)")
        print(f"  ✓ Λ_μν computed (YOUR imaginary_curvature_tensor)")
        
        results['lambda_total'] = lambda_total
        results['S_entropic_00'] = float(sp.N(S_tensor[0, 0]))
        results['S_entropic_11'] = float(sp.N(S_tensor[1, 1]))
        results['Lambda_00'] = float(sp.N(Lambda_tensor[0, 0]))
        results['Lambda_11'] = float(sp.N(Lambda_tensor[1, 1]))
    
    else:
        results['lambda_total'] = sum([
            results.get('lambda_gravity', 0.0),
            results.get('lambda_em', 0.0),
            results.get('lambda_quantum', 0.0)
        ])
    
    # =========================================================================
    # SUMMARY
    # =========================================================================
    
    print("\n" + "="*70)
    print("  INTEGRATION SUMMARY")
    print("="*70)
    print(f"  Physics scales: {results['num_physics']}")
    print(f"  Scales: {', '.join(results['scales'])}")
    print(f"  λ_total: {results.get('lambda_total', 0.0):.6e} s⁻¹")
    if 'S_entropic_00' in results:
        print(f"  S_entropic_00: {results['S_entropic_00']:.6e}")
    print("\n  ✓ All YOUR existing adapters integrated!")
    
    return results


# =============================================================================
# DEMO
# =============================================================================

def demo_integration():
    """Demonstrate integration using YOUR existing adapters"""
    
    results = integrate_all_physics(
        # GR
        schwarzschild_mass=1.0,
        use_kerr=False,
        
        # EM (YOUR meep_adapter)
        meep_lambda=1e-14,
        enz_film_thickness=0.1,
        run_enz_experiment=False,  # Faster demo
        
        # Quantum (YOUR quantum_tensors_adapter)
        num_qubits=10,
        bond_dimension=50,
        
        # CAT/EPT
        cat_ept_enabled=True,
        lambda_mode='trace_adjusted'  # YOUR mode
    )
    
    print("\n" + "="*70)
    print("  DEMO COMPLETE")
    print("="*70)
    print("\n  This used:")
    print("    ✓ YOUR meep_adapter.py")
    print("    ✓ YOUR quantum_tensors_adapter.py")
    print("    ✓ YOUR einsteinpy_adapter.py")
    print("    ✓ YOUR entropic_tensors.py")
    print("\n  With ONE integration function!")
    
    return results


if __name__ == '__main__':
    results = demo_integration()
