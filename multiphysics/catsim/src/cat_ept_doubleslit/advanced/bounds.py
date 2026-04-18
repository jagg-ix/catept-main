from __future__ import annotations

import math


def info_visibility_bound_pass(
    visibility: float,
    delta_I_bits: float,
    V0: float = 1.0,
) -> bool:
    """Check a conservative information–visibility style bound.

    We implement the dimensionless inequality in the paper-facing form:

        -ln(V/V0) >= 0.5 * DeltaI_bits

    where DeltaI_bits is measured in bits.

    This is a proxy check: in real experiments DeltaI_bits must come from an
    independently defined information accounting model (detector/environment).
    """
    if visibility <= 0 or V0 <= 0:
        return False
    lhs = -math.log(max(visibility, 1e-300) / V0)
    rhs = 0.5 * max(delta_I_bits, 0.0)
    return lhs + 1e-12 >= rhs


def delta_I_bits_proxy(beta_eff_inv_s: float, slit_separation_fs: float) -> float:
    """Proxy for Delta I in bits.

    We use a minimal, dimensionally sensible proxy:

        DeltaI_bits = beta_eff * |S| * 1e-15 / ln 2

    i.e. a collision/relaxation rate integrated over the time separation.
    This is NOT a first-principles derivation; it is a conservative place-holder
    that produces a falsifiable inequality check once the mapping is improved.
    """
    if not math.isfinite(beta_eff_inv_s) or beta_eff_inv_s <= 0:
        return float("nan")
    return float(beta_eff_inv_s * abs(slit_separation_fs) * 1e-15 / math.log(2.0))


def delta_I_bits_from_distinguishability(D: float) -> float:
    """Estimate information in bits from a binary-path distinguishability proxy.

    We interpret D \in [0,1] as a which-path distinguishability and map it to a
    binary classification advantage p=(1+D)/2. The information gain (in bits)
    relative to a fair coin is:

        DeltaI_bits = 1 - H2(p)

    where H2 is the binary entropy. This is still a *proxy* (it assumes a
    binary channel and symmetric priors), but it is anchored to an observable
    (e.g. red/blue asymmetry) rather than a free rate model.
    """
    if not math.isfinite(D):
        return float("nan")
    D = max(0.0, min(1.0, abs(D)))
    p = 0.5 * (1.0 + D)
    # binary entropy in bits
    if p <= 0.0 or p >= 1.0:
        H2 = 0.0
    else:
        H2 = -(p * math.log(p, 2) + (1.0 - p) * math.log(1.0 - p, 2))
    return float(1.0 - H2)


def delta_I_bits_from_gkls_rate(lambda_ent_inv_s: float, window_fs: float) -> float:
    """GKLS-style *rate* proxy for information in bits.

    Motivation:
      In GKLS/Lindblad forms, a natural non-negative scalar "dissipation rate"
      is \(\sum_j \mathrm{Tr}(L_j^\dagger L_j \rho)\). In the CAT/EPT papers and
      repo pipeline, a fitted scalar \(\lambda\) ("entropic rate") plays an
      analogous role.

    This function is a conservative proxy that turns the fitted \(\lambda\) into
    an information-like budget over a chosen time window:

        DeltaI_bits = lambda * T / ln 2

    where \(T\) is a user-defined window in seconds.

    Notes:
      - This is *not* a full information accounting derivation; it is the
        minimal bridge needed to tighten Phase 6.3 beyond the purely heuristic
        beta-based proxy.
      - For a paper-faithful estimator, replace this with a measurement-path
        model that defines the environment record states and computes \(\Delta I\)
        from those records.
    """
    if not math.isfinite(lambda_ent_inv_s) or lambda_ent_inv_s <= 0:
        return float("nan")
    if not math.isfinite(window_fs) or window_fs <= 0:
        return float("nan")
    T = abs(window_fs) * 1e-15
    return float(lambda_ent_inv_s * T / math.log(2.0))
