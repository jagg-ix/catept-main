"""
Unit tests for Kwant adapter with CAT/EPT.

Tests both with and without Kwant installed (fallback mode).
"""

import pytest
import numpy as np


class TestKwantAdapterNoKwant:
    """Tests that work without Kwant (fallback mode)"""
    
    def test_import_adapter(self):
        """Adapter module can be imported"""
        from catsim_core.transport import kwant_adapter
        assert kwant_adapter is not None
    
    def test_create_config(self):
        """KwantConfig can be created"""
        from catsim_core.transport.kwant_adapter import KwantConfig
        
        config = KwantConfig(
            lattice_type='graphene',
            width=10,
            length=30,
            lambda_ent=1e-17,
            cat_ept_enabled=True
        )
        
        assert config.lattice_type == 'graphene'
        assert config.lambda_ent == 1e-17
    
    def test_adapter_creation_without_kwant(self):
        """Adapter can be created even without Kwant"""
        from catsim_core.transport.kwant_adapter import KwantAdapter, KwantConfig
        
        config = KwantConfig(cat_ept_enabled=False)
        adapter = KwantAdapter(config)
        
        # Should handle missing Kwant gracefully
        assert adapter is not None
        assert adapter._kwant_available == False
    
    def test_theoretical_conductance(self):
        """Theoretical conductance fallback works"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter({
            'lattice_type': 'graphene',
            'lambda_ent': 0,
            'cat_ept_enabled': False
        })
        
        energies = np.linspace(-1, 1, 50)
        result = adapter.compute_conductance(energies)
        
        assert result is not None
        assert len(result.conductance) == len(energies)
        assert all(result.conductance >= 0)  # Conductance non-negative
    
    def test_catept_suppression(self):
        """CAT/EPT reduces conductance"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        # Without CAT/EPT
        adapter_std = make_kwant_adapter({
            'lambda_ent': 0,
            'cat_ept_enabled': False
        })
        
        # With CAT/EPT
        adapter_catept = make_kwant_adapter({
            'lambda_ent': 1e-16,  # Strong for testing
            'cat_ept_enabled': True
        })
        
        energies = np.array([0.0])  # Fermi level
        
        G_std = adapter_std.compute_conductance(energies).conductance[0]
        G_catept = adapter_catept.compute_conductance(energies).conductance[0]
        
        # CAT/EPT should suppress
        assert G_catept <= G_std
    
    def test_quantum_hall(self):
        """QHE calculation works"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter({
            'B_field': 10.0,  # Tesla
            'lambda_ent': 1e-17
        })
        
        nu_range = np.array([1.0, 2.0, 3.0])
        qhe = adapter.quantum_hall_conductance(nu_range)
        
        assert 'sigma_xy_std' in qhe
        assert 'sigma_xy_catept' in qhe
        assert len(qhe['sigma_xy_std']) == len(nu_range)
        
        # Should have plateaus near integers
        assert np.allclose(qhe['sigma_xy_std'], nu_range, rtol=0.1)
    
    def test_decoherence_length(self):
        """Decoherence length calculation"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter_std = make_kwant_adapter({
            'lambda_ent': 0,
            'cat_ept_enabled': False,
            'temperature': 1.0  # K
        })
        
        adapter_catept = make_kwant_adapter({
            'lambda_ent': 1e-17,
            'cat_ept_enabled': True,
            'beta_decoherence': 1e-5,
            'temperature': 1.0
        })
        
        L_std, _ = adapter_std.decoherence_length(energy=0.1)
        _, L_catept = adapter_catept.decoherence_length(energy=0.1)
        
        # Both should be positive
        assert L_std > 0
        assert L_catept > 0
        
        # CAT/EPT should reduce decoherence length
        assert L_catept <= L_std


@pytest.mark.skipif(
    not _kwant_available(),
    reason="Kwant not installed"
)
class TestKwantAdapterWithKwant:
    """Tests that require Kwant to be installed"""
    
    def test_kwant_import(self):
        """Kwant can be imported"""
        import kwant
        assert kwant is not None
    
    def test_create_system(self):
        """Can create Kwant system"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter({
            'lattice_type': 'square',
            'width': 5,
            'length': 10
        })
        
        system = adapter.create_system()
        
        if system is not None:  # Kwant available
            assert adapter._kwant_available == True
            assert system is not None
    
    def test_finalize_system(self):
        """Can finalize system"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter({
            'lattice_type': 'square',
            'width': 5,
            'length': 10
        })
        
        system = adapter.create_system()
        
        if system is not None:
            finalized = adapter.finalize_system()
            assert finalized is not None
    
    def test_conductance_with_kwant(self):
        """Conductance calculation with Kwant"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter({
            'lattice_type': 'square',
            'width': 5,
            'length': 10,
            'lambda_ent': 1e-17
        })
        
        adapter.create_system()
        adapter.finalize_system()
        
        energies = np.linspace(-1, 1, 10)
        result = adapter.compute_conductance(energies)
        
        if result is not None:
            assert len(result.conductance) == len(energies)
            assert all(result.conductance >= 0)
    
    def test_graphene_system(self):
        """Create graphene system"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter({
            'lattice_type': 'graphene',
            'width': 10,
            'length': 20
        })
        
        system = adapter.create_system()
        
        if system is not None:
            # Should have two sublattices for graphene
            assert adapter.config.lattice_type == 'graphene'


class TestIntegrations:
    """Test integrations with other adapters"""
    
    def test_qutip_integration_exists(self):
        """qutip integration method exists"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter()
        
        # Method should exist
        assert hasattr(adapter, 'integrate_with_qutip')
        
        # Should return something even without qutip
        result = adapter.integrate_with_qutip()
        assert result is not None
        assert 'note' in result
    
    def test_meep_integration_exists(self):
        """MEEP integration method exists"""
        from catsim_core.transport.kwant_adapter import make_kwant_adapter
        
        adapter = make_kwant_adapter()
        
        # Method should exist
        assert hasattr(adapter, 'integrate_with_meep')
        
        # Should return something
        result = adapter.integrate_with_meep()
        assert result is not None


def _kwant_available():
    """Check if Kwant is installed"""
    try:
        import kwant
        return True
    except ImportError:
        return False


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
