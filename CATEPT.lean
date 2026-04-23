-- Root aggregator for the `CATEPT` lean_lib.
-- Imports the axiom-free CAT/EPT core (`CATEPT.CATEPT.*`) plus the
-- compatibility bridges (`CATEPT.Bridges.*`). See `CATEPT/Bridges/`
-- for one-file-per-domain pphi2N / QFT / GR / Gravitas demonstrations.

-- Note: `CATEPT.CATEPT.Basic` carries legacy v4.24 idioms (renamed Mathlib
-- imports, `λ` used as a value-level identifier) that are incompatible
-- with Lean 4.29 and have not yet been migrated. Omitted from the
-- aggregator until those are fixed; the rest of `CATEPT.CATEPT.*` and the
-- full `CATEPT.Bridges.*` surface build clean.
import CATEPT.CATEPT.Foundations
import CATEPT.CATEPT.PathIntegrals
import CATEPT.CATEPT.QuantumGravity
import CATEPT.CATEPT.QFTGRClosures
import CATEPT.CATEPT.Core
import CATEPT.Bridges.Pphi2N
import CATEPT.Bridges.QFT
import CATEPT.Bridges.GR
import CATEPT.Bridges.Gravitas
