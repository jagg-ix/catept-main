import CATEPTGravitasPort.RicciTensor

/-!
# RicciTensor — re-export shim
Authoritative source: `CATEPTGravitasPort.RicciTensor` in sibling repo
[`jagg-ix/catept-gravitas-port`](https://github.com/jagg-ix/catept-gravitas-port).

Gravitas declares bare top-level namespaces (e.g. `namespace RicciTensor`) per
the upstream Wolfram Mathematica port convention, so this shim is
import-only — no `export` clause needed. The bare namespace is in scope
wherever this shim is imported.
-/
