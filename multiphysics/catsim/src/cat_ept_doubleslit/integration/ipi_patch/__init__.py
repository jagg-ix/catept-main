"""Vendored i-PI entropic-time patch artifacts.

This subpackage exists so the repo can:
- keep the original patch for provenance
- reuse the entropic socket driver logic in a stable import path
- ship the new i-PI modules as reference (they are meant to live inside i-PI)

"""

__all__ = [
    "EntropicDriver",
    "SGIDriver",
    "BlackHoleDriver",
    "ENZDriver",
]

# Soft-import so the base package works without i-PI installed.
try:  # pragma: no cover
    from .entropic_drivers import EntropicDriver, SGIDriver, BlackHoleDriver, ENZDriver
except Exception:  # pragma: no cover
    EntropicDriver = SGIDriver = BlackHoleDriver = ENZDriver = None  # type: ignore
