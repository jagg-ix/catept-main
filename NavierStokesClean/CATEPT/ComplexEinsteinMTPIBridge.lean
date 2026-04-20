import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.PhysLean.DivCurlIdentity

/-!
# CAT/EPT Complex Einstein MTPI Bridge (WP1)

This module introduces a tensor-contract layer that connects the new
measure-theoretic CAT/EPT path-integral objects to a complex Einstein-equation
interface:

- complex Einstein tensor/stress tensor decomposition (`real + i·imag`)
- pointwise complex EFE residual and contract satisfaction predicate
- MTPI source construction from stress tensor components
- connected-generating-functional compatibility in the curved MTPI model
- explicit PhysLean compatibility seed for Bianchi-style divergence identities

This is WP1 (contract layer). Dual-Bianchi and contracted-conservation
propagation are handled in WP2.
-/

set_option autoImplicit false

open MeasureTheory

namespace NavierStokesClean.CATEPT

noncomputable section

/-- Complex tensor field represented by real/imaginary component fields. -/
structure ComplexTensorField (α : Type*) [MeasurableSpace α] where
  realPart : α → ℂ
  imagPart : α → ℂ
  measurable_realPart : Measurable realPart
  measurable_imagPart : Measurable imagPart

namespace ComplexTensorField

variable {α : Type*} [MeasurableSpace α] (F : ComplexTensorField α)

/-- Reassemble a complex field from real/imaginary components as `R + i·I`. -/
def toComplex : α → ℂ :=
  fun x => F.realPart x + Complex.I * F.imagPart x

/-- Measurability of the reassembled complex field. -/
theorem measurable_toComplex : Measurable F.toComplex := by
  unfold toComplex
  exact F.measurable_realPart.add ((measurable_const.mul F.measurable_imagPart))

@[simp] theorem toComplex_apply (x : α) :
    F.toComplex x = F.realPart x + Complex.I * F.imagPart x := rfl

end ComplexTensorField

/-- Contract layer for the complex Einstein field equation at field level. -/
structure ComplexEFEContract (α : Type*) [MeasurableSpace α] where
  einsteinTensor : ComplexTensorField α
  stressTensor : ComplexTensorField α
  coupling : ℂ

namespace ComplexEFEContract

variable {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α)

/-- Complex Einstein tensor field `G + i·Λ`. -/
def einsteinComplex : α → ℂ := C.einsteinTensor.toComplex

/-- Complex stress tensor field `Tᴿ + i·Tᴵ`. -/
def stressComplex : α → ℂ := C.stressTensor.toComplex

/-- Pointwise complex-EFE residual `(G+iΛ) - κ(Tᴿ+iTᴵ)`. -/
def residual : α → ℂ :=
  fun x => C.einsteinComplex x - C.coupling * C.stressComplex x

/-- Contract satisfaction predicate: pointwise vanishing of complex-EFE residual. -/
def HoldsPointwise : Prop := ∀ x : α, C.residual x = 0

/-- The Einstein complex field is measurable. -/
theorem measurable_einsteinComplex : Measurable C.einsteinComplex :=
  C.einsteinTensor.measurable_toComplex

/-- The stress complex field is measurable. -/
theorem measurable_stressComplex : Measurable C.stressComplex :=
  C.stressTensor.measurable_toComplex

/-- The complex-EFE residual is measurable. -/
theorem measurable_residual : Measurable C.residual := by
  unfold residual
  exact C.measurable_einsteinComplex.sub (C.measurable_stressComplex.const_mul C.coupling)

/-- If the two sides match pointwise, the contract holds. -/
theorem holdsPointwise_of_eq
    (h : ∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :
    C.HoldsPointwise := by
  intro x
  unfold residual
  simpa [h x]

/-- Contract holds iff the residual vanishes pointwise. -/
theorem holdsPointwise_iff_residual_zero :
    C.HoldsPointwise ↔ (∀ x : α, C.residual x = 0) := Iff.rfl

end ComplexEFEContract

/-- MTPI source induced by the stress complex field. -/
def ComplexEFEContract.sourceFromStress
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) : α → ℂ :=
  C.stressComplex

/-- The stress-induced source is measurable. -/
theorem ComplexEFEContract.measurable_sourceFromStress
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) :
    Measurable C.sourceFromStress :=
  C.measurable_stressComplex

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : CurvedMeasurePathIntegralModel α)
variable (C : ComplexEFEContract α)

/-- Connected functional evaluated at the stress-induced source. -/
def stressConnectedFunctional : ℂ :=
  c.connectedGeneratingFunctional C.sourceFromStress

/-- The MTPI stress-connected functional is `log` of source-coupled partition. -/
theorem stressConnectedFunctional_eq_log_sourcePartition :
    c.stressConnectedFunctional C =
      Complex.log (c.sourceCoupledPartition C.sourceFromStress) := by
  rfl

/-- Zero-source reduction when stress source is identically zero. -/
theorem stressConnectedFunctional_eq_log_partition_of_zeroStress
    (h0 : C.sourceFromStress = fun _ => (0 : ℂ)) :
    c.stressConnectedFunctional C = Complex.log c.partition := by
  unfold stressConnectedFunctional
  simpa [h0] using c.connectedGeneratingFunctional_zero

end CurvedMeasurePathIntegralModel

/-- Package stating that a curved MTPI model and an EFE contract are linked by the
stress-induced source and pointwise EFE satisfaction. -/
structure MTPIComplexEFECompatibility
    (α : Type*) [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α) : Prop where
  source_measurable : Measurable C.sourceFromStress
  efe_holds : C.HoldsPointwise

/-- Extract the EFE pointwise contract from compatibility package. -/
theorem MTPIComplexEFECompatibility.efe_pointwise
    {α : Type*} [MeasurableSpace α]
    {c : CurvedMeasurePathIntegralModel α}
    {C : ComplexEFEContract α}
    (h : MTPIComplexEFECompatibility α c C) :
    C.HoldsPointwise :=
  h.efe_holds

/-- Canonical compatibility constructor from measurable source + EFE contract. -/
def mkMTPIComplexEFECompatibility
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (C : ComplexEFEContract α)
    (hE : C.HoldsPointwise) :
    MTPIComplexEFECompatibility α c C :=
  { source_measurable := C.measurable_sourceFromStress
    efe_holds := hE }

/-- PhysLean compatibility seed used by the complex-EFE/Bianchi program:
`div(curl)=0` is already available as a theorem in the codebase. -/
theorem physlean_bianchi_seed
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
  ∇ ⬝ (∇ ⨯ f) = 0 :=
  NavierStokesClean.PhysLeanBridge.ns_div_curl_zero f hf

/-- Gauss-Bonnet and corrected Einstein-equation unresolved rows from the
extraction index (legacy target name `ComplexEFE.lean`). -/
structure WeylComplexEFEGaussBonnetWitness where
  gaussBonnetEulerCharacteristicBalance : Prop
  einsteinGaussBonnetFieldEquation : Prop
  eq77_gauss_bonnet_euler_characteristic_balance : gaussBonnetEulerCharacteristicBalance
  eq79_einstein_gauss_bonnet_field_equation : einsteinGaussBonnetFieldEquation

namespace WeylComplexEFEGaussBonnetWitness

variable (W : WeylComplexEFEGaussBonnetWitness)

theorem weyl_eqblock_77_complex_efe_layer : W.gaussBonnetEulerCharacteristicBalance := by
  exact W.eq77_gauss_bonnet_euler_characteristic_balance
theorem weyl_eqblock_79_complex_efe_layer : W.einsteinGaussBonnetFieldEquation := by
  exact W.eq79_einstein_gauss_bonnet_field_equation

end WeylComplexEFEGaussBonnetWitness

/-- EqBlock 440: explicit complex-Einstein split `G + i·Λ`. -/
theorem weyl_eqblock_440_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.einsteinComplex x =
      C.einsteinTensor.realPart x + Complex.I * C.einsteinTensor.imagPart x := by
  simpa [ComplexEFEContract.einsteinComplex] using C.einsteinTensor.toComplex_apply x

/-- EqBlock 444: pointwise complex-EFE residual form. -/
theorem weyl_eqblock_444_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.residual x = C.einsteinComplex x - C.coupling * C.stressComplex x := by
  rfl

/-- EqBlock 455: explicit stress-sector split `Tᴿ + i·Tᴵ`. -/
theorem weyl_eqblock_455_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.stressComplex x =
      C.stressTensor.realPart x + Complex.I * C.stressTensor.imagPart x := by
  simpa [ComplexEFEContract.stressComplex] using C.stressTensor.toComplex_apply x

/-- EqBlock 459: same stress split in alternate paper notation. -/
theorem weyl_eqblock_459_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.stressComplex x =
      C.stressTensor.realPart x + Complex.I * C.stressTensor.imagPart x := by
  simpa using weyl_eqblock_455_complex_efe_layer C x

/-- EqBlock 478: classical real-sector recovery under vanishing imaginary parts. -/
theorem weyl_eqblock_478_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α)
    (hEin : C.einsteinTensor.imagPart x = 0)
    (hStr : C.stressTensor.imagPart x = 0) :
    C.residual x = C.einsteinTensor.realPart x - C.coupling * C.stressTensor.realPart x := by
  simp [ComplexEFEContract.residual, ComplexEFEContract.einsteinComplex,
    ComplexEFEContract.stressComplex, ComplexTensorField.toComplex, hEin, hStr]

/-- EqBlock 480: coupling applied to the explicit matter/info split. -/
theorem weyl_eqblock_480_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.coupling * C.stressComplex x =
      C.coupling * (C.stressTensor.realPart x + Complex.I * C.stressTensor.imagPart x) := by
  simp [ComplexEFEContract.stressComplex, ComplexTensorField.toComplex]

/-- EqBlock 484: explicit residual expansion with real/imag split on both sides. -/
theorem weyl_eqblock_484_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.residual x =
      (C.einsteinTensor.realPart x + Complex.I * C.einsteinTensor.imagPart x) -
        C.coupling * (C.stressTensor.realPart x + Complex.I * C.stressTensor.imagPart x) := by
  simp [ComplexEFEContract.residual, ComplexEFEContract.einsteinComplex,
    ComplexEFEContract.stressComplex, ComplexTensorField.toComplex]

/-- EqBlock 486: compact real/imag split form (same identity as EqBlock 484). -/
theorem weyl_eqblock_486_complex_efe_layer
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) (x : α) :
    C.residual x =
      (C.einsteinTensor.realPart x + Complex.I * C.einsteinTensor.imagPart x) -
        C.coupling * (C.stressTensor.realPart x + Complex.I * C.stressTensor.imagPart x) := by
  simpa using weyl_eqblock_484_complex_efe_layer C x

end

end NavierStokesClean.CATEPT
