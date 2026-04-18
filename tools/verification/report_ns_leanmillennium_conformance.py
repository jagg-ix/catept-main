#!/usr/bin/env python3
"""Emit machine-auditable NS LeanMillennium statement-conformance artifact."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MAP_PATH = ROOT / "docs" / "workstation" / "NS_LEAN_MILLENNIUM_BENCHMARK_MAP.json"
DEFAULT_OUTPUT_PATH = ROOT / "verification" / "bridge_audits" / "ns_leanmillennium_conformance.json"

REQUIRED_IDS = ("A", "B", "C", "D", "DISJ")
THEOREM_STATUSES = {"mapped_theorem_bridge", "mapped_theorem_equivalent"}
AXIOM_BACKED_STATUSES = {"mapped_axiom_backed_theorem_bridge"}


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def _load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"Missing benchmark map: {path}")
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"Expected JSON object: {path}")
    return payload


def _git_head_short() -> str:
    try:
        out = subprocess.check_output(
            ["git", "rev-parse", "--short=12", "HEAD"],
            cwd=ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except Exception:
        return "unknown"
    return out or "unknown"


def _normalize_status(raw: str) -> str:
    if raw in THEOREM_STATUSES:
        return "theorem"
    if raw in AXIOM_BACKED_STATUSES:
        return "axiom-backed"
    return "missing"


def build_report(map_payload: dict[str, Any], map_path: Path) -> dict[str, Any]:
    upstream = map_payload.get("upstream", {})
    local = map_payload.get("local", {})
    entries = map_payload.get("entries", [])
    if not isinstance(entries, list):
        entries = []

    by_id: dict[str, dict[str, Any]] = {}
    for entry in entries:
        if isinstance(entry, dict):
            key = str(entry.get("id", "")).strip()
            if key:
                by_id[key] = entry

    missing_ids = [symbol_id for symbol_id in REQUIRED_IDS if symbol_id not in by_id]
    mappings: list[dict[str, Any]] = []
    theorem_count = 0
    axiom_backed_count = 0
    warnings: list[dict[str, str]] = []

    for symbol_id in REQUIRED_IDS:
        entry = by_id.get(symbol_id)
        if not entry:
            mappings.append(
                {
                    "id": symbol_id,
                    "mapping_status_raw": "missing",
                    "mapping_status": "missing",
                    "gate": "fail",
                    "reason": "symbol_id_not_present_in_map",
                }
            )
            continue

        raw_status = str(entry.get("mapping_status", "")).strip()
        normalized = _normalize_status(raw_status)
        gate = "pass"
        reason = ""
        if normalized == "missing":
            gate = "fail"
            reason = "mapping_status_not_recognized_or_missing"
        elif normalized == "axiom-backed":
            gate = "warn"
            reason = "explicit_axiom_anchor_allowed_warn"
            axiom_backed_count += 1
            if symbol_id in {"B", "D"}:
                warnings.append(
                    {
                        "id": symbol_id,
                        "type": "axiom_backed_endpoint",
                        "message": "B/D endpoint remains axiom-backed by declared policy",
                    }
                )
        else:
            theorem_count += 1

        mappings.append(
            {
                "id": symbol_id,
                "external_symbol": str(entry.get("external_symbol", "")),
                "local_symbol": str(entry.get("local_symbol", "")),
                "local_bridge_symbol": str(entry.get("local_bridge_symbol", "")),
                "mapping_status_raw": raw_status,
                "mapping_status": normalized,
                "local_proof_basis": str(entry.get("local_proof_basis", "")),
                "gate": gate,
                "reason": reason,
            }
        )

    upstream_repo = str(upstream.get("repo_url", "")).strip()
    upstream_commit = str(upstream.get("commit", "")).strip()
    local_commit = str(local.get("commit", "")).strip() or _git_head_short()

    hard_fail_reasons: list[str] = []
    if not upstream_commit:
        hard_fail_reasons.append("upstream_commit_missing")
    if missing_ids:
        hard_fail_reasons.append("required_ids_missing_from_map")
    if any(item["mapping_status"] == "missing" for item in mappings):
        hard_fail_reasons.append("mapping_status_missing")

    hard_pass = len(hard_fail_reasons) == 0
    overall_status = "pass" if hard_pass else "fail"
    if hard_pass and axiom_backed_count > 0:
        overall_status = "pass_with_warnings"

    total_required = len(REQUIRED_IDS)
    coverage_mapped = total_required - sum(
        1 for x in mappings if x["mapping_status"] == "missing"
    )
    coverage_ratio = 0.0 if total_required == 0 else coverage_mapped / total_required

    return {
        "artifact_id": "ns_leanmillennium_conformance_v1",
        "generated_at": _now_iso(),
        "inputs": {
            "benchmark_map": str(map_path),
        },
        "benchmark_source": {
            "upstream_repo_url": upstream_repo,
            "upstream_commit": upstream_commit,
            "local_commit": local_commit,
        },
        "symbol_map_coverage": {
            "required_ids": list(REQUIRED_IDS),
            "present_ids": sorted(by_id.keys()),
            "missing_required_ids": missing_ids,
            "mapped_required_count": coverage_mapped,
            "required_total_count": total_required,
            "coverage_ratio": coverage_ratio,
        },
        "mappings": mappings,
        "counts": {
            "theorem": theorem_count,
            "axiom_backed": axiom_backed_count,
            "missing": sum(1 for x in mappings if x["mapping_status"] == "missing"),
            "warnings": len(warnings),
        },
        "policy": {
            "policy_id": "ns_leanmillennium_conformance_policy_v1",
            "hard_fail_on_missing_symbol": True,
            "hard_fail_on_unpinned_upstream": True,
            "warn_on_axiom_backed_B_or_D": True,
            "hard_fail_reasons": hard_fail_reasons,
        },
        "warnings": warnings,
        "overall": {
            "status": overall_status,
            "hard_pass": hard_pass,
            "pass_fail_policy_result": "pass" if hard_pass else "fail",
        },
    }


def run(map_path: Path, output_path: Path) -> int:
    payload = _load_json(map_path)
    report = build_report(payload, map_path=map_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"status={report['overall']['status']}")
    print(f"hard_pass={report['overall']['hard_pass']}")
    print(f"output={output_path}")
    return 0 if report["overall"]["hard_pass"] else 2


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--map", type=Path, default=DEFAULT_MAP_PATH)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT_PATH)
    args = parser.parse_args()
    return run(map_path=args.map.resolve(), output_path=args.output.resolve())


if __name__ == "__main__":
    raise SystemExit(main())
