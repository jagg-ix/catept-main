"""Thermodynamics integration layer.

This package provides optional bridges to thermodynamics engines (e.g.
pycalphad, ThermoPack) while reusing the repo's entropic proper-time
abstractions (SpacetimeCoupler + CFLClock + EntropicTimeContract).

All engines are **optional**; missing dependencies yield SKIP status in
phase scripts.
"""

from .thermo_bridge import ThermoCATBridge, ThermoResult
