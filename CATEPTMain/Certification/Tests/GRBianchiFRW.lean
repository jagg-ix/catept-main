import CATEPTMain.Certification.RelativityGRBianchiFRW

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRBianchiFRW

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.GravitasBridge
open Gravitas

/-! # BIANCHI-012 — FRW family surface tests

These tests pin the public surface of the nontrivial curved-metric
family shipped in `RelativityGRBianchiFRW`.  All examples consume only
the witnesses carried in `FRWParameter` and the family-level
admissibility / EFE projections; they do not introduce any new
hypothesis. -/

/-! ## Inventory surface -/

#check FRWParameter
#check frwMetricFamily
#check frwStressFamily
#check frwMetricFamily_bianchiAdmissible
#check frwStressFamily_einsteinEquationHolds
#check frwHasStressConservation

/-! ## Family admissibility ⇒ per-parameter contracted Bianchi -/

example (p : FRWParameter) :
    HasContractedBianchi (frwMetricFamily p) :=
  hasContractedBianchi_of_family frwMetricFamily_bianchiAdmissible p

/-! ## Family admissibility + EFE + κ ≠ 0 ⇒ per-parameter stress conservation -/

example
    (p : FRWParameter)
    (hκ : (Gravitas.Expr.var "κ") ≠ Gravitas.Expr.lit 0) :
    HasStressConservation (frwMetricFamily p) (frwStressFamily p) :=
  hasStressConservation_of_family
    frwMetricFamily_bianchiAdmissible
    frwStressFamily_einsteinEquationHolds
    hκ
    p

/-! ## Headline route -/

example
    (hκ : (Gravitas.Expr.var "κ") ≠ Gravitas.Expr.lit 0)
    (p : FRWParameter) :
    HasStressConservation (frwMetricFamily p) (frwStressFamily p) :=
  frwHasStressConservation hκ p

/-! ## BIANCHI-013 — FRW end-to-end into `IsCertifiedCurvedGRData` /
`CurvedGRDirectCertificate` -/

#check FRWCertifiedParameter
#check frwFaradayFamily
#check frwADMFamily
#check frwADMStressFamily
#check frwSourceTerm
#check frwHodgeClosure
#check frwEinsteinClosure
#check frwADMClosure
#check frwCertifiedCurvedGRData
#check curved_gr_direct_certificate_of_certified_data
#check frwCurvedGRDirectCertificate

example (p : FRWCertifiedParameter) :
    IsCertifiedCurvedGRData
      (frwMetricFamily p.base)
      (frwFaradayFamily p)
      (frwStressFamily p.base)
      (frwADMFamily p)
      (frwADMStressFamily p)
      (frwSourceTerm p) :=
  frwCertifiedCurvedGRData p

example (p : FRWCertifiedParameter) : CurvedGRDirectCertificate :=
  curved_gr_direct_certificate_of_certified_data
    p.kappa
    (frwCertifiedCurvedGRData p)

example (p : FRWCertifiedParameter) : CurvedGRDirectCertificate :=
  frwCurvedGRDirectCertificate p

end CATEPTMain.Certification.Tests.GRBianchiFRW

end
