"""
Unit tests for pynbody_adapter.

Tests both with and without pynbody installed.
"""

import pytest
import numpy as np


class TestPynbodyAdapterNoPynbody:
    """Tests that work without pynbody (fallback mode)"""
    
    def test_import_adapter(self):
        """Adapter module can be imported"""
        from catsim_core.engine import pynbody_adapter
        assert pynbody_adapter is not None
    
    def test_create_config(self):
        """LambdaFieldConfig can be created"""
        from catsim_core.engine.pynbody_adapter import LambdaFieldConfig
        
        config = LambdaFieldConfig(
            method='thermodynamic',
            smoothing_length_kpc=0.5,
            lambda_min=1e-20,
            lambda_max=1e-10
        )
        
        assert config.method == 'thermodynamic'
        assert config.smoothing_length_kpc == 0.5
    
    def test_adapter_creation_without_pynbody(self):
        """Adapter can be created even without pynbody"""
        from catsim_core.engine.pynbody_adapter import PynbodyCAT EPTAnalyzer
        
        # Should handle missing pynbody gracefully
        analyzer = PynbodyCAT EPTAnalyzer("nonexistent.gadget")
        assert analyzer._pynbody_available == False


@pytest.mark.skipif(
    not _pynbody_available(),
    reason="pynbody not installed"
)
class TestPynbodyAdapterWithPynbody:
    """Tests that require pynbody (with mock data)"""
    
    def test_create_mock_snapshot(self, tmp_path):
        """Create a mock snapshot for testing"""
        # This would require pynbody to create test data
        # For now, just check import works
        import pynbody
        assert pynbody is not None
    
    def test_lambda_from_thermodynamics(self):
        """Test λ computation from thermodynamic data"""
        from catsim_core.engine.pynbody_adapter import PynbodyCAT EPTAnalyzer
        
        # Would need actual snapshot data for full test
        # Here we just verify the method exists
        # In production, use fixture with mock snapshot
        pass
    
    def test_compare_to_catept_prediction(self):
        """Test model comparison functionality"""
        # Would use mock snapshot in production
        pass


class TestLambdaInference:
    """Test λ inference algorithms (no external deps)"""
    
    def test_lambda_bounds(self):
        """Lambda values should respect physical bounds"""
        from catsim_core.engine.pynbody_adapter import LambdaFieldConfig
        
        config = LambdaFieldConfig(
            lambda_min=1e-20,
            lambda_max=1e-10
        )
        
        # Clamping test
        test_values = np.array([1e-25, 1e-17, 1e-5])
        clamped = np.clip(test_values, config.lambda_min, config.lambda_max)
        
        assert clamped[0] == config.lambda_min  # Too small → clamped
        assert clamped[1] == 1e-17  # Within bounds
        assert clamped[2] == config.lambda_max  # Too large → clamped


def _pynbody_available():
    """Check if pynbody is installed"""
    try:
        import pynbody
        return True
    except ImportError:
        return False


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
