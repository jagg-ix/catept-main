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

/-- Source-aware indexed Einstein-equation certificate family with metric/stress
fixed in the type and source term appearing on both equation sides. -/
structure EinsteinEquationCertificateForSource
    (metric : MetricTensor)
    (stress : StressEnergyTensor) where
  kappa : ℝ
  sourceTerm : Gravitas.Expr
  equation_holds :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N")

/-- Constructor for the source-aware indexed Einstein-equation certificate
family. -/
def mk_einstein_equation_certificate_for_source
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (kappa : ℝ)
    (sourceTerm : Gravitas.Expr)
    (hEq :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N")) :
    EinsteinEquationCertificateForSource metric stress where
  kappa := kappa
  sourceTerm := sourceTerm
  equation_holds := hEq

/-- Any source-aware indexed certificate built via
`mk_einstein_equation_certificate_for_source` stores the equation proof payload
unchanged. -/
theorem mk_einstein_equation_certificate_for_source_holds
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (kappa : ℝ)
    (sourceTerm : Gravitas.Expr)
    (hEq :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N")) :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N") :=
  (mk_einstein_equation_certificate_for_source metric stress kappa sourceTerm hEq).equation_holds

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

/-- Canonical source-aware indexed electrovacuum Einstein-equation certificate. -/
def canonical_electrovac_einstein_certificate_for_source :
    EinsteinEquationCertificateForSource gravitasMinkowski gravitasEMStressEnergy where
  kappa := 8 * Real.pi
  sourceTerm := .lit 0
  equation_holds := by
    simpa using gravitasEinstein_residual_exact

/-- The canonical source-aware indexed electrovacuum certificate satisfies its
equation. -/
theorem canonical_electrovac_einstein_equation_holds_for_source :
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N") :=
  canonical_electrovac_einstein_certificate_for_source.equation_holds

/-- Family-lifted canonical Einstein residual identity:
any metric/stress pair identified with canonical electrovacuum data inherits
the indexed canonical equation certificate. -/
def canonical_electrovac_einstein_certificate_for_family
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (hMetric : metric = gravitasMinkowski)
    (hStress : stress = gravitasEMStressEnergy) :
    EinsteinEquationCertificateFor metric stress := by
  subst hMetric
  subst hStress
  exact canonical_electrovac_einstein_certificate_for

/-- Projection theorem for the family-lifted canonical Einstein certificate. -/
theorem canonical_electrovac_einstein_equation_holds_for_family
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (hMetric : metric = gravitasMinkowski)
    (hStress : stress = gravitasEMStressEnergy) :
    (solveEinsteinEquations stress (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N") :=
by
  subst hMetric
  subst hStress
  simpa using canonical_electrovac_einstein_equation_holds_for

/-- Family-lifted canonical source-aware Einstein residual identity. -/
def canonical_electrovac_einstein_certificate_for_source_family
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (hMetric : metric = gravitasMinkowski)
    (hStress : stress = gravitasEMStressEnergy) :
    EinsteinEquationCertificateForSource metric stress := by
  subst hMetric
  subst hStress
  exact canonical_electrovac_einstein_certificate_for_source

/-- Projection theorem for the family-lifted canonical source-aware Einstein
certificate. -/
theorem canonical_electrovac_einstein_equation_holds_for_source_family
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (hMetric : metric = gravitasMinkowski)
    (hStress : stress = gravitasEMStressEnergy) :
    (solveEinsteinEquations stress (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components (.lit 0) (.var "G_N") := by
  subst hMetric
  subst hStress
  simpa using canonical_electrovac_einstein_equation_holds_for_source

end CATEPTMain.Certification.RelativityGR

end
