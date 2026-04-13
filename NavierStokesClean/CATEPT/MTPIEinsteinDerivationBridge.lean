import NavierStokesClean.CATEPT.BianchiComplexEFEContracts

/-!
# CAT/EPT MTPI -> Complex EFE Derivation Bridge (WP3)

This module adds the derivation bridge from MTPI source-coupled expectation data
into the complex-EFE contract layer:

- expectation-level Einstein/stress observables at stress-induced source
- expectation-level complex-EFE residual
- derivation certificate that upgrades expectation identities into the
  pointwise EFE contract
- propagation of derived EFE contract into contracted conservation via
  the dual-Bianchi contract layer from WP2

The `expectation_to_pointwise` field is explicit on purpose: it marks the exact
mathematical boundary where a separating-observable/functional-derivative
argument must be supplied.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : CurvedMeasurePathIntegralModel α)
variable (C : ComplexEFEContract α)

/-- Source-coupled Einstein observable expectation at stress-induced source. -/
def einsteinExpectation (OEin : α → ℂ) : ℂ :=
  c.sourceCoupledExpectation C.sourceFromStress OEin

/-- Source-coupled stress observable expectation at stress-induced source. -/
def stressExpectation (OStress : α → ℂ) : ℂ :=
  c.sourceCoupledExpectation C.sourceFromStress OStress

/-- Expectation-level complex-EFE residual. -/
def efeExpectationResidual (OEin OStress : α → ℂ) : ℂ :=
  c.einsteinExpectation C OEin - C.coupling * c.stressExpectation C OStress

/-- Expectation-level relation implies zero expectation residual. -/
theorem efeExpectationResidual_eq_zero_of_relation
    (OEin OStress : α → ℂ)
    (hRel : c.einsteinExpectation C OEin = C.coupling * c.stressExpectation C OStress) :
    c.efeExpectationResidual C OEin OStress = 0 := by
  unfold efeExpectationResidual
  simp [hRel]

/-- Certificate packaging the MTPI -> EFE derivation step.

`expectation_to_pointwise` is the explicit boundary assumption bridging
expectation-level closure to the field-level EFE contract. -/
structure MTPIDerivationCertificate where
  einsteinObservable : α → ℂ
  stressObservable : α → ℂ
  expectation_relation :
    c.einsteinExpectation C einsteinObservable =
      C.coupling * c.stressExpectation C stressObservable
  expectation_to_pointwise :
    c.efeExpectationResidual C einsteinObservable stressObservable = 0 →
      C.HoldsPointwise

/-- Derive pointwise EFE contract from the MTPI derivation certificate. -/
theorem MTPIDerivationCertificate.derive_holdsPointwise
    (A : c.MTPIDerivationCertificate C) :
    C.HoldsPointwise := by
  apply A.expectation_to_pointwise
  exact c.efeExpectationResidual_eq_zero_of_relation C
    A.einsteinObservable A.stressObservable A.expectation_relation

/-- Derive MTPI/EFE compatibility package from the certificate. -/
theorem MTPIDerivationCertificate.derive_mtpi_compatibility
    (A : c.MTPIDerivationCertificate C) :
    MTPIComplexEFECompatibility α c C :=
  mkMTPIComplexEFECompatibility c C A.derive_holdsPointwise

/-- Derive contracted conservation from MTPI certificate via WP2 bridge. -/
theorem MTPIDerivationCertificate.derive_contracted_conservation
    (D : ComplexFieldDivergence α)
    (A : c.MTPIDerivationCertificate C) :
    D.ContractedConservation C :=
  ComplexFieldDivergence.contractedConservation_of_holdsPointwise D C
    A.derive_holdsPointwise

/-- The certificate also carries the connected-functional identity at the
stress-induced source. -/
theorem MTPIDerivationCertificate.connectedFunctional_identity
    (_A : c.MTPIDerivationCertificate C) :
    c.stressConnectedFunctional C =
      Complex.log (c.sourceCoupledPartition C.sourceFromStress) := by
  simpa using c.stressConnectedFunctional_eq_log_sourcePartition C

end CurvedMeasurePathIntegralModel

/-! ## WP08: MTPI→Complex EFE and Bianchi derivation strictification (paper label aliases) -/

section WP08StrictBoundary

variable {α : Type*} [MeasurableSpace α]

/-- paper4_eq_WP08_efe_residual_zero: Expectation-level EFE relation implies zero residual.
    This is the formal entry to the derivation chain. -/
theorem paper4_eq_WP08_efe_residual_zero
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (OEin OStress : α → ℂ)
    (hRel : c.einsteinExpectation C OEin = C.coupling * c.stressExpectation C OStress) :
    c.efeExpectationResidual C OEin OStress = 0 :=
  c.efeExpectationResidual_eq_zero_of_relation C OEin OStress hRel

/-- paper4_eq_WP08_derive_efe: MTPI derivation certificate → pointwise complex-EFE contract.
    This collapses the full expectation→pointwise derivation chain into one theorem. -/
theorem paper4_eq_WP08_derive_efe
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (A : c.MTPIDerivationCertificate C) :
    C.HoldsPointwise :=
  A.derive_holdsPointwise

/-- paper4_eq_WP08_contracted_conservation: MTPI certificate + divergence operator →
    contracted conservation ∇·G = coupling · ∇·T. -/
theorem paper4_eq_WP08_contracted_conservation
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (D : ComplexFieldDivergence α)
    (A : c.MTPIDerivationCertificate C) :
    D.ContractedConservation C :=
  ComplexFieldDivergence.contractedConservation_of_holdsPointwise D C A.derive_holdsPointwise

/-- paper4_eq_WP08_connected_functional: W_g[J_stress] = log Z_g[J_stress] identity
    holds under any MTPI derivation certificate. -/
theorem paper4_eq_WP08_connected_functional
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (A : c.MTPIDerivationCertificate C) :
    c.stressConnectedFunctional C =
      Complex.log (c.sourceCoupledPartition C.sourceFromStress) :=
  A.connectedFunctional_identity

/-- paper4_eq_WP08_mtpi_efe_compatibility: MTPI certificate packages into the full
    MTPI/EFE compatibility structure. -/
theorem paper4_eq_WP08_mtpi_efe_compatibility
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (A : c.MTPIDerivationCertificate C) :
    MTPIComplexEFECompatibility α c C :=
  A.derive_mtpi_compatibility

/-- paper4_eq_WP08_bianchi_first: First Bianchi seed div(curl f) = 0 (PhysLean-grounded). -/
alias paper4_eq_WP08_bianchi_first := physlean_first_bianchi_seed

/-- paper4_eq_WP08_bianchi_second: Second Bianchi seed curl(curl f) = grad(div f) − Δf
    (PhysLean-grounded). -/
alias paper4_eq_WP08_bianchi_second := physlean_second_bianchi_seed

/-- paper4_eq_WP08_strict_boundary: The MTPI→EFE derivation has exactly one open boundary:
    the `expectation_to_pointwise` hypothesis in `MTPIDerivationCertificate`.
    All other steps are formal proofs with 0 sorry, 0 axiom.

    This theorem makes the boundary explicit: given a certificate where the
    expectation-to-pointwise bridge is supplied, the full derivation closes. -/
theorem paper4_eq_WP08_strict_boundary
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (A : c.MTPIDerivationCertificate C) :
    (c.efeExpectationResidual C A.einsteinObservable A.stressObservable = 0 →
        C.HoldsPointwise) →
      C.HoldsPointwise := fun hBridge =>
  hBridge (c.efeExpectationResidual_eq_zero_of_relation C
    A.einsteinObservable A.stressObservable A.expectation_relation)

end WP08StrictBoundary

end

end NavierStokesClean.CATEPT
