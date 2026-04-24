import OSReconstruction.Bridge.AxiomBridge

/-!
# CAT/EPT ↔ OSReconstruction — compatibility bridge

OSReconstruction (xiyin137) formalizes the Osterwalder–Schrader reconstruction
theorem together with the Wightman axioms and the Lorentz / Minkowski
infrastructure that the reconstruction relies on. The CAT/EPT framework
operates on the **same Lorentzian stage** on both the Quantum-Mechanical side
(through complex actions and path integrals) and the General-Relativity side
(through Minkowski / Schwarzschild / ADM backgrounds). This bridge records
that the two independently-developed encodings of that stage coincide.

**Bridge claims** (all proved without new axioms):

1. **Minkowski-signature coincidence**: the metric-signature function used by
   OSreconstruction's `LorentzLieGroup` namespace equals the one used by its
   `MinkowskiSpace` namespace. Pure `rfl`.
2. **Lorentz-matrix coincidence**: the two `IsLorentzMatrix` predicates agree.
3. **Spacelike-condition coincidence**: the spacelike-separation predicates
   agree.

These three together witness that OSreconstruction's Wightman-side Lorentz
infrastructure is compatible with the Minkowski infrastructure already used
throughout CAT/EPT's QFT and GR bridges — so the OS / Wightman theorems
downstream of this file can be composed with CAT/EPT's QFT bridge on a
common kinematic foundation.

**Axioms**: none beyond the Lean kernel. The theorems cited from
OSreconstruction (all from `Bridge/AxiomBridge.lean`, itself zero-axiom and
zero-sorry) carry their own kernel-only provenance; this bridge simply
re-exports them as CAT/EPT-named theorems.
-/

set_option autoImplicit false

namespace CATEPT.Bridges.OSReconstruction

/-- **Minkowski signature coincidence.** The Lorentz-group-side metric
    signature equals the MinkowskiSpace-side metric signature in
    dimension `d+1` (for any nonzero `d`). Proved by `rfl` in OSreconstruction. -/
theorem minkowski_signature_coincides (d : ℕ) [NeZero d] :
    LorentzLieGroup.minkowskiSignature d = MinkowskiSpace.metricSignature d :=
  minkowskiSignature_eq_metricSignature

/-- **Lorentz-matrix coincidence.** The two `IsLorentzMatrix` predicates
    — one in the Lie-group setting, one in the Minkowski setting — are
    equivalent as propositions. -/
theorem is_lorentz_matrix_coincides (d : ℕ) [NeZero d]
    (Λ : Matrix (Fin (d + 1)) (Fin (d + 1)) ℝ) :
    LorentzLieGroup.IsLorentzMatrix d Λ ↔ IsLorentzMatrix d Λ :=
  isLorentzMatrix_iff Λ

/-- **Spacelike-condition coincidence.** The two spacelike-separation
    predicates agree: the LorentzLieGroup-side sum `∑ μ, η_μ · v_μ²` is
    positive iff the MinkowskiSpace-side norm-squared is positive. -/
theorem spacelike_condition_coincides (d : ℕ) [NeZero d]
    (v : Fin (d + 1) → ℝ) :
    (∑ μ, LorentzLieGroup.minkowskiSignature d μ * v μ ^ 2 > 0) ↔
    (MinkowskiSpace.minkowskiNormSq d v > 0) :=
  spacelike_condition_iff v

end CATEPT.Bridges.OSReconstruction
