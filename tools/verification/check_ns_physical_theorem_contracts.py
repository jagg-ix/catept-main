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
  BRIDGE_AXIOM_SCOPE      — enstrophy physicalization source must be theoremized
  DELTA_ROUTE_PRESENT     — non-vacuous discrete-time witness route remains present
  ASSUMPTION_USAGE_PRESENT — selected bridge theorems must use designated hypotheses in body
  THEOREM_ONLY_PRESENT    — selected lane-critical declarations must remain theorems
  FORBIDDEN_BODY_FRAGMENT — selected theorem bodies must not regress to vacuous fragments

Policy:
  Contracts are loaded from ns_physical_theorem_contracts_policy.json (same dir).
  To add or remove a contracted theorem, edit the policy file — the change is
  then explicit and reviewable in git history.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple


REPO_ROOT = Path(__file__).resolve().parents[2]
NS_DIR = REPO_ROOT / "lean4_formal_verification" / "NavierStokes" / "NavierStokes"
NS_ROOT_LEAN = REPO_ROOT / "lean4_formal_verification" / "NavierStokes" / "NavierStokes.lean"
DEFAULT_POLICY = Path(__file__).resolve().parent / "ns_physical_theorem_contracts_policy.json"
DEFAULT_OUTPUT = (
    REPO_ROOT / "verification_results" / "stack_audits" / "ns_physical_contracts.json"
)


# ---------------------------------------------------------------------------
# Policy loading
# ---------------------------------------------------------------------------

def _load_policy(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(
            f"Policy file not found: {path}\n"
            "Create ns_physical_theorem_contracts_policy.json alongside this script."
        )
    payload = json.loads(path.read_text(encoding="utf-8"))
    required_keys = {
        "gate_discharge_theorems",
        "gate_def_name",
        "gate_def_nontrivial_substring",
        "gate_bridge_module",
        "physical_route_contracts",
    }
    missing = required_keys - set(payload.keys())
    if missing:
        raise ValueError(f"Policy file missing required keys: {missing}")
    return payload


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


def _all_lean_files() -> List[Path]:
    return list(NS_DIR.glob("*.lean")) + list(NS_DIR.glob("**/*.lean"))


def _index_theorems(theorem_names: List[str]) -> Dict[str, Tuple[str, str, int]]:
    index: Dict[str, Tuple[str, str, int]] = {}
    for p in _all_lean_files():
        stripped = _read_stripped(p)
        rel = str(p.relative_to(REPO_ROOT))
        for name in theorem_names:
            if name in index:
                continue
            rx = re.compile(
                r"^\s*theorem\s+" + re.escape(name) + r"\b", re.MULTILINE
            )
            m = rx.search(stripped)
            if m:
                index[name] = (rel, stripped, m.start())
    return index


def _extract_theorem_signature_and_body(stripped: str, start: int) -> Tuple[str, str]:
    window = stripped[start: start + 8192]
    body_start = re.search(r":=\s*by\b|:=\s*\n|:=\s+[^\s]", window)
    if not body_start:
        return window, ""
    signature = window[: body_start.start()]
    tail = window[body_start.end():]
    next_decl = re.search(
        r"^(?:theorem|def|axiom|lemma|structure|inductive|class|abbrev)\s+[A-Za-z0-9_'.]+",
        tail,
        re.MULTILINE,
    )
    body = tail[: next_decl.start()] if next_decl else tail
    return signature, body


# ---------------------------------------------------------------------------
# Check 1: gate-discharge theorems must be `theorem`, not `axiom`
# ---------------------------------------------------------------------------

def check_gate_is_theorem(
    violations: List[ContractViolation],
    gate_discharge_theorems: List[str],
) -> None:
    lean_files = _all_lean_files()

    for name in gate_discharge_theorems:
        found_theorem = False
        found_axiom: Optional[Tuple[str, int]] = None

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
    gate_def_name: str,
    gate_def_nontrivial_substring: str,
) -> None:
    lean_files = _all_lean_files()

    def_rx = re.compile(
        r"def\s+" + re.escape(gate_def_name) + r"\s*:\s*Prop\s*:=\s*([^\n]+)",
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
                    id=f"gate_not_trivial:{gate_def_name}",
                    rule="GATE_NOT_TRIVIAL",
                    path=rel,
                    detail=(
                        f"'{gate_def_name}' body is trivially true ('{body}'). "
                        "The gate must assert a non-trivial physical property."
                    ),
                    line=ln,
                ))
                return

        # Require the expected non-trivial substring.
        if gate_def_nontrivial_substring not in stripped[m.start(): m.start() + 200]:
            violations.append(ContractViolation(
                id=f"gate_not_trivial:{gate_def_name}:missing_content",
                rule="GATE_NOT_TRIVIAL",
                path=rel,
                detail=(
                    f"'{gate_def_name}' definition does not contain expected "
                    f"content '{gate_def_nontrivial_substring}'. "
                    f"Verify the gate asserts {gate_def_nontrivial_substring} for some NS field."
                ),
                line=ln,
            ))

    if not found:
        violations.append(ContractViolation(
            id=f"gate_not_trivial:{gate_def_name}:not_found",
            rule="GATE_NOT_TRIVIAL",
            path=str(NS_DIR.relative_to(REPO_ROOT)),
            detail=f"'{gate_def_name}' definition not found in the formalization.",
        ))


# ---------------------------------------------------------------------------
# Check 3: bridge module must be imported in root NavierStokes.lean
# ---------------------------------------------------------------------------

def check_gate_import_present(
    violations: List[ContractViolation],
    gate_bridge_module: str,
) -> None:
    if not NS_ROOT_LEAN.exists():
        violations.append(ContractViolation(
            id=f"gate_import_present:{gate_bridge_module}",
            rule="GATE_IMPORT_PRESENT",
            path=str(NS_ROOT_LEAN.relative_to(REPO_ROOT)),
            detail=f"Root NavierStokes.lean not found at expected path.",
        ))
        return

    text = NS_ROOT_LEAN.read_text(encoding="utf-8", errors="replace")
    import_rx = re.compile(
        r"^\s*import\s+" + re.escape(gate_bridge_module) + r"\s*$",
        re.MULTILINE,
    )
    if not import_rx.search(text):
        violations.append(ContractViolation(
            id=f"gate_import_present:{gate_bridge_module}",
            rule="GATE_IMPORT_PRESENT",
            path=str(NS_ROOT_LEAN.relative_to(REPO_ROOT)),
            detail=(
                f"'{gate_bridge_module}' is not imported in root NavierStokes.lean. "
                "The physicalization bridge must be part of the build."
            ),
        ))


# ---------------------------------------------------------------------------
# Check 4: physical-route theorems must carry the gate hypothesis
# ---------------------------------------------------------------------------

def check_gate_hypothesis_present(
    violations: List[ContractViolation],
    physical_route_contracts: List[Tuple[str, str]],
) -> None:
    index = _index_theorems([name for name, _ in physical_route_contracts])

    for name, hypothesis_fragment in physical_route_contracts:
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

        signature, _ = _extract_theorem_signature_and_body(stripped, start)

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
# Check 5: discrete-time route theorems must carry `SatisfiesNSPDEΔ`
# ---------------------------------------------------------------------------

def check_delta_route_present(
    violations: List[ContractViolation],
    delta_route_contracts: List[Tuple[str, str]],
) -> None:
    if not delta_route_contracts:
        return

    index = _index_theorems([name for name, _ in delta_route_contracts])

    for name, signature_fragment in delta_route_contracts:
        if name not in index:
            violations.append(ContractViolation(
                id=f"delta_route_present:{name}:missing",
                rule="DELTA_ROUTE_PRESENT",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail=(
                    f"Delta-route theorem '{name}' not found. "
                    "Keep non-vacuous discrete-time route theorems present on the PDE lane."
                ),
            ))
            continue

        rel, stripped, start = index[name]
        ln = _line_of(stripped, start)
        signature, _ = _extract_theorem_signature_and_body(stripped, start)

        if signature_fragment not in signature:
            violations.append(ContractViolation(
                id=f"delta_route_present:{name}",
                rule="DELTA_ROUTE_PRESENT",
                path=rel,
                line=ln,
                detail=(
                    f"Delta-route theorem '{name}' signature is missing "
                    f"required fragment '{signature_fragment}'."
                ),
            ))


# ---------------------------------------------------------------------------
# Check 6: bridge physicalization source must be theoremized
# ---------------------------------------------------------------------------

def check_bridge_axiom_scope(
    violations: List[ContractViolation],
) -> None:
    """Enforce theoremized physicalization source contracts.

    Required shape:
      theorem enstrophyGlobalParsevalAlignment_discharged :
        EnstrophyGlobalParsevalAlignment
      theorem enstrophy_physicalized :
        EnstrophyPhysicalizedCanonicalWitnessAlignment

    Forbidden regression:
      axiom enstrophy_physicalized : ...
    """
    bridge = NS_DIR / "NSEnstrophyPhysicalizationBridge.lean"
    rel = str(bridge.relative_to(REPO_ROOT))
    if not bridge.exists():
        violations.append(ContractViolation(
            id="bridge_axiom_scope:file_missing",
            rule="BRIDGE_AXIOM_SCOPE",
            path=rel,
            detail="NSEnstrophyPhysicalizationBridge.lean not found.",
        ))
        return

    stripped = _read_stripped(bridge)

    theorem_decl_rx = re.compile(
        r"^\s*theorem\s+enstrophy_physicalized\s*:\s*([^\n]+)",
        re.MULTILINE,
    )
    m = theorem_decl_rx.search(stripped)
    if m is None:
        violations.append(ContractViolation(
            id="bridge_axiom_scope:missing_theorem",
            rule="BRIDGE_AXIOM_SCOPE",
            path=rel,
            detail=(
                "Expected declaration `theorem enstrophy_physicalized` not found. "
                "Physicalization must be theoremized, not axiomatized."
            ),
        ))
    else:
        line = _line_of(stripped, m.start())
        rhs = m.group(1).strip()
        if "EnstrophyPhysicalizedCanonicalWitnessAlignment" not in rhs:
            violations.append(ContractViolation(
                id="bridge_axiom_scope:not_canonical",
                rule="BRIDGE_AXIOM_SCOPE",
                path=rel,
                line=line,
                detail=(
                    "enstrophy_physicalized must conclude "
                    "EnstrophyPhysicalizedCanonicalWitnessAlignment."
                ),
            ))

    parseval_decl_rx = re.compile(
        r"^\s*theorem\s+enstrophyGlobalParsevalAlignment_discharged\s*:\s*"
        r"EnstrophyGlobalParsevalAlignment\b",
        re.MULTILINE,
    )
    if parseval_decl_rx.search(stripped) is None:
        violations.append(ContractViolation(
            id="bridge_axiom_scope:missing_parseval_discharge",
            rule="BRIDGE_AXIOM_SCOPE",
            path=rel,
            detail=(
                "Missing theorem `enstrophyGlobalParsevalAlignment_discharged`. "
                "Full physicalization requires a discharged global Parseval alignment source."
            ),
        ))

    axiom_regression_rx = re.compile(
        r"^\s*axiom\s+enstrophy_physicalized\b",
        re.MULTILINE,
    )
    m_axiom = axiom_regression_rx.search(stripped)
    if m_axiom is not None:
        violations.append(ContractViolation(
            id="bridge_axiom_scope:axiom_regression",
            rule="BRIDGE_AXIOM_SCOPE",
            path=rel,
            line=_line_of(stripped, m_axiom.start()),
            detail=(
                "Regression detected: `enstrophy_physicalized` is declared as an axiom. "
                "Retire canonical-witness axiom path; keep theoremized source only."
            ),
            ))


# ---------------------------------------------------------------------------
# Check 6b: file-scoped axiom/theorem scope contracts
# ---------------------------------------------------------------------------

def check_file_axiom_scope_contracts(
    violations: List[ContractViolation],
    file_axiom_scope_contracts: List[dict],
) -> None:
    if not file_axiom_scope_contracts:
        return

    for entry in file_axiom_scope_contracts:
        file_name = str(entry.get("file", "")).strip()
        allowed_axioms: List[str] = list(entry.get("allowed_axioms", []))
        required_theorems: List[str] = list(entry.get("required_theorems", []))

        if not file_name:
            violations.append(ContractViolation(
                id="file_axiom_scope:invalid_entry",
                rule="FILE_AXIOM_SCOPE",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail="Invalid file_axiom_scope_contracts entry: missing `file`.",
            ))
            continue

        path = NS_DIR / file_name
        rel = str(path.relative_to(REPO_ROOT))
        if not path.exists():
            violations.append(ContractViolation(
                id=f"file_axiom_scope:{file_name}:missing_file",
                rule="FILE_AXIOM_SCOPE",
                path=rel,
                detail=f"Contracted file '{file_name}' not found.",
            ))
            continue

        stripped = _read_stripped(path)

        # Axiom declarations in this file.
        axiom_rx = re.compile(r"^\s*axiom\s+([A-Za-z0-9_'.]+)\b", re.MULTILINE)
        axiom_names = [m.group(1) for m in axiom_rx.finditer(stripped)]

        allowed_axiom_set = set(allowed_axioms)
        for m in axiom_rx.finditer(stripped):
            axiom_name = m.group(1)
            if axiom_name not in allowed_axiom_set:
                violations.append(ContractViolation(
                    id=f"file_axiom_scope:{file_name}:unexpected_axiom:{axiom_name}",
                    rule="FILE_AXIOM_SCOPE",
                    path=rel,
                    line=_line_of(stripped, m.start()),
                    detail=(
                        f"Unexpected axiom '{axiom_name}' in '{file_name}'. "
                        f"Allowed axioms: {allowed_axioms}."
                    ),
                ))

        # Ensure every allowed axiom exists (to prevent silent rename/drop drift).
        for axiom_name in allowed_axioms:
            if axiom_name not in axiom_names:
                violations.append(ContractViolation(
                    id=f"file_axiom_scope:{file_name}:missing_allowed_axiom:{axiom_name}",
                    rule="FILE_AXIOM_SCOPE",
                    path=rel,
                    detail=(
                        f"Expected allowed axiom '{axiom_name}' not found in '{file_name}'."
                    ),
                ))

        # Ensure contracted theorem declarations exist.
        for theorem_name in required_theorems:
            theorem_rx = re.compile(
                r"^\s*theorem\s+" + re.escape(theorem_name) + r"\b",
                re.MULTILINE,
            )
            if theorem_rx.search(stripped) is None:
                violations.append(ContractViolation(
                    id=f"file_axiom_scope:{file_name}:missing_theorem:{theorem_name}",
                    rule="FILE_AXIOM_SCOPE",
                    path=rel,
                    detail=(
                        f"Expected theorem '{theorem_name}' not found in '{file_name}'."
                    ),
                ))


# ---------------------------------------------------------------------------
# Check 7: theorem body must use designated assumptions (anti-vacuity)
# ---------------------------------------------------------------------------

def check_assumption_usage_present(
    violations: List[ContractViolation],
    assumption_usage_contracts: List[Tuple[str, List[str]]],
) -> None:
    if not assumption_usage_contracts:
        return

    index = _index_theorems([name for name, _ in assumption_usage_contracts])

    for name, required_fragments in assumption_usage_contracts:
        if name not in index:
            violations.append(ContractViolation(
                id=f"assumption_usage_present:{name}:missing",
                rule="ASSUMPTION_USAGE_PRESENT",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail=(
                    f"Contracted theorem '{name}' not found. "
                    "Assumption-usage contracts must point to existing declarations."
                ),
            ))
            continue

        rel, stripped, start = index[name]
        ln = _line_of(stripped, start)
        _, body = _extract_theorem_signature_and_body(stripped, start)
        if not body:
            violations.append(ContractViolation(
                id=f"assumption_usage_present:{name}:no_body",
                rule="ASSUMPTION_USAGE_PRESENT",
                path=rel,
                line=ln,
                detail=(
                    f"Could not locate theorem body for '{name}'. "
                    "Expected a declaration with explicit `:=` body."
                ),
            ))
            continue

        for fragment in required_fragments:
            if fragment not in body:
                violations.append(ContractViolation(
                    id=f"assumption_usage_present:{name}:{fragment}",
                    rule="ASSUMPTION_USAGE_PRESENT",
                    path=rel,
                    line=ln,
                    detail=(
                        f"Theorem '{name}' body is missing required fragment '{fragment}'. "
                        "This indicates a possible regression to assumption-ignoring proof style."
                    ),
                ))


# ---------------------------------------------------------------------------
# Check 8: selected declarations must stay theoremized
# ---------------------------------------------------------------------------

def check_theorem_only_present(
    violations: List[ContractViolation],
    theorem_only_contracts: List[str],
) -> None:
    if not theorem_only_contracts:
        return

    lean_files = _all_lean_files()
    theorem_index = _index_theorems(theorem_only_contracts)

    for name in theorem_only_contracts:
        found_axiom: Optional[Tuple[str, int]] = None
        axiom_rx = re.compile(
            r"^\s*axiom\s+" + re.escape(name) + r"\b", re.MULTILINE
        )
        for p in lean_files:
            stripped = _read_stripped(p)
            rel = str(p.relative_to(REPO_ROOT))
            m = axiom_rx.search(stripped)
            if m:
                found_axiom = (rel, _line_of(stripped, m.start()))

        if found_axiom:
            rel, ln = found_axiom
            violations.append(ContractViolation(
                id=f"theorem_only_present:{name}:axiom",
                rule="THEOREM_ONLY_PRESENT",
                path=rel,
                line=ln,
                detail=(
                    f"'{name}' regressed to `axiom`. This declaration is contracted "
                    "to remain theoremized."
                ),
            ))

        if name not in theorem_index:
            violations.append(ContractViolation(
                id=f"theorem_only_present:{name}:missing",
                rule="THEOREM_ONLY_PRESENT",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail=(
                    f"'{name}' not found as a theorem. Keep lane-critical "
                    "physicalization/compactness declarations theoremized."
                ),
            ))


# ---------------------------------------------------------------------------
# Check 9: selected theorem bodies must avoid forbidden vacuous fragments
# ---------------------------------------------------------------------------

def check_forbidden_body_fragments(
    violations: List[ContractViolation],
    forbidden_body_fragment_contracts: List[Tuple[str, List[str]]],
) -> None:
    if not forbidden_body_fragment_contracts:
        return

    index = _index_theorems([name for name, _ in forbidden_body_fragment_contracts])

    for name, forbidden_fragments in forbidden_body_fragment_contracts:
        if name not in index:
            violations.append(ContractViolation(
                id=f"forbidden_body_fragment:{name}:missing",
                rule="FORBIDDEN_BODY_FRAGMENT",
                path=str(NS_DIR.relative_to(REPO_ROOT)),
                detail=(
                    f"Contracted theorem '{name}' not found. "
                    "Forbidden-fragment contracts must reference existing theorems."
                ),
            ))
            continue

        rel, stripped, start = index[name]
        ln = _line_of(stripped, start)
        _, body = _extract_theorem_signature_and_body(stripped, start)
        if not body:
            violations.append(ContractViolation(
                id=f"forbidden_body_fragment:{name}:no_body",
                rule="FORBIDDEN_BODY_FRAGMENT",
                path=rel,
                line=ln,
                detail=f"Could not locate theorem body for '{name}'.",
            ))
            continue

        for fragment in forbidden_fragments:
            if fragment in body:
                violations.append(ContractViolation(
                    id=f"forbidden_body_fragment:{name}:{fragment}",
                    rule="FORBIDDEN_BODY_FRAGMENT",
                    path=rel,
                    line=ln,
                    detail=(
                        f"Theorem '{name}' body contains forbidden fragment '{fragment}'. "
                        "This indicates regression to a vacuous/default-witness proof path."
                    ),
                ))


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def run(policy_path: Path, output_path: Path, strict: bool) -> int:
    policy = _load_policy(policy_path)

    gate_discharge_theorems: List[str] = policy["gate_discharge_theorems"]
    gate_def_name: str = policy["gate_def_name"]
    gate_def_nontrivial_substring: str = policy["gate_def_nontrivial_substring"]
    gate_bridge_module: str = policy["gate_bridge_module"]
    physical_route_contracts: List[Tuple[str, str]] = [
        (entry["theorem"], entry["hypothesis"])
        for entry in policy["physical_route_contracts"]
    ]
    delta_route_contracts: List[Tuple[str, str]] = [
        (entry["theorem"], entry["signature_contains"])
        for entry in policy.get("delta_route_contracts", [])
    ]
    assumption_usage_contracts: List[Tuple[str, List[str]]] = [
        (entry["theorem"], entry.get("body_contains", []))
        for entry in policy.get("assumption_usage_contracts", [])
    ]
    theorem_only_contracts: List[str] = policy.get("theorem_only_contracts", [])
    file_axiom_scope_contracts: List[dict] = policy.get("file_axiom_scope_contracts", [])
    forbidden_body_fragment_contracts: List[Tuple[str, List[str]]] = [
        (entry["theorem"], entry.get("forbidden_body_contains", []))
        for entry in policy.get("forbidden_body_fragment_contracts", [])
    ]

    violations: List[ContractViolation] = []

    check_gate_is_theorem(violations, gate_discharge_theorems)
    check_gate_not_trivial(violations, gate_def_name, gate_def_nontrivial_substring)
    check_gate_import_present(violations, gate_bridge_module)
    check_gate_hypothesis_present(violations, physical_route_contracts)
    check_delta_route_present(violations, delta_route_contracts)
    check_bridge_axiom_scope(violations)
    check_file_axiom_scope_contracts(violations, file_axiom_scope_contracts)
    check_assumption_usage_present(violations, assumption_usage_contracts)
    check_theorem_only_present(violations, theorem_only_contracts)
    check_forbidden_body_fragments(violations, forbidden_body_fragment_contracts)

    passed = len(violations) == 0

    output = {
        "check": "ns_physical_theorem_contracts",
        "policy": str(policy_path),
        "policy_version": policy.get("version", 0),
        "strict": bool(strict),
        "pass": passed,
        "violation_count": len(violations),
        "contracts_checked": [
            "GATE_IS_THEOREM",
            "GATE_NOT_TRIVIAL",
            "GATE_IMPORT_PRESENT",
            "GATE_HYPOTHESIS_PRESENT",
            "DELTA_ROUTE_PRESENT",
            "BRIDGE_AXIOM_SCOPE",
            "FILE_AXIOM_SCOPE",
            "ASSUMPTION_USAGE_PRESENT",
            "THEOREM_ONLY_PRESENT",
            "FORBIDDEN_BODY_FRAGMENT",
        ],
        "gate_discharge_theorems": gate_discharge_theorems,
        "gate_def": gate_def_name,
        "gate_bridge_module": gate_bridge_module,
        "physical_route_contracts": len(physical_route_contracts),
        "delta_route_contracts": len(delta_route_contracts),
        "file_axiom_scope_contracts": len(file_axiom_scope_contracts),
        "assumption_usage_contracts": len(assumption_usage_contracts),
        "theorem_only_contracts": len(theorem_only_contracts),
        "forbidden_body_fragment_contracts": len(forbidden_body_fragment_contracts),
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
    print(f"policy={policy_path}")
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
        "--policy",
        type=Path,
        default=DEFAULT_POLICY,
        help="Path to the policy JSON file (default: alongside this script)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
    )
    parser.add_argument("--strict", action="store_true", default=False)
    args = parser.parse_args()
    return run(args.policy.resolve(), args.output.resolve(), strict=bool(args.strict))


if __name__ == "__main__":
    raise SystemExit(main())
