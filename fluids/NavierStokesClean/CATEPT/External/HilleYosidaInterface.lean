import NavierStokesClean.CATEPT.ModularFlowKucharBridge

/-!
# CATEPT External Interface: Hille-Yosida / Semigroup

Opt-in semigroup contracts connecting external Hille-Yosida resolvent/generator
results to CAT/EPT modular-time witnesses.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

namespace CurvedMeasurePathIntegralModel

open NavierStokesClean.CATEPT

/-- Hille-Yosida style package layered over the existing QRF semigroup witness. -/
structure HilleYosidaSemigroupCertificate (State : Type*) where
  qrf : CurvedMeasurePathIntegralModel.QRFTimeSemigroupWitness State
  generator : State → State
  resolvent : ℝ → State → State
  resolvent_consistency :
    ∀ τ s, resolvent τ s = qrf.act τ s
  contractionContract : Prop
  contractionContract_holds : contractionContract

/-- The QRF semigroup law remains available through the Hille-Yosida certificate. -/
theorem HilleYosidaSemigroupCertificate.semigroup_law
    {State : Type*} (w : HilleYosidaSemigroupCertificate State) :
    ∀ τ₁ τ₂ s, w.qrf.act (τ₁ + τ₂) s = w.qrf.act τ₁ (w.qrf.act τ₂ s) :=
  CurvedMeasurePathIntegralModel.paper5_eq_qrf_semigroup_tau w.qrf

/-- Resolvent contract projects to the semigroup action used by the modular-time layer. -/
theorem HilleYosidaSemigroupCertificate.resolvent_matches_semigroup
    {State : Type*} (w : HilleYosidaSemigroupCertificate State) :
    ∀ τ s, w.resolvent τ s = w.qrf.act τ s :=
  w.resolvent_consistency

/-- Keep explicit access to the external contraction contract witness. -/
theorem HilleYosidaSemigroupCertificate.has_contractionContract
    {State : Type*} (w : HilleYosidaSemigroupCertificate State) :
    w.contractionContract :=
  w.contractionContract_holds

end CurvedMeasurePathIntegralModel

end

end NavierStokesClean.CATEPT.External
