/-
RelativityGRFRWSectorClosureContracts.lean

Defines FRW-specific sector closure contracts:
- FRWHodgeClosure p faraday
- FRWEinsteinClosure p sourceTerm
- FRWADMClosure p adm admStress sourceTerm

Each is a Prop-valued contract that wraps the corresponding generic closure for the FRW metric at parameter p. Wrappers are provided to produce the generic Has*Closure obligations from the named contracts.
-/

import CATEPTMain.Certification.RelativityGRFRWDerivedTargets
import CATEPTMain.Gravitas.MetricTensor
import CATEPTMain.Gravitas.ElectromagneticTensor
import CATEPTMain.Gravitas.StressEnergyTensor
import CATEPTMain.Gravitas.ADMDecomposition
import CATEPTMain.Gravitas.ADMStressEnergyDecomposition
import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect

noncomputable section
set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- FRW-specific Hodge closure contract: the Hodge star is an involution for the FRW metric at p and Faraday tensor. -/
structure FRWHodgeClosure (p : FRWRawParameter) (faraday : ElectromagneticTensor) : Prop where
  hodge_closure : HasHodgeClosure (frwRawMetricFamily p) faraday

/-- FRW-specific Einstein closure contract: the Einstein equation residual vanishes for the FRW metric at p, stress, and source term. -/
structure FRWEinsteinClosure (p : FRWRawParameter) (sourceTerm : Gravitas.Expr) : Prop where
  einstein_closure : HasEinsteinClosure (frwRawMetricFamily p) p.stress sourceTerm

/-- FRW-specific ADM closure contract: the ADM constraint residual vanishes for the FRW metric at p, ADM decomposition, ADM stress, and source term. -/
structure FRWADMClosure (p : FRWRawParameter) (adm : ADMDecomposition) (admStress : ADMStressEnergyDecomposition) (sourceTerm : Gravitas.Expr) : Prop where
  adm_closure : HasADMClosure adm admStress sourceTerm

/-- Wrapper: produce the generic HasHodgeClosure from the FRW contract. -/
def hasHodgeClosure_of_frw (p : FRWRawParameter) (faraday : ElectromagneticTensor)
  (h : FRWHodgeClosure p faraday) : HasHodgeClosure (frwRawMetricFamily p) faraday :=
  h.hodge_closure

/-- Wrapper: produce the generic HasEinsteinClosure from the FRW contract. -/
def hasEinsteinClosure_of_frw (p : FRWRawParameter) (sourceTerm : Gravitas.Expr)
  (h : FRWEinsteinClosure p sourceTerm) : HasEinsteinClosure (frwRawMetricFamily p) p.stress sourceTerm :=
  h.einstein_closure

/-- Wrapper: produce the generic HasADMClosure from the FRW contract. -/
def hasADMClosure_of_frw (p : FRWRawParameter) (adm : ADMDecomposition) (admStress : ADMStressEnergyDecomposition) (sourceTerm : Gravitas.Expr)
  (h : FRWADMClosure p adm admStress sourceTerm) : HasADMClosure adm admStress sourceTerm :=
  h.adm_closure

end CATEPTMain.Certification.RelativityGR
