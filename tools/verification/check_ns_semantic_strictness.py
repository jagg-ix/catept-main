#!/usr/bin/env python3
"""Semantic strictness guard for Navier-Stokes Lean formalization.

Purpose:
- Catch regressions where physical observables are reintroduced as zero placeholders.
- Catch vacuous-promotion markers that indicate theorem claims were closed by
  placeholder collapse rather than physical content.
- Catch explicit "open-axiom list is zero" drift in files that still declare
  open axioms.

This checker is intentionally conservative and supports an explicit allowlist for
known debt so CI can block new regressions without pretending old debt is closed.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple


REPO_ROOT = Path(__file__).resolve().parents[2]
NS_DIR = REPO_ROOT / "lean4_formal_verification" / "NavierStokes" / "NavierStokes"
DEFAULT_ALLOWLIST = (
    REPO_ROOT / "tools" / "verification" / "ns_semantic_strictness_allowlist.json"
)
DEFAULT_OUTPUT = (
    REPO_ROOT / "verification_results" / "stack_audits" / "ns_semantic_strictness.json"
)


@dataclass
class Finding:
    id: str
    rule: str
    path: str
    detail: str
    line: int


def _strip_lean_comments(text: str) -> str:
    """Strip Lean line/block comments while preserving line breaks."""
    out: List[str] = []
    i = 0
    n = len(text)
    block_depth = 0
    in_string = False

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
            # Preserve newlines to keep line numbers stable.
            out.append("\n" if ch == "\n" else " ")
            i += 1
            continue

        if in_string:
            out.append(ch)
            if ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue

        if ch == "/" and nxt == "-":
            block_depth = 1
            out.extend("  ")
            i += 2
            continue

        if ch == "-" and nxt == "-":
            # Consume until newline.
            while i < n and text[i] != "\n":
                out.append(" ")
                i += 1
            continue

        out.append(ch)
        i += 1

    return "".join(out)


def _line_number_from_offset(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def _scan_zero_placeholder_observables(rel_path: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    stripped = _strip_lean_comments(text)
    rx = re.compile(
        r"^\s*(?:noncomputable\s+)?def\s+"
        r"(enstrophy|kineticEnergy|vorticityLinfty|palinstrophy)\b"
        r"[^\n]*:=\s*0\b",
        re.MULTILINE,
    )
    for m in rx.finditer(stripped):
        name = m.group(1)
        line = _line_number_from_offset(stripped, m.start())
        fid = f"zero_placeholder_observable:{rel_path}:{name}"
        detail = f"Observable '{name}' is defined as constant zero."
        findings.append(Finding(fid, "zero_placeholder_observable", rel_path, detail, line))
    return findings


def _scan_vacuous_markers(rel_path: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    markers: List[Tuple[str, str]] = [
        ("all opaque terms zero", "all_opaque_terms_zero"),
    ]
    lowered = text.lower()
    for literal, token in markers:
        idx = lowered.find(literal)
        while idx != -1:
            line = _line_number_from_offset(text, idx)
            fid = f"vacuous_marker:{rel_path}:{token}"
            detail = f"Found vacuous marker phrase: '{literal}'."
            findings.append(Finding(fid, "vacuous_marker", rel_path, detail, line))
            idx = lowered.find(literal, idx + 1)
    return findings


def _scan_open_axiom_registry_drift(rel_path: str, text: str) -> List[Finding]:
    findings: List[Finding] = []
    stripped = _strip_lean_comments(text)

    # Targeted anti-drift rule for V2 registry claim.
    claim_rx = re.compile(
        r"theorem\s+qifV2AllOpenAxioms_length\s*:\s*qifV2AllOpenAxioms\.length\s*=\s*0",
        re.MULTILINE,
    )
    if not claim_rx.search(stripped):
        return findings

    qif_axiom_count = len(re.findall(r"^\s*axiom\s+qif_", stripped, flags=re.MULTILINE))
    if qif_axiom_count > 0:
        m = claim_rx.search(stripped)
        assert m is not None
        line = _line_number_from_offset(stripped, m.start())
        fid = f"open_axiom_registry_drift:{rel_path}:qifV2AllOpenAxioms_length"
        detail = (
            "Claims qifV2AllOpenAxioms.length = 0 while file still declares "
            f"{qif_axiom_count} 'axiom qif_*' declarations."
        )
        findings.append(Finding(fid, "open_axiom_registry_drift", rel_path, detail, line))
    return findings


def _load_allowlist(path: Path) -> Dict[str, object]:
    if not path.exists():
        return {"allowed_ids": []}
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"Invalid allowlist format at {path}")
    allowed_ids = payload.get("allowed_ids", [])
    if not isinstance(allowed_ids, list) or not all(isinstance(x, str) for x in allowed_ids):
        raise ValueError(f"allowlist.allowed_ids must be a list of strings at {path}")
    return payload


def run(allowlist_path: Path, output_path: Path, strict: bool) -> int:
    all_findings: List[Finding] = []

    for p in sorted(NS_DIR.glob("*.lean")):
        rel_path = str(p.relative_to(REPO_ROOT))
        text = p.read_text(encoding="utf-8", errors="replace")
        all_findings.extend(_scan_zero_placeholder_observables(rel_path, text))
        all_findings.extend(_scan_vacuous_markers(rel_path, text))
        all_findings.extend(_scan_open_axiom_registry_drift(rel_path, text))

    allowlist_payload = _load_allowlist(allowlist_path)
    allowed_ids = set(allowlist_payload.get("allowed_ids", []))

    allowed_findings = [f for f in all_findings if f.id in allowed_ids]
    violating_findings = [f for f in all_findings if f.id not in allowed_ids]

    stale_allowlist_ids = sorted(
        aid for aid in allowed_ids if all(f.id != aid for f in all_findings)
    )

    output = {
        "check": "ns_semantic_strictness",
        "strict": bool(strict),
        "allowlist_path": str(allowlist_path),
        "total_findings": len(all_findings),
        "allowed_findings": len(allowed_findings),
        "violating_findings": len(violating_findings),
        "stale_allowlist_ids": stale_allowlist_ids,
        "pass": len(violating_findings) == 0 and len(stale_allowlist_ids) == 0,
        "findings": [
            {
                "id": f.id,
                "rule": f.rule,
                "path": f.path,
                "line": f.line,
                "detail": f.detail,
                "allowlisted": f.id in allowed_ids,
            }
            for f in sorted(all_findings, key=lambda x: (x.path, x.line, x.id))
        ],
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")

    print(f"status={'pass' if output['pass'] else 'fail'}")
    print(f"total_findings={output['total_findings']}")
    print(f"violating_findings={output['violating_findings']}")
    print(f"stale_allowlist_ids={len(stale_allowlist_ids)}")
    print(f"output={output_path}")

    if strict and not output["pass"]:
        return 2
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--allowlist", type=Path, default=DEFAULT_ALLOWLIST)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--strict", action="store_true", default=False)
    args = parser.parse_args()
    return run(args.allowlist.resolve(), args.output.resolve(), strict=bool(args.strict))


if __name__ == "__main__":
    raise SystemExit(main())

