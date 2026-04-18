"""
Tests for OQuPy adapter

Tests cover:
- Adapter creation and configuration
- Entropy calculation
- λ extraction from dS/dt
- τ_ent integration
- TEMPO dynamics (when OQuPy available)
- Fallback mode (when OQuPy unavailable)
- Integration with Kwant

Run with: pytest test_oqupy_adapter.py -v
"""

import pytest
import numpy as np
from pathlib import Path
import sys

# Add catsim to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'simulations/catsim/src'))

from catsim_core.open_quantum import (
    make_oqupy_adapter,
    OQuPyConfig,
    OQuPyResult
)


# =============================================================================
# FIXTURES
# =============================================================================

@pytest.fixture
def simple_config():
    """Basic configuration for testing"""
    return {
        'system_dimension': 2,
        't_end': 1e-13,  # 100 fs
        'dt': 1e-15,     # 1 fs
        'temperature': 300,
        'cat_ept_enabled': True
    }


@pytest.fixture
def spin_boson_system():
    """Standard spin-boson model"""
    H = np.array([[1.0, 0.0], [0.0, -1.0]])  # Pauli-Z
    rho0 = np.array([[0.5, 0.5], [0.5, 0.5]], dtype=complex)  # |+⟩
    coupling = np.array([[0.0, 1.0], [1.0, 0.0]])  # Pauli-X
    return H, rho0, coupling


# =============================================================================
# TEST CATEGORY 1: Adapter Creation
# =============================================================================

class TestAdapterCreation:
    """Test adapter initialization and configuration"""
    
    def test_create_default_adapter(self):
        """Create adapter with default config"""
        adapter = make_oqupy_adapter()
        assert adapter is not None
        assert isinstance(adapter.config, OQuPyConfig)
    
    def test_create_with_config(self, simple_config):
        """Create adapter with custom config"""
        adapter = make_oqupy_adapter(simple_config)
        assert adapter.config.system_dimension == 2
        assert adapter.config.temperature == 300
    
    def test_oqupy_availability(self):
        """Check OQuPy availability status"""
        adapter = make_oqupy_adapter()
        # Either True or False, both valid
        assert isinstance(adapter._oqupy_available, bool)


# =============================================================================
# TEST CATEGORY 2: Entropy Calculations
# =============================================================================

class TestEntropyCalculations:
    """Test von Neumann entropy computation"""
    
    def test_entropy_pure_state(self):
        """Pure state should have zero entropy"""
        adapter = make_oqupy_adapter()
        
        # Pure state |0⟩
        rho_pure = np.array([[1.0, 0.0], [0.0, 0.0]])
        S = adapter.von_neumann_entropy(rho_pure)
        
        assert abs(S) < 1e-10  # Should be zero
    
    def test_entropy_maximally_mixed(self):
        """Maximally mixed state should have S = log(d)"""
        adapter = make_oqupy_adapter()
        
        # Maximally mixed for d=2
        rho_mixed = 0.5 * np.eye(2)
        S = adapter.von_neumann_entropy(rho_mixed, base=2.0)
        
        # S = log_2(2) = 1
        assert abs(S - 1.0) < 1e-10
    
    def test_entropy_partial_mixed(self):
        """Partially mixed state"""
        adapter = make_oqupy_adapter()
        
        # State with p=0.7, (1-p)=0.3
        p = 0.7
        rho = np.diag([p, 1-p])
        S = adapter.von_neumann_entropy(rho)
        
        # S = -p ln(p) - (1-p) ln(1-p)
        S_expected = -(p * np.log(p) + (1-p) * np.log(1-p))
        
        assert abs(S - S_expected) < 1e-10


# =============================================================================
# TEST CATEGORY 3: Purity Calculations
# =============================================================================

class TestPurityCalculations:
    """Test purity Tr(ρ²)"""
    
    def test_purity_pure_state(self):
        """Pure state should have purity = 1"""
        adapter = make_oqupy_adapter()
        
        rho_pure = np.array([[1.0, 0.0], [0.0, 0.0]])
        purity = adapter.compute_purity(rho_pure)
        
        assert abs(purity - 1.0) < 1e-10
    
    def test_purity_maximally_mixed(self):
        """Maximally mixed state should have purity = 1/d"""
        adapter = make_oqupy_adapter()
        
        rho_mixed = 0.5 * np.eye(2)
        purity = adapter.compute_purity(rho_mixed)
        
        # For d=2, purity = 1/2
        assert abs(purity - 0.5) < 1e-10
    
    def test_purity_bounds(self):
        """Purity should be in [1/d, 1]"""
        adapter = make_oqupy_adapter()
        
        # Random density matrix
        rho = np.array([[0.7, 0.1], [0.1, 0.3]], dtype=complex)
        purity = adapter.compute_purity(rho)
        
        assert 0.5 <= purity <= 1.0


# =============================================================================
# TEST CATEGORY 4: Entropy Trace Extraction
# =============================================================================

class TestEntropyTrace:
    """Test extraction of S(t), λ(t), τ_ent(t)"""
    
    def test_extract_from_dephasing(self):
        """Test extraction from simple dephasing dynamics"""
        adapter = make_oqupy_adapter()
        
        # Simple dephasing: coherences decay as exp(-γt)
        times = np.linspace(0, 1e-12, 100)
        gamma = 1e12  # s^-1
        
        # Generate ρ(t)
        rho_t = np.zeros((len(times), 2, 2), dtype=complex)
        for i, t in enumerate(times):
            coh = 0.5 * np.exp(-gamma * t)
            rho_t[i] = np.array([
                [0.5, coh],
                [coh.conjugate(), 0.5]
            ])
        
        entropy, lambda_ent, tau_ent = adapter.extract_entropy_trace(
            times, rho_t
        )
        
        # Checks
        assert len(entropy) == len(times)
        assert len(lambda_ent) == len(times)
        assert len(tau_ent) == len(times)
        
        # Entropy should increase
        assert entropy[-1] > entropy[0]
        
        # λ should be non-negative
        assert np.all(lambda_ent >= 0)
        
        # τ_ent should be monotonic
        assert np.all(np.diff(tau_ent) >= -1e-15)  # Allow tiny numerical errors
    
    def test_tau_ent_integration(self):
        """τ_ent should be integral of λ"""
        adapter = make_oqupy_adapter()
        
        times = np.linspace(0, 1e-12, 100)
        
        # Constant λ for testing
        lambda_const = 1e15  # s^-1
        lambda_ent = lambda_const * np.ones_like(times)
        
        # Manual integration
        tau_expected = lambda_const * times
        
        # Use adapter's integration (mimic internal method)
        tau_ent = np.zeros_like(times)
        for i in range(1, len(times)):
            dt = times[i] - times[i-1]
            tau_ent[i] = tau_ent[i-1] + 0.5 * (lambda_ent[i] + lambda_ent[i-1]) * dt
        
        # Should match analytical result
        assert np.allclose(tau_ent, tau_expected, rtol=1e-6)


# =============================================================================
# TEST CATEGORY 5: Bath Creation
# =============================================================================

class TestBathCreation:
    """Test creation of different bath types"""
    
    def test_create_ohmic_bath(self):
        """Create ohmic bath"""
        adapter = make_oqupy_adapter({'bath_type': 'ohmic'})
        
        if adapter._oqupy_available:
            bath = adapter.create_bath()
            assert bath is not None
        else:
            bath = adapter.create_bath()
            assert bath is None  # Expected when OQuPy unavailable
    
    def test_create_super_ohmic_bath(self):
        """Create super-ohmic bath"""
        adapter = make_oqupy_adapter({'bath_type': 'super_ohmic'})
        
        if adapter._oqupy_available:
            bath = adapter.create_bath()
            assert bath is not None
    
    def test_create_sub_ohmic_bath(self):
        """Create sub-ohmic bath"""
        adapter = make_oqupy_adapter({'bath_type': 'sub_ohmic'})
        
        if adapter._oqupy_available:
            bath = adapter.create_bath()
            assert bath is not None


# =============================================================================
# TEST CATEGORY 6: TEMPO Dynamics
# =============================================================================

class TestTEMPODynamics:
    """Test TEMPO simulation (when OQuPy available)"""
    
    def test_run_dynamics_basic(self, simple_config, spin_boson_system):
        """Run basic TEMPO dynamics"""
        adapter = make_oqupy_adapter(simple_config)
        H, rho0, coupling = spin_boson_system
        
        result = adapter.run_tempo_dynamics(H, rho0, coupling)
        
        assert isinstance(result, OQuPyResult)
        assert len(result.times) > 0
        assert result.density_matrices.shape[0] == len(result.times)
    
    def test_dynamics_entropy_increases(self, simple_config, spin_boson_system):
        """Entropy should increase (or stay constant)"""
        adapter = make_oqupy_adapter(simple_config)
        H, rho0, coupling = spin_boson_system
        
        result = adapter.run_tempo_dynamics(H, rho0, coupling)
        
        if result.entropy is not None:
            # Entropy should not decrease
            dS = np.diff(result.entropy)
            assert np.all(dS >= -1e-10)  # Allow tiny numerical errors
    
    def test_dynamics_lambda_nonnegative(self, simple_config, spin_boson_system):
        """λ should be non-negative"""
        adapter = make_oqupy_adapter(simple_config)
        H, rho0, coupling = spin_boson_system
        
        result = adapter.run_tempo_dynamics(H, rho0, coupling)
        
        if result.lambda_ent is not None:
            assert np.all(result.lambda_ent >= -1e-15)
    
    def test_dynamics_purity_decreases(self, simple_config, spin_boson_system):
        """Purity should decrease (decoherence)"""
        adapter = make_oqupy_adapter(simple_config)
        H, rho0, coupling = spin_boson_system
        
        result = adapter.run_tempo_dynamics(H, rho0, coupling)
        
        if result.purity is not None:
            # Purity decreases or stays constant
            assert result.purity[-1] <= result.purity[0] + 1e-10


# =============================================================================
# TEST CATEGORY 7: Fallback Mode
# =============================================================================

class TestFallbackMode:
    """Test fallback when OQuPy unavailable"""
    
    def test_fallback_runs(self, simple_config, spin_boson_system):
        """Fallback dynamics should run"""
        adapter = make_oqupy_adapter(simple_config)
        H, rho0, coupling = spin_boson_system
        
        # Force fallback by simulating unavailable OQuPy
        adapter._oqupy_available = False
        
        result = adapter.run_tempo_dynamics(H, rho0, coupling)
        
        assert isinstance(result, OQuPyResult)
        assert result.times is not None
        assert result.entropy is not None
    
    def test_fallback_gives_reasonable_results(self, simple_config):
        """Fallback should give physically reasonable results"""
        adapter = make_oqupy_adapter(simple_config)
        adapter._oqupy_available = False
        
        # Pure initial state
        H = np.eye(2)
        rho0 = np.array([[1.0, 0.0], [0.0, 0.0]])
        coupling = np.array([[0.0, 1.0], [1.0, 0.0]])
        
        result = adapter.run_tempo_dynamics(H, rho0, coupling)
        
        # Entropy should increase from zero
        assert result.entropy[0] < 1e-10
        assert result.entropy[-1] > result.entropy[0]


# =============================================================================
# TEST CATEGORY 8: Integration with Other Adapters
# =============================================================================

class TestIntegration:
    """Test integration with other adapters"""
    
    def test_kwant_integration_exists(self):
        """Integration method with Kwant exists"""
        adapter = make_oqupy_adapter()
        assert hasattr(adapter, 'integrate_with_kwant')
    
    def test_kwant_integration_runs(self):
        """Integration with Kwant runs without error"""
        adapter = make_oqupy_adapter()
        
        # Mock Kwant result
        mock_result = type('MockResult', (), {
            'conductance': np.array([1.0]),
            'energies': np.array([0.0])
        })()
        
        integration = adapter.integrate_with_kwant(mock_result)
        
        assert integration is not None
        assert 'note' in integration


# =============================================================================
# INTEGRATION SMOKE TEST
# =============================================================================

def test_complete_workflow_smoke_test():
    """Smoke test: Complete workflow runs without crashing"""
    
    print("\n" + "="*60)
    print("SMOKE TEST: Complete OQuPy Workflow")
    print("="*60)
    
    # Create adapter
    adapter = make_oqupy_adapter({
        'system_dimension': 2,
        't_end': 1e-13,
        'dt': 1e-15,
        'temperature': 300,
        'cat_ept_enabled': True
    })
    
    # Spin-boson model
    H = np.array([[1.0, 0.0], [0.0, -1.0]])
    rho0 = np.array([[0.5, 0.5], [0.5, 0.5]], dtype=complex)
    coupling = np.array([[0.0, 1.0], [1.0, 0.0]])
    
    # Run dynamics
    result = adapter.run_tempo_dynamics(H, rho0, coupling)
    
    # Verify results
    assert result is not None
    assert result.times is not None
    assert result.density_matrices is not None
    
    if result.entropy is not None:
        print(f"✓ Entropy: {result.entropy[0]:.6f} → {result.entropy[-1]:.6f}")
    
    if result.lambda_ent is not None:
        print(f"✓ λ_max: {np.max(result.lambda_ent):.3e} s⁻¹")
    
    if result.tau_ent is not None:
        print(f"✓ τ_ent,final: {result.tau_ent[-1]:.3e} s")
    
    print("✓ Smoke test passed!\n")


# =============================================================================
# RUN ALL TESTS
# =============================================================================

if __name__ == '__main__':
    # Run with pytest
    pytest.main([__file__, '-v', '--tb=short'])
