/-!
# OCT Translation Worklog — Octonions → Lean 4
Source: AFP `Octonions`
  (Tevita O. Taufa — 2021)
  https://www.isa-afp.org/entries/Octonions.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.OCT)
License: BSD

Prior version: none — first translation.
Methodology note: Octonions are non-associative — they form an alternative
  composition algebra. Mathlib does NOT yet have an `Octonion` type (as of Lean 4.29).
  Phase-1 uses opaque `OctonionR` type with axioms for the product,
  norm, and alternative law.

AFP entry abstract:
  Defines the octonion algebra 𝕆 = {∑ eᵢ aᵢ | aᵢ ∈ ℝ, i = 0..7} using the
  Cayley-Dickson doubling construction applied to ℍ. Proves:
  - Bilinearity and anti-commutativity of the imaginary parts
  - Non-associativity in general; alternative law: x(xy) = (xx)y, (xy)y = x(yy)
  - Composition algebra property: ‖xy‖ = ‖x‖ · ‖y‖
  - Moufang identities
  - Connection to exceptional Lie group G₂

AFP session file order:
  1.  Octonions             (definition via Cayley-Dickson, basic algebra)
  2.  Octonion_Alternative  (alternative law proof)
  3.  Octonion_Norm         (composition algebra: ‖xy‖ = ‖x‖‖y‖)
  4.  Moufang               (Moufang identities)

AFP direct dependencies:
  - Quaternions (QUAT — see QUATPrelude.lean)
  - HOL-Analysis

Mathlib modules used as semantic targets (phase-2):
  - (No direct Mathlib Octonion type yet)
  - Mathlib.Algebra.Algebra.CayleyDickson  (if/when Octonion is added)

BINDER RULES:
  B85: AFP `(x : octonion)` → `(x : OctonionR)` (opaque)
  B86: octonion multiplication → `octMul x y` (NOT `*` — non-associative)
  B87: composition algebra norm → `octNorm x` (NOT Mathlib ‖x‖ — not proved equal yet)
  B88: imaginary units `e₁, ..., e₇` → `octBasis i : OctonionR`

Phase record (cumulative):
  TH001–TH019: OCT theorems translated
-/
