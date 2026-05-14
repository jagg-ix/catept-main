/-
# `HasStressConservation` for FRW from the smooth Levi-Civita route

This file is the **FRW analog** of
`CATEPTMain/Certification/RelativityGRSmoothMinkowskiStress.lean`.
It routes the smooth-side FRW Bianchi witness
(`SmoothFRWRepresentsGravitasFRW p`, from
`RelativityGRSmoothFRWDerivedBianchi`) through the LC-009 generic
theorem `hasStressConservation_of_smooth_leviCivita_einstein` to
produce
`HasStressConservation (frwRawMetricFamily p) p.stress`
**via the smooth-side ladder**, rather than directly through the
symbolic Bianchi identity that `frwHasStressConservation` consumes.

The trip is:

1. `SmoothFRWRepresentsGravitasFRW p` (LC-007 representation witness
   for FRW) — supplied by the caller, or built from a symbolic-FLRW
   divergence-zero hypothesis via
   `smoothFRW_represents_gravitasFRW_of_raw`;
2. `EinsteinEquationHolds (frwRawMetricFamily p) p.stress (.var "κ")`
   (BIANCHI-003 for FRW) — supplied by the caller;
3. `kappa_var_ne_zero_lit` discharges the non-degeneracy
   `Gravitas.Expr.var "κ" ≠ Gravitas.Expr.lit 0`.

Reuses the FRW raw-shell smooth Levi-Civita connection witnesses
`frwLeviCivitaConnectionRaw` and `frwConnectionRaw_isLeviCivita` from
`RelativityGRSmoothFRWDerivedBianchi`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothFRWDerivedStress`
  passes;
* `#check frw_hasStressConservation_from_smooth_of_raw` and
  `#check frwDerivedEFETarget_from_smooth_of_raw` elaborate;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedBianchi
import CATEPTMain.Certification.RelativityGRSmoothStressConservation
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiStress

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- **`HasStressConservation` for the FRW raw family produced by the
smooth Levi-Civita route.**

Routes the smooth-side FRW representation witness
`SmoothFRWRepresentsGravitasFRW p` (whose `divergence_represents` field
is the LC-007 `SymbolicEinsteinDivergenceRepresentsSmooth` array
equation against `frwLeviCivitaConnectionRaw p`) through the LC-009
generic constructor `hasStressConservation_of_smooth_leviCivita_einstein`,
using a caller-supplied FRW Einstein-equation `hEFE` and the named
non-degeneracy `kappa_var_ne_zero_lit`.

This is the FRW analog of
`gravitasMinkowski_hasStressConservation_from_smooth`; it is the first
FRW stress-conservation producer that takes its input from the smooth
ladder, rather than from the witness-carrying legacy `FRWParameter`. -/
def frw_hasStressConservation_from_smooth_of_raw
    (p : FRWRawParameter)
    (hRep : SmoothFRWRepresentsGravitasFRW p)
    (hEFE :
      EinsteinEquationHolds
        (frwRawMetricFamily p) p.stress (Gravitas.Expr.var "κ")) :
    HasStressConservation (frwRawMetricFamily p) p.stress :=
  hasStressConservation_of_smooth_leviCivita_einstein
    (frwLeviCivitaConnectionRaw p)
    (frwConnectionRaw_isLeviCivita p)
    hRep.divergence_represents
    hEFE
    kappa_var_ne_zero_lit

/-- Convenience: package a caller-supplied FRW
`EinsteinEquationHolds` witness as an `FRWDerivedEFETarget p`, ready
to feed `frwParameter_of_derived_targets`.

The smooth-route producer above does *not* depend on this packaging,
but most callers want both the FRW derived-Bianchi target (from
`frwDerivedBianchiTarget_from_smooth`) and the matching EFE target,
so we expose this companion definition for completeness. -/
def frwDerivedEFETarget_from_smooth_of_raw
    (p : FRWRawParameter)
    (hEFE :
      EinsteinEquationHolds
        (frwRawMetricFamily p) p.stress (Gravitas.Expr.var "κ")) :
    FRWDerivedEFETarget p where
  derived := hEFE

end CATEPTMain.Certification.RelativityGR

end
