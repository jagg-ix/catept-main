"""Unit contract check (standalone).

This script verifies that expressing the *same* time/frequency/rate quantities
in different units normalizes to the same base values.

Run:
  PYTHONPATH=src python scripts/unit_contract_check.py
"""

from __future__ import annotations

from catsim_core.units import (
    almost_equal,
    normalize_frequency,
    normalize_rate,
    normalize_time,
)


def main() -> int:
    # time
    t_a = normalize_time("500 fs")
    t_b = normalize_time(5e-13, unit="s")
    assert almost_equal(t_a.value, t_b.value), (t_a, t_b)

    # frequency
    f_a = normalize_frequency("227 THz")
    f_b = normalize_frequency(2.27e14, unit="Hz")
    assert almost_equal(f_a.value, f_b.value), (f_a, f_b)

    # rate
    r_a = normalize_rate("1e14 1/s")
    r_b = normalize_rate(1e-1, unit="1/fs")  # 0.1 / fs == 1e14 / s
    assert almost_equal(r_a.value, r_b.value), (r_a, r_b)

    print("PASS: unit contract ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
