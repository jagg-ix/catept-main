"""Phase 6.5 (optional): QuTiP complex-action CAT/EPT diagnostic.

This phase is intentionally optional and MUST NOT affect Tirole baselines.
If QuTiP is absent, it SKIPs and still writes status artifacts.

Outputs are written under:
  PAPER_TABLES/ADVANCED/QUTIP_COMPLEX_ACTION/

The runner delegates to scripts/qutip_cat_ept_run.py with a config.
"""

from __future__ import annotations

import argparse


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--config", default="configs/qutip_cat_ept.yaml")
    args = p.parse_args()

    # Delegate to the runner without requiring scripts/ to be an importable package.
    import runpy
    import sys

    old_argv = sys.argv[:]
    sys.argv = ["qutip_cat_ept_run.py", "--config", args.config]
    try:
        runpy.run_path("scripts/qutip_cat_ept_run.py", run_name="__main__")
        return 0
    finally:
        sys.argv = old_argv


if __name__ == "__main__":
    raise SystemExit(main())
