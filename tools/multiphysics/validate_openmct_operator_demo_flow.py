#!/usr/bin/env python3
"""Validate Open MCT operator demo flow (phase 5) and emit artifact JSON."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import subprocess
import sys
from typing import Any
from urllib.request import urlopen

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = Path(
    "verification_results/stack_audits/openmct_operator_demo_validation.json"
)
DEFAULT_SNAPSHOT = Path("verification_results/stack_audits/openmct_snapshot.json")
DEFAULT_CONFIG = REPO_ROOT / "webapp" / "openmct" / "openmct.config.json"


def _run(cmd: list[str]) -> dict[str, Any]:
    proc = subprocess.run(
        cmd,
        cwd=str(REPO_ROOT),
        text=True,
        capture_output=True,
        check=False,
    )
    return {
        "command": cmd,
        "exit_code": int(proc.returncode),
        "ok": proc.returncode == 0,
        "stdout_excerpt": (proc.stdout or "")[-2000:],
        "stderr_excerpt": (proc.stderr or "")[-2000:],
    }


def _fetch_json(url: str) -> dict[str, Any]:
    with urlopen(url, timeout=4.0) as resp:
        raw = resp.read().decode("utf-8")
    payload = json.loads(raw)
    if not isinstance(payload, dict):
        raise RuntimeError(f"Expected JSON object from {url}")
    return payload


def _fetch_text(url: str) -> str:
    with urlopen(url, timeout=4.0) as resp:
        return resp.read().decode("utf-8", errors="replace")


def _load_local_config(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise RuntimeError(f"Config file is not JSON object: {path}")
    return payload


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--snapshot-output", type=Path, default=DEFAULT_SNAPSHOT)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--adapter-host", default="127.0.0.1")
    parser.add_argument("--adapter-port", type=int, default=8093)
    parser.add_argument("--frontend-host", default="127.0.0.1")
    parser.add_argument("--frontend-port", type=int, default=8094)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    generated_at = datetime.now(timezone.utc).isoformat()
    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)

    config_path = args.config if args.config.is_absolute() else (REPO_ROOT / args.config)
    snapshot_path = (
        args.snapshot_output
        if args.snapshot_output.is_absolute()
        else (REPO_ROOT / args.snapshot_output)
    )

    artifact: dict[str, Any] = {
        "validator": "openmct_operator_demo_flow",
        "generated_at_utc": generated_at,
        "host": {
            "platform": platform.platform(),
            "python_version": platform.python_version(),
        },
        "dry_run": bool(args.dry_run),
        "services": {},
        "probes": {},
        "config": {},
        "pass": False,
        "status": "fail",
        "reason": "",
    }

    try:
        cfg = _load_local_config(config_path)
        mission_views = cfg.get("missionViews")
        mission_count = len(mission_views) if isinstance(mission_views, list) else 0
        artifact["config"] = {
            "path": str(config_path),
            "adapterBaseUrl": cfg.get("adapterBaseUrl", ""),
            "mission_view_count": int(mission_count),
            "mission_views_valid": mission_count > 0,
        }
    except Exception as exc:
        artifact["reason"] = f"Failed to load Open MCT config: {exc}"
        output.write_text(json.dumps(artifact, indent=2) + "\n", encoding="utf-8")
        print(f"status={artifact['status']}")
        print(f"pass={artifact['pass']}")
        print(f"reason={artifact['reason']}")
        print(f"output={output}")
        return 2

    plan_commands = [
        [
            sys.executable,
            str(REPO_ROOT / "tools" / "multiphysics" / "openmct_telemetry_adapter.py"),
            "--include-mcp-context",
            "snapshot",
            "--output",
            str(snapshot_path),
        ],
        [
            sys.executable,
            str(REPO_ROOT / "tools" / "multiphysics" / "openmct_adapter_service.py"),
            "--include-mcp-context",
            "--host",
            str(args.adapter_host),
            "--port",
            str(args.adapter_port),
            "restart",
        ],
        [
            sys.executable,
            str(REPO_ROOT / "tools" / "multiphysics" / "openmct_frontend_service.py"),
            "--host",
            str(args.frontend_host),
            "--port",
            str(args.frontend_port),
            "restart",
        ],
    ]

    if args.dry_run:
        artifact["services"] = {
            "planned_commands": plan_commands,
            "executed": False,
        }
        ok = bool(artifact["config"].get("mission_views_valid"))
        artifact["pass"] = ok
        artifact["status"] = "pass" if ok else "fail"
        artifact["reason"] = (
            "Dry-run plan validated (config + mission view definitions present)."
            if ok
            else "Dry-run failed: mission views are missing in config."
        )
        output.write_text(json.dumps(artifact, indent=2) + "\n", encoding="utf-8")
        print(f"status={artifact['status']}")
        print(f"pass={artifact['pass']}")
        print(f"reason={artifact['reason']}")
        print(f"output={output}")
        return 0 if ok else 2

    snapshot_run = _run(plan_commands[0])
    adapter_restart = _run(plan_commands[1])
    frontend_restart = _run(plan_commands[2])
    artifact["services"] = {
        "executed": True,
        "snapshot_run": snapshot_run,
        "adapter_restart": adapter_restart,
        "frontend_restart": frontend_restart,
    }

    adapter_base = f"http://{args.adapter_host}:{args.adapter_port}"
    frontend_base = f"http://{args.frontend_host}:{args.frontend_port}"

    try:
        adapter_health = _fetch_json(f"{adapter_base}/health")
        adapter_objects = _fetch_json(f"{adapter_base}/api/openmct/objects")
        adapter_snapshot = _fetch_json(f"{adapter_base}/api/openmct/snapshot")
        frontend_index = _fetch_text(f"{frontend_base}/index.html")
        frontend_config = _fetch_json(f"{frontend_base}/openmct.config.json")
        artifact["probes"] = {
            "adapter_health_ok": bool(adapter_health.get("ok", False)),
            "adapter_objects_count": int(adapter_objects.get("object_count", 0)),
            "adapter_snapshot_channels": int(adapter_snapshot.get("channel_count", 0)),
            "frontend_index_ok": "openmct-app" in frontend_index,
            "frontend_config_mission_views": len(frontend_config.get("missionViews", []))
            if isinstance(frontend_config.get("missionViews", []), list)
            else 0,
        }
    except Exception as exc:
        artifact["reason"] = f"Endpoint probe failure: {exc}"
        output.write_text(json.dumps(artifact, indent=2) + "\n", encoding="utf-8")
        print(f"status={artifact['status']}")
        print(f"pass={artifact['pass']}")
        print(f"reason={artifact['reason']}")
        print(f"output={output}")
        return 2

    checks = [
        bool(snapshot_run.get("ok")),
        bool(adapter_restart.get("ok")),
        bool(frontend_restart.get("ok")),
        bool(artifact["config"].get("mission_views_valid")),
        bool(artifact["probes"].get("adapter_health_ok")),
        int(artifact["probes"].get("adapter_objects_count", 0)) > 0,
        int(artifact["probes"].get("adapter_snapshot_channels", 0)) > 0,
        bool(artifact["probes"].get("frontend_index_ok")),
        int(artifact["probes"].get("frontend_config_mission_views", 0)) > 0,
    ]
    ok = all(checks)
    artifact["pass"] = ok
    artifact["status"] = "pass" if ok else "fail"
    artifact["reason"] = (
        "Open MCT operator e2e demo flow validated."
        if ok
        else "Open MCT operator e2e demo flow checks failed."
    )

    output.write_text(json.dumps(artifact, indent=2) + "\n", encoding="utf-8")
    print(f"status={artifact['status']}")
    print(f"pass={artifact['pass']}")
    print(f"reason={artifact['reason']}")
    print(f"output={output}")
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
