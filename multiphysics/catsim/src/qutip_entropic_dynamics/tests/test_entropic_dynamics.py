"""Comprehensive tests for qutip_entropic_dynamics.

Tests are grouped by module.  Tests that require QuTiP or OQuPy are
skipped when those packages are not installed.
"""

from __future__ import annotations

import numpy as np
import pytest

# ---------------------------------------------------------------------------
# Module imports (core — always available)
# ---------------------------------------------------------------------------
from qutip_entropic_dynamics.entropy import (
    entropy_vn,
    entropy_production_rate,
    entropy_relative,
    entropy_trace,
)
from qutip_entropic_dynamics.reparameterize import (
    LambdaProfile,
    tau_from_lambda,
    tau_entropic,
    lambda0_from_cfl,
)
from qutip_entropic_dynamics.result import EntropicResult
from qutip_entropic_dynamics.enz import (
    DrudeParams,
    DRUDE_ITO,
    eps_drude,
    refractive_index,
    group_velocity_drude,
    enz_frequency,
    enz_wavelength,
    enhancement_factor,
    enz_decoherence_rate,
    frequency_dependent_visibility,
    wavelength_scan,
)
from qutip_entropic_dynamics.analysis import (
    quantum_classical_boundary,
    analyze_qubit,
    analyze_cavity,
)

# Optional deps
try:
    import qutip as qt  # type: ignore
    _HAS_QUTIP = True
except ImportError:
    _HAS_QUTIP = False

try:
    import oqupy  # type: ignore
    _HAS_OQUPY = True
except ImportError:
    _HAS_OQUPY = False


# ===================================================================
# entropy.py
# ===================================================================

class TestEntropyVN:
    def test_pure_state_zero(self):
        rho = np.diag([1.0, 0.0])
        assert entropy_vn(rho) == 0.0

    def test_maximally_mixed_log2(self):
        rho = np.diag([0.5, 0.5])
        assert np.isclose(entropy_vn(rho, base=2), 1.0)

    def test_maximally_mixed_nats(self):
        rho = np.eye(3) / 3.0
        assert np.isclose(entropy_vn(rho), np.log(3))

    def test_non_negative(self):
        rng = np.random.default_rng(42)
        for _ in range(10):
            d = 4
            A = rng.standard_normal((d, d)) + 1j * rng.standard_normal((d, d))
            rho = A @ A.conj().T
            rho /= np.trace(rho)
            assert entropy_vn(rho) >= -1e-14

    def test_complex_density_matrix(self):
        # Off-diagonal elements should not affect entropy of diagonal part
        rho = np.array([[0.7, 0.1j], [-0.1j, 0.3]])
        S = entropy_vn(rho)
        assert S > 0


class TestEntropyProductionRate:
    def test_constant_entropy(self):
        t = np.linspace(0, 1, 50)
        S = np.ones(50)
        lam = entropy_production_rate(S, t, k_B=1.0)
        assert np.allclose(lam, 0.0, atol=1e-12)

    def test_linear_entropy(self):
        t = np.linspace(0, 1, 100)
        S = 2.0 * t
        lam = entropy_production_rate(S, t, k_B=1.0)
        assert np.allclose(lam, 2.0, atol=0.1)

    def test_non_negative(self):
        t = np.linspace(0, 1, 100)
        S = 1 - np.exp(-5 * t)
        lam = entropy_production_rate(S, t, k_B=1.0)
        assert np.all(lam >= 0)


class TestEntropyRelative:
    def test_same_state(self):
        rho = np.diag([0.6, 0.4])
        assert np.isclose(entropy_relative(rho, rho), 0.0, atol=1e-12)

    def test_positive(self):
        rho = np.diag([0.7, 0.3])
        sigma = np.diag([0.5, 0.5])
        assert entropy_relative(rho, sigma) >= 0

    def test_inf_when_support_mismatch(self):
        rho = np.diag([1.0, 0.0])
        sigma = np.diag([0.0, 1.0])
        assert entropy_relative(rho, sigma) == float("inf")


class TestEntropyTrace:
    def test_shape(self):
        t = np.linspace(0, 1, 20)
        rho = np.array([np.diag([0.5 + 0.5 * np.exp(-ti), 0.5 - 0.5 * np.exp(-ti)]) for ti in t])
        S, lam, tau = entropy_trace(t, rho, k_B=1.0)
        assert S.shape == (20,)
        assert lam.shape == (20,)
        assert tau.shape == (20,)

    def test_tau_monotone(self):
        t = np.linspace(0, 2, 50)
        rho = np.array([np.diag([0.5 + 0.5 * np.exp(-ti), 0.5 - 0.5 * np.exp(-ti)]) for ti in t])
        _, _, tau = entropy_trace(t, rho, k_B=1.0)
        assert np.all(np.diff(tau) >= -1e-15)


# ===================================================================
# reparameterize.py
# ===================================================================

class TestTauFromLambda:
    def test_constant_rate(self):
        t = np.linspace(0, 1, 100)
        lam = 2.0 * np.ones_like(t)
        tau = tau_from_lambda(t, lam)
        assert np.isclose(tau[-1], 2.0, rtol=1e-3)
        assert tau[0] == 0.0

    def test_zero_rate(self):
        t = np.linspace(0, 1, 50)
        lam = np.zeros_like(t)
        tau = tau_from_lambda(t, lam)
        assert np.allclose(tau, 0.0)

    def test_shape_mismatch(self):
        with pytest.raises(ValueError, match="same shape"):
            tau_from_lambda(np.array([0, 1]), np.array([1]))


class TestTauEntropic:
    def test_constant(self):
        assert np.isclose(tau_entropic(1.0, 5.0), 5.0)

    def test_zero_T(self):
        assert tau_entropic(0.0, 100.0) == 0.0

    def test_profile(self):
        profile = LambdaProfile(lambda t: 2 * t)  # integral 0..1 of 2t = 1
        assert np.isclose(tau_entropic(1.0, 0.0, profile=profile), 1.0, rtol=1e-3)

    def test_negative_T_raises(self):
        with pytest.raises(ValueError, match="non-negative"):
            tau_entropic(-1.0, 1.0)

    def test_negative_lambda_raises(self):
        with pytest.raises(ValueError, match="non-negative"):
            tau_entropic(1.0, -1.0)


class TestLambda0CFL:
    def test_basic(self):
        val = lambda0_from_cfl(1e-15)
        assert np.isclose(val, 0.95e15)

    def test_zero_dt_raises(self):
        with pytest.raises(ValueError):
            lambda0_from_cfl(0.0)

    def test_bad_safety_raises(self):
        with pytest.raises(ValueError):
            lambda0_from_cfl(1e-15, safety=1.5)


class TestLambdaProfile:
    def test_call(self):
        p = LambdaProfile(lambda t: np.ones_like(t) * 3.0)
        t = np.array([0.0, 0.5, 1.0])
        assert np.allclose(p(t), 3.0)

    def test_shape_check(self):
        p = LambdaProfile(lambda t: np.array([1.0]))
        with pytest.raises(ValueError, match="same shape"):
            p(np.array([0.0, 1.0]))


# ===================================================================
# result.py
# ===================================================================

class TestEntropicResult:
    def test_basic_creation(self):
        r = EntropicResult(times=np.linspace(0, 1, 10))
        assert r.num_times == 10
        assert r.states == []
        assert r.expect == {}

    def test_with_entropy(self):
        t = np.linspace(0, 1, 5)
        S = np.array([0.0, 0.1, 0.2, 0.3, 0.4])
        r = EntropicResult(times=t, entropy=S, tau_ent=S * 2)
        assert "entropy" in repr(r)
        assert "tau_ent_final" in repr(r)


# ===================================================================
# enz.py
# ===================================================================

class TestENZDrude:
    def test_eps_drude_vacuum(self):
        # Large omega => eps -> eps_inf
        p = DrudeParams(eps_inf=1.0, omega_p=1e10, gamma=1e5)
        omega = np.array([1e18])
        eps = eps_drude(omega, p)
        assert np.isclose(np.real(eps[0]), 1.0, atol=1e-3)

    def test_eps_ito_type(self):
        omega = np.array([2 * np.pi * 230e12])
        eps = eps_drude(omega, DRUDE_ITO)
        assert isinstance(eps[0], (complex, np.complexfloating))

    def test_refractive_index_positive(self):
        eps = np.array([4.0 + 0j])
        n = refractive_index(eps)
        assert np.isclose(np.real(n[0]), 2.0)

    def test_group_velocity_finite(self):
        omega = np.linspace(1e14, 5e15, 500)
        v_g = group_velocity_drude(omega, DRUDE_ITO)
        finite = np.isfinite(v_g)
        assert np.sum(finite) > 400  # most points finite

    def test_enz_frequency_reasonable(self):
        f_enz = enz_frequency(DRUDE_ITO)
        # Should be ~1.3e15 rad/s for ITO
        assert 5e14 < f_enz < 5e15

    def test_enz_wavelength_positive(self):
        wl = enz_wavelength(DRUDE_ITO)
        assert wl > 0
        # Should be in IR range ~hundreds of nm to few um
        assert 100e-9 < wl < 10e-6

    def test_enhancement_near_enz(self):
        omega_enz = enz_frequency(DRUDE_ITO)
        omega = np.array([omega_enz * 0.99, omega_enz, omega_enz * 1.01])
        eta = enhancement_factor(omega, DRUDE_ITO)
        # Near ENZ, enhancement should be large (>1)
        finite_eta = eta[np.isfinite(eta)]
        assert len(finite_eta) > 0
        assert np.max(np.abs(finite_eta)) > 1.0


class TestFrequencyDependentVisibility:
    def test_shape(self):
        f = np.linspace(200e12, 260e12, 100)
        V = frequency_dependent_visibility(f, 500e-15)
        assert V.shape == (100,)

    def test_bounded(self):
        f = np.linspace(200e12, 260e12, 100)
        V = frequency_dependent_visibility(f, 500e-15)
        assert np.all(V >= 0)
        assert np.all(V <= 1.0 + 1e-10)

    def test_decreases_with_separation(self):
        f = np.linspace(200e12, 260e12, 100)
        V_short = frequency_dependent_visibility(f, 100e-15)
        V_long = frequency_dependent_visibility(f, 1000e-15)
        # Longer separation => more decoherence => lower mean visibility
        assert np.nanmean(V_long) <= np.nanmean(V_short) + 1e-10


class TestWavelengthScan:
    def test_keys(self):
        result = wavelength_scan(DRUDE_ITO, n_points=50)
        expected = {"wavelength_nm", "omega_rad_s", "epsilon_real",
                    "epsilon_imag", "n_real", "n_imag", "group_velocity",
                    "enhancement_factor", "lambda_enz"}
        assert set(result.keys()) == expected

    def test_shapes(self):
        result = wavelength_scan(DRUDE_ITO, n_points=50)
        for v in result.values():
            assert v.shape == (50,)


# ===================================================================
# analysis.py
# ===================================================================

class TestQuantumClassicalBoundary:
    def test_quantum_regime(self):
        # 5 GHz qubit at 20 mK => deeply quantum
        HBAR = 1.054_571_817e-34
        result = quantum_classical_boundary(HBAR * 2 * np.pi * 5e9, 0.02)
        assert result["regime"] == "quantum"
        assert result["xi"] > 10

    def test_classical_regime(self):
        result = quantum_classical_boundary(1e-30, 300)
        assert result["regime"] == "classical"

    def test_float_input(self):
        result = quantum_classical_boundary(1e-20, 300)
        assert "regime" in result


class TestAnalyzeQubit:
    def test_default(self):
        result = analyze_qubit()
        assert result["frequency_GHz"] == pytest.approx(5.0, rel=0.01)
        assert result["regime"] == "quantum"
        assert result["lambda_quantum"] > 0

    def test_custom(self):
        result = analyze_qubit(omega=2 * np.pi * 10e9, T1=100e-6, T2=50e-6, T=0.01)
        assert result["frequency_GHz"] == pytest.approx(10.0, rel=0.01)


class TestAnalyzeCavity:
    def test_default(self):
        result = analyze_cavity()
        assert result["Q_factor"] > 0
        assert result["tau_photon"] > 0

    def test_custom(self):
        result = analyze_cavity(omega_c=2 * np.pi * 5e9, kappa=1e5, n_photons=5)
        assert result["lambda_cavity"] == pytest.approx(5e5)


# ===================================================================
# dynamics.py (requires QuTiP)
# ===================================================================

@pytest.mark.skipif(not _HAS_QUTIP, reason="QuTiP not installed")
class TestDynamics:
    def test_entropic_mesolve(self):
        from qutip_entropic_dynamics.dynamics import entropic_mesolve

        H = qt.sigmaz()
        rho0 = qt.ket2dm(qt.basis(2, 0))
        c_ops = [0.1 * qt.sigmam()]
        tlist = np.linspace(0, 10, 50)

        res = entropic_mesolve(H, rho0, tlist, c_ops)

        assert isinstance(res, EntropicResult)
        assert res.num_times == 50
        assert res.entropy is not None
        assert res.lambda_ent is not None
        assert res.tau_ent is not None
        assert res.entropy[0] == pytest.approx(0.0, abs=1e-10)
        assert res.entropy[-1] > 0  # entropy should increase

    def test_entropic_sesolve(self):
        from qutip_entropic_dynamics.dynamics import entropic_sesolve

        H = qt.sigmaz()
        psi0 = qt.basis(2, 0)
        tlist = np.linspace(0, 10, 50)

        res = entropic_sesolve(H, psi0, tlist)

        assert isinstance(res, EntropicResult)
        # Pure state evolution => entropy stays zero
        assert np.allclose(res.entropy, 0.0, atol=1e-10)

    def test_evolve_complex_action(self):
        from qutip_entropic_dynamics.dynamics import evolve_complex_action

        H_R = qt.sigmaz()
        J = qt.sigmam().dag() * qt.sigmam()
        psi0 = qt.basis(2, 0)
        tlist = np.linspace(0, 1e-9, 30)

        res = evolve_complex_action(
            H_R, J, psi0, tlist,
            lambda t: 1e6,
            hbar=1.0,
        )

        assert isinstance(res, EntropicResult)
        assert res.lambda_ent is not None
        assert np.allclose(res.lambda_ent, 1e6)
        assert res.tau_ent[-1] > 0

    def test_evolve_in_tau(self):
        from qutip_entropic_dynamics.dynamics import evolve_in_tau

        H_R = qt.sigmaz()
        J = 0.01 * qt.sigmam().dag() * qt.sigmam()
        psi0 = qt.basis(2, 0)
        tlist = np.linspace(0, 1e-9, 30)

        res = evolve_in_tau(
            H_R, J, psi0, tlist,
            lambda t: 1e6,  # constant lambda
            hbar=1.0,
        )

        assert isinstance(res, EntropicResult)
        assert res.stats["solver"] == "sesolve_tau"


# ===================================================================
# analysis.py operator-based (requires QuTiP)
# ===================================================================

@pytest.mark.skipif(not _HAS_QUTIP, reason="QuTiP not installed")
class TestAnalysisQutip:
    def test_decoherence_timescales(self):
        from qutip_entropic_dynamics.analysis import decoherence_timescales

        gamma_1 = 1e3
        c_relax = np.sqrt(gamma_1) * qt.sigmam()
        rho = qt.ket2dm(qt.basis(2, 0))

        T1, T2 = decoherence_timescales([c_relax], rho)
        assert T1 == pytest.approx(1e-3, rel=0.5)

    def test_quantum_speed_limit(self):
        from qutip_entropic_dynamics.analysis import quantum_speed_limit

        H = qt.sigmax()
        psi_i = qt.basis(2, 0)
        psi_f = qt.basis(2, 1)

        tau_qsl = quantum_speed_limit(H, psi_i, psi_f)
        assert tau_qsl > 0
        assert np.isfinite(tau_qsl)


# ===================================================================
# Package-level imports
# ===================================================================

class TestPackageImports:
    def test_core_imports(self):
        from qutip_entropic_dynamics import entropy_vn, tau_from_lambda, EntropicResult
        assert callable(entropy_vn)
        assert callable(tau_from_lambda)

    def test_enz_imports(self):
        from qutip_entropic_dynamics import eps_drude, DRUDE_ITO, frequency_dependent_visibility
        assert callable(eps_drude)
        assert callable(frequency_dependent_visibility)

    def test_analysis_imports(self):
        from qutip_entropic_dynamics import quantum_classical_boundary, analyze_qubit
        assert callable(quantum_classical_boundary)
        assert callable(analyze_qubit)

    def test_version(self):
        import qutip_entropic_dynamics
        assert hasattr(qutip_entropic_dynamics, "__version__")
