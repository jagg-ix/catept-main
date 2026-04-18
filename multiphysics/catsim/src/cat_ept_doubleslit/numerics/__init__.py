"""Numerical utilities.

The project mixes coordinate-time evolution (``t``) with entropic proper time
(``tau_ent``). For explicit schemes, CFL-like bounds still apply; the practical
question is how to select a stable *coordinate-time* step while evolving in
``tau_ent``.

See :mod:`cat_ept_doubleslit.numerics.cfl_clock`.
"""
