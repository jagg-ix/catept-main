"""
Unit tests for gala_adapter.

Tests both with and without gala installed (fallback mode).
"""

import pytest
import numpy as np


class TestGalaAdapterNoGala:
    """Tests that work without gala (fallback mode)"""
    
    def test_import_adapter(self):
        """Adapter module can be imported"""
        from catsim_core.engine import gala_adapter
        assert gala_adapter is not None
    
    def test_create_config(self):
        """GalaCAT EPTConfig can be created"""
        from catsim_core.engine.gala_adapter import GalaCAT EPTConfig
        
        config = GalaCAT EPTConfig(
            potential_type='MilkyWayPotential',
            cat_ept_enabled=True,
            lambda_const=1e-17
        )
        
        assert config.potential_type == 'MilkyWayPotential'
        assert config.cat_ept_enabled == True
        assert config.lambda_const == 1e-17
    
    def test_create_state(self):
        """GalaState can be created"""
        from catsim_core.engine.gala_adapter import GalaState
        
        state = GalaState(
            pos=np.array([8.0, 0.0, 0.0]),
            vel=np.array([0.0, 220.0, 0.0]),
            time=0.0,
            tau_ent=0.0
        )
        
        assert state.pos[0] == 8.0
        assert state.vel[1] == 220.0
    
    def test_lambda_profiles(self):
        """Lambda profile functions work"""
        from catsim_core.engine.gala_adapter import LambdaProfile
        
        # Constant
        const_profile = LambdaProfile.constant(1e-17)
        pos = np.array([10.0, 0.0, 0.0])
        lambda_val = const_profile(pos, 0.0)
        assert lambda_val == 1e-17
        
        # Radial exponential
        exp_profile = LambdaProfile.radial_exponential(1e-17, r_scale=8.0)
        lambda_val = exp_profile(pos, 0.0)
        assert lambda_val > 0
        assert lambda_val < 1e-17  # r > r_scale, so exponentially suppressed
        
        # Powerlaw
        pl_profile = LambdaProfile.radial_powerlaw(1e-17, r_0=8.0, gamma=1.0)
        lambda_val = pl_profile(pos, 0.0)
        assert lambda_val > 0
    
    def test_adapter_creation_without_gala(self):
        """Adapter can be created even without gala"""
        from catsim_core.engine.gala_adapter import GalaCAT EPTAdapter, GalaCAT EPTConfig
        
        config = GalaCAT EPTConfig(cat_ept_enabled=False)
        adapter = GalaCAT EPTAdapter(config)
        
        # Should warn about gala not being available
        # but not crash
        assert adapter is not None


@pytest.mark.skipif(
    not _gala_available(),
    reason="gala not installed"
)
class TestGalaAdapterWithGala:
    """Tests that require gala to be installed"""
    
    def test_create_adapter_with_gala(self):
        """Adapter can be created with gala"""
        from catsim_core.engine.gala_adapter import make_gala_adapter
        
        adapter = make_gala_adapter({
            'potential_type': 'MilkyWayPotential',
            'cat_ept_enabled': False
        })
        
        assert adapter._gala_available == True
        assert adapter.potential is not None
    
    def test_integrate_pure_gala(self):
        """Pure gala integration (no CAT/EPT)"""
        from catsim_core.engine.gala_adapter import make_gala_adapter, GalaState
        
        adapter = make_gala_adapter({
            'potential_type': 'MilkyWayPotential',
            'cat_ept_enabled': False,
            'dt': 0.01  # Gyr
        })
        
        initial = GalaState(
            pos=np.array([8.0, 0.0, 0.0]),
            vel=np.array([0.0, 220.0, 0.0])
        )
        
        orbit = adapter.integrate_orbit(initial, t_span=(0, 0.1))  # 100 Myr
        
        assert 'times' in orbit
        assert 'positions' in orbit
        assert 'velocities' in orbit
        assert len(orbit['times']) > 0
        assert orbit['positions'].shape[1] == 3
        
        # No entropic time in pure gala mode
        assert np.all(orbit['tau_ent'] == 0)
    
    def test_integrate_with_catept(self):
        """Integration with CAT/EPT dissipation"""
        from catsim_core.engine.gala_adapter import make_gala_adapter, GalaState
        
        adapter = make_gala_adapter({
            'potential_type': 'MilkyWayPotential',
            'cat_ept_enabled': True,
            'lambda_const': 1e-17,
            'dissipation_mode': 'drag',
            'dt': 0.01
        })
        
        initial = GalaState(
            pos=np.array([8.0, 0.0, 0.0]),
            vel=np.array([0.0, 220.0, 0.0])
        )
        
        orbit = adapter.integrate_orbit(
            initial, 
            t_span=(0, 0.1),
            return_traces=True
        )
        
        assert 'tau_ent' in orbit
        assert orbit['tau_ent'][-1] > 0  # Should accumulate
        
        # Check traces
        assert 'traces' in orbit
        assert 'lambda_eff' in orbit['traces']
        assert 'gamma_eff' in orbit['traces']
    
    def test_dissipation_effect(self):
        """Dissipation should affect orbit"""
        from catsim_core.engine.gala_adapter import make_gala_adapter, GalaState
        
        # Without dissipation
        adapter_std = make_gala_adapter({
            'cat_ept_enabled': False,
            'dt': 0.01
        })
        
        # With dissipation
        adapter_dissip = make_gala_adapter({
            'cat_ept_enabled': True,
            'lambda_const': 1e-16,  # Stronger for testing
            'dt': 0.01
        })
        
        initial = GalaState(
            pos=np.array([8.0, 0.0, 0.0]),
            vel=np.array([0.0, 220.0, 0.0])
        )
        
        orbit_std = adapter_std.integrate_orbit(initial, t_span=(0, 0.5))
        orbit_dissip = adapter_dissip.integrate_orbit(initial, t_span=(0, 0.5))
        
        # Final positions should differ
        final_r_std = np.linalg.norm(orbit_std['positions'][-1])
        final_r_dissip = np.linalg.norm(orbit_dissip['positions'][-1])
        
        # Dissipation should reduce orbital radius (energy loss)
        assert final_r_dissip < final_r_std


def _gala_available():
    """Check if gala is installed"""
    try:
        import gala
        return True
    except ImportError:
        return False


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
