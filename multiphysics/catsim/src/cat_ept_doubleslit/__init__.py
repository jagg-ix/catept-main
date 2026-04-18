"""CAT/EPT double slit simulator.

Public API:
- double_slit_intensity
- visibility_factor
- default_flight_time
"""

from .models import double_slit_intensity, visibility_factor, default_flight_time

# Optional dataset I/O (SQLite) helpers
from .db import (
    Experiment,
    list_experiments,
    load_spectra,
    load_time_domain,
    spectra_to_wavelength_m,
    export_spectra_to_csv,
)

# Optional advanced modules (soft-import patterns live in their own subpackages)
from .clock.entropic_clock import EntropicClock, integrate_tau  # noqa: F401
from .metrics.redshift import MetricField, minkowski_metric, schwarzschild_metric  # noqa: F401

# Tight-binding integrations (optional)
from .tight_binding.pythtb_backend import has_pythtb  # noqa: F401

# adapters: experiment-harness entrypoints
from . import adapters  # noqa: F401
