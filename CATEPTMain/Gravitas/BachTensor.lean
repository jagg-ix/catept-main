import CATEPTGravitasPort.BachTensor

/-!
# BachTensor — re-export shim
Authoritative source: `CATEPTGravitasPort.BachTensor` in sibling repo
[`jagg-ix/catept-gravitas-port`](https://github.com/jagg-ix/catept-gravitas-port).

Gravitas declares bare top-level namespaces (e.g. `namespace BachTensor`) per
the upstream Wolfram Mathematica port convention, so this shim is
import-only — no `export` clause needed. The bare namespace is in scope
wherever this shim is imported.
-/
