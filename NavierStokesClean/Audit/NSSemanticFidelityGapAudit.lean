import NavierStokesClean.Galerkin.EnstrophyNonIncrease

/-!
# Stage 297 (M1) — Semantic Fidelity Gap Audit (clean repo)

This file records, as proved Lean theorems, the semantic gaps that still remain
between the current abstract carrier and a fully spatial Navier–Stokes encoding.

Scope: M1 only. This file does not alter M2 proof obligations.
-/

set_option autoImplicit false

open NavierStokesClean NavierStokesClean.Galerkin MeasureTheory

namespace NavierStokesClean.SemanticFidelity

/-- G1: the abstract carrier is a single velocity vector in `ℝ³`. -/
theorem gap1_NSField_is_point_vector :
    NSField = EuclideanSpace ℝ (Fin 3) := rfl

/-- G1b: trajectories are time-indexed point vectors (no spatial argument). -/
theorem gap1b_Trajectory_is_time_only :
    Trajectory = (ℝ → EuclideanSpace ℝ (Fin 3)) := rfl

/-- G2: legacy abstract palinstrophy is definitionally the zero placeholder. -/
theorem gap2_palinstrophy_is_placeholder :
    palinstrophy = (fun _ : NSField => (0 : ℝ)) := rfl

/-- G2b: the canonical lift `trajectoryToSpatial` is constant in space at fixed `t`. -/
theorem gap2b_trajectoryToSpatial_is_constant_in_space (traj : Trajectory) :
    ∀ t : ℝ, ∀ x y : Space, trajectoryToSpatial traj t x = trajectoryToSpatial traj t y := by
  intro t x y
  rfl

/-- G3: lifted trajectories have identically zero vorticity at each time. -/
theorem gap3_vorticity_zero_for_lifted (traj : Trajectory) :
    ∀ t : ℝ, vorticity (trajectoryToSpatial traj t) = (fun _ => 0) := by
  intro t
  simpa using vorticity_zero_of_lifted traj t

/-- G3b: consequently, the spatial BKM vorticity integral of the lift is zero. -/
theorem gap3b_spatialBKM_zero_for_lifted (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    spatialBKMVorticityIntegral (trajectoryToSpatial traj) T = 0 :=
  spatialBKM_zero_of_constant_traj traj T hT

/-- G3c: legacy divergence theorem on abstract trajectories is propositionally vacuous. -/
theorem gap3c_legacy_divergence_theorem_is_vacuous (traj : Trajectory)
    (hNS : SatisfiesNSPDE nsNu traj) :
    True :=
  ns_divergence_free_satisfied traj hNS

/-! ## G4: PDE operator concretization gap (m04 record) -/

/-- G4: the enstrophy equation in `SatisfiesSpatialNSPDEFull` is a *structure hypothesis*,
    not derived from a concrete weak-form NS PDE.

    **Current state** (m04): `SatisfiesSpatialNSPDEFull.hEnstrophyEq` asserts
      HasDerivAt (fun s => spatialEnstrophy (traj s)) (−2ν·P + 2·VS) t
    as an axiomatically-held structure field. The equation is *correct* for smooth
    solutions — it is the direct consequence of multiplying NS by vorticity and
    integrating over T³ (Temam 1984, §III) — but its derivation from a concrete
    weak-form PDE requires:
    - A concrete weak formulation of NS on T³ (distributional sense)
    - Integration-by-parts on T³ (Sobolev trace on periodic domain)
    - The concrete Space↔Euc coercion (NSC-P33)

    **What m04 proves** (no new axioms beyond m01 surface):
    Given `hFull : SatisfiesSpatialNSPDEFull ν traj` and VS≤νP,
      - `enstrophy_deriv_le_zero`: d/dt Ω(t) ≤ 0 at each small-data t
      - `enstrophy_hasDerivAt_nonpos`: HasDerivAt with nonpositive value
      - `enstrophy_antitoneOn_small_data`: Ω(t₂) ≤ Ω(t₁) for t₁ ≤ t₂ in small-data regime
      - `enstrophy_bounded_by_initial_small_data`: Ω(T) ≤ Ω(0) for T ≥ 0

    **Remaining gap (NSC-P33)**: `hCont` (continuity of t ↦ spatialEnstrophy (traj t))
    is an explicit hypothesis in the antitone theorems because it requires parameter
    continuity of the spatial integral — a dominated convergence argument on the
    concrete T³ measure, not available until NSC-P33. -/
theorem gap4_enstrophy_eq_is_structure_hypothesis :
    ∀ (ν : ℝ) (traj : NSSpaceTrajectory),
      SatisfiesSpatialNSPDEFull ν traj →
      ∀ t : ℝ,
        HasDerivAt (fun s => spatialEnstrophy (traj s))
          (-2 * ν * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t)) t :=
  fun _ _ hFull t => hFull.hEnstrophyEq t

/-- G4b: with VS≤νP (SA-G1 + SA-G1b), the enstrophy derivative is provably ≤ 0. -/
theorem gap4b_enstrophy_nonincreasing_from_vsnup
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (t : ℝ)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    -2 * ν * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t) ≤ 0 :=
  NavierStokesClean.Galerkin.enstrophy_deriv_le_zero traj ν hν hFull t hH1_t

end NavierStokesClean.SemanticFidelity
