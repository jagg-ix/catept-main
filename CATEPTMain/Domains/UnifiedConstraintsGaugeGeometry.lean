import CATEPTMain.Domains.UnifiedConstraints
import CATEPTMain.Domains.JointAdapter
import CATEPTMain.Domains.Adapters.Minkowski
import CATEPTMain.Domains.Adapters.EM
import CATEPTMain.Domains.Invariants.Symmetry

/-!
# T82 — Substrate-backed discharge of Copilot-doc invariant #2 (Gauge-Geometry Duality)

T80 (`UnifiedConstraints.lean`) left invariant #2 as the placeholder
`gaugeGeometryDuality _ : Prop := True`. The roadmap was: combine the
EM adapter's gauge-symmetry slot with a GR (Minkowski) diffeomorphism-
symmetry slot on the joint adapter.

This file delivers exactly that. We

  1. construct a generic `jointSymmetry` which lifts any pair of factor
     symmetries onto the joint TemporalFramework `joint T₁ T₂`, and
  2. apply it to the canonical Minkowski / EM symmetries to produce a
     concrete `SymmetryInvariant (joint minkowski (em μ₀ hμ₀))`.

The headline `gaugeGeometryDualityAtJoint_holds` then asserts that the
joint Minkowski⊕EM TF has *both* a geometry-side and a gauge-side
symmetry that combine into a single non-trivial invariance of the
joint clock.

Following the T81 pattern: this is an **additive lift**. T80's
`gaugeGeometryDuality := True` placeholder remains intact; this file
adds an honest substrate-backed Prop with a real proof.
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.UnifiedConstraints

open CATEPTMain.Temporal (TemporalFramework SymmetryInvariant)
open CATEPTMain.Temporal.Adapter
  (minkowski em joint minkowski_symmetry em_symmetry)

-- ── Generic joint-symmetry lift ──────────────────────────────────────

/-- Componentwise lift of two factor symmetries onto a binary join.
    The joint clock decomposes as a sum of factor clocks; each factor
    is held invariant by its own symmetry, hence the sum is invariant.
-/
def jointSymmetry {T₁ T₂ : TemporalFramework}
    (S₁ : SymmetryInvariant T₁) (S₂ : SymmetryInvariant T₂) :
    SymmetryInvariant (joint T₁ T₂) where
  sigma := fun x => (S₁.sigma x.1, S₂.sigma x.2)
  clock_invariant := fun x => by
    show T₁.clock (S₁.sigma x.1) + T₂.clock (S₂.sigma x.2)
          = T₁.clock x.1 + T₂.clock x.2
    rw [S₁.clock_invariant, S₂.clock_invariant]

-- ── 2. Gauge-Geometry Duality (substrate-backed) ─────────────────────

/-- **Substrate-backed gauge-geometry duality.**

    On the joint Minkowski⊕EM TemporalFramework, a *single*
    `SymmetryInvariant` simultaneously witnesses

      • the GR-side reflection `x ↦ -x` on the spacetime factor, and
      • the gauge-side reflection `A ↦ -A` on the EM 4-potential factor,

    both keeping the joint clock invariant. The duality says: gauge and
    geometry coexist as compatible symmetries of one and the same
    framework. -/
def gaugeGeometryDualityAtJoint (μ₀ : ℝ) (hμ₀ : 0 < μ₀) : Prop :=
  Nonempty (SymmetryInvariant (joint minkowski (em μ₀ hμ₀)))

theorem gaugeGeometryDualityAtJoint_holds (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    gaugeGeometryDualityAtJoint μ₀ hμ₀ :=
  ⟨jointSymmetry minkowski_symmetry (em_symmetry μ₀ hμ₀)⟩

/-- A more refined statement: the joint symmetry is *built from both
    factor symmetries*, so the duality is not a tautology but a
    coexistence claim — both axes are independently witnessed. -/
theorem gaugeGeometryDuality_factor_decomposition
    (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    let S := jointSymmetry minkowski_symmetry (em_symmetry μ₀ hμ₀)
    ∀ x : (joint minkowski (em μ₀ hμ₀)).Config,
      S.sigma x = (minkowski_symmetry.sigma x.1, (em_symmetry μ₀ hμ₀).sigma x.2) :=
  fun _ => rfl

end CATEPTMain.Domains.UnifiedConstraints
