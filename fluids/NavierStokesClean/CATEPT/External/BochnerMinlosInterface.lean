import NavierStokesClean.CATEPT.MeasurePathIntegral
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral

/-!
# CATEPT External Interface: Bochner/Minlos

Opt-in compatibility contracts for integrating external Bochner/Minlos
formalizations with the existing CAT/EPT measure-path-integral layer.

No external dependency is imported here; this file only defines the contract
surface that an external port must satisfy.
-/

set_option autoImplicit false

open MeasureTheory

namespace NavierStokesClean.CATEPT.External

noncomputable section

namespace MeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (m : NavierStokesClean.CATEPT.MeasurePathIntegralModel α)

/-- Contract witness that an external Bochner/Minlos characteristic functional
matches CAT/EPT source-coupled partition data. -/
structure BochnerMinlosCertificate where
  characteristicFunctional : (α → ℂ) → ℂ
  normalized : characteristicFunctional (fun _ => 0) = 1
  matches_sourceCoupledPartition :
    ∀ J : α → ℂ, characteristicFunctional J = m.sourceCoupledPartition J

/-- At zero source, the external characteristic functional equals CAT/EPT partition. -/
theorem BochnerMinlosCertificate.zero_source_eq_partition
    (w : BochnerMinlosCertificate m) :
    w.characteristicFunctional (fun _ => 0) = m.partition := by
  calc
    w.characteristicFunctional (fun _ => 0)
        = m.sourceCoupledPartition (fun _ => 0) := w.matches_sourceCoupledPartition _
    _ = m.partition := m.sourceCoupledPartition_zero

/-- If the external witness is normalized at zero source, CAT/EPT partition is normalized too. -/
theorem BochnerMinlosCertificate.partition_eq_one
    (w : BochnerMinlosCertificate m) :
    m.partition = 1 := by
  calc
    m.partition = w.characteristicFunctional (fun _ => 0) :=
      (w.zero_source_eq_partition).symm
    _ = 1 := w.normalized

/-- Existing CAT/EPT finite-measure partition bound, exposed through the interface. -/
theorem bochner_partition_norm_bound [IsFiniteMeasure m.μ] :
    ‖m.partition‖ ≤ (m.μ Set.univ).toReal :=
  m.norm_partition_le_measure_univ_toReal

end MeasurePathIntegralModel

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel α)

/-- Contract witness for Minlos-style nuclear embedding data used by curved CAT/EPT models. -/
structure MinlosNuclearEmbeddingCertificate
    (c : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel α) where
  dualCarrier : Type*
  evaluation : dualCarrier → α → ℂ
  characteristicLift : dualCarrier → ℂ
  measurableEmbedding : Prop
  measurableEmbedding_holds : measurableEmbedding

/-- Minimal extraction theorem: the embedding contract exposes measurability metadata. -/
theorem MinlosNuclearEmbeddingCertificate.has_measurableEmbedding
    (w : MinlosNuclearEmbeddingCertificate c) :
    w.measurableEmbedding :=
  w.measurableEmbedding_holds

end CurvedMeasurePathIntegralModel

end

end NavierStokesClean.CATEPT.External
