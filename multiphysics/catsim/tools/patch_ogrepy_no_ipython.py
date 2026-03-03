#!/usr/bin/env python3
"""Patch OGRePy to run in plain Python (no IPython/Jupyter required).

This repository originally integrated OGRePy in a notebook-heavy workflow.
If you want to run CAT/EPT + OGRePy bridges from a terminal / CI / i-PI driver,
OGRePy's optional rich-display features can become a hard dependency on IPython.

This script applies a *minimal*, forward-compatible source patch to OGRePy's
`OGRePy/_core.py`:
- remove IPython imports
- force `_in_notebook = False`
- make `_display_markdown` and `_display_tex` fall back to `print()`

It is intentionally conservative: it does NOT delete any public API.

Usage:
  # 1) Patch an OGRePy git checkout
  python tools/patch_ogrepy_no_ipython.py /path/to/OGRePy

  # 2) Patch the *installed* OGRePy (site-packages) (may require venv write access)
  python tools/patch_ogrepy_no_ipython.py --installed

Notes:
- Always review diffs before committing upstream.
- If OGRePy upstream changes, this script may require small updates.
"""

from __future__ import annotations

import argparse
import pathlib
import re
import shutil
import sys
from typing import Optional


IPYTHON_IMPORT_RE = re.compile(
    r"^\s*from\s+IPython\.[^\n]+\n", re.MULTILINE
)


def _read_text(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


def _write_text(p: pathlib.Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")


def _patch_core_text(text: str) -> tuple[str, list[str]]:
    changes: list[str] = []

    # 1) Remove IPython imports.
    new_text, n = IPYTHON_IMPORT_RE.subn("", text)
    if n:
        changes.append(f"removed {n} IPython import lines")
    text = new_text

    # 2) Force _in_notebook = False.
    # OGRePy uses get_ipython().__class__.__name__ checks; we replace the assignment.
    text2, n2 = re.subn(
        r"^_in_notebook\s*:\s*bool\s*=\s*.*$",
        "_in_notebook: bool = False",
        text,
        flags=re.MULTILINE,
    )
    if n2:
        changes.append("forced _in_notebook: bool = False")
        text = text2

    # 3) Replace _display_markdown definition body with print.
    # Keep the function signature stable.
    def repl_display_markdown(m: re.Match[str]) -> str:
        changes.append("rewrote _display_markdown to print()")
        return (
            m.group(1)
            + "\n    \"\"\"Display text in a plain Python environment.\"\"\"\n\n"
            + "    print(text)  # noqa: T201\n"
        )

    text3, n3 = re.subn(
        r"(def\s+_display_markdown\(\s*\n\s*text:\s*str,\s*\n\)\s*->\s*None:\s*)\n(?:    .*\n)+?(?=def\s+_display_tex\(|\Z)",
        repl_display_markdown,
        text,
        flags=re.MULTILINE,
    )
    if n3:
        text = text3

    # 4) Replace _display_tex body with print.
    def repl_display_tex(m: re.Match[str]) -> str:
        changes.append("rewrote _display_tex to print()")
        return (
            m.group(1)
            + "\n    \"\"\"Display TeX verbatim in a plain Python environment.\"\"\"\n\n"
            + "    print(tex)  # noqa: T201\n"
        )

    text4, n4 = re.subn(
        r"(def\s+_display_tex\(\s*\n\s*tex:\s*str,\s*\n\)\s*->\s*None:\s*)\n(?:    .*\n)+?(?=def\s+_filter_classes\(|\Z)",
        repl_display_tex,
        text,
        flags=re.MULTILINE,
    )
    if n4:
        text = text4

    return text, changes


def patch_ogrepy_root(root: pathlib.Path) -> pathlib.Path:
    core = root / "OGRePy" / "_core.py"
    if not core.exists():
        raise FileNotFoundError(f"Could not find OGRePy/_core.py under: {root}")

    original = _read_text(core)
    patched, changes = _patch_core_text(original)

    if not changes:
        print("No changes detected; file may already be patched.")
        return core

    backup = core.with_suffix(".py.bak")
    if not backup.exists():
        shutil.copy2(core, backup)

    _write_text(core, patched)

    print("Patched:", core)
    print("Backup:", backup)
    print("Changes:")
    for c in changes:
        print(" -", c)

    return core


def _guess_installed_root() -> Optional[pathlib.Path]:
    try:
        import OGRePy  # type: ignore

        pkg = pathlib.Path(OGRePy.__file__).resolve()
        # OGRePy/__init__.py -> OGRePy
        return pkg.parent
    except Exception:
        return None


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "root",
        nargs="?",
        default=None,
        help="Path to OGRePy repository root (containing OGRePy/_core.py).",
    )
    ap.add_argument(
        "--installed",
        action="store_true",
        help="Patch the installed OGRePy package (site-packages).",
    )
    args = ap.parse_args(argv)

    if args.installed:
        root = _guess_installed_root()
        if root is None:
            print("Could not locate an installed OGRePy. Install it or pass a path.")
            return 2
        # installed root is .../site-packages/OGRePy; we want its parent
        # because patch_ogrepy_root expects root/OGRePy/_core.py.
        patch_root = root.parent
        patch_ogrepy_root(patch_root)
        return 0

    if args.root is None:
        ap.print_help()
        return 2

    patch_ogrepy_root(pathlib.Path(args.root).expanduser().resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
