"""Tests for qutip_geant4_bridge package."""

from __future__ import annotations

import numpy as np
import pytest


# ============================================================
# cross_sections.py
# ============================================================

class TestComptonCrossSection:
    def test_thomson_limit(self):
        from qutip_geant4_bridge.cross_sections import compton_cross_section, SIGMA_THOMSON
        sigma = compton_cross_section(1e-4, 1)
        assert np.isclose(sigma, SIGMA_THOMSON, rtol=0.2)

    def test_scales_with_Z(self):
        from qutip_geant4_bridge.cross_sections import compton_cross_section
        s1 = compton_cross_section(1.0, 1)
        s14 = compton_cross_section(1.0, 14)
        assert s14 > s1

    def test_decreases_with_energy(self):
        from qutip_geant4_bridge.cross_sections import compton_cross_section
        s_low = compton_cross_section(0.1, 14)
        s_high = compton_cross_section(10.0, 14)
        assert s_low > s_high

    def test_positive(self):
        from qutip_geant4_bridge.cross_sections import compton_cross_section
        for E in [0.01, 0.1, 1.0, 10.0, 100.0]:
            assert compton_cross_section(E, 14) > 0


class TestComptonScatter:
    def test_energy_conservation(self):
        from qutip_geant4_bridge.cross_sections import compton_scatter
        E = 1.0
        E_prime, theta = compton_scatter(E, theta=np.pi / 2)
        assert E_prime < E
        assert E_prime > 0

    def test_forward_scattering(self):
        from qutip_geant4_bridge.cross_sections import compton_scatter
        E_prime, _ = compton_scatter(1.0, theta=0.0)
        assert np.isclose(E_prime, 1.0)


class TestPairProduction:
    def test_below_threshold(self):
        from qutip_geant4_bridge.cross_sections import pair_production_cross_section
        assert pair_production_cross_section(0.5, 82) == 0.0

    def test_above_threshold(self):
        from qutip_geant4_bridge.cross_sections import pair_production_cross_section
        sigma = pair_production_cross_section(10.0, 82)
        assert sigma > 0

    def test_scales_with_Z_squared(self):
        from qutip_geant4_bridge.cross_sections import pair_production_cross_section
        s1 = pair_production_cross_section(10.0, 10)
        s2 = pair_production_cross_section(10.0, 20)
        # Z^2 scaling: s2/s1 ≈ 4
        assert np.isclose(s2 / s1, 4.0, rtol=0.01)


class TestPhotoelectric:
    def test_positive(self):
        from qutip_geant4_bridge.cross_sections import photoelectric_cross_section
        assert photoelectric_cross_section(0.1, 82) > 0

    def test_decreases_with_energy(self):
        from qutip_geant4_bridge.cross_sections import photoelectric_cross_section
        s1 = photoelectric_cross_section(0.1, 82)
        s2 = photoelectric_cross_section(1.0, 82)
        assert s1 > s2


class TestTotalPhotonCrossSection:
    def test_sum(self):
        from qutip_geant4_bridge.cross_sections import (
            total_photon_cross_section, compton_cross_section,
            pair_production_cross_section, photoelectric_cross_section,
        )
        from qutip_geant4_bridge.transport import MaterialDatabase
        db = MaterialDatabase()
        mat = db["silicon"]
        E = 2.0
        total = total_photon_cross_section(E, mat)
        parts = (
            compton_cross_section(E, mat.Z)
            + pair_production_cross_section(E, mat.Z)
            + photoelectric_cross_section(E, mat.Z)
        )
        assert np.isclose(total, parts)


class TestBethBloch:
    def test_positive(self):
        from qutip_geant4_bridge.cross_sections import bethe_bloch_stopping_power
        from qutip_geant4_bridge.transport import MaterialDatabase
        db = MaterialDatabase()
        dEdx = bethe_bloch_stopping_power(100, 1, 938.3, db["water"])
        assert dEdx > 0

    def test_zero_in_vacuum(self):
        from qutip_geant4_bridge.cross_sections import bethe_bloch_stopping_power
        from qutip_geant4_bridge.transport import MaterialDatabase
        db = MaterialDatabase()
        dEdx = bethe_bloch_stopping_power(100, 1, 938.3, db["vacuum"])
        assert dEdx == 0.0


# ============================================================
# transport.py
# ============================================================

class TestParticleCreation:
    def test_create(self):
        from qutip_geant4_bridge.transport import create_particle
        p = create_particle("gamma", 1.0, [0, 0, 0])
        assert p.particle_type == "gamma"
        assert p.energy == 1.0
        # Direction should be unit vector
        assert np.isclose(np.linalg.norm(p.direction), 1.0)

    def test_fixed_direction(self):
        from qutip_geant4_bridge.transport import create_particle
        p = create_particle("proton", 100, [1, 2, 3], [0, 0, 1])
        assert np.allclose(p.direction, [0, 0, 1])


class TestMaterialDatabase:
    def test_contains(self):
        from qutip_geant4_bridge.transport import MaterialDatabase
        db = MaterialDatabase()
        assert "silicon" in db
        assert "bogus" not in db

    def test_getitem(self):
        from qutip_geant4_bridge.transport import MaterialDatabase
        db = MaterialDatabase()
        si = db["silicon"]
        assert si.Z == 14
        assert si.A == 28

    def test_list_materials(self):
        from qutip_geant4_bridge.transport import MaterialDatabase
        db = MaterialDatabase()
        names = db.list_materials()
        assert "water" in names
        assert len(names) >= 7

    def test_add_custom(self):
        from qutip_geant4_bridge.transport import MaterialDatabase, Material
        db = MaterialDatabase()
        db.add("custom", Material("Custom", 6, 12, 2.0, 78))
        assert "custom" in db


class TestTransport:
    def test_vacuum_full_transmission(self):
        from qutip_geant4_bridge.transport import (
            create_particle, transport_particle, MaterialDatabase,
        )
        db = MaterialDatabase()
        p = create_particle("gamma", 1.0, [0, 0, 0], [0, 0, 1])
        res = transport_particle(p, db["vacuum"], 100.0)
        assert res.transmission == 1.0
        assert res.final_particle is not None

    def test_lead_attenuates(self):
        from qutip_geant4_bridge.transport import (
            create_particle, transport_particle, MaterialDatabase,
        )
        db = MaterialDatabase()
        p = create_particle("gamma", 1.0, [0, 0, 0], [0, 0, 1])
        res = transport_particle(p, db["lead"], 10.0, rng=np.random.default_rng(42))
        assert res.transmission < 1.0

    def test_deterministic_with_seed(self):
        from qutip_geant4_bridge.transport import (
            create_particle, transport_particle, MaterialDatabase,
        )
        db = MaterialDatabase()
        p1 = create_particle("gamma", 1.0, [0, 0, 0], [0, 0, 1])
        p2 = create_particle("gamma", 1.0, [0, 0, 0], [0, 0, 1])
        r1 = transport_particle(p1, db["water"], 5.0, rng=np.random.default_rng(123))
        r2 = transport_particle(p2, db["water"], 5.0, rng=np.random.default_rng(123))
        assert r1.n_steps == r2.n_steps


# ============================================================
# radiation.py
# ============================================================

class TestRadiationDamage:
    def test_basic(self):
        from qutip_geant4_bridge.radiation import radiation_damage_qubit
        d = radiation_damage_qubit("proton", 100.0)
        assert d["gamma_rad"] >= 0
        assert d["T1_damaged"] <= d["T1_intrinsic"]
        assert 0 <= d["degradation"] <= 1

    def test_underground_less_damage(self):
        from qutip_geant4_bridge.radiation import radiation_damage_qubit, cosmic_ray_flux
        flux_surface = cosmic_ray_flux("proton", "sea_level")
        flux_underground = cosmic_ray_flux("proton", "underground")

        d_surface = radiation_damage_qubit("proton", 100, flux=flux_surface)
        d_underground = radiation_damage_qubit("proton", 100, flux=flux_underground)
        assert d_underground["gamma_rad"] < d_surface["gamma_rad"]


class TestCosmicRayFlux:
    def test_positive(self):
        from qutip_geant4_bridge.radiation import cosmic_ray_flux
        for pt in ("proton", "muon", "neutron", "gamma"):
            assert cosmic_ray_flux(pt) > 0

    def test_altitude_scaling(self):
        from qutip_geant4_bridge.radiation import cosmic_ray_flux
        assert cosmic_ray_flux("proton", "mountain") > cosmic_ray_flux("proton", "sea_level")
        assert cosmic_ray_flux("proton", "underground") < cosmic_ray_flux("proton", "sea_level")


class TestLambdaRadiation:
    def test_positive(self):
        from qutip_geant4_bridge.radiation import compute_lambda_radiation
        lam = compute_lambda_radiation(1e-2, 100, 1.0, 300)
        assert lam > 0

    def test_zero_flux(self):
        from qutip_geant4_bridge.radiation import compute_lambda_radiation
        lam = compute_lambda_radiation(0, 100, 1.0, 300)
        assert lam == 0.0


# ============================================================
# wasm.py
# ============================================================

class TestWASMConfig:
    def test_default(self):
        from qutip_geant4_bridge.wasm import WASMConfig, generate_wasm_config
        cfg = WASMConfig()
        d = generate_wasm_config(cfg)
        assert d["beam"]["particle"] == "proton"
        assert d["beam"]["energy_mev"] == 100.0

    def test_custom(self):
        from qutip_geant4_bridge.wasm import WASMConfig, generate_wasm_config
        cfg = WASMConfig(beam_particle="gamma", beam_energy_mev=1.0, n_events=10)
        d = generate_wasm_config(cfg)
        assert d["beam"]["particle"] == "gamma"
        assert d["run"]["n_events"] == 10

    def test_json(self):
        from qutip_geant4_bridge.wasm import WASMConfig, wasm_config_json
        import json
        cfg = WASMConfig()
        s = wasm_config_json(cfg)
        d = json.loads(s)
        assert "physics" in d


# ============================================================
# Package-level imports
# ============================================================

class TestPackageImports:
    def test_particle(self):
        from qutip_geant4_bridge import Particle
        assert Particle is not None

    def test_material(self):
        from qutip_geant4_bridge import Material, MaterialDatabase
        db = MaterialDatabase()
        assert "water" in db

    def test_cross_sections(self):
        from qutip_geant4_bridge import compton_cross_section, total_photon_cross_section
        assert callable(compton_cross_section)

    def test_radiation(self):
        from qutip_geant4_bridge import radiation_damage_qubit, compute_lambda_radiation
        assert callable(radiation_damage_qubit)
