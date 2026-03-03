#!/usr/bin/env python3
"""Master runner: execute all paper simulation scripts in order.

Features:
  - Runs all scripts sequentially via subprocess
  - Tracks timing for each
  - Reports success/failure
  - --scripts arg to run specific scripts (e.g., --scripts 1,4,7)
  - --quick flag to run with reduced parameter grids
  - Prints summary table at end

Usage:
  python run_all.py                   # Run all scripts
  python run_all.py --scripts 1,4,7   # Run only scripts 1, 4, 7
  python run_all.py --quick           # Run with QUICK=1 env var (reduced grids)
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

# ---------------------------------------------------------------------------
# Script registry
# ---------------------------------------------------------------------------
SCRIPTS = [
    {"id": 1, "file": "sim_01_fig2_spectral_series.py", "name": "Fig 2a-d: Spectral Series", "priority": "CRITICAL"},
    {"id": 2, "file": "sim_02_fig2e_period_vs_separation.py", "name": "Fig 2e: Period vs Separation", "priority": "CRITICAL"},
    {"id": 3, "file": "sim_03_fig2f_interferogram.py", "name": "Fig 2f: Interferogram", "priority": "CRITICAL"},
    {"id": 4, "file": "sim_04_visibility_decay.py", "name": "V(S) Visibility Decay", "priority": "CRITICAL"},
    {"id": 5, "file": "sim_05_time_domain_characterization.py", "name": "Time Domain R(t)", "priority": "HIGH"},
    {"id": 6, "file": "sim_06_slit_rise_decay_study.py", "name": "Slit Rise/Decay Study", "priority": "HIGH"},
    {"id": 7, "file": "sim_07_ext_fig3_model_comparison.py", "name": "Ext Fig 3: Model Comparison", "priority": "CRITICAL"},
    {"id": 8, "file": "sim_08_geometric_enhancement.py", "name": "Geometric Enhancement", "priority": "HIGH"},
    {"id": 9, "file": "sim_09_probe_parameter_study.py", "name": "Probe Parameter Study", "priority": "MEDIUM"},
    {"id": 10, "file": "sim_10_full_grid_characterization.py", "name": "Full Grid Characterization", "priority": "MEDIUM"},
    {"id": 11, "file": "sim_11_cat_mode_comparison.py", "name": "CAT Mode Comparison", "priority": "MEDIUM"},
]

# Priority ordering for display
PRIORITY_ORDER = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2, "LOW": 3}


def _parse_script_ids(raw: str) -> list[int]:
    """Parse comma-separated script IDs from --scripts argument."""
    ids = []
    for token in raw.split(","):
        token = token.strip()
        if token:
            ids.append(int(token))
    return ids


def _format_duration(seconds: float) -> str:
    """Format duration as human-readable string."""
    if seconds < 60:
        return f"{seconds:.1f}s"
    minutes = int(seconds // 60)
    secs = seconds - minutes * 60
    if minutes < 60:
        return f"{minutes}m {secs:.1f}s"
    hours = int(minutes // 60)
    mins = minutes - hours * 60
    return f"{hours}h {mins}m {secs:.0f}s"


def main() -> int:
    parser = argparse.ArgumentParser(description="Run all paper simulation scripts")
    parser.add_argument(
        "--scripts",
        type=str,
        default="",
        help="Comma-separated list of script IDs to run (e.g., 1,4,7). Default: all.",
    )
    parser.add_argument(
        "--quick",
        action="store_true",
        help="Run with reduced parameter grids (sets QUICK=1 env var).",
    )
    args = parser.parse_args()

    scripts_dir = Path(__file__).resolve().parent

    # Determine which scripts to run
    if args.scripts:
        selected_ids = _parse_script_ids(args.scripts)
        to_run = [s for s in SCRIPTS if s["id"] in selected_ids]
        if not to_run:
            print(f"ERROR: No scripts matched IDs: {selected_ids}")
            print(f"  Available IDs: {[s['id'] for s in SCRIPTS]}")
            return 1
    else:
        to_run = list(SCRIPTS)

    # Build environment
    env = os.environ.copy()
    if args.quick:
        env["QUICK"] = "1"

    print("=" * 72)
    print("PAPER SIMULATION SUITE - Master Runner")
    print("=" * 72)
    print(f"  Scripts to run: {len(to_run)} of {len(SCRIPTS)}")
    if args.quick:
        print("  Mode: QUICK (reduced parameter grids)")
    else:
        print("  Mode: FULL")
    print(f"  Output directory: {scripts_dir / 'outputs'}")
    print("=" * 72)

    # ------------------------------------------------------------------
    # Run scripts sequentially
    # ------------------------------------------------------------------
    results: list[dict] = []
    t0_total = time.time()

    for idx, script_info in enumerate(to_run, 1):
        sid = script_info["id"]
        fname = script_info["file"]
        sname = script_info["name"]
        priority = script_info["priority"]
        script_path = scripts_dir / fname

        print(f"\n{'='*72}")
        print(f"  [{idx}/{len(to_run)}] Script {sid}: {sname}")
        print(f"  File: {fname}")
        print(f"  Priority: {priority}")

        if not script_path.exists():
            print(f"  WARNING: Script not found: {script_path}")
            results.append({
                "id": sid,
                "name": sname,
                "file": fname,
                "priority": priority,
                "status": "SKIPPED",
                "duration": 0.0,
                "returncode": -1,
            })
            continue

        print(f"  {'='*72}")
        t0_script = time.time()

        try:
            proc = subprocess.run(
                [sys.executable, str(script_path)],
                env=env,
                cwd=str(scripts_dir),
                timeout=3600,  # 1 hour timeout per script
            )
            duration = time.time() - t0_script
            status = "OK" if proc.returncode == 0 else "FAILED"
            results.append({
                "id": sid,
                "name": sname,
                "file": fname,
                "priority": priority,
                "status": status,
                "duration": duration,
                "returncode": proc.returncode,
            })
            if proc.returncode == 0:
                print(f"\n  -> PASSED in {_format_duration(duration)}")
            else:
                print(f"\n  -> FAILED (exit code {proc.returncode}) in {_format_duration(duration)}")

        except subprocess.TimeoutExpired:
            duration = time.time() - t0_script
            print(f"\n  -> TIMEOUT after {_format_duration(duration)}")
            results.append({
                "id": sid,
                "name": sname,
                "file": fname,
                "priority": priority,
                "status": "TIMEOUT",
                "duration": duration,
                "returncode": -2,
            })

        except Exception as exc:
            duration = time.time() - t0_script
            print(f"\n  -> ERROR: {exc}")
            results.append({
                "id": sid,
                "name": sname,
                "file": fname,
                "priority": priority,
                "status": "ERROR",
                "duration": duration,
                "returncode": -3,
            })

    total_duration = time.time() - t0_total

    # ------------------------------------------------------------------
    # Summary table
    # ------------------------------------------------------------------
    print("\n")
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)

    # Header
    print(f"  {'ID':>3}  {'Status':<8}  {'Priority':<9}  {'Time':>10}  {'Script Name'}")
    print(f"  {'---':>3}  {'------':<8}  {'--------':<9}  {'----':>10}  {'-----------'}")

    n_ok = 0
    n_fail = 0
    n_skip = 0

    for r in results:
        status_str = r["status"]
        if status_str == "OK":
            n_ok += 1
            marker = "  "
        elif status_str == "SKIPPED":
            n_skip += 1
            marker = "  "
        else:
            n_fail += 1
            marker = ">>"

        print(
            f"{marker}{r['id']:>3}  {status_str:<8}  {r['priority']:<9}  "
            f"{_format_duration(r['duration']):>10}  {r['name']}"
        )

    print(f"\n  Total: {n_ok} passed, {n_fail} failed, {n_skip} skipped")
    print(f"  Total time: {_format_duration(total_duration)}")
    print("=" * 72)

    # Return non-zero if any failures
    if n_fail > 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
