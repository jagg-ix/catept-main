#!/usr/bin/env python3
"""Phase 6.19 — SymPy CAT/EPT extension smoke test.

This phase validates that our opt-in SymPy helpers load and produce expected
symbolic objects:
  - τ_ent(t)=∫λ dt
  - naive reparameterization of a toy H(t)
  - an extended DimensionSystem containing an `information` base dimension

Status:
  PASS  : SymPy present and demo outputs produced.
  SKIP  : SymPy not present (still emits STATUS/summary).
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from catsim_core.symbolic.sympy_cat_ept import demo_symbolic_outputs, has_sympy


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str, required=True)
    args = ap.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    status = "PASS" if has_sympy() else "SKIP"
    produced = ["sympy_cat_ept_demo.txt", "summary.json", "STATUS.md"]
    details: dict = {
        "phase": "6.19",
        "status": status,
        "has_sympy": bool(has_sympy()),
        "produced": produced,
    }

    demo_path = out_dir / "sympy_cat_ept_demo.txt"
    if has_sympy():
        t, lam, omega, tau, H, H_tau, info_dim, ds = demo_symbolic_outputs()
        # Keep output stable and text-only.
        demo_path.write_text(
            "\n".join(
                [
                    "# SymPy CAT/EPT demo outputs",
                    f"t = {t}",
                    f"lambda = {lam}",
                    f"omega = {omega}",
                    f"tau_ent(t) = {tau}",
                    f"H(t) = {H}",
                    f"H(t->tau/lambda) = {H_tau}",
                    f"information_dim = {info_dim}",
                    f"dimension_system_base_dims = {ds.base_dims}",
                    "",
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        details.update(
            {
                "tau_ent": str(tau),
                "H_tau": str(H_tau),
                "information_dim": str(info_dim),
            }
        )
    else:
        demo_path.write_text(
            "# SymPy not installed; phase skipped.\n",
            encoding="utf-8",
        )

    (out_dir / "summary.json").write_text(json.dumps(details, indent=2) + "\n", encoding="utf-8")
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.19 — SymPy CAT/EPT extension\n\n" + f"Status: **{status}**\n\n" + json.dumps(details, indent=2) + "\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
