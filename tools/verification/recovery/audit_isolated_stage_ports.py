#!/usr/bin/env python3
import argparse
import json
import subprocess
from pathlib import Path


def git(repo: Path, *args: str, check: bool = True) -> str:
    res = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True,
        text=True,
    )
    if check and res.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {res.stderr.strip()}")
    return res.stdout


def read_text(path: Path) -> str:
    return path.read_text() if path.exists() else ""


def blob_text(repo: Path, commit: str, path_in_repo: str) -> str:
    return git(repo, "show", f"{commit}:{path_in_repo}", check=True)


def compare_or_signal(
    *,
    stage: int,
    commit: str,
    isolated_repo: Path,
    current_repo: Path,
    source_path: str,
    target_path: str,
    supersede_signals: list[str],
) -> dict:
    target = current_repo / target_path
    target_text = read_text(target)
    exact = False
    source_exists = True
    try:
        source_text = blob_text(isolated_repo, commit, source_path)
        exact = target.exists() and (source_text == target_text)
    except RuntimeError:
        source_exists = False

    missing_signals = [s for s in supersede_signals if s not in target_text]

    if exact:
        status = "exact_match"
    elif missing_signals:
        status = "missing_signals"
    else:
        status = "superseded_or_diverged"

    return {
        "stage": stage,
        "commit": commit,
        "source_path": source_path,
        "target_path": target_path,
        "target_exists": target.exists(),
        "source_exists": source_exists,
        "status": status,
        "missing_signals": missing_signals,
    }


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Audit coverage of isolated stage ports (248/256/257/258/260/294)."
    )
    ap.add_argument("--current-repo", default=".")
    ap.add_argument(
        "--isolated-repo",
        default="/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-isolated-20260409",
    )
    ap.add_argument("--json-out", default="")
    args = ap.parse_args()

    current_repo = Path(args.current_repo).resolve()
    isolated_repo = Path(args.isolated_repo).resolve()

    checks = [
        compare_or_signal(
            stage=248,
            commit="8bdc4d94",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="NavierStokesClean/Galerkin/NSC_P33_Equicontinuity.lean",
            target_path="NavierStokesClean/Galerkin/NSC_P33_Equicontinuity.lean",
            supersede_signals=[
                "theorem galerkin_equicontinuity",
                "galerkin_equicontinuity_from_h1_deriv_bound",
            ],
        ),
        compare_or_signal(
            stage=256,
            commit="f9cbef20",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="lean4_formal_verification/NavierStokes/NavierStokes/ThermodynamicRegularityBridge.lean",
            target_path="NavierStokes/ThermodynamicRegularityBridge.lean",
            supersede_signals=[
                "def RealNoetherToSliceVSContract",
                "axiom realNoetherToSliceVS_global_contract",
                "theorem israelStewart_entropy_divergence_nonneg",
            ],
        ),
        compare_or_signal(
            stage=257,
            commit="72c27c42",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="lean4_formal_verification/NavierStokes/NavierStokes/NSVSNuPEquivalenceGraph.lean",
            target_path="NavierStokes/NSVSNuPEquivalenceGraph.lean",
            supersede_signals=[
                "def resolvedArrowObligations",
                "theorem m01_resolved_by_stage253",
                "realNoether_root_witness_expansion_pack",
            ],
        ),
        compare_or_signal(
            stage=258,
            commit="adb894fc",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="lean4_formal_verification/NavierStokes/NavierStokes/SmallDataRegularityProbe.lean",
            target_path="NavierStokes/SmallDataRegularityProbe.lean",
            supersede_signals=[
                "theorem two_dim_vs_le_nuP",
                "theorem two_dim_enstrophy_rate_nonpos",
            ],
        ),
        compare_or_signal(
            stage=260,
            commit="7ac10580",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="lean4_formal_verification/NavierStokes/NavierStokes/NSSchmidtWolframCertificate.lean",
            target_path="NavierStokes/NSSchmidtWolframCertificate.lean",
            supersede_signals=[
                "realNoetherToSliceVS_global_contract",
                "temam_galerkin_completeness",
            ],
        ),
        compare_or_signal(
            stage=294,
            commit="f0ca2b3d",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="NavierStokesClean/Galerkin/FourierTriadicKernel.lean",
            target_path="NavierStokesClean/Galerkin/FourierTriadicKernel.lean",
            supersede_signals=[
                "noncomputable def triadicKCoeff",
                "theorem triadicKCoeff_off_resonance",
            ],
        ),
        compare_or_signal(
            stage=294,
            commit="f0ca2b3d",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="NavierStokesClean.lean",
            target_path="NavierStokesClean.lean",
            supersede_signals=[
                "import NavierStokesClean.Galerkin.FourierTriadicKernel",
            ],
        ),
        compare_or_signal(
            stage=294,
            commit="f0ca2b3d",
            isolated_repo=isolated_repo,
            current_repo=current_repo,
            source_path="NavierStokesClean/Audit/AxiomAudit.lean",
            target_path="NavierStokesClean/Audit/AxiomAudit.lean",
            supersede_signals=[
                "Stage 294",
                "triadicKCoeff",
            ],
        ),
    ]

    blocking = [c for c in checks if c["status"] == "missing_signals"]
    summary = {
        "current_repo": str(current_repo),
        "isolated_repo": str(isolated_repo),
        "checks": checks,
        "status_counts": {
            "exact_match": sum(1 for c in checks if c["status"] == "exact_match"),
            "superseded_or_diverged": sum(
                1 for c in checks if c["status"] == "superseded_or_diverged"
            ),
            "missing_signals": len(blocking),
        },
        "all_actionable_covered": len(blocking) == 0,
    }

    print(json.dumps(summary, indent=2))
    if args.json_out:
        Path(args.json_out).write_text(json.dumps(summary, indent=2) + "\n")


if __name__ == "__main__":
    main()
