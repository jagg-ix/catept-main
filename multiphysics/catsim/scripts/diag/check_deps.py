from __future__ import annotations
"""Dependency checker for runtime backends.

Use cases:
- CI / reproducibility: fail fast if QuTiP / EinsteinPy are not installed.
- Local runs: print a clear matrix of which backends will be available.

Examples:
  python scripts/diag/check_deps.py
  python scripts/diag/check_deps.py --require qutip einsteinpy
  python scripts/diag/check_deps.py --json-out out.json --require qutip
"""
import argparse
import importlib
import json
from pathlib import Path
from typing import Dict, Any, List, Tuple

DEPS = [
    ("qutip", "QuTiP (open quantum dynamics)"),
    ("einsteinpy", "EinsteinPy (GR metrics / tensor utilities)"),
    ("astropy", "Astropy (units/constants/time)"),
    ("sympy", "SymPy (symbolic algebra)"),
]

OPTIONAL_HINTS = {
    "OGRePy": "OGRePy is a repo-local package; availability depends on PYTHONPATH/import path.",
}

def try_import(mod: str) -> Tuple[bool, str]:
    try:
        importlib.import_module(mod)
        return True, ""
    except Exception as e:
        return False, f"{type(e).__name__}: {e}"

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--require", nargs="*", default=[], help="List of module names that must be importable (e.g., qutip einsteinpy).")
    ap.add_argument("--json-out", default="", help="Optional: write JSON report to this path.")
    args=ap.parse_args()

    report: Dict[str, Any] = {"deps": {}, "required": list(args.require), "status": "ok", "issues": []}

    for mod, desc in DEPS:
        ok, err = try_import(mod)
        report["deps"][mod] = {"ok": bool(ok), "desc": desc, "error": err}

    # Check required
    for r in args.require:
        ok, err = try_import(r)
        if not ok:
            report["status"] = "fail"
            report["issues"].append(f"missing required dependency: {r} ({err})")

    if args.json_out:
        out=Path(args.json_out)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")

    # Human output
    print("Dependency availability:")
    for mod, desc in DEPS:
        d=report["deps"][mod]
        mark="OK " if d["ok"] else "MISSING"
        print(f" - {mark:7} {mod:10} :: {desc}")
        if not d["ok"]:
            print(f"           {d['error']}")
    if report["issues"]:
        print("\nREQUIRED CHECKS FAILED:")
        for i in report["issues"]:
            print(" -", i)

    raise SystemExit(0 if report["status"]=="ok" else 2)

if __name__=="__main__":
    main()
