"""Demo: use EinsteinPy to supply g00 and redshift sqrt(-g00).

Run:
  pip install -e '.[einsteinpy]'
  PYTHONPATH=src python examples/open_quantum/run_einsteinpy_redshift.py
"""

from __future__ import annotations

import numpy as np

from cat_ept_doubleslit.metrics.redshift import einsteinpy_metric_adapter


def main() -> None:
    try:
        from einsteinpy.metric import Schwarzschild  # type: ignore
    except Exception as e:
        raise ImportError("Install EinsteinPy: pip install -e '.[einsteinpy]'") from e

    # EinsteinPy typically uses geometric units; this is just a usage demo.
    M = 1.0
    sch = Schwarzschild(M=M)

    # Map (t_s, x_vec_m) -> (t, r, theta, phi). We treat x_vec_m as Cartesian.
    def coord_fn(t_s: float, x: np.ndarray):
        r = float(np.linalg.norm(x))
        theta = 0.5 * np.pi
        phi = 0.0
        return (float(t_s), r, theta, phi)

    metric = einsteinpy_metric_adapter(sch, coord_fn)
    x = np.array([0.0, 0.0, 10.0])
    print("g00=", metric.g00(0.0, x))
    print("redshift factor sqrt(-g00)=", metric.redshift_factor(0.0, x))


if __name__ == "__main__":
    main()
