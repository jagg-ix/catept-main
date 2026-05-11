import CATEPTMain.Certification.RelativityGRUnsafeFixes

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Typed certificate packaging Einstein coupling data for a metric/stress pair. -/
structure EinsteinEquationCertificate where
  metric : MetricTensor
  stress : StressEnergyTensor
  kappa : ℝ
  sourceTerm : Gravitas.Expr
  equation_holds :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N")

/-- Constructor for an arbitrary metric/stress Einstein-equation certificate,
parameterized by an explicit source term and proof payload. -/
def mk_einstein_equation_certificate
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (kappa : ℝ)
    (sourceTerm : Gravitas.Expr)
    (hEq :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N")) :
    EinsteinEquationCertificate where
  metric := metric
  stress := stress
  kappa := kappa
  sourceTerm := sourceTerm
  equation_holds := hEq

/-- Any certificate built via `mk_einstein_equation_certificate` stores the
provided equation proof unchanged. -/
theorem mk_einstein_equation_certificate_holds
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (kappa : ℝ)
    (sourceTerm : Gravitas.Expr)
    (hEq :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N")) :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N") :=
  (mk_einstein_equation_certificate metric stress kappa sourceTerm hEq).equation_holds

/-- Indexed Einstein-equation certificate family with metric/stress fixed in
the type. This gives a parameterized theorem surface beyond value-level wrappers. -/
structure EinsteinEquationCertificateFor
    (metric : MetricTensor)
    (stress : StressEnergyTensor) where
  kappa : ℝ
  sourceTerm : Gravitas.Expr
  equation_holds :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N")

/-- Constructor for the indexed Einstein-equation certificate family. -/
def mk_einstein_equation_certificate_for
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (kappa : ℝ)
    (sourceTerm : Gravitas.Expr)
    (hEq :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N")) :
    EinsteinEquationCertificateFor metric stress where
  kappa := kappa
  sourceTerm := sourceTerm
  equation_holds := hEq

/-- Any indexed certificate built via `mk_einstein_equation_certificate_for`
stores the equation proof payload unchanged. -/
theorem mk_einstein_equation_certificate_for_holds
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (kappa : ℝ)
    (sourceTerm : Gravitas.Expr)
    (hEq :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N")) :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N") :=
  (mk_einstein_equation_certificate_for metric stress kappa sourceTerm hEq).equation_holds

/-- Canonical electrovacuum Einstein-equation certificate on Minkowski data. -/
def canonical_electrovac_einstein_certificate :
    EinsteinEquationCertificate where
  metric := gravitasMinkowski
  stress := gravitasEMStressEnergy
  kappa := 8 * Real.pi
  sourceTerm := .lit 0
  equation_holds := by
    simpa using gravitasEinstein_residual_exact

/-- The canonical electrovacuum certificate satisfies its Einstein equation field. -/
theorem canonical_electrovac_einstein_equation_holds :
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N") :=
  canonical_electrovac_einstein_certificate.equation_holds

/-- Canonical indexed electrovacuum Einstein-equation certificate. -/
def canonical_electrovac_einstein_certificate_for :
    EinsteinEquationCertificateFor gravitasMinkowski gravitasEMStressEnergy where
  kappa := 8 * Real.pi
  sourceTerm := .lit 0
  equation_holds := by
    simpa using gravitasEinstein_residual_exact

/-- The canonical indexed electrovacuum certificate satisfies its equation. -/
theorem canonical_electrovac_einstein_equation_holds_for :
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N") :=
  canonical_electrovac_einstein_certificate_for.equation_holds

end CATEPTMain.Certification.RelativityGR

end
