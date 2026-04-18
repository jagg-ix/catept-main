"""Backward-compatibility shim — real package lives at multiphysics/qf_qutip_dsl/.

This stub ensures scripts that add ``simulations/catsim/src`` to sys.path
and then ``import qf_qutip_dsl`` still work.  All names are re-exported from
the canonical location.
"""
import importlib as _il
import sys as _sys

_real = _il.import_module("multiphysics.qf_qutip_dsl")
_sys.modules[__name__] = _real
