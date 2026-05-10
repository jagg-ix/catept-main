import CATEPTMain.Bridges.PhyslibRelativityBridge.MinkowskiBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.ProperTimeBridge

/-!
# SR Bridge Certificate

This module bundles the individual bridge theorems into a single
`PhyslibSRBridgeCertificate` structure.  Instantiating it with
`cateptEquivPhyslib` constitutes the formal claim:

> **CATEPT finite Minkowski spacetime is a sign-convention-equivalent model
> of Physlib `SpaceTime 3`, preserving the Lorentz metric, causal structure,
> and the proper-time formula.**

The SL(2,ℂ) spinor compatibility is certified separately in
`SpinorBridgeCertificate` (`PhyslibSRSpinorBridgeCertificate`), which
`extends` this structure.

## What this does NOT yet cover

- General Relativity: metric/tensor pullbacks, Levi-Civita compatibility,
  curvature/Einstein-tensor bridge.  GR needs a separate certificate layer.
- Curved-spacetime entropic-time identification: the claim
  `τ_ent = SpaceTime.properTime` holds in the flat Minkowski sector; the
  extension to curved spacetimes requires additional hypotheses.

## Certificate structure

```
PhyslibSRBridgeCertificate          -- this file
  toPhys        : CATEPTST ≃ₗ[ℝ] SpaceTime 3
  metric_compat : ∀ x, catept_metric = −physlib_metric ∘ toPhys
  timelike_compat : ∀ x, CausalTimelike x ↔ Physlib timeLike (toPhys x)
  properTime_compat : ∀ q p, CATEPT interval = Physlib properTime

PhyslibSRSpinorBridgeCertificate    -- SpinorBridgeCertificate.lean (extends above)
  toSelfAdjoint  : CATEPTST →ₗ[ℝ] selfAdjoint (Matrix (Fin 2) (Fin 2) ℂ)
  det_compat     : ∀ x, det = (−minkowskiNorm2 x : ℂ)
  sl2c_intertwines : SL(2,ℂ) action commutes with toSelfAdjoint
```
-/

open CATEPTMain.Geometry.FiniteMinkowski
open Lorentz Vector SpaceTime

namespace CATEPTMain.Bridges.PhyslibRelativityBridge

/-- A certificate bundling all SR-sector compatibility proofs between the CATEPT
finite Minkowski model and Physlib's `SpaceTime 3`.

This is a **conservative extension certificate**: it asserts that the CATEPT
adapter adds no contradiction to Physlib and preserves the four central
structures of special relativity. -/
structure PhyslibSRBridgeCertificate where
  /-- The underlying linear isomorphism between spacetime types. -/
  toPhys : CATEPTST ≃ₗ[ℝ] SpaceTime 3
  /-- Metric compatibility: CATEPT's `(−+++)` norm is the exact negation of
  Physlib's `(+−−−)` Minkowski product under the bridge. -/
  metric_compat :
    ∀ x : CATEPTST,
      minkowskiNorm2 x =
      - minkowskiProductMap (toPhys x) (toPhys x)
  /-- Causality compatibility: `CausalTimelike` and Physlib `.timeLike`
  classify the same vectors. -/
  timelike_compat :
    ∀ x : CATEPTST,
      CausalTimelike x ↔
      causalCharacter (toPhys x) = .timeLike
  /-- Proper-time compatibility: the CATEPT interval formula equals Physlib's
  `properTime` for all pairs (not just timelike ones). -/
  properTime_compat :
    ∀ q p : CATEPTST,
      Real.sqrt (-(minkowskiNorm2 (p - q))) =
      properTime (toPhys q) (toPhys p)

/-- The canonical instance of `PhyslibSRBridgeCertificate`, built from the
theorems proved in `MinkowskiBridge` and `ProperTimeBridge`. -/
noncomputable def cateptPhyslibSRBridge : PhyslibSRBridgeCertificate where
  toPhys          := cateptEquivPhyslib
  metric_compat   := minkowskiNorm2_eq_neg_physlib
  timelike_compat := causalTimelike_iff_physlib_timeLike
  properTime_compat := catept_sqrt_interval_eq_physlib_properTime

/-! ## Corollaries from the certificate -/

/-- Any `PhyslibSRBridgeCertificate` witnesses that Physlib's
`properTime_pos_ofTimeLike` lifts back to the CATEPT side: timelike-separated
events have positive interval. -/
theorem certificate_properTime_pos
    (cert : PhyslibSRBridgeCertificate)
    {q p : CATEPTST} (h : CausalTimelike (p - q)) :
    0 < Real.sqrt (-(minkowskiNorm2 (p - q))) := by
  rw [cert.properTime_compat q p]
  apply properTime_pos_ofTimeLike
  rw [show cert.toPhys p - cert.toPhys q = cert.toPhys (p - q) from
        (cert.toPhys.map_sub p q).symm]
  exact (cert.timelike_compat (p - q)).mp h

/-- The canonical bridge certificate yields a strictly positive interval for
timelike separations. -/
theorem cateptPhyslibSRBridge_properTime_pos
    {q p : CATEPTST} (h : CausalTimelike (p - q)) :
    0 < Real.sqrt (-(minkowskiNorm2 (p - q))) :=
  certificate_properTime_pos cateptPhyslibSRBridge h

end CATEPTMain.Bridges.PhyslibRelativityBridge
