"""Optional check: SymPy CAT/EPT extension smoke test.

This repo does not depend on SymPy at runtime for the main Tirole pipeline.
If SymPy is not installed, this check reports SKIP and exits 0.
"""

from __future__ import annotations

import json
import os
from datetime import datetime


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def main() -> int:
    out_dir = os.environ.get("SYMPY_EXT_OUT", "PAPER_TABLES/ADVANCED/SYMPY_EXT")
    ensure_dir(out_dir)
    summary_path = os.path.join(out_dir, "summary.json")

    payload = {
        "ts": datetime.utcnow().isoformat() + "Z",
        "status": "SKIP",
        "sympy_installed": False,
    }

    try:
        import sympy as sp  # noqa: F401

        from catsim_core.sympy_ext.entropic_time import demo_solution_constant_lambda
        from catsim_core.sympy_ext.units_information import make_lmti_system

        payload["sympy_installed"] = True
        payload["status"] = "PASS"
        payload["demo_solution"] = str(demo_solution_constant_lambda())

        system, info_dim = make_lmti_system()
        payload["info_dimension"] = str(info_dim)
        payload["system_base_dims"] = [str(d) for d in system.base_dims]
    except Exception as e:
        # If SymPy isn't installed, keep SKIP; if installed but failed, mark FAIL.
        msg = f"{type(e).__name__}: {e}"
        if payload.get("sympy_installed", False):
            payload["status"] = "FAIL"
        payload["error"] = msg

    with open(summary_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, sort_keys=True)

    print(json.dumps(payload, indent=2, sort_keys=True))
    return 0 if payload["status"] in ("PASS", "SKIP") else 2


if __name__ == "__main__":
    raise SystemExit(main())
