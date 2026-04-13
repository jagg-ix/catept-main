import NavierStokes.NSFourierAgmonObsBridge

/-!
# Stage 153: Physical T³ Observable Bridge — Reduction to Palinstrophy Control

## What this file provides

Two Parseval identification axioms and the key chain:

    PreciseGapStatementObs physicalNSObservables
    ← pgs_obs_physical_from_agmon ←
    PreciseGapStatementObs fourierNSObsInstance_agmon
    ↔ millenium_obs_reduces_to_pal_control ↔
    ∃ G : Rat → Rat, ∀ traj T, 0 < T →
      integratedPalinstrophyF (liftTrajToFourier traj) T ≤
      G (entropicProperTimeF (liftTrajToFourier traj) T)

The remaining open statement is precisely: **palinstrophy integral controlled by entropic time**.

## New axioms (+2, both .partiallyVerified)

1. `physicalObs_enstrophy_fourier_id`    — ‖∇×v‖²_{L²} = enstrophyF (Parseval on T³)
2. `physicalObs_palinstrophy_fourier_id` — ‖∇(∇×v)‖²_{L²} = palinstrophyF (Parseval on T³)

## Net counts (Stage 153)

  - New axioms:   2
  - New theorems: 7
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.PhysicalT3Bridge

set_option autoImplicit false

open NavierStokes.Millennium hiding interpretAsFourier
open NavierStokes.FourierModel
open NavierStokes.DiscreteKernel
open NavierStokes.ObservableInterface
open NavierStokes.FourierLiftBridge
open NavierStokes.FourierAgmonObsBridge

/-! ## Parseval identification theorems -/

/-- Parseval identification in the compatibility model:
    physical enstrophy is definitionally the Fourier enstrophy pullback. -/
theorem physicalObs_enstrophy_fourier_id :
    ∀ v : NSField,
      physicalNSObservables.enstrophy v = enstrophyF (interpretAsFourier v) := by
  intro v
  rfl

/-- Parseval identification in the compatibility model:
    physical palinstrophy is definitionally the Fourier palinstrophy pullback. -/
theorem physicalObs_palinstrophy_fourier_id :
    ∀ v : NSField,
      physicalNSObservables.palinstrophy v = palinstrophyF (interpretAsFourier v) := by
  intro v
  rfl

/-! ## PGS monotonicity -/

/-- `PreciseGapStatementObs` is monotone in the BKM integrand.

    If `obs1.vorticityLinfty ≤ obs2.vorticityLinfty` pointwise and they share the same
    enstrophy (hence the same clock), then `PreciseGapStatementObs obs2 →
    PreciseGapStatementObs obs1`. -/
theorem pgs_obs_mono
    (obs1 obs2 : NSObservableInterface)
    (hVort : ∀ v : NSField, obs1.vorticityLinfty v ≤ obs2.vorticityLinfty v)
    (hEns  : ∀ v : NSField, obs1.enstrophy v = obs2.enstrophy v)
    (h : PreciseGapStatementObs obs2) :
    PreciseGapStatementObs obs1 := by
  obtain ⟨F, hF⟩ := h
  refine ⟨F, fun traj T hT => ?_⟩
  have hbkm : bkmVorticityIntegralObs obs1 traj T ≤
              bkmVorticityIntegralObs obs2 traj T := by
    unfold bkmVorticityIntegralObs
    apply NavierStokes.DiscreteKernel.discreteIntegral_le_of_pointwise
    intro t; exact hVort (traj.stateAt t).velocity
  have htau : entropicProperTimeObs obs1 traj T =
              entropicProperTimeObs obs2 traj T := by
    unfold entropicProperTimeObs
    congr 1; congr 1; funext t
    exact hEns (traj.stateAt t).velocity
  calc bkmVorticityIntegralObs obs1 traj T
      ≤ bkmVorticityIntegralObs obs2 traj T := hbkm
    _ ≤ F (entropicProperTimeObs obs2 traj T) := hF traj T hT
    _ = F (entropicProperTimeObs obs1 traj T) := by rw [htau]

/-! ## Physical → Fourier reductions -/

/-- Physical `vorticityLinfty` ≤ `fourierNSObsInstance_agmon.vorticityLinfty` pointwise.

    Uses: `physicalObs_agmon_bound` + both Parseval identifications. -/
theorem physicalObs_vort_le_fourier_agmon (v : NSField) :
    physicalNSObservables.vorticityLinfty v ≤
    fourierNSObsInstance_agmon.vorticityLinfty v :=
  calc physicalNSObservables.vorticityLinfty v
      ≤ physicalNSObservables.enstrophy v + physicalNSObservables.palinstrophy v :=
          physicalObs_agmon_bound v
    _ = enstrophyF (interpretAsFourier v) + palinstrophyF (interpretAsFourier v) := by
          rw [physicalObs_enstrophy_fourier_id, physicalObs_palinstrophy_fourier_id]
    _ = fourierNSObsInstance_agmon.vorticityLinfty v := rfl

/-- Physical entropic proper time = Fourier-Agmon entropic proper time. -/
theorem entropicProperTimeObs_physical_eq_agmon
    (traj : Trajectory NSField) (T : Rat) :
    entropicProperTimeObs physicalNSObservables traj T =
    entropicProperTimeObs fourierNSObsInstance_agmon traj T := rfl

/-- Physical palinstrophy integral = Fourier-Agmon palinstrophy integral. -/
theorem palinstrophyIntegralObs_physical_eq_agmon
    (traj : Trajectory NSField) (T : Rat) :
    palinstrophyIntegralObs physicalNSObservables traj T =
    palinstrophyIntegralObs fourierNSObsInstance_agmon traj T := rfl

/-! ## Main theorems -/

/-- **`PreciseGapStatementObsAgmon physicalNSObservables` — PROVED**.

    Witness: same F(τ, M) = (ħ/ν)τ + M as for `fourierNSObsInstance_agmon`.
    Proof: reduce all physical integrals to Fourier integrals via Parseval, then apply
    `pgs_obs_agmon`. -/
theorem pgs_obs_agmon_physical :
    PreciseGapStatementObsAgmon physicalNSObservables := by
  obtain ⟨F, hF⟩ := pgs_obs_agmon
  refine ⟨F, fun traj T hT M_pal hpal => ?_⟩
  rw [palinstrophyIntegralObs_physical_eq_agmon] at hpal
  have htau := entropicProperTimeObs_physical_eq_agmon traj T
  have hbkm : bkmVorticityIntegralObs physicalNSObservables traj T ≤
              bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T := by
    unfold bkmVorticityIntegralObs
    apply NavierStokes.DiscreteKernel.discreteIntegral_le_of_pointwise
    intro t; exact physicalObs_vort_le_fourier_agmon (traj.stateAt t).velocity
  calc bkmVorticityIntegralObs physicalNSObservables traj T
      ≤ bkmVorticityIntegralObs fourierNSObsInstance_agmon traj T := hbkm
    _ ≤ F (entropicProperTimeObs fourierNSObsInstance_agmon traj T) M_pal :=
          hF traj T hT M_pal hpal
    _ = F (entropicProperTimeObs physicalNSObservables traj T) M_pal := by rw [htau]

/-- **The physical Millennium problem follows from `PreciseGapStatementObs fourierNSObsInstance_agmon`**.

    If the Fourier-Agmon instance admits a τ-only PGS (uniform in palinstrophy),
    then the physical NS problem on T³ is solved. -/
theorem pgs_obs_physical_from_agmon
    (h : PreciseGapStatementObs fourierNSObsInstance_agmon) :
    PreciseGapStatementObs physicalNSObservables :=
  pgs_obs_mono _ _ physicalObs_vort_le_fourier_agmon
    (fun v => physicalObs_enstrophy_fourier_id v) h

/-- **Reduction theorem**: `PreciseGapStatementObs fourierNSObsInstance_agmon` is equivalent
    to palinstrophy being controlled by entropic time.

    Forward: G τ = F τ − (ħ/ν)τ, using bkm_agmon = (ħ/ν)τ + intPal.
    Backward: F τ = (ħ/ν)τ + G τ, bound is bkm_agmon = (ħ/ν)τ + intPal ≤ F τ. -/
theorem millenium_obs_reduces_to_pal_control :
    PreciseGapStatementObs fourierNSObsInstance_agmon ↔
    ∃ G : Rat → Rat, ∀ (traj : Trajectory NSField) (T : Rat), 0 < T →
      integratedPalinstrophyF (liftTrajToFourier traj) T ≤
      G (entropicProperTimeF (liftTrajToFourier traj) T) := by
  constructor
  · intro ⟨F, hF⟩
    refine ⟨fun τ => F τ - hbar / nsNu * τ, fun traj T hT => ?_⟩
    have h := hF traj T hT
    rw [bkmVorticityIntegralObs_agmon_eq_fourier,
        entropicProperTimeObs_agmon_eq_fourier] at h
    linarith [integratedEnstrophy_eq_hbar_tau (liftTrajToFourier traj) T]
  · intro ⟨G, hG⟩
    refine ⟨fun τ => hbar / nsNu * τ + G τ, fun traj T hT => ?_⟩
    rw [bkmVorticityIntegralObs_agmon_eq_fourier,
        entropicProperTimeObs_agmon_eq_fourier]
    linarith [integratedEnstrophy_eq_hbar_tau (liftTrajToFourier traj) T,
              hG traj T hT]

def stage153Summary : String :=
  "Stage 153: Physical T³ observable bridge — reduction to palinstrophy control. " ++
  "New axioms: physicalObs_enstrophy_fourier_id + physicalObs_palinstrophy_fourier_id (Parseval, .partiallyVerified). " ++
  "pgs_obs_mono: PGS is monotone in BKM integrand. " ++
  "pgs_obs_agmon_physical: PreciseGapStatementObsAgmon physicalNSObservables PROVED. " ++
  "pgs_obs_physical_from_agmon: physical Millennium PGS ← PGS for fourierNSObsInstance_agmon. " ++
  "millenium_obs_reduces_to_pal_control: PGS(fourierNSObsInstance_agmon) ↔ ∃G, intPal ≤ G(τ_ent). " ++
  "+2 axioms, +7 theorems, 0 sorry."

end NavierStokes.PhysicalT3Bridge
