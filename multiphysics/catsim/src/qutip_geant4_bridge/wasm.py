"""WSM bridge configuration for browser-based Geant4.

Generates configuration for running Geant4 simulations in the browser
via WebAssembly (yaptide WASM build) with Pyodide Python support.

This module does NOT contain the actual WASM runtime — it produces
JSON configuration objects that the JavaScript bridge layer consumes.

Source
------
Based on ``webapp/js/geant4-bridge.js`` and ``webapp/js/wasm-bridge.js``.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from typing import Dict, List, Optional


@dataclass
class WASMConfig:
    """Configuration for the Geant4 WASM bridge.

    Parameters
    ----------
    physics_list : str
        Geant4 physics list name (e.g. ``"QGSP_BERT_HP"``).
    geometry_gdml : str, optional
        GDML geometry definition.
    beam_particle : str
        Primary particle type.
    beam_energy_mev : float
        Beam energy (MeV).
    n_events : int
        Number of events to simulate.
    scoring : list of str
        Scoring quantities (e.g. ``["dose", "fluence"]``).
    random_seed : int, optional
        Random seed for reproducibility.
    """

    physics_list: str = "QGSP_BERT_HP"
    geometry_gdml: Optional[str] = None
    beam_particle: str = "proton"
    beam_energy_mev: float = 100.0
    n_events: int = 1000
    scoring: List[str] = field(default_factory=lambda: ["dose", "fluence"])
    random_seed: Optional[int] = None


def generate_wasm_config(config: WASMConfig) -> Dict:
    """Generate JSON-serialisable config for the JS bridge.

    Parameters
    ----------
    config : WASMConfig
        Simulation configuration.

    Returns
    -------
    dict
        Configuration for ``Geant4Bridge.configure()``.

    Examples
    --------
    >>> cfg = WASMConfig(beam_energy_mev=200, n_events=500)
    >>> d = generate_wasm_config(cfg)
    >>> d["beam"]["energy_mev"]
    200.0
    """
    return {
        "physics": {
            "list": config.physics_list,
        },
        "geometry": {
            "gdml": config.geometry_gdml,
        },
        "beam": {
            "particle": config.beam_particle,
            "energy_mev": config.beam_energy_mev,
        },
        "run": {
            "n_events": config.n_events,
            "random_seed": config.random_seed,
        },
        "scoring": config.scoring,
    }


def wasm_config_json(config: WASMConfig) -> str:
    """Serialise config to JSON string.

    Parameters
    ----------
    config : WASMConfig

    Returns
    -------
    str
        JSON string.
    """
    return json.dumps(generate_wasm_config(config), indent=2)


# CDN URLs for the WASM assets (informational constants — actual
# resolution happens in the JavaScript bridge layer).
GEANT4_WASM_CDN = "https://cdn.example.com/geant4/geant4.wasm"
PHYSICS_DATA_CDN = "https://cdn.example.com/geant4/data/"
