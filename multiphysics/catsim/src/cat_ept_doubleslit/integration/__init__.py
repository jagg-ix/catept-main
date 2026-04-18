"""Integration bridges.

This package contains optional bridges that integrate the CAT/EPT tooling with:
- EinsteinPy (geodesics / GR trajectories)
- i-PI (socket/driver workflows)
- OGRePy (symbolic metric definitions)

These modules are *optional* and use soft-imports.
"""

# These are optional. Import errors should not break the core package.
try:  # pragma: no cover
    from .einsteinpy_bridge import GeodesicToIPIBridge, SymbolicToDriverBridge  # noqa: F401
except Exception:  # pragma: no cover
    GeodesicToIPIBridge = SymbolicToDriverBridge = None  # type: ignore

try:  # pragma: no cover
    from .ogrepy_ipi_bridge import EntropicMetricIPIBridge, IPItoQuTiPBridge  # noqa: F401
except Exception:  # pragma: no cover
    EntropicMetricIPIBridge = IPItoQuTiPBridge = None  # type: ignore

try:  # pragma: no cover
    from .ogrepy_entropic_bridge import (  # noqa: F401
        EntropicTimeMap,
        reparametrize_first_order_system,
        reparametrize_second_order_geodesic,
        try_import_ogrepy,
    )
except Exception:  # pragma: no cover
    EntropicTimeMap = None  # type: ignore
    reparametrize_first_order_system = None  # type: ignore
    reparametrize_second_order_geodesic = None  # type: ignore
    try_import_ogrepy = None  # type: ignore

try:  # pragma: no cover
    from . import ipi_patch  # noqa: F401
except Exception:  # pragma: no cover
    ipi_patch = None  # type: ignore

try:  # pragma: no cover
    from .rebound_backend import ReboundRunConfig, has_rebound, run_rebound_with_entropic_clock  # noqa: F401
except Exception:  # pragma: no cover
    ReboundRunConfig = None  # type: ignore
    has_rebound = None  # type: ignore
    run_rebound_with_entropic_clock = None  # type: ignore
