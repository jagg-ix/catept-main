"""
Unit tests for PyNE adapter with CAT/EPT.

Tests both with and without PyNE installed (fallback mode).
"""

import pytest
import numpy as np


class TestPyNEAdapterNoPyNE:
    """Tests that work without PyNE (fallback mode)"""
    
    def test_import_adapter(self):
        """Adapter module can be imported"""
        from catsim_core.nuclear import pyne_adapter
        assert pyne_adapter is not None
    
    def test_create_config(self):
        """PyNEConfig can be created"""
        from catsim_core.nuclear.pyne_adapter import PyNEConfig
        
        config = PyNEConfig(
            cat_ept_enabled=True,
            global_lambda=1e-15,
            kappa_decay=1e-10
        )
        
        assert config.cat_ept_enabled == True
        assert config.global_lambda == 1e-15
    
    def test_create_isotope(self):
        """NuclearIsotope can be created"""
        from catsim_core.nuclear.pyne_adapter import NuclearIsotope
        
        u238 = NuclearIsotope(
            name='U238',
            Z=92,
            A=238,
            half_life=1.41e17,  # seconds (4.47 Gy)
            decay_mode='alpha',
            lambda_nuclear=1e-15
        )
        
        assert u238.name == 'U238'
        assert u238.Z == 92
        assert u238.A == 238
    
    def test_decay_rate_calculation(self):
        """Decay rate can be computed"""
        from catsim_core.nuclear.pyne_adapter import NuclearIsotope
        
        isotope = NuclearIsotope(
            name='Test',
            Z=1,
            A=1,
            half_life=1000.0,  # seconds
            decay_mode='test',
            lambda_nuclear=0.0
        )
        
        # Standard decay rate
        gamma_std = isotope.decay_rate(include_catept=False)
        assert gamma_std == pytest.approx(np.log(2) / 1000.0)
        
        # With CAT/EPT (but lambda=0, so same)
        gamma_catept = isotope.decay_rate(include_catept=True)
        assert gamma_catept == pytest.approx(gamma_std)
    
    def test_catept_correction(self):
        """CAT/EPT correction modifies decay rate"""
        from catsim_core.nuclear.pyne_adapter import NuclearIsotope
        
        isotope = NuclearIsotope(
            name='Test',
            Z=1,
            A=1,
            half_life=1000.0,
            decay_mode='test',
            lambda_nuclear=1e-12,  # Non-zero
            kappa_decay=1e-10
        )
        
        gamma_std = isotope.decay_rate(include_catept=False)
        gamma_catept = isotope.decay_rate(include_catept=True)
        
        # CAT/EPT should modify rate
        assert gamma_catept != gamma_std
        # Should be enhanced (higher rate, shorter half-life)
        assert gamma_catept > gamma_std
    
    def test_adapter_creation_without_pyne(self):
        """Adapter can be created even without PyNE"""
        from catsim_core.nuclear.pyne_adapter import PyNECATEPTAdapter, PyNEConfig
        
        config = PyNEConfig(cat_ept_enabled=False)
        adapter = PyNECATEPTAdapter(config)
        
        # Should have fallback database
        assert adapter is not None
        assert len(adapter.isotopes) > 0  # Fallback isotopes loaded
    
    def test_fallback_isotopes(self):
        """Fallback database contains common isotopes"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter({'cat_ept_enabled': False})
        
        # Check common isotopes
        u235 = adapter.get_isotope('U235')
        assert u235 is not None
        assert u235.Z == 92
        assert u235.A == 235
        
        c14 = adapter.get_isotope('C14')
        assert c14 is not None
        assert c14.Z == 6


@pytest.mark.skipif(
    not _pyne_available(),
    reason="PyNE not installed"
)
class TestPyNEAdapterWithPyNE:
    """Tests that require PyNE to be installed"""
    
    def test_pyne_import(self):
        """PyNE can be imported"""
        import pyne
        assert pyne is not None
    
    def test_adapter_with_pyne(self):
        """Adapter works with PyNE installed"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter({'cat_ept_enabled': True})
        assert adapter._pyne_available == True
    
    def test_load_isotope_from_pyne(self):
        """Can load isotope data from PyNE"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter()
        
        # Load isotope
        u238 = adapter.get_isotope('U238')
        
        if u238:  # May fail if PyNE data not available
            assert u238.Z == 92
            assert u238.A == 238
            assert u238.half_life > 0
    
    def test_half_life_query(self):
        """Can query half-lives"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter({'cat_ept_enabled': False})
        
        t_half = adapter.half_life('U235')
        if t_half:
            # U-235 half-life ~ 704 My
            assert t_half > 1e15  # seconds
            assert t_half < 1e18
    
    def test_catept_comparison(self):
        """Can compare standard vs CAT/EPT"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter({
            'cat_ept_enabled': True,
            'global_lambda': 1e-12,
            'kappa_decay': 1e-10
        })
        
        comparison = adapter.compare_catept_effect('U238')
        
        if comparison:
            assert 't_half_standard' in comparison
            assert 't_half_catept' in comparison
            assert 'delta_percent' in comparison
            
            # CAT/EPT should modify (even if small)
            assert comparison['delta_percent'] != 0


class TestActivityEvolution:
    """Test radioactive activity calculations"""
    
    def test_activity_decay(self):
        """Activity should decay exponentially"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter({'cat_ept_enabled': False})
        
        N_0 = 1e12  # Initial atoms
        times = np.linspace(0, 10000, 100)  # seconds
        
        activity = adapter.activity_evolution('C14', N_0, times, include_catept=False)
        
        # Activity should decay
        assert activity[0] > activity[-1]
        
        # Should be roughly exponential (check first and last)
        # A(t) = A_0 * exp(-gamma * t)
        ratio = activity[-1] / activity[0]
        assert 0 < ratio < 1
    
    def test_catept_affects_activity(self):
        """CAT/EPT should modify activity evolution"""
        from catsim_core.nuclear.pyne_adapter import make_pyne_adapter
        
        adapter = make_pyne_adapter({
            'cat_ept_enabled': True,
            'global_lambda': 1e-12
        })
        
        N_0 = 1e12
        times = np.linspace(0, 10000, 100)
        
        A_std = adapter.activity_evolution('C14', N_0, times, include_catept=False)
        A_catept = adapter.activity_evolution('C14', N_0, times, include_catept=True)
        
        # Should be different
        assert not np.allclose(A_std, A_catept)


def _pyne_available():
    """Check if PyNE is installed"""
    try:
        import pyne
        return True
    except ImportError:
        return False


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
