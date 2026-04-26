import CATEPTGravitasPort.SchoutenTensor

/-!
# SchoutenTensor — re-export shim
Authoritative source: `CATEPTGravitasPort.SchoutenTensor` in sibling repo
[`jagg-ix/catept-gravitas-port`](https://github.com/jagg-ix/catept-gravitas-port).

Gravitas declares bare top-level namespaces (e.g. `namespace SchoutenTensor`) per
the upstream Wolfram Mathematica port convention, so this shim is
import-only — no `export` clause needed. The bare namespace is in scope
wherever this shim is imported.
-/
