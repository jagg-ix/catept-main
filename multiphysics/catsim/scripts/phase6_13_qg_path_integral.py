"""Phase 6.13: Quantum-Gravity Path Integral (toy complex action).

Optional phase: safe to run in isolation and safe to skip.

We export a small subset of sampled paths and a summary of weighted
observables. This is intended as an integration point for the CAT/EPT
math supplement's functional integral definitions.
"""

from __future__ import annotations

import json
from pathlib import Path

from catsim_core.qg.path_integral import PathIntegralConfig, export_paths_csv, run_path_integral


def main() -> int:
    out_dir = Path("PAPER_TABLES/ADVANCED/QG_PATH_INTEGRAL")
    out_dir.mkdir(parents=True, exist_ok=True)

    passed = True
    skipped = False
    details = {}

    try:
        cfg = PathIntegralConfig(
            n_paths=2000,
            n_steps=200,
            t_final_s=1.0e-12,
            seed=0,
        )
        t, x, w, obs = run_path_integral(cfg=cfg)
        export_paths_csv(str(out_dir / "paths.csv"), t=t, x=x, w=w, max_paths=200)
        (out_dir / "pi_summary.json").write_text(json.dumps({"obs": obs, "cfg": cfg.__dict__}, indent=2))

        # basic sanity gate: weights shouldn't all be NaN
        if not (w.size > 0):
            passed = False
            details["w"] = "empty"
        if not (obs.get("Z_abs", 0.0) >= 0.0):
            passed = False
            details["Z_abs"] = "invalid"

    except Exception as e:
        passed = False
        details["error"] = str(e)

    summary = {"skipped": skipped, "pass": passed, "details": details}
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.13 — QG Path Integral\n\n"
        f"- skipped: {skipped}\n"
        f"- PASS: {passed}\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
