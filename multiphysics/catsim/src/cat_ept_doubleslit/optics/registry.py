from __future__ import annotations

from typing import Dict, List, Optional, Type

from .numpy_backend import NumpyFraunhoferEngine

_BACKENDS: Dict[str, str] = {
    "numpy": "cat_ept_doubleslit.optics.numpy_backend:NumpyFraunhoferEngine",
    "hcipy": "cat_ept_doubleslit.optics.hcipy_backend:HCIPyEngine",
    "poppy": "cat_ept_doubleslit.optics.poppy_backend:POPPYEngine",
    "lightpipes": "cat_ept_doubleslit.optics.lightpipes_backend:LightPipesEngine",
    "diffractio": "cat_ept_doubleslit.optics.diffractio_backend:DiffractioEngine",
    "legume": "cat_ept_doubleslit.optics.legume_backend:LegumeEngine",
}


def _load(path: str):
    mod_path, cls_name = path.split(":")
    import importlib

    mod = importlib.import_module(mod_path)
    return getattr(mod, cls_name)


def list_backends(*, only_available: bool = False) -> List[str]:
    names = list(_BACKENDS.keys())
    if not only_available:
        return names
    out = []
    for n in names:
        try:
            create_engine(n)
            out.append(n)
        except Exception:
            continue
    return out


def create_engine(name: str = "numpy", **kwargs):
    name = str(name).lower()
    if name not in _BACKENDS:
        raise ValueError(f"Unknown optics backend: {name}")
    cls = _load(_BACKENDS[name])
    return cls(**kwargs)
