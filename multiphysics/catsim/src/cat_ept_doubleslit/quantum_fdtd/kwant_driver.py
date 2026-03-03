"""Kwant-based scattering setup (optional).

Implements the step-potential chain model outlined in 23.md.

Requires kwant.
"""

from __future__ import annotations

try:
    import kwant

    KWANT_AVAILABLE = True
except Exception:
    kwant = None  # type: ignore
    KWANT_AVAILABLE = False


def make_step_system(L_sites: int = 100, U0: float = 0.2):
    """Build a 1D chain with a step potential and two leads.

    Args:
        L_sites: number of sites
        U0: onsite energy after the step (same units used for kwant energy)

    Returns:
        finalized Kwant system
    """
    if not KWANT_AVAILABLE:
        raise ImportError("Kwant is required (pip install '.[kwant]')")

    lat = kwant.lattice.chain()
    sys = kwant.Builder()

    for i in range(int(L_sites)):
        onsite = float(U0) if i > int(L_sites) // 2 else 0.0
        sys[lat(i)] = onsite
        if i > 0:
            sys[lat(i), lat(i - 1)] = -1.0

    lead = kwant.Builder(kwant.TranslationalSymmetry([-1]))
    lead[lat(0)] = 0.0
    lead[lat(0), lat(-1)] = -1.0

    sys.attach_lead(lead)
    sys.attach_lead(lead.reversed())

    return sys.finalized()
