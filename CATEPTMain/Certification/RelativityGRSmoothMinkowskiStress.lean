/-
# `HasStressConservation` for Minkowski + EM from the smooth Levi-Civita route

This file routes the **smooth Minkowski Bianchi witness** (PR1/PR3/PR4)
into the LC-009 generic theorem
`hasStressConservation_of_smooth_leviCivita_einstein` to produce a
`HasStressConservation gravitasMinkowski gravitasEMStressEnergy`
**via the smooth-side ladder**, rather than directly through the
symbolic Bianchi identity.

The trip is:

1. `gravitasMinkowski_symbolicRepresents_smooth` (PR4) is the LC-007
   representation witness on Minkowski;
2. `gravitasMinkowski_einsteinEquationHolds (.var "κ")` (BIANCHI-003)
   supplies the divergence-compatible Einstein equation at the
   coupling `κ = Gravitas.Expr.var "κ"`;
3. `kappa_var_ne_zero_lit` discharges the non-degeneracy
   `Gravitas.Expr.var "κ" ≠ Gravitas.Expr.lit 0` by case analysis on
   the would-be equality.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothMinkowskiStress`
  passes;
* `#check gravitasMinkowski_hasStressConservation_from_smooth`
  elaborates;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothMinkowskiContractedCertificate
import CATEPTMain.Certification.RelativityGRSmoothStressConservation
import CATEPTMain.Certification.RelativityGRBianchiBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Named non-degeneracy lemma: the symbolic coupling
`Gravitas.Expr.var "κ"` is not the literal zero `Gravitas.Expr.lit 0`.

`Gravitas.Expr.var` and `Gravitas.Expr.lit` are distinct constructors
of the `Gravitas.Expr` inductive, so the equality is impossible. -/
theorem kappa_var_ne_zero_lit :
    Gravitas.Expr.var "κ" ≠ Gravitas.Expr.lit 0 := by
  intro h
  cases h

/-- **`HasStressConservation gravitasMinkowski gravitasEMStressEnergy`
produced by the smooth Levi-Civita route.**

Routes the smooth-side Minkowski witnesses through the LC-009 generic
theorem `hasStressConservation_of_smooth_leviCivita_einstein`, using
the BIANCHI-003 canonical Minkowski Einstein equation and the named
non-degeneracy lemma `kappa_var_ne_zero_lit`.

Provides a smooth-route inhabitant of the same conservation surface
that the symbolic-only route also discharges; the resulting
`.divergence_zero` field is the literal Bianchi residual equality
`covariantDivergenceStressEnergy gravitasMinkowski gravitasEMStressEnergy
  = Array.mkArray gravitasMinkowski.dim (.lit 0)`. -/
def gravitasMinkowski_hasStressConservation_from_smooth :
    HasStressConservation gravitasMinkowski gravitasEMStressEnergy :=
  hasStressConservation_of_smooth_leviCivita_einstein
    smoothMinkowskiConnection
    smoothMinkowski_isLeviCivita
    gravitasMinkowski_symbolicRepresents_smooth
    (gravitasMinkowski_einsteinEquationHolds (Gravitas.Expr.var "κ"))
    kappa_var_ne_zero_lit

end CATEPTMain.Certification.RelativityGR

end
