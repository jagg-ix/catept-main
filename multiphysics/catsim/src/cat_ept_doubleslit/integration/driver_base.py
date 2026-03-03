"""Shared driver interface used by integration bridges.

This repo does **not** ship i-PI itself; it only provides glue code.

If you want a fully working socket client, either:
- use i-PI's built-in python driver infrastructure (`i-pi-py_driver`), or
- adapt this interface into your own i-PI socket client.

The bridges here generate subclasses that implement `compute_potential(positions)`.
"""

from __future__ import annotations

import abc
import numpy as np
from typing import Dict, Tuple


class EntropicDriver(abc.ABC):
    """Abstract base: energy/forces + optional extras."""

    @abc.abstractmethod
    def compute_potential(self, positions: np.ndarray) -> Tuple[float, np.ndarray, np.ndarray, Dict]:
        """Return (energy, forces, virial(3x3), extras-dict)."""
        raise NotImplementedError
