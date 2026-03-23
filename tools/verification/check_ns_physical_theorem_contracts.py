#!/usr/bin/env python3
"""Physical theorem contract checker for Navier-Stokes Lean formalization.

Purpose:
- Enforce that critical gate-discharge theorems remain genuine theorems (not axioms).
- Enforce that the key physical gate (`EnstrophyPhysicalizationGate`) is:
  (a) defined as a non-trivial existential, not `True` or a tautology;
  (b) imported in the root NavierStokes.lean;
  (c) discharged by a `theorem`, not an `axiom`.
- Enforce that the designated physical-route theorems (the ones that connect
  physical observables to the Millennium result) each carry
  `EnstrophyPhysicalizationGate` as an explicit hypothesis.

Rationale:
  The zero-physics trap allows theorems like "global regularity holds" to be
  proved unconditionally when all physical observables are constant-zero.
  The physicalization gate is the minimal checkable evidence that the
  abstract observable carrier is non-trivial.  These contracts guarantee that
  the gate is present, non-vacuous, and actually threaded through the proofs
  that matter.

Contract taxonomy:
  GATE_IS_THEOREM         — gate-discharge decl must be `theorem`, not `axiom`
  GATE_NOT_TRIVIAL        — gate Prop body must contain a non-trivial existential
  GATE_IMPORT_PRESENT     — bridge file must be imported in root NavierStokes.lean
  GATE_HYPOTHESIS_PRESENT — critical route theorems must carry the gate hypothesis
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional


REPO_ROOT = Path(__file__).resolve().parents[2]
NS_DIR = REPO_ROOT / "lean4_formal_verification" / "NavierStokes" / "NavierStokes"
NS_ROOT_LEAN = REPO_ROOT / "lean4_formal_verification" / "NavierStokes" / "NavierStokes.lean"
DEFAULT_OUTPUT = (
    REPO_ROOT / "verification_results" / "stack_audits" / "ns_physical_contracts.json"
)

# ---------------------------------------------------------------------------
# Contract definitions
# ---------------------------------------------------------------------------

# Theorems that must be `theorem` (not `axiom`).  Each entry is the
# declaration name; if `axiom <name>` is found, or `theorem <name>` is absent,
# that is a violation.
GATE_DISCHARGE_THEOREMS: List[str] = [
    "EnstrophyPhysicalizationGate_discharged",
    "enstrophyPhysicalizedWitnessObligation_discharged",
]

# The gate definition name and a required substring that must appear in the
# definition body to confirm it is non-trivial.
GATE_DEF_NAME = "EnstrophyPhysicalizationGate"
GATE_DEF_NONTRIVIAL_SUBSTRING = "0 < enstrophy"

# The bridge file must appear in the root import list.
GATE_BRIDGE_MODULE = "NavierStokes.NSEnstrophyPhysicalizationBridge"

# Physical-route theorems whose signatures MUST contain the gate hypothesis.
# Each entry is (theorem_name, required_hypothesis_fragment).
# The hypothesis fragment is searched for in the text between `theorem <name>`
# and the first `:= ` or `:= by`.
PHYSICAL_ROUTE_CONTRACTS: List[tuple[str, str]] = [
    ("millennium_C_closed_of_enstrophyPhysicalizationGate",
     "EnstrophyPhysicalizationGate"),
    ("millennium_C_global_regularity_of_enstrophyPhysicalizationGate",
     "EnstrophyPhysicalizationGate"),
    ("millennium_t3_from_bkm_pipeline_strong_of_enstrophyPhysicalizationGate",
     "EnstrophyPhysicalizationGate"),
    ("leray_fk_bkm_from_physical_mode0_strong_of_enstrophyPhysicalizationGate",
     "EnstrophyPhysicalizationGate"),
    ("path_C_stage218_strong_bridge_reduces_to_enstrophy_physicalization_gate",
     "EnstrophyPhysicalizationGate"),
    ("path_C_stage221_strong_global_route_of_enstrophyPhysicalizationGate",
     "EnstrophyPhysicalizationGate"),
    ("pgs_from_physical_mode0_strong_of_enstrophyPhysicalizationGate",
     "EnstrophyPhysicalizationGate"),
]


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class ContractViolation:
    id: str
    rule: str
    path: str
    detail: str
    line: int = 0


def _strip_lean_comments(text: str) -> str:
    """Strip Lean line/block comments, preserving line breaks."""
    out: List[str] = []
    i = 0
    n = len(text)
    block_depth = 0

    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""

        if block_depth > 0:
            if ch == "/" and nxt == "-":
                block_depth += 1
                out.extend("  ")
                i += 2
                continue
            if ch == "-" and nxt == "/":
                block_depth -= 1
                out.extend("  ")
                i += 2
                continue
            out.append("\n" if ch == "\n" else " ")
            i += 1
            continue

        if ch == "/" and nxt == "-":
            block_depth = 1
            out.extend("  ")
            i += 2
            continue

        if ch == "-" and nxt == "-":
            while i < n and text[i] != "\n":
                out.append(" ")
                i += 1
            continue

        out.append(ch)
        i += 1

    return "".join(out)


def _line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def _read_stripped(path: Path) -> str:
    return _strip_lean_comments(path.read_text(encoding="utf-8", errors="replace"))


# ---------------------------------------------------------------------------
# Check 1: gate-discharge theorems must be `theorem`, not `axiom`
# ---------------------------------------------------------------------------

def check_gate_is_theorem(
    violations: List[ContractViolation],
) -> None:
    lean_files = list(NS_DIR.glob("*.lean")) + list(NS_DIR.glob("**/*.lean"))

    for name in GATE_DISCHARGE_THEOREMS:
        found_theorem = False
        found_axiom: Optional[tuple[str, int]] = None

        axiom_rx = re.compile(
            r"^\s*axiom\s+" + re.escape(name) + r"\b", re.MULTILINE
        )
        theorem_rx = re.compile(
            r"^\s*theorem\s+" + re.escape(name) + r"\b", re.MULTILINE
        )

        for p in lean_files:
            stripped = _read_stripped(p)
            rel = str(p.relative_to(REPO_ROOT))

            m = axiom_rx.search(stripped)
            if m:
                found_axiom = (rel, _line_of(stripped, m.start()))

            if theorem_rx.search(stripped):
                found_theorem = True

        if found_axiom:
            rel, ln = found_axiom
            violations.append(ContractViolation(
                id=f"gate_is_theorem:{name}",
                rule="GATE_IS_THEOREM",
                path=rel,
                detail=(
                    f"'{name}' is declared as `axiom` — must be `theorem`. "
                    "Gate-discharge proofs must not be axiomatic."
                ),
                line=ln,
            ))

        if not found_theorem:
            violations.append(ContractViolation(
                id=f"gate_is_theorem:{name}:missing",
                rule="GATE_IS_THEOREM",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail=(
                    f"'{name}' not found as `theorem` anywhere in the formalization. "
                    "Gate-discharge theorem must exist."
                ),
            ))


# ---------------------------------------------------------------------------
# Check 2: gate Prop body must be non-trivial
# ---------------------------------------------------------------------------

def check_gate_not_trivial(
    violations: List[ContractViolation],
) -> None:
    lean_files = list(NS_DIR.glob("*.lean")) + list(NS_DIR.glob("**/*.lean"))

    def_rx = re.compile(
        r"def\s+" + re.escape(GATE_DEF_NAME) + r"\s*:\s*Prop\s*:=\s*([^\n]+)",
        re.MULTILINE,
    )

    found = False
    for p in lean_files:
        stripped = _read_stripped(p)
        m = def_rx.search(stripped)
        if not m:
            continue
        found = True
        body = m.group(1).strip()
        rel = str(p.relative_to(REPO_ROOT))
        ln = _line_of(stripped, m.start())

        # Reject trivially-true bodies.
        trivial_patterns = [r"^\s*True\s*$", r"^\s*trivial\s*$", r"^\s*⊤\s*$"]
        for pat in trivial_patterns:
            if re.match(pat, body):
                violations.append(ContractViolation(
                    id=f"gate_not_trivial:{GATE_DEF_NAME}",
                    rule="GATE_NOT_TRIVIAL",
                    path=rel,
                    detail=(
                        f"'{GATE_DEF_NAME}' body is trivially true ('{body}'). "
                        "The gate must assert a non-trivial physical property."
                    ),
                    line=ln,
                ))
                return

        # Require the expected non-trivial substring.
        if GATE_DEF_NONTRIVIAL_SUBSTRING not in stripped[m.start(): m.start() + 200]:
            violations.append(ContractViolation(
                id=f"gate_not_trivial:{GATE_DEF_NAME}:missing_content",
                rule="GATE_NOT_TRIVIAL",
                path=rel,
                detail=(
                    f"'{GATE_DEF_NAME}' definition does not contain expected "
                    f"content '{GATE_DEF_NONTRIVIAL_SUBSTRING}'. "
                    "Verify the gate asserts 0 < enstrophy for some NS field."
                ),
                line=ln,
            ))

    if not found:
        violations.append(ContractViolation(
            id=f"gate_not_trivial:{GATE_DEF_NAME}:not_found",
            rule="GATE_NOT_TRIVIAL",
            path=str(NS_DIR.relative_to(REPO_ROOT)),
            detail=f"'{GATE_DEF_NAME}' definition not found in the formalization.",
        ))


# ---------------------------------------------------------------------------
# Check 3: bridge module must be imported in root NavierStokes.lean
# ---------------------------------------------------------------------------

def check_gate_import_present(
    violations: List[ContractViolation],
) -> None:
    if not NS_ROOT_LEAN.exists():
        violations.append(ContractViolation(
            id=f"gate_import_present:{GATE_BRIDGE_MODULE}",
            rule="GATE_IMPORT_PRESENT",
            path=str(NS_ROOT_LEAN.relative_to(REPO_ROOT)),
            detail=f"Root NavierStokes.lean not found at expected path.",
        ))
        return

    text = NS_ROOT_LEAN.read_text(encoding="utf-8", errors="replace")
    import_rx = re.compile(
        r"^\s*import\s+" + re.escape(GATE_BRIDGE_MODULE) + r"\s*$",
        re.MULTILINE,
    )
    if not import_rx.search(text):
        violations.append(ContractViolation(
            id=f"gate_import_present:{GATE_BRIDGE_MODULE}",
            rule="GATE_IMPORT_PRESENT",
            path=str(NS_ROOT_LEAN.relative_to(REPO_ROOT)),
            detail=(
                f"'{GATE_BRIDGE_MODULE}' is not imported in root NavierStokes.lean. "
                "The physicalization bridge must be part of the build."
            ),
        ))


# ---------------------------------------------------------------------------
# Check 4: physical-route theorems must carry the gate hypothesis
# ---------------------------------------------------------------------------

def check_gate_hypothesis_present(
    violations: List[ContractViolation],
) -> None:
    lean_files = list(NS_DIR.glob("*.lean")) + list(NS_DIR.glob("**/*.lean"))

    # Build an index: theorem_name → (file, stripped_text, match_offset)
    Index = Dict[str, tuple[str, str, int]]
    index: Index = {}

    for p in lean_files:
        stripped = _read_stripped(p)
        rel = str(p.relative_to(REPO_ROOT))
        for name, _ in PHYSICAL_ROUTE_CONTRACTS:
            if name in index:
                continue
            rx = re.compile(
                r"^\s*theorem\s+" + re.escape(name) + r"\b", re.MULTILINE
            )
            m = rx.search(stripped)
            if m:
                index[name] = (rel, stripped, m.start())

    for name, hypothesis_fragment in PHYSICAL_ROUTE_CONTRACTS:
        if name not in index:
            violations.append(ContractViolation(
                id=f"gate_hypothesis_present:{name}:missing",
                rule="GATE_HYPOTHESIS_PRESENT",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail=(
                    f"Critical route theorem '{name}' not found in the formalization. "
                    "All contracted physical-route theorems must exist."
                ),
            ))
            continue

        rel, stripped, start = index[name]
        ln = _line_of(stripped, start)

        # Extract the theorem signature: from `theorem <name>` up to first `:= by` or `:=`.
        # We look at a reasonable window (up to 4096 chars) to find the body delimiter.
        window = stripped[start: start + 4096]
        # Find first `:= by` or standalone `:=` that ends the signature.
        body_start = re.search(r":=\s*by\b|:=\s*\n|:=\s+[^\s]", window)
        signature = window[: body_start.start()] if body_start else window

        if hypothesis_fragment not in signature:
            violations.append(ContractViolation(
                id=f"gate_hypothesis_present:{name}",
                rule="GATE_HYPOTHESIS_PRESENT",
                path=rel,
                detail=(
                    f"Critical route theorem '{name}' does not have "
                    f"'{hypothesis_fragment}' as an explicit hypothesis. "
                    "Physical-route theorems must be gated on the physicalization gate."
                ),
                line=ln,
            ))


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def run(output_path: Path, strict: bool) -> int:
    violations: List[ContractViolation] = []

    check_gate_is_theorem(violations)
    check_gate_not_trivial(violations)
    check_gate_import_present(violations)
    check_gate_hypothesis_present(violations)

    passed = len(violations) == 0

    output = {
        "check": "ns_physical_theorem_contracts",
        "strict": bool(strict),
        "pass": passed,
        "violation_count": len(violations),
        "contracts_checked": [
            "GATE_IS_THEOREM",
            "GATE_NOT_TRIVIAL",
            "GATE_IMPORT_PRESENT",
            "GATE_HYPOTHESIS_PRESENT",
        ],
        "gate_discharge_theorems": GATE_DISCHARGE_THEOREMS,
        "gate_def": GATE_DEF_NAME,
        "gate_bridge_module": GATE_BRIDGE_MODULE,
        "physical_route_contracts": len(PHYSICAL_ROUTE_CONTRACTS),
        "violations": [
            {
                "id": v.id,
                "rule": v.rule,
                "path": v.path,
                "line": v.line,
                "detail": v.detail,
            }
            for v in sorted(violations, key=lambda x: (x.rule, x.path, x.line))
        ],
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")

    print(f"status={'pass' if passed else 'fail'}")
    print(f"violations={len(violations)}")
    print(f"output={output_path}")

    if violations:
        for v in violations:
            print(f"  [{v.rule}] {v.path}:{v.line} — {v.detail}")

    if strict and not passed:
        return 2
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
    )
    parser.add_argument("--strict", action="store_true", default=False)
    args = parser.parse_args()
    return run(args.output.resolve(), strict=bool(args.strict))


if __name__ == "__main__":
    raise SystemExit(main())
