import NavierStokes.Popkov.PopkovZenoBridge

/-!
# Popkov Governance Quantitative Bridge

Small bridge layer that makes the reduced-carrier governance direction explicit:
quantitative correspondence witnesses imply `TrajGovernedByLiouvillian`.

This module is intentionally lightweight; it is a staging point for replacing
reduced-carrier shims with non-placeholder quantitative semantics.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-- Structural witness package for the Lindbladian correspondence.

`perturbationEnvelope` is the executable piece used by the current
`TrajGovernedByLiouvillian` predicate; the other fields reserve slots for
future non-placeholder semantics. -/
structure LindbladianCorrespondenceWitness
    (pld : PopkovLiouvillianData)
    (traj : Trajectory NSField) where
  projectedEvolutionWitness : Prop
  darkSubspaceInvariant : Prop
  perturbationEnvelope :
    ∀ (t : Rat), 0 ≤ t →
      vortexStretchingIntegral traj t ≤
        pld.perturbationNorm * enstrophy (traj.stateAt t).velocity

/-- Any correspondence witness provides trajectory governance. -/
theorem traj_governed_of_lindbladian_correspondence
    (pld : PopkovLiouvillianData)
    (traj : Trajectory NSField)
    (hCorr : LindbladianCorrespondenceWitness pld traj) :
    TrajGovernedByLiouvillian pld traj :=
  hCorr.perturbationEnvelope

/-- Quantitative Popkov-decay witness for a concrete horizon `T`. -/
structure PopkovDecayQuantitativeWitness
    (traj : Trajectory NSField) (T : Rat) where
  bkmBound : Rat
  bkmBound_pos : 0 < bkmBound
  bkmBound_spec : bkmVorticityIntegral traj T ≤ bkmBound

/-- Any quantitative witness yields the existential Popkov-style bound. -/
theorem popkov_decay_exists_of_quantitative_witness
    (traj : Trajectory NSField) (T : Rat)
    (w : PopkovDecayQuantitativeWitness traj T) :
    ∃ (bound : Rat), 0 < bound ∧ bkmVorticityIntegral traj T ≤ bound :=
  ⟨w.bkmBound, w.bkmBound_pos, w.bkmBound_spec⟩

/-- Convenient constructor for the Cameron Liouvillian case from a VS-ratio bound. -/
def nsCameronCorrespondenceWitnessOfVSBound
    (G : GalerkinLevel)
    (traj : Trajectory NSField)
    (hVS : ∀ (t : Rat), 0 ≤ t →
      vortexStretchingIntegral traj t ≤
        cameronWeightedPerturbationNorm G * enstrophy (traj.stateAt t).velocity) :
    LindbladianCorrespondenceWitness (nsCameronLiouvillian G) traj where
  projectedEvolutionWitness := True
  darkSubspaceInvariant := True
  perturbationEnvelope := by
    intro t ht
    simpa [nsCameronLiouvillian] using hVS t ht

end

end NavierStokes.Millennium
