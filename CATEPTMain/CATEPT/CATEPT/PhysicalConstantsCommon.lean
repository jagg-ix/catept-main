import Mathlib.Data.Real.Basic

/-!
# `PhysicalConstants` — single canonical definition (T101)

Resolves a pre-existing namespace collision: four files in
`CATEPTMain.CATEPT.CATEPT.*` each defined `structure PhysicalConstants`
in the same namespace, blocking simultaneous import:

  - `NoetherEPT.lean`             (2 fields: hbar, hbar_pos)
  - `GeometryGauge.lean`          (4 fields: hbar, kB, c, hbar_pos)
  - `AQFTFoundations.lean`        (4 fields: hbar, kB, c, hbar_pos)
  - `TemporalOrderAndReduction.lean` (4 fields: hbar, kB, c, hbar_pos)

This file ships ONE canonical structure with the 4-field superset
(NoetherEPT uses only `hbar` / `hbar_pos`, so it builds against this
superset unchanged). The four redefining files now `import` this
file instead of redefining `PhysicalConstants` locally.

After T101, `import`ing any combination of the four files no longer
triggers `environment already contains 'PhysicalConstants.recOn'`,
which unblocks audit-gate inclusion of the substantive Noether
theorems in `NoetherEPT.lean`.
-/

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

/-- Physical constants used across CAT/EPT bridges.

    Canonical 6-field superset matching the pre-T101 definitions in
    `GeometryGauge.lean`, `AQFTFoundations.lean`, and
    `TemporalOrderAndReduction.lean`. The pre-T101 `NoetherEPT.lean`
    version had only `hbar` / `hbar_pos`; consumers there use only
    those two fields, so they build against this superset. -/
structure PhysicalConstants where
  hbar : ℝ
  kB   : ℝ
  c    : ℝ
  hbar_pos : 0 < hbar
  kB_pos   : 0 < kB
  c_pos    : 0 < c

end CATEPTMain.CATEPT.CATEPT
