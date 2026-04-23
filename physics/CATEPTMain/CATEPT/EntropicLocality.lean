import CATEPTMain.CATEPT.GeometryGauge

/-!
# EntropicLocality (Compatibility Re-export)

This module now re-exports `CATEPTMain.CATEPT.GeometryGauge` to avoid
redeclaring the same `CATEPT` namespace constants in two files.

Any downstream import of `CATEPTMain.CATEPT.EntropicLocality` continues to
see the same `CATEPT.*` declarations, now sourced from a single definition site.
-/
