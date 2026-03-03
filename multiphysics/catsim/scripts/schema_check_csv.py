"""CSV schema checker.

Primarily used to enforce the `next.md` discipline for quantum backends:
the output schema must include coordinate time, entropic proper time, and
lambda (or documented equivalents).

Usage:
  python scripts/schema_check_csv.py path/to/file.csv
"""

from __future__ import annotations

import csv
import sys

from catsim_core.gates.output_schema import gate_has_time_tau_lambda


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Usage: python scripts/schema_check_csv.py <file.csv>")
        return 2
    path = argv[1]
    with open(path, "r", newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
    gate = gate_has_time_tau_lambda(header)
    if not gate.passed:
        print(f"FAIL: {gate.name}")
        print(gate.details)
        return 2
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
