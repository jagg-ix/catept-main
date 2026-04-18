"""
PythTB Workflows for CAT/EPT Framework

Comprehensive demonstrations of tight-binding models with CAT/EPT:
1. SSH model (1D topological insulator)
2. Graphene band structure (2D Dirac material)
3. Haldane model (Chern insulator)
4. Integration with Kwant (transport)

Each workflow extracts:
- Band structure E(k)
- Topological invariants (Berry phase, Chern number)
- CAT/EPT quantities (λ, τ_ent from topology)

References:
- Asbóth et al., "A Short Course on Topological Insulators" (2016)
- Hatsugai, "Chern number and edge states" (1993)
- Shen, "Topological Insulators" (2012)
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import sys

# Add catsim to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'src'))

from catsim_core.pythtb import make_pythtb_adapter


# =============================================================================
# WORKFLOW 1: SSH Model (1D Topological Insulator)
# =============================================================================

def workflow_1_ssh_topological():
    """
    SSH (Su-Schrieffer-Heeger) model demonstrating topology
    
    Physics:
    - 1D chain with two sublattices (A, B)
    - Dimerized hopping: t1 (intracell) vs t2 (intercell)
    - Topological phase when t1 > t2
    - Berry phase γ = π (topological) or 0 (trivial)
    - Edge states at domain walls
    
    CAT/EPT:
    - τ_ent ∝ |Berry phase|
    - λ_ent suppressed in topological phase
    - Topological protection vs dissipation
    """
    
    print("="*70)
    print("WORKFLOW 1: SSH Model - Topological Phases")
    print("="*70)
    
    # Two phases to compare
    phases = [
        {'name': 'Trivial', 't1': 0.6, 't2': 1.0, 'color': 'blue'},
        {'name': 'Topological', 't1': 1.0, 't2': 0.6, 'color': 'red'}
    ]
    
    results = []
    
    for phase in phases:
        print(f"\n{phase['name']} Phase:")
        print(f"  t1 = {phase['t1']}, t2 = {phase['t2']}")
        
        # Create adapter
        adapter = make_pythtb_adapter({
            'lattice_type': 'ssh',
            'dimension': 1,
            'num_orbitals': 2,
            'hopping_params': {
                't1': phase['t1'],
                't2': phase['t2']
            },
            'k_points': 200,
            'compute_berry': True,
            'cat_ept_enabled': True
        })
        
        # Compute bands
        result = adapter.compute_bands()
        
        # Store
        phase['result'] = result
        results.append(phase)
        
        # Analysis
        print(f"  Band gap: {result.band_gap:.4f} eV")
        if result.berry_phase is not None:
            print(f"  Berry phase: {result.berry_phase:.4f} π")
            print(f"  τ_ent: {result.tau_ent:.3e} s")
        print(f"  λ_ent: {result.lambda_ent:.3e} s⁻¹")
    
    # Visualization
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1 & 2: Band structures
    for i, phase in enumerate(results):
        ax = axes[0, i]
        result = phase['result']
        
        # Convert k to linear coordinate
        k_lin = np.linspace(0, 1, len(result.k_points))
        
        # Plot bands
        for band in range(result.energies.shape[1]):
            ax.plot(k_lin, result.energies[:, band],
                   color=phase['color'], linewidth=2)
        
        ax.set_xlabel('k (−π to π)', fontsize=12)
        ax.set_ylabel('Energy (eV)', fontsize=12)
        ax.set_title(f"{phase['name']} Phase\n"
                    f"t₁={phase['t1']}, t₂={phase['t2']}\n"
                    f"Gap={result.band_gap:.3f} eV",
                    fontsize=13, fontweight='bold')
        ax.axhline(0, color='gray', linestyle=':', alpha=0.5)
        ax.set_xticks([0, 0.5, 1])
        ax.set_xticklabels(['−π', '0', 'π'])
        ax.grid(alpha=0.3)
    
    # Plot 3: Berry phase comparison
    ax3 = axes[1, 0]
    
    phases_labels = [r['name'] for r in results]
    berry_values = [r['result'].berry_phase if r['result'].berry_phase is not None else 0
                   for r in results]
    colors = [r['color'] for r in results]
    
    bars = ax3.bar(phases_labels, berry_values, color=colors, alpha=0.7, edgecolor='black')
    ax3.axhline(1.0, color='red', linestyle='--', label='Topological (π)')
    ax3.axhline(0.0, color='blue', linestyle='--', label='Trivial (0)')
    ax3.set_ylabel('Berry Phase (π units)', fontsize=12)
    ax3.set_title('Berry Phase Comparison', fontsize=13, fontweight='bold')
    ax3.legend()
    ax3.grid(alpha=0.3, axis='y')
    
    # Plot 4: CAT/EPT quantities
    ax4 = axes[1, 1]
    
    tau_values = [r['result'].tau_ent * 1e15 for r in results]  # Convert to fs
    lambda_values = [r['result'].lambda_ent * 1e-15 for r in results]  # Scale
    
    x = np.arange(len(phases_labels))
    width = 0.35
    
    ax4.bar(x - width/2, tau_values, width, label='τ_ent (fs)',
           color='green', alpha=0.7)
    ax4.bar(x + width/2, lambda_values, width, label='λ_ent (10¹⁵ s⁻¹)',
           color='orange', alpha=0.7)
    
    ax4.set_ylabel('CAT/EPT Quantities', fontsize=12)
    ax4.set_title('CAT/EPT: Topology vs Dissipation', fontsize=13, fontweight='bold')
    ax4.set_xticks(x)
    ax4.set_xticklabels(phases_labels)
    ax4.legend()
    ax4.grid(alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('pythtb_ssh_topology.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: pythtb_ssh_topology.png")
    
    return {
        'results': results,
        'topological_phase': results[1]['result'],
        'trivial_phase': results[0]['result']
    }


# =============================================================================
# WORKFLOW 2: Graphene Band Structure
# =============================================================================

def workflow_2_graphene_dirac():
    """
    Graphene: 2D Dirac material
    
    Physics:
    - Honeycomb lattice (2 sublattices)
    - Linear dispersion near K, K' (Dirac cones)
    - Massless Dirac fermions
    - Pseudospin chirality
    - Klein tunneling
    
    CAT/EPT:
    - τ_ent from sublattice pseudospin
    - λ_ent from scattering channels
    - Dirac point physics
    """
    
    print("\n" + "="*70)
    print("WORKFLOW 2: Graphene Band Structure")
    print("="*70)
    
    print("\nPhysics:")
    print("  Honeycomb lattice with 2 carbon atoms per cell")
    print("  Nearest-neighbor hopping t ≈ 2.7 eV")
    print("  Linear dispersion: E(k) ∝ ħv_F|k−K|")
    print("  Fermi velocity: v_F ≈ 10⁶ m/s")
    
    # Create adapter
    adapter = make_pythtb_adapter({
        'lattice_type': 'graphene',
        'dimension': 2,
        'num_orbitals': 2,
        'hopping_params': {'t': 2.7},  # eV
        'k_points': 300,
        'cat_ept_enabled': True
    })
    
    print("\nCreating graphene model...")
    result = adapter.compute_bands()
    
    # Analysis
    print("\nResults:")
    print(f"  Number of bands: {result.energies.shape[1]}")
    print(f"  Energy range: {np.min(result.energies):.2f} to {np.max(result.energies):.2f} eV")
    
    # Find Dirac point (where bands touch)
    # At K point, should be near zero energy
    mid_idx = len(result.k_points) // 3  # Approximate K point
    dirac_energy = result.energies[mid_idx, 0]
    print(f"  Dirac point energy: {dirac_energy:.4f} eV")
    
    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Plot 1: Band structure along path
    ax1 = axes[0]
    
    k_lin = np.linspace(0, 1, len(result.k_points))
    
    for band in range(result.energies.shape[1]):
        ax1.plot(k_lin, result.energies[:, band],
                linewidth=2, color='black')
    
    ax1.axhline(0, color='red', linestyle='--', label='Fermi level')
    ax1.set_xlabel('k-path', fontsize=12)
    ax1.set_ylabel('Energy (eV)', fontsize=12)
    ax1.set_title('Graphene Band Structure\nΓ → M → K → Γ',
                 fontsize=13, fontweight='bold')
    
    if result.k_labels is not None:
        n_labels = len(result.k_labels)
        label_pos = np.linspace(0, 1, n_labels)
        ax1.set_xticks(label_pos)
        ax1.set_xticklabels(result.k_labels)
        for pos in label_pos:
            ax1.axvline(pos, color='gray', linestyle=':', alpha=0.5)
    
    ax1.legend()
    ax1.grid(alpha=0.3)
    
    # Plot 2: Zoom near Dirac point
    ax2 = axes[1]
    
    # Near K point
    k_near_K_idx = slice(len(result.k_points)//3 - 20,
                         len(result.k_points)//3 + 20)
    k_near_K = k_lin[k_near_K_idx]
    E_near_K = result.energies[k_near_K_idx, :]
    
    ax2.plot(k_near_K, E_near_K[:, 0], 'b-', linewidth=2, label='Valence')
    ax2.plot(k_near_K, E_near_K[:, 1], 'r-', linewidth=2, label='Conduction')
    ax2.axhline(0, color='gray', linestyle=':', alpha=0.5)
    ax2.set_xlabel('k near K point', fontsize=12)
    ax2.set_ylabel('Energy (eV)', fontsize=12)
    ax2.set_title('Dirac Cone (Linear Dispersion)',
                 fontsize=13, fontweight='bold')
    ax2.legend()
    ax2.grid(alpha=0.3)
    
    # Plot 3: Density of states (if computed)
    ax3 = axes[2]
    
    # Compute DOS by histogram
    E_flat = result.energies.flatten()
    dos_energies = np.linspace(-3, 3, 100)
    dos_values, _ = np.histogram(E_flat, bins=dos_energies, density=True)
    dos_energies = (dos_energies[:-1] + dos_energies[1:]) / 2
    
    ax3.plot(dos_values, dos_energies, linewidth=2, color='purple')
    ax3.axhline(0, color='red', linestyle='--', label='Dirac point')
    ax3.set_xlabel('DOS (arb. units)', fontsize=12)
    ax3.set_ylabel('Energy (eV)', fontsize=12)
    ax3.set_title('Density of States\n(Linear at Dirac point)',
                 fontsize=13, fontweight='bold')
    ax3.legend()
    ax3.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('pythtb_graphene_bands.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: pythtb_graphene_bands.png")
    
    return {
        'result': result,
        'dirac_energy': dirac_energy,
        'dos_energies': dos_energies,
        'dos_values': dos_values
    }


# =============================================================================
# WORKFLOW 3: Haldane Model (Chern Insulator)
# =============================================================================

def workflow_3_haldane_chern():
    """
    Haldane model: Quantum Hall effect without magnetic field
    
    Physics:
    - Honeycomb lattice
    - Complex next-nearest hopping (breaks time-reversal)
    - Chern number C = ±1 (topological invariant)
    - Quantum anomalous Hall effect
    - Topological edge states
    
    CAT/EPT:
    - τ_ent from Chern number
    - λ_ent suppressed by topology
    - Protected edge transport
    """
    
    print("\n" + "="*70)
    print("WORKFLOW 3: Haldane Model - Chern Insulator")
    print("="*70)
    
    print("\nPhysics:")
    print("  Honeycomb + complex next-nearest hopping")
    print("  Breaks time-reversal symmetry")
    print("  Chern number C = ±1")
    print("  Topological insulator without magnetic field")
    
    # Create adapter
    adapter = make_pythtb_adapter({
        'lattice_type': 'haldane',
        'dimension': 2,
        'num_orbitals': 2,
        'hopping_params': {
            't1': 1.0,  # Nearest-neighbor
            't2': 0.3,  # Next-nearest
            'phi': np.pi/2,  # Phase (breaks TRS)
            'M': 0.5  # Sublattice mass
        },
        'k_points': 200,
        'compute_chern': True,
        'cat_ept_enabled': True
    })
    
    print("\nCreating Haldane model...")
    result = adapter.compute_bands()
    
    # Analysis
    print("\nResults:")
    if result.band_gap is not None:
        print(f"  Band gap: {result.band_gap:.4f} eV")
    if result.chern_number is not None:
        print(f"  Chern number: {result.chern_number}")
        print(f"  Topological: {'YES' if result.chern_number != 0 else 'NO'}")
    
    print(f"  τ_ent: {result.tau_ent:.3e} s")
    print(f"  λ_ent: {result.lambda_ent:.3e} s⁻¹")
    
    # Visualization
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1: Band structure
    ax1 = axes[0, 0]
    
    k_lin = np.linspace(0, 1, len(result.k_points))
    
    for band in range(result.energies.shape[1]):
        ax1.plot(k_lin, result.energies[:, band],
                linewidth=2, label=f'Band {band+1}')
    
    ax1.axhline(0, color='red', linestyle='--', alpha=0.5, label='Fermi level')
    ax1.set_xlabel('k-path', fontsize=12)
    ax1.set_ylabel('Energy (eV)', fontsize=12)
    ax1.set_title(f'Haldane Model Bands\nChern Number = {result.chern_number}',
                 fontsize=13, fontweight='bold')
    ax1.legend()
    ax1.grid(alpha=0.3)
    
    # Plot 2: Band gap vs parameters (scan)
    ax2 = axes[0, 1]
    
    # Scan sublattice mass M
    M_values = np.linspace(0, 1.5, 20)
    gaps = []
    chern_nums = []
    
    print("\n  Scanning sublattice mass M...")
    for M in M_values:
        temp_adapter = make_pythtb_adapter({
            'lattice_type': 'haldane',
            'dimension': 2,
            'num_orbitals': 2,
            'hopping_params': {
                't1': 1.0,
                't2': 0.3,
                'phi': np.pi/2,
                'M': M
            },
            'k_points': 50,  # Faster
            'compute_chern': True
        })
        temp_result = temp_adapter.compute_bands()
        gaps.append(temp_result.band_gap if temp_result.band_gap else 0)
        chern_nums.append(temp_result.chern_number if temp_result.chern_number else 0)
    
    ax2.plot(M_values, gaps, 'o-', linewidth=2, markersize=6, color='blue')
    ax2.set_xlabel('Sublattice Mass M (eV)', fontsize=12)
    ax2.set_ylabel('Band Gap (eV)', fontsize=12)
    ax2.set_title('Band Gap vs Mass Term', fontsize=13, fontweight='bold')
    ax2.grid(alpha=0.3)
    
    # Plot 3: Chern number phase diagram
    ax3 = axes[1, 0]
    
    # Color-code by Chern number
    colors = ['blue' if c == -1 else 'red' if c == 1 else 'gray' for c in chern_nums]
    ax3.scatter(M_values, gaps, c=colors, s=100, alpha=0.7, edgecolor='black')
    ax3.set_xlabel('Sublattice Mass M (eV)', fontsize=12)
    ax3.set_ylabel('Band Gap (eV)', fontsize=12)
    ax3.set_title('Topological Phase Diagram\n(Blue: C=-1, Red: C=+1, Gray: C=0)',
                 fontsize=13, fontweight='bold')
    ax3.grid(alpha=0.3)
    
    # Plot 4: CAT/EPT - Topology suppresses dissipation
    ax4 = axes[1, 1]
    
    # For each M, compute τ_ent from Chern number
    tau_values = [abs(c) * 1e-15 if c != 0 else 0 for c in chern_nums]
    
    ax4.plot(M_values, tau_values, 'o-', linewidth=2, markersize=6,
            color='green', label='τ_ent ∝ |C|')
    ax4.set_xlabel('Sublattice Mass M (eV)', fontsize=12)
    ax4.set_ylabel('τ_ent (s)', fontsize=12)
    ax4.set_title('CAT/EPT: Topology → Entropic Time',
                 fontsize=13, fontweight='bold')
    ax4.legend()
    ax4.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('pythtb_haldane_topology.png', dpi=150, bbox_inches='tight')
    print("\n✓ Figure saved: pythtb_haldane_topology.png")
    
    return {
        'result': result,
        'M_scan': M_values,
        'gaps': gaps,
        'chern_numbers': chern_nums
    }


# =============================================================================
# WORKFLOW 4: Integration with Kwant (Transport)
# =============================================================================

def workflow_4_kwant_integration():
    """
    Integration: PythTB → Kwant for transport
    
    Use case:
    - PythTB: Define bulk Hamiltonian
    - Kwant: Add leads and compute conductance
    - CAT/EPT: Unified dissipation throughout
    
    Physics:
    - SSH model in scattering geometry
    - Edge states conduct
    - CAT/EPT suppression from topology
    """
    
    print("\n" + "="*70)
    print("WORKFLOW 4: PythTB + Kwant Integration")
    print("="*70)
    
    print("\nConcept:")
    print("  PythTB defines bulk tight-binding Hamiltonian")
    print("  Export to Kwant for scattering/transport")
    print("  CAT/EPT provides unified λ_ent")
    
    # Create SSH model in topological phase
    pythtb_adapter = make_pythtb_adapter({
        'lattice_type': 'ssh',
        'hopping_params': {'t1': 1.0, 't2': 0.6},
        'compute_berry': True,
        'cat_ept_enabled': True
    })
    
    pythtb_result = pythtb_adapter.compute_bands()
    
    print("\nPythTB Results:")
    print(f"  Band gap: {pythtb_result.band_gap:.4f} eV")
    print(f"  Berry phase: {pythtb_result.berry_phase:.4f} π")
    print(f"  τ_ent: {pythtb_result.tau_ent:.3e} s")
    
    # Export Hamiltonian
    print("\nExporting to Kwant...")
    kwant_data = pythtb_adapter.export_to_kwant()
    
    print(f"  Exported hopping parameters:")
    print(f"    Lattice: {kwant_data['lattice_type']}")
    print(f"    Hoppings: {kwant_data['hopping_params']}")
    
    # Try to use Kwant if available
    try:
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        print("\n  Kwant available! Creating transport calculation...")
        
        # Create Kwant system with PythTB parameters
        kwant_adapter = make_kwant_adapter({
            'lattice_type': 'chain',  # 1D chain
            'width': 1,
            'length': 50,
            'lambda_ent': pythtb_result.lambda_ent,  # Use PythTB's λ
            'cat_ept_enabled': True
        })
        
        kwant_adapter.create_system()
        kwant_adapter.finalize_system()
        
        # Compute conductance
        energies = np.linspace(-0.5, 0.5, 100)
        kwant_result = kwant_adapter.compute_conductance(energies)
        
        print(f"\n  Kwant Results:")
        print(f"    Conductance computed at {len(energies)} energies")
        print(f"    Peak G: {np.max(kwant_result.conductance):.4f} (2e²/h)")
        
        # Visualization
        fig, axes = plt.subplots(1, 3, figsize=(16, 5))
        
        # Plot 1: PythTB band structure
        ax1 = axes[0]
        k_lin = np.linspace(0, 1, len(pythtb_result.k_points))
        for band in range(pythtb_result.energies.shape[1]):
            ax1.plot(k_lin, pythtb_result.energies[:, band], linewidth=2)
        ax1.set_xlabel('k', fontsize=12)
        ax1.set_ylabel('Energy (eV)', fontsize=12)
        ax1.set_title('PythTB: Bulk Bands', fontsize=13, fontweight='bold')
        ax1.grid(alpha=0.3)
        
        # Plot 2: Kwant conductance
        ax2 = axes[1]
        ax2.plot(energies, kwant_result.conductance, linewidth=2, color='green')
        ax2.set_xlabel('Energy (eV)', fontsize=12)
        ax2.set_ylabel('Conductance (2e²/h)', fontsize=12)
        ax2.set_title('Kwant: Transport', fontsize=13, fontweight='bold')
        ax2.grid(alpha=0.3)
        
        # Plot 3: Combined CAT/EPT
        ax3 = axes[2]
        
        labels = ['PythTB\n(Bulk)', 'Kwant\n(Transport)']
        tau_vals = [pythtb_result.tau_ent * 1e15, pythtb_result.tau_ent * 1e15]
        lambda_vals = [pythtb_result.lambda_ent * 1e-15,
                      pythtb_result.lambda_ent * 1e-15]
        
        x = np.arange(len(labels))
        width = 0.35
        
        ax3.bar(x - width/2, tau_vals, width, label='τ_ent (fs)', color='blue', alpha=0.7)
        ax3.bar(x + width/2, lambda_vals, width, label='λ_ent (10¹⁵ s⁻¹)',
               color='red', alpha=0.7)
        
        ax3.set_ylabel('CAT/EPT Quantities', fontsize=12)
        ax3.set_title('Unified CAT/EPT', fontsize=13, fontweight='bold')
        ax3.set_xticks(x)
        ax3.set_xticklabels(labels)
        ax3.legend()
        ax3.grid(alpha=0.3, axis='y')
        
        plt.tight_layout()
        plt.savefig('pythtb_kwant_integration.png', dpi=150, bbox_inches='tight')
        print("\n✓ Figure saved: pythtb_kwant_integration.png")
        
        integration_result = {
            'pythtb': pythtb_result,
            'kwant': kwant_result,
            'unified_lambda': pythtb_result.lambda_ent
        }
        
    except ImportError:
        print("  Kwant not available - showing PythTB results only")
        
        # Simple visualization without Kwant
        fig, ax = plt.subplots(figsize=(8, 6))
        
        k_lin = np.linspace(0, 1, len(pythtb_result.k_points))
        for band in range(pythtb_result.energies.shape[1]):
            ax.plot(k_lin, pythtb_result.energies[:, band], linewidth=2)
        
        ax.set_xlabel('k', fontsize=12)
        ax.set_ylabel('Energy (eV)', fontsize=12)
        ax.set_title('SSH Model (Ready for Kwant Export)',
                    fontsize=13, fontweight='bold')
        ax.grid(alpha=0.3)
        
        plt.tight_layout()
        plt.savefig('pythtb_kwant_integration.png', dpi=150, bbox_inches='tight')
        print("\n✓ Figure saved: pythtb_kwant_integration.png")
        
        integration_result = {
            'pythtb': pythtb_result,
            'kwant_data': kwant_data
        }
    
    return integration_result


# =============================================================================
# MAIN: Run All Workflows
# =============================================================================

def main():
    """Run all PythTB workflows"""
    
    print("\n" + "="*70)
    print("  PYTHTB + CAT/EPT WORKFLOWS")
    print("  Tight-Binding Models with Topology")
    print("="*70 + "\n")
    
    try:
        # Workflow 1: SSH topology
        print("Running Workflow 1...")
        results1 = workflow_1_ssh_topological()
        print("\n✓ Workflow 1 complete")
        
        input("\nPress Enter to continue to Workflow 2...")
        
        # Workflow 2: Graphene
        print("\nRunning Workflow 2...")
        results2 = workflow_2_graphene_dirac()
        print("\n✓ Workflow 2 complete")
        
        input("\nPress Enter to continue to Workflow 3...")
        
        # Workflow 3: Haldane
        print("\nRunning Workflow 3...")
        results3 = workflow_3_haldane_chern()
        print("\n✓ Workflow 3 complete")
        
        input("\nPress Enter to continue to Workflow 4...")
        
        # Workflow 4: Kwant integration
        print("\nRunning Workflow 4...")
        results4 = workflow_4_kwant_integration()
        print("\n✓ Workflow 4 complete")
        
        # Summary
        print("\n" + "="*70)
        print("  ALL WORKFLOWS COMPLETE!")
        print("="*70)
        
        print("\n Summary:")
        print(f"  Workflow 1 - SSH Berry phase (topological): "
              f"{results1['topological_phase'].berry_phase:.3f} π")
        print(f"  Workflow 2 - Graphene Dirac energy: "
              f"{results2['dirac_energy']:.4f} eV")
        print(f"  Workflow 3 - Haldane Chern number: "
              f"{results3['result'].chern_number}")
        print(f"  Workflow 4 - Integration demonstrated")
        
        print("\n Figures generated:")
        print("  ✓ pythtb_ssh_topology.png")
        print("  ✓ pythtb_graphene_bands.png")
        print("  ✓ pythtb_haldane_topology.png")
        print("  ✓ pythtb_kwant_integration.png")
        
        print("\n🎉 PythTB + CAT/EPT workflows successfully demonstrated!")
        
    except KeyboardInterrupt:
        print("\n\nWorkflows interrupted.")
    except Exception as e:
        print(f"\n⚠ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
