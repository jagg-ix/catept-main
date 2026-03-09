from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys


def _script_path() -> Path:
    repo_root = Path(__file__).resolve().parents[2]
    return (
        repo_root
        / "tools"
        / "multiphysics"
        / "validate_openmct_operator_demo_flow.py"
    )


def test_validate_openmct_operator_demo_flow_dry_run(tmp_path: Path) -> None:
    out = tmp_path / "openmct_operator_demo_validation.json"
    proc = subprocess.run(
        [sys.executable, str(_script_path()), "--dry-run", "--output", str(out)],
        text=True,
        capture_output=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr

    payload = json.loads(out.read_text(encoding="utf-8"))
    assert payload["validator"] == "openmct_operator_demo_flow"
    assert payload["dry_run"] is True
    assert payload["pass"] is True
    assert payload["status"] == "pass"
    assert payload["config"]["mission_view_count"] >= 1
    assert payload["services"]["executed"] is False
