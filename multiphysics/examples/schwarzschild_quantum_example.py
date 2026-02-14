"""
Complete Quantum-Gravity Integration Example

Demonstrates full CAT/EPT framework integration:
- QuTiP: Quantum dynamics
- einsteinpy: Spacetime geometry
- CAT/EPT: Entropic time, complex action

Example: Quantum system near Schwarzschild black hole
Shows gravitational redshift + entropic damping
"""

import numpy as np
import matplotlib.pyplot as plt
import qutip as qt
from pathlib import Path
import sys

# Add adapters to path
sys.path.insert(0, str(Path(__file__).parent.parent / "adapters"))

from entropic_time_adapter import EntropicTimeAdapter
from einsteinpy_adapter import SpacetimeAdapter
from complex_action_adapter import ComplexActionAdapter

def schwarzschild_quantum_evolution():
    """
    Evolve quantum two-level system near black hole.
    
    Physics:
    - Atom at fixed radius r from black hole
    - Gravitational redshift affects transition frequency
    - Entropic time from thermal Hawking radiation
    - Combined GR + CAT/EPT effects
    """
    
    print("=" * 70)
    print("  QUANTUM SYSTEM NEAR SCHWARZSCHILD BLACK HOLE")
    print("  Integration: QuTiP + einsteinpy + CAT/EPT")
    print("=" * 70)
    print()
    
    # ========================================================================
    # SETUP: BLACK HOLE GEOMETRY
    # ========================================================================
    
    print("Setting up Schwarzschild geometry...")
    
    # Black hole parameters (natural units: G = c = 1)
    M_bh = 1.0               # Black hole mass
    r_s = 2.0 * M_bh         # Schwarzschild radius
    
    # Observation radius
    r_observer = 10 * r_s    # Safe distance from horizon
    
    # Create spacetime adapter
    spacetime = SpacetimeAdapter(
        metric_type="schwarzschild",
        M=M_bh,
        G=1.0,
        c=1.0,
        hbar=1.0,
        k_B=1.0
    )
    
    # Compute Hawking temperature
    T_H = spacetime.horizon_temperature()
    
    print(f"  Black hole mass:        M = {M_bh:.2f}")
    print(f"  Schwarzschild radius:   r_s = {r_s:.2f}")
    print(f"  Observer radius:        r = {r_observer:.2f}")
    print(f"  Hawking temperature:    T_H = {T_H:.6f}")
    print()
    
    # ========================================================================
    # SETUP: QUANTUM SYSTEM
    # ========================================================================
    
    print("Setting up quantum two-level system...")
    
    # Atomic transition frequency (at infinity)
    omega_infinity = 1.0
    
    # Gravitational redshift at observer position
    omega_local = spacetime.gravitational_redshift(r_observer, omega_infinity)
    redshift_factor = omega_local / omega_infinity
    
    print(f"  Frequency at infinity:  ω_∞ = {omega_infinity:.4f}")
    print(f"  Frequency at r={r_observer:.1f}:   ω(r) = {omega_local:.4f}")
    print(f"  Redshift factor:        {redshift_factor:.4f}")
    print()
    
    # Hamiltonian (redshifted)
    H_infinity = 0.5 * omega_infinity * qt.sigmaz()
    H_local = spacetime.schwarzschild_redshift_operator(r_observer, H_infinity)
    
    # Initial state: ground state
    psi0 = qt.basis(2, 0)
    
    # ========================================================================
    # SETUP: ENTROPIC TIME
    # ========================================================================
    
    print("Setting up entropic time from Hawking radiation...")
    
    # Entropic rate from thermal bath at Hawking temperature
    # For two-level system:  λ ∝ ω·coth(ℏω/2k_BT)
    
    entropic_adapter = EntropicTimeAdapter()
    lambda_hawking = entropic_adapter.lambda_from_temperature(
        T=T_H,
        omega=omega_local,
        hbar=1.0,
        k_B=1.0
    )
    
    # Scale for observable effects
    lambda_eff = 0.05 * lambda_hawking  # Reduced for clarity
    
    print(f"  Hawking λ (theoretical): {lambda_hawking:.6f}")
    print(f"  Effective λ (scaled):    {lambda_eff:.6f}")
    print()
    
    # Create adapter with effective rate
    entropic_adapter = EntropicTimeAdapter(lambda_const=lambda_eff)
    
    # ========================================================================
    # EVOLUTION: FOUR SCENARIOS
    # ========================================================================
    
    print("Running evolution scenarios...")
    print()
    
    times = np.linspace(0, 50.0, 500)
    
    # Scenario 1: Flat space, no dissipation (reference)
    print("  1. Flat spacetime, closed system...")
    H_flat = H_infinity
    result_flat = qt.sesolve(H_flat, psi0, times, [qt.sigmaz(), qt.sigmax()])
    
    # Scenario 2: Curved space, no dissipation
    print("  2. Schwarzschild, closed system...")
    result_curved = qt.sesolve(H_local, psi0, times, [qt.sigmaz(), qt.sigmax()])
    
    # Scenario 3: Flat space, with entropic damping
    print("  3. Flat spacetime, open system (CAT/EPT)...")
    result_flat_open = entropic_adapter.evolve_with_entropic_time(
        H_flat, psi0, times, e_ops=[qt.sigmaz(), qt.sigmax()]
    )
    
    # Scenario 4: Full integration (curved + entropic)
    print("  4. Schwarzschild + CAT/EPT (full integration)...")
    result_full = entropic_adapter.evolve_with_entropic_time(
        H_local, psi0, times, e_ops=[qt.sigmaz(), qt.sigmax()]
    )
    
    print("  ✓ All scenarios complete")
    print()
    
    # ========================================================================
    # COMPLEX ACTION FORMALISM
    # ========================================================================
    
    print("Computing complex action dynamics...")
    
    # Imaginary Hamiltonian from dissipation
    H_imag = lambda_eff * H_local
    
    complex_adapter = ComplexActionAdapter(
        H_real=H_local,
        H_imag=H_imag,
        lambda_rate=lambda_eff
    )
    
    # Non-Hermitian evolution
    states_nh, norms, entropy_prod = complex_adapter.complex_evolution(
        psi0, times
    )
    
    print(f"  Final norm:              {norms[-1]:.4f}")
    print(f"  Entropy production:      {entropy_prod[-1]:.4f}")
    print()
    
    # ========================================================================
    # VISUALIZATION
    # ========================================================================
    
    print("Generating visualization...")
    
    fig = plt.figure(figsize=(16, 12))
    gs = fig.add_gridspec(3, 3, hspace=0.3, wspace=0.3)
    
    # ----- ROW 1: EXPECTATION VALUES -----
    
    # Panel 1: σ_z expectation
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.plot(times, result_flat.expect[0], 'k-', label='Flat, closed', lw=1.5, alpha=0.7)
    ax1.plot(times, result_curved.expect[0], 'b-', label='Curved, closed', lw=2)
    ax1.plot(times, result_full.expect[0], 'r--', label='Curved + CAT/EPT', lw=2)
    ax1.set_xlabel('Time t')
    ax1.set_ylabel('⟨σ_z⟩')
    ax1.set_title('Population Inversion')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: σ_x expectation
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.plot(times, result_flat.expect[1], 'k-', label='Flat, closed', lw=1.5, alpha=0.7)
    ax2.plot(times, result_curved.expect[1], 'b-', label='Curved, closed', lw=2)
    ax2.plot(times, result_full.expect[1], 'r--', label='Curved + CAT/EPT', lw=2)
    ax2.set_xlabel('Time t')
    ax2.set_ylabel('⟨σ_x⟩')
    ax2.set_title('Coherence')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    
    # Panel 3: Frequency comparison
    ax3 = fig.add_subplot(gs[0, 2])
    ax3.axhline(omega_infinity, color='k', ls='-', label=f'ω_∞ = {omega_infinity:.3f}', lw=2)
    ax3.axhline(omega_local, color='b', ls='--', label=f'ω(r) = {omega_local:.3f}', lw=2)
    ax3.fill_between([0, times[-1]], omega_local, omega_infinity, alpha=0.2, color='blue')
    ax3.set_xlabel('Time t')
    ax3.set_ylabel('Frequency ω')
    ax3.set_title('Gravitational Redshift')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim([0.9*omega_local, 1.1*omega_infinity])
    
    # ----- ROW 2: ENTROPIC TIME & GEOMETRY -----
    
    # Panel 4: Dual time
    ax4 = fig.add_subplot(gs[1, 0])
    tau_ent = result_full.tau_ent
    ax4.plot(times, times, 'k--', label='t (coordinate)', lw=1.5, alpha=0.5)
    ax4.plot(times, tau_ent, 'g-', label='τ_ent (entropic)', lw=2)
    ax4.set_xlabel('Coordinate time t')
    ax4.set_ylabel('Time')
    ax4.set_title(f'Dual Time (λ = {lambda_eff:.4f})')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    # Panel 5: Damping factor
    ax5 = fig.add_subplot(gs[1, 1])
    damping = entropic_adapter.damping_factor(tau_ent)
    ax5.plot(times, damping, 'orange', lw=2)
    ax5.set_xlabel('Time t')
    ax5.set_ylabel('exp(-τ_ent)')
    ax5.set_title('Entropic Damping')
    ax5.grid(True, alpha=0.3)
    
    # Panel 6: Proper time factor vs radius
    ax6 = fig.add_subplot(gs[1, 2])
    r_range = np.linspace(2.1*r_s, 20*r_s, 200)
    proper_factor = [spacetime.proper_time_factor(r) for r in r_range]
    ax6.plot(r_range/r_s, proper_factor, 'b-', lw=2)
    ax6.axvline(r_observer/r_s, color='r', ls='--', label=f'Observer (r={r_observer/r_s:.1f}r_s)', lw=2)
    ax6.axhline(redshift_factor, color='r', ls=':', alpha=0.5)
    ax6.set_xlabel('r / r_s')
    ax6.set_ylabel('√(1 - r_s/r)')
    ax6.set_title('Proper Time Factor')
    ax6.legend()
    ax6.grid(True, alpha=0.3)
    
    # ----- ROW 3: COMPLEX ACTION & ENTROPY -----
    
    # Panel 7: Norm decay (complex action)
    ax7 = fig.add_subplot(gs[2, 0])
    ax7.plot(times, norms, 'purple', lw=2)
    ax7.set_xlabel('Time t')
    ax7.set_ylabel('||ψ||')
    ax7.set_title('Norm Decay (Non-Hermitian)')
    ax7.grid(True, alpha=0.3)
    
    # Panel 8: Entropy production
    ax8 = fig.add_subplot(gs[2, 1])
    ax8.plot(times, entropy_prod, 'brown', lw=2)
    ax8.set_xlabel('Time t')
    ax8.set_ylabel('S_produced')
    ax8.set_title('Entropy Production')
    ax8.grid(True, alpha=0.3)
    
    # Panel 9: Phase space (Bloch sphere trajectory)
    ax9 = fig.add_subplot(gs[2, 2])
    # Compare trajectories
    ax9.plot(result_flat.expect[1], result_flat.expect[0], 'k-', 
             label='Flat', lw=1.5, alpha=0.5)
    ax9.plot(result_curved.expect[1], result_curved.expect[0], 'b-', 
             label='Curved', lw=2)
    ax9.plot(result_full.expect[1], result_full.expect[0], 'r--', 
             label='Curved+CAT', lw=2)
    ax9.set_xlabel('⟨σ_x⟩')
    ax9.set_ylabel('⟨σ_z⟩')
    ax9.set_title('Phase Space Trajectories')
    ax9.legend()
    ax9.grid(True, alpha=0.3)
    ax9.set_aspect('equal')
    
    plt.savefig('quantum_gravity_integration.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved: quantum_gravity_integration.png")
    print()
    
    # ========================================================================
    # ANALYSIS
    # ========================================================================
    
    print("=" * 70)
    print("  RESULTS SUMMARY")
    print("=" * 70)
    print()
    
    print("GRAVITATIONAL EFFECTS:")
    print(f"  Redshift:              ω(r)/ω_∞ = {redshift_factor:.6f}")
    print(f"  Proper time factor:    √(1-r_s/r) = {redshift_factor:.6f}")
    print(f"  Frequency slowdown:    {(1-redshift_factor)*100:.2f}%")
    print()
    
    print("ENTROPIC EFFECTS:")
    print(f"  Dissipation rate:      λ = {lambda_eff:.6f}")
    print(f"  Final entropic time:   τ_ent = {tau_ent[-1]:.4f}")
    print(f"  Final damping:         exp(-τ_ent) = {damping[-1]:.4f}")
    print(f"  Entropy produced:      S = {entropy_prod[-1]:.4f}")
    print()
    
    print("COMBINED QUANTUM-GR-THERMODYNAMICS:")
    print(f"  Standard oscillation period:   T_0 = {2*np.pi/omega_infinity:.4f}")
    print(f"  Redshifted period:             T_r = {2*np.pi/omega_local:.4f}")
    print(f"  With entropic damping:         Effective decay")
    print()
    
    # Final purity comparison
    purity_flat = result_flat.states[-1].purity()
    purity_curved = result_curved.states[-1].purity()
    purity_full = result_full.states[-1].purity()
    
    print("FINAL PURITY:")
    print(f"  Flat, closed:          {purity_flat:.6f}")
    print(f"  Curved, closed:        {purity_curved:.6f}")
    print(f"  Curved + CAT/EPT:      {purity_full:.6f}")
    print()
    
    print("=" * 70)
    print("  Integration demonstrates:")
    print("  ✓ Gravitational redshift affects quantum frequencies")
    print("  ✓ Entropic time provides thermodynamic arrow")
    print("  ✓ Complex action tracks entropy production")
    print("  ✓ Full quantum-GR-thermodynamics coupling achieved")
    print("=" * 70)
    print()

if __name__ == "__main__":
    schwarzschild_quantum_evolution()
