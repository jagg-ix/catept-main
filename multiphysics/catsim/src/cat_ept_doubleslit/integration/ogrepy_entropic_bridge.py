"""OGRePy integration for CAT/EPT (plain-Python friendly).

This module is the missing piece between:
- your CAT/EPT runtime objects (entropic proper time, complex action weights)
- GR tensor computations (metric, connection, curvature, geodesics)
- downstream bridges (EinsteinPy, i-PI drivers)

Design goals
------------
1) **No notebook requirement**: OGRePy upstream is designed to render rich
   Markdown/TeX in Jupyter. For a CLI simulator + i-PI driver workflow, that
   becomes a liability. We therefore ship a helper script:
     `tools/patch_ogrepy_no_ipython.py`
   which patches OGRePy's `_core.py` to avoid importing IPython.

2) **Entropic proper time as a curve parameter**: OGRePy already supports
   changing the curve parameter. CAT/EPT introduces:

      tau_ent(t) = \int_0^t lambda(t') dt' ,   with lambda >= 0

   If OGRePy geodesics are produced w.r.t. a parameter `s`, we can set `s=tau_ent`
   and express derivatives using:

      d/dtau_ent = (1/lambda) d/dt

   In code, we provide symbolic helpers that transform curve ODEs.

3) **Minimal assumptions**: we don't require a specific metric ansatz here.
   You can feed in any OGRePy metric (or your own EntropicMetric class).

"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Iterable, Optional, Sequence, Tuple

import numpy as np


try:
    import sympy as sp
except Exception as e:  # pragma: no cover
    sp = None  # type: ignore


def require_sympy() -> None:
    if sp is None:
        raise ImportError("sympy is required for OGRePy symbolic integration")


def try_import_ogrepy():
    """Import OGRePy with a helpful error message."""
    try:
        import OGRePy as og  # type: ignore
        return og
    except Exception as e:  # pragma: no cover
        raise ImportError(
            "OGRePy could not be imported.\n\n"
            "If this is due to a missing IPython/Jupyter dependency, patch OGRePy for\n"
            "plain Python execution by running:\n\n"
            "  python tools/patch_ogrepy_no_ipython.py --installed\n\n"
            "Or patch a git checkout:\n\n"
            "  python tools/patch_ogrepy_no_ipython.py /path/to/OGRePy\n\n"
            f"Original error: {type(e).__name__}: {e}"
        )


@dataclass(frozen=True)
class EntropicTimeMap:
    """Mapping between coordinate time `t` and entropic proper time `tau_ent`.

    Parameters
    ----------
    lam : sympy expression or callable
        Entropy production rate lambda(t, x, ...) >= 0.

    Notes
    -----
    In CAT/EPT, tau_ent is monotone when lambda >= 0.
    """

    lam: "sp.Expr"

    def d_dtau_dt(self) -> "sp.Expr":
        """Return dtau/dt = lambda."""
        require_sympy()
        return self.lam

    def d_dt_dtau(self) -> "sp.Expr":
        """Return dt/dtau = 1/lambda."""
        require_sympy()
        return 1 / self.lam


def reparametrize_first_order_system(
    t: "sp.Symbol",
    y: Sequence["sp.Function"],
    rhs_dt: Sequence["sp.Expr"],
    time_map: EntropicTimeMap,
) -> Tuple[Sequence["sp.Function"], Sequence["sp.Expr"]]:
    """Convert dy/dt = f(t,y) into dy/dtau = f(t,y)/lambda.

    This is the canonical software migration step:
        dt -> dtau = lambda dt

    Returns
    -------
    (y, rhs_dtau)
    """
    require_sympy()
    lam = time_map.d_dtau_dt()
    rhs_dtau = [sp.simplify(expr / lam) for expr in rhs_dt]
    return y, rhs_dtau


def reparametrize_second_order_geodesic(
    t: "sp.Symbol",
    x: Sequence["sp.Function"],
    ddx_dt2: Sequence["sp.Expr"],
    time_map: EntropicTimeMap,
) -> Sequence["sp.Expr"]:
    """Reparameterize second-order ODEs x''(t) = F(t,x,x') to tau-ent.

    If tau = \int lambda dt then:
        d/dt = lambda d/dtau
        d^2/dt^2 = lambda^2 d^2/dtau^2 + (dlambda/dt) d/dtau

    Therefore:
        d^2 x/dtau^2 = (1/lambda^2) ( F - (dlambda/dt) dx/dtau )

    This is the *software-level* replacement of "coordinate parametric time" with
    entropic proper time.

    Notes
    -----
    - This assumes `lambda` may depend on t and x (and possibly x').
      If lambda depends on x', treat dlambda/dt via total derivative.
      Here we implement the common case lambda=lambda(t, x), where:
          dlambda/dt = ∂_t lambda + Σ_i ∂_{x_i} lambda * dx_i/dt
      and dx_i/dt = lambda * dx_i/dtau.

    Returns
    -------
    ddx_dtau2 : list of sympy expressions for d^2 x / d tau^2.
    """
    require_sympy()

    lam = time_map.lam

    # Build symbols for velocities w.r.t. tau: u_i = dx_i/dtau
    u = [sp.Function(f"u_{i}")(t) for i in range(len(x))]

    # Total derivative of lambda w.r.t. coordinate time t.
    # dlambda/dt = ∂_t lam + Σ ∂_{x_i} lam * dx_i/dt
    dlam_dt = sp.diff(lam, t)
    for xi, ui in zip(x, u):
        dlam_dt += sp.diff(lam, xi(t)) * (lam * ui)
    dlam_dt = sp.simplify(dlam_dt)

    # Reparameterized acceleration
    ddx_dtau2 = []
    for Fi, ui in zip(ddx_dt2, u):
        expr = (Fi - dlam_dt * ui) / (lam**2)
        ddx_dtau2.append(sp.simplify(expr))

    return ddx_dtau2


def complex_action_weight(
    S_R: "sp.Expr",
    S_I: "sp.Expr",
    hbar: "sp.Expr" = None,
) -> "sp.Expr":
    """Return the CAT/EPT path-integral weight exp(i S_R/ħ - S_I/ħ)."""
    require_sympy()
    if hbar is None:
        hbar = sp.Symbol("hbar", positive=True, real=True)
    return sp.exp(sp.I * S_R / hbar - S_I / hbar)


# ----------------------------
# Practical glue for simulator
# ----------------------------

def ogrepy_metric_from_components(coords: Sequence["sp.Symbol"], g_matrix: "sp.Matrix"):
    """Construct an OGRePy metric from a SymPy matrix.

    This helper keeps OGRePy usage centralized, so the rest of the simulator can
    stay independent of OGRePy.
    """
    og = try_import_ogrepy()
    require_sympy()

    # OGRePy expects a coordinate system object.
    C = og.Coordinates(list(coords))
    g = og.Metric(C, g_matrix)
    return g
