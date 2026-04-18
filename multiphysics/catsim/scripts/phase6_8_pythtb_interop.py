"""Phase 6.8: pythtb interoperability (optional).

This stage provides a **tight-binding Hamiltonian** generator that can:

- consume catsim CAT/EPT timeline contracts (t_s, tau_ent_s, lambda_s_inv)
- optionally be driven by Paper3 phi(t) profiles (lambda = dphi/dt)
- optionally hand the Hamiltonian timeline to QuTiP for evolution

It follows the repo's standard optional-backend policy:
- if pythtb is missing: SKIP safely + write STATUS artifacts
"""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess


def _auto_find_phi_profile() -> str | None:
    candidates = [
        "PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES/profiles",
        "PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES",
    ]
    for base in candidates:
        p = Path(base)
        if not p.exists() or not p.is_dir():
            continue
        matches = sorted(p.glob("**/tensor_profile_*.csv"))
        if matches:
            return str(matches[0])
    return None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--enable_qutip", action="store_true")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    phi_path = _auto_find_phi_profile()
    cmd = [
        "python",
        "scripts/pythtb_interop_demo.py",
        "--out",
        str(out),
    ]
    if phi_path:
        cmd += ["--phi_profile_csv", phi_path]
    if args.enable_qutip:
        cmd += ["--enable_qutip"]

    return subprocess.call(cmd)


if __name__ == "__main__":
    raise SystemExit(main())
