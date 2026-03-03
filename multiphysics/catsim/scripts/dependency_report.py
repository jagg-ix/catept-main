"""Dependency report for Catsim.

Prints which optional backends are available and the versions found.

Used to make runs reproducible across environments (UI + CI).
"""

from __future__ import annotations

import importlib
import json
import platform
from dataclasses import dataclass, asdict
from typing import Optional, Dict


OPTIONAL = [
    "numpy",
    "pandas",
    "matplotlib",
    "streamlit",
    "qutip",
    "astropy",
    "einsteinpy",
    "sympy",
    # material backends
    "pymatgen",
    "pyscf",
    # EM solver
    "meep",
]

def _try_import(name: str):
    try:
        mod = importlib.import_module(name)
        ver = getattr(mod, "__version__", None) or getattr(mod, "version", None)
        return {"present": True, "version": str(ver) if ver is not None else None}
    except Exception as e:
        return {"present": False, "error": str(e)}

def main():
    rep: Dict[str, object] = {
        "python": platform.python_version(),
        "platform": platform.platform(),
        "packages": {name: _try_import(name) for name in OPTIONAL},
    }
    print(json.dumps(rep, indent=2, sort_keys=True))

if __name__ == "__main__":
    main()

# Note: Kerr redshift factor is implemented analytically (no EinsteinPy required), but EinsteinPy can still be used for tensor checks.
