"""Tests for qutip_spacetime_coupling package."""

from __future__ import annotations

import numpy as np
import pytest

# ============================================================
# hawking.py — always available (NumPy only)
# ============================================================

class TestHawkingTemperature:
    def test_natural_units(self):
        from qutip_spacetime_coupling.hawking import hawking_temperature
        T = hawking_temperature(1.0, natural_units=True)
        assert np.isclose(T, 1 / (8 * np.pi), rtol=1e-10)

    def test_solar_mass_si(self):
        from qutip_spacetime_coupling.hawking import hawking_temperature, M_SUN
        T = hawking_temperature(M_SUN)
        # ~6e-8 K for solar mass BH
        assert 1e-9 < T < 1e-6

    def test_smaller_bh_hotter(self):
        from qutip_spacetime_coupling.hawking import hawking_temperature
        T1 = hawking_temperature(1.0, natural_units=True)
        T2 = hawking_temperature(2.0, natural_units=True)
        assert T1 > T2


class TestUnruhTemperature:
    def test_natural_units(self):
        from qutip_spacetime_coupling.hawking import unruh_temperature
        T = unruh_temperature(1.0, natural_units=True)
        assert np.isclose(T, 1 / (2 * np.pi), rtol=1e-10)

    def test_si_units(self):
        from qutip_spacetime_coupling.hawking import unruh_temperature
        T = unruh_temperature(1e20)
        # Extreme acceleration yields measurable T
        assert T > 0


class TestThermalOccupation:
    def test_zero_temperature(self):
        from qutip_spacetime_coupling.hawking import thermal_occupation
        assert thermal_occupation(1.0, 0.0) == 0.0

    def test_high_temperature_natural(self):
        from qutip_spacetime_coupling.hawking import thermal_occupation
        n = thermal_occupation(1.0, 100.0, natural_units=True)
        # High T => large n
        assert n > 10

    def test_low_temperature_natural(self):
        from qutip_spacetime_coupling.hawking import thermal_occupation
        n = thermal_occupation(100.0, 0.01, natural_units=True)
        # Very cold => n ≈ 0
        assert n < 1e-10


class TestSchwarzschildRedshift:
    def test_far_away(self):
        from qutip_spacetime_coupling.hawking import schwarzschild_redshift, M_SUN
        a = schwarzschild_redshift(M_SUN, 1e20)
        assert np.isclose(a, 1.0, atol=1e-6)

    def test_near_horizon(self):
        from qutip_spacetime_coupling.hawking import schwarzschild_redshift, G, C
        M = 1e30
        r_s = 2 * G * M / C**2
        a = schwarzschild_redshift(M, r_s * 1.01)  # just outside
        assert 0 < a < 0.2

    def test_at_horizon(self):
        from qutip_spacetime_coupling.hawking import schwarzschild_redshift, G, C
        M = 1e30
        r_s = 2 * G * M / C**2
        a = schwarzschild_redshift(M, r_s)
        assert a == 0.0


class TestISCO:
    def test_positive(self):
        from qutip_spacetime_coupling.hawking import isco_radius, M_SUN
        r = isco_radius(M_SUN)
        assert r > 0

    def test_equals_3_rs(self):
        from qutip_spacetime_coupling.hawking import isco_radius, G, C
        M = 1e30
        r_s = 2 * G * M / C**2
        r_isco = isco_radius(M)
        assert np.isclose(r_isco, 3 * r_s)


class TestHawkingEntropyRate:
    def test_positive(self):
        from qutip_spacetime_coupling.hawking import hawking_entropy_rate, M_SUN
        rate = hawking_entropy_rate(M_SUN)
        assert rate > 0

    def test_smaller_bh_higher_rate(self):
        from qutip_spacetime_coupling.hawking import hawking_entropy_rate, M_SUN
        r1 = hawking_entropy_rate(M_SUN)
        r2 = hawking_entropy_rate(10 * M_SUN)
        # Smaller BH has higher T => higher rate per unit area, but
        # the area scaling dominates for total luminosity. For the
        # entropy rate dS/dt = L/T, smaller BH wins.
        # L ~ T^4 * A ~ M^-4 * M^2 = M^-2
        # dS/dt = L/T ~ M^-2 / M^-1 = M^-1
        assert r1 > r2


class TestBekensteinHawkingEntropy:
    def test_positive(self):
        from qutip_spacetime_coupling.hawking import bekenstein_hawking_entropy, M_SUN
        S = bekenstein_hawking_entropy(M_SUN)
        assert S > 1e70  # Solar mass BH has ~1e77 entropy


# ============================================================
# coupler.py — NumPy only
# ============================================================

class TestSpacetimeCoupler:
    def test_identity_coupler(self):
        from qutip_spacetime_coupling.coupler import make_identity_coupler
        c = make_identity_coupler(lambda t: 1000.0)
        assert c.lambda_eff(0.0) == 1000.0
        assert c.redshift_factor(0.0) == 1.0
        assert c.efe_residual_norm(0.0) == 0.0

    def test_redshift_modulation(self):
        from qutip_spacetime_coupling.coupler import SpacetimeCoupler
        c = SpacetimeCoupler(
            lambda_base=lambda t: 1000.0,
            redshift_fn=lambda t: 0.5,
        )
        assert np.isclose(c.lambda_eff(0.0), 500.0)

    def test_efe_gain(self):
        from qutip_spacetime_coupling.coupler import SpacetimeCoupler
        c = SpacetimeCoupler(
            lambda_base=lambda t: 1000.0,
            efe_residual_fn=lambda t: 0.1,
            efe_gain=2.0,
        )
        # 1000 * 1.0 * (1 + 2.0 * 0.1) = 1200
        assert np.isclose(c.lambda_eff(0.0), 1200.0)

    def test_evaluate_on(self):
        from qutip_spacetime_coupling.coupler import make_identity_coupler
        c = make_identity_coupler(lambda t: float(t) * 100.0)
        tlist = np.linspace(0, 1, 10)
        vals = c.evaluate_on(tlist)
        assert vals.shape == (10,)
        assert np.isclose(vals[-1], 100.0)

    def test_schwarzschild_coupler(self):
        from qutip_spacetime_coupling.coupler import make_schwarzschild_coupler
        c = make_schwarzschild_coupler(
            lambda t: 1e3, M=1.989e30, r_m=1e10,
        )
        lam = c.lambda_eff(0.0)
        assert 0 < lam <= 1e3


# ============================================================
# metric.py — requires SymPy
# ============================================================

sympy = pytest.importorskip("sympy")


class TestMetric:
    def test_schwarzschild(self):
        from qutip_spacetime_coupling.metric import schwarzschild_metric
        g, coords, params = schwarzschild_metric()
        assert g.shape == (4, 4)
        assert len(coords) == 4
        assert "M" in params

    def test_kerr(self):
        from qutip_spacetime_coupling.metric import kerr_metric
        g, coords, params = kerr_metric()
        assert g.shape == (4, 4)
        assert "a" in params

    def test_minkowski(self):
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        assert g == sympy.diag(-1, 1, 1, 1)

    def test_metric_determinant_minkowski(self):
        from qutip_spacetime_coupling.metric import minkowski_metric, metric_determinant
        g, _, _ = minkowski_metric()
        det = metric_determinant(g)
        assert det == -1

    def test_evaluate_metric(self):
        from qutip_spacetime_coupling.metric import schwarzschild_metric, evaluate_metric
        g, coords, params = schwarzschild_metric(M=1.0)
        point = {coords[0]: 0, coords[1]: 10, coords[2]: np.pi / 2, coords[3]: 0}
        g_num = evaluate_metric(g, coords, point)
        assert g_num.shape == (4, 4)
        # g_tt = -(1 - 2/10) = -0.8
        assert np.isclose(g_num[0, 0], -0.8)


# ============================================================
# curvature.py — requires SymPy
# ============================================================

class TestCurvature:
    def test_christoffel_flat(self):
        from qutip_spacetime_coupling.curvature import christoffel_symbols
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        Gamma = christoffel_symbols(g, coords)
        # Flat space: all Christoffels vanish
        for i in range(4):
            for j in range(4):
                for k in range(4):
                    assert Gamma[i, j, k] == 0

    def test_riemann_flat(self):
        from qutip_spacetime_coupling.curvature import christoffel_symbols, riemann_tensor
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        Gamma = christoffel_symbols(g, coords)
        R = riemann_tensor(Gamma, coords)
        for i in range(4):
            for j in range(4):
                for k in range(4):
                    for l in range(4):
                        assert R[i, j, k, l] == 0

    def test_ricci_flat(self):
        from qutip_spacetime_coupling.curvature import christoffel_symbols, riemann_tensor, ricci_tensor
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        Gamma = christoffel_symbols(g, coords)
        R = riemann_tensor(Gamma, coords)
        Ric = ricci_tensor(R)
        assert Ric == sympy.zeros(4)

    def test_ricci_scalar_flat(self):
        from qutip_spacetime_coupling.curvature import (
            christoffel_symbols, riemann_tensor, ricci_tensor, ricci_scalar
        )
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        Gamma = christoffel_symbols(g, coords)
        R = riemann_tensor(Gamma, coords)
        Ric = ricci_tensor(R)
        Rs = ricci_scalar(Ric, g)
        assert Rs == 0


# ============================================================
# entropic_stress.py — requires SymPy
# ============================================================

class TestEntropicStress:
    def test_constant_phi_zero(self):
        """Constant phi => S_uv = 0."""
        from qutip_spacetime_coupling.entropic_stress import entropic_stress_tensor
        sp = sympy
        t, x = sp.symbols("t x")
        g = sp.diag(-1, 1)
        phi = sp.Integer(5)  # constant
        S = entropic_stress_tensor(phi, g, (t, x))
        assert S == sp.zeros(2)

    def test_constant_phi_lambda_zero(self):
        """Constant phi => Lambda_uv = 0."""
        from qutip_spacetime_coupling.entropic_stress import imaginary_curvature_tensor
        sp = sympy
        t, x = sp.symbols("t x")
        g = sp.diag(-1, 1)
        phi = sp.Integer(3)
        L = imaginary_curvature_tensor(phi, g, (t, x))
        assert L == sp.zeros(2)

    def test_linear_phi_lambda_zero(self):
        """Linear phi => Hessian = 0 => Lambda = 0."""
        from qutip_spacetime_coupling.entropic_stress import imaginary_curvature_tensor
        sp = sympy
        t, x = sp.symbols("t x")
        g = sp.diag(-1, 1)
        phi = 2 * t + 3 * x
        L = imaginary_curvature_tensor(phi, g, (t, x))
        assert L == sp.zeros(2)

    def test_stress_symmetric(self):
        from qutip_spacetime_coupling.entropic_stress import entropic_stress_tensor
        sp = sympy
        t, x = sp.symbols("t x")
        g = sp.diag(-1, 1)
        phi = t**2 + x**2
        S = entropic_stress_tensor(phi, g, (t, x))
        assert sp.simplify(S[0, 1] - S[1, 0]) == 0

    def test_hessian_mode(self):
        from qutip_spacetime_coupling.entropic_stress import imaginary_curvature_tensor
        sp = sympy
        t, x = sp.symbols("t x")
        g = sp.diag(-1, 1)
        phi = t**2 + x**2
        L = imaginary_curvature_tensor(phi, g, (t, x), mode="hessian")
        # Hessian of phi = diag(2, 2)
        assert L[0, 0] == 2
        assert L[1, 1] == 2

    def test_invalid_mode_raises(self):
        from qutip_spacetime_coupling.entropic_stress import imaginary_curvature_tensor
        sp = sympy
        t, x = sp.symbols("t x")
        g = sp.diag(-1, 1)
        with pytest.raises(ValueError, match="Unknown Lambda mode"):
            imaginary_curvature_tensor(sp.Integer(1), g, (t, x), mode="bogus")


# ============================================================
# complex_efe.py — requires SymPy
# ============================================================

class TestComplexEFE:
    def test_einstein_tensor_flat(self):
        from qutip_spacetime_coupling.complex_efe import einstein_tensor
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        G = einstein_tensor(g=g, coords=coords)
        assert G == sympy.zeros(4)

    def test_residual_flat_constant_phi(self):
        from qutip_spacetime_coupling.complex_efe import complex_efe_residual
        from qutip_spacetime_coupling.metric import minkowski_metric
        g, coords, _ = minkowski_metric()
        result = complex_efe_residual(g=g, coords=coords, phi=sympy.Integer(1))
        assert result.G == sympy.zeros(4)
        assert result.S == sympy.zeros(4)
        assert result.Lambda == sympy.zeros(4)
        assert result.residual_fro_norm == 0


# ============================================================
# Package-level imports
# ============================================================

class TestPackageImports:
    def test_top_level_hawking(self):
        from qutip_spacetime_coupling import hawking_temperature
        T = hawking_temperature(1.0, natural_units=True)
        assert T > 0

    def test_top_level_coupler(self):
        from qutip_spacetime_coupling import SpacetimeCoupler, make_identity_coupler
        c = make_identity_coupler(lambda t: 42.0)
        assert c.lambda_eff(0) == 42.0

    def test_lazy_import_metric(self):
        from qutip_spacetime_coupling import schwarzschild_metric
        g, _, _ = schwarzschild_metric()
        assert g.shape == (4, 4)

    def test_lazy_import_curvature(self):
        from qutip_spacetime_coupling import christoffel_symbols
        assert callable(christoffel_symbols)
