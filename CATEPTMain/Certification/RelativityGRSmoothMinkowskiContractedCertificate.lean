/-
# `ContractedBianchiCertificate gravitasMinkowski` from the smooth Levi-Civita route

This file derives a `ContractedBianchiCertificate gravitasMinkowski`
**by going through the smooth-side LC-008 generic theorem**, rather
than the older symbolic-only route
`gravitasMinkowski_einstein_covariantDivergence_zero`.

The trip is:

1. `gravitasMinkowski_symbolic_divergence_matches_smooth` discharges
   the `representation` field of the LC-007 predicate
   `SymbolicEinsteinDivergenceRepresentsSmooth` on the canonical
   Minkowski witness.
2. The rfl-level `dim_match : smoothMinkowskiSpacetime.dim =
   gravitasMinkowski.dim` discharges the dimension field.
3. The generic LC-008 theorem
   `contractedBianchiCertificate_of_smooth_leviCivita` then assembles
   the symbolic-side `ContractedBianchiCertificate gravitasMinkowski`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothMinkowskiContractedCertificate`
  passes;
* `#check gravitasMinkowski_contractedBianchiCertificate_from_smooth`
  elaborates;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothMinkowskiCoordinateBridge
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchiCertificate

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open CATEPTMain.Integration.GravitasBridge

/-- Tactic-style construction of the LC-007 symbolic↔smooth
representation predicate on the canonical Minkowski witness.

This is the `refine { … }` companion to
`gravitasMinkowski_symbolicEinsteinDivergenceRepresentsSmooth`
from `RelativityGRSmoothMinkowskiCoordinateBridge`; both inhabit the
same type and differ only in proof presentation.  Exposed under this
name so the downstream certificate construction below mirrors the
upstream task description verbatim. -/
def gravitasMinkowski_symbolicRepresents_smooth :
    SymbolicEinsteinDivergenceRepresentsSmooth
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
      gravitasMinkowski := by
  refine
    { representation := ?_
      dim_match := ?_ }
  · exact gravitasMinkowski_symbolic_divergence_matches_smooth
  · rfl

/-- **`ContractedBianchiCertificate gravitasMinkowski` produced by the
smooth Levi-Civita route.**

Assembles the symbolic-side contracted-Bianchi certificate for the
canonical Minkowski metric **via the generic LC-008 theorem**, using
only the smooth-side Minkowski witnesses
(`smoothMinkowskiConnection`, `smoothMinkowski_isLeviCivita`) and the
LC-007 representation predicate
`gravitasMinkowski_symbolicRepresents_smooth`.

Provides an alternative to the older symbolic-only route through
`gravitasMinkowski_einstein_covariantDivergence_zero`, and demonstrates
that the smooth-side ladder is sufficient to discharge the symbolic
certification surface on Minkowski. -/
def gravitasMinkowski_contractedBianchiCertificate_from_smooth :
    ContractedBianchiCertificate gravitasMinkowski :=
  contractedBianchiCertificate_of_smooth_leviCivita
    smoothMinkowskiConnection
    smoothMinkowski_isLeviCivita
    gravitasMinkowski_symbolicRepresents_smooth

end CATEPTMain.Certification.RelativityGR

end
