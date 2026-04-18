#!/usr/bin/env python3
"""Run local NS LeanMillennium conformance bundle (Phase 5 policy gate)."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys
import time
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
BRIDGE_AUDITS_DIR = ROOT / "verification" / "bridge_audits"
DEFAULT_MAP = ROOT / "docs" / "workstation" / "NS_LEAN_MILLENNIUM_BENCHMARK_MAP.json"
DEFAULT_REPORT = BRIDGE_AUDITS_DIR / "ns_leanmillennium_conformance.json"
DEFAULT_OUTPUT = BRIDGE_AUDITS_DIR / "ns_leanmillennium_conformance_bundle.json"


def _run_step(name: str, cmd: list[str], cwd: Path) -> dict[str, Any]:
    start = time.time()
    proc = subprocess.run(
        cmd,
        cwd=str(cwd),
        check=False,
        capture_output=True,
        text=True,
    )
    elapsed = round(time.time() - start, 3)
    return {
        "name": name,
        "command": cmd,
        "cwd": str(cwd),
        "exit_code": int(proc.returncode),
        "status": "pass" if proc.returncode == 0 else "fail",
        "duration_sec": elapsed,
        "stdout": proc.stdout[-8000:],
        "stderr": proc.stderr[-8000:],
    }


def _load_report(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"Missing report artifact: {path}")
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"Expected JSON object in report artifact: {path}")
    return payload


def _evaluate_report(report: dict[str, Any]) -> dict[str, Any]:
    overall = report.get("overall", {}) if isinstance(report.get("overall"), dict) else {}
    symbol_map = (
        report.get("symbol_map_coverage", {})
        if isinstance(report.get("symbol_map_coverage"), dict)
        else {}
    )
    counts = report.get("counts", {}) if isinstance(report.get("counts"), dict) else {}

    hard_pass = bool(overall.get("hard_pass", False))
    missing_required = symbol_map.get("missing_required_ids", [])
    if not isinstance(missing_required, list):
        missing_required = []
    missing_count = int(counts.get("missing", 0))

    checks = {
        "report_hard_pass": hard_pass,
        "missing_required_ids_empty": len(missing_required) == 0,
        "missing_mapping_count_zero": missing_count == 0,
    }
    gate_pass = all(checks.values())
    status = "pass" if gate_pass else "fail"
    return {
        "status": status,
        "hard_pass": gate_pass,
        "checks": checks,
        "report_status": str(overall.get("status", "")),
        "warn_expected_for_axiom_backed_B_D": True,
        "policy_note": "B/D axiom-backed anchors remain warn-only by design",
    }


def run(map_path: Path, report_path: Path, output_path: Path, strict: bool) -> int:
    map_path = map_path.resolve()
    report_path = report_path.resolve()
    output_path = output_path.resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)

    py = sys.executable
    step = _run_step(
        "generate_ns_leanmillennium_conformance_report",
        [
            py,
            str(ROOT / "tools" / "verification" / "report_ns_leanmillennium_conformance.py"),
            "--map",
            str(map_path),
            "--output",
            str(report_path),
        ],
        ROOT,
    )

    report_eval: dict[str, Any]
    if step["exit_code"] == 0:
        report_eval = _evaluate_report(_load_report(report_path))
    else:
        report_eval = {
            "status": "fail",
            "hard_pass": False,
            "checks": {"report_generation_exit_zero": False},
            "report_status": "not_generated",
            "warn_expected_for_axiom_backed_B_D": True,
            "policy_note": "report generation failed",
        }

    payload = {
        "artifact_id": "ns_leanmillennium_conformance_bundle_v1",
        "strict_policy_gate": bool(strict),
        "status": report_eval.get("status", "fail"),
        "steps": [step],
        "policy_evaluation": report_eval,
        "outputs": {
            "benchmark_map": str(map_path),
            "conformance_report": str(report_path),
        },
    }
    output_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    print(f"status={payload['status']}")
    print(f"hard_pass={payload['policy_evaluation']['hard_pass']}")
    print(f"output={output_path}")

    if strict and not bool(payload["policy_evaluation"]["hard_pass"]):
        return 2
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--map", type=Path, default=DEFAULT_MAP)
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument(
        "--no-strict-policy-gate",
        action="store_true",
        default=False,
        help="Do not fail non-zero when policy gate fails.",
    )
    args = parser.parse_args()
    return run(
        map_path=args.map,
        report_path=args.report,
        output_path=args.output,
        strict=not bool(args.no_strict_policy_gate),
    )


if __name__ == "__main__":
    raise SystemExit(main())
