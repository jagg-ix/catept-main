from __future__ import annotations
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

@dataclass
class RunResult:
    returncode: int
    stdout: str
    stderr: str

def run_cmd(cmd: List[str], cwd: Optional[Path] = None, env: Optional[dict] = None, timeout_s: Optional[int] = None) -> RunResult:
    p = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=timeout_s,
    )
    return RunResult(p.returncode, p.stdout, p.stderr)

def run_make(target: str, repo_root: Path, timeout_s: Optional[int] = None) -> RunResult:
    return run_cmd(["make", target], cwd=repo_root, timeout_s=timeout_s)
