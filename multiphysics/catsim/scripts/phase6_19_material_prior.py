#!/usr/bin/env python3
"""
Phase 6.19 - Material prior synthesis from cached Materials Project subset.

This phase:
- reads data/cache/materials_project/mp_subset__*.json if present
- synthesizes a conservative ITO/ENZ Drude prior (eps_inf, omega_p, gamma)
- writes:
  - PAPER_TABLES/MATERIAL_PRIOR/material_prior.json
  - PAPER_LOGS/PHASE6/6.19_MATERIAL_PRIOR/{STATUS.md,summary.json,data_sources.json}
  - configs/generated/enz_model_from_mp.yaml  (optional; does NOT overwrite existing configs)

No network calls, no hidden downloads.
"""
from __future__ import annotations

import json
from pathlib import Path
import sys
import argparse
import time

from catsim_core.data_sources.export import export_data_sources_manifest
from catsim_core.materials.materials_project_adapter import (
    locate_latest_mp_subset,
    load_mp_subset,
    infer_ito_like_prior,
    to_dict,
)

def write_text(p: Path, s: str) -> None:
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(s, encoding="utf-8")

def write_json(p: Path, obj) -> None:
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--chemsys", default="In-Sn-O")
    ap.add_argument("--cache-dir", default="data/cache/materials_project")
    ap.add_argument("--emit-yaml", action="store_true", help="emit configs/generated/enz_model_from_mp.yaml")
    args = ap.parse_args()

    repo = Path(__file__).resolve().parents[1]
    cache_dir = repo / args.cache_dir

    log_dir = repo / "PAPER_LOGS" / "PHASE6" / "6.19_MATERIAL_PRIOR"
    tables_dir = repo / "PAPER_TABLES" / "MATERIAL_PRIOR"
    gen_cfg_dir = repo / "configs" / "generated"

    started = time.time()

    mp_loc = locate_latest_mp_subset(cache_dir)
    if mp_loc is None:
        # SKIP
        write_text(log_dir / "STATUS.md", "# Phase 6.19 MATERIAL PRIOR\n\nSTATUS: SKIP\n\nReason: no cached MP subset found.\n")
        write_json(log_dir / "summary.json", {
            "phase": "6.19",
            "name": "material_prior",
            "status": "SKIP",
            "reason": "no_mp_cache",
            "elapsed_s": round(time.time() - started, 3),
        })
        write_json(log_dir / "data_sources.json", export_data_sources_manifest(repo))
        return 0

    mp_path, mp_meta = mp_loc
    mp_subset = load_mp_subset(mp_path)
    prior = infer_ito_like_prior(mp_subset, expected_chemsys=args.chemsys)

    prior_dict = to_dict(prior)
    prior_dict["cache_file"] = {"path": str(mp_path), "sha256": mp_meta.sha256}

    write_json(tables_dir / "material_prior.json", prior_dict)

    if args.emit_yaml:
        # minimal enz_model yaml snippet
        y = []
        y.append("# Auto-generated from cached Materials Project subset (conservative heuristic prior).")
        y.append("drude:")
        y.append(f"  eps_inf: {prior.prior.get('eps_inf')}")
        y.append(f"  omega_p: {prior.prior.get('omega_p_rad_s')}")
        y.append(f"  gamma: {prior.prior.get('gamma_rad_s')}")
        y.append(f"  note: {prior.prior.get('note')}")
        write_text(gen_cfg_dir / "enz_model_from_mp.yaml", "\n".join(y) + "\n")

    # PASS
    status_md = (
        "# Phase 6.19 MATERIAL PRIOR\n\n"
        "STATUS: PASS\n\n"
        f"- chemsys: {args.chemsys}\n"
        f"- mp_cache: {mp_path.name}\n"
        f"- mp_ids_count: {len(prior.mp_ids)}\n"
        f"- output: PAPER_TABLES/MATERIAL_PRIOR/material_prior.json\n"
        + (f"- generated_config: configs/generated/enz_model_from_mp.yaml\n" if args.emit_yaml else "")
    )
    write_text(log_dir / "STATUS.md", status_md)
    write_json(log_dir / "summary.json", {
        "phase": "6.19",
        "name": "material_prior",
        "status": "PASS",
        "chemsys": args.chemsys,
        "mp_cache_file": {"path": str(mp_path), "sha256": mp_meta.sha256},
        "mp_ids_count": len(prior.mp_ids),
        "elapsed_s": round(time.time() - started, 3),
    })
    write_json(log_dir / "data_sources.json", export_data_sources_manifest(repo))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
