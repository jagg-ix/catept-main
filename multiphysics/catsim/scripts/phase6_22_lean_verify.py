"""Phase 6.22 - Lean / PhysLean verification harness (optional).

This phase is intentionally *non-blocking* unless Lean tooling is installed.
It exports a small verification spec (JSON) that mirrors the repo's entropic
time contract and then attempts to run `lake build` in ./lean.

Outputs:
  - STATUS.md
  - summary.json
  - lean_verification_spec.json

Design constraints:
  - Must not break paper_all when Lean is absent.
  - Must reuse existing entropic time abstractions (contract + CFLClock) by
    exporting the already-generated contract CSV when available.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Optional


@dataclass
class PhaseResult:
    status: str  # PASS | SKIP | FAIL
    reason: str
    details: Dict[str, Any]


def _read_entropic_contract_csv(repo_root: Path) -> Optional[Path]:
    """Return a path to the most recent entropic_time_contract.csv if present."""
    candidates = [
        repo_root / "PAPER_TABLES" / "ADVANCED" / "OPTICS_INTEROP" / "entropic_time_contract.csv",
        repo_root / "PAPER_TABLES" / "ADVANCED" / "WEAK_FIELD_METRIC" / "entropic_time_contract.csv",
    ]
    for p in candidates:
        if p.exists():
            return p
    return None


def _run(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        env={**os.environ, "NO_COLOR": "1"},
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="Output directory under PAPER_TABLES")
    args = ap.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    out_dir = repo_root / args.out
    out_dir.mkdir(parents=True, exist_ok=True)

    spec: Dict[str, Any] = {
        "phase": "6.22",
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "intent": "Optional Lean/PhysLean verification harness",
        "contracts": {
            "entropic_time": {
                "required_columns": ["t_s", "tau_ent_s", "lambda_eff_s_inv"],
                "notes": "Contract is produced by existing phases; Lean harness consumes it for proof targets.",
            }
        },
        "theorems_planned": [
            "tau_ent_monotone_for_nonneg_lambda",
            "cfl_step_respects_tau_ent_reparam",
            "weak_field_redshift_is_positive_under_small_phi",
        ],
        "lean_project_path": "./lean",
    }

    contract_csv = _read_entropic_contract_csv(repo_root)
    if contract_csv is not None:
        spec["contracts"]["entropic_time"]["example_csv"] = str(contract_csv.relative_to(repo_root))

    (out_dir / "lean_verification_spec.json").write_text(json.dumps(spec, indent=2), encoding="utf-8")

    lake = shutil.which("lake")
    elan = shutil.which("elan")
    lean_dir = repo_root / "lean"

    if lake is None or not lean_dir.exists():
        res = PhaseResult(
            status="SKIP",
            reason="Lean tooling not installed (lake missing) or ./lean not present.",
            details={"lake_found": bool(lake), "lean_dir_exists": lean_dir.exists(), "elan_found": bool(elan)},
        )
    else:
        # Try to build. This may still fail if mathlib/PhysLean deps are not fetched.
        cp = _run([lake, "build"], cwd=lean_dir)
        if cp.returncode == 0:
            res = PhaseResult(
                status="PASS",
                reason="lake build succeeded",
                details={"stdout_tail": cp.stdout[-2000:], "stderr_tail": cp.stderr[-2000:]},
            )
        else:
            res = PhaseResult(
                status="FAIL",
                reason="lake build failed (deps may be missing; see stderr_tail)",
                details={"stdout_tail": cp.stdout[-2000:], "stderr_tail": cp.stderr[-2000:]},
            )

    summary = {
        "phase": "6.22",
        "status": res.status,
        "reason": res.reason,
        "details": res.details,
        "outputs": [
            "lean_verification_spec.json",
            "STATUS.md",
            "summary.json",
        ],
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

    status_md = [
        "# Phase 6.22 - Lean verification (optional)",
        "",
        f"**STATUS:** {res.status}",
        "",
        f"**Reason:** {res.reason}",
        "",
        "## Notes",
        "- This phase is optional and should not block `make paper_all` when Lean is absent.",
        "- The verification spec mirrors the repo's entropic time contract and is designed to be consumed by a Lean/PhysLean project in `./lean`.",
    ]
    (out_dir / "STATUS.md").write_text("\n".join(status_md) + "\n", encoding="utf-8")

    print(json.dumps(summary, indent=2))
    return 0 if res.status in ("PASS", "SKIP") else 1


if __name__ == "__main__":
    raise SystemExit(main())
