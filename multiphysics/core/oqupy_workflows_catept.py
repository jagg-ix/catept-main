"""
OQuPy Workflows for CAT/EPT Framework

Comprehensive demonstrations of open quantum systems with CAT/EPT:
1. Spin-boson model with non-Markovian bath
2. Quantum dot decoherence
3. Two-level system with temperature dependence
4. Integration with Kwant (quantum transport)

Each workflow extracts:
- S(t): von Neumann entropy
- λ(t): entropic dissipation rate
- τ_ent(t): accumulated entropic time

Reference: Strathearn et al., Nature Commun. 9, 3322 (2018)
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import sys

# Add catsim to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'src'))

from catsim_core.open_quantum import make_oqupy_adapter


# =============================================================================
# WORKFLOW 1: Spin-Boson Model with Ohmic Bath
# =============================================================================

def workflow_spin_boson_ohmic():
    """
    Classic spin-boson model: two-level system coupled to ohmic bath
    
    Physics:
    - System: Qubit with energy splitting
    - Bath: Ohmic spectral density J(ω) = α ω exp(-ω/ω_c)
    - Coupling: σ_x (bit-flip)
    
    CAT/EPT predictions:
    - λ(t) peaks during decoherence transient
    - τ_ent accumulates as coherence lost
    - Temperature dependence: λ ∝ T at high T
    """
    
    print("="*70)
    print("WORKFLOW 1: Spin-Boson Model with Ohmic Bath")
    print("="*70)
    
    # Configuration
    adapter = make_oqupy_adapter({
        'system_dimension': 2,
        't_start': 0.0,
        't_end': 1e-12,  # 1 ps
        'dt': 5e-15,     # 5 fs
        'bath_type': 'ohmic',
        'temperature': 300.0,  # K
        'cutoff_freq': 1e14,   # rad/s
        'coupling_strength': 0.1,
        'tempo_dt': 5e-15,
        'tempo_dkmax': 100,
        'cat_ept_enabled': True
    })
    
    print("\nSystem Setup:")
    print("  Two-level system (qubit)")
    print("  Energy splitting: Δ = 2 eV")
    print("  Ohmic bath at T = 300 K")
    print("  Coupling strength: α = 0.1")
    
    # System Hamiltonian: H = Δ σ_z / 2
    Delta = 2.0  # eV (large splitting)
    H_sys = 0.5 * Delta * np.array([
        [1.0, 0.0],
        [0.0, -1.0]
    ])
    
    # Initial state: equal superposition |+⟩ = (|0⟩ + |1⟩)/√2
    rho0 = np.array([
        [0.5, 0.5],
        [0.5, 0.5]
    ], dtype=complex)
    
    # Coupling operator: σ_x (causes bit-flips)
    coupling = np.array([
        [0.0, 1.0],
        [1.0, 0.0]
    ])
    
    # Observables to track
    observables = {
        'sigma_x': coupling,
        'sigma_z': np.array([[1.0, 0.0], [0.0, -1.0]]),
        'populations': np.array([[1.0, 0.0], [0.0, 0.0]])  # |0⟩⟨0|
    }
    
    print("\nRunning TEMPO simulation...")
    result = adapter.run_tempo_dynamics(
        H_sys=H_sys,
        rho0=rho0,
        coupling_op=coupling,
        observables=observables
    )
    
    # Analysis
    print("\nResults:")
    print(f"  Initial entropy: S(0) = {result.entropy[0]:.6f}")
    print(f"  Final entropy: S(t_f) = {result.entropy[-1]:.6f}")
    print(f"  Entropy increase: ΔS = {result.entropy[-1] - result.entropy[0]:.6f}")
    print(f"  Peak λ: {np.max(result.lambda_ent):.3e} s⁻¹")
    print(f"  Final τ_ent: {result.tau_ent[-1]:.3e} s")
    print(f"  Initial purity: {result.purity[0]:.6f}")
    print(f"  Final purity: {result.purity[-1]:.6f}")
    print(f"  Purity loss: {result.purity[0] - result.purity[-1]:.6f}")
    
    # Decoherence time (when coherence drops to 1/e)
    coherence_norm = result.coherence / result.coherence[0]
    idx_decohere = np.where(coherence_norm < 1/np.e)[0]
    if len(idx_decohere) > 0:
        t_decohere = result.times[idx_decohere[0]]
        print(f"  Decoherence time: τ_d = {t_decohere:.3e} s")
    
    # Visualization
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Plot 1: Entropy and λ
    ax1 = axes[0, 0]
    ax1_twin = ax1.twinx()
    
    times_ps = result.times * 1e12  # Convert to ps
    
    ax1.plot(times_ps, result.entropy, 'b-', linewidth=2, label='Entropy S(t)')
    ax1.set_xlabel('Time (ps)', fontsize=12)
    ax1.set_ylabel('Entropy S', fontsize=12, color='b')
    ax1.tick_params(axis='y', labelcolor='b')
    ax1.grid(alpha=0.3)
    
    ax1_twin.plot(times_ps, result.lambda_ent, 'r-', linewidth=2, label='λ(t)')
    ax1_twin.set_ylabel('λ (s⁻¹)', fontsize=12, color='r')
    ax1_twin.tick_params(axis='y', labelcolor='r')
    
    ax1.set_title('Entropy Production & Dissipation Rate', fontsize=13, fontweight='bold')
    
    # Plot 2: Entropic time
    ax2 = axes[0, 1]
    ax2.plot(times_ps, result.tau_ent, 'g-', linewidth=2)
    ax2.set_xlabel('Time (ps)', fontsize=12)
    ax2.set_ylabel('τ_ent (s)', fontsize=12)
    ax2.set_title('Accumulated Entropic Time', fontsize=13, fontweight='bold')
    ax2.grid(alpha=0.3)
    
    # Plot 3: Purity and coherence
    ax3 = axes[1, 0]
    ax3.plot(times_ps, result.purity, 'b-', linewidth=2, label='Purity Tr(ρ²)')
    ax3.plot(times_ps, coherence_norm, 'r--', linewidth=2, label='Coherence (normalized)')
    ax3.axhline(1/np.e, color='gray', linestyle=':', label='1/e')
    ax3.set_xlabel('Time (ps)', fontsize=12)
    ax3.set_ylabel('Purity / Coherence', fontsize=12)
    ax3.set_title('Decoherence Dynamics', fontsize=13, fontweight='bold')
    ax3.legend()
    ax3.grid(alpha=0.3)
    
    # Plot 4: Observables
    ax4 = axes[1, 1]
    if result.observables is not None:
        ax4.plot(times_ps, result.observables['sigma_x'], 'b-', linewidth=2, label='⟨σ_x⟩')
        ax4.plot(times_ps, result.observables['sigma_z'], 'r-', linewidth=2, label='⟨σ_z⟩')
    ax4.set_xlabel('Time (ps)', fontsize=12)
    ax4.set_ylabel('Expectation Value', fontsize=12)
    ax4.set_title('Observable Dynamics', fontsize=13, fontweight='bold')
    ax4.legend()
    ax4.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oqupy_spin_boson.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: oqupy_spin_boson.png")
    
    return {
        'result': result,
        'decoherence_time': t_decohere if len(idx_decohere) > 0 else None,
        'entropy_increase': result.entropy[-1] - result.entropy[0],
        'peak_lambda': np.max(result.lambda_ent),
        'final_tau_ent': result.tau_ent[-1]
    }


# =============================================================================
# WORKFLOW 2: Temperature Dependence
# =============================================================================

def workflow_temperature_dependence():
    """
    Study how CAT/EPT quantities depend on bath temperature
    
    Physics:
    - Same spin-boson model
    - Vary temperature: 10 K to 500 K
    - Track λ_max and τ_ent,final vs T
    
    CAT/EPT predictions:
    - λ increases with T (thermal fluctuations)
    - τ_ent accumulates faster at higher T
    - Decoherence time decreases with T
    """
    
    print("\n" + "="*70)
    print("WORKFLOW 2: Temperature Dependence of CAT/EPT")
    print("="*70)
    
    temperatures = [10, 50, 100, 200, 300, 400, 500]  # K
    results = []
    
    print("\nScanning temperatures: 10 K to 500 K")
    
    for T in temperatures:
        print(f"\n  T = {T} K...")
        
        adapter = make_oqupy_adapter({
            'system_dimension': 2,
            't_end': 1e-12,
            'dt': 1e-14,
            'bath_type': 'ohmic',
            'temperature': T,
            'coupling_strength': 0.1,
            'cat_ept_enabled': True
        })
        
        # Same system as workflow 1
        H_sys = np.array([[1.0, 0.0], [0.0, -1.0]])
        rho0 = np.array([[0.5, 0.5], [0.5, 0.5]], dtype=complex)
        coupling = np.array([[0.0, 1.0], [1.0, 0.0]])
        
        result = adapter.run_tempo_dynamics(H_sys, rho0, coupling)
        
        results.append({
            'T': T,
            'lambda_max': np.max(result.lambda_ent),
            'tau_ent_final': result.tau_ent[-1],
            'entropy_final': result.entropy[-1],
            'purity_final': result.purity[-1]
        })
        
        print(f"    λ_max = {results[-1]['lambda_max']:.3e} s⁻¹")
        print(f"    τ_ent,final = {results[-1]['tau_ent_final']:.3e} s")
    
    # Analysis
    print("\n\nTemperature Scaling:")
    
    temps = np.array([r['T'] for r in results])
    lambdas = np.array([r['lambda_max'] for r in results])
    taus = np.array([r['tau_ent_final'] for r in results])
    
    # Fit power law: λ ∝ T^n
    log_T = np.log(temps)
    log_lambda = np.log(lambdas)
    coeffs = np.polyfit(log_T, log_lambda, 1)
    n_lambda = coeffs[0]
    
    print(f"  λ_max ∝ T^{n_lambda:.2f}")
    print(f"  (Theory: n ≈ 1 for linear ohmic coupling)")
    
    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Plot 1: λ vs T
    ax1 = axes[0]
    ax1.plot(temps, lambdas, 'o-', linewidth=2, markersize=8)
    ax1.set_xlabel('Temperature (K)', fontsize=12)
    ax1.set_ylabel('Peak λ (s⁻¹)', fontsize=12)
    ax1.set_title('Dissipation Rate vs Temperature', fontsize=13, fontweight='bold')
    ax1.grid(alpha=0.3)
    
    # Plot 2: τ_ent vs T
    ax2 = axes[1]
    ax2.plot(temps, taus, 's-', linewidth=2, markersize=8, color='green')
    ax2.set_xlabel('Temperature (K)', fontsize=12)
    ax2.set_ylabel('Final τ_ent (s)', fontsize=12)
    ax2.set_title('Entropic Time vs Temperature', fontsize=13, fontweight='bold')
    ax2.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oqupy_temperature_dependence.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: oqupy_temperature_dependence.png")
    
    return {
        'temperatures': temps,
        'lambda_max': lambdas,
        'tau_ent_final': taus,
        'scaling_exponent': n_lambda
    }


# =============================================================================
# WORKFLOW 3: Integration with Kwant (Quantum Dot)
# =============================================================================

def workflow_quantum_dot_with_kwant():
    """
    Quantum dot coupled to leads (Kwant) and phonon bath (OQuPy)
    
    Physics:
    - Quantum dot: Single level
    - Leads: Kwant scattering region
    - Phonons: OQuPy bath
    
    CAT/EPT framework:
    - Kwant: Ballistic transport G(E)
    - OQuPy: Decoherence from phonons
    - Combined: Realistic device with dissipation
    """
    
    print("\n" + "="*70)
    print("WORKFLOW 3: Quantum Dot with Kwant + OQuPy")
    print("="*70)
    
    print("\nPhysics:")
    print("  Quantum dot connected to leads")
    print("  - Kwant: Transport through dot")
    print("  - OQuPy: Phonon-induced decoherence")
    print("  - CAT/EPT: Unified dissipation λ(t)")
    
    # OQuPy: Phonon bath dynamics
    adapter = make_oqupy_adapter({
        'system_dimension': 2,
        't_end': 5e-13,  # 500 fs
        'dt': 5e-15,
        'bath_type': 'ohmic',
        'temperature': 77,  # Liquid nitrogen
        'coupling_strength': 0.05,  # Weak coupling
        'cat_ept_enabled': True
    })
    
    # Quantum dot Hamiltonian
    epsilon_d = 0.5  # eV (dot energy level)
    H_dot = epsilon_d * np.array([[1.0, 0.0], [0.0, -1.0]])
    
    # Initial state: electron in dot
    rho0 = np.array([[1.0, 0.0], [0.0, 0.0]])
    
    # Electron-phonon coupling (position-like)
    coupling = np.array([[1.0, 0.0], [0.0, 1.0]])  # Number operator
    
    print("\nRunning OQuPy for phonon bath...")
    oqupy_result = adapter.run_tempo_dynamics(H_dot, rho0, coupling)
    
    # Kwant integration (simplified - would use real Kwant adapter)
    try:
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        print("\nRunning Kwant for ballistic transport...")
        kwant_adapter = make_kwant_adapter({
            'lattice_type': 'square',
            'width': 1,
            'length': 10,
            'lambda_ent': np.mean(oqupy_result.lambda_ent),
            'cat_ept_enabled': True
        })
        
        kwant_adapter.create_system()
        kwant_adapter.finalize_system()
        
        energies = np.array([epsilon_d])
        kwant_result = kwant_adapter.compute_conductance(energies)
        
        G_ballistic = 1.0  # G_0 = 2e²/h per channel
        G_with_phonons = kwant_result.conductance[0]
        
        suppression = (G_ballistic - G_with_phonons) / G_ballistic
        
        print(f"\nCombined Results:")
        print(f"  Ballistic G: {G_ballistic:.4f} (2e²/h)")
        print(f"  G with phonons: {G_with_phonons:.4f} (2e²/h)")
        print(f"  Suppression: {suppression*100:.2f}%")
        print(f"  OQuPy λ_mean: {np.mean(oqupy_result.lambda_ent):.3e} s⁻¹")
        
        integration_result = {
            'oqupy': oqupy_result,
            'kwant': kwant_result,
            'G_ballistic': G_ballistic,
            'G_phonons': G_with_phonons,
            'suppression': suppression
        }
        
    except ImportError:
        print("  Kwant not available - showing OQuPy results only")
        integration_result = {'oqupy': oqupy_result}
    
    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    times_fs = oqupy_result.times * 1e15  # fs
    
    # Plot 1: Entropy
    axes[0].plot(times_fs, oqupy_result.entropy, linewidth=2)
    axes[0].set_xlabel('Time (fs)', fontsize=12)
    axes[0].set_ylabel('Entropy S', fontsize=12)
    axes[0].set_title('Phonon-Induced Entropy', fontsize=13, fontweight='bold')
    axes[0].grid(alpha=0.3)
    
    # Plot 2: λ(t)
    axes[1].plot(times_fs, oqupy_result.lambda_ent, linewidth=2, color='red')
    axes[1].set_xlabel('Time (fs)', fontsize=12)
    axes[1].set_ylabel('λ (s⁻¹)', fontsize=12)
    axes[1].set_title('Dissipation Rate', fontsize=13, fontweight='bold')
    axes[1].grid(alpha=0.3)
    
    # Plot 3: Purity
    axes[2].plot(times_fs, oqupy_result.purity, linewidth=2, color='green')
    axes[2].set_xlabel('Time (fs)', fontsize=12)
    axes[2].set_ylabel('Purity Tr(ρ²)', fontsize=12)
    axes[2].set_title('Decoherence', fontsize=13, fontweight='bold')
    axes[2].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oqupy_quantum_dot.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: oqupy_quantum_dot.png")
    
    return integration_result


# =============================================================================
# WORKFLOW 4: Comparative Bath Study
# =============================================================================

def workflow_bath_comparison():
    """
    Compare different bath spectral densities
    
    Baths:
    - Ohmic: J(ω) ∝ ω (metallic leads)
    - Super-ohmic: J(ω) ∝ ω³ (acoustic phonons)
    - Sub-ohmic: J(ω) ∝ ω^0.5 (1/f noise)
    
    CAT/EPT question:
    - How does bath spectrum affect λ(t) and τ_ent?
    """
    
    print("\n" + "="*70)
    print("WORKFLOW 4: Bath Spectral Density Comparison")
    print("="*70)
    
    bath_types = ['ohmic', 'super_ohmic', 'sub_ohmic']
    bath_results = {}
    
    for bath_type in bath_types:
        print(f"\nBath: {bath_type}")
        
        adapter = make_oqupy_adapter({
            'system_dimension': 2,
            't_end': 1e-12,
            'dt': 5e-15,
            'bath_type': bath_type,
            'temperature': 300,
            'coupling_strength': 0.1,
            'cat_ept_enabled': True
        })
        
        # Standard spin-boson
        H_sys = np.array([[1.0, 0.0], [0.0, -1.0]])
        rho0 = np.array([[0.5, 0.5], [0.5, 0.5]], dtype=complex)
        coupling = np.array([[0.0, 1.0], [1.0, 0.0]])
        
        result = adapter.run_tempo_dynamics(H_sys, rho0, coupling)
        
        bath_results[bath_type] = result
        
        print(f"  λ_max: {np.max(result.lambda_ent):.3e} s⁻¹")
        print(f"  τ_ent,final: {result.tau_ent[-1]:.3e} s")
    
    # Comparison plot
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    colors = {'ohmic': 'blue', 'super_ohmic': 'red', 'sub_ohmic': 'green'}
    
    for bath_type, result in bath_results.items():
        times_ps = result.times * 1e12
        color = colors[bath_type]
        label = bath_type.replace('_', '-')
        
        # Entropy
        axes[0, 0].plot(times_ps, result.entropy, linewidth=2, 
                        color=color, label=label)
        
        # λ(t)
        axes[0, 1].plot(times_ps, result.lambda_ent, linewidth=2,
                        color=color, label=label)
        
        # τ_ent
        axes[1, 0].plot(times_ps, result.tau_ent, linewidth=2,
                        color=color, label=label)
        
        # Purity
        axes[1, 1].plot(times_ps, result.purity, linewidth=2,
                        color=color, label=label)
    
    axes[0, 0].set_xlabel('Time (ps)', fontsize=12)
    axes[0, 0].set_ylabel('Entropy S', fontsize=12)
    axes[0, 0].set_title('Entropy Production', fontsize=13, fontweight='bold')
    axes[0, 0].legend()
    axes[0, 0].grid(alpha=0.3)
    
    axes[0, 1].set_xlabel('Time (ps)', fontsize=12)
    axes[0, 1].set_ylabel('λ (s⁻¹)', fontsize=12)
    axes[0, 1].set_title('Dissipation Rate', fontsize=13, fontweight='bold')
    axes[0, 1].legend()
    axes[0, 1].grid(alpha=0.3)
    
    axes[1, 0].set_xlabel('Time (ps)', fontsize=12)
    axes[1, 0].set_ylabel('τ_ent (s)', fontsize=12)
    axes[1, 0].set_title('Entropic Time', fontsize=13, fontweight='bold')
    axes[1, 0].legend()
    axes[1, 0].grid(alpha=0.3)
    
    axes[1, 1].set_xlabel('Time (ps)', fontsize=12)
    axes[1, 1].set_ylabel('Purity', fontsize=12)
    axes[1, 1].set_title('Purity Loss', fontsize=13, fontweight='bold')
    axes[1, 1].legend()
    axes[1, 1].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oqupy_bath_comparison.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: oqupy_bath_comparison.png")
    
    return bath_results


# =============================================================================
# MAIN: Run All Workflows
# =============================================================================

def main():
    """Run all OQuPy workflows"""
    
    print("\n" + "="*70)
    print("  OQuPy + CAT/EPT WORKFLOWS")
    print("  Non-Markovian Open Quantum Systems")
    print("="*70 + "\n")
    
    try:
        # Workflow 1: Basic spin-boson
        print("Running Workflow 1...")
        results1 = workflow_spin_boson_ohmic()
        print("\n✓ Workflow 1 complete")
        
        input("\nPress Enter to continue to Workflow 2...")
        
        # Workflow 2: Temperature dependence
        print("\nRunning Workflow 2...")
        results2 = workflow_temperature_dependence()
        print("\n✓ Workflow 2 complete")
        
        input("\nPress Enter to continue to Workflow 3...")
        
        # Workflow 3: Kwant integration
        print("\nRunning Workflow 3...")
        results3 = workflow_quantum_dot_with_kwant()
        print("\n✓ Workflow 3 complete")
        
        input("\nPress Enter to continue to Workflow 4...")
        
        # Workflow 4: Bath comparison
        print("\nRunning Workflow 4...")
        results4 = workflow_bath_comparison()
        print("\n✓ Workflow 4 complete")
        
        # Summary
        print("\n" + "="*70)
        print("  ALL WORKFLOWS COMPLETE!")
        print("="*70)
        
        print("\n Summary:")
        print(f"  Workflow 1 - Peak λ: {results1['peak_lambda']:.3e} s⁻¹")
        print(f"  Workflow 2 - T scaling: λ ∝ T^{results2['scaling_exponent']:.2f}")
        print(f"  Workflow 3 - Quantum dot integration demonstrated")
        print(f"  Workflow 4 - Bath comparison complete")
        
        print("\n Figures generated:")
        print("  ✓ oqupy_spin_boson.png")
        print("  ✓ oqupy_temperature_dependence.png")
        print("  ✓ oqupy_quantum_dot.png")
        print("  ✓ oqupy_bath_comparison.png")
        
        print("\n🎉 OQuPy + CAT/EPT workflows successfully demonstrated!")
        
    except KeyboardInterrupt:
        print("\n\nWorkflows interrupted.")
    except Exception as e:
        print(f"\n⚠ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
