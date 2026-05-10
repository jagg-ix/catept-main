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
  equation_holds : Prop

/-- Canonical electrovacuum Einstein-equation certificate on Minkowski data. -/
def canonical_electrovac_einstein_certificate :
    EinsteinEquationCertificate where
  metric := gravitasMinkowski
  stress := gravitasEMStressEnergy
  kappa := 8 * Real.pi
  equation_holds :=
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N")

/-- The canonical electrovacuum certificate satisfies its Einstein equation field. -/
theorem canonical_electrovac_einstein_equation_holds :
    canonical_electrovac_einstein_certificate.equation_holds := by
  simpa [canonical_electrovac_einstein_certificate] using gravitasEinstein_residual_exact

end CATEPTMain.Certification.RelativityGR

end