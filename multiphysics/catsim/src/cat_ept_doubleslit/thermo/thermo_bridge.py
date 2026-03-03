"""Unified thermodynamics bridge (optional engines).

Design goals (repo invariants):
  - No baseline disruption: If engines are unavailable, return SKIP.
  - Reuse entropic-time abstractions: callers pass `SpacetimeCoupler` and
    use the same time grids (CFLClock) as other phases.
  - Single dispatch point: avoid per-backend duplication.

Engines:
  - "calphad": pycalphad (solid-state/CALPHAD); good default for ENZ/ITO-like
    solid materials.
  - "thermopack": ThermoPack (fluid EOS); useful for gas/plasma extensions.

This bridge intentionally keeps the API **scalar** (entropy, chemical
potential proxy, etc.) so it composes cleanly with other modules.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional

import numpy as np


@dataclass(frozen=True)
class ThermoResult:
    t_s: float
    temperature_K: float
    pressure_Pa: float
    entropy_J_per_K: float
    # Optional: allow engines to report other diagnostics
    meta: Dict[str, Any]


def _try_import_pycalphad():
    try:
        import pycalphad  # noqa: F401
        return True
    except Exception:
        return False


def _try_import_thermopack():
    # ThermoPack Python bindings are not standardized across distros.
    # We keep this permissive.
    try:
        import thermopack  # noqa: F401
        return True
    except Exception:
        try:
            import thermo_pack  # noqa: F401
            return True
        except Exception:
            return False


class ThermoCATBridge:
    """Dispatch wrapper for optional thermodynamics engines."""

    def __init__(
        self,
        *,
        backend: str = "calphad",
        cat_ept_mode: bool = False,
        engine_kwargs: Optional[Dict[str, Any]] = None,
    ) -> None:
        self.backend = str(backend).strip().lower()
        self.cat_ept_mode = bool(cat_ept_mode)
        self.engine_kwargs = dict(engine_kwargs or {})

        self._engine = None
        self._engine_kind = None

        if self.backend == "calphad":
            if _try_import_pycalphad():
                self._engine_kind = "calphad"
                self._engine = self._init_calphad(self.engine_kwargs)
        elif self.backend == "thermopack":
            if _try_import_thermopack():
                self._engine_kind = "thermopack"
                self._engine = self._init_thermopack(self.engine_kwargs)
        else:
            raise ValueError(f"Unknown thermo backend: {backend}")

    @property
    def available(self) -> bool:
        return self._engine is not None

    def _init_calphad(self, kwargs: Dict[str, Any]) -> Any:
        # Keep init minimal; phase scripts can supply a database, comps, etc.
        # We don't want heavy disk I/O by default.
        return {"kwargs": kwargs}

    def _init_thermopack(self, kwargs: Dict[str, Any]) -> Any:
        return {"kwargs": kwargs}

    def entropy(self, *, temperature_K: float, pressure_Pa: float, t_s: float) -> ThermoResult:
        """Compute a scalar entropy value.

        If engine isn't available, raise RuntimeError so callers can mark SKIP.
        """
        if not self.available:
            raise RuntimeError("Thermo engine not available")

        T = float(temperature_K)
        P = float(pressure_Pa)
        t = float(t_s)

        if self._engine_kind == "calphad":
            # Placeholder scalar proxy: in real runs, user supplies CALPHAD database
            # and composition; here we return a simple monotone function.
            # This keeps the bridge testable without shipping databases.
            s = 1.0e2 * np.log(max(T, 1.0))  # J/K proxy
            meta = {"proxy": "calphad_entropy_logT"}
            return ThermoResult(t_s=t, temperature_K=T, pressure_Pa=P, entropy_J_per_K=float(s), meta=meta)

        if self._engine_kind == "thermopack":
            s = 8.314 * np.log(max(T, 1.0))  # ideal-gas-like proxy (J/K/mol); treated as proxy
            meta = {"proxy": "thermopack_entropy_logT"}
            return ThermoResult(t_s=t, temperature_K=T, pressure_Pa=P, entropy_J_per_K=float(s), meta=meta)

        raise RuntimeError("Unknown engine kind")

