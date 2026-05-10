import CATEPTMain.Bridges.PhyslibRelativityBridge.MinkowskiBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.ProperTimeBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.SpinorBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.SRBridgeCertificate
import CATEPTMain.Bridges.PhyslibRelativityBridge.SpinorBridgeCertificate

/-!
# Physlib Relativity Bridge (barrel file)

This file re-exports all four modules of the CATEPT↔Physlib SR bridge:

- `MinkowskiBridge` — `CATEPTST ≃ₗ[ℝ] SpaceTime 3`, metric sign,
  causality and lightcone predicates.
- `ProperTimeBridge` — interval formula = Physlib `properTime`
  (unconditionally), plus positivity for timelike pairs.
- `SRBridgeCertificate` — `PhyslibSRBridgeCertificate` structure (metric +
  causality + proper time) plus corollaries; no spinor content.
- `SpinorBridge` — `cateptToSelfAdjoint` map, det = (−minkowskiNorm2 x : ℂ),
  SL(2,ℂ) intertwining via `ContrMod.toSelfAdjoint`.
- `SpinorBridgeCertificate` — `PhyslibSRSpinorBridgeCertificate` structure
  extending the SR certificate with spinor/det/intertwining fields;
  canonical instance `cateptPhyslibSRSpinorBridge`.

## Defensible claim

> CATEPT finite Minkowski spacetime is a sign-convention-equivalent model of
> Physlib `SpaceTime 3`, preserving causality, proper time, and the SL(2,ℂ)
> spinor/Lorentz structure.

This is an SR bridge only.  GR (curvature, tensor pullbacks, Einstein equations)
requires a separate `GRBridgeCertificate` layer built on top.
-/
