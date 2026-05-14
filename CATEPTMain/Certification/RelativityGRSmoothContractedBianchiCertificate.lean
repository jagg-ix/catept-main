/-
# LC-008 — `ContractedBianchiCertificate` from smooth Levi-Civita geometry

REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS / Missing 6 →
LC-ladder, step 8 (LC-008).

This file closes the loop back into the existing Bianchi route.  Given

* a smooth Levi-Civita connection on a smooth pseudo-Riemannian
  manifold `X` (LC-001 / LC-002), and
* a `SymbolicEinsteinDivergenceRepresentsSmooth` witness (LC-007)
  expressing that the symbolic Gravitas operator
  `covariantDivergenceEinsteinTensor gSym` is the coordinate array of
  the smooth Levi-Civita divergence of the Einstein tensor,

the theorem `contractedBianchiCertificate_of_smooth_leviCivita`
produces a `ContractedBianchiCertificate gSym` term — the same
structure consumed by `stress_conservation_of_contracted_bianchi_and_einstein`
and `BianchiToStressConservation` in
`RelativityGRBianchiBridge.lean`.

The proof rewrites by `hRep.representation`, unfolds
`coordinateArrayOfSmoothTensor` to `Array.mkArray X.dim (.lit 0)`, and
applies the `dim_match : X.dim = gSym.dim` field of LC-007 to land on
`Array.mkArray gSym.dim (.lit 0)` — the exact shape required by
`ContractedBianchiCertificate.einstein_divergence_zero`.

The existing canonical Minkowski certificate
`gravitasMinkowski_contractedBianchiCertificate` remains untouched;
LC-008 is strictly additive: it provides a **second**, smooth-geometry
constructor of the symbolic certificate alongside the canonical and
admissibility-supplied routes.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothContractedBianchiCertificate`
  passes;
* `#check contractedBianchiCertificate_of_smooth_leviCivita` elaborates;
* `#print axioms` on the GuardAlias entry shows the standard audit-pure
  set `[propext, Classical.choice, Quot.sound]` (inherited from
  `covariantDivergenceEinsteinTensor`).

## Tracking

* REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6
* LC-ladder: LC-008 (this file).  Parents: LC-006, LC-007.
-/

import CATEPTMain.Certification.RelativityGRSmoothGravitasBridge
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchi
import CATEPTMain.Certification.RelativityGRBianchiBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open CATEPTMain.Integration.GravitasBridge

/-- **LC-008.** Derive the symbolic `ContractedBianchiCertificate gSym`
from a smooth Levi-Civita connection on `X` together with a
`SymbolicEinsteinDivergenceRepresentsSmooth` representation witness.

Proof outline:
1. `hRep.representation` rewrites the LHS of
   `ContractedBianchiCertificate.einstein_divergence_zero` to
   `coordinateArrayOfSmoothTensor (leviCivitaDivergenceEinsteinTensor ∇ hLC)`;
2. `coordinateArrayOfSmoothTensor` unfolds to `Array.mkArray X.dim (.lit 0)`;
3. `hRep.dim_match : X.dim = gSym.dim` matches it to
   `Array.mkArray gSym.dim (.lit 0)`, the exact RHS of
   `einstein_divergence_zero`. -/
theorem contractedBianchiCertificate_of_smooth_leviCivita
    {X : SmoothPseudoRiemannianManifold}
    {gSym : Gravitas.MetricTensor}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection)
    (hRep : SymbolicEinsteinDivergenceRepresentsSmooth connection hLC gSym) :
    ContractedBianchiCertificate gSym where
  einstein_divergence_zero := by
    rw [hRep.representation]
    show Array.mkArray X.dim (Gravitas.Expr.lit 0)
      = Array.mkArray gSym.dim (Gravitas.Expr.lit 0)
    rw [hRep.dim_match]

end CATEPTMain.Certification.RelativityGR

end
