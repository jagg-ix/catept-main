"""Backward-compatibility shim — real package lives at multiphysics/catsim_core/.

This stub ensures scripts that add ``simulations/catsim/src`` to sys.path
and then ``import catsim_core`` still work.  All names are re-exported from
the canonical location.
"""
import importlib as _il
import sys as _sys

_real = _il.import_module("multiphysics.catsim_core")
_sys.modules[__name__] = _real
