import CATEPTMain.Domains.CoherenceSpine
import CATEPTMain.Domains.UnifiedValidator

/-!
# Coherence Spine + UnifiedValidator — Kernel-Axiom Showcase

Inline `#print axioms` audit for the three adapters, the coherence-spine
theorem, AND the per-adapter unified-validator instances (T66).

Expected (every line on `[propext, Classical.choice, Quot.sound]`):

  Spine theorems (T65):
    minkowski_satisfies_spine
    em_satisfies_spine
    vml_satisfies_spine
    coherence_spine_GR_EM_VML
    live_dynamics_EM_VML

  Per-invariant adapter claims (T66e):
    minkowski_conservation / _reduction / _symmetry / _quantum_correspondence
    em_conservation / em_reduction / em_symmetry  (μ₀=1, hμ₀=one_pos applied below)
    vml_conservation / vml_reduction / vml_symmetry

  Unified validators (T66f):
    minkowski_validates  — spine + 4 invariants (vacuum tier)
    em_validates         — spine + 3 invariants (no quantum-correspondence)
    vml_validates        — spine + 3 invariants (no quantum-correspondence)

Any axiom outside `[propext, Classical.choice, Quot.sound]` is a regression.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal

open Adapter

-- ── Concrete UnifiedValidator instances (one per adapter) ────────────

/-- Minkowski validates against ALL four invariants (vacuum tier). -/
theorem minkowski_validates :
    UnifiedValidator
      minkowski
      (some minkowski_conservation)
      (some minkowski_reduction)
      (some minkowski_symmetry)
      (some minkowski_quantum_correspondence) :=
  UnifiedValidator.full
    minkowski
    minkowski_conservation
    minkowski_reduction
    minkowski_symmetry
    minkowski_quantum_correspondence

/-- EM validates against three invariants (Conservation/Reduction/
    Symmetry); QuantumCorrespondence not claimed. -/
theorem em_validates (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    UnifiedValidator
      (em μ₀ hμ₀)
      (some <| em_conservation μ₀ hμ₀)
      (some <| em_reduction μ₀ hμ₀)
      (some <| em_symmetry μ₀ hμ₀)
      none :=
  ⟨(em μ₀ hμ₀).coherence_spine,
   (em_conservation μ₀ hμ₀).divergence_free,
   (em_reduction μ₀ hμ₀).reduces_classically,
   (em_symmetry μ₀ hμ₀).clock_invariant,
   trivial⟩

/-- VML validates against three invariants; QuantumCorrespondence not
    claimed (the bridge requires QM machinery beyond the current scope). -/
theorem vml_validates :
    UnifiedValidator
      vml
      (some vml_conservation)
      (some vml_reduction)
      (some vml_symmetry)
      none :=
  ⟨vml.coherence_spine,
   vml_conservation.divergence_free,
   vml_reduction.reduces_classically,
   vml_symmetry.clock_invariant,
   trivial⟩

end CATEPTMain.Temporal

-- ═══════════════════════════════════════════════════════════════════════
-- KERNEL-AXIOM AUDIT
-- ═══════════════════════════════════════════════════════════════════════

-- Spine theorems (T65, retained):
#print axioms CATEPTMain.Temporal.Adapter.minkowski_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.em_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.vml_satisfies_spine
#print axioms CATEPTMain.Temporal.coherence_spine_GR_EM_VML
#print axioms CATEPTMain.Temporal.live_dynamics_EM_VML

-- Per-invariant adapter claims (T66e):
#print axioms CATEPTMain.Temporal.Adapter.minkowski_conservation
#print axioms CATEPTMain.Temporal.Adapter.minkowski_reduction
#print axioms CATEPTMain.Temporal.Adapter.minkowski_symmetry
#print axioms CATEPTMain.Temporal.Adapter.minkowski_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.em_conservation
#print axioms CATEPTMain.Temporal.Adapter.em_reduction
#print axioms CATEPTMain.Temporal.Adapter.em_symmetry
#print axioms CATEPTMain.Temporal.Adapter.vml_conservation
#print axioms CATEPTMain.Temporal.Adapter.vml_reduction
#print axioms CATEPTMain.Temporal.Adapter.vml_symmetry

-- UnifiedValidator instances (T66f):
#print axioms CATEPTMain.Temporal.minkowski_validates
#print axioms CATEPTMain.Temporal.em_validates
#print axioms CATEPTMain.Temporal.vml_validates
